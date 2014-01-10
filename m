From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 1/4] net_sched: switch filter list to list_head
Date: Thu, 09 Jan 2014 19:48:31 -0800
Message-ID: <52CF6D8F.60508@gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com> <1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:46725 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaAJDs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 22:48:58 -0500
Received: by mail-oa0-f43.google.com with SMTP id m1so4453586oag.16
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 19:48:58 -0800 (PST)
In-Reply-To: <1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2014 10:19 AM, Cong Wang wrote:
> So that it could be potentially traversed with RCU.
>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/net/pkt_sched.h   |  4 ++--
>   include/net/sch_generic.h |  9 ++++++---
>   net/sched/cls_api.c       | 36 ++++++++++++++++++++++++------------
>   net/sched/sch_api.c       | 35 ++++++++++++++++++++++-------------
>   net/sched/sch_atm.c       | 14 +++++++-------
>   net/sched/sch_cbq.c       |  9 +++++----
>   net/sched/sch_choke.c     | 11 ++++++-----
>   net/sched/sch_drr.c       |  7 ++++---
>   net/sched/sch_dsmark.c    |  7 ++++---
>   net/sched/sch_fq_codel.c  |  9 +++++----
>   net/sched/sch_hfsc.c      | 15 +++++++++------
>   net/sched/sch_htb.c       | 20 ++++++++++++--------
>   net/sched/sch_ingress.c   | 14 +++++++++++---
>   net/sched/sch_multiq.c    |  7 ++++---
>   net/sched/sch_prio.c      |  9 +++++----
>   net/sched/sch_qfq.c       |  7 ++++---
>   net/sched/sch_sfb.c       |  9 +++++----
>   net/sched/sch_sfq.c       | 11 ++++++-----
>   18 files changed, 141 insertions(+), 92 deletions(-)
>
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index 891d80d..27a1efa 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -109,9 +109,9 @@ static inline void qdisc_run(struct Qdisc *q)
>   		__qdisc_run(q);
>   }
>
> -int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
> +int tc_classify_compat(struct sk_buff *skb, const struct list_head *head,
>   		       struct tcf_result *res);
> -int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
> +int tc_classify(struct sk_buff *skb, const struct list_head *head,
>   		struct tcf_result *res);
>
>   /* Calculate maximal size of packet seen by hard_start_xmit
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 013d96d..97123cc 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -6,6 +6,7 @@
>   #include <linux/rcupdate.h>
>   #include <linux/pkt_sched.h>
>   #include <linux/pkt_cls.h>
> +#include <linux/list.h>
>   #include <net/gen_stats.h>
>   #include <net/rtnetlink.h>
>
> @@ -143,7 +144,7 @@ struct Qdisc_class_ops {
>   	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
>
>   	/* Filter manipulation */
> -	struct tcf_proto **	(*tcf_chain)(struct Qdisc *, unsigned long);
> +	struct list_head *	(*tcf_chain)(struct Qdisc *, unsigned long);

I'm not sure, I thought it was just fine the way it was. That pattern
exists in a few other places inside the networking stack and we don't
go around converting them to lists. But that is just my opinion.

