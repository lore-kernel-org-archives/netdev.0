From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 21 Apr 2010 21:01:20 +0200
Message-ID: <1271876480.7895.3106.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271764941.3735.94.camel@bigi> <1271769195.7895.4.camel@edumazet-laptop>
	 <1271853570.4032.21.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:40346 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab0DUTBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:01:33 -0400
Received: by bwz1 with SMTP id 1so10539679bwz.2
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 12:01:31 -0700 (PDT)
In-Reply-To: <1271853570.4032.21.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 08:39 -0400, jamal a =C3=A9crit :
> On Tue, 2010-04-20 at 15:13 +0200, Eric Dumazet wrote:
>=20
>=20
> > I think your tests are very interesting, maybe could you publish th=
em
> > somehow ? (I forgot to thank you about the previous report and nice
> > graph)
> > perf reports would be good too to help to spot hot points.
>=20
> Ok ;->
> Let me explain my test setup (which some app types may gasp at;->):
>=20
> SUT(system under test) was a nehalem single processor (4 cores, 2 SMT
> threads per core).=20
> SUT runs a udp sink server i wrote (with apologies to Rick Jones[1])
> which forks at most a process per detected cpu and binds to a differe=
nt
> udp port on each processor.
> Traffic generator sent to SUT upto 750Kpps of udp packets round-robbi=
n
> and varied the destination port to select a different flow on each of
> the outgoing packets. I could further increment the number of flows b=
y
> varying the source address and source port number but in the end i=20
> settled down to fixed srcip/srcport/destinationip and just varied the
> port number in order to simplify results collection.
> For rps i selected mask "ee" and bound interrupt to cpu0. ee leaves
> out cpu0 and cpu4 from the set of target cpus. Because Nehalem has SM=
T
> threads, cpu0 and cpu4 are SMT threads that reside on core0 and they
> steal execution cycles from each other - so i didnt want that to happ=
en
> and instead tried to have as many of those cycles as possible for
> demuxing incoming packets.
>=20
> Overall, in best case scenario rps had 5-7% better throughput than
> nonrps setup. It had upto 10% more cpu use and about 2-5% more latenc=
y.
> I am attaching some visualization of the way 8 flows were distributed
> around the different cpus. The diagrams show some samples - but what =
you
> see there was a good reflection of what i saw in many runs of the tes=
ts.
> Essentially, for localization is better with rps which gets better if
> you can somehow map the target cpus as selected by rps to what the ap=
p
> binds to.
> Ive also attached a small annotated perf output - sorry i didnt have
> time to dig deeper into the code; maybe later this week. I think my
> biggest problem in this setup was the sky2 driver or hardware poor
> ability to handle lots of traffic.
>=20
>=20
> cheers,
> jamal
>=20
> [1] I want to hump on the SUT with tons of traffic and count packets;
> too complex to do with netperf

Thanks a lot Jamal, this is really useful

Drawback of using a fixed src ip from your generator is that all flows
share the same struct dst entry on SUT. This might explain some glitche=
s
you noticed (ip_route_input + ip_rcv at high level on slave/application
cpus)
Also note your test is one way. If some data was replied we would see
much use of the 'flows'

I notice epoll_ctl() used a lot, are you re-arming epoll each time you
receive a datagram ?

I see slave/application cpus hit _raw_spin_lock_irqsave() and =20
_raw_spin_unlock_irqrestore().

Maybe a ring buffer could help (instead of a double linked queue) for
backlog, or the double queue trick, if Changli wants to respin his
patch.





