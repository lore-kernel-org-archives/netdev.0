From: Andy Fleming <afleming@gmail.com>
Subject: Re: root_lock vs. device's TX lock
Date: Thu, 17 Nov 2011 14:55:11 -0600
Message-ID: <CAKWjMd7xvepSb2sMf4X4U4cjRYizq=tP2TTHhYaozuyBeSW4AQ@mail.gmail.com>
References: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
	<1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:49904 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab1KQUzL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 15:55:11 -0500
Received: by yenq3 with SMTP id q3so1617953yen.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 12:55:11 -0800 (PST)
In-Reply-To: <CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 12:19 PM, Dave Taht <dave.taht@gmail.com> wrote=
:
> On Thu, Nov 17, 2011 at 6:26 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le jeudi 17 novembre 2011 =E0 17:34 +0100, Eric Dumazet a =E9crit :
>>> Le jeudi 17 novembre 2011 =E0 08:10 -0800, Tom Herbert a =E9crit :
>>> > From sch_direct_xmit:
>>> >
>>> > =A0 =A0 =A0 =A0 /* And release qdisc */
>>> > =A0 =A0 =A0 =A0 spin_unlock(root_lock);
>>> >
>>> > =A0 =A0 =A0 =A0 HARD_TX_LOCK(dev, txq, smp_processor_id());
>>> > =A0 =A0 =A0 =A0 if (!netif_tx_queue_frozen_or_stopped(txq))
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D dev_hard_start_xmit(skb, =
dev, txq);
>>> >
>>> > =A0 =A0 =A0 =A0 HARD_TX_UNLOCK(dev, txq);
>>> >
>>> > =A0 =A0 =A0 =A0 spin_lock(root_lock);
>>> >
>>> > This is a lot of lock manipulation to basically switch from one l=
ock
>>> > to another and possibly thrashing just to send a packet. =A0I am
>>> > thinking that if the there is a 1-1 correspondence between qdisc =
and
>>> > device queue then we could actually use the device's lock as the =
root
>>> > lock for the qdisc. =A0So in that case, we would need to touch an=
y locks
>>> > from sch_direct_xmit (just hold root lock which is already device=
 lock
>>> > for the duration).
>>> >
>>> > Is there any reason why this couldn't work?
>>>
>>> But we have to dirty part of Qdisc anyway ?
>>> (state, bstats, q, ...)
>>>
>>
>> Also we want to permit other cpus to enqueue packets to Qdisc while =
our
>> cpu is busy in network driver ndo_start_xmit()
>>
>> For complex Qdisc / tc setups (potentially touching a lot of cache
>> lines), we could eventually add a small ring buffer so that the cpu
>> doing the ndo_start_xmit() also queues the packets into Qdisc.
>>
>> This ringbuffer could use a lockless algo. (we currently use the
>> secondary 'busylock' to serialize other cpus, but each cpu calls qdi=
sc
>> enqueue itself.)
>
> I was thinking ringbuffering might also help in adding a 'grouper'
> abstraction to the dequeuing side.

Actually, I'm interested in circumventing *both* locks. Our SoC has
some quite-versatile queueing infrastructure, such that (for many
queueing setups) we can do all of the queueing in hardware, using
per-cpu access portals. By hacking around the qdisc lock, and using a
tx queue per core, we were able to achieve a significant speedup.

Right now, it's a big hack, but I'd like to find a way that we could
provide support for this. My initial thought was to craft a qdisc
implementation for our hardware, but the root_lock means doing so
would not yield any performance gain.

Andy
