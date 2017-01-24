From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v6 1/1] net sched actions: Add support for user
 cookies
Date: Tue, 24 Jan 2017 06:09:23 -0500
Message-ID: <369a64ff-2fe1-0700-00f1-85159ba08cf0@mojatatu.com>
References: <1485116750-31198-1-git-send-email-jhs@emojatatu.com>
 <20170123125838.GD31958@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com, mrv@mojatatu.com,
        hadarh@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36053 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750753AbdAXLJe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 06:09:34 -0500
Received: by mail-qt0-f195.google.com with SMTP id l7so24295154qtd.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 03:09:34 -0800 (PST)
In-Reply-To: <20170123125838.GD31958@penelope.horms.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-23 07:58 AM, Simon Horman wrote:
> Hi Jamal,
>
> On Sun, Jan 22, 2017 at 03:25:50PM -0500, Jamal Hadi Salim wrote:
>
> ...
>

>> @@ -33,6 +34,8 @@ static void free_tcf(struct rcu_head *head)
>>
>>  	free_percpu(p->cpu_bstats);
>>  	free_percpu(p->cpu_qstats);
>> +	kfree(p->act_cookie->data);
>
> Does the above need to be protected by a check for p->act_cookie being non-NULL?
>

Indeed it does.

>> +	kfree(p->act_cookie);
>>  	kfree(p);
>>  }
>>
>
> ...
>
>> @@ -575,6 +584,33 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>>  	if (err < 0)
>>  		goto err_mod;
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

I will make the change.

Thanks Simon.

cheers,
jamal
