From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCH] Add Fixed PHY support for ucc_geth
Date: Tue, 18 Mar 2008 19:32:42 +0300
Message-ID: <20080318193242.27926a9e@kernel.crashing.org>
References: <1205833615-15833-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tjernlund <Joakim.Tjernlund@transmode.se>, Joakim@ozlabs.org,
	Netdev <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	"Linuxppc-Embedded@Ozlabs.Org" <linuxppc-embedded@ozlabs.org>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <1205833615-15833-1-git-send-email-Joakim.Tjernlund@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Mar 2008 10:46:55 +0100
Joakim Tjernlund wrote:

> The new Fixed PHY method, fixed-link property, isn't
> impl. for ucc_geth which makes fixed PHYs non functional.
> Add support for the new method to restore the Fixed PHY
> functionality.
> 
Makes sense to me, but let's cc linuxppc-devel

> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Acked-by: Vitaly Bordug <vitb@kernel.crashing.org>

> ---
> 
> This is a regression as fixed PHYs works in 2.6.23 and I am
> using it.
> 
>  drivers/net/ucc_geth.c |   53
> +++++++++++++++++++++++++++-------------------- 1 files changed, 30
> insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index ecc5712..18c8b39 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3836,6 +3836,7 @@ static int ucc_geth_probe(struct of_device*
> ofdev, const struct of_device_id *ma struct device_node *phy;
>  	int err, ucc_num, max_speed = 0;
>  	const phandle *ph;
> +	const u32 *fixed_link;
>  	const unsigned int *prop;
>  	const char *sprop;
>  	const void *mac_addr;
> @@ -3926,18 +3927,38 @@ static int ucc_geth_probe(struct of_device*
> ofdev, const struct of_device_id *ma 
>  	ug_info->uf_info.regs = res.start;
>  	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
> +	fixed_link = of_get_property(np, "fixed-link", NULL);
> +	if (fixed_link) {
> +		ug_info->mdio_bus = 0;
> +		ug_info->phy_address = fixed_link[0];
> +		phy = NULL;
> +	} else {
> +		ph = of_get_property(np, "phy-handle", NULL);
> +		phy = of_find_node_by_phandle(*ph);
>  
> -	ph = of_get_property(np, "phy-handle", NULL);
> -	phy = of_find_node_by_phandle(*ph);
> +		if (phy == NULL)
> +			return -ENODEV;
>  
> -	if (phy == NULL)
> -		return -ENODEV;
> +		/* set the PHY address */
> +		prop = of_get_property(phy, "reg", NULL);
> +		if (prop == NULL)
> +			return -1;
> +		ug_info->phy_address = *prop;
> +
> +		/* Set the bus id */
> +		mdio = of_get_parent(phy);
> +
> +		if (mdio == NULL)
> +			return -1;
>  
> -	/* set the PHY address */
> -	prop = of_get_property(phy, "reg", NULL);
> -	if (prop == NULL)
> -		return -1;
> -	ug_info->phy_address = *prop;
> +		err = of_address_to_resource(mdio, 0, &res);
> +		of_node_put(mdio);
> +
> +		if (err)
> +			return -1;
> +
> +		ug_info->mdio_bus = res.start;
> +	}
>  
>  	/* get the phy interface type, or default to MII */
>  	prop = of_get_property(np, "phy-connection-type", NULL);
> @@ -3982,20 +4003,6 @@ static int ucc_geth_probe(struct of_device*
> ofdev, const struct of_device_id *ma ug_info->numThreadsRx =
> UCC_GETH_NUM_OF_THREADS_4; }
>  
> -	/* Set the bus id */
> -	mdio = of_get_parent(phy);
> -
> -	if (mdio == NULL)
> -		return -1;
> -
> -	err = of_address_to_resource(mdio, 0, &res);
> -	of_node_put(mdio);
> -
> -	if (err)
> -		return -1;
> -
> -	ug_info->mdio_bus = res.start;
> -
>  	if (netif_msg_probe(&debug))
>  		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq =
> %d) \n", ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
