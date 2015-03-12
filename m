From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] xps: fix xps for stacked devices
Date: Thu, 12 Mar 2015 16:48:11 -0700
Message-ID: <CAHA+R7NQgYRG9oCXYB+H_7opcbebJCbpPq_UnYNf0bQ3fEWh+g@mail.gmail.com>
References: <1423036104.907.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33163 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbCLXsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:48:12 -0400
Received: by iecvj10 with SMTP id vj10so65756869iec.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:48:12 -0700 (PDT)
In-Reply-To: <1423036104.907.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 3, 2015 at 11:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> A typical qdisc setup is the following :
>
> bond0 : bonding device, using HTB hierarchy
> eth1/eth2 : slaves, multiqueue NIC, using MQ + FQ qdisc
>
> XPS allows to spread packets on specific tx queues, based on the cpu
> doing the send.
>
> Problem is that dequeues from bond0 qdisc can happen on random cpus,
> due to the fact that qdisc_run() can dequeue a batch of packets.
>
> CPUA -> queue packet P1 on bond0 qdisc, P1->ooo_okay=1
> CPUA -> queue packet P2 on bond0 qdisc, P2->ooo_okay=0
>
> CPUB -> dequeue packet P1 from bond0
>         enqueue packet on eth1/eth2
> CPUC -> dequeue packet P2 from bond0
>         enqueue packet on eth1/eth2 using sk cache (ooo_okay is 0)
>
> get_xps_queue() then might select wrong queue for P1, since current cpu
> might be different than CPUA.
>
> P2 might be sent on the old queue (stored in sk->sk_tx_queue_mapping),
> if CPUC runs a bit faster (or CPUB spins a bit on qdisc lock)
>

I am trying to understand this, and wondering how possible CPUC or the CPU
whichever faster can dequeue P2 instead of P1? Since we always dequeue
from root qdisc and take the root qdisc lock before dequeue, the order should
be guaranteed?

Also, since CPUA enqueues P1 and P2, the root qdisc is supposed to schedule
on CPUA too, in which case it is CPUB or CPUC which can run dequeue()?
Looks like htb schedules the root qdisc by itself, but it schedules the work
on the same cpu with dequeue(), the hrtimer is pinned as well, so I don't
see the possibility.

Thanks.
