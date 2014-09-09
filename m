From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 02/15] net: rcu-ify tcf_proto
Date: Tue, 09 Sep 2014 05:20:57 -0700
Message-ID: <1410265257.11872.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	 <20140909055437.2071.86430.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:56627 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756294AbaIIMU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 08:20:59 -0400
Received: by mail-pd0-f170.google.com with SMTP id fp1so1118249pdb.29
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 05:20:58 -0700 (PDT)
In-Reply-To: <20140909055437.2071.86430.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 22:54 -0700, John Fastabend wrote:
> rcu'ify tcf_proto this allows calling tc_classify() without holding
> any locks. Updaters are protected by RTNL.
> 
> This patch prepares the core net_sched infrastracture for running
> the classifier/action chains without holding the qdisc lock however
> it does nothing to ensure cls_xxx and act_xxx types also work without
> locking. Additional patches are required to address the fall out.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/net/sch_generic.h |    9 +++++----
>  net/sched/cls_api.c       |   30 +++++++++++++++---------------
>  net/sched/sch_api.c       |   10 +++++-----
>  net/sched/sch_atm.c       |   22 +++++++++++++---------
>  net/sched/sch_cbq.c       |   13 +++++++++----
>  net/sched/sch_choke.c     |   17 ++++++++++++-----
>  net/sched/sch_drr.c       |    9 ++++++---
>  net/sched/sch_dsmark.c    |    9 +++++----
>  net/sched/sch_fq_codel.c  |   11 +++++++----
>  net/sched/sch_hfsc.c      |    8 ++++----
>  net/sched/sch_htb.c       |   15 ++++++++-------
>  net/sched/sch_ingress.c   |    8 +++++---
>  net/sched/sch_multiq.c    |    8 +++++---
>  net/sched/sch_prio.c      |   11 +++++++----
>  net/sched/sch_qfq.c       |    9 ++++++---
>  net/sched/sch_sfb.c       |   15 +++++++++------
>  net/sched/sch_sfq.c       |   11 +++++++----
>  17 files changed, 128 insertions(+), 87 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 19b1b36..be000bb 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -143,7 +143,7 @@ struct Qdisc_class_ops {
>  	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
>  
>  	/* Filter manipulation */
> -	struct tcf_proto **	(*tcf_chain)(struct Qdisc *, unsigned long);
> +	struct tcf_proto __rcu ** (*tcf_chain)(struct Qdisc *, unsigned long);
>  	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long,
>  					u32 classid);
>  	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
> @@ -212,8 +212,8 @@ struct tcf_proto_ops {
>  
>  struct tcf_proto {
>  	/* Fast access part */
> -	struct tcf_proto	*next;
> -	void			*root;
> +	struct tcf_proto __rcu	*next;
> +	void __rcu		*root;
>  	int			(*classify)(struct sk_buff *,
>  					    const struct tcf_proto *,
>  					    struct tcf_result *);
> @@ -225,6 +225,7 @@ struct tcf_proto {
>  	struct Qdisc		*q;
>  	void			*data;
>  	const struct tcf_proto_ops	*ops;
> +	struct rcu_head		rcu;
>  };
>  
>  struct qdisc_skb_cb {
> @@ -378,7 +379,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
>  void __qdisc_calculate_pkt_len(struct sk_buff *skb,
>  			       const struct qdisc_size_table *stab);
>  void tcf_destroy(struct tcf_proto *tp);
> -void tcf_destroy_chain(struct tcf_proto **fl);
> +void tcf_destroy_chain(struct tcf_proto __rcu **fl);
>  
>  /* Reset all TX qdiscs greater then index of a device.  */
>  static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index c28b0d3..e3d3c48 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -117,7 +117,6 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>  {
>  	struct net *net = sock_net(skb->sk);
>  	struct nlattr *tca[TCA_MAX + 1];
> -	spinlock_t *root_lock;
>  	struct tcmsg *t;
>  	u32 protocol;
>  	u32 prio;
> @@ -125,7 +124,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>  	u32 parent;
>  	struct net_device *dev;
>  	struct Qdisc  *q;
> -	struct tcf_proto **back, **chain;
> +	struct tcf_proto __rcu **back;
> +	struct tcf_proto __rcu **chain;
>  	struct tcf_proto *tp;
>  	const struct tcf_proto_ops *tp_ops;
>  	const struct Qdisc_class_ops *cops;
> @@ -197,7 +197,9 @@ replay:
>  		goto errout;
>  
>  	/* Check the chain for existence of proto-tcf with this priority */
> -	for (back = chain; (tp = *back) != NULL; back = &tp->next) {
> +	for (back = chain;
> +	     (tp = rtnl_dereference(*back)) != NULL;
> +	     back = &tp->next) {
>  		if (tp->prio >= prio) {
>  			if (tp->prio == prio) {
>  				if (!nprio ||
> @@ -209,8 +211,6 @@ replay:
>  		}
>  	}
>  
> -	root_lock = qdisc_root_sleeping_lock(q);
> -
>  	if (tp == NULL) {
>  		/* Proto-tcf does not exist, create new one */
>  
> @@ -259,7 +259,8 @@ replay:
>  		}
>  		tp->ops = tp_ops;
>  		tp->protocol = protocol;
> -		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
> +		tp->prio = nprio ? :
> +			       TC_H_MAJ(tcf_auto_prio(rtnl_dereference(*back)));
>  		tp->q = q;
>  		tp->classify = tp_ops->classify;
>  		tp->classid = parent;
> @@ -280,9 +281,9 @@ replay:
>  
>  	if (fh == 0) {
>  		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
> -			spin_lock_bh(root_lock);
> -			*back = tp->next;
> -			spin_unlock_bh(root_lock);
> +			struct tcf_proto *next = rtnl_dereference(tp->next);
> +
> +			rcu_assign_pointer(*back, next);

RCU_ACCESS_POINTER() is sufficient here.  (vi +999
include/linux/rcupdate.h   if you want exact details)

>  
>  			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
>  			tcf_destroy(tp);
> @@ -322,10 +323,8 @@ replay:
>  			      n->nlmsg_flags & NLM_F_CREATE ? TCA_ACT_NOREPLACE : TCA_ACT_REPLACE);
>  	if (err == 0) {
>  		if (tp_created) {
> -			spin_lock_bh(root_lock);
> -			tp->next = *back;
> -			*back = tp;
> -			spin_unlock_bh(root_lock);
> +			rcu_assign_pointer(tp->next, rtnl_dereference(*back));

The first rcu_assign_pointer() should be an RCU_ACCESS_POINTER() : tp is
not yet visible to any reader.

> +			rcu_assign_pointer(*back, tp);

This one is OK.

>  		}
>  		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
>  	} else {
> @@ -420,7 +419,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
>  	int s_t;
>  	struct net_device *dev;
>  	struct Qdisc *q;
> -	struct tcf_proto *tp, **chain;
> +	struct tcf_proto *tp, __rcu **chain;
>  	struct tcmsg *tcm = nlmsg_data(cb->nlh);
>  	unsigned long cl = 0;
>  	const struct Qdisc_class_ops *cops;
> @@ -454,7 +453,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
>  
>  	s_t = cb->args[0];
>  
> -	for (tp = *chain, t = 0; tp; tp = tp->next, t++) {
> +	for (tp = rtnl_dereference(*chain), t = 0;
> +	     tp; tp = rtnl_dereference(tp->next), t++) {
>  		if (t < s_t)
>  			continue;
>  		if (TC_H_MAJ(tcm->tcm_info) &&
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 58bed75..7c57867 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1781,7 +1781,7 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
>  	__be16 protocol = skb->protocol;
>  	int err;
>  
> -	for (; tp; tp = tp->next) {
> +	for (; tp; tp = rcu_dereference_bh(tp->next)) {
>  		if (tp->protocol != protocol &&
>  		    tp->protocol != htons(ETH_P_ALL))
>  			continue;
> @@ -1833,15 +1833,15 @@ void tcf_destroy(struct tcf_proto *tp)
>  {
>  	tp->ops->destroy(tp);
>  	module_put(tp->ops->owner);
> -	kfree(tp);
> +	kfree_rcu(tp, rcu);
>  }
>  
> -void tcf_destroy_chain(struct tcf_proto **fl)
> +void tcf_destroy_chain(struct tcf_proto __rcu **fl)
>  {
>  	struct tcf_proto *tp;
>  
> -	while ((tp = *fl) != NULL) {
> -		*fl = tp->next;
> +	while ((tp = rtnl_dereference(*fl)) != NULL) {
> +		rcu_assign_pointer(*fl, tp->next);

RCU_ACCESS_POINTER()

>  		tcf_destroy(tp);
>  	}
>  }
> diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
> index 8449b33..9140bb0 100644
> --- a/net/sched/sch_atm.c
> +++ b/net/sched/sch_atm.c
> @@ -41,7 +41,7 @@
>  
>  struct atm_flow_data {
>  	struct Qdisc		*q;	/* FIFO, TBF, etc. */
> -	struct tcf_proto	*filter_list;
> +	struct tcf_proto __rcu	*filter_list;
>  	struct atm_vcc		*vcc;	/* VCC; NULL if VCC is closed */
>  	void			(*old_pop)(struct atm_vcc *vcc,
>  					   struct sk_buff *skb); /* chaining */
> @@ -142,7 +142,9 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
>  	list_del_init(&flow->list);
>  	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
>  	qdisc_destroy(flow->q);
> +

Please refrain doing this cleanups as much as possible ;)

>  	tcf_destroy_chain(&flow->filter_list);
> +

Same here

>  	if (flow->sock) {
>  		pr_debug("atm_tc_put: f_count %ld\n",
>  			file_count(flow->sock->file));
> @@ -273,7 +275,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
>  		error = -ENOBUFS;
>  		goto err_out;
>  	}
> -	flow->filter_list = NULL;
> +	RCU_INIT_POINTER(flow->filter_list, NULL);
>  	flow->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
>  	if (!flow->q)
>  		flow->q = &noop_qdisc;
> @@ -311,7 +313,7 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
>  	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
>  	if (list_empty(&flow->list))
>  		return -EINVAL;
> -	if (flow->filter_list || flow == &p->link)
> +	if (rtnl_dereference(flow->filter_list) || flow == &p->link)

rcu_access_pointer()

>  		return -EBUSY;
>  	/*
>  	 * Reference count must be 2: one for "keepalive" (set at class
> @@ -345,7 +347,8 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
>  	}
>  }
>  
> -static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
> +static struct tcf_proto __rcu **atm_tc_find_tcf(struct Qdisc *sch,
> +						unsigned long cl)
>  {
>  	struct atm_qdisc_data *p = qdisc_priv(sch);
>  	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
> @@ -369,11 +372,12 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	flow = NULL;
>  	if (TC_H_MAJ(skb->priority) != sch->handle ||
>  	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
> +		struct tcf_proto *fl;
> +
>  		list_for_each_entry(flow, &p->flows, list) {
> -			if (flow->filter_list) {
> -				result = tc_classify_compat(skb,
> -							    flow->filter_list,
> -							    &res);
> +			fl = rcu_dereference_bh(flow->filter_list);
> +			if (fl) {
> +				result = tc_classify_compat(skb, fl, &res);
>  				if (result < 0)
>  					continue;
>  				flow = (struct atm_flow_data *)res.class;
> @@ -544,7 +548,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
>  	if (!p->link.q)
>  		p->link.q = &noop_qdisc;
>  	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
> -	p->link.filter_list = NULL;
> +	RCU_INIT_POINTER(p->link.filter_list, NULL);
>  	p->link.vcc = NULL;
>  	p->link.sock = NULL;
>  	p->link.classid = sch->handle;
> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 762a04b..80231d9 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -133,7 +133,7 @@ struct cbq_class {
>  	struct gnet_stats_rate_est64 rate_est;
>  	struct tc_cbq_xstats	xstats;
>  
> -	struct tcf_proto	*filter_list;
> +	struct tcf_proto __rcu	*filter_list;
>  
>  	int			refcnt;
>  	int			filters;
> @@ -221,6 +221,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
>  	struct cbq_class **defmap;
>  	struct cbq_class *cl = NULL;
>  	u32 prio = skb->priority;
> +	struct tcf_proto *fl;
>  	struct tcf_result res;
>  
>  	/*
> @@ -233,13 +234,15 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
>  	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
>  	for (;;) {
>  		int result = 0;
> +
Please remove this NL

>  		defmap = head->defaults;
>  
> +		fl = rcu_dereference_bh(head->filter_list);
>  		/*
>  		 * Step 2+n. Apply classifier.
>  		 */
> -		if (!head->filter_list ||
> -		    (result = tc_classify_compat(skb, head->filter_list, &res)) < 0)
> +		result = tc_classify_compat(skb, fl, &res);
> +		if (!fl || result < 0)
>  			goto fallback;
>  
>  		cl = (void *)res.class;
> @@ -1667,6 +1670,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
>  	WARN_ON(cl->filters);
>  
>  	tcf_destroy_chain(&cl->filter_list);
> +
Please remove this NL

>  	qdisc_destroy(cl->q);
>  	qdisc_put_rtab(cl->R_tab);
>  	gen_kill_estimator(&cl->bstats, &cl->rate_est);
> @@ -1954,7 +1958,8 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
>  	return 0;
>  }
>  

// rest of patch was good.

Thanks !
