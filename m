From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Wed, 25 Jun 2014 18:17:08 -0700
Message-ID: <87lhskpizv.fsf@x220.int.ebiederm.org>
References: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
	<87d2dwsfh6.fsf@x220.int.ebiederm.org>
	<CAM_iQpVeVpcQLPz7GDuni_v5+bJikQkc2cSzrKee72eGuOecDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51649 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756874AbaFZBU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:20:26 -0400
In-Reply-To: <CAM_iQpVeVpcQLPz7GDuni_v5+bJikQkc2cSzrKee72eGuOecDQ@mail.gmail.com>
	(Cong Wang's message of "Wed, 25 Jun 2014 17:22:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Wed, Jun 25, 2014 at 5:04 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>
>>> From: Cong Wang <cwang@twopensource.com>
>>>
>>> Different net namespaces have different devices, routes, neighbours,
>>> so their neigh table should be separated as well.
>>
>> This justification doesn't work.  Neighbour entries are per network
>> device which are already per network device.
>
> I knew, this is why I never say I am fixing a bug. I just don't see the
> point of holding all such entries in one big table. Routing tables
> are already separated.

And routing tables are a different data structure.  Hash tables tend to
benefit from larger tables.

I can see a point being made for a per network device table, but a per
network namespace table doesn't make much sense.  You are picking a
weird halfway point for the data structure.  Neither optimal in the
minimal amount of sharing nor optimal in the minimal amount of memory
used.

>> The only thing I see that you can gain by this work is getting around
>> global limits on neighbor table size.  Something that I think is most
>> unwise.
>
> Yes, this is one the benefits.

I disagree that removing a global DOS prevention check is a benefit.
Certainly large semantics changes like that should not happen without
being discussed in the patch description.

>> At the very least neigh_tbl_lock today protects against rmmod decnet
>> and rmmod ipv6, which while unlikely can oops they kernel if they aren't
>> handled carefully.  So it definitely feels inappropriate to mush these
>> all together.
>
> At module exit, we should call unregister_pernet_subsys(), where
> each ->exit() will called.

That does seme to provide equivalent protection but it is not clear that
is the protection being relied upon from your patch description.

>> If your goal is to deal with the issue of the limited set of neighbour
>> limits say so and let's look at that problem.
>>
>> If your goal is just to kill neigh_tbl_lock please take that to a
>> separate patch where the pros and cons can be weighed, and people can
>> focus on the issue.
>>
>
> Neither.
>
>> As it stands this patch does too much, and seems to do nothing except
>> bypass controls on global kernel memory consumption.
>>
>
> I agree it's too big, I can split it into two if you want. One for removing
> neigh_tbl_lock, one for making it per netns.

If you can send patches that provide a clear benefit, and describe that
benefit and don't do a lot of other things in the same patch certainly.

Big semantic changes like you have proposed in the patch under
discussion that say let's delete the historic controls and replace them
with something that does not provide the same benefit I find scary.
Especially when those changes come without any discussion.

Eric
