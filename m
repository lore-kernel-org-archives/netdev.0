From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 7/9] sh_eth: get SH7724 support out of #ifdef
Date: Sat, 8 Jun 2013 04:03:37 +0400
Message-ID: <201306080403.37551.sergei.shtylyov@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, lethal@linux-sh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:43377 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757096Ab3FHADc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 20:03:32 -0400
Received: by mail-la0-f45.google.com with SMTP id fr10so4206852lab.4
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 17:03:30 -0700 (PDT)
In-Reply-To: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get the SH7724 code/data in the driver out of #ifdef by adding "r8a7724-ether"
to the platform driver's ID table. Change the Ether platform device's name in
the SH platform code accordingly.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Note that the Ether paltform data in the SolutionEngine7724 board code lacks the
initializer for the 'register_type' field which means it'll be  incorrectly  set
to SH_ETH_REG_GIGABIT...

 arch/sh/boards/mach-ecovec24/setup.c   |    4 ++--
 arch/sh/boards/mach-se/7724/setup.c    |    4 ++--
 arch/sh/kernel/cpu/sh4a/clock-sh7724.c |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c  |   10 +++++-----
 4 files changed, 10 insertions(+), 10 deletions(-)

Index: net-next/arch/sh/boards/mach-ecovec24/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-ecovec24/setup.c
+++ net-next/arch/sh/boards/mach-ecovec24/setup.c
@@ -165,8 +165,8 @@ static struct sh_eth_plat_data sh_eth_pl
 };
 
 static struct platform_device sh_eth_device = {
-	.name = "sh-eth",
-	.id	= 0,
+	.name = "sh7724-ether",
+	.id = 0,
 	.dev = {
 		.platform_data = &sh_eth_plat,
 	},
Index: net-next/arch/sh/boards/mach-se/7724/setup.c
===================================================================
--- net-next.orig/arch/sh/boards/mach-se/7724/setup.c
+++ net-next/arch/sh/boards/mach-se/7724/setup.c
@@ -380,8 +380,8 @@ static struct sh_eth_plat_data sh_eth_pl
 };
 
 static struct platform_device sh_eth_device = {
-	.name = "sh-eth",
-	.id	= 0,
+	.name = "sh7724-ether",
+	.id = 0,
 	.dev = {
 		.platform_data = &sh_eth_plat,
 	},
Index: net-next/arch/sh/kernel/cpu/sh4a/clock-sh7724.c
===================================================================
--- net-next.orig/arch/sh/kernel/cpu/sh4a/clock-sh7724.c
+++ net-next/arch/sh/kernel/cpu/sh4a/clock-sh7724.c
@@ -329,7 +329,7 @@ static struct clk_lookup lookups[] = {
 	CLKDEV_DEV_ID("i2c-sh_mobile.0", &mstp_clks[HWBLK_IIC0]),
 	CLKDEV_DEV_ID("i2c-sh_mobile.1", &mstp_clks[HWBLK_IIC1]),
 	CLKDEV_DEV_ID("sh_mmcif.0", &mstp_clks[HWBLK_MMC]),
-	CLKDEV_DEV_ID("sh-eth.0", &mstp_clks[HWBLK_ETHER]),
+	CLKDEV_DEV_ID("sh7724-ether.0", &mstp_clks[HWBLK_ETHER]),
 	CLKDEV_CON_ID("atapi0", &mstp_clks[HWBLK_ATAPI]),
 	CLKDEV_CON_ID("tpu0", &mstp_clks[HWBLK_TPU]),
 	CLKDEV_CON_ID("irda0", &mstp_clks[HWBLK_IRDA]),
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -392,9 +392,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tpauser	= 1,
 	.hw_swap	= 1,
 };
-#elif defined(CONFIG_CPU_SUBTYPE_SH7724)
+#endif
 
-static void sh_eth_set_rate(struct net_device *ndev)
+static void sh_eth_set_rate_sh7724(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -411,9 +411,9 @@ static void sh_eth_set_rate(struct net_d
 }
 
 /* SH7724 */
-static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+static struct sh_eth_cpu_data sh7724_data = {
 	.set_duplex	= sh_eth_set_duplex,
-	.set_rate	= sh_eth_set_rate,
+	.set_rate	= sh_eth_set_rate_sh7724,
 
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
@@ -431,7 +431,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.rpadir		= 1,
 	.rpadir_value	= 0x00020000, /* NET_IP_ALIGN assumed to be 2 */
 };
-#endif
 
 static void sh_eth_set_rate_sh7757(struct net_device *ndev)
 {
@@ -2687,6 +2686,7 @@ static const struct dev_pm_ops sh_eth_de
 static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7619-ether", (kernel_ulong_t)&sh7619_data },
 	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
+	{ "sh7724-ether", (kernel_ulong_t)&sh7724_data },
 	{ "sh7734-gether", (kernel_ulong_t)&sh7734_data },
 	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
