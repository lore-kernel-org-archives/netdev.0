From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next] drivers: net: xgene-v2: Extend ethtool statistics
Date: Mon, 17 Apr 2017 16:47:55 -0700
Message-ID: <1492472875-32385-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds extended statistics reporting to ethtool.

In summary, this patch,

   - adds ethtool.h with the statistics register definitions
   - adds 'struct xge_gstrings_extd_stats' to gather extended stats
   - modifies xge_get_strings(), get_sset_count() and
     get_ethtool_stats() accordingly
   - moves 'struct xge_gstrings_stats' to ethtool.h

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
v2: Address review comments from v1
	- removed duplicate statistics counters that were reported by
	  xge_get_stats64()
v1:
	- Initial version
---

 drivers/net/ethernet/apm/xgene-v2/ethtool.c | 78 ++++++++++++++++++++++++++---
 drivers/net/ethernet/apm/xgene-v2/ethtool.h | 78 +++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/mac.h     |  3 --
 drivers/net/ethernet/apm/xgene-v2/main.h    |  2 +-
 4 files changed, 151 insertions(+), 10 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ethtool.h

diff --git a/drivers/net/ethernet/apm/xgene-v2/ethtool.c b/drivers/net/ethernet/apm/xgene-v2/ethtool.c
index 0c426f5..b6666e4 100644
--- a/drivers/net/ethernet/apm/xgene-v2/ethtool.c
+++ b/drivers/net/ethernet/apm/xgene-v2/ethtool.c
@@ -21,12 +21,13 @@
 
 #include "main.h"
 
-struct xge_gstrings_stats {
-	char name[ETH_GSTRING_LEN];
-	int offset;
-};
-
 #define XGE_STAT(m)		{ #m, offsetof(struct xge_pdata, stats.m) }
