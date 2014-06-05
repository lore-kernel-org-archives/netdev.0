From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 1/6] net: fec: Factorize the .xmit transmit function
Date: Thu, 5 Jun 2014 09:06:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17257A93@AcuExch.aculab.com>
References: <1401951572-6538-1-git-send-email-b38611@freescale.com>
 <1401951572-6538-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"R49496@freescale.com" <R49496@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"b20596@freescale.com" <b20596@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: 'Fugang Duan' <b38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44131 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750840AbaFEJHO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 05:07:14 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21118-09 for <netdev@vger.kernel.org>;
 Thu,  5 Jun 2014 10:07:05 +0100 (BST)
In-Reply-To: <1401951572-6538-2-git-send-email-b38611@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan
> Make the code more readable and easy to support other features like
> SG, TSO, moving the common transmit function to one api.
> 
> And the patch also factorize the getting BD index to it own function.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |   87 ++++++++++++++++++-----------
>  1 files changed, 54 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 802be17..32c2276 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -287,6 +287,25 @@ struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp, struct fec_enet_priva
>  		return (new_bd < base) ? (new_bd + ring_size) : new_bd;
>  }
> 
> +static inline
> +int fec_enet_get_bd_index(struct bufdesc *bdp, struct fec_enet_private *fep)
> +{
> +	struct bufdesc *base;
> +	int index;
> +
> +	if (bdp >= fep->tx_bd_base)
> +		base = fep->tx_bd_base;
> +	else
> +		base = fep->rx_bd_base;

You really don't want the above conditional.
It is known from the call site - but the compiler can't determine that
and remove the test.
You may not want to rely on the tx and rx descriptors being allocated
as a single entity - particularly now that they (probably) consume
more than a single page.

> +
> +	if (fep->bufdesc_ex)
> +		index = (struct bufdesc_ex *)bdp - (struct bufdesc_ex *)base;
> +	else
> +		index = bdp - base;

Save the sizeof the descriptor structure as (say) fep->bufdesc_size
(Possibly replacing bufdesc_ex)
and then just calculate:
	index = ((const char *)bdp - (const char *)base)/fep->bufdesc_size;

	David
