From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] net/fec: "u32" is more explicit than "unsigned long"
Date: Fri, 23 Aug 2013 13:44:29 +0100
Message-ID: <1377261869.3364.3.camel@bwh-desktop.uk.level5networks.com>
References: <20130823094920.GP31293@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Fabio Estevam" <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6773 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435Ab3HWMoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 08:44:38 -0400
In-Reply-To: <20130823094920.GP31293@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 12:49 +0300, Dan Carpenter wrote:
> tmpaddr[] is a six byte array.  We want to set the first four bytes on
> the first line and the remaining two on the next line.  The code assumes
> that "unsigned long" is 32 bits and obviously that's not true on 64 bit
> arches.  It's better to just use u32 instead.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This is a static checker thing and I can't compile this file.
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index fdf9307..422b125 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1100,9 +1100,9 @@ static void fec_get_mac(struct net_device *ndev)
>  	 * 4) FEC mac registers set by bootloader
>  	 */
>  	if (!is_valid_ether_addr(iap)) {
> -		*((unsigned long *) &tmpaddr[0]) =
> +		*((u32 *) &tmpaddr[0]) =
>  			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
> -		*((unsigned short *) &tmpaddr[4]) =
> +		*((u16 *) &tmpaddr[4]) =
>  			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
>  		iap = &tmpaddr[0];
>  	}

This code also seems to have CPU vs big-endian byte order the wrong way
round.  readl() returns bytes in native order whereas we always store
MAC addresses in network (big-endian) order.  So I think it should be
doing:

		*((__be32 *) &tmpaddr[0]) =
			cpu_to_be32(readl(fep->hwp + FEC_ADDR_LOW));
		*((__be16 *) &tmpaddr[4]) =
			cpu_to_be16(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
