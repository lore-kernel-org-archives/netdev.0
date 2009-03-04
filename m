From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Wed, 04 Mar 2009 17:27:48 +0800
Message-ID: <1236158868.2567.93.camel@ymzhang>
References: <20090225063656.GA32635@gondor.apana.org.au>
	 <1235546423.2604.556.camel@ymzhang>
	 <20090224.233115.240823417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:59039 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753644AbZCDJ2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 04:28:14 -0500
In-Reply-To: <20090224.233115.240823417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-02-24 at 23:31 -0800, David Miller wrote:=20
> From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
> Date: Wed, 25 Feb 2009 15:20:23 +0800
>=20
> > If the machines might have a couple of NICs and every NIC has CPU_N=
UM queues,
> > binding them evenly might cause more cache-miss/ping-pong. I didn't=
 test
> > multiple receiving NICs scenario as I couldn't get enough hardware.
>=20
> In the net-next-2.6 tree, since we mark incoming packets with
> skb_record_rx_queue() properly, we'll make a more favorable choice of
> TX queue.
Thanks for your pointer. I cloned net-next-2.6 tree. =EF=BB=BFskb_recor=
d_rx_queue is a smart
idea to implement an auto TX selection.

There is no NIC multi-queue standard or RFC available. At least I didn'=
t find it
by google.

Both the new =EF=BB=BFskb_record_rx_queue and current kernel have an as=
sumption on
multi-queue. The assumption is it's best to send out packets from the T=
X of the
same number of queue like the one of RX if the receved packets are rela=
ted to
the out packets. Or more direct speaking is we need send packets on the=
 same cpu on
which we receive them. The start point is that could reduce skb and dat=
a cache miss.

With slow NIC, the assumption is right. But with high-speed NIC, especi=
ally 10G
NIC, the assumption seems not ok.

Here is a simple calculation with real testing/data with Nehalem machin=
e and Bensley
machine. There are 2 machines with the testing driven by pktgen.

		    	send packets
	Machine A   	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>		Machine B
		   =20
		    	forward pkts back
		    	<=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D	=09


With Nehalem machines, I can get 4 million pps (packets per second) and=
 per packet consists
of 60 bytes. So the speed is about 240MBytes/s. Nehalem has 2 sockets a=
nd every socket has
4 core and 8 logical cpu. All logical cpu share the last level cache 8M=
bytes. That means
every physical cpu receives 120M bytes per second which is 8 times of l=
ast level cache
size.

With Bensley machine, I can get 1.2M pps, or 72MBytes. That machine has=
 2 sockets and every
socket has a qual-core cpu. Every dual-core share the last level cache =
6MByte. That means
every dual-core gets 18M bytes per second, which is 3 times of last lev=
el cache size.

So with both bensley and Nehalem, the cache is flushed very quickly wit=
h 10G NIC testing.

Some other kinds of machines might have bigger cache. For example, my M=
ontvale Itanium has
2 sockets, and every socket has a qual-core cpu plus multi-thread. Ever=
y dual-core shares
the last level cache 12M. But the cache is stll flushed at least twice =
per second.

If checking NIC drivers, we can find drivers touch very limited fields =
of sk_buff when
collecting packets from NIC.

It is said 20G or 30G NIC are under producing.

So with high-speed 10G NIC, the old assumption seems not working.

In the other hand, which part causes most cache foot print and cache mi=
ss? I don't think
drivers do so because=EF=BB=BF the receiving cpu only touch some fields=
 of sb_buff before sending
to upper layer.

My patch throws packets to specific cpu controlled by configuration, wh=
ich doesn't
cause much cache ping-pong. =EF=BB=BFAfter receving cpu throws packets =
to 2nd cpu, it doesn't need them
again. The 2nd cpu has cache-miss, but it doesn't cause cache ping-pong=
=2E

My patch doesn't always disagree with =EF=BB=BF=EF=BB=BFskb_record_rx_q=
ueue.
1) It can be configured by admin;
2) We can call =EF=BB=BFskb_record_rx_queue or similiar functions at th=
e 2nd cpu (the real cpu to
process the packets by process_backlog); So later on cache footprint wo=
n't be wasted when
forwarding packets out;

>=20
> You may want to figure out what that isn't behaving well in your
> case.

I did check kernel, including slab ( I tried slab/slub/slqb and use slu=
b now) tuning, and
instrumented IXGBE driver. Besides careful multi-queue/interrupt bindin=
g, another way is
just to use my patch to promote speed for more than 40% on both Nehalem=
 and Bensley.


>=20
> I don't think we should do any kind of software spreading for such
> capable hardware,
> it defeats the whole point of supporting the
> multiqueue features.
=EF=BB=BFThere is no NIC multi-queue standard or RFC.

Jesse is worried about we might allocate free cores for the packet coll=
ection while a
real environment keeps cpu all busy. I added more pressure on sending m=
achine, and got
better performance on forwarding machine and the forwarding machine's c=
pu are busier
than before. Some logical cpu idle is near to 0. But I only have a coup=
le of 10G NIC,
and couldn't add more pressure to make all cpu busy.


Thanks again, for your comments and patience.

Yanmin


