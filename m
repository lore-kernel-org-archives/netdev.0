From: Dinh Nguyen <dinguyen@altera.com>
Subject: Re: socfpga/sockit ethernet problems
Date: Mon, 7 Jul 2014 15:25:51 -0500
Message-ID: <1404764751.14294.3.camel@linux-builds1>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
	 <20140703093548.GA9937@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <gsi@denx.de>,
	<dzu@denx.de>
To: ZY - pavel <pavel@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0139.outbound.protection.outlook.com ([207.46.163.139]:41990
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753108AbaGGU25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2014 16:28:57 -0400
In-Reply-To: <20140703093548.GA9937@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

On Thu, 2014-07-03 at 11:35 +0200, ZY - pavel wrote:
> Hi!
> 
> > 
> > It seems we have some problems with Ethernet on socfpga boards.
> > 
> > Like, "stmmac: Energy-Efficient Ethernet initialized" repeated way too
> > often. Or machine failing to boot because NFS server can not be
> > accessed. (And then working on next try). Or link going up and down
> > and up and down. Or link taking 3 seconds, 10 seconds to estabilish.
> > 

The "stmmac: Energy-Efficient Ethernet initialized" being repeated
should have been fixed with this commit:

138b1ceb2613 stmmac: disable at run-time the EEE if not supported

> > It also seems to be picky about hubs it wants to talk to.
> > 
> > This time it mounted root; on last boot it just hung.
> ...
> > u-boot talk 12.033741 Configuring PHY skew timing for Micrel ksz9021
> > 
> > is there something similar that needs to be done at Linux layer.
> 
> It seems there is. There is patch at
> http://lists.infradead.org/pipermail/linux-arm-kernel/2013-July/184335.html
> , but it does not match the code we have in u-boot (and that seems to
> work).
> 
> I made this, but ethernet problems I currently see are not frequent
> enough to allow easy debugging. If link takes long to  estabilish for
> you, could you test the patch below?
> 
> Thanks,
> 								Pavel
> 
> Signed-off-by: Pavel Machek <pavel@denx.de>
> 
> diff --git a/arch/arm/mach-at91/board-dt-sama5.c b/arch/arm/mach-at91/board-dt-sama5.c
> index 075ec05..6a2d5f7 100644
> --- a/arch/arm/mach-at91/board-dt-sama5.c
> +++ b/arch/arm/mach-at91/board-dt-sama5.c
> @@ -51,11 +51,11 @@ static int ksz9021rn_phy_fixup(struct phy_device *phy)
>  	int value;
>  
>  	/* Set delay values */
> -	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW | 0x8000;
> +	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW | 0x8000;
>  	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
>  	value = 0xF2F4;
>  	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
> -	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW | 0x8000;
> +	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW | 0x8000;
>  	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
>  	value = 0x2222;
>  	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
> diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
> index e60456d..8a0ba06 100644
> --- a/arch/arm/mach-imx/mach-imx6q.c
> +++ b/arch/arm/mach-imx/mach-imx6q.c
> @@ -45,15 +45,15 @@ static int ksz9021rn_phy_fixup(struct phy_device *phydev)
>  	if (IS_BUILTIN(CONFIG_PHYLIB)) {
>  		/* min rx data delay */
>  		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> -			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW);
> +			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW);
>  		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
>  
>  		/* max rx/tx clock delay, min rx/tx control delay */
>  		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> -			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
> +			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
>  		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
>  		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> -			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
> +			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
>  	}
>  
>  	return 0;
> diff --git a/arch/arm/mach-socfpga/socfpga.c b/arch/arm/mach-socfpga/socfpga.c
> index adbf383..4a953c0 100644
> --- a/arch/arm/mach-socfpga/socfpga.c
> +++ b/arch/arm/mach-socfpga/socfpga.c
> @@ -19,6 +19,8 @@
>  #include <linux/of_irq.h>
>  #include <linux/of_platform.h>
>  #include <linux/reboot.h>
> +#include <linux/phy.h>
> +#include <linux/micrel_phy.h>
>  
>  #include <asm/hardware/cache-l2x0.h>
>  #include <asm/mach/arch.h>
> @@ -85,6 +87,44 @@ static void __init socfpga_init_irq(void)
>  	socfpga_sysmgr_init();
>  }
>  
> +static int ksz9021rn_phy_fixup(struct phy_device *phydev)
> +{
> +        if (IS_BUILTIN(CONFIG_PHYLIB)) {
> +		printk("------------- running phy fixup\n");
> +
> +                /* min rx data delay */
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> +			  0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW);
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
> +
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> +			  0x8000 | MICREL_KSZ9021_RGMII_TX_DATA_PAD_SKEW);
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
> +
> +                /* max rx/tx clock delay, min rx/tx control delay */
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> +			  0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
> +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> +			  MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
> +        }
> +
> +        return 0;
> +}
> +

All of this stuff is not needed as it's already taken care of by the
Micrel phy driver. The clock skew values are now represented in the DTS.
Please look at:

Documentation/devicetree/bindings/net/micrel-ksz90x1.txt

Dinh
