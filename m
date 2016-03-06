From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 7/8] bnxt_en: Include hardware port statistics in ethtool -S.
Date: Sun,  6 Mar 2016 02:01:23 -0500
Message-ID: <1457247684-2403-8-git-send-email-michael.chan@broadcom.com>
References: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:7726 "EHLO
	mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbcCFHB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 02:01:26 -0500
In-Reply-To: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include the more useful port statistics in ethtool -S for the PF device.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 105 +++++++++++++++++++++-
 1 file changed, 103 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 87dcc62..888f03f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/ctype.h>
+#include <linux/stringify.h>
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
@@ -83,13 +84,99 @@ static int bnxt_set_coalesce(struct net_device *dev,
 
 #define BNXT_NUM_STATS	21
 
+#define BNXT_RX_STATS_OFFSET(counter)	\
+	(offsetof(struct rx_port_stats, counter) / 8)
+
+#define BNXT_RX_STATS_ENTRY(counter)	\
+	{ BNXT_RX_STATS_OFFSET(counter), __stringify(counter) }
+
+#define BNXT_TX_STATS_OFFSET(counter)			\
+	((offsetof(struct tx_port_stats, counter) +	\
+	  sizeof(struct rx_port_stats) + 512) / 8)
+
+#define BNXT_TX_STATS_ENTRY(counter)	\
+	{ BNXT_TX_STATS_OFFSET(counter), __stringify(counter) }
+
+static const struct {
+	long offset;
+	char string[ETH_GSTRING_LEN];
+} bnxt_port_stats_arr[] = {
+	BNXT_RX_STATS_ENTRY(rx_64b_frames),
+	BNXT_RX_STATS_ENTRY(rx_65b_127b_frames),
+	BNXT_RX_STATS_ENTRY(rx_128b_255b_frames),
+	BNXT_RX_STATS_ENTRY(rx_256b_511b_frames),
+	BNXT_RX_STATS_ENTRY(rx_512b_1023b_frames),
+	BNXT_RX_STATS_ENTRY(rx_1024b_1518_frames),
+	BNXT_RX_STATS_ENTRY(rx_good_vlan_frames),
+	BNXT_RX_STATS_ENTRY(rx_1519b_2047b_frames),
+	BNXT_RX_STATS_ENTRY(rx_2048b_4095b_frames),
+	BNXT_RX_STATS_ENTRY(rx_4096b_9216b_frames),
+	BNXT_RX_STATS_ENTRY(rx_9217b_16383b_frames),
+	BNXT_RX_STATS_ENTRY(rx_total_frames),
+	BNXT_RX_STATS_ENTRY(rx_ucast_frames),
+	BNXT_RX_STATS_ENTRY(rx_mcast_frames),
+	BNXT_RX_STATS_ENTRY(rx_bcast_frames),
+	BNXT_RX_STATS_ENTRY(rx_fcs_err_frames),
+	BNXT_RX_STATS_ENTRY(rx_ctrl_frames),
+	BNXT_RX_STATS_ENTRY(rx_pause_frames),
+	BNXT_RX_STATS_ENTRY(rx_pfc_frames),
+	BNXT_RX_STATS_ENTRY(rx_align_err_frames),
+	BNXT_RX_STATS_ENTRY(rx_ovrsz_frames),
+	BNXT_RX_STATS_ENTRY(rx_jbr_frames),
+	BNXT_RX_STATS_ENTRY(rx_mtu_err_frames),
+	BNXT_RX_STATS_ENTRY(rx_tagged_frames),
+	BNXT_RX_STATS_ENTRY(rx_double_tagged_frames),
+	BNXT_RX_STATS_ENTRY(rx_good_frames),
+	BNXT_RX_STATS_ENTRY(rx_undrsz_frames),
+	BNXT_RX_STATS_ENTRY(rx_eee_lpi_events),
+	BNXT_RX_STATS_ENTRY(rx_eee_lpi_duration),
+	BNXT_RX_STATS_ENTRY(rx_bytes),
+	BNXT_RX_STATS_ENTRY(rx_runt_bytes),
+	BNXT_RX_STATS_ENTRY(rx_runt_frames),
+
+	BNXT_TX_STATS_ENTRY(tx_64b_frames),
+	BNXT_TX_STATS_ENTRY(tx_65b_127b_frames),
+	BNXT_TX_STATS_ENTRY(tx_128b_255b_frames),
+	BNXT_TX_STATS_ENTRY(tx_256b_511b_frames),
+	BNXT_TX_STATS_ENTRY(tx_512b_1023b_frames),
+	BNXT_TX_STATS_ENTRY(tx_1024b_1518_frames),
+	BNXT_TX_STATS_ENTRY(tx_good_vlan_frames),
+	BNXT_TX_STATS_ENTRY(tx_1519b_2047_frames),
+	BNXT_TX_STATS_ENTRY(tx_2048b_4095b_frames),
+	BNXT_TX_STATS_ENTRY(tx_4096b_9216b_frames),
+	BNXT_TX_STATS_ENTRY(tx_9217b_16383b_frames),
+	BNXT_TX_STATS_ENTRY(tx_good_frames),
+	BNXT_TX_STATS_ENTRY(tx_total_frames),
+	BNXT_TX_STATS_ENTRY(tx_ucast_frames),
+	BNXT_TX_STATS_ENTRY(tx_mcast_frames),
+	BNXT_TX_STATS_ENTRY(tx_bcast_frames),
+	BNXT_TX_STATS_ENTRY(tx_pause_frames),
+	BNXT_TX_STATS_ENTRY(tx_pfc_frames),
+	BNXT_TX_STATS_ENTRY(tx_jabber_frames),
+	BNXT_TX_STATS_ENTRY(tx_fcs_err_frames),
+	BNXT_TX_STATS_ENTRY(tx_err),
+	BNXT_TX_STATS_ENTRY(tx_fifo_underruns),
+	BNXT_TX_STATS_ENTRY(tx_eee_lpi_events),
+	BNXT_TX_STATS_ENTRY(tx_eee_lpi_duration),
+	BNXT_TX_STATS_ENTRY(tx_total_collisions),
+	BNXT_TX_STATS_ENTRY(tx_bytes),
+};
+
+#define BNXT_NUM_PORT_STATS ARRAY_SIZE(bnxt_port_stats_arr)
+
 static int bnxt_get_sset_count(struct net_device *dev, int sset)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
 	switch (sset) {
-	case ETH_SS_STATS:
-		return BNXT_NUM_STATS * bp->cp_nr_rings;
+	case ETH_SS_STATS: {
+		int num_stats = BNXT_NUM_STATS * bp->cp_nr_rings;
+
+		if (bp->flags & BNXT_FLAG_PORT_STATS)
+			num_stats += BNXT_NUM_PORT_STATS;
+
+		return num_stats;
+	}
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -118,6 +205,14 @@ static void bnxt_get_ethtool_stats(struct net_device *dev,
 			buf[j] = le64_to_cpu(hw_stats[k]);
 		buf[j++] = cpr->rx_l4_csum_errors;
 	}
+	if (bp->flags & BNXT_FLAG_PORT_STATS) {
+		__le64 *port_stats = (__le64 *)bp->hw_rx_port_stats;
+
+		for (i = 0; i < BNXT_NUM_PORT_STATS; i++, j++) {
+			buf[j] = le64_to_cpu(*(port_stats +
+					       bnxt_port_stats_arr[i].offset));
+		}
+	}
 }
 
 static void bnxt_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
@@ -172,6 +267,12 @@ static void bnxt_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 			sprintf(buf, "[%d]: rx_l4_csum_errors", i);
 			buf += ETH_GSTRING_LEN;
 		}
+		if (bp->flags & BNXT_FLAG_PORT_STATS) {
+			for (i = 0; i < BNXT_NUM_PORT_STATS; i++) {
+				strcpy(buf, bnxt_port_stats_arr[i].string);
+				buf += ETH_GSTRING_LEN;
+			}
+		}
 		break;
 	default:
 		netdev_err(bp->dev, "bnxt_get_strings invalid request %x\n",
-- 
1.8.3.1
