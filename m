From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 10:03:55 -0400
Message-ID: <d582d8bc-f5d4-f136-a654-9ebcd5b53d5d@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
 <705a4d67-4a81-113f-e22a-0ca0bb6cf1eb@mojatatu.com>
 <20170419131323.GE3357@nanopsycho.orion>
 <e2a1e201-4830-e600-e668-91f83bcc9b32@mojatatu.com>
 <20170419155400.GH3357@nanopsycho.orion>
 <56488055-1f4b-ee10-2357-5ce80f1fbc50@mojatatu.com>
 <20170419161736.GJ3357@nanopsycho.orion>
 <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
 <20170420113540.GC1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33289 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031637AbdDTOD7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:03:59 -0400
Received: by mail-io0-f193.google.com with SMTP id k87so16668908ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:03:59 -0700 (PDT)
In-Reply-To: <20170420113540.GC1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 07:35 AM, Jiri Pirko wrote:
> Thu, Apr 20, 2017 at 12:42:55PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-19 12:17 PM, Jiri Pirko wrote:
>
> Ha. So the current code is wrong, I see it now. Following is needed:
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 82b1d48..c432b22 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -1005,7 +1005,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
>  	    !netlink_capable(skb, CAP_NET_ADMIN))
>  		return -EPERM;
>
> -	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
> +	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
>  			  extack);
>  	if (ret < 0)
>  		return ret;
>
> You confused me squashing the change to this patch.
>
> Ok, so the name could be:
> TCA_ACTS_*
> ?
> I believe it is crucial to figure this out right now. TC UAPI is in deep
> mess already, no need to push it even more.
>

I could change that name. Look at the last series i sent, add any extra
comments to that  and i will get to it by tomorrow.

>> They are not the same issue Jiri. We have used bitmasks fine on netlink
>
> Howcome they are not the same? I'm pretty certain they are.
>

They are not Jiri. I challenge you to point me to one netlink bitmask
representation used that has some bits that were not being used that
someone or some compiler is going to set some random values on.
Typically flags are u64/32/16

>
>> message for a millenia. Nobody sets garbage on a bitmask they are not
>> supposed to touch. The struct padding thing is a shame the way it
>> turned out - now netlink can no longer have a claim to be a (good)
>> wire protocol.
>> Other thing: I know you feel strongly about this but I dont agree that
>> everything has to be a TLV and in no way, as a matter of principle, you are
>> going to convince me  (even when the cows come home) that I have to
>> use 64 bits to carry a single bit just so I can use TLVs.
>
> Then I guess we have to agree to disagree. I believe that your approach
> is wrong and will break users in future when you add even a single flag.
> Argument that "we are doing this for ages-therefore it is correct" has
> simply 0 value.
>

"doing these for 80 years" is not the main driving point.
I appreciate that data structures - even when fields are
annotated as "pads" there is no guarantee when i allocate one
the pads will be zeroes.

Bitmasks are atomic in nature and therefore used in whole - not complex
like structs. Thats the difference. I dont define this u32 bitmap that
has 8 bits that are "pads" because that concept doesnt make sense for
atomic fields.
This implies that 6 months down the road I dont regret and say "shit, I
need 2 more bits for flagbits but some idiot or compiler was setting
those fields so i cant use them now because the kernel wont tell the
difference between what s/he is doing and real values".
Allocations of data structures I can understand, unless we enforce
always reset to zeroes all the struct members as part of creation.

But lets agree to disagree if you are still not convinced.

On your "everything must be a TLV". Caveat is: there is a balance
between  performance and flexibility. I should be able to pack aligned
complex data structures in a TLV for performance reasons.
One lesson is: in the future we can make these extra service header like
tcamsg very small and always use all their fields instead of defining
pads.

cheers,
jamal
