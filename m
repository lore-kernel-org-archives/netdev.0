From: Dave Taht <dave.taht@gmail.com>
Subject: Re: root_lock vs. device's TX lock
Date: Thu, 17 Nov 2011 19:19:58 +0100
Message-ID: <CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
References: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
	<1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62837 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab1KQSUA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 13:20:00 -0500
Received: by fagn18 with SMTP id n18so3290846fag.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 10:19:59 -0800 (PST)
In-Reply-To: <1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 6:26 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 17 novembre 2011 =E0 17:34 +0100, Eric Dumazet a =E9crit :
>> Le jeudi 17 novembre 2011 =E0 08:10 -0800, Tom Herbert a =E9crit :
>> > From sch_direct_xmit:
>> >
>> > =A0 =A0 =A0 =A0 /* And release qdisc */
>> > =A0 =A0 =A0 =A0 spin_unlock(root_lock);
>> >
>> > =A0 =A0 =A0 =A0 HARD_TX_LOCK(dev, txq, smp_processor_id());
>> > =A0 =A0 =A0 =A0 if (!netif_tx_queue_frozen_or_stopped(txq))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D dev_hard_start_xmit(skb, d=
ev, txq);
>> >
>> > =A0 =A0 =A0 =A0 HARD_TX_UNLOCK(dev, txq);
>> >
>> > =A0 =A0 =A0 =A0 spin_lock(root_lock);
>> >
>> > This is a lot of lock manipulation to basically switch from one lo=
ck
>> > to another and possibly thrashing just to send a packet. =A0I am
>> > thinking that if the there is a 1-1 correspondence between qdisc a=
nd
>> > device queue then we could actually use the device's lock as the r=
oot
>> > lock for the qdisc. =A0So in that case, we would need to touch any=
 locks
>> > from sch_direct_xmit (just hold root lock which is already device =
lock
>> > for the duration).
>> >
>> > Is there any reason why this couldn't work?
>>
>> But we have to dirty part of Qdisc anyway ?
>> (state, bstats, q, ...)
>>
>
> Also we want to permit other cpus to enqueue packets to Qdisc while o=
ur
> cpu is busy in network driver ndo_start_xmit()
>
> For complex Qdisc / tc setups (potentially touching a lot of cache
> lines), we could eventually add a small ring buffer so that the cpu
> doing the ndo_start_xmit() also queues the packets into Qdisc.
>
> This ringbuffer could use a lockless algo. (we currently use the
> secondary 'busylock' to serialize other cpus, but each cpu calls qdis=
c
> enqueue itself.)

I was thinking ringbuffering might also help in adding a 'grouper'
abstraction to the dequeuing side.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
