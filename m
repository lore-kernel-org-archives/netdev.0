From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH v5 2/3] ARM: shmobile: lager: enable Ether
Date: Wed, 24 Jul 2013 19:28:29 +0900
Message-ID: <CANqRtoQ-1tr44u_y7Ay1PjOGcGjcn63O=Hd1+Th-Q8rHpGyLjg@mail.gmail.com>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
	<1374656169-9241-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374656169-9241-3-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 24, 2013 at 5:56 PM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
>
> This patch has a run-time dependency on "sh_eth: add support for r8a7790 SoC".
>
> v5
> * As suggested by Laurent Pinchart
>   - Do not use eth_magic pinmux group, that pin is not used on Lager
> * As suggested by Morimoto-san and Magnus Damm
>   - Refactor moving all setup code into boards-lager.c
>
> v4
> * Remove needs_gpio_reset and reset_gpio from ether_platdata
>   as the patch that adds that feature and those fields has
>   been dropped.
> * Annotate ether_platdata as __initdata
>
> v3
> * Use newly added "r8a7790-ether" instead of "sh-eth"
>
> v2
> * Do not add MSTP812, EtherAVB. It is not used.
> * As suggested by Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>   - Move Ethernet element of MSTP enum to a separate line
>   - Move declaration of r8a7790_add_ether_device() to immediately
>     after that of r8a7790_add_standard_devices()
>   - Add __initdata annotation to ether_resource.
> * As suggested by Laurent Pinchart
>   - Do not manipilate sh_eth reset GPIO directly,
>     rather, do so through newly proposed support for this in
>     the sh_eth driver.
> * A suggested by Sergei Shtylyov
>   - Move DTS portion into a separate patch
> ---
>  arch/arm/mach-shmobile/board-lager.c | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
>
> diff --git a/arch/arm/mach-shmobile/board-lager.c b/arch/arm/mach-shmobile/board-lager.c
> index 3c67b2a..86e6319 100644
> --- a/arch/arm/mach-shmobile/board-lager.c
> +++ b/arch/arm/mach-shmobile/board-lager.c
> @@ -31,6 +31,7 @@
>  #include <linux/platform_device.h>
>  #include <linux/regulator/fixed.h>
>  #include <linux/regulator/machine.h>
> +#include <linux/sh_eth.h>
>  #include <mach/common.h>
>  #include <mach/irqs.h>
>  #include <mach/r8a7790.h>
> @@ -91,6 +92,20 @@ static struct resource mmcif1_resources[] = {
>         DEFINE_RES_IRQ(gic_spi(170)),
>  };
>
> +/* Ether */
> +static struct sh_eth_plat_data ether_pdata __initdata = {
> +       .phy                    = 0x1,
> +       .edmac_endian           = EDMAC_LITTLE_ENDIAN,
> +       .register_type          = SH_ETH_REG_FAST_RCAR,
> +       .phy_interface          = PHY_INTERFACE_MODE_RMII,
> +       .ether_link_active_low  = 1,
> +};
> +
> +static struct resource ether_resources[] __initdata = {
> +       DEFINE_RES_MEM(0xee700000, 0x400),
> +       DEFINE_RES_IRQ(gic_spi(162)), /* IRQ0 */

Hi Simon,

Thanks for your patch series. In general it looks good, but
surprisingly I have some comments related to interrupts.

According to the data sheet SPI 162 is ETHER(Fast), so gic_spi(162)
above is correct. But the comment seems wrong.

I'm not sure where external interrupt pin IRQ0 comes from above, but I
assume it is for the PHY chip. If so then we need to hook up the PHY
interrupt as well. This may require some driver changes, I'm not sure.

For external IRQ pins you want to use either INTC or GPIO depending on
which pin you use, so using gic_spi() directly is always wrong. Please
consult the lager manual or schematics for pin information.

Cheers,

/ magnus
