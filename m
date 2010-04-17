From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sat, 17 Apr 2010 09:35:39 +0200
Message-ID: <1271489739.16881.4586.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:40082 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990Ab0DQHfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 03:35:47 -0400
Received: by bwz25 with SMTP id 25so3853914bwz.28
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 00:35:46 -0700 (PDT)
In-Reply-To: <1271424065.4606.31.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 09:21 -0400, jamal a =C3=A9crit :
> On Fri, 2010-04-16 at 07:18 +0200, Eric Dumazet wrote:
>=20
> >=20
> > A kernel module might do this, this could be integrated in perf ben=
ch so
> > that we can regression tests upcoming kernels.
>=20
> Perf would be good - but even softnet_stat cleaner than the the nasty
> hack i use (attached) would be a good start; the ping with and withou=
t
> rps gives me a ballpark number.
>=20
> IPI is important to me because having tried it before it and failed
> miserably. I was thinking the improvement may be due to hardware used
> but i am having a hard time to get people to tell me what hardware th=
ey
> used! I am old school - I need data;-> The RFS patch commit seems to
> have more info but still vague, example:=20
> "The benefits of RFS are dependent on cache hierarchy, application
> load, and other factors"
> Also, what does a "simple" or "complex" benchmark mean?;->
> I think it is only fair to get this info, no?
>=20
> Please dont consider what i say above as being anti-RPS.
> 5 microsec extra latency is not bad if it can be amortized.
> Unfortunately, the best traffic i could generate was < 20Kpps of
> ping which still manages to get 1 IPI/packet on Nehalem. I am going
> to write up some app (lots of cycles available tommorow). I still thi=
nk
> it is valueable.

I did some tests on a dual quad core machine (E5450  @ 3.00GHz), not
nehalem. So a 3-4 years old design.

=46or all test, I use the best time of 3 runs of "ping -f -q -c 100000
192.168.0.2". Yes ping is not very good, but its available ;)

Note: I make sure all 8 cpus of target are busy, eating cpu cycles in
user land. I dont want to tweak acpi or whatever smart power saving
mechanisms.

When RPS off
100000 packets transmitted, 100000 received, 0% packet loss, time 4160m=
s

RPS on, but directed on the cpu0 handling device interrupts (tg3, napi)
(echo 01 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
100000 packets transmitted, 100000 received, 0% packet loss, time 4234m=
s

So the cost of queing the packet into our own queue (netif_receive_skb
-> enqueue_to_backlog) is about 0.74 us  (74 ms / 100000)

I personally think we should process packet instead of queeing it, but
Tom disagree with me.

RPS on, directed on cpu1 (other socket)
(echo 02 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
100000 packets transmitted, 100000 received, 0% packet loss, time 4542m=
s

So extra cost to enqueue to a remote cpu queue, IPI, softirq handling..=
=2E
is 3 us. Note this cost is in case we receive a single packet.

I suspect IPI itself is in the 1.5 us range, not very far from the
queing to ourself case.

=46or me RPS use cases are :

1) Value added apps handling lot of TCP data, where the costs of cache
misses in tcp stack easily justify to spend 3 us to gain much more.

2) Network appliance, where a single cpu is filled 100% to handle one
device hardware and software/RPS interrupts, delegating all higher leve=
l
works to a pool of cpus.

I'll try to do these tests on a Nehalem target.



