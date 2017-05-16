From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 10/10] net: sched: add termination action to
 allow goto chain
Date: Tue, 16 May 2017 06:43:19 +0200
Message-ID: <20170516044319.GA24493@nanopsycho>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-11-jiri@resnulli.us>
 <591A0940.2070801@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34840 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751225AbdEPEnW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 00:43:22 -0400
Received: by mail-wm0-f66.google.com with SMTP id v4so34490889wmb.2
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 21:43:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <591A0940.2070801@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 15, 2017 at 10:02:08PM CEST, daniel@iogearbox.net wrote:
>On 05/15/2017 10:38 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Introduce new type of termination action called "goto_chain". This allows
>> user to specify a chain to be processed. This action type is
>> then processed as a return value in tcf_classify loop in similar
>> way as "reclassify" is, only it does not reset to the first filter
>> in chain but rather reset to the first filter of the desired chain.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>[...]
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index 1112a2b..98cc689 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -304,10 +304,14 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>>   			continue;
>> 
>>   		err = tp->classify(skb, tp, res);
>> -		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode))
>> +		if (err == TC_ACT_RECLASSIFY && !compat_mode) {
>>   			goto reset;
>> -		if (err >= 0)
>> +		} else if (TC_ACT_EXT_CMP(err, TC_ACT_GOTO_CHAIN)) {
>> +			old_tp = res->goto_tp;
>> +			goto reset;
>> +		} else if (err >= 0) {
>>   			return err;
>> +		}
>
>Given this goto chain feature is pretty much only interesting for hw
>offloads, can we move this further away from the sw fast path to not
>add up to the cost per packet? (I doubt anyone is using TC_ACT_RECLASSIFY
>in sw as well ...)

I don't think so. First of all, the whole thing would be broken then in
sw. It is useful to have it in sw, at least for testing reasons.
So I would leave the unlikely and add it to the second check as well.


>
>>   	}
>> 
>>   	return TC_ACT_UNSPEC; /* signal: continue lookup */
>> 
