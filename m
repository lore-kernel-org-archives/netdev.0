From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 20:46:34 +0200
Message-ID: <49ECC30A.9040501@cosmosbay.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com> <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com> <alpine.DEB.1.10.0904201410430.3361@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48255 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbZDTSrX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 14:47:23 -0400
In-Reply-To: <alpine.DEB.1.10.0904201410430.3361@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Mon, 20 Apr 2009, Eric Dumazet wrote:
>=20
>>> Sounds very good. If I just knew what you are measuring.
>> Rephrasing my email, I was measuring latencies on the receiving mach=
ine,
>> by using tcpdump and doing substraction of 'answer_time' and 'reques=
t_time'
>> Thing is that timestamps dont care about hardware delays.
>> (we note time when RX interrupt delivers the packet, and time right =
before giving frame to hardware)
>>
>>
>> 21:04:23.780421 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, l=
ength 300   (request)
>> 21:04:23.780428 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, l=
ength 300   (answer)
>>
>> Here, [21:04:23.780428 - 21:04:23.780421] =3D 7 us
>>
>> So my results are extensively published :)
>=20
> But they are not comparable with my results. There could be other eff=
ects
> in the system call API etc that have caused this regression. Plus tcp=
dump
> causes additional copies of the packet to be delivered to user space.

Yep, this was all mentioned in my mail.
I wanted to compare latencies on receiver only, ruling out hardware, an=
d ruling out sender (no need to reboot it)
These latencies are higher than ones without tcpdump, since more copies=
 are involved with tcpdump.

About system call API effects, they are included in my tests.
Since :

t0 : time we receive packet from NIC
  -> wakeup user process, scheduler...
     User process returns from the recvfrom()  copy from system to user=
 space
     User process does the sendto()    copy from user to system space

t1:  -> calling dev_start_xmit()
     packet given to NIC driver (idle during the tests, so should reall=
y send the packet asap)

     User call again recvfrom() and block (this one is not accounted in=
 latency, as in your test)
t2: NIC driver acknowledge the TX=20

delta =3D t1 - t0

One thing that could hurt is the TX done interrupt, but this is done a =
few us after "t1" so it
doesnt hurt your workload, since next frame is received at least 100us =
after the last answer...

(cpu is idle 99%)

Point is that even with tcpdump running, latencies are very good on 2.6=
=2E30-rc2, and were very good
with 2.6.22. I see no significant increase/decrease...


>=20
>>> CONFIG_HPET_TIMER=3Dy
>>> CONFIG_HPET_EMULATE_RTC=3Dy
>>> CONFIG_NR_CPUS=3D32
>>> CONFIG_SCHED_SMT=3Dy
>> OK, I had "# CONFIG_SCHED_SMT is not set"
>> I'll try with this option set
>=20
> Should not be relevant since the processor has no hyperthreading.
>=20
>> Are you running a 32 or 64 bits kernel ?
>=20
> Test was done using a 64 bit kernel.

Ok, I'll try 64bit too :)

1 us is time to access about 10 false shared cache lines.
64 bit arches store less pointers/long per cache line.
So a 64 bit kernel could be slower on this kind of workload in the gene=
ral case (if several cpus play the game)


