From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 25 Aug 2016 10:48:54 -0700
Message-ID: <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
         <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35722 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754276AbcHYRs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 13:48:57 -0400
Received: by mail-pa0-f45.google.com with SMTP id hb8so18878845pac.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 10:48:56 -0700 (PDT)
In-Reply-To: <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 19:13 +0300, Hadar Hen Zion wrote:
> From: Amir Vadai <amir@vadai.me>
> 
> This action could be used before redirecting packets to a shared tunnel
> device, or when redirecting packets arriving from a such a device.
> 
> The action will release the metadata created by the tunnel device
> (decap), or set the metadata with the specified values for encap
> operation.
> 
> For example, the following flower filter will forward all ICMP packets
> destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
> redirecting, a metadata for the vxlan tunnel is created using the
> tunnel_key action and it's arguments:

....

> +
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
> +		break;
> +	default:
> +		WARN_ONCE(1, "Bad tunnel_key action.\n");
> +		break;
> +	}
> +
> +	spin_unlock(&t->tcf_lock);
> +	return action;


Please find a better way than using a spinlock in this hot path.

Maybe looking at 
2ee22a90c7afac265bb6f7abea610b938195e2b8 net_sched: act_mirred: remove spinlock in fast path
56e5d1ca183d8616fab377d7d466c244b4dbb3b9 net_sched: act_gact: remove spinlock in fast path
8f2ae965b7ef4f4ddab6110f06388e270723d694 net_sched: act_gact: read tcfg_ptype once
cc6510a9504fd3c03d76bd68d99653148342eecc net_sched: act_gact: use a separate packet counters for gact_determ()
cef5ecf96b28dc91c4e9f398a336c578fb9e1a0c net_sched: act_gact: make tcfg_pval non zero
519c818e8fb646eef1e8bfedd18519bec47bc9a9 net: sched: add percpu stats to actions
