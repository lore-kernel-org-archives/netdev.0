From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V7 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 8 Sep 2016 09:15:35 -0700
Message-ID: <57D18EA7.7000709@gmail.com>
References: <1473341028-29368-1-git-send-email-hadarh@mellanox.com>
 <1473341028-29368-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36453 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757680AbcIHQP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 12:15:56 -0400
Received: by mail-pf0-f195.google.com with SMTP id x24so2692133pfa.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 09:15:55 -0700 (PDT)
In-Reply-To: <1473341028-29368-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-08 06:23 AM, Hadar Hen Zion wrote:
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
> 
> $ tc filter add dev net0 protocol ip parent ffff: \
>     flower \
>       ip_proto 1 \
>       dst_ip 11.11.11.2 \
>     action tunnel_key set \
>       src_ip 11.11.0.1 \
>       dst_ip 11.11.0.2 \
>       id 11 \
>     action mirred egress redirect dev vxlan0
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---

[...]

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
> +	kfree_rcu(params, rcu);
> +
> +	rcu_read_unlock();
> +}
> +

Same comment as Eric, you better own the action or else this could
race.

> +
> +static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
> +			   int bind, int ref)
> +{
> +	unsigned char *b = skb_tail_pointer(skb);
> +	struct tcf_tunnel_key *t = to_tunnel_key(a);
> +	struct tcf_tunnel_key_params *params;
> +	struct tc_tunnel_key opt = {
> +		.index    = t->tcf_index,
> +		.refcnt   = t->tcf_refcnt - ref,
> +		.bindcnt  = t->tcf_bindcnt - bind,
> +	};
> +	struct tcf_t tm;
> +	int ret = -1;
> +
> +	rcu_read_lock();
> +	params = rcu_dereference(t->params);

This should be rtnl_derefence(t->params) and drop the read_lock/unlock
pair. This is always called with RTNL lock unless you have a path I'm
not seeing.


> +
> +	opt.t_action = params->tcft_action;
> +	opt.action = params->action;
> +
> +	if (nla_put(skb, TCA_TUNNEL_KEY_PARMS, sizeof(opt), &opt))
> +		goto nla_put_failure;
> +
> +	if (params->tcft_action == TCA_TUNNEL_KEY_ACT_SET) {
> +		struct ip_tunnel_key *key =
> +			&params->tcft_enc_metadata->u.tun_info.key;
> +		__be32 key_id = tunnel_id_to_key32(key->tun_id);
> +
> +		if (nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_KEY_ID, key_id) ||
> +		    tunnel_key_dump_addresses(skb,
> +					      &params->tcft_enc_metadata->u.tun_info))
> +			goto nla_put_failure;
> +	}
> +
> +	tcf_tm_dump(&tm, &t->tcf_tm);
> +	if (nla_put_64bit(skb, TCA_TUNNEL_KEY_TM, sizeof(tm),
> +			  &tm, TCA_TUNNEL_KEY_PAD))
> +		goto nla_put_failure;
> +
> +	ret = skb->len;
> +	goto out;
> +
> +nla_put_failure:
> +	nlmsg_trim(skb, b);
> +out:
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +

I don't really care if you roll the above two rcu cleanups on top of
the patch as a follow up or roll a v8. But I think we should get the
annotation right here so its clear later.

.John
