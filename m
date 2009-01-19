From: Gabriel Paubert <paubert@iram.es>
Subject: Re: mv643xx broken on pegasos
Date: Mon, 19 Jan 2009 12:18:49 +0100
Message-ID: <20090119111849.GA28927__15.5929862104998$1232364073$gmane$org@iram.es>
References: <20090115012232.3852.qmail@kosh.dhis.org>
	<20090119104225.GI17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, pacman@kosh.dhis.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090119104225.GI17124@xi.wantstofly.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2009 at 11:42:25AM +0100, Lennert Buytenhek wrote:
> On Wed, Jan 14, 2009 at 08:22:32PM -0500, pacman@kosh.dhis.org wrote:
> 
> > In 2.6.28, it behaves like 2.6.27 with a bonus bug: the port has
> > moved to eth2, and eth1 is now a phantom port with MAC address
> > 00:00:00:00:00:00. And the old 2.6.26 code doesn't compile so the
> > workaround is dead.
> 
> This is probably because mv643xx_eth now no longer fails registration
> of the interface if no valid PHY could be found.  Gabriel Paubert
> (CC'ed) had a patch for this that basically amounted to removing the
> initialisation for eth1 (called "eth0" in the Pegasos platform code).
> He's away for a couple of days but should be back soon.

Indeed, I'm back. Maybe I should have posted my patches to a mailing
list, but since I did not kow which one (linuxppc or netdev), I opted 
for none. 

In the end I have booted a Pegasos with the following patch on top of 2.6.29-rc1.
Actually I have slightly amended pegasos_eth.c since my last post on Matt's request
and I'm not going to be close to the machine and reboot it until Janurary 20th but 
it's only a few renames (and at least it builds), but buyer beware (note that the
patches to drivers/net/mv643xx_eth.c have already been submitted separately
by Lennert through netdev):


diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 130ff72..039fc8e 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -21,8 +21,8 @@
 #define PEGASOS2_SRAM_BASE 			(0xf2000000)
 #define PEGASOS2_SRAM_SIZE			(256*1024)
 
-#define PEGASOS2_SRAM_BASE_ETH0			(PEGASOS2_SRAM_BASE)
-#define PEGASOS2_SRAM_BASE_ETH1			(PEGASOS2_SRAM_BASE_ETH0 + (PEGASOS2_SRAM_SIZE / 2) )
+#define PEGASOS2_SRAM_BASE_ETH_PORT0			(PEGASOS2_SRAM_BASE)
+#define PEGASOS2_SRAM_BASE_ETH_PORT1			(PEGASOS2_SRAM_BASE_ETH_PORT0 + (PEGASOS2_SRAM_SIZE / 2) )
 
 
 #define PEGASOS2_SRAM_RXRING_SIZE		(PEGASOS2_SRAM_SIZE/4)
@@ -47,75 +47,42 @@ static struct platform_device mv643xx_eth_shared_device = {
 	.resource	= mv643xx_eth_shared_resources,
 };
 
