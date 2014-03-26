From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] igb: fix race conditions on queuing skb for HW time stamp
Date: Wed, 26 Mar 2014 11:03:33 -0700
Message-ID: <1395857013-7568-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52739 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755645AbaCZSEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:33 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

igb has a single set of TX time stamping resources per NIC.
Use a simple bit lock to avoid race conditions and leaking skbs
when multiple TX rings try to claim time stamping.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      | 3 ++-
 drivers/net/ethernet/intel/igb/igb_main.c | 3 ++-
 drivers/net/ethernet/intel/igb/igb_ptp.c  | 3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 411b213..7fbe1e9 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -492,7 +492,8 @@ struct igb_adapter {
 enum e1000_state_t {
 	__IGB_TESTING,
 	__IGB_RESETTING,
-	__IGB_DOWN
+	__IGB_DOWN,
+	__IGB_PTP_TX_IN_PROGRESS,
 };
 
 enum igb_boards {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1fdffa2..55fc559 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4983,7 +4983,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 
-		if (!(adapter->ptp_tx_skb)) {
+		if (!test_and_set_bit_lock(__IGB_PTP_TX_IN_PROGRESS,
+					   &adapter->state)) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= IGB_TX_FLAGS_TSTAMP;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index da55fbb..2cca8fd 100644
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
@@ -857,6 +859,7 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 	if (adapter->ptp_tx_skb) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
+		clear_bit_unlock(__IGB_PTP_TX_IN_PROGRESS, &adapter->state);
 	}
 
 	if (adapter->ptp_clock) {
-- 
1.8.3.1
