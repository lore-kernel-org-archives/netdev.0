From: =?UTF-8?B?TWFydGluIE1PS1JFSsWg?= <mmokrejs@ribosome.natur.cuni.cz>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0: (sk_lock-AF_PACKET){--..},
 at: [<c1279838>] sock_setsockopt+0x12b/0x4a4
Date: Tue, 27 Jan 2009 22:53:44 +0100
Message-ID: <497F8268.6010803@ribosome.natur.cuni.cz>
References: <bug-12515-10286@http.bugzilla.kernel.org/> <20090127134342.e24b158c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	a.p.zijlstra@chello.nl, Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ribosome.natur.cuni.cz ([195.113.57.20]:52347 "EHLO
	ribosome.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbZA0Vxw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 16:53:52 -0500
In-Reply-To: <20090127134342.e24b158c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been some discussion under subject
"Re: [PATCH] net: fix setsockopt() locking errors"
and I hope it is archived somewhere via netdev@vger.kernel.org .
If not, Jarek Poplawski and Peter Zijlstra have some clues
what to do and I am waiting for Vegard Nossum to give me
another patch to test.


Here is some part of the discussion ,hopefully the most important
part:

On Tue, Jan 27, 2009 at 09:52:49AM +0100, Peter Zijlstra wrote:
> > On Tue, 2009-01-27 at 08:45 +0000, Jarek Poplawski wrote:
>> > > On Mon, Jan 26, 2009 at 10:30:30PM +0100, Martin MOKREJ=C5=A0 wr=
ote:
>>> > > > The patch really did not help:
>>> > > > http://bugzilla.kernel.org/show_bug.cgi?id=3D12515#c5
>>> > > > Martin
>> > >=20
>> > > Actually, there is a little change: the warning triggerd in anot=
her
>> > > place (sock_setsockopt() -> sk_attach_filter()). So we could go =
deeper
>> > > with these changes, but I'm not sure this is the right way to fi=
x.
>> > >=20
>> > > It looks like the scenario is very old, but probably wasn't repo=
rted
>> > > (maybe there is some lockdep improvement):
> >=20
> > Yes, they likely are very old, and yes we added a lockdep annotatio=
n to
> > copy_to/from_user() to catch these.
> >=20
>> > > A) sys_mmap2() -> mm->mmap_sem -> packet_mmap() -> sk_lock
>> > > B) sock_setsockopt() -> sk_lock -> copy_from_user() -> mm->mmap_=
sem
>> > >=20
>> > > packet_mmap() (net/packet/af_packet.c) seems to be the only plac=
e in
>> > > net to implement mmap method, and using this lock order btw. On =
the
>> > > other hand copy_from_user() could be more popular under sk_lock,=
 and
>> > > I'm not sure these changes are necessary.
>> > >=20
>> > > Since I don't know enough neither sock/packet nor sys_mmap, I gu=
ess
>> > > some advice would be precious. It looks like Peter Zijlstra solv=
ed
>> > > similar problems in nfs, so I CC him.
> >=20
> > The NFS/sunrpc case was special in that it did copy_to/from_kernel,=
 that
> > is, it never actually touched user memory -- we taught the might_fa=
ult()
> > annotation about that.
> >=20
> > Can't you simply do the copy_from_user() before you take the sk_loc=
k?
> >=20

Since it's really needed, and Vegard started doing it like this, I
guess he will try to add the missing pieces.

Thanks again,
Jarek P.





Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Tue, 20 Jan 2009 10:16:38 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
>=20
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D12515
>>
>>            Summary: possible circular locking #0:  (sk_lock-AF_PACKE=
T){--
>>                     ..}, at: [<c1279838>] sock_setsockopt+0x12b/0x4a=
4
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.29-rc1-git4
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger@linux-foundation.org
>>         ReportedBy: mmokrejs@ribosome.natur.cuni.cz
>>
>>
>> Latest working kernel version:
>> Earliest failing kernel version:
>> Distribution: Gentoo Linux
>> Hardware Environment: ASUS L3C/S laptop
>> Software Environment:
>> Problem Description:
>>
>> Steps to reproduce: I have been reinstalling some apps while started=
 tcpdump.
>> It immediately hit the bug.
>>
>=20
> More info at the link.  Vegard did some analysis, had a shot at fixin=
g
> it, but it seems that he missed.

