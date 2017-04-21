From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 11:38:00 -0400 (EDT)
Message-ID: <20170421.113800.1367091481085913667.davem@davemloft.net>
References: <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
        <20170421.105156.736001860584596934.davem@davemloft.net>
        <82a6c32b-d58e-aeed-bfb5-546f328eaf35@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041723AbdDUSWg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:22:36 -0400
In-Reply-To: <82a6c32b-d58e-aeed-bfb5-546f328eaf35@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 21 Apr 2017 11:29:19 -0400

> On 17-04-21 10:51 AM, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Fri, 21 Apr 2017 06:36:19 -0400
>>
>>> On 17-04-20 01:58 PM, David Miller wrote:
>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>> Date: Thu, 20 Apr 2017 13:38:14 -0400
>>>>
>>>
> 
>>
>> Which means we can never use them for anything else reliably,
>> there could be random crap in there.
>>
> 
> Today: User space set them to zero.

You don't know this because the kernel has never verified it.
Jamal, you cannot walk past this important point, nothing can
be argued further because of it.

> Old kernels ignore them. New kernels look at the new ones.
> We'll be in a lot of trouble if this was not the case
> for things today;-> People add bits all the time in TLVs
> and in netlink headers that are labeled as flags.

And when we do things that way it's broken, and why we have such
crappy behavior.

We made a very bad decision a long time ago to ignore unrecognized
things in netlink and it was a grave error which we must start
correcting now.

If a user says "enable X" and it just gets simply ignored by older
kernels, that can't work properly.  What if "enable X" is something
like "turn on encryption"?  Are you OK with the user getting no
feedback that their stuff is not going to be encrypted?

Even something as benign as "give melarger action dumps" _must_ still
have the same behavior because the user has no alternative action plan
possible if it cannot tell if the kernel supports the facility or not.

> Dave, I dont think you are suggesting we should use a TLV for every
> bit
> we want to  send to the kernel (as Jiri is), are you?

Jiri is not suggesting this, he is instead saying if you want to
support more bits in the future then you must check that the unused
bits are zero _now_ so that we can prove that userland clears them
properly.

And if you don't have any direct plans for more bits in the future,
use just a single attribute with the smallest integer type possible.

> I think you as suggesting we should from now on enforce a rule that
> in the kernel we start checking that bits in a bitmap received for
> things we are not interested in. So if a bit i dont understand shows
> up in the kernel what should i do?

Reject it.

> Rejecting the transaction because i received something i dont
> understand is not conducive to forward compatibility.

Not rejecting it breaks everything and gives the user no feedback
or way whatsoever to know whether the kernel supports something or
not.

I'm not letting us continue to do things so stupidly any more.

I want future applications to know if they are running on an older
kernel and that a specific netlink feature is not supported.

Ignoring not-understood bits prevents that and is the single most
fundamental mistake we've made in netlink.
