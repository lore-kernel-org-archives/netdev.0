From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 06:49:19 +0100
Message-ID: <49C1DCDF.6050300@cosmosbay.com>
References: <1237425191.8204.41.camel@quadrophenia.thebigcorporation.com>	<20090318.181713.62394874.davem@davemloft.net>	<1237427007.8204.55.camel@quadrophenia.thebigcorporation.com> <20090318.185441.138157931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sven@thebigcorporation.com, ghaskins@novell.com, vernux@us.ibm.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090318.185441.138157931.davem@davemloft.net>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
> Date: Wed, 18 Mar 2009 18:43:27 -0700
>=20
>> Do we have to rule-out per-CPU queues, that aggregate into a master
>> queue in a batch-wise manner?=20
>=20
> That would violate the properties and characteristics expected by
> the packet scheduler, wrt. to fair based fairness, rate limiting,
> etc.
>=20
> The only legal situation where we can parallelize to single device
> is where only the most trivial packet scheduler is attached to
> the device and the device is multiqueue, and that is exactly what
> we do right now.

I agree with you David.

Still, there is room for improvements, since :

1) default qdisc is pfifo_fast. This beast uses three sk_buff_head (96 =
bytes)
  where it could use 3 smaller list_head (3 * 16 =3D 48 bytes on x86_64=
)

 (assuming sizeof(spinlock_t) is only 4 bytes, but it's more than that
 on various situations (LOCKDEP, ...)

2) struct Qdisc layout could be better, letting read mostly fields
   at beginning of structure. (ie move 'dev_queue', 'next_sched', resha=
pe_fail,
   u32_node, __parent, ...)

  'struct gnet_stats_basic' has a 32 bits hole

   'gnet_stats_queue' could be split, at least in Qdisc, so that three
   seldom use fields (drops, requeues, overlimits) go in a different ca=
che line.

   gnet_stats_rate_est might be also moved in a 'not very used' cache l=
ine, if
   I am not mistaken ?

3) In stress situation a CPU A queues a skb to a sk_buff_head, but a CP=
U B
   dequeues it to feed device, involving an expensive cache line miss
   on the skb.{next|prev} (to set them to NULL)

   We could:
      Use a special dequeue op that doesnt touch skb.{next|prev}
   Eventually set next/prev to NULL after q.lock is released



--
To unsubscribe from this list: send the line "unsubscribe linux-rt-user=
s" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
