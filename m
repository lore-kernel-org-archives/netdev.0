From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V7 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 08 Sep 2016 07:19:12 -0700
Message-ID: <1473344352.15733.46.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473341028-29368-1-git-send-email-hadarh@mellanox.com>
         <1473341028-29368-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33749 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758272AbcIHOTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 10:19:19 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so2587111pfb.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 07:19:19 -0700 (PDT)
In-Reply-To: <1473341028-29368-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 16:23 +0300, Hadar Hen Zion wrote:
> From: Amir Vadai <amir@vadai.me>
> 
> This action could be used before redirecting packets to a shared tunnel
> device, or when redirecting packets arriving from a such a device.


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

Note that you own the action here, so technically speaking no writer
could possibly modify t->params while this function is running.

So you could use 

params = rcu_dereference_protected(t->params, 1)

(I could not find a way to express the 'I own this action and am the
last user' for LOCKDEP sake so I used 1)

instead of

rcu_read_lock();
params = rcu_dereference(t->params);
rcu_read_unlock();


But this is a very minor detail, and this patch looks fine to me, thanks
a lot for your patience Hadar .

Acked-by: Eric Dumazet <edumazet@google.com>
