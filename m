From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 4/6] stmmac: Update stmmac descriptor checks for stmmac core prior to Rev-3.5.
Date: Fri, 2 Mar 2012 18:25:26 +0530
Message-ID: <1330692928-30330-5-git-send-email-deepak.sikri@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear-devel@list.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:45305 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755798Ab2CBM4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 07:56:03 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 43603D4
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:47:31 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 043B0760
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:55:55 +0000 (GMT)
In-Reply-To: <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds in the following support.
1. The stmmac core supporting Type-1 checksum offload engine & prior to
Revision 3.5, append the HW cecksum at the end of payload in case the Rx
checksum engine was used to offload the HW checksum.
There cores did not provide the HW register interface to read the device
capabilities, and hence the plat code provides the core checksum capabilties
that help to identify type-1 cores, and adjust the frame length.

2. Also, the following Frame status checks with the Full checksum offload
Type-2 engine enabled are not backward compatible and are reserved for
STMMAC core revisions prior to 3.5.
Bit18(Eth Frame)	Bit27(Header Csum Error)	Bit28 (Payload Csum Err)
	0			1				1
	0			1				0

These conditions have been treated as no HW checksum support for stmmac core
prior to rev-3.5.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |    2 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   17 +++++++++++------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   14 +++++++++++++-
 4 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index d0b814e..12d1565 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -230,7 +230,7 @@ struct stmmac_desc_ops {
 	int (*get_rx_frame_len) (struct dma_desc *p);
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
-			  struct dma_desc *p);
+			  struct dma_desc *p, u32 mac_id);
 };
 
 struct stmmac_dma_ops {
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index d879763..42026f6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -22,6 +22,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <linux/stmmac.h>
 #include "common.h"
 #include "descs_com.h"
 
@@ -106,7 +107,9 @@ static int enh_desc_get_tx_len(struct dma_desc *p)
 	return p->des01.etx.buffer1_size;
 }
 
-static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
+#define GMAC_VERSION_35 0x35
+static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err,
+		u32 mac_id)
 {
 	int ret = good_frame;
 	u32 status = (type << 2 | ipc_err << 1 | payload_err) & 0x7;
@@ -141,16 +144,16 @@ static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
 	} else if (status == 0x1) {
 		CHIP_DBG(KERN_ERR
 		    "RX Des0 status: IPv4/6 unsupported IP PAYLOAD.\n");
-		ret = discard_frame;
+		ret = (mac_id >= GMAC_VERSION_35) ? discard_frame : csum_none;
 	} else if (status == 0x3) {
 		CHIP_DBG(KERN_ERR "RX Des0 status: No IPv4, IPv6 frame.\n");
-		ret = discard_frame;
+		ret = (mac_id >= GMAC_VERSION_35) ? discard_frame : csum_none;
 	}
 	return ret;
 }
 
 static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
-				  struct dma_desc *p)
+				  struct dma_desc *p, u32 mac_id)
 {
 	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
@@ -195,9 +198,11 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	/* After a payload csum error, the ES bit is set.
 	 * It doesn't match with the information reported into the databook.
 	 * At any rate, we need to understand if the CSUM hw computation is ok
-	 * and report this info to the upper layers. */
+	 * and report this info to the upper layers.
+	 */
 	ret = enh_desc_coe_rdes0(p->des01.erx.ipc_csum_error,
-		p->des01.erx.frame_type, p->des01.erx.payload_csum_error);
+			p->des01.erx.frame_type,
+			p->des01.erx.payload_csum_error, mac_id);
 
 	if (unlikely(p->des01.erx.dribbling)) {
 		CHIP_DBG(KERN_ERR "GMAC RX: dribbling error\n");
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index fda5d2b..057a728 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -72,7 +72,7 @@ static int ndesc_get_tx_len(struct dma_desc *p)
  * In case of success, it returns good_frame because the GMAC device
  * is supposed to be able to compute the csum in HW. */
 static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
-			       struct dma_desc *p)
+			       struct dma_desc *p, u32 mac_id)
 {
 	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 001b8f3..3bcdc97 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1103,6 +1103,7 @@ static int stmmac_open(struct net_device *dev)
 	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
 	if (priv->rx_coe)
 		pr_info(" Checksum Offload Engine supported\n");
+
 	if (priv->plat->tx_coe)
 		pr_info(" Checksum insertion supported\n");
 
@@ -1436,7 +1437,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		/* read the status of the incoming frame */
 		status = (priv->hw->desc->rx_status(&priv->dev->stats,
-						    &priv->xstats, p));
+					&priv->xstats, p,
+					priv->hw->synopsys_uid & 0xff));
 		if (unlikely(status == discard_frame))
 			priv->dev->stats.rx_errors++;
 		else {
@@ -1444,6 +1446,16 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			int frame_len;
 
 			frame_len = priv->hw->desc->get_rx_frame_len(p);
+			/*
+			 * The type-1 checksume offload engines append
+			 * the checksum at the end of frame, and the
+			 * the two bytes of checksum are added in
+			 * length.
+			 * Adjust for that in the framelen for type-1
+			 * checksum offload engines.
+			 */
+			if (priv->plat->csum_off_engine_type == STMMAC_CSUM_T1)
+				frame_len -= 2;
 			/* ACS is set; GMAC core strips PAD/FCS for IEEE 802.3
 			 * Type frames (LLC/LLC-SNAP) */
 			if (unlikely(status != llc_snap))
-- 
1.6.0.2
