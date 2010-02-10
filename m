From: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Wed, 10 Feb 2010 13:50:48 -0700
Message-ID: <20100210205048.GT20231@esk.cs.usu.edu>
References: <20091210231103.GA20231@esk.cs.usu.edu>
 <4B218E36.4030808@gmail.com>
 <20091215172119.GF20231@esk.cs.usu.edu>
 <4B27E4A1.4050802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from esk.cs.usu.edu ([129.123.28.15]:59447 "EHLO esk.cs.usu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180Ab0BJVkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 16:40:36 -0500
Received: from esk by esk.cs.usu.edu with local (Exim 4.69)
	(envelope-from <esk@esk.cs.usu.edu>)
	id 1NfJWK-0006R9-4H
	for netdev@vger.kernel.org; Wed, 10 Feb 2010 13:50:48 -0700
Content-Disposition: inline
In-Reply-To: <4B27E4A1.4050802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  Dec 15 20:33+0100, Eric Dumazet wrote:
> Le 15/12/2009 18:21, Eldon Koyle a =E9crit :
> > On  Dec 11  1:11+0100, Eric Dumazet wrote:
> >> Le 11/12/2009 00:11, Eldon Koyle a =E9crit :
> >>> We have built a firewall with two 10 Gbit interfaces (intel 82598=
EB) and
> >>> are doing some testing.  A simple bridge between the two interfac=
es acts
> >>> as expected with packets being distributed fairly evenly across a=
ll of
> >>> the rx/tx queues.
> >>>
> >>> We then switched to tagged vlans on both interfaces (10 vlans eac=
h, 8
> >>> source and 8 dest addresses per vlan) and bridged eth0.N to eth1.=
N, and
> >>> many of our queues (and CPUs) remained idle, and all of our VLAN =
traffic
> >>> went out on the same tx queue.  Are multiple transmit queues supp=
orted
> >>> with 802.1q?  How do we figure out what is causing some of our re=
ceive
> >>> queues to be unused?
> >>>
> >>> We are using 2.6.31 (from Debian) and ixgbe-2.0.44.14 .
> >>>
> >>
> >> You need more recent kernel (2.6.32) to get multi queue support on=
 vlans, sorry.
> >=20
> > Excellent.  2.6.32 solved half of the problem.  Now, we are using t=
he
> > same number of rx and tx queues.  We are still seeing no packets on=
 3 of
> > our 8 rx queues on each interface, though (no packets on 2, 4 or 6)=
=2E
> > Does the card assign queues in hardware, or is that handled by the
> > kernel?
> >=20
>=20
> When a packet is received (ethernet -> Card), the hardware chooses a =
RX queue using
> hash function.
>=20
> Then, in your forwarding setup, we (the kernel) automaticaly use same=
 queue to transmit packet.
>=20
> So if only 5 queues out of 8 receive trafic, it might be because of t=
he flows all map to only 5 queues,
> but you should ask Intel people for details :)

I am now trying 2.6.32.7 with the in-tree ixgbe driver.  I am still
seeing some unusual behavior when bridging VLAN interfaces.  It looks
like there is an off-by-one error in the mapping from rx queue to tx
queue (ie. packets are sent on <rx queue number>-1 instead of using the
same rx and tx queue number).

Any idea what might cause this?

The following shows queues vs packets on the physical interfaces (the
counts aren't exact, since not all traffic was bridged):

with vlans:
br3990 (eth0.3990 and eth1.3990)
 queue|      eth0-rx|      eth1-tx|      eth1-rx|      eth0-tx
--------------------------------------------------------------
     0|         6344|       150003|          222|       261103
     1|       150488|       118250|       261103|        80550
     2|       118909|        97282|        80545|       133299
     3|        97588|       104442|       133299|       170111
     4|       105242|       231104|       170001|        68381
     5|       231551|       100548|        68381|       262220
     6|       101202|       262220|       262220|        88248
     7|       262309|            0|        88253|            0

without vlans (expected behavior):
br0 (eth0 and eth1)
 queue|      eth0-rx|      eth1-tx|      eth1-rx|      eth0-tx
--------------------------------------------------------------
     0|         6001|         5977|          159|          159
     1|          541|          541|      1419199|      1419199
     2|      1420084|      1419051|         6270|         6270
     3|        74354|        74312|       305867|       305867
     4|       232547|       232421|       163397|       163397
     5|          367|          365|            2|            2
     6|       170854|       170174|            5|            5
     7|           99|           97|            9|            9

--=20
Eldon Koyle
System Administration Operations
Information Technology
Utah State University
--=20
The rule is, jam to-morrow and jam yesterday, but never jam today.
		-- Lewis Carroll
