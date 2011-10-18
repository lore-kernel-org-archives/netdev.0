From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 4/7] stmmac: allow mtu bigger than 1500 in case of normal desc (V3)
Date: Tue, 18 Oct 2011 10:42:08 +0200
Message-ID: <1318927331-20855-5-git-send-email-peppe.cavallaro@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:60188 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753781Ab1JRIr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:47:29 -0400
In-Reply-To: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to set the mtu bigger than 1500
in case of normal descriptors.
This is helping some SPEAr customers.

Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |    8 +++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    4 ++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 029c2a2..e13226b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -126,6 +126,7 @@ static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
 	for (i = 0; i < ring_size; i++) {
 		p->des01.rx.own = 1;
 		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
+		p->des01.rx.buffer2_size = BUF_SIZE_2KiB - 1;
 		if (i == ring_size - 1)
 			p->des01.rx.end_ring = 1;
 		if (disable_rx_ic)
@@ -183,7 +184,12 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 				  int csum_flag)
 {
 	p->des01.tx.first_segment = is_fs;
-	p->des01.tx.buffer1_size = len;
+
+	if (unlikely(len > BUF_SIZE_2KiB)) {
+		p->des01.etx.buffer1_size = BUF_SIZE_2KiB - 1;
+		p->des01.etx.buffer2_size = len - p->des01.etx.buffer1_size;
+	} else
+		p->des01.tx.buffer1_size = len;
 }
 
 static void ndesc_clear_tx_ic(struct dma_desc *p)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d0af002..622b7ac 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1412,10 +1412,10 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
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
