From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH net v3 1/4] e1000e: Fix a null deference in
	e1000_open
Date: Thu, 25 Dec 2014 09:57:00 +0800
Message-ID: <1419472623-6060-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>, linux.nics@intel.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com, mitch.a.williams@intel.com
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

The function vzalloc is called by e1000e_setup_rx_resources (in
e1000_open) when initializing the ethernet card driver. But when vzalloc is
failed, "err" segment in e1000e_setup_rx_resources is executed to return,
and then e1000e_free_tx_resources in "err_setup_rx" segment is executed to 
halt e1000_open. However, "writel(0, tx_ring->head)" statement in
e1000_clean_tx_ring in e1000e_free_tx_resources will cause system crash,
because "tx_ring->head" is not assigned the value. In the code,
"tx_ring->head" is initialized in e1000_configure_tx in e1000_configure
after the e1000e_setup_rx_resources.
This patch fixes this problem, and it has been tested on the hardware.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 247335d..728328b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1737,6 +1737,8 @@ static void e1000_clean_rx_ring(struct e1000_ring *rx_ring)
 	rx_ring->next_to_use = 0;
 	adapter->flags2 &= ~FLAG2_IS_DISCARDING;
 
+	if (!rx_ring->head)
+		return;
 	writel(0, rx_ring->head);
 	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
 		e1000e_update_rdt_wa(rx_ring, 0);
@@ -2444,6 +2446,8 @@ static void e1000_clean_tx_ring(struct e1000_ring *tx_ring)
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
+	if (!tx_ring->head)
+		return;
 	writel(0, tx_ring->head);
 	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
 		e1000e_update_tdt_wa(tx_ring, 0);
@@ -4357,6 +4361,9 @@ static int e1000_open(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 
+	adapter->tx_ring->head = NULL;
+	adapter->rx_ring->head = NULL;
+
 	/* allocate transmit descriptors */
 	err = e1000e_setup_tx_resources(adapter->tx_ring);
 	if (err)
-- 
1.7.9.5



------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
