From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH 3/3] rx_all e100 patch
Date: Tue, 25 Nov 2003 16:21:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125162152.D1107@sygehus.dk>
References: <3FC30AEE.7000005@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FC30AEE.7000005@candelatech.com>; from greearb@candelatech.com on Mon, Nov 24, 2003 at 11:55:26PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2003 at 11:55:26PM -0800, Ben Greear wrote:
> @@ -2052,13 +2065,26 @@
>  			if (bdp->rev_id >= D102_REV_ID) {
>  				skb->ip_summed = e100_D102_check_checksum(rfd);
>  			} else {
> -				skb->ip_summed = e100_D101M_checksum(bdp, skb);
> +				skb->ip_summed = e100_D101M_checksum(bdp, skb, !!(dev->priv_flags & IFF_ACCEPT_ALL_FRAMES));
>  			}

Shouldn't that be IFF_SAVE_FCS rather than IFF_ACCEPT_ALL_FRAMES?

>  		} else {
>  			skb->ip_summed = CHECKSUM_NONE;
>  		}
>  
> +		/* Show the FCS? */
> +		if (unlikely(dev->priv_flags & IFF_SAVE_FCS)) {
> +			if (bdp->rev_id < D102_REV_ID) {
> +				/* Have to over-write the two IP checksum bytes
> +				 * TODO:  Will this break vlan_hwaccel_rx???
> +				 */
> +				skb->tail[-4] = skb->tail[-2];
> +				skb->tail[-3] = skb->tail[-1];
> +				skb->tail[-2] = skb->tail[0];
> +				skb->tail[-1] = skb->tail[1];
> +			}
> +		}
> +		

I don't understand this part of the code. The 55x docs say that the IP
checksum bytes are transferred to memory _following_ the FCS.

> +/**
> + * e100_config_promisc - configure promiscuous mode
> + * @bdp: atapter's private data struct
> + * @enable: should we enable this option or not

s/atapter/adapter/g

s/etherne /ethernet /g too, somewhere, IIRC.

> +/* Only valid for 82558 and 82559.  Must be zero for 82557 */
> +#define CB_CFIG_LONG_RX_OK          BIT_3	/* OK to receive Long frames */

I find it disappointing that the good, old 82586 transfers long frames to
memory without complaint while newer chips such as the 82557 and tulip
can't/don't.

-- 
Regards,
Rask Ingemann Lambertsen
