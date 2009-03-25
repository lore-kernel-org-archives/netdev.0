From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 19:05:09 +0100
Message-ID: <49CA7255.20807@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36205 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840AbZCYSFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 14:05:18 -0400
In-Reply-To: <49CA6F9A.9010806@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Hi Patrick
> 
> Here is the patch I had the time to test this time...
> No problem so far on my machine.
> I did a UDP flood stress.

Thanks Eric. Most parts looks good, just two questions below:

> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> index 6ba5c55..fcbcf62 100644
> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> @@ -25,30 +25,30 @@ struct ct_iter_state {
>  	unsigned int bucket;
>  };
>  
> -static struct hlist_node *ct_get_first(struct seq_file *seq)
> +static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
>  {
>  	struct net *net = seq_file_net(seq);
>  	struct ct_iter_state *st = seq->private;
> -	struct hlist_node *n;
> +	struct hlist_nulls_node *n;
>  
>  	for (st->bucket = 0;
>  	     st->bucket < nf_conntrack_htable_size;
>  	     st->bucket++) {
>  		n = rcu_dereference(net->ct.hash[st->bucket].first);
> -		if (n)
> +		if (!is_a_nulls(n))
>  			return n;
>  	}
>  	return NULL;
>  }

Don't we need to make sure the entry is not reused while dumping
it?

> diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
> index a51bdac..6066144 100644
> --- a/net/netfilter/nf_conntrack_helper.c
> +++ b/net/netfilter/nf_conntrack_helper.c
> @@ -158,6 +158,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
>  	struct nf_conntrack_tuple_hash *h;
>  	struct nf_conntrack_expect *exp;
>  	const struct hlist_node *n, *next;
> +	const struct hlist_nulls_node *nn;
>  	unsigned int i;
>  
>  	/* Get rid of expectations */
> @@ -174,10 +175,10 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
>  	}
>  
>  	/* Get rid of expecteds, set helpers to NULL. */
> -	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode)
> +	hlist_for_each_entry(h, nn, &net->ct.unconfirmed, hnnode)
>  		unhelp(h, me);
>  	for (i = 0; i < nf_conntrack_htable_size; i++) {
> -		hlist_for_each_entry(h, n, &net->ct.hash[i], hnode)
> +		hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
>  			unhelp(h, me);
>  	}
>  }
> @@ -217,7 +218,7 @@ int nf_conntrack_helper_init(void)
>  
>  	nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
>  	nf_ct_helper_hash = nf_ct_alloc_hashtable(&nf_ct_helper_hsize,
> -						  &nf_ct_helper_vmalloc);
> +						  &nf_ct_helper_vmalloc, 0);

This should be "1" I think since it wants a hlist_nulls hash.
