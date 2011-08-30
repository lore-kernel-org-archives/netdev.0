From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: netfilter: work around shared nfct struct
Date: Tue, 30 Aug 2011 14:43:08 +0200
Message-ID: <4E5CDADC.7000902@trash.net>
References: <1314701827-21702-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54593 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab1H3MnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 08:43:09 -0400
In-Reply-To: <1314701827-21702-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.08.2011 12:57, Florian Westphal wrote:
> When incoking iptables hooks from bridge netfilter, the assumption
> that non-confirmed skb->nfct is never shared does no longer hold,
> as bridge code clones skbs when e.g. forwarding packets to multiple
> bridge ports.
> 
> When NFQUEUE is used, we can BUG because nf_nat_setup_info can be
> invoked simultaneously for the same conntrack:

I'm wondering how this can happen, when flooding packets to multiple
ports, they are still processed by the same CPU one after another,
so for the second and further packets, nf_nat should notice that
the mappings are already set up.

> [ 3196.798768] kernel BUG at net/ipv4/netfilter/nf_nat_core.c:300!
> [..]
> [ 3196.798768]  [<ffffffff8120d73e>] ? nf_hook_slow+0x21a/0x282
> [ 3196.798768]  [<ffffffffa03207e4>] ? br_handle_frame_finish+0x0/0x13b [bridge]
> [ 3196.798768]  [<ffffffffa02a61a5>] ? alloc_null_binding+0x47/0x4c [iptable_nat]
> [ 3196.798768]  [<ffffffffa02a64eb>] ? nf_nat_fn+0x193/0x1fb [iptable_nat]
> [ 3196.798768]  [<ffffffff8120d4c5>] ? nf_iterate+0x40/0x9f
> [ 3196.798768]  [<ffffffff8120d73e>] ? nf_hook_slow+0x21a/0x282
> [ 3196.798768]  [<ffffffff81213c94>] ? ip_local_deliver_finish+0x0/0x1f1
> [ 3196.798768]  [<ffffffff81213c94>] ? ip_local_deliver_finish+0x0/0x1f1
> [ 3196.798768]  [<ffffffff8120d73e>] ? nf_hook_slow+0x21a/0x282
> [ 3196.798768]  [<ffffffff8121369c>] ? ip_rcv_finish+0x0/0x340
> [ 3196.798768]  [<ffffffff81213ed7>] ? ip_local_deliver+0x52/0x6c
> [ 3196.798768]  [<ffffffff812139c2>] ? ip_rcv_finish+0x326/0x340
> [ 3196.798768]  [<ffffffff81213c4f>] ? ip_rcv+0x273/0x2b8
> [ 3196.798768]  [<ffffffff811f1384>] ? process_backlog+0x8d/0xc6
> [ 3196.798768]  [<ffffffff811f2f85>] ? net_rx_action+0xa2/0x1cf
> [ 3196.798768]  [<ffffffff8103d3c2>] ? __do_softirq+0x8b/0x10b
> [ 3196.798768]  [<ffffffff8100c9dc>] ? call_softirq+0x1c/0x28
> [ 3196.798768]  [<ffffffff8100dd15>] ? do_softirq+0x31/0x66
> [ 3196.798768]  [<ffffffff8103d267>] ? irq_exit+0x36/0x78
> [ 3196.798768]  [<ffffffff8100d41a>] ? do_IRQ+0xa0/0xb6
> [ 3196.798768]  [<ffffffff8100c253>] ? ret_from_intr+0x0/0xa
> [..]
> [ 3196.798768] Code: be 2b 01 00 00 48 c7 c7 e8 cd 29 a0 e8 e8 d7 d9 e0 45 85 ff 49 8b 45 78 75 06 48 c1 e8 07 eb 04 48 c1 e8 08 83 e0 01 85 c0 74 04 <0f> 0b eb fe 49 8d 75 50 48 8d bc 24 80 00 00 00 e8 83 38 f7 ff
> [ 3196.798768] RIP  [<ffffffffa029b68f>] nf_nat_setup_info+0x8a/0x564 [nf_nat]
> [ 3196.798768]  RSP <ffff880001603bf0>
> 
> Fix this by changing ->nfct of all clones to untracked.
> 
> This should be OK, because if we do a full copy of ->nfct we'd
> end up trying to confirm the same tuples multiple times, which results in
> NF_DROP for the cloned skbs.
> 
> Also, we only need to do this if the conntrack is unconfirmed.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/bridge/br_netfilter.c |   34 ++++++++++++++++++++++++++++++++++
>  1 files changed, 34 insertions(+), 0 deletions(-)
> 
>  I have one alternate patch that changes nf_nat_setup_info
>  to detect conflicts by forcing serialization via ct->lock spinlock.
> 
>  But it is silly to do this for the sake of bridge netfilter only...
> 
>  Any other ideas?
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 3fa1231..7d47f34 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -42,6 +42,10 @@
>  #include <linux/sysctl.h>
>  #endif
>  
> +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +#include <net/netfilter/nf_conntrack.h>
> +#endif
> +
>  #define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
>  				 (skb->nf_bridge->data))->daddr.ipv4)
>  #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = ip_hdr(skb)->daddr)
> @@ -158,10 +162,40 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
>  	return skb->nf_bridge;
>  }
>  
> +
> +/* conntrack assumes exclusive ownership of skb->nfct
> + * if conntrack has not yet been confirmed.
> + *
> + * Without this, we may BUG because we might try to set up
> + * NAT bindings for the same conntrack struct simultaneously.
> + *
> + * Work around this by forcing untracked state.
> + */
> +static inline void nf_bridge_unshare_nfct(struct sk_buff *skb)
> +{
> +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +	struct nf_conn *ct, *ct_orig = (void *) skb->nfct;
> +
> +	if (!ct_orig || nf_ct_is_untracked(ct_orig))
> +		return;
> +
> +	if (likely(nf_ct_is_confirmed(ct_orig)) ||
> +	    atomic_read(&ct_orig->ct_general.use) == 1)
> +		return;
> +
> +	ct = nf_ct_untracked_get();

This will introduce a module dependency on nf_conntrack, which we really
shouldn't be doing.

> +	atomic_inc(&ct->ct_general.use);
> +	nf_conntrack_put(skb->nfct);
> +	skb->nfct = &ct->ct_general;
> +#endif
