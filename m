From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/3] stmmac: fix automatic PAD/FCS stripping
Date: Tue, 27 Jul 2010 12:09:47 +0200
Message-ID: <1280225387-26240-3-git-send-email-peppe.cavallaro@st.com>
References: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
 <1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:35691 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756053Ab0G0KKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 06:10:07 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9A6EE118
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 10:10:05 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5CA9B264F
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 10:10:05 +0000 (GMT)
In-Reply-To: <1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For Simple Ethernet frames (802.2 and 802.3) the GMAC Core
never strips pad and fcs. This means the ACS has no effect
on IPv4/6 frames.
The FL bits, in the RDES0, include the FCS so the driver
has to remove it in SW.
For 802.3 frame format with LLC or LLC-SNAP, when set the ACS
bit, the HW strips both PAD and FCS.
The FL bits, in the RDES0, actually represents the frame length
already stripped.
This patch fixes this logic within the device driver that
erroneously removed 4byte from 802.3 frames already stripped
corrupting the payload.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h      |    1 +
 drivers/net/stmmac/dwmac1000.h   |    2 +-
 drivers/net/stmmac/enh_desc.c    |    2 +-
 drivers/net/stmmac/stmmac_main.c |    8 ++++++--
 4 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 144f76f..66b9da0 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -108,6 +108,7 @@ enum rx_frame_status { /* IPC status */
 	good_frame = 0,
 	discard_frame = 1,
 	csum_none = 2,
+	llc_snap = 4,
 };
 
 enum tx_dma_irq_status {
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
index d8d0f35..8b20b19 100644
--- a/drivers/net/stmmac/dwmac1000.h
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -93,7 +93,7 @@ enum inter_frame_gap {
 #define GMAC_CONTROL_IPC	0x00000400 /* Checksum Offload */
 #define GMAC_CONTROL_DR		0x00000200 /* Disable Retry */
 #define GMAC_CONTROL_LUD	0x00000100 /* Link up/down */
-#define GMAC_CONTROL_ACS	0x00000080 /* Automatic Pad Stripping */
+#define GMAC_CONTROL_ACS	0x00000080 /* Automatic Pad/FCS Stripping */
 #define GMAC_CONTROL_DC		0x00000010 /* Deferral Check */
 #define GMAC_CONTROL_TE		0x00000008 /* Transmitter Enable */
 #define GMAC_CONTROL_RE		0x00000004 /* Receiver Enable */
diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_desc.c
index 3c18ebe..f612f98 100644
--- a/drivers/net/stmmac/enh_desc.c
+++ b/drivers/net/stmmac/enh_desc.c
@@ -123,7 +123,7 @@ static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
 	 */
 	if (status == 0x0) {
 		CHIP_DBG(KERN_INFO "RX Des0 status: IEEE 802.3 Type frame.\n");
-		ret = good_frame;
+		ret = llc_snap;
 	} else if (status == 0x4) {
 		CHIP_DBG(KERN_INFO "RX Des0 status: IPv4/6 No CSUM errorS.\n");
 		ret = good_frame;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 1083334..bbb7951 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1216,9 +1216,13 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			priv->dev->stats.rx_errors++;
 		else {
 			struct sk_buff *skb;
-			/* Length should omit the CRC */
-			int frame_len = priv->hw->desc->get_rx_frame_len(p) - 4;
+			int frame_len;
 
+			frame_len = priv->hw->desc->get_rx_frame_len(p);
+			/* ACS is set; GMAC core strips PAD/FCS for IEEE 802.3
+			 * Type frames (LLC/LLC-SNAP) */
+			if (unlikely(status != llc_snap))
+				frame_len -= ETH_FCS_LEN;
 #ifdef STMMAC_RX_DEBUG
 			if (frame_len > ETH_FRAME_LEN)
 				pr_debug("\tRX frame size %d, COE status: %d\n",
-- 
1.5.5.6

