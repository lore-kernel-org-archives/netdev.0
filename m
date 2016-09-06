From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 6 Sep 2016 14:03:13 +0300
Message-ID: <CAJL1qvEP7NOMr1xGr1LkUDi9K96P+ZzU2m5D1q=uZMC-AyrKSw@mail.gmail.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
 <1472986555-14949-5-git-send-email-hadarh@mellanox.com> <b6d6b736-bc45-3216-6109-0b67a54fb704@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36162 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932400AbcIFLDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 07:03:21 -0400
Received: by mail-oi0-f66.google.com with SMTP id u131so4768811oif.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 04:03:14 -0700 (PDT)
In-Reply-To: <b6d6b736-bc45-3216-6109-0b67a54fb704@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 1:49 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-04 06:55 AM, Hadar Hen Zion wrote:
>>
>> From: Amir Vadai <amir@vadai.me>
>>
>> This action could be used before redirecting packets to a shared tunnel
>> device, or when redirecting packets arriving from a such a device.
>>
>> The action will release the metadata created by the tunnel device
>> (decap), or set the metadata with the specified values for encap
>> operation.
>>
>> For example, the following flower filter will forward all ICMP packets
>> destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
>> redirecting, a metadata for the vxlan tunnel is created using the
>> tunnel_key action and it's arguments:
>>
>> $ filter add dev net0 protocol ip parent ffff: \
>>     flower \
>>       ip_proto 1 \
>>       dst_ip 11.11.11.2 \
>>     action tunnel_key set \
>>       src_ip 11.11.0.1 \
>>       dst_ip 11.11.0.2 \
>>       id 11 \
>>     action mirred egress redirect dev vxlan0
>>
>
>
> Syntax error above. Regardless:

ack, will be fixed.

> Please verify by running a test and send a packet or two
> and verify that stats are incremented (I know it may sound silly to
> ask but it is important).

Already tested that tc filter stats are working and incremented as expected :-)
.
>
>
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
>> +       action = params->action;
>> +
>> +       switch (params->tcft_action) {
>> +       case TCA_TUNNEL_KEY_ACT_RELEASE:
>> +               skb_dst_drop(skb);
>> +               break;
>> +       case TCA_TUNNEL_KEY_ACT_SET:
>> +               skb_dst_drop(skb);
>> +               skb_dst_set(skb,
>> dst_clone(&params->tcft_enc_metadata->dst));
>> +               break;
>> +       default:
>> +               WARN_ONCE(1, "Bad tunnel_key action.\n");
>> +               break;
>
>
>
> slow path (_init()) is already checking for a bad tcft_act so it seems
> unnecessary to have the default.
> If you have to keep default would be useful to print the value as well.

ack.

>
> Other than that looks good.
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> cheers,
> jamal
