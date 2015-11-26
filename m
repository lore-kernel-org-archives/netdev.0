From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 5/5] stmmac: fix oversized frame reception
Date: Thu, 26 Nov 2015 08:35:45 +0100
Message-ID: <1448523345-832-6-git-send-email-peppe.cavallaro@st.com>
References: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre TORGUE <alexandre.torgue@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:46817 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026AbbKZH2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:28:20 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id tAQ7Narj017328
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:19 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1ycpmrt7n2-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:19 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 217D934
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:27:45 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 356251674
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:28:17 +0000 (GMT)
In-Reply-To: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The receive skb buffers can be preallocated when the link is opened
according to mtu size.
While testing on a network environment with not standard MTU (e.g. 3000),
a panic occurred if an incoming packet had a length greater than rx skb
buffer size. This is because the HW is programmed to copy, from the DMA,
an Jumbo frame and the Sw must check if the allocated buffer is enough to
store the frame.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6256b32..3c6549a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2232,6 +2232,12 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 			frame_len = priv->hw->desc->get_rx_frame_len(p, coe);
 
+			/*  check if frame_len fits the preallocated memory */
+			if (frame_len > priv->dma_buf_sz) {
+				priv->dev->stats.rx_length_errors++;
+				break;
+			}
+
 			/* ACS is set; GMAC core strips PAD/FCS for IEEE 802.3
 			 * Type frames (LLC/LLC-SNAP)
 			 */
-- 
1.7.4.4
