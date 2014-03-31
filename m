From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] ixgbe: fix race conditions on queuing skb for HW time stamp
Date: Mon, 31 Mar 2014 16:34:50 -0700
Message-ID: <1396308899-20926-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34702 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbaCaXga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:30 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

ixgbe has a single set of TX time stamping resources per NIC.
Use a simple bit lock to avoid race conditions and leaking skbs
when multiple TX rings try to claim time stamping.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
index 24538cb..c4b930c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7042,7 +7042,9 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
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
1.9.0
