From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve
 fragmentation handling
Date: Fri, 17 Aug 2012 10:06:35 +0200
Message-ID: <1345190795.3069.228.camel@localhost>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
	 <1344542943-11588-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1344542943-11588-6-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-09 at 22:08 +0200, kaber@trash.net wrote:
> From: Patrick McHardy <kaber@trash.net>
> 
> The IPv6 conntrack fragmentation currently has a couple of shortcomings.
> Fragmentes are collected in PREROUTING/OUTPUT, are defragmented, the
> defragmented packet is then passed to conntrack, the resulting conntrack
> information is attached to each original fragment and the fragments then
> continue their way through the stack.
> 
> Helper invocation occurs in the POSTROUTING hook, at which point only
> the original fragments are available. The result of this is that
> fragmented packets are never passed to helpers.
> 
> This patch improves the situation in the following way:
> 
> - If a reassembled packet belongs to a connection that has a helper
>   assigned, the reassembled packet is passed through the stack instead
>   of the original fragments.

I'm working on IPv6 fragment handling for IPVS, and are taking advantage
of the "replay" by nf_ct_frag6_output() at hook prio -399
(NF_IP6_PRI_CONNTRACK_DEFRAG + 1).
By making a hook at NF_INET_PRE_ROUTING at prio -99 (NF_IP6_PRI_NAT_DST
+ 1).

I can see that the code path can be changed (with this patch), if a
helper is assigned.  Then the "replay" starts at prio -199
(NF_IP6_PRI_CONNTRACK + 1), I guess I'm safe as I run at -99.

I have tested that your patchset works, with my ipvs patches, but would
like the trigger the changed code path, to make sure.

Could you provide an iptables command/rule, that trigger this code path?


[cut]

> @@ -199,9 +200,13 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
>  static unsigned int __ipv6_conntrack_in(struct net *net,
>  					unsigned int hooknum,
>  					struct sk_buff *skb,
> +					const struct net_device *in,
> +					const struct net_device *out,
>  					int (*okfn)(struct sk_buff *))
>  {
>  	struct sk_buff *reasm = skb->nfct_reasm;
> +	struct nf_conn *ct;
> +	enum ip_conntrack_info ctinfo;
>  
>  	/* This packet is fragmented and has reassembled packet. */
>  	if (reasm) {
> @@ -213,6 +218,20 @@ static unsigned int __ipv6_conntrack_in(struct net *net,
>  			if (ret != NF_ACCEPT)
>  				return ret;
>  		}
> +
> +		/* Conntrack helpers need the entire reassembled packet in the
> +		 * POST_ROUTING hook.
> +		 */
> +		ct = nf_ct_get(reasm, &ctinfo);
> +		if (ct != NULL && test_bit(IPS_HELPER_BIT, &ct->status)) {
> +			nf_conntrack_get_reasm(skb);
> +			NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
> +				       (struct net_device *)in,
> +				       (struct net_device *)out,
> +				       okfn, NF_IP6_PRI_CONNTRACK + 1);

Hook prio change to NF_IP6_PRI_CONNTRACK + 1


> +			return NF_DROP_ERR(-ECANCELED);
> +		}

[cut]

> @@ -592,6 +599,7 @@ void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
>  			int (*okfn)(struct sk_buff *))
>  {
>  	struct sk_buff *s, *s2;
> +	unsigned int ret = 0;
>  
>  	for (s = NFCT_FRAG6_CB(skb)->orig; s;) {
>  		nf_conntrack_put_reasm(s->nfct_reasm);
> @@ -601,8 +609,13 @@ void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
>  		s2 = s->next;
>  		s->next = NULL;
>  
> -		NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, s, in, out, okfn,
> -			       NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
> +		if (ret != -ECANCELED)
> +			ret = NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, s,
> +					     in, out, okfn,
> +					     NF_IP6_PRI_CONNTRACK_DEFRAG + 1);

Old hook prio

> +		else
> +			kfree_skb(s);
> +
>  		s = s2;
>  	}
>  	nf_conntrack_put_reasm(skb);


