From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Sat, 27 Aug 2016 09:25:21 -0700
Message-ID: <1472315121.14381.232.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAK6E8=feHjgq-JK8L5Wd+2HZaLs7qicw1+W7gHUCN0e6RzL4TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34122 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754067AbcH0QZm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 12:25:42 -0400
Received: by mail-pf0-f181.google.com with SMTP id p64so38084806pfb.1
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 09:25:23 -0700 (PDT)
In-Reply-To: <CAK6E8=feHjgq-JK8L5Wd+2HZaLs7qicw1+W7gHUCN0e6RzL4TA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-08-27 at 09:13 -0700, Yuchung Cheng wrote:
> On Sat, Aug 27, 2016 at 7:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >

> > +       /* Only socket owner can try to collapse/prune rx queues
> > +        * to reduce memory overhead, so add a little headroom here.
> > +        * Few sockets backlog are possibly concurrently non empty.
> > +        */
> > +       limit += 64*1024;
> Just a thought: only add the headroom if ofo queue exists (e.g., signs
> of losses ore recovery).

Testing the ofo would add a cache line miss, and likely slow down the
other cpu processing the other packets for this flow.

Also, even if the ofo does not exist, the sk_rcvbuf budget can be
consumed by regular receive queue.

We still need to be able to process incoming ACK, if both send and
receive queues are 'full'.

> 
> btw is the added headroom subject to the memory pressure check?

Remind that the backlog check here is mostly to avoid some kind of DOS
attacks that we had in the past.

While we should definitely prevents DOS attacks, we should also not drop
legitimate traffic.

Here, number of backlogged sockets is limited by the number of cpus in
the host (if CONFIG_PREEMPT is disabled), or number of threads blocked
during a sendmsg()/recvmsg() (if CONFIG_PREEMPT is enabled)

So we do not need to be ultra precise, just have a safe guard.

The pressure check will be done at the time skbs will be added into a
receive/ofo queue in the very near future.

Thanks !
