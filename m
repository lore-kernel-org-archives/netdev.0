From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 4/7] packet: rollover lock contention avoidance
Date: Wed, 6 May 2015 17:05:39 -0400
Message-ID: <CA+FuTSdJ4xGdp=tcTUnPGqYkgDaJK7bnDWtDjJ1hrX5GZtMoUg@mail.gmail.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
 <1430936837-22655-5-git-send-email-willemb@google.com> <1430941450.14545.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34696 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFVGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 17:06:10 -0400
Received: by obfe9 with SMTP id e9so16995671obf.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 14:06:10 -0700 (PDT)
In-Reply-To: <1430941450.14545.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-05-06 at 14:27 -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>
>> @@ -3718,6 +3726,10 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
>>                       mask |= POLLOUT | POLLWRNORM;
>>       }
>>       spin_unlock_bh(&sk->sk_write_queue.lock);
>> +
>> +     if (po->pressure && !(mask & POLLIN))
>> +             xchg(&po->pressure, 0);
>> +
>>       return mask;
>
> This look racy to me : several threads could run here, and a thread
> could remove pressure just set by another one.
>
> Also waiting for queue being completely empty before releasing pressure
> might depend on scheduling to utilize queue shortly.
>
> (We usually use max_occupancy/2 thresholds)

Yes, half would be better. I could not figure out a way to test anything
besides empty without taking the receive lock. But as your change points
out, packet_poll already takes that lock. I can call a lockless variant of
packet_rcv_has_room right there, then (iff po->pressure).

> Maybe this would be better, but please check.
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 5102c3cc4eec..fab59f8bb336 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -3694,6 +3694,8 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
>                         TP_STATUS_KERNEL))
>                         mask |= POLLIN | POLLRDNORM;
>         }
> +       if (po->pressure && !(mask & POLLIN))
> +               xchg(&po->pressure, 0);
>         spin_unlock_bh(&sk->sk_receive_queue.lock);
>         spin_lock_bh(&sk->sk_write_queue.lock);
>         if (po->tx_ring.pg_vec) {
>

That would fix it for rings. I'll move the check there.
