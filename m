From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH] macb: detect IP version to determin if we are on at91 or
 avr32
Date: Mon, 14 Mar 2011 10:39:17 +0000
Message-ID: <20110314103917.GA2825@pulham.picochip.com>
References: <1299863585-17263-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jamie Iles <jamie@jamieiles.com>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51670 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab1CNKjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 06:39:21 -0400
Content-Disposition: inline
In-Reply-To: <1299863585-17263-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I agree with Russell's comments about providing a fake hclk to remove 
the conditional clock stuff.  I was planning on posting the patch below 
in my next spin of the gem support patches which also renames macb_clk 
to pclk to be consistent with avr32 and enables us to remove all of the 
conditional clock stuff.

On Fri, Mar 11, 2011 at 06:13:05PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> this will make macb soc generic and will allow to use it on other arch
> 
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: Jamie Iles <jamie@jamieiles.com>
> ---
[...]
> diff --git a/drivers/net/macb.h b/drivers/net/macb.h
> index d3212f6..56a4fcb 100644
> --- a/drivers/net/macb.h
> +++ b/drivers/net/macb.h
> @@ -59,6 +59,7 @@
>  #define MACB_TPQ				0x00bc
>  #define MACB_USRIO				0x00c0
>  #define MACB_WOL				0x00c4
> +#define MACB_VERSION				0x00fc
>  
>  /* Bitfields in NCR */
>  #define MACB_LB_OFFSET				0
> @@ -389,6 +390,14 @@ struct macb {
>  	unsigned int 		link;
>  	unsigned int 		speed;
>  	unsigned int 		duplex;
> +
> +	uint32_t		version;

Minor nitpick, this should be u32 to be consistent with the rest of the 
fields.

>  };
>  
> +#define MACB_VERSION_MASK	0xffff0000
> +#define macb_is_at91(bp)	\
> +	(((bp)->version & MACB_VERSION_MASK) == 0x06010000)
> +#define macb_is_avr32(bp)	\
> +	(((bp)->version & MACB_VERSION_MASK) == 0x00010000)
> +
>  #endif /* _MACB_H */

I can't convince myself that this is safe and correct.  From the Cadence 
GEM spec:

31:16 Module identification number - for the GEM, this
      value is fixed at 0x0002.
15:0 Module revision - fixed byte value specific to the
     revision of the design which is incremented after
     each release of the IP.

I don't have access to the MACB spec, but it seems that 31:16 are 
defined by Cadence so there could well be other chips with a module ID 
of 0x0001 that aren't avr32.

We can certainly use this to tell us if we are GEM/MACB but if we need 
to know if we are AT91/AVR32 for the RMII/MII USRIO stuff, then couldn't 
we just keep the #ifdef CONFIG_ARCH_AT91 and factor that out into a 
macb_set_usrio() type method?

Jamie

8<---------

diff --git a/arch/arm/mach-at91/at572d940hf.c b/arch/arm/mach-at91/at572d940hf.c
index a6b9c68..9b3a37e 100644
--- a/arch/arm/mach-at91/at572d940hf.c
+++ b/arch/arm/mach-at91/at572d940hf.c
@@ -71,10 +71,15 @@ static struct clk pioC_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT572D940HF_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk usart0_clk = {
 	.name		= "usart0_clk",
 	.pmc_mask	= 1 << AT572D940HF_ID_US0,
@@ -182,6 +187,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&pioB_clk,
 	&pioC_clk,
 	&macb_clk,
+	&macb_hclk,
 	&usart0_clk,
 	&usart1_clk,
 	&usart2_clk,
diff --git a/arch/arm/mach-at91/at91cap9.c b/arch/arm/mach-at91/at91cap9.c
index 7337617..0d38ce7 100644
--- a/arch/arm/mach-at91/at91cap9.c
+++ b/arch/arm/mach-at91/at91cap9.c
@@ -150,10 +150,15 @@ static struct clk pwm_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91CAP9_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk aestdes_clk = {
 	.name		= "aestdes_clk",
 	.pmc_mask	= 1 << AT91CAP9_ID_AESTDES,
@@ -212,6 +217,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&tcb_clk,
 	&pwm_clk,
 	&macb_clk,
+	&macb_hclk,
 	&aestdes_clk,
 	&adc_clk,
 	&isi_clk,
diff --git a/arch/arm/mach-at91/at91sam9260.c b/arch/arm/mach-at91/at91sam9260.c
index 195208b..f00774c 100644
--- a/arch/arm/mach-at91/at91sam9260.c
+++ b/arch/arm/mach-at91/at91sam9260.c
@@ -162,10 +162,15 @@ static struct clk ohci_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9260_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk isi_clk = {
 	.name		= "isi_clk",
 	.pmc_mask	= 1 << AT91SAM9260_ID_ISI,
@@ -221,6 +226,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&tc2_clk,
 	&ohci_clk,
 	&macb_clk,
+	&macb_hclk,
 	&isi_clk,
 	&usart3_clk,
 	&usart4_clk,
diff --git a/arch/arm/mach-at91/at91sam9263.c b/arch/arm/mach-at91/at91sam9263.c
index 249f900..25cbae1 100644
--- a/arch/arm/mach-at91/at91sam9263.c
+++ b/arch/arm/mach-at91/at91sam9263.c
@@ -136,10 +136,15 @@ static struct clk pwm_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9263_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk dma_clk = {
 	.name		= "dma_clk",
 	.pmc_mask	= 1 << AT91SAM9263_ID_DMA,
@@ -190,6 +195,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&tcb_clk,
 	&pwm_clk,
 	&macb_clk,
+	&macb_hclk,
 	&twodge_clk,
 	&udc_clk,
 	&isi_clk,
diff --git a/arch/arm/mach-at91/at91sam9g45.c b/arch/arm/mach-at91/at91sam9g45.c
index c67b47f..a4d4a2d 100644
--- a/arch/arm/mach-at91/at91sam9g45.c
+++ b/arch/arm/mach-at91/at91sam9g45.c
@@ -157,10 +157,15 @@ static struct clk ac97_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9G45_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk isi_clk = {
 	.name		= "isi_clk",
 	.pmc_mask	= 1 << AT91SAM9G45_ID_ISI,
@@ -224,6 +229,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&lcdc_clk,
 	&ac97_clk,
 	&macb_clk,
+	&macb_hclk,
 	&isi_clk,
 	&udphs_clk,
 	&mmc1_clk,
-- 
1.7.4

