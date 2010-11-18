From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH 1/2] of/phylib: Use device tree properties to initialize
 Marvell PHYs.
Date: Thu, 18 Nov 2010 14:32:52 -0500
Message-ID: <4CE57F64.8040200@ti.com>
References: <1290038071-13296-1-git-send-email-ddaney@caviumnetworks.com> <1290038071-13296-2-git-send-email-ddaney@caviumnetworks.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"grant.likely@secretlab.ca" <grant.likely@secretlab.ca>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290038071-13296-2-git-send-email-ddaney@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/17/2010 06:54 PM, David Daney wrote:
> Some aspects of PHY initialization are board dependent, things like
> indicator LED connections and some clocking modes cannot be determined
> by probing.  The dev_flags element of struct phy_device can be used to
> control these things if an appropriate value can be passed from the
> Ethernet driver.  We run into problems however if the PHY connections
> are specified by the device tree.  There is no way for the Ethernet
> driver to know what flags it should pass.
> 
> If we are using the device tree, the struct phy_device will be
> populated with the device tree node corresponding to the PHY, and we
> can extract extra configuration information from there.
> 
> The next question is what should the format of that information be?
> It is highly device specific, and the device tree representation
> should not be tied to any arbitrary kernel defined constants.  A
> straight forward representation is just to specify the exact bits that
> should be set using the "marvell,reg-init" property:
> 
>       phy5: ethernet-phy@5 {
> 	reg = <5>;
> 	device_type = "ethernet-phy";
> 	marvell,reg-init =
> 		<0x00030010 0x5777>, /* Reg 3,16 <- 0x5777 */
> 		<0x00030011 0x00aa>, /* Reg 3,17 <- 0x00aa */
> 		<0x00030012 0x4105>, /* Reg 3,18 <- 0x4105 */
> 		<0x00030013 0x0060>; /* Reg 3,19 <- 0x0060 */
> 		<0x00020015 0x00300000>; /* clear bits 4..5 of Reg 2,21 */
>       };
> 
> The Marvell PHYs have a page select register at register 22 (0x16), we
> can specify any register by its page and register number.  These are
> encoded in the high and low parts of the first word.  The second word
> contains a mask and value to be ORed in its high and low parts.  The
> new marvell_of_reg_init function leaves the page select register
> unchanged, so a call to it can be dropped into the .config_init
> functions without unduly affecting the state of the PHY.
> 
> If CONFIG_OF is not set, there is no of_node, or no "marvell,reg-init"
> property, the PHY initialization is unchanged.
> 
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Cyril Chemparathy <cyril@ti.com>
> Cc: David Daney <ddaney@caviumnetworks.com>
> Cc: Arnaud Patard <arnaud.patard@rtp-net.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/phy/marvell.c |   91 +++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 91 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index f0bd1a1..33ad654 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -30,6 +30,7 @@
>  #include <linux/ethtool.h>
>  #include <linux/phy.h>
>  #include <linux/marvell_phy.h>
> +#include <linux/of.h>
>  
>  #include <asm/io.h>
>  #include <asm/irq.h>
> @@ -186,6 +187,85 @@ static int marvell_config_aneg(struct phy_device *phydev)
>  	return 0;
>  }
>  
> +#ifndef CONFIG_OF
> +static int marvell_of_reg_init(struct phy_device *phydev)
> +{
> +	return 0;
> +}
> +#else
> +/*
> + * Set and/or override some configuration registers based on the
> + * marvell,reg-init property stored in the of_node for the phydev.
> + *
> + * marvell,reg-init = <reg-spec val-spec>,...;
> + *
> + * There may be one or more  pairs of <reg-spec val-spec>:
> + * reg-spec [16..31]: Page address.
> + * reg-spec [0..15]: Register address.
> + *
> + * val-spec [16..31]: Mask bits.
> + * val-spec [0..15]: Register bits.
> + */
> +static int marvell_of_reg_init(struct phy_device *phydev)
> +{
> +	const __be32 *paddr;
> +	int len, i, saved_page, current_page, page_changed, ret;
> +
> +	if (!phydev->dev.of_node)
> +		return 0;
> +
> +	paddr = of_get_property(phydev->dev.of_node, "marvell,reg-init", &len);
> +	if (!paddr || len < (2 * sizeof(u32)))
> +		return 0;
> +
> +	saved_page = phy_read(phydev, 22);

Please use MII_88E1121_PHY_PAGE (renamed if necessary) instead of 22 here.

> +	if (saved_page < 0)
> +		return saved_page;
> +	page_changed = 0;
> +	current_page = saved_page;
> +
> +	ret = 0;
> +	len /= sizeof(u32);
> +	for (i = 0; i < len / 2; i += 2) {
> +		u32 reg_spec =  be32_to_cpup(&paddr[i]);
> +		u32 val_spec =  be32_to_cpup(&paddr[i + 1]);
> +		u16 reg = reg_spec & 0xffff;
> +		u16 reg_page = reg_spec >> 16;
> +		u16 val_bits = val_spec & 0xffff;
> +		u16 mask = val_spec >> 16;
> +		int val;
> +
> +		if (reg_page != current_page) {
> +			ret = phy_write(phydev, 22, reg_page);
> +			if (ret < 0)
> +				goto err;
> +			current_page = reg_page;
> +			page_changed = 1;
> +		}
> +
> +		val = 0;
> +		if (mask) {
> +			val = phy_read(phydev, reg);

If this phy_read() were to fail...

> +			if (val < 0) {
> +				ret = val;
> +				goto err;
> +			}
> +			val &= mask;
> +		}
> +		val |= val_bits;
> +
> +		ret = phy_write(phydev, reg, (u16)val);
> +		if (ret < 0)
> +			goto err;
> +
> +	}
> +err:
> +	if (page_changed)
> +		ret = phy_write(phydev, 22, saved_page);
> +	return ret;

... this function may incorrectly return success if the phy_write()
succeeds.

Some mdio controllers verify turn around during read operations and
return failure if the phy fails to drive the data line low.  On write
transactions turn around is driven by the controller, and failures may
go undetected.

[...]

Regards
- Cyril.
