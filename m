From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net.git) 3/3] stmmac: fix PTP type ethtool stats
Date: Mon, 14 Nov 2016 09:27:30 +0100
Message-ID: <1479112050-14042-4-git-send-email-peppe.cavallaro@st.com>
References: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>, <rayagond@vayavyalabs.com>,
        <richardcochran@gmail.com>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <seraphin.bonnaffe@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479112050-14042-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the ethtool stats for PTP frames; previous
version does not take care about some message types: i.e.
announce, management and signaling. It also provided a
broken statistic in case of "No PTP message received".

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Acked-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Acked-by: Alexandre TORGUE <alexandre.torgue@st.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       | 19 ++++++++-------
 drivers/net/ethernet/stmicro/stmmac/descs.h        | 20 +++++++++-------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 27 +++++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     | 28 ++++++++++++++--------
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 19 ++++++++-------
 5 files changed, 69 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6fc214c..6d2de4e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -120,14 +120,17 @@ struct stmmac_extra_stats {
 	unsigned long ip_csum_bypassed;
 	unsigned long ipv4_pkt_rcvd;
 	unsigned long ipv6_pkt_rcvd;
-	unsigned long rx_msg_type_ext_no_ptp;
-	unsigned long rx_msg_type_sync;
-	unsigned long rx_msg_type_follow_up;
-	unsigned long rx_msg_type_delay_req;
-	unsigned long rx_msg_type_delay_resp;
-	unsigned long rx_msg_type_pdelay_req;
-	unsigned long rx_msg_type_pdelay_resp;
-	unsigned long rx_msg_type_pdelay_follow_up;
+	unsigned long no_ptp_rx_msg_type_ext;
+	unsigned long ptp_rx_msg_type_sync;
+	unsigned long ptp_rx_msg_type_follow_up;
+	unsigned long ptp_rx_msg_type_delay_req;
+	unsigned long ptp_rx_msg_type_delay_resp;
+	unsigned long ptp_rx_msg_type_pdelay_req;
+	unsigned long ptp_rx_msg_type_pdelay_resp;
+	unsigned long ptp_rx_msg_type_pdelay_follow_up;
+	unsigned long ptp_rx_msg_type_announce;
+	unsigned long ptp_rx_msg_type_management;
+	unsigned long ptp_rx_msg_pkt_reserved_type;
 	unsigned long ptp_frame_type;
 	unsigned long ptp_ver;
 	unsigned long timestamp_dropped;
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index 2e4c171..e3c86d4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -155,14 +155,18 @@
 #define	ERDES4_L3_L4_FILT_NO_MATCH_MASK	GENMASK(27, 26)
 
 /* Extended RDES4 message type definitions */
-#define RDES_EXT_NO_PTP			0
-#define RDES_EXT_SYNC			1
-#define RDES_EXT_FOLLOW_UP		2
-#define RDES_EXT_DELAY_REQ		3
-#define RDES_EXT_DELAY_RESP		4
-#define RDES_EXT_PDELAY_REQ		5
-#define RDES_EXT_PDELAY_RESP		6
-#define RDES_EXT_PDELAY_FOLLOW_UP	7
+#define RDES_EXT_NO_PTP			0x0
+#define RDES_EXT_SYNC			0x1
+#define RDES_EXT_FOLLOW_UP		0x2
+#define RDES_EXT_DELAY_REQ		0x3
+#define RDES_EXT_DELAY_RESP		0x4
+#define RDES_EXT_PDELAY_REQ		0x5
+#define RDES_EXT_PDELAY_RESP		0x6
+#define RDES_EXT_PDELAY_FOLLOW_UP	0x7
+#define RDES_PTP_ANNOUNCE		0x8
+#define RDES_PTP_MANAGEMENT		0x9
+#define RDES_PTP_SIGNALING		0xa
+#define RDES_PTP_PKT_RESERVED_TYPE	0xf
 
 /* Basic descriptor structure for normal and alternate descriptors */
 struct dma_desc {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index 2ef2f0c..a601f8d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -123,22 +123,29 @@ static int dwmac4_wrback_get_rx_status(void *data, struct stmmac_extra_stats *x,
 		x->ipv4_pkt_rcvd++;
 	if (rdes1 & RDES1_IPV6_HEADER)
 		x->ipv6_pkt_rcvd++;
-	if (message_type == RDES_EXT_SYNC)
-		x->rx_msg_type_sync++;
+
+	if (message_type == RDES_EXT_NO_PTP)
+		x->no_ptp_rx_msg_type_ext++;
+	else if (message_type == RDES_EXT_SYNC)
+		x->ptp_rx_msg_type_sync++;
 	else if (message_type == RDES_EXT_FOLLOW_UP)
-		x->rx_msg_type_follow_up++;
+		x->ptp_rx_msg_type_follow_up++;
 	else if (message_type == RDES_EXT_DELAY_REQ)
-		x->rx_msg_type_delay_req++;
+		x->ptp_rx_msg_type_delay_req++;
 	else if (message_type == RDES_EXT_DELAY_RESP)
-		x->rx_msg_type_delay_resp++;
+		x->ptp_rx_msg_type_delay_resp++;
 	else if (message_type == RDES_EXT_PDELAY_REQ)
-		x->rx_msg_type_pdelay_req++;
+		x->ptp_rx_msg_type_pdelay_req++;
 	else if (message_type == RDES_EXT_PDELAY_RESP)
-		x->rx_msg_type_pdelay_resp++;
+		x->ptp_rx_msg_type_pdelay_resp++;
 	else if (message_type == RDES_EXT_PDELAY_FOLLOW_UP)
-		x->rx_msg_type_pdelay_follow_up++;
-	else
-		x->rx_msg_type_ext_no_ptp++;
+		x->ptp_rx_msg_type_pdelay_follow_up++;
+	else if (message_type == RDES_PTP_ANNOUNCE)
+		x->ptp_rx_msg_type_announce++;
+	else if (message_type == RDES_PTP_MANAGEMENT)
+		x->ptp_rx_msg_type_management++;
+	else if (message_type == RDES_PTP_PKT_RESERVED_TYPE)
+		x->ptp_rx_msg_pkt_reserved_type++;
 
 	if (rdes1 & RDES1_PTP_PACKET_TYPE)
 		x->ptp_frame_type++;
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 38f19c9..e755493 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -150,22 +150,30 @@ static void enh_desc_get_ext_status(void *data, struct stmmac_extra_stats *x,
 			x->ipv4_pkt_rcvd++;
 		if (rdes4 & ERDES4_IPV6_PKT_RCVD)
 			x->ipv6_pkt_rcvd++;
-		if (message_type == RDES_EXT_SYNC)
-			x->rx_msg_type_sync++;
+
+		if (message_type == RDES_EXT_NO_PTP)
+			x->no_ptp_rx_msg_type_ext++;
+		else if (message_type == RDES_EXT_SYNC)
+			x->ptp_rx_msg_type_sync++;
 		else if (message_type == RDES_EXT_FOLLOW_UP)
-			x->rx_msg_type_follow_up++;
+			x->ptp_rx_msg_type_follow_up++;
 		else if (message_type == RDES_EXT_DELAY_REQ)
-			x->rx_msg_type_delay_req++;
+			x->ptp_rx_msg_type_delay_req++;
 		else if (message_type == RDES_EXT_DELAY_RESP)
-			x->rx_msg_type_delay_resp++;
+			x->ptp_rx_msg_type_delay_resp++;
 		else if (message_type == RDES_EXT_PDELAY_REQ)
-			x->rx_msg_type_pdelay_req++;
+			x->ptp_rx_msg_type_pdelay_req++;
 		else if (message_type == RDES_EXT_PDELAY_RESP)
-			x->rx_msg_type_pdelay_resp++;
+			x->ptp_rx_msg_type_pdelay_resp++;
 		else if (message_type == RDES_EXT_PDELAY_FOLLOW_UP)
-			x->rx_msg_type_pdelay_follow_up++;
-		else
-			x->rx_msg_type_ext_no_ptp++;
+			x->ptp_rx_msg_type_pdelay_follow_up++;
+		else if (message_type == RDES_PTP_ANNOUNCE)
+			x->ptp_rx_msg_type_announce++;
+		else if (message_type == RDES_PTP_MANAGEMENT)
+			x->ptp_rx_msg_type_management++;
+		else if (message_type == RDES_PTP_PKT_RESERVED_TYPE)
+			x->ptp_rx_msg_pkt_reserved_type++;
+
 		if (rdes4 & ERDES4_PTP_FRAME_TYPE)
 			x->ptp_frame_type++;
 		if (rdes4 & ERDES4_PTP_VER)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 1e06173..c5d0142 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -115,14 +115,17 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(ip_csum_bypassed),
 	STMMAC_STAT(ipv4_pkt_rcvd),
 	STMMAC_STAT(ipv6_pkt_rcvd),
-	STMMAC_STAT(rx_msg_type_ext_no_ptp),
-	STMMAC_STAT(rx_msg_type_sync),
-	STMMAC_STAT(rx_msg_type_follow_up),
-	STMMAC_STAT(rx_msg_type_delay_req),
-	STMMAC_STAT(rx_msg_type_delay_resp),
-	STMMAC_STAT(rx_msg_type_pdelay_req),
-	STMMAC_STAT(rx_msg_type_pdelay_resp),
-	STMMAC_STAT(rx_msg_type_pdelay_follow_up),
+	STMMAC_STAT(no_ptp_rx_msg_type_ext),
+	STMMAC_STAT(ptp_rx_msg_type_sync),
+	STMMAC_STAT(ptp_rx_msg_type_follow_up),
+	STMMAC_STAT(ptp_rx_msg_type_delay_req),
+	STMMAC_STAT(ptp_rx_msg_type_delay_resp),
+	STMMAC_STAT(ptp_rx_msg_type_pdelay_req),
+	STMMAC_STAT(ptp_rx_msg_type_pdelay_resp),
+	STMMAC_STAT(ptp_rx_msg_type_pdelay_follow_up),
+	STMMAC_STAT(ptp_rx_msg_type_announce),
+	STMMAC_STAT(ptp_rx_msg_type_management),
+	STMMAC_STAT(ptp_rx_msg_pkt_reserved_type),
 	STMMAC_STAT(ptp_frame_type),
 	STMMAC_STAT(ptp_ver),
 	STMMAC_STAT(timestamp_dropped),
-- 
2.7.4
