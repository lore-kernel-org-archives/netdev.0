From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 18:55:22 +0800
Message-ID: <20080731105522.GB7601@gondor.apana.org.au>
References: <20080730235004.GC21999@xi.wantstofly.org> <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org> <20080730.181047.39922732.davem@davemloft.net> <20080731014506.GA23402@xi.wantstofly.org> <20080731035410.GA4893@gondor.apana.org.au> <20080731094536.GC23814@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58391 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751214AbYGaKze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:55:34 -0400
Content-Disposition: inline
In-Reply-To: <20080731094536.GC23814@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 11:45:36AM +0200, Lennert Buytenhek wrote:
>
> From: Lennert Buytenhek <buytenh@wantstofly.org>
> Subject: [NET] use software GSO for SG+CSUM capable netdevices
> 
> If a netdevice does not support hardware GSO, allowing the stack to
> use GSO anyway and then splitting the GSO skb into MSS-sized pieces
> as it is handed to the netdevice for transmitting is likely still
> a win at least as far as CPU usage is concerned, since it reduces
> the number of trips through the output path.
> 
> This patch enables the use of GSO on any netdevice that supports SG
> and hardware checksumming.  If a GSO skb is then sent to a netdevice
> that supports SG and checksumming but does not support hardware GSO,
> net/core/dev.c:dev_hard_start_xmit() will take care of doing the
> necessary GSO segmentation in software.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> Index: linux-2.6.27-rc1/include/net/sock.h
> ===================================================================
> --- linux-2.6.27-rc1.orig/include/net/sock.h
> +++ linux-2.6.27-rc1/include/net/sock.h
> @@ -1085,7 +1085,12 @@ extern struct dst_entry *sk_dst_check(st
>  
>  static inline int sk_can_gso(const struct sock *sk)
>  {
> -	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
> +	int caps = sk->sk_route_caps;
> +	int type = sk->sk_gso_type;
> +
> +	return (caps & NETIF_F_SG) &&
> +		 ((type == SKB_GSO_TCPV4 && (caps & NETIF_F_V4_CSUM)) ||
> +		  (type == SKB_GSO_TCPV6 && (caps & NETIF_F_V6_CSUM)));

I think you've lost the hardware UFO support.

In any case, this is really the wrong place to do this as the
user will no longer be able to disable it.

Please do it in the netdev registration function instead.  The code
should enable NETIF_F_GSO if NETIF_F_SG is on.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
