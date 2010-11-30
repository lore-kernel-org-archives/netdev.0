From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 19:52:07 +0100
Message-ID: <1291143127.2904.192.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <1290705163.4274.12.camel@localhost>
	 <1291054477.3435.1302.camel@edumazet-laptop>
	 <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
	 <1291142377.2904.176.camel@edumazet-laptop>
	 <1291142762.21077.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43984 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756111Ab0K3SwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:52:12 -0500
Received: by wwa36 with SMTP id 36so6396487wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 10:52:11 -0800 (PST)
In-Reply-To: <1291142762.21077.47.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 18:46 +0000, Ben Hutchings a =C3=A9cri=
t :

> Yes, that's why I proposed an ethtool interface for reconfiguring thi=
s.
> Although to be honest I haven't yet constructed a case where it made =
a
> difference.  I think the most important objects to be allocated on th=
e
> right node are RX buffers, and as long as refill is scheduled on the
> same CPU as the IRQ this already happens.
>=20

Hmm, right now RX skbs are allocated on the right node, since they are
allocated on the node of the cpu handling the {soft}irq.

commit 564824b0c52c346

net: allocate skbs on local node

    commit b30973f877 (node-aware skb allocation) spread a wrong habit =
of
    allocating net drivers skbs on a given memory node : The one closes=
t to
    the NIC hardware. This is wrong because as soon as we try to scale
    network stack, we need to use many cpus to handle traffic and hit
    slub/slab management on cross-node allocations/frees when these cpu=
s
    have to alloc/free skbs bound to a central node.
   =20
    skb allocated in RX path are ephemeral, they have a very short
    lifetime : Extra cost to maintain NUMA affinity is too expensive. W=
hat
    appeared as a nice idea four years ago is in fact a bad one.
   =20
    In 2010, NIC hardwares are multiqueue, or we use RPS to spread the =
load,
    and two 10Gb NIC might deliver more than 28 million packets per sec=
ond,
    needing all the available cpus.
   =20
    Cost of cross-node handling in network and vm stacks outperforms th=
e
    small benefit hardware had when doing its DMA transfert in its 'loc=
al'
    memory node at RX time. Even trying to differentiate the two alloca=
tions
    done for one skb (the sk_buff on local node, the data part on NIC
    hardware node) is not enough to bring good performance.


