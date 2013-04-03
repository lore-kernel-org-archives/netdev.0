From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/7] stmmac: review barriers
Date: Wed,  3 Apr 2013 07:41:24 +0200
Message-ID: <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Deepak Sikri <deepak.sikri@st.com>,
	Shiraz Hashim <shiraz.hashim@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:60818 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762275Ab3DCFlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 01:41:53 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 108C583
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:41:44 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D3BB525FF
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 05:41:44 +0000 (GMT)
In-Reply-To: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In all my tests performed on SH4 and ARM A9 platforms, I've never met problems
that can be fixed by using memory barriers. In the past there was some issues
on SMP ARM but fixed by reviewing xmit spinlock.

Further barriers have been added in the commits too: 8e83989106562326bf

This patch is to use the smp_wbm instead of wbm because the driver
runs on UP systems. Then, IMO it could make sense to only maintain the barriers
just in places where we touch the dma owner bits (that is the
only real critical path as we had seen and fixed in the commit:
eb0dc4bb2e22c04964d).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Deepak Sikri <deepak.sikri@st.com>
Cc: Shiraz Hashim <shiraz.hashim@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8b69e3b..c92dcbc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1797,15 +1797,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->tx_skbuff[entry] = NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
 						priv->mode);
-		wmb();
+		smp_wmb();
 		priv->hw->desc->set_tx_owner(desc);
-		wmb();
 	}
 
 	/* Finalize the latest segment. */
 	priv->hw->desc->close_tx_desc(desc);
 
-	wmb();
 	/* According to the coalesce parameter the IC bit for the latest
 	 * segment could be reset and the timer re-started to invoke the
 	 * stmmac_tx function. This approach takes care about the fragments.
@@ -1821,9 +1819,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else
 		priv->tx_count_frames = 0;
 
+	smp_wmb();
 	/* To avoid raise condition */
 	priv->hw->desc->set_tx_owner(first);
-	wmb();
 
 	priv->cur_tx++;
 
@@ -1899,9 +1897,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
-		wmb();
+		smp_wmb();
 		priv->hw->desc->set_rx_owner(p);
-		wmb();
 	}
 }
 
-- 
1.7.4.4
