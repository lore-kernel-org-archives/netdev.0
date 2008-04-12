From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Add Fixed PHY support for ucc_geth
Date: Sat, 12 Apr 2008 01:53:59 -0400
Message-ID: <48004E77.3030807@garzik.org>
References: <>	 <1205833615-15833-1-git-send-email-Joakim.Tjernlund@transmode.se>	 <989B956029373F45A0B8AF029708189001D1954D@zch01exm26.fsl.freescale.net>	 <1207138552.9675.61.camel@gentoo-jocke.transmode.se> <1207868083.9544.10.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47647 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610AbYDLFyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 01:54:05 -0400
In-Reply-To: <1207868083.9544.10.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> On Wed, 2008-04-02 at 14:15 +0200, Joakim Tjernlund wrote:
>> On Fri, 2008-03-21 at 16:51 +0800, Li Yang wrote:
>>>> -----Original Message-----
>>>> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
>>>> Sent: Tuesday, March 18, 2008 5:47 PM
>>>> To: Netdev; Li Yang; Linuxppc-Embedded@Ozlabs.Org
>>>> Cc: Joakim Tjernlund
>>>> Subject: [PATCH] Add Fixed PHY support for ucc_geth
>>>>
>>>> The new Fixed PHY method, fixed-link property, isn't
>>>> impl. for ucc_geth which makes fixed PHYs non functional.
>>>> Add support for the new method to restore the Fixed PHY
>>>> functionality.
>>>>
>>>> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>>> Signed-off-by: Li Yang <leoli@freescale.com>
>>>
>>> ---
>>> Ps: This patch depends on the patch "ucc_geth: use correct thread number
>>> for 10/100Mbps link" to apply, which hasn't made to Linus' tree for now
>>> but has already been in Jeff and David's trees.
>> What happened to this patch? It is not in Linus tree.
>>
>>  Jocke
> 
> David,
> 
> Perhaps you can look into this patch? It has been signedoffed by its
> maintainer and Jeff hasn't commented or applied it.
> 
>  Jocke
> 
>>From 9851f2cffb2eaa3f3dfa02c07d01a93b1a260d78 Mon Sep 17 00:00:00 2001
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Tue, 18 Mar 2008 10:33:43 +0100
> Subject: [PATCH] Add Fixed PHY support for ucc_geth
> 
> The new Fixed PHY method, fixed-link property, isn't
> impl. for ucc_geth which makes fixed PHYs non functional.
> Add support for the new method to restore the Fixed PHY
> functionality.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> This is a regression as fixed PHYs works in 2.6.23 and I am
> using it.
> 
>  drivers/net/ucc_geth.c |   53 +++++++++++++++++++++++++++--------------------
>  1 files changed, 30 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index ecc5712..18c8b39 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3836,6 +3836,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
>  	struct device_node *phy;
>  	int err, ucc_num, max_speed = 0;
>  	const phandle *ph;
> +	const u32 *fixed_link;
>  	const unsigned int *prop;
>  	const char *sprop;
>  	const void *mac_addr;
> @@ -3926,18 +3927,38 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
>  
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
> @@ -3982,20 +4003,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
>  		ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
>  	}
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

applied


