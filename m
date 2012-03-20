From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net] e1000: fix vlan processing regression
Date: Tue, 20 Mar 2012 10:57:53 +0100
Message-ID: <1332237473-11311-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch fixes a regression introduced by commit "e1000: do vlan
cleanup (799d531)".

Apparently some e1000 chips (not mine) are sensitive about the order of
setting vlan filter and vlan stripping/inserting functionality. So this
patch changes the order so it's the same as before vlan cleanup.

Reported-by: Ben Greear <greearb@candelatech.com>
Tested-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   35 +++++++++++++++---------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index d94d64b..b444f21 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -164,6 +164,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
 static bool e1000_vlan_used(struct e1000_adapter *adapter);
 static void e1000_vlan_mode(struct net_device *netdev,
 			    netdev_features_t features);
+static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
+				     bool filter_on);
 static int e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static int e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -1213,7 +1215,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	e1000_vlan_mode(netdev, netdev->features);
+	e1000_vlan_filter_on_off(adapter, false);
 
 	/* print bus type/speed/width info */
 	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
@@ -4549,6 +4551,22 @@ static bool e1000_vlan_used(struct e1000_adapter *adapter)
 	return false;
 }
 
+static void __e1000_vlan_mode(struct e1000_adapter *adapter,
+			      netdev_features_t features)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl;
+
+	ctrl = er32(CTRL);
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* enable VLAN tag insert/strip */
+		ctrl |= E1000_CTRL_VME;
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl &= ~E1000_CTRL_VME;
+	}
+	ew32(CTRL, ctrl);
+}
 static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 				     bool filter_on)
 {
@@ -4558,6 +4576,7 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
 
+	__e1000_vlan_mode(adapter, adapter->netdev->features);
 	if (filter_on) {
 		/* enable VLAN receive filtering */
 		rctl = er32(RCTL);
@@ -4578,24 +4597,14 @@ static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
 }
 
 static void e1000_vlan_mode(struct net_device *netdev,
-	netdev_features_t features)
+			    netdev_features_t features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
 
-	ctrl = er32(CTRL);
-	if (features & NETIF_F_HW_VLAN_RX) {
-		/* enable VLAN tag insert/strip */
-		ctrl |= E1000_CTRL_VME;
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl &= ~E1000_CTRL_VME;
-	}
-	ew32(CTRL, ctrl);
+	__e1000_vlan_mode(adapter, features);
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
-- 
1.7.6.4


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