+#define XGE_EXTD_STAT(m, n)					\
+	{							\
+		#m,						\
+		n,						\
+		0						\
+	}
 
 static const struct xge_gstrings_stats gstrings_stats[] = {
 	XGE_STAT(rx_packets),
@@ -36,7 +37,62 @@ struct xge_gstrings_stats {
 	XGE_STAT(rx_errors)
 };
 
+static struct xge_gstrings_extd_stats gstrings_extd_stats[] = {
+	XGE_EXTD_STAT(tx_rx_64b_frame_cntr, TR64),
+	XGE_EXTD_STAT(tx_rx_127b_frame_cntr, TR127),
+	XGE_EXTD_STAT(tx_rx_255b_frame_cntr, TR255),
+	XGE_EXTD_STAT(tx_rx_511b_frame_cntr, TR511),
+	XGE_EXTD_STAT(tx_rx_1023b_frame_cntr, TR1K),
+	XGE_EXTD_STAT(tx_rx_1518b_frame_cntr, TRMAX),
+	XGE_EXTD_STAT(tx_rx_1522b_frame_cntr, TRMGV),
+	XGE_EXTD_STAT(rx_fcs_error_cntr, RFCS),
+	XGE_EXTD_STAT(rx_multicast_pkt_cntr, RMCA),
+	XGE_EXTD_STAT(rx_broadcast_pkt_cntr, RBCA),
+	XGE_EXTD_STAT(rx_ctrl_frame_pkt_cntr, RXCF),
+	XGE_EXTD_STAT(rx_pause_frame_pkt_cntr, RXPF),
+	XGE_EXTD_STAT(rx_unk_opcode_cntr, RXUO),
+	XGE_EXTD_STAT(rx_align_err_cntr, RALN),
+	XGE_EXTD_STAT(rx_frame_len_err_cntr, RFLR),
+	XGE_EXTD_STAT(rx_code_err_cntr, RCDE),
+	XGE_EXTD_STAT(rx_carrier_sense_err_cntr, RCSE),
+	XGE_EXTD_STAT(rx_undersize_pkt_cntr, RUND),
+	XGE_EXTD_STAT(rx_oversize_pkt_cntr, ROVR),
+	XGE_EXTD_STAT(rx_fragments_cntr, RFRG),
+	XGE_EXTD_STAT(rx_jabber_cntr, RJBR),
+	XGE_EXTD_STAT(rx_dropped_pkt_cntr, RDRP),
+	XGE_EXTD_STAT(tx_multicast_pkt_cntr, TMCA),
+	XGE_EXTD_STAT(tx_broadcast_pkt_cntr, TBCA),
+	XGE_EXTD_STAT(tx_pause_ctrl_frame_cntr, TXPF),
+	XGE_EXTD_STAT(tx_defer_pkt_cntr, TDFR),
+	XGE_EXTD_STAT(tx_excv_defer_pkt_cntr, TEDF),
+	XGE_EXTD_STAT(tx_single_col_pkt_cntr, TSCL),
+	XGE_EXTD_STAT(tx_multi_col_pkt_cntr, TMCL),
+	XGE_EXTD_STAT(tx_late_col_pkt_cntr, TLCL),
+	XGE_EXTD_STAT(tx_excv_col_pkt_cntr, TXCL),
+	XGE_EXTD_STAT(tx_total_col_cntr, TNCL),
+	XGE_EXTD_STAT(tx_pause_frames_hnrd_cntr, TPFH),
+	XGE_EXTD_STAT(tx_drop_frame_cntr, TDRP),
+	XGE_EXTD_STAT(tx_jabber_frame_cntr, TJBR),
+	XGE_EXTD_STAT(tx_fcs_error_cntr, TFCS),
+	XGE_EXTD_STAT(tx_ctrl_frame_cntr, TXCF),
+	XGE_EXTD_STAT(tx_oversize_frame_cntr, TOVR),
+	XGE_EXTD_STAT(tx_undersize_frame_cntr, TUND),
+	XGE_EXTD_STAT(tx_fragments_cntr, TFRG)
+};
+
 #define XGE_STATS_LEN		ARRAY_SIZE(gstrings_stats)
+#define XGE_EXTD_STATS_LEN	ARRAY_SIZE(gstrings_extd_stats)
+
+static void xge_mac_get_extd_stats(struct xge_pdata *pdata)
+{
+	u32 data;
+	int i;
+
+	for (i = 0; i < XGE_EXTD_STATS_LEN; i++) {
+		data = xge_rd_csr(pdata, gstrings_extd_stats[i].addr);
+		gstrings_extd_stats[i].value += data;
+	}
+}
 
 static void xge_get_drvinfo(struct net_device *ndev,
 			    struct ethtool_drvinfo *info)
@@ -62,6 +118,11 @@ static void xge_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 		memcpy(p, gstrings_stats[i].name, ETH_GSTRING_LEN);
 		p += ETH_GSTRING_LEN;
 	}
+
+	for (i = 0; i < XGE_EXTD_STATS_LEN; i++) {
+		memcpy(p, gstrings_extd_stats[i].name, ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+	}
 }
 
 static int xge_get_sset_count(struct net_device *ndev, int sset)
@@ -69,7 +130,7 @@ static int xge_get_sset_count(struct net_device *ndev, int sset)
 	if (sset != ETH_SS_STATS)
 		return -EINVAL;
 
