From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel side)
Date: Thu, 17 Oct 2013 12:28:54 -0700
Message-ID: <8738nzelxl.fsf@xmission.com>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>
	<20131008.152349.729447337097758010.davem@davemloft.net>
	<20131008141337.1a8a556c@nehalam.linuxnetplumber.net>
	<20131009165254.2e1c8332@nehalam.linuxnetplumber.net>
	<87li22vv1w.fsf@xmission.com> <525D7109.4010004@6wind.com>
	<87a9ias274.fsf@xmission.com> <525E659C.3000305@6wind.com>
	<87txghm1qw.fsf@xmission.com> <52600ABC.1030701@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, yamato@redhat.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50335 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861Ab3JQT3E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:29:04 -0400
In-Reply-To: <52600ABC.1030701@6wind.com> (Nicolas Dichtel's message of "Thu,
	17 Oct 2013 18:05:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 16/10/2013 21:53, Eric W. Biederman a =C3=A9crit :

>> The age old question why can't we have global identifiers for
>> namespaces?
>>
>> The answer is that I don't want to implement a namespace for namespa=
ces.
> Sorry, but I don't understand the problem. This ID is owned by the ke=
rnel, like
> the netns list (for_each_net()) is owned by it.

The scenario where problem are likely to show up is something like this=
=2E

=46or testing it would be reasonable to setup two linux containers that
look like full linux systems.  In those containers you run one instance
of your virtual router managment daemons, and you arrange to synchroniz=
e
between the two linux containers for testing.

It becomes even more interesting when we want to migrate one of those
linux containers to another physical machine.

Global identifiers start breaking the first scenario, and really trash
the second scenario.

At the same time migration of configuration and replication of
configuration are essentially the same problem, so it would be very
silly to design such that will cause problems.

>> While the proc inode does work today across different mounts of proc=
, I
>> reserve the right at some future date (if it solves a technical prob=
lem)
>> to give each namespace a different inode number in each different mo=
unt
>> of proc.  So the inode number is not quite the unique identifier you
>> want.  The inode number is a close as I am willing to get to a names=
pace
>> of namespaces.
>>
>> I think the simplest solution is to just not worry about which names=
pace
>> the other half of a veth pair is in.  But I have not encountered the
>> problem where I need to know exactly which namespace we are worrying
>> about.
> Ok, let's start by explaining our usecase.
>
> We are using namespaces only to implement virtual routers (VR), ie on=
ly
> the networking stack is virtualized. We don't care about other namesp=
aces, we
> just want to run several network stacks and beeing able to manage the=
m.
>
> For example, providers use this feature to isolate clients, one VR is=
 opened
> for each client. You can have a large number of clients (+10 000) and=
 thus the
> same number of netns.
> Considering these numbers, we don't want to run one instance per VR f=
or all of
> our network daemons, but have only one instance that manage all VR.
>
> You also have daemons that monitor the system and synchronize network=
 objects
> (interfaces, routes, etc.) on another linux. Goal is to implement an =
high
> availablity system: it's possible to switch to the other linux to avo=
id service
> interruption.
> This kind of daemon wants to have the full information about interfac=
es to be
> able to build/configure them on the other linux.
>
>>
>> Global identifiers are easy until you hit the cases where they make
>> things impossible.
> I don't want specially to use ID, but I fear that the solution with f=
ile
> descriptors will be a nightmare.

I can certainly see challenges.  In asking for symmetry between set and
get the solution with file descriptors is the obvious answer and the
first answer I have been able to come up with so far.

My original answer was that the ifindex happened to be unique across
namespaces but that actually turned out to be a problem for migration
so that abandoned.

Namespace file descriptors are the solution that I know semantically
will work.  Beyond that I don't have any good ideas right now.

I just know that local names (aka file descriptors) are much easier to
work with semantically than global names.

Eric
