From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: Add support for user
 cookies
Date: Sat, 14 Jan 2017 10:39:24 -0500
Message-ID: <09bf24f3-7080-341d-a332-a2042e7fc34b@mojatatu.com>
References: <1484405958-24591-1-git-send-email-jhs@emojatatu.com>
 <20170114152248.GB1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, Jamal Hadi Salim <hadi@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32830 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdANPj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 10:39:27 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so8474651iom.0
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 07:39:26 -0800 (PST)
In-Reply-To: <20170114152248.GB1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-14 10:22 AM, Jiri Pirko wrote:

>> .. create an accept action with cookie 0xA:0xa0a0a0a0a0a0a0
>> sudo $TC actions add action ok index 1 cookie 0xA 0xa0a0a0a0a0a0a0
>
> 2x 64bit values? Why can't this have variable length, according to what
> user needs:


You can intepret it however you wish. It is 128 bits. You can make it
2x64, 4x32, 8x16, 16x8

>
> sudo $TC actions add action ok index 1 cookie a0
> sudo $TC actions add action ok index 1 cookie a01122
> sudo $TC actions add action ok index 1 cookie a01122334455
> sudo $TC actions add action ok index 1 cookie a01122334455aabbccddeeff
>

Sure you can do that too..
I will add add 16 8b fields to the union.


>>
>> .. dump all gact actions..
>> sudo $TC -s actions ls action gact
>>
>> 	action order 0: gact action pass
>> 	 random type none pass val 0
>> 	 index 1 ref 2 bind 1 installed 1221 sec used 27 sec
>> 	Action statistics:
>> 	Sent 373248 bytes 5056 pkt (dropped 0, overlimits 0 requeues 0)
>> 	backlog 0b 0p requeues 0
>> 	 cookie(0000000a:00000000:a0a0a0a0:00a0a0a0)
>
> Input is 2x64 and dump is 4x32? That is confusing. With my suggested
> example, this would be:
>
> 	 cookie a0
> 	 cookie a01122
> 	 cookie a01122334455
> 	 cookie a01122334455aabbccddeeff
>

Your suggestion is more sensible for a user space cli tool like tc.
I will add a uchar cku8[16] field and make changes to iproute2.

>> struct tc_action_ops;
>>
>> +union act_cookie {
>> +	u16 ck16[8];
>> +	u32 ck32[4];
>> +	u64 ck64[2];
>
> Since this should be never interpreted by kernel, I don't understand why
> this union is needed. Why just don't pass a char array?
>

programmatic usability.

> Also, whatever format this is, could we make is shared with cls cookie?
>
>

The structure could be shared (and because it is in pkt_cls.h
that makes it easier). But the TLVs are domain specific. We need another
one for classifiers.

>> +};
>> +
>> struct tc_action {
>> 	const struct tc_action_ops	*ops;
>> 	__u32				type; /* for backward compat(TCA_OLD_COMPAT) */
>> @@ -41,6 +47,7 @@ struct tc_action {
>> 	struct rcu_head			tcfa_rcu;
>> 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>> 	struct gnet_stats_queue __percpu *cpu_qstats;
>> +	union act_cookie	*ck;
>> };
>> #define tcf_head	common.tcfa_head
>> #define tcf_index	common.tcfa_index
>> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>> index 1e5e1dd..6379af3 100644
>> --- a/include/uapi/linux/pkt_cls.h
>> +++ b/include/uapi/linux/pkt_cls.h
>> @@ -4,6 +4,12 @@
>> #include <linux/types.h>
>> #include <linux/pkt_sched.h>
>>
>> +union u_act_cookie {
>> +	__u16 ck16[8];
>> +	__u32 ck32[4];
>> +	__u64 ck64[2];
>> +};
>
> Again, the same struct? I don't understand why twice.

Just old habits.
user vs kernel api? Standard action approach one says
__u32 other says u32; hanging off the user variant to kernel
didnt feel right.

cheers,
jamal