>   	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
>   					u32 classid);
>   	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
> @@ -184,6 +185,8 @@ struct tcf_result {
>   	u32		classid;
>   };
>
> +struct tcf_proto;
> +
>   struct tcf_proto_ops {
>   	struct list_head	head;
>   	char			kind[IFNAMSIZ];
> @@ -212,7 +215,7 @@ struct tcf_proto_ops {
>
>   struct tcf_proto {
>   	/* Fast access part */
> -	struct tcf_proto	*next;
> +	struct list_head	head;
>   	void			*root;
>   	int			(*classify)(struct sk_buff *,
>   					    const struct tcf_proto *,
> @@ -376,7 +379,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
>   void __qdisc_calculate_pkt_len(struct sk_buff *skb,
>   			       const struct qdisc_size_table *stab);
>   void tcf_destroy(struct tcf_proto *tp);
> -void tcf_destroy_chain(struct tcf_proto **fl);
> +void tcf_destroy_chain(struct list_head *fl);
>
>   /* Reset all TX qdiscs greater then index of a device.  */
>   static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index d8c42b1..bcc9987 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -125,8 +125,9 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>   	u32 parent;
>   	struct net_device *dev;
>   	struct Qdisc  *q;
> -	struct tcf_proto **back, **chain;
> -	struct tcf_proto *tp;
> +	struct tcf_proto *back;
> +	struct list_head *chain;
> +	struct tcf_proto *tp, *res = NULL;
>   	const struct tcf_proto_ops *tp_ops;
>   	const struct Qdisc_class_ops *cops;
>   	unsigned long cl;
> @@ -196,21 +197,27 @@ replay:
>   		goto errout;
>
>   	/* Check the chain for existence of proto-tcf with this priority */
> -	for (back = chain; (tp = *back) != NULL; back = &tp->next) {
> +	rcu_read_lock();

why rcu_read_lock() this is under rtnl lock.

> +	list_for_each_entry_rcu(tp, chain, head) {

No need for the rcu you are under the writer lock.

> +		back = list_next_entry(tp, head);
>   		if (tp->prio >= prio) {
>   			if (tp->prio == prio) {
>   				if (!nprio ||
> -				    (tp->protocol != protocol && protocol))
> +				    (tp->protocol != protocol && protocol)) {
> +					rcu_read_unlock();
>   					goto errout;
> +				}
> +				res = tp;
>   			} else
> -				tp = NULL;
> +				res = NULL;
>   			break;
>   		}
>   	}
> +	rcu_read_unlock();

ditto

>
>   	root_lock = qdisc_root_sleeping_lock(q);
>
> -	if (tp == NULL) {
> +	if ((tp = res) == NULL) {
>   		/* Proto-tcf does not exist, create new one */
>
>   		if (tca[TCA_KIND] == NULL || !protocol)
> @@ -228,6 +235,7 @@ replay:
>   		tp = kzalloc(sizeof(*tp), GFP_KERNEL);
>   		if (tp == NULL)
>   			goto errout;
> +		INIT_LIST_HEAD(&tp->head);
>   		err = -ENOENT;
>   		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
>   		if (tp_ops == NULL) {
> @@ -258,7 +266,7 @@ replay:
>   		}
>   		tp->ops = tp_ops;
>   		tp->protocol = protocol;
> -		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
> +		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(back));
>   		tp->q = q;
>   		tp->classify = tp_ops->classify;
>   		tp->classid = parent;
> @@ -280,7 +288,7 @@ replay:
>   	if (fh == 0) {
>   		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
>   			spin_lock_bh(root_lock);
> -			*back = tp->next;
> +			list_del_rcu(&tp->head);
>   			spin_unlock_bh(root_lock);
>
>   			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
> @@ -321,8 +329,7 @@ replay:
>   	if (err == 0) {
>   		if (tp_created) {
>   			spin_lock_bh(root_lock);
> -			tp->next = *back;
> -			*back = tp;
> +			list_add_rcu(&tp->head, chain);
>   			spin_unlock_bh(root_lock);
>   		}
>   		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
> @@ -417,7 +424,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
>   	int s_t;
>   	struct net_device *dev;
>   	struct Qdisc *q;
> -	struct tcf_proto *tp, **chain;
> +	struct tcf_proto *tp;
> +	struct list_head *chain;
>   	struct tcmsg *tcm = nlmsg_data(cb->nlh);
>   	unsigned long cl = 0;
>   	const struct Qdisc_class_ops *cops;
> @@ -451,7 +459,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
>
>   	s_t = cb->args[0];
>
> -	for (tp = *chain, t = 0; tp; tp = tp->next, t++) {
> +	t = 0;
> +	rcu_read_lock();

same under rtnl right?

> +	list_for_each_entry_rcu(tp, chain, head) {

... so the _rcu can be dropped.

>   		if (t < s_t)
>   			continue;
>   		if (TC_H_MAJ(tcm->tcm_info) &&
> @@ -482,7 +492,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
>   		cb->args[1] = arg.w.count + 1;
>   		if (arg.w.stop)
>   			break;
> +		t++;
>   	}
> +	rcu_read_unlock();
>
>   	cb->args[0] = t;
>
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 1313145..df86686 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -29,6 +29,7 @@
>   #include <linux/hrtimer.h>
>   #include <linux/lockdep.h>
>   #include <linux/slab.h>
> +#include <linux/rculist.h>
>
>   #include <net/net_namespace.h>
>   #include <net/sock.h>
> @@ -1772,13 +1773,15 @@ done:
>    * to this qdisc, (optionally) tests for protocol and asks
>    * specific classifiers.
>    */
> -int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
> +int tc_classify_compat(struct sk_buff *skb, const struct list_head *head,

notice you don't check for a null head value here so it better not be
null.

>   		       struct tcf_result *res)
>   {
> +	struct tcf_proto *tp;
>   	__be16 protocol = skb->protocol;
> -	int err;
> +	int err = -1;
>
> -	for (; tp; tp = tp->next) {
> +	WARN_ON_ONCE(!rcu_read_lock_held());

its just rfc code but no need for the warn on.

> +	list_for_each_entry_rcu(tp, head, head) {
>   		if (tp->protocol != protocol &&
>   		    tp->protocol != htons(ETH_P_ALL))
>   			continue;
> @@ -1789,23 +1792,25 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
>   			if (err != TC_ACT_RECLASSIFY && skb->tc_verd)
>   				skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
>   #endif
> -			return err;
> +			break;
>   		}
>   	}
> -	return -1;
> +
> +	return err;
>   }
>   EXPORT_SYMBOL(tc_classify_compat);
>
> -int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
> +int tc_classify(struct sk_buff *skb, const struct list_head *head,
>   		struct tcf_result *res)
>   {
>   	int err = 0;
>   #ifdef CONFIG_NET_CLS_ACT
> -	const struct tcf_proto *otp = tp;
> +	const struct tcf_proto *tp;
> +	const struct tcf_proto *otp = list_first_entry(head, struct tcf_proto, head);
>   reclassify:
>   #endif
>
> -	err = tc_classify_compat(skb, tp, res);
> +	err = tc_classify_compat(skb, head, res);
>   #ifdef CONFIG_NET_CLS_ACT
>   	if (err == TC_ACT_RECLASSIFY) {
>   		u32 verd = G_TC_VERD(skb->tc_verd);
> @@ -1830,16 +1835,20 @@ void tcf_destroy(struct tcf_proto *tp)
>   {
>   	tp->ops->destroy(tp);
>   	module_put(tp->ops->owner);
> +	synchronize_rcu();

maybe call_rcu we don't wan't to syncronize during a destroy chain
operation.

>   	kfree(tp);
>   }
>
> -void tcf_destroy_chain(struct tcf_proto **fl)
> +void tcf_destroy_chain(struct list_head *fl)
>   {
> -	struct tcf_proto *tp;
> +	struct tcf_proto *tp, *n;
> +	LIST_HEAD(list);
> +	list_splice_init_rcu(fl, &list, synchronize_rcu);
>
> -	while ((tp = *fl) != NULL) {
> -		*fl = tp->next;
> -		tcf_destroy(tp);
> +	list_for_each_entry_safe(tp, n, &list, head) {
> +		tp->ops->destroy(tp);
> +		module_put(tp->ops->owner);
> +		kfree(tp);

fix the sync above and then there is no reason as far as I can tell
to change this code. Or at least that should be kfree_rcu().

>   	}
>   }
>   EXPORT_SYMBOL(tcf_destroy_chain);
> diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
> index 1f9c314..20a07c2 100644
> --- a/net/sched/sch_atm.c
> +++ b/net/sched/sch_atm.c
> @@ -41,7 +41,7 @@
>
>   struct atm_flow_data {
>   	struct Qdisc		*q;	/* FIFO, TBF, etc. */
> -	struct tcf_proto	*filter_list;
> +	struct list_head 	filter_list;
>   	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
>   	void			(*old_pop)(struct atm_vcc *vcc,
>   					   struct sk_buff *skb); /* chaining */
> @@ -273,7 +273,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
>   		error = -ENOBUFS;
>   		goto err_out;
>   	}
> -	flow->filter_list = NULL;
> +	INIT_LIST_HEAD(&flow->filter_list);
>   	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
>   	if (!flow->q)
>   		flow->q = &noop_qdisc;
> @@ -311,7 +311,7 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
>   	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
>   	if (list_empty(&flow->list))
>   		return -EINVAL;
> -	if (flow->filter_list || flow == &p->link)
> +	if (!list_empty(&flow->filter_list) || flow == &p->link)
>   		return -EBUSY;
>   	/*
>   	 * Reference count must be 2: one for "keepalive" (set at class
> @@ -345,7 +345,7 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
>   	}
>   }
>
> -static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
> +static struct list_head *atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
>   {
>   	struct atm_qdisc_data *p = qdisc_priv(sch);
>   	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
> @@ -370,9 +370,9 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>   	if (TC_H_MAJ(skb->priority) != sch->handle ||
>   	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
>   		list_for_each_entry(flow, &p->flows, list) {
> -			if (flow->filter_list) {
> +			if (!list_empty(&flow->filter_list)) {
>   				result = tc_classify_compat(skb,
> -							    flow->filter_list,
> +							    &flow->filter_list,
>   							    &res);
>   				if (result < 0)
>   					continue;
> @@ -544,7 +544,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
>   	if (!p->link.q)
>   		p->link.q = &noop_qdisc;
>   	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
> -	p->link.filter_list = NULL;
> +	INIT_LIST_HEAD(&p->link.filter_list);
>   	p->link.vcc = NULL;
>   	p->link.sock = NULL;
>   	p->link.classid = sch->handle;
> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 2f80d01..a5914ff 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -133,7 +133,7 @@ struct cbq_class {
>   	struct gnet_stats_rate_est64 rate_est;
>   	struct tc_cbq_xstats	xstats;
>
> -	struct tcf_proto	*filter_list;
> +	struct list_head	filter_list;
>
>   	int			refcnt;
>   	int			filters;
> @@ -239,8 +239,8 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
>   		/*
>   		 * Step 2+n. Apply classifier.
>   		 */
> -		if (!head->filter_list ||
> -		    (result = tc_classify_compat(skb, head->filter_list, &res)) < 0)
> +		if (list_empty(&head->filter_list) ||
> +		    (result = tc_classify_compat(skb, &head->filter_list, &res)) < 0)

there is a race here, if the list is not empty when you check it but
emptied by the time you call tc_classify_compat.

Also notice you accessed a list without an _rcu function. If you grep
for list_empty_rcu() iirc its not even defined to stop this sort of
error.


>   			goto fallback;
>
>   		cl = (void *)res.class;
> @@ -1881,6 +1881,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
>   		}
>   	}
>
> +	INIT_LIST_HEAD(&cl->filter_list);
>   	cl->R_tab = rtab;
>   	rtab = NULL;
>   	cl->refcnt = 1;
> @@ -1976,7 +1977,7 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
>   	return 0;
>   }
>
> -static struct tcf_proto **cbq_find_tcf(struct Qdisc *sch, unsigned long arg)
> +static struct list_head *cbq_find_tcf(struct Qdisc *sch, unsigned long arg)
>   {
>   	struct cbq_sched_data *q = qdisc_priv(sch);
>   	struct cbq_class *cl = (struct cbq_class *)arg;
> diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
> index ddd73cb..9b36830 100644
> --- a/net/sched/sch_choke.c
> +++ b/net/sched/sch_choke.c
> @@ -58,7 +58,7 @@ struct choke_sched_data {
>
>   /* Variables */
>   	struct red_vars  vars;
> -	struct tcf_proto *filter_list;
> +	struct list_head filter_list;
>   	struct {
>   		u32	prob_drop;	/* Early probability drops */
>   		u32	prob_mark;	/* Early probability marks */
> @@ -202,7 +202,7 @@ static bool choke_classify(struct sk_buff *skb,
>   	struct tcf_result res;
>   	int result;
>
> -	result = tc_classify(skb, q->filter_list, &res);
> +	result = tc_classify(skb, &q->filter_list, &res);

hmm q->filter_list passed to tc_classify without rcu_deref.

>   	if (result >= 0) {
>   #ifdef CONFIG_NET_CLS_ACT
>   		switch (result) {
> @@ -256,7 +256,7 @@ static bool choke_match_random(const struct choke_sched_data *q,
>   		return false;
>
>   	oskb = choke_peek_random(q, pidx);
> -	if (q->filter_list)
> +	if (!list_empty(&q->filter_list))
>   		return choke_get_classid(nskb) == choke_get_classid(oskb);

same class of list_empty bug?

>
>   	return choke_match_flow(oskb, nskb);
> @@ -268,7 +268,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>   	const struct red_parms *p = &q->parms;
>   	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
>
> -	if (q->filter_list) {
> +	if (!list_empty(&q->filter_list)) {
>   		/* If using external classifiers, get result and record it. */
>   		if (!choke_classify(skb, sch, &ret))
>   			goto other_drop;	/* Packet was eaten by filter */
> @@ -476,6 +476,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
>
>   	q->flags = ctl->flags;
>   	q->limit = ctl->limit;
> +	INIT_LIST_HEAD(&q->filter_list);
>
>   	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
>   		      ctl->Plog, ctl->Scell_log,
> @@ -566,7 +567,7 @@ static unsigned long choke_bind(struct Qdisc *sch, unsigned long parent,
>   	return 0;
>   }
>
> -static struct tcf_proto **choke_find_tcf(struct Qdisc *sch, unsigned long cl)
> +static struct list_head *choke_find_tcf(struct Qdisc *sch, unsigned long cl)
>   {
>   	struct choke_sched_data *q = qdisc_priv(sch);
>
> diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
> index 8302717..62f45ac 100644
> --- a/net/sched/sch_drr.c
> +++ b/net/sched/sch_drr.c
> @@ -35,7 +35,7 @@ struct drr_class {
>
>   struct drr_sched {
>   	struct list_head		active;
> -	struct tcf_proto		*filter_list;
> +	struct list_head		filter_list;

also all of this needs to be annotated.

>   	struct Qdisc_class_hash		clhash;
>   };
>
> @@ -184,7 +184,7 @@ static void drr_put_class(struct Qdisc *sch, unsigned long arg)
>   		drr_destroy_class(sch, cl);
>   }
>
> -static struct tcf_proto **drr_tcf_chain(struct Qdisc *sch, unsigned long cl)
> +static struct list_head *drr_tcf_chain(struct Qdisc *sch, unsigned long cl)
>   {
>   	struct drr_sched *q = qdisc_priv(sch);
>
> @@ -328,7 +328,7 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
>   	}
>
>   	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
> -	result = tc_classify(skb, q->filter_list, &res);
> +	result = tc_classify(skb, &q->filter_list, &res);

ditto no rcu_deref.

>   	if (result >= 0) {
>   #ifdef CONFIG_NET_CLS_ACT
>   		switch (result) {
> @@ -443,6 +443,7 @@ static int drr_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
>   	if (err < 0)
>   		return err;
>   	INIT_LIST_HEAD(&q->active);
> +	INIT_LIST_HEAD(&q->filter_list);
>   	return 0;
>   }
>
> diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
> index 49d6ef3..4489ffe 100644
> --- a/net/sched/sch_dsmark.c
> +++ b/net/sched/sch_dsmark.c
> @@ -37,7 +37,7 @@
>
>   struct dsmark_qdisc_data {
>   	struct Qdisc		*q;
> -	struct tcf_proto	*filter_list;
> +	struct list_head	filter_list;

annotate and let smatch catch a lot of bugs for you. Same comment
for all the above instantiates I didn't comment on.

>   	u8			*mask;	/* "owns" the array */
>   	u8			*value;
>   	u16			indices;
> @@ -186,7 +186,7 @@ ignore:
>   	}
>   }
>
> -static inline struct tcf_proto **dsmark_find_tcf(struct Qdisc *sch,
> +static inline struct list_head *dsmark_find_tcf(struct Qdisc *sch,
>   						 unsigned long cl)
>   {
>   	struct dsmark_qdisc_data *p = qdisc_priv(sch);
> @@ -229,7 +229,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>   		skb->tc_index = TC_H_MIN(skb->priority);
>   	else {
>   		struct tcf_result res;
> -		int result = tc_classify(skb, p->filter_list, &res);
> +		int result = tc_classify(skb, &p->filter_list, &res);

rcu deref.

[...]

OK now I'm just repeating myself. You see the trend.

Additionally I don't see how any of the cls_*c change routines work in
your series. For example look at basic_change. Even with the rtnl lock
you need to do a read, copy, update (RCU namesake) you can't just modify
it in place like you have done.

I'll send a fixed up series out in a few minutes it should illustrate
my point.

.John

-- 
John Fastabend         Intel Corporation
