From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 8/8] qlge: Add CBFC pause frame counters to ethtool stats.
Date: Sat, 10 Oct 2009 12:35:10 -0700
Message-ID: <1255203310-18114-9-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934793AbZJJTnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:43:46 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |   21 ++++++++++++
 drivers/net/qlge/qlge_ethtool.c |   69 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 633fcd1..fd47691 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1363,6 +1363,27 @@ struct nic_stats {
 	u64 rx_1024_to_1518_pkts;
 	u64 rx_1519_to_max_pkts;
 	u64 rx_len_err_pkts;
+	/*
+	 * These stats come from offset 500h to 5C8h
+	 * in the XGMAC register.
+	 */
+	u64 tx_cbfc_pause_frames0;
+	u64 tx_cbfc_pause_frames1;
+	u64 tx_cbfc_pause_frames2;
+	u64 tx_cbfc_pause_frames3;
+	u64 tx_cbfc_pause_frames4;
+	u64 tx_cbfc_pause_frames5;
+	u64 tx_cbfc_pause_frames6;
+	u64 tx_cbfc_pause_frames7;
+	u64 rx_cbfc_pause_frames0;
+	u64 rx_cbfc_pause_frames1;
+	u64 rx_cbfc_pause_frames2;
+	u64 rx_cbfc_pause_frames3;
+	u64 rx_cbfc_pause_frames4;
+	u64 rx_cbfc_pause_frames5;
+	u64 rx_cbfc_pause_frames6;
+	u64 rx_cbfc_pause_frames7;
+	u64 rx_nic_fifo_drop;
 };
 
 /*
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 5207394..aac6c6f 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -132,6 +132,41 @@ static void ql_update_stats(struct ql_adapter *qdev)
 		iter++;
 	}
 
+	/*
+	 * Get Per-priority TX pause frame counter statistics.
+	 */
+	for (i = 0x500; i < 0x540; i += 8) {
+		if (ql_read_xgmac_reg64(qdev, i, &data)) {
+			QPRINTK(qdev, DRV, ERR,
+				"Error reading status register 0x%.04x.\n", i);
+			goto end;
+		} else
+			*iter = data;
+		iter++;
+	}
+
+	/*
+	 * Get Per-priority RX pause frame counter statistics.
+	 */
+	for (i = 0x568; i < 0x5a8; i += 8) {
+		if (ql_read_xgmac_reg64(qdev, i, &data)) {
+			QPRINTK(qdev, DRV, ERR,
+				"Error reading status register 0x%.04x.\n", i);
+			goto end;
+		} else
+			*iter = data;
+		iter++;
+	}
+
+	/*
+	 * Get RX NIC FIFO DROP statistics.
+	 */
+	if (ql_read_xgmac_reg64(qdev, 0x5b8, &data)) {
+		QPRINTK(qdev, DRV, ERR,
+			"Error reading status register 0x%.04x.\n", i);
+		goto end;
+	} else
+		*iter = data;
 end:
 	ql_sem_unlock(qdev, qdev->xg_sem_mask);
 quit:
@@ -185,6 +220,23 @@ static char ql_stats_str_arr[][ETH_GSTRING_LEN] = {
 	{"rx_1024_to_1518_pkts"},
 	{"rx_1519_to_max_pkts"},
 	{"rx_len_err_pkts"},
+	{"tx_cbfc_pause_frames0"},
+	{"tx_cbfc_pause_frames1"},
+	{"tx_cbfc_pause_frames2"},
+	{"tx_cbfc_pause_frames3"},
+	{"tx_cbfc_pause_frames4"},
+	{"tx_cbfc_pause_frames5"},
+	{"tx_cbfc_pause_frames6"},
+	{"tx_cbfc_pause_frames7"},
+	{"rx_cbfc_pause_frames0"},
+	{"rx_cbfc_pause_frames1"},
+	{"rx_cbfc_pause_frames2"},
+	{"rx_cbfc_pause_frames3"},
+	{"rx_cbfc_pause_frames4"},
+	{"rx_cbfc_pause_frames5"},
+	{"rx_cbfc_pause_frames6"},
+	{"rx_cbfc_pause_frames7"},
+	{"rx_nic_fifo_drop"},
 };
 
 static void ql_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
@@ -257,6 +309,23 @@ ql_get_ethtool_stats(struct net_device *ndev,
 	*data++ = s->rx_1024_to_1518_pkts;
 	*data++ = s->rx_1519_to_max_pkts;
 	*data++ = s->rx_len_err_pkts;
+	*data++ = s->tx_cbfc_pause_frames0;
+	*data++ = s->tx_cbfc_pause_frames1;
+	*data++ = s->tx_cbfc_pause_frames2;
+	*data++ = s->tx_cbfc_pause_frames3;
+	*data++ = s->tx_cbfc_pause_frames4;
+	*data++ = s->tx_cbfc_pause_frames5;
+	*data++ = s->tx_cbfc_pause_frames6;
+	*data++ = s->tx_cbfc_pause_frames7;
+	*data++ = s->rx_cbfc_pause_frames0;
+	*data++ = s->rx_cbfc_pause_frames1;
+	*data++ = s->rx_cbfc_pause_frames2;
+	*data++ = s->rx_cbfc_pause_frames3;
+	*data++ = s->rx_cbfc_pause_frames4;
+	*data++ = s->rx_cbfc_pause_frames5;
+	*data++ = s->rx_cbfc_pause_frames6;
+	*data++ = s->rx_cbfc_pause_frames7;
+	*data++ = s->rx_nic_fifo_drop;
 }
 
 static int ql_get_settings(struct net_device *ndev,
-- 
1.6.0.2

