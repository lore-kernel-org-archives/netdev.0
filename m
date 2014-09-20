From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 2/2] net: sched: cls_u32 changes to knode must
 appear atomic to readers
Date: Fri, 19 Sep 2014 21:55:34 -0700
Message-ID: <541D08C6.8060804@gmail.com>
References: <20140917191131.20529.91136.stgit@nitbit.x32> <20140917191202.20529.87231.stgit@nitbit.x32> <541AC425.2090300@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:56049 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbaITEzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 00:55:51 -0400
Received: by mail-oa0-f44.google.com with SMTP id eb12so2480177oac.31
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 21:55:50 -0700 (PDT)
In-Reply-To: <541AC425.2090300@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2014 04:38 AM, Jamal Hadi Salim wrote:
> On 09/17/14 15:12, John Fastabend wrote:
>> Changes to the cls_u32 classifier must appear atomic to the
>> readers. Before this patch if a change is requested for both
>> the exts and ifindex, first the ifindex is updated then the
>> exts with tcf_exts_change(). This opens a small window where
>> a reader can have a exts chain with an incorrect ifindex. This
>> violates the the RCU semantics.
>>
>> Here we resolve this by always passing u32_set_parms() a copy
>> of the tc_u_knode to work on and then inserting it into the hash
>> table after the updates have been successfully applied.
>>
>> Tested with the following short script:
>>
>
>>
>> #tc filter add dev p3p2 parent 8001:0 protocol ip prio 99 handle 1: \
>>            u32 divisor 256
>>
>> #tc filter add dev p3p2 parent 8001:0 protocol ip prio 99 \
>>            u32 link 1: hashkey mask ffffff00 at 12    \
>>            match ip src 192.168.8.0/2
>>
>> #tc filter add dev p3p2 parent 8001:0 protocol ip prio 102    \
>>            handle 1::10 u32 classid 1:2 ht 1:           \
>>            match ip src 192.168.8.0/8 match ip tos 0x0a 1e
>>
>> #tc filter change dev p3p2 parent 8001:0 protocol ip prio 102 \
>>          handle 1::10 u32 classid 1:2 ht 1:        \
>>          match ip src 1.1.0.0/8 match ip tos 0x0b 1e
>>
>> CC: Eric Dumazet <edumazet@google.com>
>> CC: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>
>
> Looks good to me.
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> cheers,
> jamal

Thanks for looking it over! I made v2 though to address a comment
that my variable/function names could be better and added a comment
around the perhaps tricky cases where it is safe to free the percpu
variables.

Because I did touch the patch and make some changes I dropped your
ACK. I always thought it was a bit of bad form to carry ack's around
after modifying the code without an explicit approval. Please add it
back though if you want.

Thanks,
John

-- 
John Fastabend         Intel Corporation
