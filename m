From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e/i40evf: Add a stat to track how many times we have to do a force WB
Date: Tue, 24 Nov 2015 16:04:38 -0800
Message-ID: <1448409886-90686-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14673 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603AbbKYAEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:52 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

When in NAPI with interrupts disabled, the HW needs to be forced to do a
write back on TX if the number of descriptors pending are less than a
cache line.

This stat helps keep track of how many times we get into this situation.

Change-ID: I76c1bcc7ebccd6bffcc5aa33bfe05f2fa1c9a984
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 5 ++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 4 +++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c  | 4 +++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h  | 1 +
 7 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 4dd3e26..ca07a7b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -487,6 +487,7 @@ struct i40e_vsi {
 	u32 tx_restart;
 	u32 tx_busy;
 	u64 tx_linearize;
+	u64 tx_force_wb;
 	u32 rx_buf_failed;
 	u32 rx_page_failed;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 3f385ff..eeb1af4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -88,6 +88,7 @@ static const struct i40e_stats i40e_gstrings_misc_stats[] = {
 	I40E_VSI_STAT("tx_broadcast", eth_stats.tx_broadcast),
 	I40E_VSI_STAT("rx_unknown_protocol", eth_stats.rx_unknown_protocol),
 	I40E_VSI_STAT("tx_linearize", tx_linearize),
+	I40E_VSI_STAT("tx_force_wb", tx_force_wb),
 };
 
 /* These PF_STATs might look like duplicates of some NETDEV_STATs,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 781a6f4..0e6abc2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -881,6 +881,7 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 	u64 bytes, packets;
 	unsigned int start;
 	u64 tx_linearize;
+	u64 tx_force_wb;
 	u64 rx_p, rx_b;
 	u64 tx_p, tx_b;
 	u16 q;
@@ -899,7 +900,7 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 	 */
 	rx_b = rx_p = 0;
 	tx_b = tx_p = 0;
-	tx_restart = tx_busy = tx_linearize = 0;
+	tx_restart = tx_busy = tx_linearize = tx_force_wb = 0;
 	rx_page = 0;
 	rx_buf = 0;
 	rcu_read_lock();
@@ -917,6 +918,7 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 		tx_restart += p->tx_stats.restart_queue;
 		tx_busy += p->tx_stats.tx_busy;
 		tx_linearize += p->tx_stats.tx_linearize;
+		tx_force_wb += p->tx_stats.tx_force_wb;
 
 		/* Rx queue is part of the same block as Tx queue */
 		p = &p[1];
@@ -934,6 +936,7 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 	vsi->tx_restart = tx_restart;
 	vsi->tx_busy = tx_busy;
 	vsi->tx_linearize = tx_linearize;
+	vsi->tx_force_wb = tx_force_wb;
 	vsi->rx_page_failed = rx_page;
 	vsi->rx_buf_failed = rx_buf;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 98680b6..dbd2bca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1925,8 +1925,10 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
 tx_only:
-		if (arm_wb)
+		if (arm_wb) {
+			q_vector->tx.ring[0].tx_stats.tx_force_wb++;
 			i40e_force_wb(vsi, q_vector);
+		}
 		return budget;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 6779fb7..dccc1eb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -202,6 +202,7 @@ struct i40e_tx_queue_stats {
 	u64 tx_busy;
 	u64 tx_done_old;
 	u64 tx_linearize;
+	u64 tx_force_wb;
 };
 
 struct i40e_rx_queue_stats {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index a4eea08..8629a9f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1363,8 +1363,10 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
 tx_only:
-		if (arm_wb)
+		if (arm_wb) {
+			q_vector->tx.ring[0].tx_stats.tx_force_wb++;
 			i40evf_force_wb(vsi, q_vector);
+		}
 		return budget;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index ebc1bf7..997b374 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -201,6 +201,7 @@ struct i40e_tx_queue_stats {
 	u64 tx_busy;
 	u64 tx_done_old;
 	u64 tx_linearize;
+	u64 tx_force_wb;
 };
 
 struct i40e_rx_queue_stats {
-- 
2.5.0
