From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v10 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Sun, 11 Jun 2017 13:45:06 -0400
Message-ID: <7d4f7dbe-631a-34f5-0549-93dd484d2368@mojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-4-git-send-email-jhs@emojatatu.com>
 <20170611141303.GC1896@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33224 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdFKRpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 13:45:21 -0400
Received: by mail-it0-f65.google.com with SMTP id l6so9833586iti.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 10:45:20 -0700 (PDT)
In-Reply-To: <20170611141303.GC1896@nanopsycho.orion>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-11 10:13 AM, Jiri Pirko wrote:
> Sun, Jun 11, 2017 at 01:53:45PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> When you dump hundreds of thousands of actions, getting only 32 per
>> dump batch even when the socket buffer and memory allocations allow
>> is inefficient.
>>
>> With this change, the user will get as many as possibly fitting
>> within the given constraints available to the kernel.
>>
>> The top level action TLV space is extended. An attribute
>> TCA_ROOT_FLAGS is used to carry flags; flag TCA_FLAG_LARGE_DUMP_ON
>> is set by the user indicating the user is capable of processing
>> these large dumps. Older user space which doesnt set this flag
>> doesnt get the large (than 32) batches.
>> The kernel uses the TCA_ROOT_COUNT attribute to tell the user how many
>> actions are put in a single batch. As such user space app knows how long
>> to iterate (independent of the type of action being dumped)
>> instead of hardcoded maximum of 32 thus maintaining backward compat.
>>
>> Some results dumping 1.5M actions below:
>> first an unpatched tc which doesnt understand these features...
>>
>> prompt$ time -p tc actions ls action gact | grep index | wc -l
>> 1500000
>> real 1388.43
>> user 2.07
>> sys 1386.79
>>
>> Now lets see a patched tc which sets the correct flags when requesting
>> a dump:
>>
>> prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
>> 1500000
>> real 178.13
>> user 2.02
>> sys 176.96
>>
>> That is about 8x performance improvement for tc app which sets its
>> receive buffer to about 32K.
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>> include/uapi/linux/rtnetlink.h | 22 +++++++++++++++++--
>> net/sched/act_api.c            | 50 +++++++++++++++++++++++++++++++++---------
>> 2 files changed, 60 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index 8f07957..7d2030f 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -693,10 +693,28 @@ struct tcamsg {
>> 	unsigned char	tca__pad1;
>> 	unsigned short	tca__pad2;
>> };
>> +
>> +enum {
>> +	TCA_ROOT_UNSPEC,
>> +	TCA_ROOT_TAB,
>> +#define TCA_ACT_TAB TCA_ROOT_TAB
>> +#define TCAA_MAX TCA_ROOT_TAB
>> +	TCA_ROOT_FLAGS,
>> +	TCA_ROOT_COUNT,
>> +	__TCA_ROOT_MAX,
>> +#define	TCA_ROOT_MAX (__TCA_ROOT_MAX - 1)
>> +};
>> +
>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>> -#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>> -#define TCAA_MAX 1
>> +/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
>> + *
>> + * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>> + * actions in a dump. All dump responses will contain the number of actions
>> + * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
>> + *
>> + */
>> +#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
>>
>> /* New extended info filters for IFLA_EXT_MASK */
>> #define RTEXT_FILTER_VF		(1 << 0)
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 400eb6e..935dc19 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -110,6 +110,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			   struct netlink_callback *cb)
>> {
>> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>> +	u32 act_flags = cb->args[2];
>> 	struct nlattr *nest;
>>
>> 	spin_lock_bh(&hinfo->lock);
>> @@ -138,14 +139,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			}
>> 			nla_nest_end(skb, nest);
>> 			n_i++;
>> -			if (n_i >= TCA_ACT_MAX_PRIO)
>> +			if (!(act_flags & TCA_FLAG_LARGE_DUMP_ON) &&
>> +			    n_i >= TCA_ACT_MAX_PRIO)
>> 				goto done;
>> 		}
>> 	}
>> done:
>> 	spin_unlock_bh(&hinfo->lock);
>> -	if (n_i)
>> +	if (n_i) {
>> 		cb->args[0] += n_i;
>> +		if (act_flags & TCA_FLAG_LARGE_DUMP_ON)
>> +			cb->args[1] = n_i;
>> +	}
>> 	return n_i;
>>
>> nla_put_failure:
>> @@ -1068,11 +1073,17 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
>> 	return tcf_add_notify(net, n, &actions, portid);
>> }
>>
>> +static u32 allowed_flags = TCA_FLAG_LARGE_DUMP_ON;
> 
> An empty line would be nice. Also, since this is outside a function, some
> context prefix would be nice:
> static u32 tcaa_root_flags_allowed = TCA_FLAG_LARGE_DUMP_ON;
>

You are going to make me exceed the 80 char limit? ;->


>> +	if (tb[TCA_ROOT_FLAGS])
>> +		nla_memcpy(&select_flags, tb[TCA_ROOT_FLAGS],
>> +			   sizeof(select_flags));
> 
> Please introduce a helper for this attr type in patch 1:
> 
> u32 select_flags;
> 
> select_flags = nla_get_flag_bits_values(tb[TCA_ROOT_FLAGS])
> 

Sure.

cheers,
jamal
