From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Sun, 24 Sep 2017 19:57:41 -0600
Message-ID: <b175f7ab-12b6-061a-4233-ba53641ef99b@gmail.com>
References: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37770 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752872AbdIYB5o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 21:57:44 -0400
Received: by mail-pf0-f196.google.com with SMTP id e69so2990260pfg.4
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 18:57:44 -0700 (PDT)
In-Reply-To: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/17 12:07 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While running TCP tests involving netem storing millions of packets,
> I had the idea to speed up tfifo_reset() and did experiments.
> 
> I tried the rbtree_postorder_for_each_entry_safe() method that is
> used in skb_rbtree_purge() but discovered it was slower than the
> current tfifo_reset() method.
> 
> I measured time taken to release skbs with three occupation levels :
> 10^4, 10^5 and 10^6 skbs with three methods :
> 
> 1) (current 'naive' method)
> 
> 	while ((p = rb_first(&q->t_root))) {
> 		struct sk_buff *skb = netem_rb_to_skb(p);
>  
> 		rb_erase(p, &q->t_root);
> 		rtnl_kfree_skbs(skb, skb);
> 	}
> 
> 2) Use rb_next() instead of rb_first() in the loop :
> 
> 	p = rb_first(&q->t_root);
> 	while (p) {
> 		struct sk_buff *skb = netem_rb_to_skb(p);
> 
> 		p = rb_next(p);
> 		rb_erase(&skb->rbnode, &q->t_root);
> 		rtnl_kfree_skbs(skb, skb);
> 	}
> 
> 3) "optimized" method using rbtree_postorder_for_each_entry_safe()
> 
> 	struct sk_buff *skb, *next;
> 
> 	rbtree_postorder_for_each_entry_safe(skb, next,
> 					     &q->t_root, rbnode) {
>                rtnl_kfree_skbs(skb, skb);
> 	}
> 	q->t_root = RB_ROOT;
> 
> Results :
> 
> method_1:while (rb_first()) rb_erase() 10000 skbs in 690378 ns (69 ns per skb)
> method_2:rb_first; while (p) { p = rb_next(p); ...}  10000 skbs in 541846 ns (54 ns per skb)
> method_3:rbtree_postorder_for_each_entry_safe() 10000 skbs in 868307 ns (86 ns per skb)
> 
> method_1:while (rb_first()) rb_erase() 99996 skbs in 7804021 ns (78 ns per skb)
> method_2:rb_first; while (p) { p = rb_next(p); ...}  100000 skbs in 5942456 ns (59 ns per skb)
> method_3:rbtree_postorder_for_each_entry_safe() 100000 skbs in 11584940 ns (115 ns per skb)
> 
> method_1:while (rb_first()) rb_erase() 1000000 skbs in 108577838 ns (108 ns per skb)
> method_2:rb_first; while (p) { p = rb_next(p); ...}  1000000 skbs in 82619635 ns (82 ns per skb)
> method_3:rbtree_postorder_for_each_entry_safe() 1000000 skbs in 127328743 ns (127 ns per skb)
> 
> Method 2) is simply faster, probably because it maintains a smaller
> working size set.
> 
> Note that this is the method we use in tcp_ofo_queue() already.
> 
> I will also change skb_rbtree_purge() in a second patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/sched/sch_netem.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index 063a4bdb9ee6f26b01387959e8f6ccd15ec16191..5a4f1008029068372019a965186e7a3c0a18aac3 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -361,12 +361,13 @@ static psched_time_t packet_len_2_sched_time(unsigned int len, struct netem_sche
>  static void tfifo_reset(struct Qdisc *sch)
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
> -	struct rb_node *p;
> +	struct rb_node *p = rb_first(&q->t_root);
>  
> -	while ((p = rb_first(&q->t_root))) {
> +	while (p) {
>  		struct sk_buff *skb = netem_rb_to_skb(p);
>  
> -		rb_erase(p, &q->t_root);
> +		p = rb_next(p);
> +		rb_erase(&skb->rbnode, &q->t_root);
>  		rtnl_kfree_skbs(skb, skb);
>  	}
>  }
> 
> 

Hi Eric:

I'm guessing the cost is in the rb_first and rb_next computations. Did
you consider something like this:

        struct rb_root *root
        struct rb_node **p = &root->rb_node;

        while (*p != NULL) {
                struct foobar *fb;

                fb = container_of(*p, struct foobar, rb_node);
                // fb processing

                p = &root->rb_node;
        }
