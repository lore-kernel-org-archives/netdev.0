From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Fri, 26 Aug 2016 13:13:32 +0200
Message-ID: <20160826131332.329c7c98@griffin>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
        <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753566AbcHZLNh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 07:13:37 -0400
In-Reply-To: <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Aug 2016 19:13:47 +0300, Hadar Hen Zion wrote:
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

You're leaking dst here.

> +	case TCA_TUNNEL_KEY_ACT_SET:
> +		skb_dst_set_noref(skb, &t->tcft_enc_metadata->dst);
> +		break;

And here, too. Also, what protects the tcft_enc_metadata->dst from
being freed if there's a skb queued and the action is removed? Seems
that tunnel_key_release just happily frees it. You probably need to
take a reference here.

> +		if (tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC] &&
> +		    tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]) {
> +			__be32 saddr;
> +			__be32 daddr;
> +
> +			saddr = nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC]);
> +			daddr = nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);

Use nla_get_in_addr, please.

> +	if (family == AF_INET) {
> +		__be32 saddr = info->key.u.ipv4.src;
> +		__be32 daddr = info->key.u.ipv4.dst;
> +
> +		if (!nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_IPV4_SRC, saddr) &&
> +		    !nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_IPV4_DST, daddr))

nla_put_in_addr

Thanks!

 Jiri
