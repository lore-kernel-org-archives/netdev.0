From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 11:37:15 -0400
Message-ID: <e2a1e201-4830-e600-e668-91f83bcc9b32@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
 <705a4d67-4a81-113f-e22a-0ca0bb6cf1eb@mojatatu.com>
 <20170419131323.GE3357@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34262 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1766004AbdDSPhY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 11:37:24 -0400
Received: by mail-io0-f195.google.com with SMTP id h41so4471292ioi.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 08:37:24 -0700 (PDT)
In-Reply-To: <20170419131323.GE3357@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 09:13 AM, Jiri Pirko wrote:
> Wed, Apr 19, 2017 at 03:03:59PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-19 08:36 AM, Jiri Pirko wrote:
>>> Wed, Apr 19, 2017 at 01:57:29PM CEST, jhs@mojatatu.com wrote:
>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>>>> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++++--
>>>> net/sched/act_api.c            | 43 ++++++++++++++++++++++++++++++++----------
>>>> 3 files changed, 53 insertions(+), 12 deletions(-)

>>>> +#define TCAA_MAX (__TCAA_MAX - 1)
>>>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>>>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>>>> -#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>>>> -#define TCAA_MAX 1
>>>> +#define TCA_ACT_TAB TCAA_ACT_TAB
>>>
>>> This is mess. What does "TCAA" stand for?
>>
>> TC Actions Attributes.  What would you call it? I could have
>> called it TCA_ROOT etc. But maybe a comment to just call it
>> TC Actions Attributes would be enough?
>
> TCA_DUMP_X
>
> it is only for dumping. Naming it "attribute" seems weird. Same as if
> you have: int variable_something;
>

Jiri, this is not just for dumping. We are describing high level
attributes for tc actions.

>
>>
>>> I suggest some more meaningful naming of the enum items and define
>>> TCA_ACT_TAB and TCAA_MAX to the new values in order to maintain UAPI
>>
>>
>> Thats what the above does (for UAPI) maintainance, no?
>
> It does it for TCA_ACT_TAB. We need to do it for both TCA_ACT_TAB and TCAA_MAX
>

TCAA_XXX is the namespace selected. You dont like that name and
adding DUMP doesnt make sense to me. How about TCA_ACT_ROOT?

>>
>>> Also, please put X_MAX = __X_MAX - 1 into enum
>>
>> That is diverting from the norm which defines it outside
>> of the enum. A good reason could be: You, Jiri, plan to go and
>> cleanup all the netlink stuff which uses this style.
>> Or you think we should start a trend which leads us
>> to a new clean style.
>
> I would start now. I can take of the follow-up patch to change the rest.
>

It is a _lot_ of code to change! Note:
This is all the UAPI visible code (the same coding style for 20 years).
I am worried about this part.

>>>
>>>> +/* tcamsg flags stored in attribute TCAA_ACT_FLAGS
>>>> + *
>>>> + * ACT_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
>>>> + * actions in a dump. All dump responses will contain the number of actions
>>>> + * being dumped stored in for user app's consumption in TCAA_ACT_COUNT
>>>> + *
>>>> + */
>>>> +#define ACT_LARGE_DUMP_ON		(1 << 0)
>>>
>>> Use "BIT(0)"
>>>
>>
>> Same question as before.
>
> Same answer :)
>

I will change this one - it is a lot simpler coding style
wide/wise than the other one.

>> Are you planning to cleanup the rest of the code which

>> So you are using 8 bits for one flag which requires one bit?
>> + the TLV header? Sounds like overkill.
>> Note: We dont need more than 1 or 2 bits for this case.
>> Even 32 bits is overkill for what I am doing.
>> When do i need to extend a single bit representation?
>
> I don't see any problem adding couple of bytes if it increases cleannes
> and easy extendability.
>

How do you extend one bit? Seriously. If i want to add another bit I
will add one more to existing bit map not 64 (T + L + 8bits + pad).
If i ran out of space i will add a new TLV.

>>>
>>>> 	struct net *net = sock_net(skb->sk);
>>>> -	struct nlattr *tca[TCA_ACT_MAX + 1];
>>>> +	struct nlattr *tca[TCAA_MAX + 1];
>>>
>>> This is certainly wrong.
>>>
>>
>> Why is it wrong?
>
> Because you use existing TCA_ACT_ attr enum.
>

Is there a programming mistake or you  just dont like the name?
AFAIK, and based on my testing that code is correct.

>>>> -	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
>>>> +	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, tcaa_policy,
>>>
>>> This is certainly wrong.
>>>
>>
>> Same question as above.
>
> Same answer.
>

And same question still.

cheers,
jamal
