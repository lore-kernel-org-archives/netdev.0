From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v6 1/1] net sched actions: Add support for user
 cookies
Date: Mon, 23 Jan 2017 17:18:47 +0100
Message-ID: <58862CE7.2080906@iogearbox.net>
References: <1485116750-31198-1-git-send-email-jhs@emojatatu.com> <20170123125838.GD31958@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com, mrv@mojatatu.com,
        hadarh@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        xiyou.wangcong@gmail.com
To: Simon Horman <simon.horman@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45785 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdAWQSw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:18:52 -0500
In-Reply-To: <20170123125838.GD31958@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2017 01:58 PM, Simon Horman wrote:
> Hi Jamal,
>
> On Sun, Jan 22, 2017 at 03:25:50PM -0500, Jamal Hadi Salim wrote:
>
> ...
>
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index cd08df9..58cf1c5 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -24,6 +24,7 @@
>>   #include <net/net_namespace.h>
>>   #include <net/sock.h>
>>   #include <net/sch_generic.h>
>> +#include <net/pkt_cls.h>
>>   #include <net/act_api.h>
>>   #include <net/netlink.h>
>>
>> @@ -33,6 +34,8 @@ static void free_tcf(struct rcu_head *head)
>>
>>   	free_percpu(p->cpu_bstats);
>>   	free_percpu(p->cpu_qstats);
>> +	kfree(p->act_cookie->data);
>
> Does the above need to be protected by a check for p->act_cookie being non-NULL?

Yep, that would be a NULL-deref. Why not just embedd tc_cookie as
suggested earlier, the struct is rather small anyway ...

>> +	kfree(p->act_cookie);
>>   	kfree(p);
>>   }
>>
>
> ...
>
>> @@ -575,6 +584,33 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>>   	if (err < 0)
>>   		goto err_mod;
>>
>> +	if (tb[TCA_ACT_COOKIE]) {
>> +		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
>> +
>> +		if (cklen > TC_COOKIE_MAX_SIZE) {
>> +			err = -EINVAL;
>> +			tcf_hash_release(a, bind);
>> +			goto err_mod;
>> +		}
>> +
>> +		a->act_cookie = kzalloc(sizeof(*a->act_cookie), GFP_KERNEL);
>> +		if (!a->act_cookie) {
>> +			err = -ENOMEM;
>> +			tcf_hash_release(a, bind);
>> +			goto err_mod;
>> +		}
>> +
>> +		a->act_cookie->data = nla_memdup(tb[TCA_ACT_COOKIE],
>> +						 GFP_KERNEL);
>> +		if (!a->act_cookie->data) {
>> +			err = -ENOMEM;
>> +			kfree(a->act_cookie);
>> +			tcf_hash_release(a, bind);
>> +			goto err_mod;
>> +		}
>> +		a->act_cookie->len = cklen;
>
> FWIW, the above looks correct but it also looks like the error handling
> could be done less verbosely if the logic was moved to a separate function.
>
>> +	}
>> +
>>   	/* module count goes up only when brand new policy is created
>>   	 * if it exists and is only bound to in a_o->init() then
>>   	 * ACT_P_CREATED is not returned (a zero is).
>> --
>> 1.9.1
>>
