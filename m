From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 05:58:36 +0100
Message-ID: <4B0621FC.6060004@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <412e6f7f0911191812uf0abc61w2f0d44f4d71bd55@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44521 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbZKTE6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 23:58:39 -0500
In-Reply-To: <412e6f7f0911191812uf0abc61w2f0d44f4d71bd55@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :
> On Fri, Nov 20, 2009 at 7:46 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 9977288..9e134f6 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2000,6 +2001,7 @@ gso:
>>         */
>>        rcu_read_lock_bh();
>>
>> +       skb->sending_cpu =3D cpu =3D smp_processor_id();
>>        txq =3D dev_pick_tx(dev, skb);
>>        q =3D rcu_dereference(txq->qdisc);
>=20
> I think assigning cpu to skb->sending_cpu just before calling
> hard_start_xmit is better, because the CPU which dequeues the skb wil=
l
> be another one.

I want to record the application CPU, because I want the application CP=
U
to call sock_wfree(), not the CPU that happened to dequeue skb to trans=
mit it
in case of txq contention.

>=20
>> @@ -2024,8 +2026,6 @@ gso:
>>           Either shot noqueue qdisc, it is even simpler 8)
>>         */
>>        if (dev->flags & IFF_UP) {
>> -               int cpu =3D smp_processor_id(); /* ok because BHs ar=
e off */
>> -
>>                if (txq->xmit_lock_owner !=3D cpu) {
>>
>>                        HARD_TX_LOCK(dev, txq, cpu);
>> @@ -2967,7 +2967,7 @@ static void net_rx_action(struct softirq_actio=
n *h)
>>        }
>>  out:
>>        local_irq_enable();
>> -
>> +       xps_flush();
>=20
> If there isn't any new skbs, the memory will be hold forever. I know
> you want to eliminate unnecessary IPI, how about sending IPI only whe=
n
> the remote xps_pcpu_queues are changed from empty to nonempty?

I dont understand your remark, and dont see the problem, yet.

I send IPI only on cpus I know I have at least one skb queueud for them=
=2E
=46or each cpu taking TX completion interrupts I have :

One bitmask (xps_cpus) of cpus I will eventually send IPI at end of net=
_rx_action()

One array of skb lists per remote cpu, allocated on cpu node memory, th=
anks
to __alloc_percpu() at boot time.

I say _eventually_ because the algo is :

+		if (cpu_online(cpu)) {
+			spin_lock(&q->list.lock);
+			prevlen =3D skb_queue_len(&q->list);
+			skb_queue_splice_init(&head[cpu], &q->list);
+			spin_unlock(&q->list.lock);
+			/*
+			 * We hope remote cpu will be fast enough to transfert
+			 * this list to its completion queue before our
+			 * next xps_flush() call
+			 */
+			if (!prevlen)
+				__smp_call_function_single(cpu, &q->csd, 0);
+			continue;

So I send an IPI only if needed, once for the whole skb list.

With my pktgen (no skb cloning setup) tests, and

ethtool -C eth3 tx-usecs 1000 tx-frames 100

I really saw batches of 100 frames given from CPU X (NIC interrupts) to=
 CPU Y (pktgen cpu)

What memory is hold forever ?
