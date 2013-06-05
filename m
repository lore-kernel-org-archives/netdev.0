From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v4 5/8] sh_eth: add IRQ flags to 'struct sh_eth_cpu_data'
Date: Thu, 6 Jun 2013 01:15:27 +0400
Message-ID: <201306060115.27643.sergei.shtylyov@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

The driver supports some SH and SH-Mobile SOCs. There are SOCs with two or more
Ethernet devices, for these we need to pass IRQF_SHARED to request_irq().  Add
the 'irq_flags' field to the 'struct sh_eth_cpu_data' instead of #ifdef'fery.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: properly aligned request_irq() call continuation line, reworded the
changelog, reworded the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 4:
- resolved reject;
- properly aligned request_irq() call continuation line;
- reworded the changelog;
- reworded the subject, changing the prefix.

Changes in version 3:
- remove 'irq_flags' from 'struct sh_eth_private';
- fix indentation.

 drivers/net/ethernet/renesas/sh_eth.c |   13 +++++--------
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 6 insertions(+), 8 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -462,6 +462,7 @@ static struct sh_eth_cpu_data sh_eth_my_
 			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
 	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
+	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
 	.mpr		= 1,
 	.tpauser	= 1,
@@ -570,6 +571,7 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.fdr_value	= 0x0000072f,
 	.rmcr_value	= 0x00000001,
 
+	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
 	.mpr		= 1,
 	.tpauser	= 1,
@@ -650,6 +652,8 @@ static struct sh_eth_cpu_data sh_eth_my_
 #if defined(CONFIG_CPU_SUBTYPE_SH7734)
 	.hw_crc     = 1,
 	.select_mii = 1,
+#else
+	.irq_flags	= IRQF_SHARED,
 #endif
 };
 
@@ -1908,14 +1912,7 @@ static int sh_eth_open(struct net_device
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
-#if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7757)
-				IRQF_SHARED,
-#else
-				0,
-#endif
-				ndev->name, ndev);
+			  mdp->cd->irq_flags, ndev->name, ndev);
 	if (ret) {
 		dev_err(&ndev->dev, "Can not assign IRQ number\n");
 		return ret;
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -463,6 +463,7 @@ struct sh_eth_cpu_data {
 	unsigned long tx_error_check;
 
 	/* hardware features */
+	unsigned long irq_flags;	/* IRQ configuration flags */
 	unsigned no_psr:1;		/* EtherC DO NOT have PSR */
 	unsigned apr:1;			/* EtherC have APR */
 	unsigned mpr:1;			/* EtherC have MPR */
