From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V2 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 24 Aug 2016 22:05:32 +0300
Message-ID: <20160824220532.57d2fe1b@halley>
References: <20160824122710.30356-1-amir@vadai.me>
        <20160824122710.30356-5-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32812 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755812AbcHXTFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:05:43 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so3939756wme.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:05:43 -0700 (PDT)
In-Reply-To: <20160824122710.30356-5-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 24 Aug 2016 15:27:10 +0300 Amir Vadai <amir@vadai.me> wrote:
> +config NET_ACT_TUNNEL_KEY
> +        tristate "IP tunnel metadata manipulation"
> +        depends on NET_CLS_ACT
> +        ---help---
> +	  Say Y here to set/release ip tunnel metadata.
> +
> +	  If unsure, say N.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called act_tunnel.

actually looks like it's called "act_tunnel_key" ;)

> +static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
> +			  struct tcf_result *res)
> +{
> +	struct tcf_tunnel_key *t = to_tunnel_key(a);
> +	int action;
> +
> +	spin_lock(&t->tcf_lock);
> +	tcf_lastuse_update(&t->tcf_tm);
> +	bstats_update(&t->tcf_bstats, skb);
> +	action = t->tcf_action;
> +
> +	switch (t->tcft_action) {
> +	case TCA_TUNNEL_KEY_ACT_RELEASE:
> +		skb_dst_set_noref(skb, NULL);
> +		break;
> +	case TCA_TUNNEL_KEY_ACT_SET:
> +		skb_dst_set_noref(skb, &t->tcft_enc_metadata->dst);
> +
> +		break;

nit: empty line unneeded here.

> +static int tunnel_key_init(struct net *net, struct nlattr *nla,
> +			   struct nlattr *est, struct tc_action **a,
> +			   int ovr, int bind)
> +{
> +	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
> +	struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
> +	struct metadata_dst *metadata = NULL;
> +	struct tc_tunnel_key *parm;
> +	struct tcf_tunnel_key *t;
> +	__be64 key_id;
> +	int encapdecap;
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
> +	encapdecap = parm->t_action;
> +
> +	switch (encapdecap) {

As we no longer have "encapdecap" actions, either rename or just use
parm->t_action explicitly (only needed twice).

> +static int tunnel_key_dump_addresses(struct sk_buff *skb,
> +				     const struct ip_tunnel_info *info)
> +{
> +	unsigned short family = ip_tunnel_info_af(info);
> +
> +	if (family == AF_INET) {
> +		__be32 saddr = info->key.u.ipv4.src;
> +		__be32 daddr = info->key.u.ipv4.dst;
> +
> +		if (!nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_IPV4_SRC, saddr) &&
> +		    !nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_IPV4_DST, daddr))
> +			return 0;
> +	}
> +
> +	if (family == AF_INET6) {
> +		struct in6_addr saddr6 = info->key.u.ipv6.src;
> +		struct in6_addr daddr6 = info->key.u.ipv6.dst;

Why the in6_addr copy? Point to the things, then pass the pointers to
nla_put_in6_addr().

Also, there are few lines too long.

Regards,
Shmulik
