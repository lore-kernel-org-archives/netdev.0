From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/2] net sched act_vlan: VLAN action rewrite to
 use RCU lock/unlock and update
Date: Wed, 11 Oct 2017 09:27:07 -0700
Message-ID: <CAM_iQpUYGUzvvM3Weaw5ertgVpwn0p9j6B5xd5Ar5ysJwrdVvg@mail.gmail.com>
References: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>, manish.kurup@verizon.com
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 7:33 PM, Manish Kurup <kurup.manish@gmail.com> wrote:
> diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
> index 14c262c..9bb0236 100644
> --- a/net/sched/act_vlan.c
> +++ b/net/sched/act_vlan.c
> @@ -29,31 +29,37 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>         int action;
>         int err;
>         u16 tci;
> +       struct tcf_vlan_params *p;
>
>         tcf_lastuse_update(&v->tcf_tm);
>         bstats_cpu_update(this_cpu_ptr(v->common.cpu_bstats), skb);
>
> -       spin_lock(&v->tcf_lock);
> -       action = v->tcf_action;
> -

spin_lock() is removed here, see below.


>         /* Ensure 'data' points at mac_header prior calling vlan manipulating
>          * functions.
>          */
>         if (skb_at_tc_ingress(skb))
>                 skb_push_rcsum(skb, skb->mac_len);
>
> -       switch (v->tcfv_action) {
> +       rcu_read_lock();
> +
> +       action = READ_ONCE(v->tcf_action);
> +
> +       p = rcu_dereference(v->vlan_p);
> +
> +       switch (p->tcfv_action) {
>         case TCA_VLAN_ACT_POP:
>                 err = skb_vlan_pop(skb);
>                 if (err)
>                         goto drop;
>                 break;
> +
>         case TCA_VLAN_ACT_PUSH:
> -               err = skb_vlan_push(skb, v->tcfv_push_proto, v->tcfv_push_vid |
> -                                   (v->tcfv_push_prio << VLAN_PRIO_SHIFT));
> +               err = skb_vlan_push(skb, p->tcfv_push_proto, p->tcfv_push_vid |
> +                               (p->tcfv_push_prio << VLAN_PRIO_SHIFT));
>                 if (err)
>                         goto drop;
>                 break;
> +
>         case TCA_VLAN_ACT_MODIFY:
>                 /* No-op if no vlan tag (either hw-accel or in-payload) */
>                 if (!skb_vlan_tagged(skb))
> @@ -69,15 +75,16 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>                                 goto drop;
>                 }
>                 /* replace the vid */
> -               tci = (tci & ~VLAN_VID_MASK) | v->tcfv_push_vid;
> +               tci = (tci & ~VLAN_VID_MASK) | p->tcfv_push_vid;
>                 /* replace prio bits, if tcfv_push_prio specified */
> -               if (v->tcfv_push_prio) {
> +               if (p->tcfv_push_prio) {
>                         tci &= ~VLAN_PRIO_MASK;
> -                       tci |= v->tcfv_push_prio << VLAN_PRIO_SHIFT;
> +                       tci |= p->tcfv_push_prio << VLAN_PRIO_SHIFT;
>                 }
>                 /* put updated tci as hwaccel tag */
> -               __vlan_hwaccel_put_tag(skb, v->tcfv_push_proto, tci);
> +               __vlan_hwaccel_put_tag(skb, p->tcfv_push_proto, tci);
>                 break;
> +
>         default:
>                 BUG();
>         }
> @@ -89,6 +96,7 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>         qstats_drop_inc(this_cpu_ptr(v->common.cpu_qstats));
>
>  unlock:
> +       rcu_read_unlock();
>         if (skb_at_tc_ingress(skb))
>                 skb_pull_rcsum(skb, skb->mac_len);
>


But here spin_unlock() is not removed... At least it doesn't show in diff
context. It's probably unbalanced spinlock.


> @@ -111,6 +119,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>         struct nlattr *tb[TCA_VLAN_MAX + 1];
>         struct tc_vlan *parm;
>         struct tcf_vlan *v;
> +       struct tcf_vlan_params *p, *p_old;
>         int action;
>         __be16 push_vid = 0;
>         __be16 push_proto = 0;
> @@ -187,16 +196,33 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>
>         v = to_vlan(*a);
>
> -       spin_lock_bh(&v->tcf_lock);
> -
> -       v->tcfv_action = action;
> -       v->tcfv_push_vid = push_vid;
> -       v->tcfv_push_prio = push_prio;
> -       v->tcfv_push_proto = push_proto;
> +       ASSERT_RTNL();
> +       p = kzalloc(sizeof(*p), GFP_KERNEL);
> +       if (unlikely(!p)) {
> +               if (ovr)
> +                       tcf_idr_release(*a, bind);
> +               return -ENOMEM;
> +       }
>
>         v->tcf_action = parm->action;
>
> -       spin_unlock_bh(&v->tcf_lock);
> +       p_old = rtnl_dereference(v->vlan_p);
> +
> +       if (ovr)
> +               spin_lock_bh(&v->tcf_lock);

Why still take spinlock when you already have RTNL lock?
What's the point?
