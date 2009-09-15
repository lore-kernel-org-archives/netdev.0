From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Tue, 15 Sep 2009 21:02:15 +0200
Message-ID: <4AAFE4B7.50606@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com> <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1> <4AAF263E.9010405@gmail.com> <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1> <4AAFCE3A.8060102@gmail.com> <alpine.DEB.1.10.0909151550200.3340@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43171 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758079AbZIOVCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 17:02:17 -0400
In-Reply-To: <alpine.DEB.1.10.0909151550200.3340@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 15 Sep 2009, Eric Dumazet wrote:
>=20
>> Once I understood my 2.6.31 kernel had much more features than 2.6.2=
2 and that I tuned
>> it to :
>>
>> - Let cpu run at full speed (3GHz instead of 2GHz) : before tuning, =
2.6.31 was
>> using "ondemand" governor and my cpus were running at 2GHz, while th=
ey where
>> running at 3GHz on my 2.6.22 config
>=20
> My kernel did not have support for any governors compiled in.
>=20
>> - Dont let cpus enter C2/C3 wait states (idle=3Dmwait)
>=20
> Ok. Trying idle=3Dmwait.
>=20
>> - Correctly affine cpu to ethX irq (2.6.22 was running ethX irq on o=
ne cpu, while
>>  on 2.6.31, irqs were distributed to all online cpus)
>=20
> Interrupts of both 2.6.22 and 2.6.31 go to cpu 0. Does it matter for
> loopback?

No of course, loopback triggers softirq on the local cpu, no special se=
tup
to respect.

>=20
>> Then, your mcast test gives same results, at 10pps, 100pps, 1000pps,=
 10000pps
>=20
> loopback via mcast -Ln1 -r <rate>
>=20
> 		10pps	100pps	1000pps	10000pps
> 2.6.22(32bit)	7.36	7.28	7.15	7.16
> 2.6.31(64bit)	9.28	10.27	9.70	9.79
>=20
> What a difference. Now the initial latency rampup for 2.6.31 is gone.=
 So
> even w/o governors the kernel does something to increase the latencie=
s.
>=20
> We sacrificed 2 - 3 microseconds per message to kernel features, bloa=
t and
> 64 bitness?

Well, I dont know, I mainly use 32bits kernel, but yes, using 64bits ha=
s a cost,
since skbs for example are bigger, sockets are bigger, so we touch more=
 cache lines
per transaction...


You could precisely compute number of cycles per transaction, with "per=
f" tools
(only on 2.6.31), between 64bit and 32bit kernels, benching 100000 pps =
for example
and counting number of perf counter irqs per second
