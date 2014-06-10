From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] tcp: set skb checksum unnecessary and encapsulation
 in TCP GRO
Date: Mon, 09 Jun 2014 23:51:11 -0700
Message-ID: <1402383071.3645.397.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406092324450.8959@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:37093 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbaFJGvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 02:51:13 -0400
Received: by mail-pb0-f50.google.com with SMTP id rp16so482979pbb.23
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 23:51:12 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406092324450.8959@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 23:35 -0700, Tom Herbert wrote:
> Once checksum has been validated in TCP RO we can assume all
> preceeding checksums have been properly validated so ip_summed can
> changed to unnecessary. Also, if UDP encapsulation was encountered
> we set skb->encapsulation to indicated encapsulated checksums are
> verified.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h | 5 ++++-
>  net/ipv4/tcp_offload.c    | 4 ++++
>  net/ipv4/udp_offload.c    | 2 ++
>  3 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 774e539..d39221f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1760,7 +1760,10 @@ struct napi_gro_cb {
>  	u16	proto;
>  
>  	/* Used in udp_gro_receive */
> -	u16	udp_mark;
> +	u8	udp_mark;
> +
> +	/* Crossed encpsulation boundary */
> +	u8	encapsulation;
>  
>  	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
>  	__wsum	csum;
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 4e86c59..f40eb4c 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -290,7 +290,11 @@ static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *
>  	case CHECKSUM_COMPLETE:
>  		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
>  				  wsum)) {
> +			/* Assume all previous checksums have succeeded
> +			 * so we can convert to CHECKSUM_UNNECESSARY now.
> +			 */
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
> +			skb->encapsulation = NAPI_GRO_CB(skb)->encapsulation;
>  			break;
>  		}
>  
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 546d2d4..56749a2 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -167,6 +167,8 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
>  	/* mark that this skb passed once through the udp gro layer */
>  	NAPI_GRO_CB(skb)->udp_mark = 1;
>  
> +	NAPI_GRO_CB(skb)->encapsulation = 1;
> +
>  	off  = skb_gro_offset(skb);
>  	hlen = off + sizeof(*uh);
>  	uh   = skb_gro_header_fast(skb, off);


You need to clear this encapsulation field in dev_gro_receive(),
otherwise its content can be random.
