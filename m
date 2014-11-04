From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/5] stmmac: fix stmmac_tx_avail should be called with TX locked
Date: Tue, 4 Nov 2014 17:08:05 +0100
Message-ID: <1415117289-7733-2-git-send-email-peppe.cavallaro@st.com>
References: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47601 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbaKDQT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:19:59 -0500
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sA4GFnLF014618
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2014 17:19:58 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1qetgejbvv-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:19:58 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 103873D
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 16:19:29 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 32DCF2C2F4
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 16:19:54 +0000 (GMT)
In-Reply-To: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabrice Gasnier <fabrice.gasnier@st.com>

stmmac_tx_avail() may lie if used unprotected. It's using cur_tx
and dirty_tx index. These index may be already in use by tx_clean
when entering xmit routine. So, this should be called locked.

This can cause transmit queue to be stuck, with following message:
NETDEV WATCHDOG: eth0 (stmmaceth): transmit queue 0 timed out

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6f77a46..bcd8a34 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1894,7 +1894,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int nopaged_len = skb_headlen(skb);
 	unsigned int enh_desc = priv->plat->enh_desc;
 
+	spin_lock(&priv->tx_lock);
+
 	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
+		spin_unlock(&priv->tx_lock);
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
@@ -1903,8 +1906,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock(&priv->tx_lock);
-
 	if (priv->tx_path_in_lpi_mode)
 		stmmac_disable_eee_mode(priv);
 
-- 
1.7.4.4
