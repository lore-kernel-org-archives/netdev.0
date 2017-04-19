From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 2/2] net sched actions: add time filter for
 action dumping
Date: Wed, 19 Apr 2017 09:11:26 -0400
Message-ID: <f1704aae-af9d-75eb-47f7-64950f2b841b@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <1492603050-9318-2-git-send-email-jhs@emojatatu.com>
 <20170419125336.GC3357@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34769 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934273AbdDSNL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:11:29 -0400
Received: by mail-it0-f67.google.com with SMTP id 193so2728844itm.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 06:11:28 -0700 (PDT)
In-Reply-To: <20170419125336.GC3357@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 08:53 AM, Jiri Pirko wrote:
> Wed, Apr 19, 2017 at 01:57:30PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> This adds support for filtering based on time since last used.
>> When we are dumping a large number of actions it is useful to
>> have the option of filtering based on when the action was last
>> used to reduce the amount of data crossing to user space.
>>
>> With this patch the user space app sets the TCAA_ACT_TIME_FILTER
>> attribute with the value in milliseconds with "time of interest
>> since now".  The kernel converts this to jiffies and does the
>> filtering comparison matching entries that have seen activity
>> since then and returns them to user space.
>> Old kernels and old tc continue to work in legacy mode since
>> they dont specify this attribute.
>>
>> Some example (we have 400 actions bound to 400 filters); at installation
>> time using  hacked tc which sets the time of interest to 120 seconds:
>>
>> prompt$ hackedtc actions ls action gact | grep index | wc -l
>> 400
>>
>> go get some coffee and  wait for > 120 seconds and try again:
>>
>> prompt$ hackedtc actions ls action gact | grep index | wc -l
>> 0
>>
>> Lets see a filter bound to one of these actions:
>> ..
>> filter pref 10 u32
>> filter pref 10 u32 fh 800: ht divisor 1
>> filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
>>  match 7f000002/ffffffff at 12 (success 1 )
>>    action order 1: gact action pass
>>     random type none pass val 0
>>     index 23 ref 2 bind 1 installed 1145 sec used 802 sec
>>    Action statistics:
>>    Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
>>    backlog 0b 0p requeues 0
>> ....
>>
>> that coffee took long, no? It was good.
>>
>> Now lets ping -c 1 127.0.0.2, then run the actions again:
>>
>> prompt$ hackedtc actions ls action gact | grep index | wc -l
>> 1
>>
>> More details please:
>>
>> prompt$ hackedtc -s actions ls action gact
>
> I don't see where you pass the time.
>

User space sets the TCAA_ACT_TIME_FILTER value.
Jiri - this is described in the commit log ;->
I have some tc changes which set this value.
In the example below it was 120 seconds.


>
>>
>>    action order 0: gact action pass
>>     random type none pass val 0
>>     index 23 ref 2 bind 1 installed 1270 sec used 30 sec
>>    Action statistics:
>>    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>>    backlog 0b 0p requeues 0
>>
>> And the filter?
>>
>> filter pref 10 u32
>> filter pref 10 u32 fh 800: ht divisor 1
>> filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
>>  match 7f000002/ffffffff at 12 (success 2 )
>>    action order 1: gact action pass
>>     random type none pass val 0
>>     index 23 ref 2 bind 1 installed 1324 sec used 84 sec
>>    Action statistics:
>>    Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>>    backlog 0b 0p requeues 0
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>> include/uapi/linux/rtnetlink.h |  1 +
>> net/sched/act_api.c            | 25 +++++++++++++++++++++++--
>> 2 files changed, 24 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index c7080ec..1b36cc0 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -680,6 +680,7 @@ enum {
>> 	TCAA_ACT_TAB,
>> 	TCAA_ACT_FLAGS,
>> 	TCAA_ACT_COUNT,
>> +	TCAA_ACT_TIME_FILTER,
>
> Another use of word "filter" for something else. I believe that we need
> to reduce confusion, not to make it worse.
>

It is a time filter. What do you want to call it?


>
>> 	__TCAA_MAX
>> };
>>
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 45e1cf7..b03863a 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -84,11 +84,12 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> {
>> 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
>> 	unsigned short act_flags = cb->args[2];
>> +	unsigned long jiffy_filter = cb->args[3];
>
> call this "jiffy_since" for example
>

Sure.


>
>> 	struct nlattr *nest;
>>
>> 	spin_lock_bh(&hinfo->lock);
>>
>> -	s_i = cb->args[0];
>> +	s_i = cb->args[4];
>>
>> 	for (i = 0; i < (hinfo->hmask + 1); i++) {
>> 		struct hlist_head *head;
>> @@ -101,6 +102,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			if (index < s_i)
>> 				continue;
>>
>> +			if (jiffy_filter &&
>> +			    time_after(jiffy_filter,
>> +				       (unsigned long)p->tcfa_tm.lastuse))
>> +				continue;
>> +
>> 			nest = nla_nest_start(skb, n_i);
>> 			if (nest == NULL)
>> 				goto nla_put_failure;
>> @@ -118,6 +124,9 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 		}
>> 	}
>> done:
>> +	if (index > 0)
>> +		cb->args[4] = index + 1;
>> +
>> 	spin_unlock_bh(&hinfo->lock);
>> 	if (n_i) {
>> 		cb->args[0] += n_i;
>
> You don't use "cb->args[0]" anymore. Why do you need this?

You are right - will remove this.

> Just use cb->args[0] instead of 4
>

I can do that too.


>
>> @@ -1000,6 +1009,7 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
>>
>> static const struct nla_policy tcaa_policy[TCAA_MAX + 1] = {
>> 	[TCAA_ACT_FLAGS]      = { .type = NLA_U32 },
>> +	[TCAA_ACT_TIME_FILTER]      = { .type = NLA_U32 },
>> };
>>
>> static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>> @@ -1090,13 +1100,14 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>> 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
>> 	struct nlattr *kind = NULL;
>> 	u32 act_flags = 0;
>> +	u32 msecs_filter = 0;
>> +	unsigned long jiffy_wanted = 0;
>
> Also, "jiffy_since". Same variable, same name please.
>

np.

>>
>> 	ret = nlmsg_parse(cb->nlh, sizeof(struct tcamsg), tcaa, TCAA_MAX,
>> 			  tcaa_policy, NULL);
>> 	if (ret < 0)
>> 		return ret;
>>
>> -
>
> This should not be part of this patch.
>

Will remove.

>
>> 	kind = find_dump_kind(tcaa);
>> 	if (kind == NULL) {
>> 		pr_info("tc_dump_action: action bad kind\n");
>> @@ -1110,12 +1121,22 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
>> 	if (tcaa[TCAA_ACT_FLAGS])
>> 		act_flags = nla_get_u32(tcaa[TCAA_ACT_FLAGS]);
>>
>> +	if (tcaa[TCAA_ACT_TIME_FILTER])
>> +		msecs_filter = nla_get_u32(tcaa[TCAA_ACT_TIME_FILTER]);
>> +
>> 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
>> 			cb->nlh->nlmsg_type, sizeof(*t), 0);
>> 	if (!nlh)
>> 		goto out_module_put;
>>
>> +	if (msecs_filter) {
>> +		unsigned long jiffy_msecs = msecs_to_jiffies(msecs_filter);
>> +
>> +		jiffy_wanted = jiffies - jiffy_msecs;
>
> you can do just:
> 		jiffy_wanted = jiffies - msecs_to_jiffies(msecs_filter);
>
> Also, you can put this under "if (tcaa[TCAA_ACT_TIME_FILTER])" so it's
> all in one place.
>

Will do - next cycle run.


cheers,
jamal
