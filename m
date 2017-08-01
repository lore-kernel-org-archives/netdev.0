From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/6] [net-next]net: sched: act_mirred: Extend redirect
 action to accept a traffic class
Date: Tue, 1 Aug 2017 06:44:46 -0400
Message-ID: <7f2d3255-ecb1-0252-1066-4ac1ed7c79eb@mojatatu.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154785793.4135.15194023552358061083.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36956 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdHAKot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:44:49 -0400
Received: by mail-it0-f66.google.com with SMTP id 77so1307340itj.4
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 03:44:49 -0700 (PDT)
In-Reply-To: <150154785793.4135.15194023552358061083.stgit@anamdev.jf.intel.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 08:37 PM, Amritha Nambiar wrote:
> The Mirred/redirect action is extended to forward to a traffic
> class on the device. The traffic class index needs to be
> provided in addition to the device's ifindex.
> 
> Example:
> # tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>    dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>    skip_sw indev eth0 action mirred ingress redirect dev eth0 tc 1
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> ---
>   include/net/tc_act/tc_mirred.h        |    7 +++++++
>   include/uapi/linux/tc_act/tc_mirred.h |    5 +++++
>   net/sched/act_mirred.c                |   17 +++++++++++++++++
>   3 files changed, 29 insertions(+)
> 
> diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
> index 604bc31..60058c4 100644
> --- a/include/net/tc_act/tc_mirred.h
> +++ b/include/net/tc_act/tc_mirred.h
> @@ -9,6 +9,8 @@ struct tcf_mirred {
>   	int			tcfm_eaction;
>   	int			tcfm_ifindex;
>   	bool			tcfm_mac_header_xmit;
> +	u8			tcfm_tc;
> +	u32			flags;
>   	struct net_device __rcu	*tcfm_dev;
>   	struct list_head	tcfm_list;
>   };
> @@ -37,4 +39,9 @@ static inline int tcf_mirred_ifindex(const struct tc_action *a)
>   	return to_mirred(a)->tcfm_ifindex;
>   }
>   
> +static inline int tcf_mirred_tc(const struct tc_action *a)
> +{
> +	return to_mirred(a)->tcfm_tc;
> +}
> +
>   #endif /* __NET_TC_MIR_H */
> diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
> index 3d7a2b3..8ff4d76 100644
> --- a/include/uapi/linux/tc_act/tc_mirred.h
> +++ b/include/uapi/linux/tc_act/tc_mirred.h
> @@ -9,6 +9,10 @@
>   #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
>   #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
>   #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
> +
> +#define MIRRED_F_TC_MAP		0x1
> +#define MIRRED_TC_MAP_MAX	0x10
> +#define MIRRED_TC_MAP_MASK	0xF
>                                                                                   
>   struct tc_mirred {
>   	tc_gen;
> @@ -21,6 +25,7 @@ enum {
>   	TCA_MIRRED_TM,
>   	TCA_MIRRED_PARMS,
>   	TCA_MIRRED_PAD,
> +	TCA_MIRRED_TC_MAP,
>   	__TCA_MIRRED_MAX
>   };
>   #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 1b5549a..f9801de 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -67,6 +67,7 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
>   
>   static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
>   	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
> +	[TCA_MIRRED_TC_MAP]	= { .type = NLA_U8 },
>   };
>   
>   static unsigned int mirred_net_id;
> @@ -83,6 +84,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   	struct tcf_mirred *m;
>   	struct net_device *dev;
>   	bool exists = false;
> +	u8 *tc_map = NULL;
> +	u32 flags = 0;
>   	int ret;
>   
>   	if (nla == NULL)
> @@ -92,6 +95,14 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   		return ret;
>   	if (tb[TCA_MIRRED_PARMS] == NULL)
>   		return -EINVAL;
> +
> +	if (tb[TCA_MIRRED_TC_MAP]) {
> +		tc_map = nla_data(tb[TCA_MIRRED_TC_MAP]);
> +		if (*tc_map >= MIRRED_TC_MAP_MAX)
> +			return -EINVAL;
> +		flags |= MIRRED_F_TC_MAP;


> +	}
> +
>   	parm = nla_data(tb[TCA_MIRRED_PARMS]);
>   
>   	exists = tcf_hash_check(tn, parm->index, a, bind);
> @@ -139,6 +150,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   	ASSERT_RTNL();
>   	m->tcf_action = parm->action;
>   	m->tcfm_eaction = parm->eaction;
> +	m->flags = flags;
>   	if (dev != NULL) {
>   		m->tcfm_ifindex = parm->ifindex;
>   		if (ret != ACT_P_CREATED)
> @@ -146,6 +158,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
>   		dev_hold(dev);
>   		rcu_assign_pointer(m->tcfm_dev, dev);
>   		m->tcfm_mac_header_xmit = mac_header_xmit;
> +		if (flags & MIRRED_F_TC_MAP)
> +			m->tcfm_tc = *tc_map & MIRRED_TC_MAP_MASK;
>   	}
>   
Is the mask a hardware limit. I dont know how these queues are
allocated - I am assuming each of these "tc queues" maps to a rx
DMA ring?

>   	if (ret == ACT_P_CREATED) {
> @@ -259,6 +273,9 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
>   
>   	if (nla_put(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt))
>   		goto nla_put_failure;
> +	if ((m->flags & MIRRED_F_TC_MAP) &&
> +	    nla_put_u8(skb, TCA_MIRRED_TC_MAP, m->tcfm_tc))
> +		goto nla_put_failure;
>

If you have m->tcfm_tc then I dont think you need the flags; so i would
remove it from the struct altogether.

cheers,
jamal
