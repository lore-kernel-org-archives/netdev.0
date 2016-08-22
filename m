From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Mon, 22 Aug 2016 20:57:06 +0300
Message-ID: <20160822205706.4f5fb33e@halley>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-4-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34562 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753411AbcHVR5R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 13:57:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so14574676wma.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 10:57:16 -0700 (PDT)
In-Reply-To: <20160822143834.32422-4-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 22 Aug 2016 17:38:34 +0300 Amir Vadai <amir@vadai.me> wrote:
> +static struct metadata_dst *iptunnel_alloc(struct tcf_iptunnel *t,
> +					   __be32 saddr, __be32 daddr,
> +					   __be64 key_id)
> +{
> +	struct ip_tunnel_info *tun_info;
> +	struct metadata_dst *metadata;
> +
> +	metadata = metadata_dst_alloc(0, GFP_KERNEL);
> +	if (!metadata)
> +		return ERR_PTR(-ENOMEM);
> +
> +	tun_info = &metadata->u.tun_info;
> +	tun_info->mode = IP_TUNNEL_INFO_TX;
> 
> +	ip_tunnel_key_init(&tun_info->key, saddr, daddr, 0, 0, 0, 0, 0,
> +			   key_id, 0);

Seems key.tun_flags should be armed with TUNNEL_KEY.
This will make things work with GRE as well.
Pass it in the 'tun_flags' parameter.

> +
> +	return metadata;
> +}
> +
> +static int tcf_iptunnel_init(struct net *net, struct nlattr *nla,
> +			     struct nlattr *est, struct tc_action **a,
> +			     int ovr, int bind)
> +{
> +	struct tc_action_net *tn = net_generic(net, iptunnel_net_id);
> +	struct nlattr *tb[TCA_IPTUNNEL_MAX + 1];
> +	struct metadata_dst *metadata;
> +	struct tc_iptunnel *parm;
> +	struct tcf_iptunnel *t;
> +	__be32 saddr = 0;
> +	__be32 daddr = 0;
> +	__be64 key_id = 0;
> +	int encapdecap;
> +	bool exists = false;
> +	int ret = -EINVAL;
> +	int err;
> +
> +	if (!nla)
> +		return -EINVAL;
> +
> +	err = nla_parse_nested(tb, TCA_IPTUNNEL_MAX, nla, iptunnel_policy);
> +	if (err < 0)
> +		return err;
> +
> +	if (!tb[TCA_IPTUNNEL_PARMS])
> +		return -EINVAL;
> +	parm = nla_data(tb[TCA_IPTUNNEL_PARMS]);
> +	exists = tcf_hash_check(tn, parm->index, a, bind);
> +	if (exists && bind)
> +		return 0;
> +
> +	encapdecap = parm->t_action;
> +
> +	switch (encapdecap) {
> +	case TCA_IPTUNNEL_ACT_DECAP:
> +		break;
> +	case TCA_IPTUNNEL_ACT_ENCAP:
> +		if (tb[TCA_IPTUNNEL_ENC_IPV4_SRC])
> +			saddr = nla_get_be32(tb[TCA_IPTUNNEL_ENC_IPV4_SRC]);
> +		if (tb[TCA_IPTUNNEL_ENC_IPV4_DST])
> +			daddr = nla_get_be32(tb[TCA_IPTUNNEL_ENC_IPV4_DST]);
> +		if (tb[TCA_IPTUNNEL_ENC_KEY_ID])
> +			key_id = key32_to_tunnel_id(nla_get_be32(tb[TCA_IPTUNNEL_ENC_KEY_ID]));
> +
> +		if (!saddr || !daddr || !key_id) {

A zero tunnel ID is legit.

> +			ret = -EINVAL;
> +			goto err_out;
> +		}
> +
> +		metadata = iptunnel_alloc(t, saddr, daddr, key_id);
> +		if (IS_ERR(metadata)) {
> +			ret = PTR_ERR(metadata);
> +			goto err_out;
> +		}
> +
> +		break;
> +	default:
> +		goto err_out;
> +	}
> +
> +	if (!exists) {
> +		ret = tcf_hash_create(tn, parm->index, est, a,
> +				      &act_iptunnel_ops, bind, false);
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
> +	t = to_iptunnel(*a);
> +
> +	spin_lock_bh(&t->tcf_lock);
> +
> +	t->tcf_action = parm->action;
> +
> +	t->tcft_action = encapdecap;
> +	t->tcft_enc_metadata = metadata;

Although tcft_enc_metadata is not used in TCA_IPTUNNEL_ACT_DECAP, still
prefer to nullify it instead of initializing it to stack junk.

> +
> +	spin_unlock_bh(&t->tcf_lock);
> +
> +	if (ret == ACT_P_CREATED)
> +		tcf_hash_insert(tn, *a);
> +
> +	return ret;

In the (exists && ovr) case, 'ret' seems to be left as '-EINVAL' as was
initialized. Initialize 'ret' to zero instead.

> +
> +err_out:
> +	if (exists)
> +		tcf_hash_release(*a, bind);
> +	return ret;
> +}
> +
