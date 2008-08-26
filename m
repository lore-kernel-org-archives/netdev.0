From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH][for 2.6.27] fs_enet: Fix SCC Ethernet on CPM2, and crash in
 fs_enet_rx_napi()
Date: Mon, 25 Aug 2008 20:20:53 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0808252019030.20949@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, hs@denx.de,
	vitb@kernel.crashing.org
To: Jeff Garzik <jeff@garzik.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38701 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbYHZBWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 21:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Schocher <hs@denx.de>

Signed-off-by: Heiko Schocher <hs@denx.de>
Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

Updated to apply cleanly to top of linus's tree.

- k

 arch/powerpc/include/asm/cpm2.h    |    5 +++++
 drivers/net/fs_enet/fs_enet-main.c |    8 ++++++++
 drivers/net/fs_enet/mac-scc.c      |    8 +++++++-
 3 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/cpm2.h b/arch/powerpc/include/asm/cpm2.h
index 2a6fa01..0f5e8ff 100644
--- a/arch/powerpc/include/asm/cpm2.h
+++ b/arch/powerpc/include/asm/cpm2.h
@@ -337,6 +337,11 @@ typedef struct scc_param {
 	uint	scc_tcrc;	/* Internal */
 } sccp_t;

+/* Function code bits.
+*/
+#define SCC_EB	((u_char) 0x10)	/* Set big endian byte order */
+#define SCC_GBL	((u_char) 0x20) /* Snooping enabled */
+
 /* CPM Ethernet through SCC1.
  */
 typedef struct scc_enet {
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 9a51ec8..9d46182 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -792,6 +792,10 @@ static int fs_enet_open(struct net_device *dev)
 	int r;
 	int err;

+	/* to initialize the fep->cur_rx,... */
+	/* not doing this, will cause a crash in fs_enet_rx_napi */
+	fs_init_bds(fep->ndev);
+
 	if (fep->fpi->use_napi)
 		napi_enable(&fep->napi);

@@ -1167,6 +1171,10 @@ static struct of_device_id fs_enet_match[] = {
 		.compatible = "fsl,cpm1-scc-enet",
 		.data = (void *)&fs_scc_ops,
 	},
+	{
+		.compatible = "fsl,cpm2-scc-enet",
+		.data = (void *)&fs_scc_ops,
+	},
 #endif
 #ifdef CONFIG_FS_ENET_HAS_FCC
 	{
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 029b3c7..22f50dd 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -47,7 +47,6 @@
 #include "fs_enet.h"

 /*************************************************/
-
 #if defined(CONFIG_CPM1)
 /* for a 8xx __raw_xxx's are sufficient */
 #define __fs_out32(addr, x)	__raw_writel(x, addr)
@@ -62,6 +61,8 @@
 #define __fs_out16(addr, x)	out_be16(addr, x)
 #define __fs_in32(addr)	in_be32(addr)
 #define __fs_in16(addr)	in_be16(addr)
+#define __fs_out8(addr, x)	out_8(addr, x)
+#define __fs_in8(addr)	in_8(addr)
 #endif

 /* write, read, set bits, clear bits */
@@ -262,8 +263,13 @@ static void restart(struct net_device *dev)

 	/* Initialize function code registers for big-endian.
 	 */
+#ifndef CONFIG_NOT_COHERENT_CACHE
+	W8(ep, sen_genscc.scc_rfcr, SCC_EB | SCC_GBL);
+	W8(ep, sen_genscc.scc_tfcr, SCC_EB | SCC_GBL);
+#else
 	W8(ep, sen_genscc.scc_rfcr, SCC_EB);
 	W8(ep, sen_genscc.scc_tfcr, SCC_EB);
+#endif

 	/* Set maximum bytes per receive buffer.
 	 * This appears to be an Ethernet frame size, not the buffer
-- 
1.5.5.1

