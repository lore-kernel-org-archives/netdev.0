From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 12:47:29 +0200
Message-ID: <1272710849.2230.143.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272548258.4258.185.camel@bigi> <1272548980.2222.87.camel@edumazet-laptop>
	 <1272549408.4258.189.camel@bigi> <1272573383.3969.8.camel@bigi>
	 <1272655814.3879.8.camel@bigi> <1272660000.2230.4.camel@edumazet-laptop>
	 <1272672394.14499.1.camel@bigi> <1272693424.2230.75.camel@edumazet-laptop>
	 <1272694442.2230.86.camel@edumazet-laptop>
	 <o2u412e6f7f1005010324sfb63393fo86acdff4c97c5be3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:47645 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab0EAKrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 06:47:42 -0400
Received: by bwz19 with SMTP id 19so541520bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 03:47:41 -0700 (PDT)
In-Reply-To: <o2u412e6f7f1005010324sfb63393fo86acdff4c97c5be3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 18:24 +0800, Changli Gao a =C3=A9crit :
> On Sat, May 1, 2010 at 2:14 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >
> > BTW, using ee mask, cpu4 is not used at _all_, even for the user
> > threads. Scheduler does a bad job IMHO.
> >
> > Using fe mask, I get all packets (sent at 733311pps by my pktgen
> > machine), and my CPU0 even has idle time !!!
> >
> > Limit seems to be around 800.000 pps
> >
> > -------------------------------------------------------------------=
-----------------------------------------------------
> >   PerfTop:    5616 irqs/sec  kernel:93.9% [1000Hz cycles],  (all, 8=
 CPUs)
> > -------------------------------------------------------------------=
-----------------------------------------------------
> >
>=20
> Oh, cpu0 usage is about 100-(100-93.9)*8 =3D 51.2%(Am I right?). If w=
e
> can do weighted packet distributing: cpu0's weight is 1, and other
> cpus are 2. maybe we can utilize all the cpu power.
>=20

Nope, cpu0 was at 100% in this test, other cpus were about at 50% each.

weigthed would be ok if I wanted to use cpu0 in the 'slave' cpus (RPS
targets). But I know the workload I am interested to, and ability to
resist to DDOS, want to keep cpu0 outside of IP/TCP/UDP stack.


Later, skb_pull() inline in eth_type_trans() permitted to reach 840.000
pps.

top - 12:42:55 up  3:00,  2 users,  load average: 0.44, 0.11, 0.03
Tasks: 126 total,   1 running, 125 sleeping,   0 stopped,   0 zombie
Cpu(s):  2.2%us, 16.5%sy,  0.0%ni, 46.5%id, 11.4%wa,  0.9%hi, 22.5%si,
0.0%st
Mem:   4148112k total,   211152k used,  3936960k free,    15228k buffer=
s
Swap:  4192928k total,        0k used,  4192928k free,   121804k cached

You can see average idle of 46%
So there is probably more optimizations to do to reach maybe 1.300.000
pps ;)



