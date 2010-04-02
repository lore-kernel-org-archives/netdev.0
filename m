From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Fri, 02 Apr 2010 11:38:23 +0100
Message-ID: <1270204703.3101.2368.camel@macbook.infradead.org>
References: <1269998334.18090.278.camel@macbook.infradead.org>
	 <1270096441.12516.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, 553024@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38990 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758426Ab0DBKi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 06:38:29 -0400
In-Reply-To: <1270096441.12516.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 05:34 +0100, Ben Hutchings wrote:
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -188,7 +188,7 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
>  	   around for long enough for the driver to get loaded. With
>  	   MDIO, the NIC driver will get bored and give up as soon
>  	   as it finds that there's no driver _already_ loaded. */
> -	sprintf(modid, "phy:" PHYID_FMT, PHYID_ARGS(phy_id));
> +	sprintf(modid, MDIO_MODULE_PREFIX MDIO_ID_FMT, MDIO_ID_ARGS(phy_id));
>  	request_module(modid);

You forgot to increase the size of the 'modid' storage there, and it
needed to grow by one character. But that's OK. I forgot that
request_module() takes printf-style arguments. So now I've killed the
temporary 'modid' buffer altogether, and I just call
request_module(MDIO_MODULE_PREFIX ...). I dropped the ifdef, too.

> -#define PHY_MODULE_PREFIX	"phy:"
> +#define MDIO_MODULE_PREFIX	"mdio:"
>  
> -#define PHYID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
> -#define PHYID_ARGS(_id) \
> +#define MDIO_ID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
> +#define MDIO_ID_ARGS(_id) \
>  	(_id)>>31, ((_id)>>30) & 1, ((_id)>>29) & 1, ((_id)>>28) & 1,	\
>  	((_id)>>27) & 1, ((_id)>>26) & 1, ((_id)>>25) & 1, ((_id)>>24) & 1, \
>  	((_id)>>23) & 1, ((_id)>>22) & 1, ((_id)>>21) & 1, ((_id)>>20) & 1, \
> @@ -487,11 +487,17 @@ struct platform_device_id {
>  	((_id)>>7) & 1, ((_id)>>6) & 1, ((_id)>>5) & 1, ((_id)>>4) & 1, \
>  	((_id)>>3) & 1, ((_id)>>2) & 1, ((_id)>>1) & 1, (_id) & 1

Still tempted to add a %b format to the kernel's printf... some runtimes
have it.

> -
> -
> -struct phy_device_id {
> -	uint32_t phy_id;
> -	uint32_t phy_id_mask;
> +/**
> + * struct mdio_device_id - identifies PHY devices on an MDIO/MII bus
> + * @phy_id: The result of
> + *     (mdio_read(&MII_PHYSID1) << 16 | mdio_read(&PHYSID2)) & @phy_id_mask
> + *     for this PHY type
> + * @phy_id_mask: Defines the significant bits of @phy_id.  A value of 0
> + *     is used to terminate an array of struct mdio_device_id.

That last sentence is a lie; I removed it. file2alias.c just ignores the
last entry in the array regardless of what it contains. I have no idea
why we use a 'terminator' in these arrays. Legacy, perhaps?

>  static int do_phy_entry(const char *filename,
> -			struct phy_device_id *id, char *alias)
> +			struct mdio_device_id *id, char *alias)

I made that 'do_mdio_entry()' for cosmetic reasons.

> -			 sizeof(struct phy_device_id), "phy",
> +			 sizeof(struct mdio_device_id), "phy",

And that "mdio", not "phy", so that it works.

-- 
dwmw2

