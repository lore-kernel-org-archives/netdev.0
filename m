From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 16:52:13 +0200
Message-ID: <5628F81D.1070009@6wind.com>
References: <20151021164613.24650836@griffin>
 <20151021.083214.534622235927401863.davem@davemloft.net>
 <20151021172502.63220dbb@griffin>
 <20151021.085635.1582760365341524949.davem@davemloft.net>
 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36901 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932412AbbJVOwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:52:17 -0400
Received: by wicfv8 with SMTP id fv8so124046756wic.0
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 07:52:16 -0700 (PDT)
In-Reply-To: <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/10/2015 19:12, Hannes Frederic Sowa a =C3=A9crit :
> Hello,
>
> On Wed, Oct 21, 2015, at 17:56, David Miller wrote:
>> From: Jiri Benc <jbenc@redhat.com>
>> Date: Wed, 21 Oct 2015 17:25:02 +0200
>>
>>> On Wed, 21 Oct 2015 08:32:14 -0700 (PDT), David Miller wrote:
>>>> As you say the apps are broken, so file a bug and have them fixed.
>>>>
>>>> The assumption is clearly invalid, so apps cannot make such an
>>>> assumption.
>>>
>>> Does it mean you would be okay with a patch that always allocates a=
nd
>>> assigns a new ifindex in the target netns when interface is moved
>>> between name spaces?
>>
>> I think you're misunderstanding me if you're still recommending
>> kernel changes.
>>
>> I'm plainly saying to remove the assumption in the apps.
>>
>> If you don't show me exactly how some kernel change can lead to
>> the apps implementing things properly, without the invalid
>> assumptions, then I can only assume you didn't hear what I
>> said.
>
> I think the reason why ifindexes exists as ints is that we want to ha=
ve
> lightweight way to refer to interfaces without taking references or
> timestamps or generation ids which completely remove the possibility =
for
> races. But the racy nature in ifindexes is something we actually want=
,
> otherwise a user space program acquiring an ifindex would need to get=
 a
> reference on the device and either during socket close or program
> termination release it, that would be very costly.
>
> This patch minimizes the race quite a lot, from something we could
> actually see in everydays container creation to probably something on=
ly
> some users will expire with depleting the ifindex pool or playing aro=
und
> with CRIU.
>
> We could come up with more heavy machinery to close the race further =
for
> CRIU by keeping track of "poisoned" ifindexes, which would need a
> hashmap which could become pretty big and we could recycle when ifind=
ex
> wraps around, but this seems too heavy weight to me.
>
> I am in favor of a solution to minimize this race in the kernel even
> though we cannot ever close it completely.
I probably miss something, but if the app listens netlink, I don't see =
how such
app may have a race window.

With the proposed scenario:
1. create netns 'new_netns'
2. in root netns, move the interface with ifindex 2 to new_netns
3. in new_netns, delete the interface with ifindex 2
4. in new_netns, create an interface - it will get ifindex 2

Operation 2 and 4 are done by dev_change_net_namespace() under rtnl_loc=
k().
RTM_DELLINK(root netns) and RTM_NEWLINK(new_netns) are sent by this fun=
ction.
It means that operation 3 has been done before and that RTM_DELLINK(new=
_netns)
has been sent before.

Regards,
Nicolas
