From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] i40e: fix race conditions on queuing skb for HW time stamp
Date: Wed, 16 Jul 2014 14:35:32 -0700
Message-ID: <1405546534-21025-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28354 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752673AbaGPVgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 17:36:13 -0400
In-Reply-To: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

i40e has a single set of TX time stamping resources per NIC.
Use a simple bit lock to avoid race conditions and leaking skbs
when multiple TX rings try to claim time stamping.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c  | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f7bf69f..29cd81a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -134,6 +134,7 @@ enum i40e_state_t {
 	__I40E_EMP_RESET_REQUESTED,
 	__I40E_FILTER_OVERFLOW_PROMISC,
 	__I40E_SUSPENDED,
+	__I40E_PTP_TX_IN_PROGRESS,
 	__I40E_BAD_EEPROM,
 	__I40E_DOWN_REQUESTED,
 };
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index c364781..582704a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -314,6 +314,7 @@ void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf)
 	skb_tstamp_tx(pf->ptp_tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(pf->ptp_tx_skb);
 	pf->ptp_tx_skb = NULL;
+	clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
 }
 
 /**
@@ -677,6 +678,7 @@ void i40e_ptp_stop(struct i40e_pf *pf)
 	if (pf->ptp_tx_skb) {
 		dev_kfree_skb_any(pf->ptp_tx_skb);
 		pf->ptp_tx_skb = NULL;
+		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
 	}
 
 	if (pf->ptp_clock) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f65d361..79489a8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1856,7 +1856,8 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	 * we are not already transmitting a packet to be timestamped
 	 */
 	pf = i40e_netdev_to_pf(tx_ring->netdev);
-	if (pf->ptp_tx && !pf->ptp_tx_skb) {
+	if (pf->ptp_tx &&
+	    !test_and_set_bit_lock(__I40E_PTP_TX_IN_PROGRESS, &pf->state)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		pf->ptp_tx_skb = skb_get(skb);
 	} else {
-- 
1.9.3
