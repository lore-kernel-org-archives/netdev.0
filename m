From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: manual merge of the ipvs-next tree with the  tree
Date: Tue, 1 Dec 2015 20:55:44 +0100
Message-ID: <20151201195544.GA6440@salvia>
References: <20151201192609.d3b1069f650471db2bdd61f4@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Simon Horman <horms@verge.net.au>,
	Michal Kubecek <mkubecek@suse.cz>,
	Florian Westphal <fw@strlen.de>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Joe Stringer <joestringer@nicira.com>,
	David Miller <davem@davemloft.net>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151201192609.d3b1069f650471db2bdd61f4@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2015 at 07:26:09PM +0000, Mark Brown wrote:
> Hi Simon,
> 
> Today's linux-next merge of the ipvs-next tree got a conflict in
> between commit 264640fc2c5f4f ("ipv6: distinguish frag queues by
> device for multicast and link-local packets") from the net tree and
> commit 029f7f3b8701c ("netfilter: ipv6: nf_defrag: avoid/free clone
> operations") from the ipvs-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

This a clash between Florian's fragmentation work and David's net
tree: https://lkml.org/lkml/2015/11/24/732

I'll be using this here to resolve this conflict here before passing
nf-next updates to David.

Thanks.

> diff --cc net/ipv6/netfilter/nf_conntrack_reasm.c
> index bab4441ed4e4,912bc3afc183..000000000000
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@@ -582,31 -576,19 +577,21 @@@ int nf_ct_frag6_gather(struct net *net
>   	}
>   
>   	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
> - 		return skb;
> + 		return -EINVAL;
>   
> - 	clone = skb_clone(skb, GFP_ATOMIC);
> - 	if (clone == NULL) {
> - 		pr_debug("Can't clone skb\n");
> - 		return skb;
> - 	}
> - 
> - 	NFCT_FRAG6_CB(clone)->orig = skb;
> - 
> - 	if (!pskb_may_pull(clone, fhoff + sizeof(*fhdr))) {
> - 		pr_debug("message is too short.\n");
> - 		goto ret_orig;
> - 	}
> + 	if (!pskb_may_pull(skb, fhoff + sizeof(*fhdr)))
> + 		return -ENOMEM;
>   
> - 	skb_set_transport_header(clone, fhoff);
> - 	hdr = ipv6_hdr(clone);
> - 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
> + 	skb_set_transport_header(skb, fhoff);
> + 	hdr = ipv6_hdr(skb);
> + 	fhdr = (struct frag_hdr *)skb_transport_header(skb);
>   
>   	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
>  -		     ip6_frag_ecn(hdr));
>  -	if (fq == NULL)
>  +		     skb->dev ? skb->dev->ifindex : 0, ip6_frag_ecn(hdr));
>  +	if (fq == NULL) {
>  +		pr_debug("Can't find and can't create new queue\n");
> - 		goto ret_orig;
> + 		return -ENOMEM;
>  +	}
>   
>   	spin_lock_bh(&fq->q.lock);
>   
