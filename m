From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 06/10] ixgbe: fix race conditions on
	queuing skb for HW time stamp
Date: Fri, 14 Mar 2014 18:34:37 +0100
Message-ID: <1394818481-7652-7-git-send-email-kubakici@wp.pl>
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

ixgbe has a single set of TX time stamping resources per NIC.
Use a simple bit lock to avoid race conditions and leaking skbs
when multiple TX rings try to claim time stamping.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 3 +++
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 2fff0fc..26d27aa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -812,6 +812,7 @@ enum ixgbe_state_t {
 	__IXGBE_SERVICE_SCHED,
 	__IXGBE_IN_SFP_INIT,
 	__IXGBE_PTP_RUNNING,
+	__IXGBE_PTP_TX_IN_PROGRESS,
 };
 
 struct ixgbe_cb {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f6ac11c..42aa708 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7031,7 +7031,9 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		tx_flags |= IXGBE_TX_FLAGS_SW_VLAN;
 	}
 
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
+		     !test_and_set_bit_lock(__IXGBE_PTP_TX_IN_PROGRESS,
+					    &adapter->state))) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 8b527d7..63515a6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -493,6 +493,7 @@ static void ixgbe_ptp_tx_hwtstamp(struct ixgbe_adapter *adapter)
 
 	dev_kfree_skb_any(adapter->ptp_tx_skb);
 	adapter->ptp_tx_skb = NULL;
+	clear_bit_unlock(__IXGBE_PTP_TX_IN_PROGRESS, &adapter->state);
 }
 
 /**
@@ -515,6 +516,7 @@ static void ixgbe_ptp_tx_hwtstamp_work(struct work_struct *work)
 	if (timeout) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
+		clear_bit_unlock(__IXGBE_PTP_TX_IN_PROGRESS, &adapter->state);
 		e_warn(drv, "clearing Tx Timestamp hang");
 		return;
 	}
@@ -925,6 +927,7 @@ void ixgbe_ptp_stop(struct ixgbe_adapter *adapter)
 	if (adapter->ptp_tx_skb) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
+		clear_bit_unlock(__IXGBE_PTP_TX_IN_PROGRESS, &adapter->state);
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