-	return XGE_STATS_LEN;
+	return XGE_STATS_LEN + XGE_EXTD_STATS_LEN;
 }
 
 static void xge_get_ethtool_stats(struct net_device *ndev,
@@ -81,6 +142,11 @@ static void xge_get_ethtool_stats(struct net_device *ndev,
 
 	for (i = 0; i < XGE_STATS_LEN; i++)
 		*data++ = *(u64 *)(pdata + gstrings_stats[i].offset);
+
+	xge_mac_get_extd_stats(pdata);
+
+	for (i = 0; i < XGE_EXTD_STATS_LEN; i++)
+		*data++ = gstrings_extd_stats[i].value;
 }
 
 static int xge_get_link_ksettings(struct net_device *ndev,
diff --git a/drivers/net/ethernet/apm/xgene-v2/ethtool.h b/drivers/net/ethernet/apm/xgene-v2/ethtool.h
new file mode 100644
index 0000000..54b48d5
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene-v2/ethtool.h
@@ -0,0 +1,78 @@
+/*
+ * Applied Micro X-Gene SoC Ethernet v2 Driver
+ *
+ * Copyright (c) 2017, Applied Micro Circuits Corporation
+ * Author(s): Iyappan Subramanian <isubramanian@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_V2_ETHTOOL_H__
+#define __XGENE_ENET_V2_ETHTOOL_H__
+
+struct xge_gstrings_stats {
+	char name[ETH_GSTRING_LEN];
+	int offset;
+};
+
+struct xge_gstrings_extd_stats {
+	char name[ETH_GSTRING_LEN];
+	u32 addr;
+	u32 value;
+};
+
+#define TR64			0xa080
+#define TR127			0xa084
+#define TR255			0xa088
+#define TR511			0xa08c
+#define TR1K			0xa090
+#define TRMAX			0xa094
+#define TRMGV			0xa098
+#define RFCS			0xa0a4
+#define RMCA			0xa0a8
+#define RBCA			0xa0ac
+#define RXCF			0xa0b0
+#define RXPF			0xa0b4
+#define RXUO			0xa0b8
+#define RALN			0xa0bc
+#define RFLR			0xa0c0
+#define RCDE			0xa0c4
+#define RCSE			0xa0c8
+#define RUND			0xa0cc
+#define ROVR			0xa0d0
+#define RFRG			0xa0d4
+#define RJBR			0xa0d8
+#define RDRP			0xa0dc
+#define TMCA			0xa0e8
+#define TBCA			0xa0ec
+#define TXPF			0xa0f0
+#define TDFR			0xa0f4
+#define TEDF			0xa0f8
+#define TSCL			0xa0fc
+#define TMCL			0xa100
+#define TLCL			0xa104
+#define TXCL			0xa108
+#define TNCL			0xa10c
+#define TPFH			0xa110
+#define TDRP			0xa114
+#define TJBR			0xa118
+#define TFCS			0xa11c
+#define TXCF			0xa120
+#define TOVR			0xa124
+#define TUND			0xa128
+#define TFRG			0xa12c
+
+void xge_set_ethtool_ops(struct net_device *ndev);
+
+#endif  /* __XGENE_ENET_V2_ETHTOOL_H__ */
diff --git a/drivers/net/ethernet/apm/xgene-v2/mac.h b/drivers/net/ethernet/apm/xgene-v2/mac.h
index 18a9c9d..3c83fa6 100644
--- a/drivers/net/ethernet/apm/xgene-v2/mac.h
+++ b/drivers/net/ethernet/apm/xgene-v2/mac.h
@@ -34,9 +34,6 @@
 #define INTERFACE_CONTROL	0xa038
 #define STATION_ADDR0		0xa040
 #define STATION_ADDR1		0xa044
-#define RBYT			0xa09c
-#define RPKT			0xa0a0
-#define RFCS			0xa0a4
 
 #define RGMII_REG_0		0x27e0
 #define ICM_CONFIG0_REG_0	0x2c00
diff --git a/drivers/net/ethernet/apm/xgene-v2/main.h b/drivers/net/ethernet/apm/xgene-v2/main.h
index db1178e..969b258 100644
--- a/drivers/net/ethernet/apm/xgene-v2/main.h
+++ b/drivers/net/ethernet/apm/xgene-v2/main.h
@@ -38,6 +38,7 @@
 #include "mac.h"
 #include "enet.h"
 #include "ring.h"
+#include "ethtool.h"
 
 #define XGENE_ENET_V2_VERSION	"v1.0"
 #define XGENE_ENET_STD_MTU	1536
@@ -75,6 +76,5 @@ struct xge_pdata {
 
 int xge_mdio_config(struct net_device *ndev);
 void xge_mdio_remove(struct net_device *ndev);
-void xge_set_ethtool_ops(struct net_device *ndev);
 
 #endif /* __XGENE_ENET_V2_MAIN_H__ */
-- 
1.9.1
