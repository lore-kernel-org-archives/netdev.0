From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user
 cookies
Date: Tue, 17 Jan 2017 11:50:21 -0500
Message-ID: <bead2dc5-87a2-2fca-d50d-871f28be1d5b@mojatatu.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
 <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
 <587E2747.9000207@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33543 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751031AbdAQQuY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:50:24 -0500
Received: by mail-qt0-f196.google.com with SMTP id n13so22778229qtc.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:50:23 -0800 (PST)
In-Reply-To: <587E2747.9000207@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 09:16 AM, Daniel Borkmann wrote:
> On 01/17/2017 12:11 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Introduce optional 128-bit action cookie.
>> Like all other cookie schemes in the networking world (eg in protocols
>> like http or existing kernel fib protocol field, etc) the idea is to save
>> user state that when retrieved serves as a correlator. The kernel
>> _should not_ intepret it.  The user can store whatever they wish in the
>> 128 bits.
> [...]
>
> Since it looks like you need a v5 anyway, few comments below.
>
>>   include/net/act_api.h        |  1 +
>>   include/net/pkt_cls.h        |  8 ++++++++
>>   include/uapi/linux/pkt_cls.h |  3 +++
>>   net/sched/act_api.c          | 25 +++++++++++++++++++++++++
>>   4 files changed, 37 insertions(+)
>>
>> diff --git a/include/net/act_api.h b/include/net/act_api.h
>> index 1d71644..0692458 100644
>> --- a/include/net/act_api.h
>> +++ b/include/net/act_api.h
>> @@ -41,6 +41,7 @@ struct tc_action {
>>       struct rcu_head            tcfa_rcu;
>>       struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>>       struct gnet_stats_queue __percpu *cpu_qstats;
>> +    struct tc_cookie    *act_ck;
>
> Since we know anyway that this is part of struct tc_action, can't
> you just give this some real/readable name like ...
>
>   struct tc_cookie cookie;
>


Grep-ability.
I was worried about when the classifier adds its cookie it
would need to use something like cls_cookie etc.

> ... and then ...
>
>>   };
>>   #define tcf_head    common.tcfa_head
>>   #define tcf_index    common.tcfa_index
>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>> index f0a0514..e0bc7e8 100644
>> --- a/include/net/pkt_cls.h
>> +++ b/include/net/pkt_cls.h
>> @@ -515,4 +515,12 @@ struct tc_cls_bpf_offload {
>>       u32 gen_flags;
>>   };
>>
>> +
>> +/* This structure holds cookie structure that is passed from user
>> + * to the kernel for actions and classifiers
>> + */
>> +struct tc_cookie {
>> +    unsigned char ck[TC_COOKIE_MAX_SIZE];
>> +    unsigned char ck_len;
>
> ... embed and make this ...
>
> struct tc_cookie {
>     u8  *data;
>     u32  len;
> };
>

> as act->act_ck->ck_len is rather funky, compare that to act->cookie->len.
>
>> +};
>>   #endif
> [...]
>> @@ -575,6 +583,23 @@ struct tc_action *tcf_action_init_1(struct net
>> *net, struct nlattr *nla,
>>       if (err < 0)
>>           goto err_mod;
>>
>> +    if (tb[TCA_ACT_COOKIE]) {
>> +        if (nla_len(tb[TCA_ACT_COOKIE]) > TC_COOKIE_MAX_SIZE) {
>> +            err = -EINVAL;
>> +            goto err_mod;
>> +        }
>> +
>> +        a->act_ck = kzalloc(sizeof(*a->act_ck), GFP_KERNEL);
>> +        if (unlikely(!a->act_ck)) {
>> +            err = -ENOMEM;
>> +            goto err_mod;
>> +        }
>> +
>> +        memcpy(a->act_ck->ck, nla_data(tb[TCA_ACT_COOKIE]),
>> +               nla_len(tb[TCA_ACT_COOKIE]));
>> +        a->act_ck->ck_len = nla_len(tb[TCA_ACT_COOKIE]);
>
> Then you can also simplify all this and use nla_memdup() here for
> act->cookie->data.
>

I can do that if you feel strongly. I am dropping the first patch and
hope Dave just applies this first patch.

cheers,
jamal
