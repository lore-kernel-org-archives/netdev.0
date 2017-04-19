From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 09:03:59 -0400
Message-ID: <705a4d67-4a81-113f-e22a-0ca0bb6cf1eb@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32828 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763379AbdDSNED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:04:03 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so3475607ioi.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 06:04:02 -0700 (PDT)
In-Reply-To: <20170419123645.GB3357@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 08:36 AM, Jiri Pirko wrote:
> Wed, Apr 19, 2017 at 01:57:29PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>

>> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++++--
>> net/sched/act_api.c            | 43 ++++++++++++++++++++++++++++++++----------
>> 3 files changed, 53 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index cce0613..c7080ec 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -674,10 +674,27 @@ struct tcamsg {
>> 	unsigned char	tca__pad1;
>> 	unsigned short	tca__pad2;
>> };
>> +
>> +enum {
>> +	TCAA_UNSPEC,
>> +	TCAA_ACT_TAB,
>> +	TCAA_ACT_FLAGS,
>> +	TCAA_ACT_COUNT,
>> +	__TCAA_MAX
>> +};
>> +
>> +#define TCAA_MAX (__TCAA_MAX - 1)
>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>> -#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>> -#define TCAA_MAX 1
>> +#define TCA_ACT_TAB TCAA_ACT_TAB
>
> This is mess. What does "TCAA" stand for?

TC Actions Attributes.  What would you call it? I could have
called it TCA_ROOT etc. But maybe a comment to just call it
TC Actions Attributes would be enough?

> I suggest some more meaningful naming of the enum items and define
> TCA_ACT_TAB and TCAA_MAX to the new values in order to maintain UAPI


Thats what the above does (for UAPI) maintainance, no?

> Also, please put X_MAX = __X_MAX - 1 into enum

That is diverting from the norm which defines it outside
of the enum. A good reason could be: You, Jiri, plan to go and
cleanup all the netlink stuff which uses this style.
Or you think we should start a trend which leads us
to a new clean style.

>
>> +/* tcamsg flags stored in attribute TCAA_ACT_FLAGS
>> + *
>> + * ACT_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>> + * actions in a dump. All dump responses will contain the number of actions
>> + * being dumped stored in for user app's consumption in TCAA_ACT_COUNT
>> + *
>> + */
>> +#define ACT_LARGE_DUMP_ON		(1 << 0)
>
> Use "BIT(0)"
>

Same question as before.
Are you planning to cleanup the rest of the code which
follows the same style? example, look at this:
         TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT = (1 << 0),


> Also use the same prefix as for the enum.
>
> + you can have each potential flag as a separate u8 attribute. That is the
> clearest approach and easily extendable. That's how we do it in devlink
> for example.
>

So you are using 8 bits for one flag which requires one bit?
+ the TLV header? Sounds like overkill.
Note: We dont need more than 1 or 2 bits for this case.
Even 32 bits is overkill for what I am doing.
When do i need to extend a single bit representation?

>
>> 	struct net *net = sock_net(skb->sk);
>> -	struct nlattr *tca[TCA_ACT_MAX + 1];
>> +	struct nlattr *tca[TCAA_MAX + 1];
>
> This is certainly wrong.
>

Why is it wrong?

>
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
> This is certainly wrong.
>

Same question as above.


>> +		if (nla_put_u32(skb, TCAA_ACT_COUNT, cb->args[1]))
>> +			goto out_module_put;
>> +		cb->args[1] = 0;
>
> Why you need to zero this?
>
>

The count is per submitted message - every time we succesfuly send a msg
to user, we start the recount.

cheers,
jamal
