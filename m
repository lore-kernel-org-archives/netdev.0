From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v4 12/16] net: sched: rcu'ify cls_bpf
Date: Fri, 12 Sep 2014 08:16:04 -0700
Message-ID: <54130E34.3050001@gmail.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>  <20140910155141.2036.66048.stgit@nitbit.x32> <1410402481.7106.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:41237 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbaILPQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 11:16:17 -0400
Received: by mail-ob0-f172.google.com with SMTP id wp18so669067obc.31
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 08:16:17 -0700 (PDT)
In-Reply-To: <1410402481.7106.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2014 07:28 PM, Eric Dumazet wrote:
> On Wed, 2014-09-10 at 08:51 -0700, John Fastabend wrote:
>> This patch makes the cls_bpf classifier RCU safe. The tcf_lock
>> was being used to protect a list of cls_bpf_prog now this list
>> is RCU safe and updates occur with rcu_replace.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>
> ...

[...]

>> @@ -281,15 +280,17 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>>   	if (ret < 0)
>>   		goto errout;
>>
>> -	tcf_tree_lock(tp);
>> -	list_add(&prog->link, &head->plist);
>> -	tcf_tree_unlock(tp);
>> +	if (oldprog) {
>> +		list_replace_rcu(&prog->link, &oldprog->link);
>> +		call_rcu(&oldprog->rcu, __cls_bpf_delete_prog);
>> +	} else {
>> +		list_add_rcu(&prog->link, &head->plist);
>> +	}
>>
>>   	*arg = (unsigned long) prog;
>> -
>>   	return 0;
>>   errout:
>> -	if (*arg == 0UL && prog)
>> +	if (prog)
>>   		kfree(prog);
>>
>
> nit, you can directly call kfree(prog) even if prog == NULL
>

Yep, made the change.

-- 
John Fastabend         Intel Corporation
