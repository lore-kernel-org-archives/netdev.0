From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 2/2] stmmac: Fix for higher mtu size handling
Date: Mon, 9 Jul 2012 12:44:46 +0530
Message-ID: <1341818086-28897-3-git-send-email-deepak.sikri@st.com>
References: <1341818086-28897-1-git-send-email-deepak.sikri@st.com>
 <1341818086-28897-2-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear--sw-devel@codex.cro.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:33361 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752418Ab2GIHO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:14:56 -0400
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id AB67F93
	for <netdev@vger.kernel.org>; Mon,  9 Jul 2012 07:06:33 +0000 (GMT)
In-Reply-To: <1341818086-28897-2-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the higher mtu sizes requiring the buffer size greater than 8192,
the buffers are sent or received using multiple dma descriptors/ same
descriptor with option of multi buffer handling.
It was observed during tests that the driver was missing on data
packets during the normal ping operations if the data buffers being used
catered to jumbo frame handling.

The memory barrriers are added in between preparation of dma descriptors
in the jumbo frame handling path to ensure all instructions before
enabling the dma are complete.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index fb8377d..4b785e1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -51,7 +51,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax,
 						csum);
-
+		wmb();
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
 
@@ -59,6 +59,7 @@ static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 					    len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum);
+		wmb();
 		priv->hw->desc->set_tx_owner(desc);
 		priv->tx_skbuff[entry] = NULL;
 	} else {
-- 
1.7.2.2
