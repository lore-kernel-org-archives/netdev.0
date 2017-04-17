From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 07:01:57 -0400
Message-ID: <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36097 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbdDQLCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 07:02:00 -0400
Received: by mail-io0-f195.google.com with SMTP id x86so25930263ioe.3
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 04:02:00 -0700 (PDT)
In-Reply-To: <20170417081936.GA1892@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-17 04:19 AM, Jiri Pirko wrote:
> Sun, Apr 16, 2017 at 02:34:30PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> When you dump hundreds of thousands of actions, getting only 32 per
>> dump batch even when the socket buffer and memory allocations allow
>> is inefficient.
>>
>> With this change, the user will get as many as possibly fitting
>> within the given constraints.
>>
>> We reuse the pad fields in tcamsg. pad1 is used as a flag space.
>> User explicitly requests for the large dump in order to maintain
>> backwards compatibility with user space by setting bit
>> ACT_LARGE_DUMP_ON; older user space which doesnt set this flag
>> doesnt get the large (than 32) batches - so continues to work
>> as before. Older kernels ignore this flag, so legacy behavior
>> is maintained.
>> The kernel uses pad2 to tell the user how many actions are put in
>> a single batch. As such user space app(like tc) knows how long
>> to iterate instead of hardcoded maximum of 32.
>>
>> Some results dumping 1.5M actions, first unpatched tc which the
>> kernel doesnt help:
>>
>> prompt$ time -p tc actions ls action gact | grep index | wc -l
>> 1500000
>> real 1388.43
>> user 2.07
>> sys 1386.79
>>
>> Now patched tc which sets the correct flags when requesting a dump:
>>
>> prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
>> 1500000
>> real 178.13
>> user 2.02
>> sys 176.96
>>
>> Improvement: Dump time from about 20 minutes to about 2 minutes.
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>> include/uapi/linux/rtnetlink.h |  7 +++++++
>> net/sched/act_api.c            | 17 ++++++++++++++---
>> 2 files changed, 21 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index cce0613..3434d98 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -678,6 +678,13 @@ struct tcamsg {
>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>> #define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>> #define TCAA_MAX 1
>> +/* tcamsg flags stored in tca__pad
>> + *
>> + * ACT_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>> + * actions in a dump. All dump responses will contain the number of actions
>> + * being dumped stored in tca__pad2 for user app's info
>> + */
>> +#define ACT_LARGE_DUMP_ON		(1 << 0)
>>
>> /* New extended info filters for IFLA_EXT_MASK */
>> #define RTEXT_FILTER_VF		(1 << 0)
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 79d875c..90cc774 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -83,6 +83,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			   struct netlink_callback *cb)
>> {
>> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>> +	unsigned short act_flags = cb->args[2];
>> 	struct nlattr *nest;
>>
>> 	spin_lock_bh(&hinfo->lock);
>> @@ -111,14 +112,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			}
>> 			nla_nest_end(skb, nest);
>> 			n_i++;
>> -			if (n_i >= TCA_ACT_MAX_PRIO)
>> +			if (!(act_flags & ACT_LARGE_DUMP_ON) &&
>> +			    n_i >= TCA_ACT_MAX_PRIO)
>> 				goto done;
>> 		}
>> 	}
>> done:
>> 	spin_unlock_bh(&hinfo->lock);
>> -	if (n_i)
>> +	if (n_i) {
>> 		cb->args[0] += n_i;
>> +		if (act_flags & ACT_LARGE_DUMP_ON)
>> +			cb->args[1] = n_i;
>> +	}
>> 	return n_i;
>>
>> nla_put_failure:
>> @@ -1081,6 +1086,7 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>> 	struct tc_action_ops *a_o;
>> 	int ret = 0;
>> 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
>> +	unsigned char act_flags = t->tca__pad1;
>> 	struct nlattr *kind = find_dump_kind(cb->nlh);
>>
>> 	if (kind == NULL) {
>> @@ -1096,9 +1102,12 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>> 			cb->nlh->nlmsg_type, sizeof(*t), 0);
>> 	if (!nlh)
>> 		goto out_module_put;
>> +
>> +	cb->args[2] = act_flags;
>> +
>> 	t = nlmsg_data(nlh);
>> 	t->tca_family = AF_UNSPEC;
>> -	t->tca__pad1 = 0;
>> +	t->tca__pad1 = act_flags;
>
> I don't like this one bit. Pad is no longer a pad but by name it still
> is. Why don't you introduce new attributes for this?
>

The name "pad" is ugly - but _we need to put these reserved spaces
to good use_. We cant keep declaring pads and say they should never
be used in the future.
We dont need more than 2-3 bits for the flags for example and i dont
see anyone dumping 64K actions in one message.
An attribute is a big waste of space. I cant change the name pad - 
perhaps a union with a new name? We had a similar discussion a while 
back on some netlink header, i just dont remember the details.
Suggestions?

cheers,
jamal
