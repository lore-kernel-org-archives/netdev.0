From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v4 3/3] net sched act_vlan: VLAN action rewrite
 to use RCU lock/unlock and update
Date: Wed, 1 Nov 2017 16:25:07 +0100
Message-ID: <20171101152506.vjhhloswfyoycb2v@netronome.com>
References: <1509473820-4301-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, oss-drivers@netronome.com,
        davem@davemloft.net, netdev@vger.kernel.org, aring@mojatatu.com,
        mrv@mojatatu.com, Manish Kurup <manish.kurup@verizon.com>
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:55078 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754685AbdKAPZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 11:25:10 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so5626896wmr.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 08:25:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1509473820-4301-1-git-send-email-manish.kurup@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 02:17:00PM -0400, Manish Kurup wrote:
> Using a spinlock in the VLAN action causes performance issues when the VLAN
> action is used on multiple cores. Rewrote the VLAN action to use RCU read
> locking for reads and updates instead.
> 
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Manish Kurup <manish.kurup@verizon.com>
> ---
>  include/net/tc_act/tc_vlan.h | 46 +++++++++++++++++++++++++------
>  net/sched/act_vlan.c         | 65 ++++++++++++++++++++++++++++----------------
>  2 files changed, 78 insertions(+), 33 deletions(-)
> 
> diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
> index c2090df..22ae260 100644
> --- a/include/net/tc_act/tc_vlan.h
> +++ b/include/net/tc_act/tc_vlan.h
> @@ -13,12 +13,17 @@
>  #include <net/act_api.h>
>  #include <linux/tc_act/tc_vlan.h>
>  
> +struct tcf_vlan_params {
> +	int               tcfv_action;
> +	u16               tcfv_push_vid;
> +	__be16            tcfv_push_proto;
> +	u8                tcfv_push_prio;
> +	struct rcu_head   rcu;
> +};
> +
>  struct tcf_vlan {
>  	struct tc_action	common;
> -	int			tcfv_action;
> -	u16			tcfv_push_vid;
> -	__be16			tcfv_push_proto;
> -	u8			tcfv_push_prio;
> +	struct tcf_vlan_params __rcu *vlan_p;
>  };
>  #define to_vlan(a) ((struct tcf_vlan *)a)
>  
> @@ -33,22 +38,45 @@ static inline bool is_tcf_vlan(const struct tc_action *a)
>  
>  static inline u32 tcf_vlan_action(const struct tc_action *a)
>  {
> -	return to_vlan(a)->tcfv_action;
> +	u32 tcfv_action;
> +
> +	rcu_read_lock();
> +	tcfv_action = rcu_dereference(to_vlan(a)->vlan_p)->tcfv_action;
> +	rcu_read_unlock();
> +
> +	return tcfv_action;
>  }
>  
>  static inline u16 tcf_vlan_push_vid(const struct tc_action *a)
>  {
> -	return to_vlan(a)->tcfv_push_vid;
> +	u16 tcfv_push_vid;
> +
> +	rcu_read_lock();
> +	tcfv_push_vid = rcu_dereference(to_vlan(a)->vlan_p)->tcfv_push_vid;
> +	rcu_read_unlock();
> +
> +	return tcfv_push_vid;
>  }
>  
>  static inline __be16 tcf_vlan_push_proto(const struct tc_action *a)
>  {
> -	return to_vlan(a)->tcfv_push_proto;
> +	__be16 tcfv_push_proto;
> +
> +	rcu_read_lock();
> +	tcfv_push_proto = rcu_dereference(to_vlan(a)->vlan_p)->tcfv_push_proto;
> +	rcu_read_unlock();
> +
> +	return tcfv_push_proto;
>  }
>  
>  static inline u8 tcf_vlan_push_prio(const struct tc_action *a)
>  {
> -	return to_vlan(a)->tcfv_push_prio;
> -}
> +	u8 tcfv_push_prio;
>  
> +	rcu_read_lock();
> +	tcfv_push_prio = rcu_dereference(to_vlan(a)->vlan_p)->tcfv_push_prio;
> +	rcu_read_unlock();
> +
> +	return tcfv_push_prio;
> +}
>  #endif /* __NET_TC_VLAN_H */
> diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
> index b093bad..7f461f9 100644
> --- a/net/sched/act_vlan.c
> +++ b/net/sched/act_vlan.c
> @@ -26,6 +26,7 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>  		    struct tcf_result *res)
>  {
>  	struct tcf_vlan *v = to_vlan(a);
> +	struct tcf_vlan_params *p;
>  	int action;
>  	int err;
>  	u16 tci;
> @@ -33,24 +34,27 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>  	tcf_lastuse_update(&v->tcf_tm);
>  	bstats_cpu_update(this_cpu_ptr(v->common.cpu_bstats), skb);
>  
> -	spin_lock(&v->tcf_lock);
> -	action = v->tcf_action;
> -
>  	/* Ensure 'data' points at mac_header prior calling vlan manipulating
>  	 * functions.
>  	 */
>  	if (skb_at_tc_ingress(skb))
>  		skb_push_rcsum(skb, skb->mac_len);
>  
> -	switch (v->tcfv_action) {
> +	rcu_read_lock();
> +
> +	action = READ_ONCE(v->tcf_action);
> +
> +	p = rcu_dereference(v->vlan_p);
> +
> +	switch (p->tcfv_action) {

Its not clear to me why v->tcfv_action is changed to p->tcfv_action here.

>  	case TCA_VLAN_ACT_POP:
>  		err = skb_vlan_pop(skb);
>  		if (err)
>  			goto drop;
>  		break;
>  	case TCA_VLAN_ACT_PUSH:
> -		err = skb_vlan_push(skb, v->tcfv_push_proto, v->tcfv_push_vid |
> -				    (v->tcfv_push_prio << VLAN_PRIO_SHIFT));
> +		err = skb_vlan_push(skb, p->tcfv_push_proto, p->tcfv_push_vid |
> +				    (p->tcfv_push_prio << VLAN_PRIO_SHIFT));
>  		if (err)
>  			goto drop;
>  		break;
> @@ -69,14 +73,14 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>  				goto drop;
>  		}
>  		/* replace the vid */
> -		tci = (tci & ~VLAN_VID_MASK) | v->tcfv_push_vid;
> +		tci = (tci & ~VLAN_VID_MASK) | p->tcfv_push_vid;
>  		/* replace prio bits, if tcfv_push_prio specified */
> -		if (v->tcfv_push_prio) {
> +		if (p->tcfv_push_prio) {
>  			tci &= ~VLAN_PRIO_MASK;
> -			tci |= v->tcfv_push_prio << VLAN_PRIO_SHIFT;
> +			tci |= p->tcfv_push_prio << VLAN_PRIO_SHIFT;
>  		}
>  		/* put updated tci as hwaccel tag */
> -		__vlan_hwaccel_put_tag(skb, v->tcfv_push_proto, tci);
> +		__vlan_hwaccel_put_tag(skb, p->tcfv_push_proto, tci);
>  		break;
>  	default:
>  		BUG();
> @@ -89,10 +93,10 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>  	qstats_drop_inc(this_cpu_ptr(v->common.cpu_qstats));
>  
>  unlock:
> +	rcu_read_unlock();
>  	if (skb_at_tc_ingress(skb))
>  		skb_pull_rcsum(skb, skb->mac_len);
>  
> -	spin_unlock(&v->tcf_lock);
>  	return action;
>  }
>  
> @@ -109,6 +113,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>  {
>  	struct tc_action_net *tn = net_generic(net, vlan_net_id);
>  	struct nlattr *tb[TCA_VLAN_MAX + 1];
> +	struct tcf_vlan_params *p, *p_old;
>  	struct tc_vlan *parm;
>  	struct tcf_vlan *v;
>  	int action;
> @@ -187,16 +192,27 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>  
>  	v = to_vlan(*a);
>  
> -	spin_lock_bh(&v->tcf_lock);
> -
> -	v->tcfv_action = action;
> -	v->tcfv_push_vid = push_vid;
> -	v->tcfv_push_prio = push_prio;
> -	v->tcfv_push_proto = push_proto;
> +	ASSERT_RTNL();
> +	p = kzalloc(sizeof(*p), GFP_KERNEL);
> +	if (unlikely(!p)) {

I don't think its usual to use unlikely to handle allocation errors
in the control plane. I'd remove it from here.

> +		if (ovr)
> +			tcf_idr_release(*a, bind);
> +		return -ENOMEM;
> +	}
>  
>  	v->tcf_action = parm->action;
>  
> -	spin_unlock_bh(&v->tcf_lock);
> +	p_old = rtnl_dereference(v->vlan_p);
> +
> +	p->tcfv_action = action;
> +	p->tcfv_push_vid = push_vid;
> +	p->tcfv_push_prio = push_prio;
> +	p->tcfv_push_proto = push_proto;
> +
> +	rcu_assign_pointer(v->vlan_p, p);
> +
> +	if (p_old)
> +		kfree_rcu(p_old, rcu);
>  
>  	if (ret == ACT_P_CREATED)
>  		tcf_idr_insert(tn, *a);
> @@ -208,25 +224,26 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
>  {
>  	unsigned char *b = skb_tail_pointer(skb);
>  	struct tcf_vlan *v = to_vlan(a);
> +	struct tcf_vlan_params *p = rtnl_dereference(v->vlan_p);
>  	struct tc_vlan opt = {
>  		.index    = v->tcf_index,
>  		.refcnt   = v->tcf_refcnt - ref,
>  		.bindcnt  = v->tcf_bindcnt - bind,
>  		.action   = v->tcf_action,
> -		.v_action = v->tcfv_action,
> +		.v_action = p->tcfv_action,
>  	};
>  	struct tcf_t t;
>  
>  	if (nla_put(skb, TCA_VLAN_PARMS, sizeof(opt), &opt))
>  		goto nla_put_failure;
>  
> -	if ((v->tcfv_action == TCA_VLAN_ACT_PUSH ||
> -	     v->tcfv_action == TCA_VLAN_ACT_MODIFY) &&
> -	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) ||
> +	if ((p->tcfv_action == TCA_VLAN_ACT_PUSH ||
> +	     p->tcfv_action == TCA_VLAN_ACT_MODIFY) &&
> +	    (nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, p->tcfv_push_vid) ||
>  	     nla_put_be16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL,
> -			  v->tcfv_push_proto) ||
> +			  p->tcfv_push_proto) ||
>  	     (nla_put_u8(skb, TCA_VLAN_PUSH_VLAN_PRIORITY,
> -					      v->tcfv_push_prio))))
> +					      p->tcfv_push_prio))))
>  		goto nla_put_failure;
>  
>  	tcf_tm_dump(&t, &v->tcf_tm);
> -- 
> 2.7.4
> 
