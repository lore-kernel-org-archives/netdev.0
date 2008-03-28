From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/3] [LLC]: skb allocation size for responses
Date: Fri, 28 Mar 2008 10:12:02 -0300
Message-ID: <20080328131202.GP14945@ghostprotocols.net>
References: <1206691159-10872-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbYC1NMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 09:12:09 -0400
Content-Disposition: inline
In-Reply-To: <1206691159-10872-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 28, 2008 at 04:59:19PM +0900, Joonwoo Park escreveu:
> allocate the skb for llc responses with the received packet size by
> using the size adjustable llc_frame_alloc.
> don't allocate useless extra payload.
> cleanup magic numbers
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

<SNIP>

> diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
> index 2525165..46447e7 100644
> --- a/net/llc/llc_sap.c
> +++ b/net/llc/llc_sap.c
> @@ -24,20 +24,52 @@
>  #include <net/tcp_states.h>
>  #include <linux/llc.h>
>  
> +#ifdef CONFIG_TR
> +static inline int __llc_tr_mac_header_len(unsigned short devtype)
> +{
> +	if (devtype == ARPHDR_IEEE802_TR)
> +		return sizeof(struct thr_hdr);
> +	return 0;
> +}
> +#else
> +static inline int __llc_tr_mac_header_len(unsigned short devtype)
> +{
> +	return 0;
> +}
> +#endif

Why not just:

static inline int __llc_tr_mac_header_len(unsigned short devtype)
{
#ifdef CONFIG_TR
	if (devtype == ARPHDR_IEEE802_TR)
		return sizeof(struct thr_hdr);
#endif
	return 0;
}

?

> +static int llc_mac_header_len(unsigned short devtype)
> +{
> +	switch (devtype) {
> +	case ARPHRD_ETHER:
> +	case ARPHRD_LOOPBACK:
> +		return sizeof(struct ethhdr);
> +	}
> +
> +	return __llc_tr_mac_header_len(devtype);
> +}

Nah, just drop __llc_tr_mac_header_len altogether and have another case
entry for ARPHDR_IEEE802_TR.

>  /**
>   *	llc_alloc_frame - allocates sk_buff for frame
>   *	@dev: network device this skb will be sent over
> + *	@type: pdu type to allocate
> + *	@data_size: data size to allocate
>   *
>   *	Allocates an sk_buff for frame and initializes sk_buff fields.
>   *	Returns allocated skb or %NULL when out of memory.
>   */
> -struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev)
> +struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
> +				u8 type, u32 data_size)
>  {
> -	struct sk_buff *skb = alloc_skb(128, GFP_ATOMIC);
> +	int hlen = type == LLC_PDU_TYPE_U ? 3 : 4;
> +	struct sk_buff *skb;
> +
> +	hlen += llc_mac_header_len(dev->type);
> +	skb = alloc_skb(hlen + data_size, GFP_ATOMIC);
>  
>  	if (skb) {
>  		skb_reset_mac_header(skb);
> -		skb_reserve(skb, 50);
> +		skb_reserve(skb, hlen);

Well done, now it is better documented (LLC_PDU_TYPE_U passed) and uses
less memory, no more magic numbers, good.

- Arnaldo
