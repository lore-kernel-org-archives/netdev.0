From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Mon, 02 Feb 2009 22:31:41 +0100
Message-ID: <4987663D.6080802@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com> <4987610D.6040902@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wes Chow <wchow@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60389 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756727AbZBBVbv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:31:51 -0500
In-Reply-To: <4987610D.6040902@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wes Chow a =E9crit :
>=20
>=20
> Eric Dumazet wrote:
>> Wes Chow a =E9crit :
>>> (I'm Kenny's colleague, and I've been doing the kernel builds)
>>>
>>> First I'd like to note that there were a lot of bnx2 NAPI changes
>>> between 2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amounts
>>> of packet loss,
>>> whereas loss in 2.6.22 is significant.
>>>
>>> Second, some CPU affinity info: if I do like Eric and pin all of th=
e
>>> apps onto a single CPU, I see no packet loss. Also, I do *not* see
>>> ksoftirqd show up on top at all!
>>>
>>> If I pin half the processes on one CPU and the other half on anothe=
r
>>> CPU, one ksoftirqd processes shows up in top and completely pegs on=
e
>>> CPU. My packet loss
>>> in that case is significant (25%).
>>>
>>> Now, the strange case: if I pin 3 processes to one CPU and 1 proces=
s
>>> to another, I get about 25% packet loss and ksoftirqd pins one CPU.
>>> However, one
>>> of the apps takes significantly less CPU than the others, and all
>>> apps lose the
>>> *exact same number of packets*. In all other situations where we se=
e
>>> packet
>>> loss, the actual number lost per application instance appears rando=
m.
>>
>> You see same number of packet lost because they are lost at NIC leve=
l
>=20
> Understood.
>=20
> I have a new observation: if I pin processes to just CPUs 0 and 1, I =
see
> no packet loss. Pinning to 0 and 2, I do see packet loss. Pinning 2 a=
nd
> 3, no packet loss. 4 & 5 - no packet loss, 6 & 7 - no packet loss. An=
y
> other combination appears to produce loss (though I have not tried al=
l
> 28 combinations, this seems to be the case).
>=20
> At first I thought maybe it had to do with processes pinned to the sa=
me
> CPU, but different cores. The machine is a dual quad core, which mean=
s
> that CPUs 0-3 should be a physical CPU, correct? Pinning to 0/2 and 0=
/3
> produce packet loss.

a quad core is really a 2 x 2 core

L2 cache is splited on two blocks, one block used by CPU0/1, other by C=
PU2/3=20

You are at the limit of the machine with such workload, so as soon as y=
our
CPUs have to transfert 64 bytes lines between those two L2 blocks, you =
loose.


>=20
> I've also noticed that it does not matter which of the working pairs =
I
> pin to. For example, pinning 5 processes in any combination on either
> 0/1 produce no packet loss, pinning all 5 to just CPU 0 also produces=
 no
> packet loss.
>=20
> The failures are also sudden. In all of the working cases mentioned
> above, I don't see ksoftirqd on top at all. But when I run 6 processe=
s
> on a single CPU, ksoftirqd shoots up to 100% and I lose a huge number=
 of
> packets.
>=20
>>
>> Normaly, softirq runs on same cpu (the one handling hard irq)
>=20
> What determines which CPU the hard irq occurs on?
>=20

Check /proc/irq/{irqnumber}/smp_affinity

If you want IRQ16 only served by CPU0 :

echo 1 >/proc/irq/16/smp_affinity

