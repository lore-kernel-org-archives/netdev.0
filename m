From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: fix memory leak with multiple tables during
 netns destruction
Date: Fri, 08 Sep 2017 10:59:52 -0700
Message-ID: <1504893592.15310.80.camel@edumazet-glaptop3.roam.corp.google.com>
References: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32936 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754777AbdIHR7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 13:59:54 -0400
Received: by mail-pf0-f196.google.com with SMTP id h4so1752746pfk.0
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 10:59:54 -0700 (PDT)
In-Reply-To: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-08 at 10:26 +0200, Sabrina Dubroca wrote:
> fib6_net_exit only frees the main and local tables. If another table was
> created with fib6_alloc_table, we leak it when the netns is destroyed.
> 
> Fix this in the same way ip_fib_net_exit cleans up tables, by walking
> through the whole hashtable of fib6_table's. We can get rid of the
> special cases for local and main, since they're also part of the
> hashtable.
> 
> Reproducer:
>     ip netns add x
>     ip -net x -6 rule add from 6003:1::/64 table 100
>     ip netns del x
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Fixes: 58f09b78b730 ("[NETNS][IPV6] ip6_fib - make it per network namespace")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  net/ipv6/ip6_fib.c | 25 +++++++++++++++++++------
>  1 file changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index a3b5c163325f..8280172c806c 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -191,6 +191,12 @@ void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
>  }
>  EXPORT_SYMBOL_GPL(rt6_free_pcpu);
>  
> +static void fib6_free_table(struct fib6_table *table)
> +{
> +	inetpeer_invalidate_tree(&table->tb6_peers);
> +	kfree(table);
> +}
> +
>  static void fib6_link_table(struct net *net, struct fib6_table *tb)
>  {
>  	unsigned int h;
> @@ -2022,15 +2028,22 @@ static int __net_init fib6_net_init(struct net *net)
>  
>  static void fib6_net_exit(struct net *net)
>  {
> +	unsigned int i;
> +
>  	rt6_ifdown(net, NULL);
>  	del_timer_sync(&net->ipv6.ip6_fib_timer);
>  
> -#ifdef CONFIG_IPV6_MULTIPLE_TABLES
> -	inetpeer_invalidate_tree(&net->ipv6.fib6_local_tbl->tb6_peers);
> -	kfree(net->ipv6.fib6_local_tbl);
> -#endif
> -	inetpeer_invalidate_tree(&net->ipv6.fib6_main_tbl->tb6_peers);
> -	kfree(net->ipv6.fib6_main_tbl);
> +	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {

should not this be FIB6_TABLE_HASHSZ ?

> +		struct hlist_head *head = &net->ipv6.fib_table_hash[i];
> +		struct hlist_node *tmp;
> +		struct fib6_table *tb;
> +
> +		hlist_for_each_entry_safe(tb, tmp, head, tb6_hlist) {
> +			hlist_del(&tb->tb6_hlist);
> +			fib6_free_table(tb);
> +		}
> +	}
> +
>  	kfree(net->ipv6.fib_table_hash);
>  	kfree(net->ipv6.rt6_stats);
>  	fib6_notifier_exit(net);
