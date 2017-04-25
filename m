From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 25 Apr 2017 09:01:22 -0400
Message-ID: <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34843 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1947458AbdDYNB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 09:01:26 -0400
Received: by mail-it0-f68.google.com with SMTP id 70so2784272ita.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 06:01:26 -0700 (PDT)
In-Reply-To: <20170425121338.GC1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-25 08:13 AM, Jiri Pirko wrote:
> Tue, Apr 25, 2017 at 01:54:06PM CEST, jhs@mojatatu.com wrote:


[..]

>> -#define TCAA_MAX 1
>> +/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
>> + *
>> + * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>> + * actions in a dump. All dump responses will contain the number of actions
>> + * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
>> + *
>> + */
>> +#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
>
> BIT (I think I mentioned this before)
>

You did - but i took it out about two submissions back (per cover
letter) because it is no part of UAPI today. I noticed devlink was
using it but they defined  their own variant.
So if i added this, iproute2 doesnt compile. I could fix iproute2
to move it somewhere to a common header then restore this.

>> +#define VALID_TCA_FLAGS TCA_FLAG_LARGE_DUMP_ON
>
> Again, namespace please. "TCA_ROOT_FLAGS_VALID"

Good point.

> Why is this UAPI?
>

Should not be. I will fix in next update.


>
>>
>> /* New extended info filters for IFLA_EXT_MASK */
>> #define RTEXT_FILTER_VF		(1 << 0)
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 9ce22b7..2756213 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -83,6 +83,7 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			   struct netlink_callback *cb)
>> {
>> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>> +	u32 act_flags = cb->args[2];
>> 	struct nlattr *nest;
>>
>> 	spin_lock_bh(&hinfo->lock);
>> @@ -111,14 +112,18 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
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
>> @@ -993,11 +998,15 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
>> 	return tcf_add_notify(net, n, &actions, portid);
>> }
>>
>> +static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
>> +	[TCA_ROOT_FLAGS]      = { .type = NLA_U32 },
>> +};
>> +
>> static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>> 			 struct netlink_ext_ack *extack)
>> {
>> 	struct net *net = sock_net(skb->sk);
>> -	struct nlattr *tca[TCAA_MAX + 1];
>> +	struct nlattr *tca[TCA_ROOT_MAX + 1];
>> 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
>> 	int ret = 0, ovr = 0;
>>
>> @@ -1005,7 +1014,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>> 	    !netlink_capable(skb, CAP_NET_ADMIN))
>> 		return -EPERM;
>>
>> -	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
>> +	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ROOT_MAX, NULL,
>> 			  extack);
>> 	if (ret < 0)
>> 		return ret;
>> @@ -1046,16 +1055,12 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>> 	return ret;
>> }
>>
>> -static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
>> +static struct nlattr *find_dump_kind(struct nlattr **nla)
>> {
>> 	struct nlattr *tb1, *tb2[TCA_ACT_MAX + 1];
>> 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
>> -	struct nlattr *nla[TCAA_MAX + 1];
>> 	struct nlattr *kind;
>>
>> -	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX,
>> -			NULL, NULL) < 0)
>> -		return NULL;
>> 	tb1 = nla[TCA_ACT_TAB];
>> 	if (tb1 == NULL)
>> 		return NULL;
>> @@ -1073,6 +1078,16 @@ static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
>> 	return kind;
>> }
>>
>> +static inline bool tca_flags_valid(u32 act_flags)
>> +{
>> +	u32 invalid_flags_mask  = ~VALID_TCA_FLAGS;
>> +
>> +	if (act_flags & invalid_flags_mask)
>> +		return false;
>
> I don't see how this resolves anything. VALID_TCA_FLAGS is set in stone
> not going to change anytime in future, right?

Every time a new bit gets added VALID_TCA_FLAGS changes.

>Then the TCA_ROOT_FLAGS
> attr will always contain only one flag, right?

Not true - forever. Just in this patch discussion:
I have added 2 other flags since removed. So I cant predict the
future. You keep coming back to this assumption there will always
ever be this one flag. I am not following how you reach this
conclusion.

> Then, I don't see why do we need this dance... u8 flag attr resolves
> this in elegant way. I know I sound like a broken record. This is the
> last time I'm commenting on this. I give up.
>

Why is a u8 better than u32 Jiri?
The TLV space consumed is still 64 bits in both cases. If I define u8,
u16, u32 - it is still 64 bits being alloced. If i use a u8 then i have
24 bits which are pads - given current discussions I can never ever use
again!

If i keep 32 bits I am free to use those without ever changing the
data structure (except for the restrictions to now make sure nothing
gets set).

cheers,
jamal
