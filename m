From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] udp: move logic out of
 udp[46]_ufo_send_check
Date: Sat, 20 Sep 2014 18:12:34 -0700
Message-ID: <1411261954.26859.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
	 <1411249950-6795-3-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33948 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIUBMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:12:35 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so2186370pde.0
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:12:35 -0700 (PDT)
In-Reply-To: <1411249950-6795-3-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 14:52 -0700, Tom Herbert wrote:
> In udp[46]_ufo_send_check the UDP checksum initialized to the pseudo
> header checksum. We can move this logic into udp[46]_ufo_fragment.
> After this change udp[64]_ufo_send_check is a no-op.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/udp_offload.c | 37 +++++++++++++++----------------------
>  net/ipv6/udp_offload.c | 40 ++++++++++++++++++----------------------
>  2 files changed, 33 insertions(+), 44 deletions(-)
> 
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index d7c43f7..2918cc9 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -27,23 +27,6 @@ struct udp_offload_priv {
>  
>  static int udp4_ufo_send_check(struct sk_buff *skb)
>  {
> -	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
> -		return -EINVAL;
> -
> -	if (likely(!skb->encapsulation)) {
> -		const struct iphdr *iph;
> -		struct udphdr *uh;
> -
> -		iph = ip_hdr(skb);
> -		uh = udp_hdr(skb);
> -
> -		uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
> -				IPPROTO_UDP, 0);
> -		skb->csum_start = skb_transport_header(skb) - skb->head;
> -		skb->csum_offset = offsetof(struct udphdr, check);
> -		skb->ip_summed = CHECKSUM_PARTIAL;
> -	}
> -
>  	return 0;
>  }
>  
> @@ -128,8 +111,9 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>  {
>  	struct sk_buff *segs = ERR_PTR(-EINVAL);
>  	unsigned int mss;
> -	int offset;
>  	__wsum csum;
> +	struct udphdr *uh;
> +	struct iphdr *iph;
>  
>  	if (skb->encapsulation &&
>  	    (skb_shinfo(skb)->gso_type &
> @@ -138,6 +122,9 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>  		goto out;
>  	}
>  
> +	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
> +		goto out;
> +
>  	mss = skb_shinfo(skb)->gso_size;
>  	if (unlikely(skb->len <= mss))
>  		goto out;
> @@ -165,10 +152,16 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>  	 * HW cannot do checksum of UDP packets sent as multiple
>  	 * IP fragments.
>  	 */
> -	offset = skb_checksum_start_offset(skb);
> -	csum = skb_checksum(skb, offset, skb->len - offset, 0);
> -	offset += skb->csum_offset;
> -	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
> +
> +	uh = udp_hdr(skb);
> +	iph = ip_hdr(skb);
> +
> +	uh->check = 0;
> +	csum = skb_checksum(skb, 0, skb->len, 0);
> +	uh->check = udp_v4_check(skb->len, iph->saddr, iph->daddr, csum);
> +	if (uh->check == 0)
> +		uh->check = CSUM_MANGLED_0;
> +
>  	skb->ip_summed = CHECKSUM_NONE;


Shouldn't it be changed to CHECKSUM_PARTIAL or something ?

udp4_ufo_send_check() was able to fill CHECKSUM_PARTIAL,
I fear I do not understand enough this part.
