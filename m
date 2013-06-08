From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 8/9] sh_eth: get R8A777x support out of #ifdef
Date: Sat, 8 Jun 2013 04:05:59 +0400
Message-ID: <201306080405.59474.sergei.shtylyov@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get the R-Car code/data in the driver out of #ifdef by adding "r8a777x-ether" to
the platfrom driver's  ID table; since it's the last #ifdef, we remove CARDNAME
from the  ID table and no longer check  the driver data before  assigning it to
'mdp->cd'...
Change the Ether platform device's name in the ARM platform code accordingly.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Note that the Ether device on R8A777[89]  cannot yet be used due to  the typo in
the device name when registering the platform device -- I'll fix this in the ARM
tree. Moreover, the only working Ether board code (for the BOCK-W board) will be
merged only in 3.11...

 arch/arm/mach-shmobile/clock-r8a7778.c |    2 +-
 arch/arm/mach-shmobile/clock-r8a7779.c |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c  |   14 +++++---------
 3 files changed, 7 insertions(+), 11 deletions(-)

Index: net-next/arch/arm/mach-shmobile/clock-r8a7778.c
===================================================================
--- net-next.orig/arch/arm/mach-shmobile/clock-r8a7778.c
+++ net-next/arch/arm/mach-shmobile/clock-r8a7778.c
@@ -77,7 +77,7 @@ static struct clk mstp_clks[MSTP_NR] = {
 
 static struct clk_lookup lookups[] = {
 	/* MSTP32 clocks */
-	CLKDEV_DEV_ID("sh-eth",	&mstp_clks[MSTP114]), /* Ether */
+	CLKDEV_DEV_ID("r8a777x-ether", &mstp_clks[MSTP114]), /* Ether */
 	CLKDEV_DEV_ID("sh-sci.0", &mstp_clks[MSTP026]), /* SCIF0 */
 	CLKDEV_DEV_ID("sh-sci.1", &mstp_clks[MSTP025]), /* SCIF1 */
 	CLKDEV_DEV_ID("sh-sci.2", &mstp_clks[MSTP024]), /* SCIF2 */
Index: net-next/arch/arm/mach-shmobile/clock-r8a7779.c
===================================================================
--- net-next.orig/arch/arm/mach-shmobile/clock-r8a7779.c
+++ net-next/arch/arm/mach-shmobile/clock-r8a7779.c
@@ -163,7 +163,7 @@ static struct clk_lookup lookups[] = {
 	/* MSTP32 clocks */
 	CLKDEV_DEV_ID("sata_rcar", &mstp_clks[MSTP115]), /* SATA */
 	CLKDEV_DEV_ID("fc600000.sata", &mstp_clks[MSTP115]), /* SATA w/DT */
-	CLKDEV_DEV_ID("sh-eth", &mstp_clks[MSTP114]), /* Ether */
+	CLKDEV_DEV_ID("r8a777x-ether", &mstp_clks[MSTP114]), /* Ether */
 	CLKDEV_DEV_ID("ehci-platform.1", &mstp_clks[MSTP101]), /* USB EHCI port2 */
 	CLKDEV_DEV_ID("ohci-platform.1", &mstp_clks[MSTP101]), /* USB OHCI port2 */
 	CLKDEV_DEV_ID("ehci-platform.0", &mstp_clks[MSTP100]), /* USB EHCI port0/1 */
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -356,8 +356,7 @@ static void __maybe_unused sh_eth_set_du
 }
 
 /* There is CPU dependent code */
-#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
-static void sh_eth_set_rate(struct net_device *ndev)
+static void sh_eth_set_rate_r8a777x(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -374,9 +373,9 @@ static void sh_eth_set_rate(struct net_d
 }
 
 /* R8A7778/9 */
-static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+static struct sh_eth_cpu_data r8a777x_data = {
 	.set_duplex	= sh_eth_set_duplex,
-	.set_rate	= sh_eth_set_rate,
+	.set_rate	= sh_eth_set_rate_r8a777x,
 
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
@@ -392,7 +391,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tpauser	= 1,
 	.hw_swap	= 1,
 };
-#endif
 
 static void sh_eth_set_rate_sh7724(struct net_device *ndev)
 {
@@ -2566,9 +2564,7 @@ static int sh_eth_drv_probe(struct platf
 	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);
 
 	/* set cpu data */
-	mdp->cd = &sh_eth_my_cpu_data;
-	if (id->driver_data)
-		mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
+	mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
 	sh_eth_set_default_cpu_data(mdp->cd);
 
 	/* set function */
@@ -2692,7 +2688,7 @@ static struct platform_device_id sh_eth_
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
-	{ CARDNAME },
+	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
