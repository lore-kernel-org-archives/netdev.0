From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 22:57:17 +0200
Message-ID: <1272056237.4599.7.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:40249 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab0DWU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 16:57:22 -0400
In-Reply-To: <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 22:38 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :

>=20
> I think its plausable, there is a lot of modification going on.
> Approx 40.000 deletes/sec and 40.000 inserts/sec.
> The hash bucket size is 300032, and with 80000 modifications/sec, we =
are=20
> (potentially) changing 26.6% of the hash chains each second.
>=20
> As can be seen from the graphs:
>   http://people.netfilter.org/hawk/DDoS/2010-04-12__001/list.html
>=20
> Notice that primarily CPU2 is doing the 40k deletes/sec, while CPU1 i=
s=20
> caught searching...
>=20
>=20
> > maybe hash table has one slot :)
>=20
> Guess I have to reproduce the DoS attack in a testlab (I will first h=
ave=20
> time Tuesday).  So we can determine if its bad hashing or restart of =
the=20
> search loop.
>=20
>=20
> The traffic pattern was fairly simple:
>=20
> 200 bytes UDP packets, comming from approx 60 source IPs, going to on=
e=20
> destination IP.  The UDP destination port number was varied in the ra=
nge=20
> of 1 to 6000.   The source UDP port was varied a bit more, some rangi=
ng=20
> from 32768 to 61000, and some from 1028 to 5000.
>=20
>=20

Re-reading this, I am not sure there is a real problem on RCU as you
pointed out.

With 800.000 entries, in a 300.032 buckets hash table, each lookup hit
about 3 entries (aka searches in conntrack stats)

300.000 packets/second -> 900.000 'searches' per second.

If you have four cpus all trying to insert/delete entries in //, they
all hit the central conntrack lock.

On a DDOS scenario, every packet needs to take this lock twice,
once to free an old conntrack (early drop), once to insert a new entry.

To scale this, only way would be to have an array of locks, like we hav=
e
for TCP/UDP hash tables.

I did some tests here, with a multiqueue card, flooded with 300.000
pack/second, 65.536 source IP, millions of flows, and nothing wrong
happened (but packets drops, of course)

My two cpus were busy 100%, after tweaking smp_affinities, because on
first try, irqbalance put "01" mask on both queues, so only one ksoftir=
q
was working, other cpu was idle :(



