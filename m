From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock contention
Date: Thu, 14 May 2015 14:35:57 -0400
Message-ID: <CA+FuTSesrSiC84pDVR=0r9uhsM5UHuQpJ=hYLvBjafOtTGUfLQ@mail.gmail.com>
References: <1431617634.27831.60.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+FuTSfQ3xuTjJk-oSDvT0o67vY34Y68zVjuTByhNaGfaNPagg@mail.gmail.com>
 <1431620686.27831.63.camel@edumazet-glaptop2.roam.corp.google.com> <20150514.125922.1722914809373007896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36334 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbbENSg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 14:36:28 -0400
Received: by oift201 with SMTP id t201so62596677oif.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 11:36:28 -0700 (PDT)
In-Reply-To: <20150514.125922.1722914809373007896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 12:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 14 May 2015 09:24:46 -0700
>
>> On Thu, 2015-05-14 at 11:53 -0400, Willem de Bruijn wrote:
>>
>>> I principally want to avoid the lock contention on sk_receive_queue.lock,
>>> which is held for a lot longer while probing frames. But yes, I'd prefer to
>>> avoid the cacheline contention as well.
>>>
>>> The alternative is to keep the race and just replace the xchg with a
>>> straight assignment.
>>
>> Please describe the race. It seems quite innocent at first look.

It is. David described it well.

>> Clearly putting xchg() gives a false sense of security in this context.

Agreed.

>> Atomic ops should be reserved for cases we cannot avoid them,
>> not to give false hopes ;)
>
> Basically, ->pressure seems to exist merely to optimize the scanner
> in fanout_demux_rollover().  It makes it so that we don't check
> sockets we already know lack space.
>
> It is set (in an unlocked context) by packet_rcv_has_room() calls
> which calculate that the socket lacks space.
>
> It is cleared either in non-tpacket recvmsg() or poll(), the latter
> of which holds the socket receive queue spinlock.
>
> This kind of variable and conditional locking is crummy, at best.
>
> Since non-tpacket recvmsg already has to hold the receive queue lock
> to pull out the SKB (via skb_recv_datagram()), there is no value to
> the conditional locking done by packet_rcv_has_room().

Good point. I hadn't thought of that.

> Just take the receive queue lock always, and then you can guarantee
> that all ->pressure updates occur under that lock.
>
> Tests can be done asynchronously without locking in the
> fanout_demux_rollover() code, and that's fine.  It's a heuristic
> after all.
>
> Like this:

This looks great, thanks. I can submit it, but it is essentially your fix.

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 31d5856..0947895 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1301,17 +1301,14 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
>         int ret;
>         bool has_room;
>
> -       if (po->prot_hook.func == tpacket_rcv) {
> -               spin_lock(&po->sk.sk_receive_queue.lock);
> -               ret = __packet_rcv_has_room(po, skb);
> -               spin_unlock(&po->sk.sk_receive_queue.lock);
> -       } else {
> -               ret = __packet_rcv_has_room(po, skb);
> -       }
> +       spin_lock(&po->sk.sk_receive_queue.lock);
>
> +       ret = __packet_rcv_has_room(po, skb);
>         has_room = ret == ROOM_NORMAL;
>         if (po->pressure == has_room)
> -               xchg(&po->pressure, !has_room);
> +               po->pressure = !has_room;
> +
> +       spin_unlock(&po->sk.sk_receive_queue.lock);
>
>         return ret;
>  }
> @@ -3814,7 +3811,7 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
>                         mask |= POLLIN | POLLRDNORM;
>         }
>         if (po->pressure && __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
> -               xchg(&po->pressure, 0);
> +               po->pressure = 0;
>         spin_unlock_bh(&sk->sk_receive_queue.lock);
>         spin_lock_bh(&sk->sk_write_queue.lock);
>         if (po->tx_ring.pg_vec) {
