From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: do not create inetpeer on SYNACK message
Date: Sat, 02 Jun 2012 08:56:56 +0200
Message-ID: <1338620216.2760.1677.camel@edumazet-glaptop>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	 ,<1338534026.2760.1451.camel@edumazet-glaptop>
	 <C8A6796DE7C66C4ABCBC18106CB6C1CC164D13A516@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>
To: Hans =?ISO-8859-1?Q?Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42633 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965168Ab2FBG5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 02:57:01 -0400
Received: by weyu7 with SMTP id u7so1803782wey.19
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 23:57:00 -0700 (PDT)
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC164D13A516@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-01 at 23:34 +0200, Hans Schillstr=C3=B6m wrote:

> It think we are on the right way now,
>=20
> Some results from one of our testers:
> before applying "reflect SYN queue_mapping into SYNACK"
>=20
> "(The latest one from Eric is not included. I am building with
> that one right now.)
> Results were that with the same number of SYN/s, load went down
> 30% on each of the three Cpus that were handling the SYNs.
> Great !!!"
>=20

I am not sure reflecting queue_mapping will help your workload, since
you specifically asked to your NIC to queue all SYN packets on one
single queue.

Eventually not relying on skb->queue_mapping but skb->rxhash to chose a=
n
outgoing queue for the SYNACKS to not harm a single tx queue ?

Then it might be not needed, if the queue is dedicated to SYN and SYNAC=
K
packets, since net_rx_action/net_tx_action should both dequeue 64
packets each round, in a round robin fashion.

(I had problems in a standard setup, where you can have a single cpu
(CPU0 in my case) servicing all NAPI interrupts, so with 16 queues, the
rx_action/tx_action ratio is 16/1 if all synack go to a single queue,
while SYN are distributed to all 16 rx queues)


> I'm looking forward to see the results of the latests patch.
>=20
> Then I think conntrack need a little shape up, like a "mini-conntrack=
"
> it is way to expensive to alloc a full "coontack for every SYN.
>=20
> I have a bunch of patches and ideas for that...
>=20

Cool ! the conntrack issue is a real one for sure.


Given the conntrack current requirement (being protected by a central
lock), I guess your best bet would be following setup :

One single CPU to handle all SYN packets.

Eventually not relying on skb->queue_mapping but skb->rxhash to chose a=
n
outgoing queue for the SYNACKS to not harm a single tx queue.

> Thanks Eric for a great job
>=20

Thanks for giving testing results and ideas !
