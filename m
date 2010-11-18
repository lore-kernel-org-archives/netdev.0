From: Milton Miller <miltonm-ogEGBHC/i9Y@public.gmane.org>
Subject: Re: [1/2] of/phylib: Use device tree properties to initialize Marvell
	PHYs.
Date: Wed, 17 Nov 2010 23:38:50 -0600
Message-ID: <marvell-phy@mdm.bga.com>
References: <1290038071-13296-2-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>,
	Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
To: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1290038071-13296-2-git-send-email-ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2010 15:54:30 -0800, David Daney wrote:
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
..
> 
> ---
> drivers/net/phy/marvell.c |   91 +++++++++++++++++++++++++++++++++++++++++++++
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
> +	if (saved_page < 0)
> +		return saved_page;
> +	page_changed = 0;
> +	current_page = saved_page;
> +
> +	ret = 0;
> +	len /= sizeof(u32);
> +	for (i = 0; i < len / 2; i += 2) {

i < len - 1 would execute all the register inits specified in the property.

> +		u32 reg_spec =  be32_to_cpup(&paddr[i]);
> +		u32 val_spec =  be32_to_cpup(&paddr[i + 1]);
> +		u16 reg = reg_spec & 0xffff;
> +		u16 reg_page = reg_spec >> 16;
> +		u16 val_bits = val_spec & 0xffff;
> +		u16 mask = val_spec >> 16;
> +		int val;
> +

While the outcome is the same, this code also mixes sizeof(u32) 
with __be32 pointer math.

milton
