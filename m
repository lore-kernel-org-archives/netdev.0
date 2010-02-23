From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: receive packets larger than MTU but smaller
 than 1500 bytes
Date: Tue, 23 Feb 2010 15:15:22 -0800
Message-ID: <20100223231522.GA850@xw6200.broadcom.net>
References: <ac67d9131002230356h7d293a5yba011698302f8c4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>
To: "Szilveszter Ordog" <slipszi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2139 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656Ab0BWXPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 18:15:36 -0500
In-Reply-To: <ac67d9131002230356h7d293a5yba011698302f8c4a@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This isn't such a good idea, is it?  The tg3 driver tries very hard to
configure the hardware to the requirements specified by they kernel.  If
you break that link, then you reduce the effectiveness of the hardware's
filtering based on packet size and you interfere with the hardware's
ability to tally oversized frames.

This patch also makes assumptions about how large the driver's internal
buffer sizes are.

I saw the conversation you had with Ben Hutchings and Fred Templin.
Perhaps it is better to first decide if we should decouple the tx MTU
from the rx MTU.  If everyone agrees to that, then we can work on
implementing a proper driver interface to describe our intentions.

On Tue, Feb 23, 2010 at 03:56:26AM -0800, Szilveszter Ordog wrote:
> This allows for proper ICMP needs fragmentation responses on standard Ethernet
> networks.
> 
> Signed-off-by: Szilveszter ?rd?g <slipszi@gmail.com>
> ---
>  drivers/net/tg3.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 46a3f86..0c5027b 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -93,6 +93,8 @@
>  #define TG3_MIN_MTU			60
>  #define TG3_MAX_MTU(tp)	\
>  	((tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) ? 9000 : 1500)
> +#define TG3_MAX_RX_MTU(tp) \
> +	max(tp->dev->mtu, (unsigned int)ETH_DATA_LEN)
> 
>  /* These numbers seem to be hard coded in the NIC firmware somehow.
>   * You can't change the ring sizes, but you can change where you place
> @@ -4532,7 +4534,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
> 
>  		skb->protocol = eth_type_trans(skb, tp->dev);
> 
> -		if (len > (tp->dev->mtu + ETH_HLEN) &&
> +		if (len > (TG3_MAX_RX_MTU(tp) + ETH_HLEN) &&
>  		    skb->protocol != htons(ETH_P_8021Q)) {
>  			dev_kfree_skb(skb);
>  			goto next_pkt;
> @@ -6979,7 +6981,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
> 
>  	/* MTU + ethernet header + FCS + optional VLAN tag */
>  	tw32(MAC_RX_MTU_SIZE,
> -	     tp->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
> +	     TG3_MAX_RX_MTU(tp) + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
> 
>  	/* The slot time is changed by tg3_setup_phy if we
>  	 * run at gigabit with half duplex.
> -- 
> 1.6.3.3
> 

