From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 3/4] e1000e: use mc helpers to
	access	multicast list
Date: Thu, 22 Oct 2009 15:54:05 +0200
Message-ID: <20091022135404.GF2868@psychotron.lab.eng.brq.redhat.com>
References: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	mchehab@infradead.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	linux-media@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/e1000e/netdev.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3769248..97cd106 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2529,6 +2529,17 @@ static void e1000_update_mc_addr_list(struct e1000_hw *hw, u8 *mc_addr_list,
 }
 
 /**
+ * e1000_mc_walker - helper function
+ **/
+static void e1000_mc_walker(void *data, unsigned char *addr)
+{
+	u8 **mta_list_i = data;
+
+	memcpy(*mta_list_i, addr, ETH_ALEN);
+	*mta_list_i += ETH_ALEN;
+}
+
+/**
  * e1000_set_multi - Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -2542,10 +2553,9 @@ static void e1000_set_multi(struct net_device *netdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
-	struct dev_mc_list *mc_ptr;
-	u8  *mta_list;
+	u8  *mta_list, *mta_list_i;
 	u32 rctl;
-	int i;
+	int mc_count;
 
 	/* Check for Promiscuous and All Multicast modes */
 
@@ -2567,23 +2577,17 @@ static void e1000_set_multi(struct net_device *netdev)
 
 	ew32(RCTL, rctl);
 
-	if (netdev->mc_count) {
-		mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+	mc_count = netdev_mc_count(netdev);
+	if (mc_count) {
+		mta_list = kmalloc(mc_count * ETH_ALEN, GFP_ATOMIC);
 		if (!mta_list)
 			return;
 
 		/* prepare a packed array of only addresses. */
-		mc_ptr = netdev->mc_list;
-
-		for (i = 0; i < netdev->mc_count; i++) {
-			if (!mc_ptr)
-				break;
-			memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
-			       ETH_ALEN);
-			mc_ptr = mc_ptr->next;
-		}
+		mta_list_i = mta_list;
+		netdev_mc_walk(netdev, e1000_mc_walker, &mta_list_i);
 
-		e1000_update_mc_addr_list(hw, mta_list, i, 1,
+		e1000_update_mc_addr_list(hw, mta_list, mc_count, 1,
 					  mac->rar_entry_count);
 		kfree(mta_list);
 	} else {
-- 
1.6.2.5


------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
