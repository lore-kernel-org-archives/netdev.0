From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 31 Aug 2016 20:44:56 +0300
Message-ID: <20160831204456.46210aa2@halley>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
        <1472647584-6713-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36766 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161191AbcHaRpP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:45:15 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so8599066wmf.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:45:14 -0700 (PDT)
In-Reply-To: <1472647584-6713-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 31 Aug 2016 15:46:24 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
> +static int tunnel_key_init(struct net *net, struct nlattr *nla,
> +			   struct nlattr *est, struct tc_action **a,
> +			   int ovr, int bind)
> +{
> +	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
> +	struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
> +	struct metadata_dst *metadata = NULL;
> +	struct tc_tunnel_key *parm;
> +	struct tcf_tunnel_key *t;
> +	struct tcf_tunnel_key_params *params_old;
> +	struct tcf_tunnel_key_params *params_new;
> +	__be64 key_id;
> +	bool exists = false;
> +	int ret = 0;
> +	int err;
> +
> +	if (!nla)
> +		return -EINVAL;
> +
> +	err = nla_parse_nested(tb, TCA_TUNNEL_KEY_MAX, nla, tunnel_key_policy);
> +	if (err < 0)
> +		return err;
> +
> +	if (!tb[TCA_TUNNEL_KEY_PARMS])
> +		return -EINVAL;
> +
> +	parm = nla_data(tb[TCA_TUNNEL_KEY_PARMS]);
> +	exists = tcf_hash_check(tn, parm->index, a, bind);
> +	if (exists && bind)
> +		return 0;
> +
> +	switch (parm->t_action) {
> +	case TCA_TUNNEL_KEY_ACT_RELEASE:
> +		break;
> +	case TCA_TUNNEL_KEY_ACT_SET:
> +		if (!tb[TCA_TUNNEL_KEY_ENC_KEY_ID]) {
> +			ret = -EINVAL;
> +			goto err_out;
> +		}
> +
> +		key_id = key32_to_tunnel_id(nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_KEY_ID]));
> +
> +		if (tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC] &&
> +		    tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]) {
> +			__be32 saddr;
> +			__be32 daddr;
> +
> +			saddr = nla_get_in_addr(tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC]);
> +			daddr = nla_get_in_addr(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
> +
> +			metadata = __ip_tun_set_dst(saddr, daddr, 0, 0,
> +						    TUNNEL_KEY, key_id, 0);
> +		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
> +			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
> +			struct in6_addr saddr;
> +			struct in6_addr daddr;
> +
> +			saddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC]);
> +			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
> +
> +			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, 0,
> +						      TUNNEL_KEY, key_id, 0);
> +		}
> +
> +		if (!metadata) {
> +			ret = -EINVAL;
> +			goto err_out;
> +		}
> +
> +		metadata->u.tun_info.mode |= IP_TUNNEL_INFO_TX;
> +		break;
> +	default:
> +		goto err_out;
> +	}
> +
> +	if (!exists) {
> +		ret = tcf_hash_create(tn, parm->index, est, a,
> +				      &act_tunnel_key_ops, bind, true);
> +		if (ret)
> +			return ret;
> +
> +		ret = ACT_P_CREATED;
> +	} else {
> +		tcf_hash_release(*a, bind);
> +		if (!ovr)
> +			return -EEXIST;
> +	}
> +
> +	t = to_tunnel_key(*a);
> +
> +	ASSERT_RTNL();
> +	params_new = kzalloc(sizeof(*params_new),
> +			     GFP_KERNEL);

nit: Fits oneline. Fix if patch needs other amendments.

> +	if (unlikely(!params_new)) {
> +		if (ovr)
> +			tcf_hash_release(*a, bind);
> +		return -ENOMEM;

Seems we need to call tcf_hash_release regardless 'ovr':
In case (!exist), we've created a new hash few lines above.
Therefore in failure, don't we need a tcf_hash_release()?
Am I missing something?

> +	}
> +
> +	params_old = rtnl_dereference(t->params);
> +
> +	t->tcf_action = parm->action;
> +	params_new->tcft_action = parm->t_action;
> +	params_new->tcft_enc_metadata = metadata;
> +
> +	rcu_assign_pointer(t->params, params_new);
> +
> +	if (params_old)
> +		kfree_rcu(params_old, rcu);
> +
> +	if (ret == ACT_P_CREATED)
> +		tcf_hash_insert(tn, *a);
> +
> +	return ret;
> +
> +err_out:
> +	if (exists)
> +		tcf_hash_release(*a, bind);
> +	return ret;
> +}
> +
> +static void tunnel_key_release(struct tc_action *a, int bind)
> +{
> +	struct tcf_tunnel_key *t = to_tunnel_key(a);
> +	struct tcf_tunnel_key_params *params;
> +
> +	rcu_read_lock();
> +	params = rcu_dereference(t->params);
> +
> +	if (params->tcft_action == TCA_TUNNEL_KEY_ACT_SET)
> +		dst_release(&params->tcft_enc_metadata->dst);
> +
> +	rcu_read_unlock();

Not an RCU expert, maybe I'm off...
This alters params in some way (dst_release), so shouldn't it be
considered an UPDATE, involving 'params' replacement?
Current code declares it as an rcu read section.

Thanks,
Shmulik
