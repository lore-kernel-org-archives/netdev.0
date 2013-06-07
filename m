From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 6/9] sh_eth: get SH7757 support out of #ifdef
Date: Sat, 8 Jun 2013 03:59:21 +0400
Message-ID: <201306080359.21534.sergei.shtylyov@cogentembedded.com>
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

Get the SH7757 code/data in the driver out of #ifdef by adding "sh7757-ether"
and "sh7757-gether" to the platform driver's ID table.  Note that we can remove
SH_ETH_HAS_BOTH_MODULES and sh_eth_get_cpu_data().
Change the Ether/GEther platform devices' names in the SH platform code
accordingly.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 arch/sh/boards/board-sh7757lcr.c      |    8 ++++----
 drivers/net/ethernet/renesas/sh_eth.c |   28 ++++++++--------------------
 2 files changed, 12 insertions(+), 24 deletions(-)

Index: net-next/arch/sh/boards/board-sh7757lcr.c
===================================================================
--- net-next.orig/arch/sh/boards/board-sh7757lcr.c
+++ net-next/arch/sh/boards/board-sh7757lcr.c
@@ -82,7 +82,7 @@ static struct sh_eth_plat_data sh7757_et
 };
 
 static struct platform_device sh7757_eth0_device = {
-	.name		= "sh-eth",
+	.name		= "sh7757-ether",
 	.resource	= sh_eth0_resources,
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(sh_eth0_resources),
@@ -111,7 +111,7 @@ static struct sh_eth_plat_data sh7757_et
 };
 
 static struct platform_device sh7757_eth1_device = {
-	.name		= "sh-eth",
+	.name		= "sh7757-ether",
 	.resource	= sh_eth1_resources,
 	.id		= 1,
 	.num_resources	= ARRAY_SIZE(sh_eth1_resources),
@@ -157,7 +157,7 @@ static struct sh_eth_plat_data sh7757_et
 };
 
 static struct platform_device sh7757_eth_giga0_device = {
-	.name		= "sh-eth",
+	.name		= "sh7757-gether",
 	.resource	= sh_eth_giga0_resources,
 	.id		= 2,
 	.num_resources	= ARRAY_SIZE(sh_eth_giga0_resources),
@@ -192,7 +192,7 @@ static struct sh_eth_plat_data sh7757_et
 };
 
 static struct platform_device sh7757_eth_giga1_device = {
-	.name		= "sh-eth",
+	.name		= "sh7757-gether",
 	.resource	= sh_eth_giga1_resources,
 	.id		= 3,
 	.num_resources	= ARRAY_SIZE(sh_eth_giga1_resources),
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -431,10 +431,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.rpadir		= 1,
 	.rpadir_value	= 0x00020000, /* NET_IP_ALIGN assumed to be 2 */
 };
-#elif defined(CONFIG_CPU_SUBTYPE_SH7757)
-#define SH_ETH_HAS_BOTH_MODULES	1
+#endif
 
-static void sh_eth_set_rate(struct net_device *ndev)
+static void sh_eth_set_rate_sh7757(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -451,9 +450,9 @@ static void sh_eth_set_rate(struct net_d
 }
 
 /* SH7757 */
-static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
-	.set_duplex		= sh_eth_set_duplex,
-	.set_rate		= sh_eth_set_rate,
+static struct sh_eth_cpu_data sh7757_data = {
+	.set_duplex	= sh_eth_set_duplex,
+	.set_rate	= sh_eth_set_rate_sh7757,
 
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.rmcr_value	= 0x00000001,
@@ -518,7 +517,7 @@ static void sh_eth_set_rate_giga(struct 
 }
 
 /* SH7757(GETHERC) */
-static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
+static struct sh_eth_cpu_data sh7757_data_giga = {
 	.chip_reset	= sh_eth_chip_reset_giga,
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_giga,
@@ -549,15 +548,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tsu		= 1,
 };
 
-static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
-{
-	if (sh_eth_is_gether(mdp))
-		return &sh_eth_my_cpu_data_giga;
-	else
-		return &sh_eth_my_cpu_data;
-}
-#endif
-
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -2577,11 +2567,7 @@ static int sh_eth_drv_probe(struct platf
 	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);
 
 	/* set cpu data */
-#if defined(SH_ETH_HAS_BOTH_MODULES)
-	mdp->cd = sh_eth_get_cpu_data(mdp);
-#else
 	mdp->cd = &sh_eth_my_cpu_data;
-#endif
 	if (id->driver_data)
 		mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
 	sh_eth_set_default_cpu_data(mdp->cd);
@@ -2702,6 +2688,8 @@ static struct platform_device_id sh_eth_
 	{ "sh7619-ether", (kernel_ulong_t)&sh7619_data },
 	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
 	{ "sh7734-gether", (kernel_ulong_t)&sh7734_data },
+	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
+	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ CARDNAME },
