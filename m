From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Fri, 30 Jan 2009 20:04:15 +0100
Message-ID: <49834F2F.9070500@cosmosbay.com>
References: <49833DBC.7040607@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52113 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbZA3TEW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 14:04:22 -0500
In-Reply-To: <49833DBC.7040607@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kenny Chang a =E9crit :
> Hi all,
>=20
> We've been having some issues with multicast packet loss, we were won=
dering
> if anyone knows anything about the behavior we're seeing.
>=20
> Background: we use multicast messaging with lots of messages per sec =
for
> our
> work. We recently transitioned many of our systems from an Ubuntu Dap=
per
> Drake
> ia32 distribution to Ubuntu Hardy Heron x86_64. Since the transition,=
 we've
> noticed much more multicast packet loss, and we think it's related to=
 the
> transition. Our particular theory is that it's specifically a 32 vs 6=
4-bit
> issue.
>=20
> We narrowed the problem down to the attached program (mcasttest.cc). =
 Run
> "mcasttest server" on one machine -- it'll send 500,000 messages smal=
l
> message
> to a multicast group, 50,000 messages per second.  If we run "mcastte=
st
> client"
> on another machine, it'll receive all those messages and print a coun=
t
> at the
> end of how many messages it sees. It almost never loses any messages.
> However,
> if we run 4 copies of the client on the same machine, receiving the s=
ame
> data,
> then the programs usually sees fewer than 500,000 messages. We're
> running with:
>=20
> for i in $(seq 1 4); do (./mcasttest client &); done
>=20
> We know this because the program prints a count, but dropped packets =
also
> show up in ifconfig's "RX packets" section.
>=20
> Things we're curious about: do other people see similar problems?  Th=
e
> tests
> we've done: we've tried this program on a bunch of different machines=
,
> all of
> which are running either dapper ia32 or hardy x86_64. Uniformly, the =
dapper
> machines have no problems but on certain machines, Hardy shows
> significant loss. We did some experiments on a troubled machine, vary=
ing
> the OS install, including mixed installations where the kernel was
> 64-bit and the userspace was
> 32-bit. This is what we found:
>=20
> On machines that exhibit this problem, the ksoftirqd process seems to=
 be
> pegged to 100% CPU when receiving packets.
>=20
> Note: while we're on Ubuntu, we've tried this with other distros and
> have seen
> similar results, we just haven't tabulated them.
>=20
>> --------------------------------------------------------------------=
--------
>>
>> userland | userland arch | kernel           | kernel arch |
>> mode         =20
>> --------------------------------------------------------------------=
--------
>>
>> Dapper   |            32 | 2.6.15-28-server |          32 | no packe=
t
>> loss
>> Dapper   |            32 | 2.6.22-generic   |          32 | no packe=
t
>> loss Dapper   |            32 | 2.6.22-server    |          32 | no
>> packet loss Hardy    |            32 | 2.6.24-rt        |          3=
2
>> | no packet loss
>> Hardy    |            32 | 2.6.24-generic   |          32 | ~5% pack=
et
>> loss
>> Hardy    |            32 | 2.6.24-server    |          32 | ~10%
>> packet loss
>=20
>> Hardy    |            32 | 2.6.22-server    |          64 | no packe=
t
>> loss
>> Hardy    |            32 | 2.6.24-rt        |          64 | no packe=
t
>> loss
>> Hardy    |            32 | 2.6.24-generic   |          64 | 14% pack=
et
>> loss
>> Hardy    |            32 | 2.6.24-server    |          64 | 12% pack=
et
>> loss
>=20
>> Hardy    |            64 | 2.6.22-vanilla   |          64 | packet l=
oss
>> Hardy    |            64 | 2.6.24-rt        |          64 | ~5% pack=
et
>> loss
>> Hardy    |            64 | 2.6.24-server    |          64 | ~30%
>> packet loss
>> Hardy    |            64 | 2.6.24-generic   |          64 | ~5% pack=
et
>> loss
>> --------------------------------------------------------------------=
--------
>>
>=20
> It's not exactly clear what exactly the problem is but dapper shows n=
o
> issues regardless of what we try. For hardy, userspace seem to matter=
:
> 2.6.24-rt kernel shows no packet loss for 32&64bit kernels, as long a=
s
> the userspace is 32-bit.
>=20
> Kernel comments:
> 2.6.15-28-server: This is Ubuntu Dapper's stock kernel build.
> 2.6.24-*: This is Ubuntu Hardy's stock kernel.
> 2.6.22-{generic,server}: This is a custom, in-house kernel build, bui=
lt
> for ia32.
> 2.6.22-vanilla: This is our custom, in-house kernel build, built for
> x86_64.
>=20
> We don't think it's related to our custom kernels, because the same
> phenomena
> show up with the Ubuntu stock kernels.
>=20
> Hardware:
>=20
> The benchmark machine We've been using is an Intel Xeon E5440 @2.83GH=
z
> dual-cpu quad-core with Broadcom NetXtreme II BCM5708 bnx2 networking=
=2E
>=20
> We've also tried AMD machines, as well as machines with Tigon3
> partno(BCM95704A6) tg3 network cards, they all show consistent behavi=
or.
>=20
> Our hardy x86_64 server machines all appear to have this problem, new
> and old.
>=20
> On the other hand, a desktop with Intel Q6600 quad core 2.4GHz and In=
tel
> 82566DC GigE
> seem to work fine.
>=20
> All of the dapper ia32 machines have no trouble, even our older hardw=
are.
>=20
>

Hi Kenny

Interesting... You forgot the mcasttest.cc program

Any chance you try a recent kernel (2.6.29-rcX) ?

Could you post "cat /proc/interrupts" results (one for working
 setup, another for non working/droping setup)


