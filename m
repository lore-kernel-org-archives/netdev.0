From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 08/10] igb: fix race conditions on
	queuing skb for HW time stamp
Date: Fri, 14 Mar 2014 18:34:39 +0100
Message-ID: <1394818481-7652-9-git-send-email-kubakici@wp.pl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

igb has a single set of TX time stamping resources per NIC.
Use a simple bit lock to avoid race conditions and leaking skbs
when multiple TX rings try to claim time stamping.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/igb/igb.h      | 3 ++-
 drivers/net/ethernet/intel/igb/igb_main.c | 3 ++-
 drivers/net/ethernet/intel/igb/igb_ptp.c  | 3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index a202c96..bb2298f 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -491,7 +491,8 @@ struct igb_adapter {
 enum e1000_state_t {
 	__IGB_TESTING,
 	__IGB_RESETTING,
-	__IGB_DOWN
+	__IGB_DOWN,
+	__IGB_PTP_TX_IN_PROGRESS,
 };
 
 enum igb_boards {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ee9a482..fb9db6e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4949,7 +4949,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 
-		if (!(adapter->ptp_tx_skb)) {
+		if (!test_and_set_bit_lock(__IGB_PTP_TX_IN_PROGRESS,
+					   &adapter->state)) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= IGB_TX_FLAGS_TSTAMP;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 9c9c141..2a83098 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -387,6 +387,7 @@ static void igb_ptp_tx_work(struct work_struct *work)
 				   IGB_PTP_TX_TIMEOUT)) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
+		clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
 		adapter->tx_hwtstamp_timeouts++;
 		dev_warn(&adapter->pdev->dev, "clearing Tx timestamp hang");
 		return;
@@ -480,6 +481,7 @@ static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 	skb_tstamp_tx(adapter->ptp_tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(adapter->ptp_tx_skb);
 	adapter->ptp_tx_skb = NULL;
+	clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
 }
 
 /**
@@ -842,6 +844,7 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 	if (adapter->ptp_tx_skb) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
+		clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
 	}
 
 	if (adapter->ptp_clock) {
-- 
1.8.5.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
