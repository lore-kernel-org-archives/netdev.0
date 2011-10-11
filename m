From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/5] stmmac: allow mtu bigger than 1500 in case of normal desc.
Date: Tue, 11 Oct 2011 09:30:43 +0200
Message-ID: <1318318246-1326-3-git-send-email-peppe.cavallaro@st.com>
References: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:56357 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750872Ab1JKHbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 03:31:04 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DCC6ED1
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:31:02 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A65A91A90
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:31:02 +0000 (GMT)
In-Reply-To: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to set the mtu bigger than 1500
in case of normal descriptors.
This is helping some SPEAr customers.

Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   10 +++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 6c40a38..c3456f8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -127,6 +127,7 @@ static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 		p->des01.rx.own = 1;
 		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
 #if defined(CONFIG_STMMAC_RING)
+		p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
 		if (i == (ring_size - 1))
 			p->des01.rx.end_ring = 1;
 #else
@@ -196,7 +197,14 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  int csum_flag)
 {
 	p->des01.tx.first_segment = is_fs;
-	p->des01.tx.buffer1_size = len;
+
+#if defined(CONFIG_STMMAC_RING)
+	if (unlikely(len > BUF_SIZE_2KiB)) {
+		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
+		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
+	} else
+#endif
+		p->des01.tx.buffer1_size = len;
 }
 
 static void ndesc_clear_tx_ic(struct dma_desc *p)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 54f1e76..0a7d326 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1491,17 +1491,17 @@ static void stmmac_set_rx_mode(struct net_device *dev)
 static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int max_mtu;
+	int max_mtu = ETH_DATA_LEN;
 
 	if (netif_running(dev)) {
 		pr_err("%s: must be stopped to change its MTU\n", dev->name);
 		return -EBUSY;
 	}
 
-	if (priv->plat->has_gmac)
+	if (priv->plat->enh_desc)
 		max_mtu = JUMBO_LEN;
 	else
-		max_mtu = ETH_DATA_LEN;
+		max_mtu = BUF_SIZE_4KiB;
 
 	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
 		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
-- 
1.7.4.4
