From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net sched act_vlan: Change stats update to
 use per-core stats
Date: Wed, 11 Oct 2017 15:15:59 +0200
Message-ID: <20171011131559.GG2039@nanopsycho>
References: <1507689147-22941-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        aring@mojatatu.com, mrv@mojatatu.com, manish.kurup@verizon.com
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507689147-22941-1-git-send-email-manish.kurup@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Oct 11, 2017 at 04:32:27AM CEST, kurup.manish@gmail.com wrote:
>The VLAN action maintains one set of stats across all cores, and uses a
>spinlock to synchronize updates to it from the same. Changed this to use a
>per-CPU stats context instead.
>This change will result in better performance.
>
>Signed-off-by: Manish Kurup <manish.kurup@verizon.com>
>---
> net/sched/act_vlan.c | 10 ++++++----
> 1 file changed, 6 insertions(+), 4 deletions(-)
>
>diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
>index 16eb067..14c262c 100644
>--- a/net/sched/act_vlan.c
>+++ b/net/sched/act_vlan.c
>@@ -30,9 +30,10 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
> 	int err;
> 	u16 tci;
> 
>-	spin_lock(&v->tcf_lock);
> 	tcf_lastuse_update(&v->tcf_tm);
>-	bstats_update(&v->tcf_bstats, skb);
>+	bstats_cpu_update(this_cpu_ptr(v->common.cpu_bstats), skb);
>+
>+	spin_lock(&v->tcf_lock);
> 	action = v->tcf_action;
> 
> 	/* Ensure 'data' points at mac_header prior calling vlan manipulating
>@@ -85,7 +86,8 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
> 
> drop:
> 	action = TC_ACT_SHOT;
>-	v->tcf_qstats.drops++;
>+	qstats_drop_inc(this_cpu_ptr(v->common.cpu_qstats));
>+
> unlock:
> 	if (skb_at_tc_ingress(skb))
> 		skb_pull_rcsum(skb, skb->mac_len);
>@@ -172,7 +174,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
> 
> 	if (!exists) {
> 		ret = tcf_idr_create(tn, parm->index, est, a,
>-				     &act_vlan_ops, bind, false);
>+						&act_vlan_ops, bind, true);

Please fix this indent nit as pointed out by Jamal.

Feel free to add my tag:
Acked-by: Jiri Pirko <jiri@mellanox.com>


Thanks!
