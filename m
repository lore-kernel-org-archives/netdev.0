From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC] net: skb_head_is_locked() should use skb_header_cloned()
Date: Tue, 22 May 2012 10:23:42 -0700
Message-ID: <4FBBCB9E.8020409@intel.com>
References: <1337432555.7029.196.camel@edumazet-glaptop>  <20120519.183556.1085711138074171029.davem@davemloft.net>  <1337578663.3361.10.camel@edumazet-glaptop> <1337666034.3361.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13622 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab2EVRXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 13:23:43 -0400
In-Reply-To: <1337666034.3361.50.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/2012 10:53 PM, Eric Dumazet wrote:
> Hi David and Alexander
>
> There is no hurry since net-next is closed, but I hit the following
> problem :
>
> When IPv6 conntracking is enabled, code from
> net/ipv6/netfilter/nf_conntrack_reasm.c does a cloning of all skbs to
> build a shadow.
>
> Then we run : (skb here is the head of the 'shadow skb' )
>
> void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
>                         struct net_device *in, struct net_device *out,
>                         int (*okfn)(struct sk_buff *))
> {
>         struct sk_buff *s, *s2;
>
>         for (s = NFCT_FRAG6_CB(skb)->orig; s;) {
>                 nf_conntrack_put_reasm(s->nfct_reasm);
>                 nf_conntrack_get_reasm(skb);
>                 s->nfct_reasm = skb;
>
>                 s2 = s->next;
>                 s->next = NULL;
>
>                 NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, s, in, out, okfn,
>                                NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
>                 s = s2;
>         }
>         nf_conntrack_put_reasm(skb);
> }
>
> So when all original skbs are fed to real IPv6 reassembly code, their
> clones are still alive and we hit the condition in skb_try_coalesce() :
>
> if (skb_head_is_locked(from))
> 	return false;
>
> I was wondering if skb_head_is_locked() should be changed to :
>
> if (!skb->head_frag || skb_header_cloned(skb))
> 	return false;
>
> Then we could add skb_header_release() calls on the clones of course in
> net/ipv6/netfilter/nf_conntrack_reasm.c 
>
> Not-Yet-Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/skbuff.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0e50171..6509ee1 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2587,7 +2587,7 @@ static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
>   */
>  static inline bool skb_head_is_locked(const struct sk_buff *skb)
>  {
> -	return !skb->head_frag || skb_cloned(skb);
> +	return !skb->head_frag || skb_header_cloned(skb);
>  }
>  #endif	/* __KERNEL__ */
>  #endif	/* _LINUX_SKBUFF_H */
>
>
The problem is that the whole reason for checking skb_cloned was to
avoid reference count issues between the skb and the page.  We should
only be using the reference count in one or the other and not both. 
Otherwise we open up the possibility of a data corruption if someone
misinterprets a skb_shinfo()->dataref == 1, or skb_header_cloned
returning false when we have the buffer shared between both the sk_buff
and a page.

The skb_header_cloned check only verifies that the portion between
skb->head and skb->data is currently being unused by the other clones. 
It doesn't guarantee that skb->head is not being used by any other
sk_buff.  As such we run the same risk of messing up the dataref
counting if we were to use it.

The way I see it there are 2 solutions.  The first would be to just
split the reference counts and make it so that calls like skb_cloned
have to check both dataref and page count if skb->head_frag is set.  The
second option would be to look at something like pskb_expand_head where
we could generate a new head fragment and then memcpy the data over to
that frag in order to "unlock" the head.

Thanks,

Alex
