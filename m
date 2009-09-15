From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Tue, 15 Sep 2009 19:26:18 +0200
Message-ID: <4AAFCE3A.8060102@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com> <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1> <4AAF263E.9010405@gmail.com> <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44343 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758623AbZIOT0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 15:26:51 -0400
In-Reply-To: <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 15 Sep 2009, Eric Dumazet wrote:
>=20
>> 2.6.31 is actually faster than 2.6.22 on the bench you provided.
>=20
> Well at high packet rates which were not the topic.
>=20
>> Must be specific to the hardware I guess ?
>=20
> Huh? Even your loopback numbers did show the regression up to 10k.
>=20
>> As text size presumably is bigger in 2.6.31, fetching code
>> in cpu caches to handle 10 packets per second is what we call
>> a cold path anyway.
>=20
> Ok so its an accepted regression? This is a significant reason not to=
 use
> newer versions of kernels for latency critical applications that may =
have
> to send a packet once in a while for notification. The latency is dou=
bled
> (1G) / tripled / quadrupled (IB) vs 2.6.22.
>=20
>> If you want to make it a fast path, you want to make sure code its
>> always hot in cpu caches, and find a way to inject packets into
>> the kernel to make sure cpu keep the path hot.
>=20
> Oh, gosh.

It seems there is a lot of confusion on this topic, so I will make a fu=
ll recap :

Once I understood my 2.6.31 kernel had much more features than 2.6.22 a=
nd that I tuned
it to :

- Let cpu run at full speed (3GHz instead of 2GHz) : before tuning, 2.6=
=2E31 was=20
using "ondemand" governor and my cpus were running at 2GHz, while they =
where
running at 3GHz on my 2.6.22 config

- Dont let cpus enter C2/C3 wait states (idle=3Dmwait)

- Correctly affine cpu to ethX irq (2.6.22 was running ethX irq on one =
cpu, while
 on 2.6.31, irqs were distributed to all online cpus)


Then, your mcast test gives same results, at 10pps, 100pps, 1000pps, 10=
000pps

When sniffing receiving side, I can notice :

- Answer to an icmp ping (served by softirq only) : 6 us between reques=
t and reply

- Answer to one 'give timestamp' request from mcast client : 11 us betw=
en request and reply,
  regardless of kernel version (2.6.22 or 2.6.31)

So there is a 5us cost to actually wakeup a process and let him do the =
recvfrom() and sendto() pair,
which is quite OK, and this time was not significantly changed between =
2.6.22 and 2.6.31

Hope this helps
