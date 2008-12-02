From: David Brownell <david-b@pacbell.net>
Subject: Re: [spi-devel-general] [PATCH] enc28j60: Fix sporadic packet loss (correction)
Date: Tue, 2 Dec 2008 13:05:05 -0800
Message-ID: <200812021305.06083.david-b@pacbell.net>
References: <20081202085947.GB24490@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: spi-devel-general@lists.sourceforge.net,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	Shachar Shemesh <shachar@lingnu.com>,
	Network development list <netdev@vger.kernel.org>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:44125 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751217AbYLBVFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 16:05:08 -0500
In-Reply-To: <20081202085947.GB24490@diamond.tkos.co.il>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 December 2008, Baruch Siach wrote:
> Packet data read from the RX buffer the when the RSV is at the end of the RX 
> buffer does not warp around. This causes packet loss, as the actual data is 
> never read. Fix this by calculating the right packet data location.
> 
> Thanks to Shachar Shemesh for suggesting the fix.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> 
> ---

Seems plausible to me, but network patches should be submitted
to the netdev list.  :)

I CC'd them on this reply ... if nobody gives any feedback, I'll
suggest you resubmit there on Friday.

- Dave

p.s. Just for info ... what kind of Linux system are you using
   this driver on?

> 
> --- drivers/net/enc28j60.c-git	2008-12-02 09:08:24.000000000 +0200
> +++ drivers/net/enc28j60.c	2008-12-02 09:38:33.000000000 +0200
> @@ -568,6 +568,17 @@ static u16 erxrdpt_workaround(u16 next_p
>  	return erxrdpt;
>  }
>  
> +/*
> + * Calculate wrap around when reading beyond the end of the RX buffer
> + */
> +static u16 rx_packet_start(u16 ptr)
> +{
> +	if (ptr + RSV_SIZE > RXEND_INIT)
> +		return (ptr + RSV_SIZE) - RXEND_INIT - 1;
> +	else
> +		return ptr + RSV_SIZE;
> +}
> +
>  static void nolock_rxfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
>  {
>  	u16 erxrdpt;
> @@ -938,8 +949,9 @@ static void enc28j60_hw_rx(struct net_de
>  			skb->dev = ndev;
>  			skb_reserve(skb, NET_IP_ALIGN);
>  			/* copy the packet from the receive buffer */
> -			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
> -					len, skb_put(skb, len));
> +			enc28j60_mem_read(priv,
> +				rx_packet_start(priv->next_pk_ptr),
> +				len, skb_put(skb, len));
>  			if (netif_msg_pktdata(priv))
>  				dump_packet(__func__, skb->len, skb->data);
>  			skb->protocol = eth_type_trans(skb, ndev);
> 
> -- 
>                                                      ~. .~   Tk Open Systems
> =}------------------------------------------------ooO--U--Ooo------------{=
>    - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
> 
>
