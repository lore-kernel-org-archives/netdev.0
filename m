From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 10:18:50 -0400
Message-ID: <a0d70dc5-b0cb-c54e-7d98-93099b68c247@mojatatu.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33723 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032447AbdDTOTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:19:05 -0400
Received: by mail-io0-f193.google.com with SMTP id k87so16799214ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:18:55 -0700 (PDT)
In-Reply-To: <20170420135915.GE1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 09:59 AM, Jiri Pirko wrote:
> Thu, Apr 20, 2017 at 03:06:21PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> When you dump hundreds of thousands of actions, getting only 32 per
>> dump batch even when the socket buffer and memory allocations allow
>> is inefficient.
>>
>> With this change, the user will get as many as possibly fitting
>> within the given constraints available to the kernel.
>>
>> A new top level TLV space is introduced. An attribute
>> TCAA_ACT_FLAGS is used to carry the flags indicating the user
>> is capable of processing these large dumps. Older user space which
>> doesn't set this flag doesn't get the large (than 32) batches.
>> The kernel uses the TCAA_ACT_COUNT attribute to tell the user how many
>> actions are put in a single batch. As such user space app knows how long
>> to iterate (independent of the type of action being dumped)
>> instead of hardcoded maximum of 32.
>>
>> Some results dumping 1.5M actions, first unpatched tc which the
>> kernel doesn't help:
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
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++--
>> net/sched/act_api.c            | 46 +++++++++++++++++++++++++++++++++---------
>> 2 files changed, 55 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index cce0613..d7d28ec 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -674,10 +674,27 @@ struct tcamsg {
>> 	unsigned char	tca__pad1;
>> 	unsigned short	tca__pad2;
>> };
>> +
>> +enum {
>> +	TCAA_UNSPEC,
>
> TCAA stands for "traffic control action action". I don't get it :(
> Prefix still sounds wrong to me, sorry :/
> Should be:
> TCA_SOMETHING_*
>
>
>> +	TCAA_ACT_TAB,
>> +#define TCA_ACT_TAB TCAA_ACT_TAB
>> +	TCAA_ACT_FLAGS,
>> +	TCAA_ACT_COUNT,
>> +	__TCAA_MAX,
>> +#define	TCAA_MAX (__TCAA_MAX - 1)
>> +};
>> +
>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>> -#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>> -#define TCAA_MAX 1
>> +/* tcamsg flags stored in attribute TCAA_ACT_FLAGS
>> + *
>> + * ACT_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>> + * actions in a dump. All dump responses will contain the number of actions
>> + * being dumped stored in for user app's consumption in TCAA_ACT_COUNT
>> + *
>> + */
>> +#define ACT_LARGE_DUMP_ON		BIT(0)
>
> Please put some prefix to the name, as I asked for in the previous
> version.	
> 	

Didnt mean to leave out but:
I cant seem to find it. Do you recall what you said it should be?

> 	
>>
>> /* New extended info filters for IFLA_EXT_MASK */
>> #define RTEXT_FILTER_VF		(1 << 0)
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 82b1d48..f85b8fd 100644
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
>> @@ -993,11 +998,15 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
>> 	return tcf_add_notify(net, n, &actions, portid);
>> }
>>
>> +static const struct nla_policy tcaa_policy[TCAA_MAX + 1] = {
>> +	[TCAA_ACT_FLAGS]      = { .type = NLA_U32 },
>> +};
>> +
>> static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>> 			 struct netlink_ext_ack *extack)
>> {
>> 	struct net *net = sock_net(skb->sk);
>> -	struct nlattr *tca[TCA_ACT_MAX + 1];
>> +	struct nlattr *tca[TCAA_MAX + 1];
>> 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
>> 	int ret = 0, ovr = 0;
>>
>> @@ -1005,7 +1014,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>> 	    !netlink_capable(skb, CAP_NET_ADMIN))
>> 		return -EPERM;
>>
>> -	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
>> +	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, tcaa_policy,
>
> Please do this in a separate patch. It is an unrelated bug fix.
>

Ok, that is fair. Thanks. Ok, if this was patch 1/3 in next update.

>
>

>
> "tcaa" again, now as a variable :/
> Just use "tb" as the rest of the code does.
>

Sure.

>
>>
>> +	if (tcaa[TCAA_ACT_FLAGS])
>> +		act_flags = nla_get_u32(tcaa[TCAA_ACT_FLAGS]);
>
> I still believe this is wrong. Should be a separate attr per flag.
> For user experience breakage reasons:
> 2 kernels should not behave differently on the exact same value passed
> from userspace:
> User passes 0x2. Now the kernel will ignore the set bit, the next kernel
> will recognize it as a valid flag and do something.
> Please let the discussion reach a consensus before pushing this again.
>
>

Jiri - I dont agree. There is no such breakage. Refer to my previous
email. Lets just move on.

cheers,
jamal