-static struct resource mv643xx_eth0_resources[] = {
+static struct resource mv643xx_eth_port1_resources[] = {
 	[0] = {
-		.name	= "eth0 irq",
+		.name	= "eth port1 irq",
 		.start	= 9,
 		.end	= 9,
 		.flags	= IORESOURCE_IRQ,
 	},
 };
 
-
-static struct mv643xx_eth_platform_data eth0_pd = {
-	.shared		= &mv643xx_eth_shared_device,
-	.port_number	= 0,
-
-	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH0,
-	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
-	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
-
-	.rx_sram_addr = PEGASOS2_SRAM_BASE_ETH0 + PEGASOS2_SRAM_TXRING_SIZE,
-	.rx_sram_size = PEGASOS2_SRAM_RXRING_SIZE,
-	.rx_queue_size = PEGASOS2_SRAM_RXRING_SIZE/16,
-};
-
-static struct platform_device eth0_device = {
-	.name		= MV643XX_ETH_NAME,
-	.id		= 0,
-	.num_resources	= ARRAY_SIZE(mv643xx_eth0_resources),
-	.resource	= mv643xx_eth0_resources,
-	.dev = {
-		.platform_data = &eth0_pd,
-	},
-};
-
-static struct resource mv643xx_eth1_resources[] = {
-	[0] = {
-		.name	= "eth1 irq",
-		.start	= 9,
-		.end	= 9,
-		.flags	= IORESOURCE_IRQ,
-	},
-};
-
-static struct mv643xx_eth_platform_data eth1_pd = {
+static struct mv643xx_eth_platform_data eth_port1_pd = {
 	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 1,
+	.phy_addr	= MV643XX_ETH_PHY_ADDR(7),
 
-	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH1,
+	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH_PORT1,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
 
-	.rx_sram_addr = PEGASOS2_SRAM_BASE_ETH1 + PEGASOS2_SRAM_TXRING_SIZE,
+	.rx_sram_addr = PEGASOS2_SRAM_BASE_ETH_PORT1 + PEGASOS2_SRAM_TXRING_SIZE,
 	.rx_sram_size = PEGASOS2_SRAM_RXRING_SIZE,
 	.rx_queue_size = PEGASOS2_SRAM_RXRING_SIZE/16,
 };
 
-static struct platform_device eth1_device = {
+static struct platform_device eth_port1_device = {
 	.name		= MV643XX_ETH_NAME,
 	.id		= 1,
-	.num_resources	= ARRAY_SIZE(mv643xx_eth1_resources),
-	.resource	= mv643xx_eth1_resources,
+	.num_resources	= ARRAY_SIZE(mv643xx_eth_port1_resources),
+	.resource	= mv643xx_eth_port1_resources,
 	.dev = {
-		.platform_data = &eth1_pd,
+		.platform_data = &eth_port1_pd,
 	},
 };
 
 static struct platform_device *mv643xx_eth_pd_devs[] __initdata = {
 	&mv643xx_eth_shared_device,
-	&eth0_device,
-	&eth1_device,
+	&eth_port1_device,
 };
 
 /***********/
@@ -191,15 +158,10 @@ static int __init mv643xx_eth_add_pds(void)
 
 		if ( Enable_SRAM() < 0)
 		{
-			eth0_pd.tx_sram_addr = 0;
-			eth0_pd.tx_sram_size = 0;
-			eth0_pd.rx_sram_addr = 0;
-			eth0_pd.rx_sram_size = 0;
-
-			eth1_pd.tx_sram_addr = 0;
-			eth1_pd.tx_sram_size = 0;
-			eth1_pd.rx_sram_addr = 0;
-			eth1_pd.rx_sram_size = 0;
+			eth_port1_pd.tx_sram_addr = 0;
+			eth_port1_pd.tx_sram_size = 0;
+			eth_port1_pd.rx_sram_addr = 0;
+			eth_port1_pd.rx_sram_size = 0;
 
 #ifdef BE_VERBOSE
 			printk("Pegasos II/Marvell MV64361: Can't enable the "
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 7253a49..fc8836d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -136,15 +136,17 @@ static char mv643xx_eth_driver_version[] = "1.4";
 /*
  * SDMA configuration register.
  */
+#define RX_BURST_SIZE_4_64BIT		(2 << 1)
 #define RX_BURST_SIZE_16_64BIT		(4 << 1)
 #define BLM_RX_NO_SWAP			(1 << 4)
 #define BLM_TX_NO_SWAP			(1 << 5)
+#define TX_BURST_SIZE_4_64BIT		(2 << 22)
 #define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		(RX_BURST_SIZE_16_64BIT	|	\
-		TX_BURST_SIZE_16_64BIT)
+		(RX_BURST_SIZE_4_64BIT	|	\
+		TX_BURST_SIZE_4_64BIT)
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		(RX_BURST_SIZE_16_64BIT	|	\
@@ -2210,6 +2212,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
+	wrlp(mp, INT_MASK_EXT, 0x00000000);
 	wrlp(mp, INT_MASK, 0x00000000);
 	rdlp(mp, INT_MASK);
 


> Also, since the mv643xx_eth phylib conversion, it appears that the
> PHY on the Pegasos board fails to initialise properly, and this can
> apparently be worked around by turning the Marvell phylib driver off.
> Are you seeing this as well?

At least I experienced this problem. On the Pegasos, the generic
PHY driver works, the Marvell specific ones screws up (at least 
when connected to a 100Mb/s hub, it detects it as 1Gb). 


	Gabriel
