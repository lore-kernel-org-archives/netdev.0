From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 10/10] net: sched: extend gact to allow jumping
 to another filter chain
Date: Fri, 28 Apr 2017 08:52:09 +0200
Message-ID: <20170428065209.GA1886@nanopsycho.orion>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <1493291540-2119-11-git-send-email-jiri@resnulli.us>
 <bedf1246-4900-ebba-cf78-936989029db9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        mlxsw@mellanox.com, simon.horman@netronome.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36190 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424088AbdD1GwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 02:52:12 -0400
Received: by mail-wm0-f68.google.com with SMTP id u65so8983864wmu.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 23:52:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bedf1246-4900-ebba-cf78-936989029db9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 03:41:08AM CEST, jhs@mojatatu.com wrote:
>
>Jiri,
>
>Good stuff!
>Thanks for the effort.
>
>I didnt review the details - will do. I wanted to raise one issue.
>This should work for all actions, not just gact (refer to the
>recent commit i made on the action jumping).
>
>Example policy for policer:
>
>#if packets destined for mac address 52:54:00:3d:c7:6d
>#exceed 90kbps with burst of 90K then jump to chain 11
>#for further classification, otherwise set their skb mark to 11
># and proceed.
>
>tc filter add dev eth0 parent ffff: protocol ip pref 33 \
>flower dst_mac 52:54:00:3d:c7:6d \
>action police rate 1kbit burst 90k conform-exceed pipe/goto chain 11 \
>action skbedit mark 11
>
>But i should also be able to do this for any other action, etc.
>
>For this to work, you have to be able to encode the action in the
>opcode. Something like (for 2^16 chains):
>
>#define TC_ACT_GOTO_CHAIN	0x20000000
>#define TCA_ACT_MAX_CHAIN_MASK 0xFFFF
>
>So 0x20000001 is encoding of chain 1 etc.
>
>I will post the iproute2 code i used for jumping of actions.

You can have multiple actions in list and gact goto as the last one. Why
to do this ugliness?


