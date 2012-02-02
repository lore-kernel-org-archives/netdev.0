From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Thu, 2 Feb 2012 16:01:47 +0200
Message-ID: <4F2A974B.209@mellanox.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>  <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>  <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>  <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>  <20120130081849.GA7848@gondor.apana.org.au>  <1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120130085742.GA8262@gondor.apana.org.au>  <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>  <20120201083837.GA7081@gondor.apana.org.au>  <CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com> <1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/1/2012 4:07 PM, Eric Dumazet wrote:
>>> If we just turn it into a memcmp with a variable length would
>>> that work for you?
>>
>> I think yes, FWIW we will compare the IPoIB header, Roland is that okay for you?
>
> A memcmp(xxx, yyy, variable_len) will be out of line and slow, its a bit sad ... Are skb_mac_header(p) / skb_gro_mac_header(skb) going to point to IPoIB header ?

yes, both skb_mac_header(p) / skb_gro_mac_header(skb) point to IPoIB 
header, however (see next)


> Maybe we can keep a fastpath for ethernet case... (the "if (hlen == ETH_HLEN) being always predicted)
> Maybe need to introduce gro_hard_header_len as well)

today, IPoIB advertizes hard_header_len which is bigger than the IPoIB 
header len, this is done such that skbs sent by the network stack have 
enough headroom for a "pseudoheader" which for few flows (e.g unicast 
arp replies and multicast) is placed there by the ipoib hard_header 
function and later used by the xmit function.

So we can either try and change that, such that hard_header_len will be 
equal to the ipoib header len or add gro_hard_header_len as you 
suggested, any preferences?

Or.

Or.




>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 115dee1..62abee4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3500,14 +3500,20 @@ static inline gro_result_t
>   __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
>   {
>   	struct sk_buff *p;
> +	unsigned int hlen = skb->dev->hard_header_len;
>
>   	for (p = napi->gro_list; p; p = p->next) {
>   		unsigned long diffs;
>
>   		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
>   		diffs |= p->vlan_tci ^ skb->vlan_tci;
> -		diffs |= compare_ether_header(skb_mac_header(p),
> -					      skb_gro_mac_header(skb));
> +		if (hlen == ETH_HLEN)
> +			diffs |= compare_ether_header(skb_mac_header(p),
> +						      skb_gro_mac_header(skb));
> +		else if (!diffs)
> +			diffs = memcmp(skb_mac_header(p),
> +					skb_gro_mac_header(skb),
> +					skb->dev->hard_header_len);
>   		NAPI_GRO_CB(p)->same_flow = !diffs;
>   		NAPI_GRO_CB(p)->flush = 0;
>   	}
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
