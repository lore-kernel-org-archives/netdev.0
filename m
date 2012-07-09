From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 1/2] stmmac: Fix for nfs hang on multiple reboot
Date: Mon, 9 Jul 2012 12:44:45 +0530
Message-ID: <1341818086-28897-2-git-send-email-deepak.sikri@st.com>
References: <1341818086-28897-1-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear--sw-devel@codex.cro.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:37868 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752281Ab2GIHOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:14:54 -0400
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 96FF09E
	for <netdev@vger.kernel.org>; Mon,  9 Jul 2012 07:06:31 +0000 (GMT)
In-Reply-To: <1341818086-28897-1-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was observed that during multiple reboots nfs hangs. The status of
receive descriptors shows that all the descriptors were in control of
CPU, and none were assigned to DMA.
Also the DMA status register confirmed that the Rx buffer is
unavailable.

This patch adds the fix for the same by adding the memory barriers to
ascertain that the all instructions before enabling the Rx or Tx DMA are
completed which involves the proper setting of the ownership bit in DMA
descriptors.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 51b3b68..ea3003e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1212,6 +1212,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
 		wmb();
 		priv->hw->desc->set_tx_owner(desc);
+		wmb();
 	}
 
 	/* Interrupt on completition only for the latest segment */
@@ -1227,6 +1228,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* To avoid raise condition */
 	priv->hw->desc->set_tx_owner(first);
+	wmb();
 
 	priv->cur_tx++;
 
@@ -1290,6 +1292,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		}
 		wmb();
 		priv->hw->desc->set_rx_owner(p + entry);
+		wmb();
 	}
 }
 
-- 
1.7.2.2
