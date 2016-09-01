From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V4 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 1 Sep 2016 12:28:40 +0300
Message-ID: <CAJL1qvE7Tpv0vmg6yRz7+Xh2T3rpqUvHshazK-N_6w2P-iv1hw@mail.gmail.com>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
 <1472647584-6713-5-git-send-email-hadarh@mellanox.com> <CANn89i+ZnnJrLeSXadgDxWWT6q1Y+gPVoK8EJ417AzNfFKLQ+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34762 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbcIAJ2l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 05:28:41 -0400
Received: by mail-oi0-f68.google.com with SMTP id t127so7294729oie.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 02:28:41 -0700 (PDT)
In-Reply-To: <CANn89i+ZnnJrLeSXadgDxWWT6q1Y+gPVoK8EJ417AzNfFKLQ+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 9:39 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, Aug 31, 2016 at 5:46 AM, Hadar Hen Zion <hadarh@mellanox.com> wrote:
>>
>> From: Amir Vadai <amir@vadai.me>
>>
>> This action could be used before redirecting packets to a shared tunnel
>> device, or when redirecting packets arriving from a such a device.
>>
>>
>> +
>> +struct tcf_tunnel_key_params {
>> +       struct rcu_head         rcu;
>> +       int                     tcft_action;
>
> Also add " int action;"
>
> (see why later)
>
>> +       struct metadata_dst     *tcft_enc_metadata;
>> +};
>> +
>
>
>
>> +
>> +static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
>> +                         struct tcf_result *res)
>> +{
>> +       struct tcf_tunnel_key *t = to_tunnel_key(a);
>> +       struct tcf_tunnel_key_params *params;
>> +       int action;
>> +
>> +       rcu_read_lock();
>> +
>> +       params = rcu_dereference(t->params);
>> +
>> +       tcf_lastuse_update(&t->tcf_tm);
>> +       bstats_cpu_update(this_cpu_ptr(t->common.cpu_bstats), skb);
>> +       action = t->tcf_action;
>
> Ideally, you should read param->action instead of t->tcf_action to be
> completely clean.

As you suggested above, I can do it by adding "int action" to struct
tcf_tunnel_key_paramse.
But, it means that act_tunnel_key would have a different behavior than
all the other actions and even though
"struct tc_action" has a designated parameters to store this action we
won't use it.
So it won't be completely clean...

Do you think we have a cleaner way to protect it?

>
>> +
>> +       switch (params->tcft_action) {
>> +       case TCA_TUNNEL_KEY_ACT_RELEASE:
>> +               skb_dst_drop(skb);
>> +               break;
>> +       case TCA_TUNNEL_KEY_ACT_SET:
>> +               skb_dst_drop(skb);
>> +               skb_dst_set(skb, dst_clone(&params->tcft_enc_metadata->dst));
>> +               break;
>> +       default:
>> +               WARN_ONCE(1, "Bad tunnel_key action.\n");
>> +               break;
>> +       }
>> +
>> +       rcu_read_unlock();
>> +
>> +       return action;
>> +}
>>
