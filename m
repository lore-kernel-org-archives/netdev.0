From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fib_trie: /proc/net/route performance improvement
Date: Mon, 11 Feb 2008 21:14:49 -0800 (PST)
Message-ID: <20080211.211449.82800864.davem@davemloft.net>
References: <20080211171250.60ad7bc5@extreme>
	<20080211171659.28d96844@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751740AbYBLFOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:14:17 -0500
In-Reply-To: <20080211171659.28d96844@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 11 Feb 2008 17:16:59 -0800

> Use key/offset caching to change /proc/net/route (use by iputils route)
> from O(n^2) to O(n). This improves performance from 30sec with 160,000
> routes to 1sec.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.

> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 2d89527..1ff446d 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -2459,6 +2459,84 @@ static const struct file_operations fib_trie_fops = {
>  	.release = seq_release_net,
>  };
>  
> +struct fib_route_iter {
> +	struct seq_net_private p;
> +	struct trie *main_trie;
> +	loff_t	pos;
> +	t_key	key;
> +};
> +
> +static struct leaf *fib_route_get_idx(struct fib_route_iter *iter, loff_t pos)
> +{
> +	struct leaf *l = NULL;
> +	struct trie *t = iter->main_trie;
> +
> +	/* use cache location of last found key */
> +	if (iter->pos > 0 && pos >= iter->pos && (l = fib_find_node(t, iter->key)))
> +		pos -= iter->pos;
> +	else {
> +		iter->pos = 0;
> +		l = trie_firstleaf(t);
> +	}
> +
> +	while (l && pos-- > 0) {
> +		iter->pos++;
> +		l = trie_nextleaf(l);
> +	}
> +
> +	if (l)
> +		iter->key = pos;	/* remember it */
> +	else
> +		iter->pos = 0;		/* forget it */
> +
> +	return l;
> +}
> +
> +static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(RCU)
> +{
> +	struct fib_route_iter *iter = seq->private;
> +	struct fib_table *tb;
> +
> +	rcu_read_lock();
> +	tb = fib_get_table(iter->p.net, RT_TABLE_MAIN);
> +	if (!tb)
> +		return NULL;
> +
> +	iter->main_trie = (struct trie *) tb->tb_data;
> +	if (*pos == 0)
> +		return SEQ_START_TOKEN;
> +	else
> +		return fib_route_get_idx(iter, *pos - 1);
> +}
> +
> +static void *fib_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> +{
> +	struct fib_route_iter *iter = seq->private;
> +	struct leaf *l = v;
> +
> +	++*pos;
> +	if (v == SEQ_START_TOKEN) {
> +		iter->pos = 0;
> +		l = trie_firstleaf(iter->main_trie);
> +	} else {
> +		iter->pos++;
> +		l = trie_nextleaf(l);
> +	}
> +
> +	if (l)
> +		iter->key = l->key;
> +	else
> +		iter->pos = 0;
> +	return l;
> +}
> +
> +static void fib_route_seq_stop(struct seq_file *seq, void *v)
> +	__releases(RCU)
> +{
> +	rcu_read_unlock();
> +}
> +
>  static unsigned fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
>  {
>  	static unsigned type2flags[RTN_MAX + 1] = {
> @@ -2482,7 +2560,6 @@ static unsigned fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
>   */
>  static int fib_route_seq_show(struct seq_file *seq, void *v)
>  {
> -	const struct fib_trie_iter *iter = seq->private;
>  	struct leaf *l = v;
>  	struct leaf_info *li;
>  	struct hlist_node *node;
> @@ -2494,12 +2571,6 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
>  		return 0;
>  	}
>  
> -	if (iter->trie == iter->trie_local)
> -		return 0;
> -
> -	if (IS_TNODE(l))
> -		return 0;
> -
>  	hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
>  		struct fib_alias *fa;
>  		__be32 mask, prefix;
> @@ -2542,16 +2613,16 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
>  }
>  
>  static const struct seq_operations fib_route_seq_ops = {
> -	.start  = fib_trie_seq_start,
> -	.next   = fib_trie_seq_next,
> -	.stop   = fib_trie_seq_stop,
> +	.start  = fib_route_seq_start,
> +	.next   = fib_route_seq_next,
> +	.stop   = fib_route_seq_stop,
>  	.show   = fib_route_seq_show,
>  };
>  
>  static int fib_route_seq_open(struct inode *inode, struct file *file)
>  {
>  	return seq_open_net(inode, file, &fib_route_seq_ops,
> -			    sizeof(struct fib_trie_iter));
> +			    sizeof(struct fib_route_iter));
>  }
>  
>  static const struct file_operations fib_route_fops = {
> -- 
> 1.5.3.8
> 
