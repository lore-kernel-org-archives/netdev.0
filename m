From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Thu, 17 Oct 2013 18:05:16 +0200
Message-ID: <52600ABC.1030701@6wind.com>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>	<20131008.152349.729447337097758010.davem@davemloft.net>	<20131008141337.1a8a556c@nehalam.linuxnetplumber.net>	<20131009165254.2e1c8332@nehalam.linuxnetplumber.net>	<87li22vv1w.fsf@xmission.com> <525D7109.4010004@6wind.com>	<87a9ias274.fsf@xmission.com> <525E659C.3000305@6wind.com> <87txghm1qw.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, yamato@redhat.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:39231 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757703Ab3JQQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 12:05:32 -0400
Received: by mail-wg0-f49.google.com with SMTP id x12so2482784wgg.4
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 09:05:31 -0700 (PDT)
In-Reply-To: <87txghm1qw.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/10/2013 21:53, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 15/10/2013 22:34, Eric W. Biederman a =C3=A9crit :
>
>>> For IFLA_NET_NS_FD not that I know of.
>>>
>>> Mostly it is doable but there are some silly cases.
>>> - Do we need to actually implement SCM_RIGHTS to prevent people
>>>     accepting file-descriptors unknowingly and hitting their file
>>>     descriptor limits.
>>>
>>>     In which case we need to call the attribute IFLA_NET_NS_SCM_FD
>>>     so we knew it was just an index into the passed file descriptor=
s.n
>>>
>>> - Do we need an extra permission check to prevent keeping a network
>>>     namespace alive longer than necessary?  Aka there are some perm=
ission
>>>     checks opening and bind mounting /proc/<pid>/ns/net do we need
>>>     a similar check.  Perhaps we would need to require CAP_NET_ADMI=
N over
>>>     the target network namespace.
>>>
>>> Beyond that it is just the logistics to open what is essentially
>>> /proc/<pid>/ns/net and add it to the file descriptor table of the
>>> requesting process.  Exactly which mount of proc we are going to
>>> find the appropriate file to open I don't know.
>>>
>>> It isn't likely to be lots of code but it is code that the necessar=
y
>>> infrastructure is not in place for, and a bunch of moderately hairy
>>> corner cases to deal with.
>> Got it. This doesn't seems the simpliest/best way to resolve this pb=
=2E
>> Can we not introduce another identifier (something like IFLA_NET_NS_=
ID),
>> which will not have such constraint?
>> inode is unique on the system, why not using it as an opaque value t=
o
>> identitfy the netns (like 'ip netns identify' do)?
>
> The age old question why can't we have global identifiers for
> namespaces?
>
> The answer is that I don't want to implement a namespace for namespac=
es.
Sorry, but I don't understand the problem. This ID is owned by the kern=
el, like
the netns list (for_each_net()) is owned by it.

>
> While the proc inode does work today across different mounts of proc,=
 I
> reserve the right at some future date (if it solves a technical probl=
em)
> to give each namespace a different inode number in each different mou=
nt
> of proc.  So the inode number is not quite the unique identifier you
> want.  The inode number is a close as I am willing to get to a namesp=
ace
> of namespaces.
>
> I think the simplest solution is to just not worry about which namesp=
ace
> the other half of a veth pair is in.  But I have not encountered the
> problem where I need to know exactly which namespace we are worrying
> about.
Ok, let's start by explaining our usecase.

We are using namespaces only to implement virtual routers (VR), ie only
the networking stack is virtualized. We don't care about other namespac=
es, we
just want to run several network stacks and beeing able to manage them.

=46or example, providers use this feature to isolate clients, one VR is=
 opened
for each client. You can have a large number of clients (+10 000) and t=
hus the
same number of netns.
Considering these numbers, we don't want to run one instance per VR for=
 all of
our network daemons, but have only one instance that manage all VR.

You also have daemons that monitor the system and synchronize network o=
bjects
(interfaces, routes, etc.) on another linux. Goal is to implement an hi=
gh
availablity system: it's possible to switch to the other linux to avoid=
 service
interruption.
This kind of daemon wants to have the full information about interfaces=
 to be
able to build/configure them on the other linux.

>
> Global identifiers are easy until you hit the cases where they make
> things impossible.
I don't want specially to use ID, but I fear that the solution with fil=
e
descriptors will be a nightmare.


Nicolas
