From: Li Yang <leoli@freescale.com>
Subject: [PATCH] powerpc/fsl_rio: use LAW address from device tree
Date: Tue, 28 Apr 2009 18:15:34 +0800
Message-ID: <1240913737-23773-2-git-send-email-leoli@freescale.com>
References: <2a27d3730904280316l7049bddbie914907b16ccfff6@mail.gmail.com>
 <1240913737-23773-1-git-send-email-leoli@freescale.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: akpm@linux-foundation.org, galak@kernel.crashing.org,
	davem@davemloft.net, mporter@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:40587 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbZD1KTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 06:19:23 -0400
In-Reply-To: <1240913737-23773-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of fixed address in old code.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 arch/powerpc/sysdev/fsl_rio.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/sysdev/fsl_rio.c b/arch/powerpc/sysdev/fsl_rio.c
index abdb124..fa0720f 100644
--- a/arch/powerpc/sysdev/fsl_rio.c
+++ b/arch/powerpc/sysdev/fsl_rio.c
@@ -1077,8 +1077,9 @@ int fsl_rio_setup(struct of_device *dev)
 
 	INIT_LIST_HEAD(&port->dbells);
 	port->iores.start = law_start;
-	port->iores.end = law_start + law_size;
+	port->iores.end = law_start + law_size - 1;
 	port->iores.flags = IORESOURCE_MEM;
+	port->iores.name = "rio_io_win";
 
 	priv->bellirq = irq_of_parse_and_map(dev->node, 2);
 	priv->txirq = irq_of_parse_and_map(dev->node, 3);
@@ -1156,14 +1157,15 @@ int fsl_rio_setup(struct of_device *dev)
 		out_be32((priv->regs_win + RIO_ISR_AACR), RIO_ISR_AACR_AA);
 
 	/* Configure maintenance transaction window */
-	out_be32(&priv->maint_atmu_regs->rowbar, 0x000c0000);
-	out_be32(&priv->maint_atmu_regs->rowar, 0x80077015);
+	out_be32(&priv->maint_atmu_regs->rowbar, law_start >> 12);
+	out_be32(&priv->maint_atmu_regs->rowar, 0x80077015);	/* 4M */
 
 	priv->maint_win = ioremap(law_start, RIO_MAINT_WIN_SIZE);
 
 	/* Configure outbound doorbell window */
-	out_be32(&priv->dbell_atmu_regs->rowbar, 0x000c0400);
-	out_be32(&priv->dbell_atmu_regs->rowar, 0x8004200b);
+	out_be32(&priv->dbell_atmu_regs->rowbar,
+			(law_start + RIO_MAINT_WIN_SIZE) >> 12);
+	out_be32(&priv->dbell_atmu_regs->rowar, 0x8004200b);	/* 4k */
 	fsl_rio_doorbell_init(port);
 
 	return 0;
-- 
1.5.4

