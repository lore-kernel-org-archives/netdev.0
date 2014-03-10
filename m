From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 09/14] net: sched: make cls_u32 lockless
Date: Mon, 10 Mar 2014 10:58:56 -0700
Message-ID: <1394474336.3607.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170658.3011.39901.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:58422 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbaCJR66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:58:58 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so7581593pad.14
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:58:58 -0700 (PDT)
In-Reply-To: <20140310170658.3011.39901.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:07 -0700, John Fastabend wrote:
> Make cls_u32 classifier safe to run without holding lock. This patch
> converts statistics that are kept in read section u32_classify into
> per cpu counters.
> 
> This patch was tested with a tight u32 filter add/delete loop while
> generating traffic with pktgen. By running pktgen on vlan devices
> created on top of a physical device we can hit the qdisc layer
> correctly. For ingress qdisc's a loopback cable was used.
> 
> for i in {1..100}; do
>         q=`echo $i%8|bc`;
>         echo -n "u32 tos: iteration $i on queue $q";
>         tc filter add dev p3p2 parent $p prio $i u32 match ip tos 0x10 0xff \
>                   action skbedit queue_mapping $q;
>         sleep 1;
>         tc filter del dev p3p2 prio $i;
> 
>         echo -n "u32 tos hash table: iteration $i on queue $q";
>         tc filter add dev p3p2 parent $p protocol ip prio $i handle 628: u32 divisor 1
>         tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
>                 match ip protocol 17 0xff link 628: offset at 0 mask 0xf00 shift 6 plus 0
>         tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
>                 ht 628:0 match ip tos 0x10 0xff action skbedit queue_mapping $q
>         sleep 2;
>         tc filter del dev p3p2 prio $i
>         sleep 1;
> done
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_u32.c |  257 +++++++++++++++++++++++++++++++++------------------
>  1 file changed, 168 insertions(+), 89 deletions(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 84c28da..e1f7119 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -36,6 +36,7 @@
>  #include <linux/kernel.h>
>  #include <linux/string.h>
>  #include <linux/errno.h>
> +#include <linux/percpu.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/skbuff.h>
>  #include <net/netlink.h>
> @@ -43,40 +44,46 @@
>  #include <net/pkt_cls.h>
>  
>  struct tc_u_knode {
> -	struct tc_u_knode	*next;
> +	struct tc_u_knode __rcu	*next;
>  	u32			handle;
> -	struct tc_u_hnode	*ht_up;
> +	struct tc_u_hnode __rcu	*ht_up;
>  	struct tcf_exts		exts;
>  #ifdef CONFIG_NET_CLS_IND
>  	int			ifindex;
>  #endif
>  	u8			fshift;
>  	struct tcf_result	res;
> -	struct tc_u_hnode	*ht_down;
> +	struct tc_u_hnode __rcu	*ht_down;
>  #ifdef CONFIG_CLS_U32_PERF
> -	struct tc_u32_pcnt	*pf;
> +	struct tc_u32_pcnt __percpu *pf;
>  #endif
>  #ifdef CONFIG_CLS_U32_MARK
> -	struct tc_u32_mark	mark;
> +	u32			val;
> +	u32			mask;
> +	u32 __percpu		*pcpu_success;
>  #endif
> +	struct tcf_proto	*tp;
> +	struct rcu_head		rcu;
>  	struct tc_u32_sel	sel;
>  };
>  
>  struct tc_u_hnode {
> -	struct tc_u_hnode	*next;
> +	struct tc_u_hnode __rcu	*next;
>  	u32			handle;
>  	u32			prio;
>  	struct tc_u_common	*tp_c;
>  	int			refcnt;
>  	unsigned int		divisor;
> -	struct tc_u_knode	*ht[1];
> +	struct tc_u_knode __rcu	*ht[1];
> +	struct rcu_head		rcu;
>  };
>  
>  struct tc_u_common {
> -	struct tc_u_hnode	*hlist;
> +	struct tc_u_hnode __rcu	*hlist;
>  	struct Qdisc		*q;
>  	int			refcnt;
>  	u32			hgenerator;
> +	struct rcu_head		rcu;
>  };
>  
>  static inline unsigned int u32_hash_fold(__be32 key,
> @@ -95,7 +102,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
>  		unsigned int	  off;
>  	} stack[TC_U32_MAXDEPTH];
>  
> -	struct tc_u_hnode *ht = tp->root;
> +	struct tc_u_hnode *ht = rcu_dereference_bh(tp->root);
>  	unsigned int off = skb_network_offset(skb);
>  	struct tc_u_knode *n;
>  	int sdepth = 0;
> @@ -103,27 +110,31 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
>  	int sel = 0;
>  #ifdef CONFIG_CLS_U32_PERF
>  	int j;
> +	struct tc_u32_pcnt *pf;
>  #endif
>  	int i, r;
>  
>  next_ht:
> -	n = ht->ht[sel];
> +	n = rcu_dereference_bh(ht->ht[sel]);
>  
>  next_knode:
>  	if (n) {
>  		struct tc_u32_key *key = n->sel.keys;
>  
>  #ifdef CONFIG_CLS_U32_PERF
> -		n->pf->rcnt += 1;
> +		pf = this_cpu_ptr(n->pf);
> +		pf->rcnt += 1;

Please prefer this_cpu_add() or this_cpu_inc()

>  		j = 0;
>  #endif
>  
>  #ifdef CONFIG_CLS_U32_MARK
> -		if ((skb->mark & n->mark.mask) != n->mark.val) {
> -			n = n->next;
> +		if ((skb->mark & n->mask) != n->val) {
> +			n = rcu_dereference_bh(n->next);
>  			goto next_knode;
>  		} else {
> -			n->mark.success++;
> +			u32 *success = this_cpu_ptr(n->pcpu_success);
> +
> +			*success = *success + 1;

Same here, this_cpu_add() or this_cpu_inc()

>  		}
>  #endif
>  
> @@ -138,37 +149,41 @@ next_knode:
>  			if (!data)
>  				goto out;
>  			if ((*data ^ key->val) & key->mask) {
> -				n = n->next;
> +				n = rcu_dereference_bh(n->next);
>  				goto next_knode;
>  			}
>  #ifdef CONFIG_CLS_U32_PERF
> -			n->pf->kcnts[j] += 1;
> +			pf = this_cpu_ptr(n->pf);
> +			pf->kcnts[j] += 1;

same here.

>  			j++;
>  #endif
>  		}
> -		if (n->ht_down == NULL) {
> +
> +		ht = rcu_dereference_bh(n->ht_down);
> +		if (!ht) {
>  check_terminal:
>  			if (n->sel.flags & TC_U32_TERMINAL) {
>  
>  				*res = n->res;
>  #ifdef CONFIG_NET_CLS_IND
>  				if (!tcf_match_indev(skb, n->ifindex)) {
> -					n = n->next;
> +					n = rcu_dereference_bh(n->next);
>  					goto next_knode;
>  				}
>  #endif
>  #ifdef CONFIG_CLS_U32_PERF
> -				n->pf->rhit += 1;
> +				pf = this_cpu_ptr(n->pf);
> +				pf->rhit += 1;


same

Otherwise, patch looks good, thanks !
