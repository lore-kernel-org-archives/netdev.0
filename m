From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Mon, 16 Nov 2009 09:19:21 +0100
Message-ID: <4B010B09.9020101@gmail.com>
References: <4B00FFD8.4040508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46598 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbZKPIT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 03:19:27 -0500
In-Reply-To: <4B00FFD8.4040508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> ifb: add multi-queue support.
>=20
> Add multi-queue support, through more than one tasklets. One tasklet =
per
> queue always steers on the same CPU, and if the number of the
> tasklets(queues) is lager than the number of CPUs, more than one
> tasklets will be assigned to the same CPU.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

>=20

I must say I fail to see how multiple tasklets per cpu can be of any us=
e.

And :

+	if (skb_queue_len(&pq->rq) =3D=3D 1)
+		tasklet_schedule_on(&pq->task, num % num_online_cpus());

Is probably not what you want, because :

A) num_online_cpus() can be expensive to compute,
B) and you can have such configs :

Three online cpus, CPU0 and CPU4, CPU5
-> you call tasklet_schedule_on(... , num =3D {0|1|2})

To avoid packets reorder, if your hash function selects an offline cpu,
you must forward the packet to a particular cpu, regardless of cpu curr=
ently running.
(even if real device is not multiqueue, its RX interrupts can be handle=
d by any online cpu)

You maybe need to maintain a mapping table with cpu hotplug notifiers.
