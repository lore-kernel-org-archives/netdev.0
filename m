From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC net-next] net: xfrm: support setting an output mark.
Date: Mon, 7 Aug 2017 13:16:23 +0200
Message-ID: <20170807111623.GQ2631@secunet.com>
References: <20170807092326.10239-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <jhs@mojatatu.com>, <herbert@gondor.apana.org.au>,
        <nharold@google.com>, <misterikkit@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41062 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752786AbdHGLQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 07:16:27 -0400
Content-Disposition: inline
In-Reply-To: <20170807092326.10239-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 07, 2017 at 06:23:26PM +0900, Lorenzo Colitti wrote:
> On systems that use mark-based routing it may be necessary for
> routing lookups to use marks in order for packets to be routed
> correctly. An example of such a system is Android, which uses
> socket marks to route packets via different networks.
> 
> Currently, routing lookups in tunnel mode always use a mark of
> zero, making routing incorrect on such systems. This patch adds
> a new output_mark parameter to the SA properties.  The mark will
> be used in routing lookups, and if nonzero, will also set the
> mark of the packets emitted by the SA, so it can be matched by
> iptables.
> 
> Tested: https://android-review.googlesource.com/452776
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  include/net/xfrm.h        |  9 ++++++---
>  include/uapi/linux/xfrm.h |  1 +
>  net/ipv4/xfrm4_policy.c   | 14 +++++++++-----
>  net/ipv6/xfrm6_policy.c   |  9 ++++++---
>  net/xfrm/xfrm_output.c    |  3 +++
>  net/xfrm/xfrm_policy.c    | 17 +++++++++--------
>  net/xfrm/xfrm_user.c      | 11 +++++++++++
>  7 files changed, 45 insertions(+), 19 deletions(-)
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index afb4929d72..6b1ddb790d 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -163,6 +163,7 @@ struct xfrm_state {
>  		int		header_len;
>  		int		trailer_len;
>  		u32		extra_flags;
> +		u32		output_mark;
>  	} props;
>  
>  	struct xfrm_lifetime_cfg lft;
> @@ -296,10 +297,12 @@ struct xfrm_policy_afinfo {
>  	struct dst_entry	*(*dst_lookup)(struct net *net,
>  					       int tos, int oif,
>  					       const xfrm_address_t *saddr,
> -					       const xfrm_address_t *daddr);
> +					       const xfrm_address_t *daddr,
> +					       u32 mark);
>  	int			(*get_saddr)(struct net *net, int oif,
>  					     xfrm_address_t *saddr,
> -					     xfrm_address_t *daddr);
> +					     xfrm_address_t *daddr,
> +					     u32 mark);
>  	void			(*decode_session)(struct sk_buff *skb,
>  						  struct flowi *fl,
>  						  int reverse);
> @@ -1638,7 +1641,7 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
>  struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
>  				    const xfrm_address_t *saddr,
>  				    const xfrm_address_t *daddr,
> -				    int family);
> +				    int family, u32 mark);
>  
>  struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
>  
> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
> index 2b384ff09f..5fe7370a2b 100644
> --- a/include/uapi/linux/xfrm.h
> +++ b/include/uapi/linux/xfrm.h
> @@ -304,6 +304,7 @@ enum xfrm_attr_type_t {
>  	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
>  	XFRMA_PAD,
>  	XFRMA_OFFLOAD_DEV,	/* struct xfrm_state_offload */
> +	XFRMA_OUTPUT_MARK,	/* __u32 */
>  	__XFRMA_MAX

Hm, why don't you use the existing xfrm_mark for this?
Having two different marks on one SA seems to be a bit odd.
