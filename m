From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH v2 1/3] gianfar: Implement workaround for eTSEC74 erratum
Date: Wed, 30 Jun 2010 20:39:12 +0400
Message-ID: <20100630163912.GA23337@oksana.dev.rtsoft.ru>
References: <20100630163804.GA636@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Manfred Rudigier <manfred.rudigier@omicron.at>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:24707 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756323Ab0F3QjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 12:39:13 -0400
Content-Disposition: inline
In-Reply-To: <20100630163804.GA636@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPC8313ECE says:

"If MACCFG2[Huge Frame]=0 and the Ethernet controller receives frames
 which are larger than MAXFRM, the controller truncates the frames to
 length MAXFRM and marks RxBD[TR]=1 to indicate the error. The controller
 also erroneously marks RxBD[TR]=1 if the received frame length is MAXFRM
 or MAXFRM-1, even though those frames are not truncated.
 No truncation or truncation error occurs if MACCFG2[Huge Frame]=1."

There are two options to workaround the issue:

"1. Set MACCFG2[Huge Frame]=1, so no truncation occurs for invalid large
 frames. Software can determine if a frame is larger than MAXFRM by
 reading RxBD[LG] or RxBD[Data Length].

 2. Set MAXFRM to 1538 (0x602) instead of the default 1536 (0x600), so
 normal-length frames are not marked as truncated. Software can examine
 RxBD[Data Length] to determine if the frame was larger than MAXFRM-2."

This patch implements the first workaround option by setting HUGEFRAME
bit, and gfar_clean_rx_ring() already checks the RxBD[Data Length].

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |   29 +++++++++++++++++++++++++++--
 drivers/net/gianfar.h |   11 +++++++++++
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 28b53d1..9abcb39 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -85,6 +85,7 @@
 #include <linux/net_tstamp.h>
 
 #include <asm/io.h>
+#include <asm/reg.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 #include <linux/module.h>
@@ -928,6 +929,24 @@ static void gfar_init_filer_table(struct gfar_private *priv)
 	}
 }
 
+static void gfar_detect_errata(struct gfar_private *priv)
+{
+	struct device *dev = &priv->ofdev->dev;
+	unsigned int pvr = mfspr(SPRN_PVR);
+	unsigned int svr = mfspr(SPRN_SVR);
+	unsigned int mod = (svr >> 16) & 0xfff6; /* w/o E suffix */
+	unsigned int rev = svr & 0xffff;
+
+	/* MPC8313 Rev 2.0 and higher; All MPC837x */
+	if ((pvr == 0x80850010 && mod == 0x80b0 && rev >= 0x0020) ||
+			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+		priv->errata |= GFAR_ERRATA_74;
+
+	if (priv->errata)
+		dev_info(dev, "enabled errata workarounds, flags: 0x%x\n",
+			 priv->errata);
+}
+
 /* Set up the ethernet device structure, private data,
  * and anything else we need before we start */
 static int gfar_probe(struct of_device *ofdev,
@@ -960,6 +979,8 @@ static int gfar_probe(struct of_device *ofdev,
 	dev_set_drvdata(&ofdev->dev, priv);
 	regs = priv->gfargrp[0].regs;
 
+	gfar_detect_errata(priv);
+
 	/* Stop the DMA engine now, in case it was running before */
 	/* (The firmware could have used it, and left it running). */
 	gfar_halt(dev);
@@ -974,7 +995,10 @@ static int gfar_probe(struct of_device *ofdev,
 	gfar_write(&regs->maccfg1, tempval);
 
 	/* Initialize MACCFG2. */
-	gfar_write(&regs->maccfg2, MACCFG2_INIT_SETTINGS);
+	tempval = MACCFG2_INIT_SETTINGS;
+	if (gfar_has_errata(priv, GFAR_ERRATA_74))
+		tempval |= MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK;
+	gfar_write(&regs->maccfg2, tempval);
 
 	/* Initialize ECNTRL */
 	gfar_write(&regs->ecntrl, ECNTRL_INIT_SETTINGS);
@@ -2300,7 +2324,8 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	 * to allow huge frames, and to check the length */
 	tempval = gfar_read(&regs->maccfg2);
 
-	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE)
+	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE ||
+			gfar_has_errata(priv, GFAR_ERRATA_74))
 		tempval |= (MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
 	else
 		tempval &= ~(MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index ac4a92e..0a0483c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1025,6 +1025,10 @@ struct gfar_priv_grp {
 	char int_name_er[GFAR_INT_NAME_MAX];
 };
 
+enum gfar_errata {
+	GFAR_ERRATA_74		= 0x01,
+};
+
 /* Struct stolen almost completely (and shamelessly) from the FCC enet source
  * (Ok, that's not so true anymore, but there is a family resemblence)
  * The GFAR buffer descriptors track the ring buffers.  The rx_bd_base
@@ -1049,6 +1053,7 @@ struct gfar_private {
 	struct device_node *node;
 	struct net_device *ndev;
 	struct of_device *ofdev;
+	enum gfar_errata errata;
 
 	struct gfar_priv_grp gfargrp[MAXGROUPS];
 	struct gfar_priv_tx_q *tx_queue[MAX_TX_QS];
@@ -1111,6 +1116,12 @@ struct gfar_private {
 extern unsigned int ftp_rqfpr[MAX_FILER_IDX + 1];
 extern unsigned int ftp_rqfcr[MAX_FILER_IDX + 1];
 
+static inline int gfar_has_errata(struct gfar_private *priv,
+				  enum gfar_errata err)
+{
+	return priv->errata & err;
+}
+
 static inline u32 gfar_read(volatile unsigned __iomem *addr)
 {
 	u32 val;
-- 
1.7.0.5

