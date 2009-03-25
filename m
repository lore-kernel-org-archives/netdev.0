From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 20:00:21 +0100
Message-ID: <49CA7F45.5020800@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net> <49CA74CA.1040603@cosmosbay.com> <49CA76C4.2090409@trash.net> <49CA7DAF.9070207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37425 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbZCYTAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 15:00:35 -0400
In-Reply-To: <49CA7DAF.9070207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Here is take 2 of the patch with proper ref counting on dumping.

Thanks, one final question about the seq-file handling:

> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
> index 6ba5c55..0b870b9 100644
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
>  
> -static struct hlist_node *ct_get_next(struct seq_file *seq,
> -				      struct hlist_node *head)
> +static struct hlist_nulls_node *ct_get_next(struct seq_file *seq,
> +				      struct hlist_nulls_node *head)
>  {
>  	struct net *net = seq_file_net(seq);
>  	struct ct_iter_state *st = seq->private;
>  
>  	head = rcu_dereference(head->next);
> -	while (head == NULL) {
> +	while (is_a_nulls(head)) {
>  		if (++st->bucket >= nf_conntrack_htable_size)
>  			return NULL;
>  		head = rcu_dereference(net->ct.hash[st->bucket].first);
> @@ -56,9 +56,9 @@ static struct hlist_node *ct_get_next(struct seq_file *seq,
>  	return head;
>  }
>  
> -static struct hlist_node *ct_get_idx(struct seq_file *seq, loff_t pos)
> +static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_t pos)
>  {
> -	struct hlist_node *head = ct_get_first(seq);
> +	struct hlist_nulls_node *head = ct_get_first(seq);
>  
>  	if (head)
>  		while (pos && (head = ct_get_next(seq, head)))
> @@ -87,69 +87,76 @@ static void ct_seq_stop(struct seq_file *s, void *v)
>  
>  static int ct_seq_show(struct seq_file *s, void *v)
>  {
> -	const struct nf_conntrack_tuple_hash *hash = v;
> -	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
> +	struct nf_conntrack_tuple_hash *hash = v;
> +	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(hash);
>  	const struct nf_conntrack_l3proto *l3proto;
>  	const struct nf_conntrack_l4proto *l4proto;
> +	int ret = 0;
>  
>  	NF_CT_ASSERT(ct);
> +	if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
> +		return 0;

Can we assume the next pointer still points to the next entry
in the same chain after the refcount dropped to zero?