>
>cheers,
>jamal
>
>On 17-04-27 07:12 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Introduce new type of gact action called "goto_chain". This allows
>> user to specify a chain to be processed. This action type is
>> then processed as a return value in tcf_classify loop in similar
>> way as "reclassify" is, only it does not reset to the first filter
>> in chain but rather reset to the first filter of the desired chain.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/sch_generic.h           |  9 +++++--
>>  include/net/tc_act/tc_gact.h        |  2 ++
>>  include/uapi/linux/pkt_cls.h        |  1 +
>>  include/uapi/linux/tc_act/tc_gact.h |  1 +
>>  net/sched/act_gact.c                | 48 ++++++++++++++++++++++++++++++++++++-
>>  net/sched/cls_api.c                 |  8 +++++--
>>  6 files changed, 64 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index 569b565..3688501 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -193,8 +193,13 @@ struct Qdisc_ops {
>> 
>> 
>>  struct tcf_result {
>> -	unsigned long	class;
>> -	u32		classid;
>> +	union {
>> +		struct {
>> +			unsigned long	class;
>> +			u32		classid;
>> +		};
>> +		const struct tcf_proto *goto_tp;
>> +	};
>>  };
>> 
>>  struct tcf_proto_ops {
>> diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
>> index b6f1739..58bee54 100644
>> --- a/include/net/tc_act/tc_gact.h
>> +++ b/include/net/tc_act/tc_gact.h
>> @@ -12,6 +12,8 @@ struct tcf_gact {
>>  	int			tcfg_paction;
>>  	atomic_t		packets;
>>  #endif
>> +	struct tcf_chain	*goto_chain;
>> +	struct rcu_head		rcu;
>>  };
>>  #define to_gact(a) ((struct tcf_gact *)a)
>> 
>> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>> index f1129e3..e03ba27 100644
>> --- a/include/uapi/linux/pkt_cls.h
>> +++ b/include/uapi/linux/pkt_cls.h
>> @@ -37,6 +37,7 @@ enum {
>>  #define TC_ACT_QUEUED		5
>>  #define TC_ACT_REPEAT		6
>>  #define TC_ACT_REDIRECT		7
>> +#define TC_ACT_GOTO_CHAIN	8
>>  #define TC_ACT_JUMP		0x10000000
>> 
>>  /* Action type identifiers*/
>> diff --git a/include/uapi/linux/tc_act/tc_gact.h b/include/uapi/linux/tc_act/tc_gact.h
>> index 70b536a..388733d 100644
>> --- a/include/uapi/linux/tc_act/tc_gact.h
>> +++ b/include/uapi/linux/tc_act/tc_gact.h
>> @@ -26,6 +26,7 @@ enum {
>>  	TCA_GACT_PARMS,
>>  	TCA_GACT_PROB,
>>  	TCA_GACT_PAD,
>> +	TCA_GACT_CHAIN,
>>  	__TCA_GACT_MAX
>>  };
>>  #define TCA_GACT_MAX (__TCA_GACT_MAX - 1)
>> diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
>> index c527c11..d63aebd 100644
>> --- a/net/sched/act_gact.c
>> +++ b/net/sched/act_gact.c
>> @@ -20,6 +20,7 @@
>>  #include <linux/init.h>
>>  #include <net/netlink.h>
>>  #include <net/pkt_sched.h>
>> +#include <net/pkt_cls.h>
>>  #include <linux/tc_act/tc_gact.h>
>>  #include <net/tc_act/tc_gact.h>
>> 
>> @@ -54,6 +55,7 @@ static g_rand gact_rand[MAX_RAND] = { NULL, gact_net_rand, gact_determ };
>>  static const struct nla_policy gact_policy[TCA_GACT_MAX + 1] = {
>>  	[TCA_GACT_PARMS]	= { .len = sizeof(struct tc_gact) },
>>  	[TCA_GACT_PROB]		= { .len = sizeof(struct tc_gact_p) },
>> +	[TCA_GACT_CHAIN]	= { .type = NLA_U32 },
>>  };
>> 
>>  static int tcf_gact_init(struct net *net, struct tcf_proto *tp,
>> @@ -92,6 +94,9 @@ static int tcf_gact_init(struct net *net, struct tcf_proto *tp,
>>  	}
>>  #endif
>> 
>> +	if (parm->action == TC_ACT_GOTO_CHAIN && !tb[TCA_GACT_CHAIN])
>> +		return -EINVAL;
>> +
>>  	if (!tcf_hash_check(tn, parm->index, a, bind)) {
>>  		ret = tcf_hash_create(tn, parm->index, est, a,
>>  				      &act_gact_ops, bind, true);
>> @@ -121,11 +126,43 @@ static int tcf_gact_init(struct net *net, struct tcf_proto *tp,
>>  		gact->tcfg_ptype   = p_parm->ptype;
>>  	}
>>  #endif
>> +
>> +	if (gact->tcf_action == TC_ACT_GOTO_CHAIN) {
>> +		u32 chain_index = nla_get_u32(tb[TCA_GACT_CHAIN]);
>> +
>> +		if (!tp) {
>> +			if (ret == ACT_P_CREATED)
>> +				tcf_hash_release(*a, bind);
>> +			return -EINVAL;
>> +		}
>> +		gact->goto_chain = tcf_chain_get(tp->chain->block, chain_index);
>> +		if (!gact->goto_chain) {
>> +			if (ret == ACT_P_CREATED)
>> +				tcf_hash_release(*a, bind);
>> +			return -ENOMEM;
>> +		}
>> +	}
>> +
>>  	if (ret == ACT_P_CREATED)
>>  		tcf_hash_insert(tn, *a);
>>  	return ret;
>>  }
>> 
>> +static void tcf_gact_cleanup_rcu(struct rcu_head *rcu)
>> +{
>> +	struct tcf_gact *gact = container_of(rcu, struct tcf_gact, rcu);
>> +
>> +	if (gact->tcf_action == TC_ACT_GOTO_CHAIN)
>> +		tcf_chain_put(gact->goto_chain);
>> +}
>> +
>> +static void tcf_gact_cleanup(struct tc_action *a, int bind)
>> +{
>> +	struct tcf_gact *gact = to_gact(a);
>> +
>> +	call_rcu(&gact->rcu, tcf_gact_cleanup_rcu);
>> +}
>> +
>>  static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
>>  		    struct tcf_result *res)
>>  {
>> @@ -141,8 +178,13 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
>>  	}
>>  #endif
>>  	bstats_cpu_update(this_cpu_ptr(gact->common.cpu_bstats), skb);
>> -	if (action == TC_ACT_SHOT)
>> +	if (action == TC_ACT_SHOT) {
>>  		qstats_drop_inc(this_cpu_ptr(gact->common.cpu_qstats));
>> +	} else if (action == TC_ACT_GOTO_CHAIN) {
>> +		struct tcf_chain *chain = gact->goto_chain;
>> +
>> +		res->goto_tp = rcu_dereference_bh(chain->filter_chain);
>> +	}
>> 
>>  	tcf_lastuse_update(&gact->tcf_tm);
>> 
>> @@ -194,6 +236,9 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a,
>>  	tcf_tm_dump(&t, &gact->tcf_tm);
>>  	if (nla_put_64bit(skb, TCA_GACT_TM, sizeof(t), &t, TCA_GACT_PAD))
>>  		goto nla_put_failure;
>> +	if (gact->tcf_action == TC_ACT_GOTO_CHAIN &&
>> +	    nla_put_u32(skb, TCA_GACT_CHAIN, gact->goto_chain->index))
>> +		goto nla_put_failure;
>>  	return skb->len;
>> 
>>  nla_put_failure:
>> @@ -225,6 +270,7 @@ static struct tc_action_ops act_gact_ops = {
>>  	.stats_update	=	tcf_gact_stats_update,
>>  	.dump		=	tcf_gact_dump,
>>  	.init		=	tcf_gact_init,
>> +	.cleanup	=	tcf_gact_cleanup,
>>  	.walk		=	tcf_gact_walker,
>>  	.lookup		=	tcf_gact_search,
>>  	.size		=	sizeof(struct tcf_gact),
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index dbc1348..a2d6bc7 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -304,10 +304,14 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>>  			continue;
>> 
>>  		err = tp->classify(skb, tp, res);
>> -		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode))
>> +		if (err == TC_ACT_RECLASSIFY && !compat_mode) {
>>  			goto reset;
>> -		if (err >= 0)
>> +		} else if (err == TC_ACT_GOTO_CHAIN) {
>> +			old_tp = res->goto_tp;
>> +			goto reset;
>> +		} else if (err >= 0) {
>>  			return err;
>> +		}
>>  	}
>> 
>>  	return TC_ACT_UNSPEC; /* signal: continue lookup */
>> 
>
