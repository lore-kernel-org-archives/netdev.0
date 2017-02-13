From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page
 recycling
Date: Sun, 12 Feb 2017 16:33:10 -0800
Message-ID: <1486945990.8227.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170209135838.16487-1-edumazet@google.com>
         <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
         <CANn89i+sbU7b5CAhRq15Mk021X4afkB5E1ip+FRB4NevOrYJvQ@mail.gmail.com>
         <c192d259-644b-0697-748f-549fdc9c11e0@gmail.com>
         <CANn89iLNvQyfXUZwtQuhXBgZrKCDWEaouVtD4Txaem_wDXrdQg@mail.gmail.com>
         <2a345874-2ad7-997e-2904-0d56148a2c56@gmail.com>
         <1486933066.8227.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170212233853.193a2714@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33227 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdBMAdM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:33:12 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so6246944pfg.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:33:12 -0800 (PST)
In-Reply-To: <20170212233853.193a2714@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-02-12 at 23:38 +0100, Jesper Dangaard Brouer wrote:

> Just so others understand this: The number of RX queue slots is
> indirectly the size of the page-recycle "cache" in this scheme (that
> depend on refcnt tricks to see if page can be reused).

Note that the page recycle tricks only work on some occasions.

To provision correctly hosts dealing with TCP flows, one should not rely
on page recycling or any opportunistic (non guaranteed) behavior.

Page recycling, _if_ possible, will help to reduce system load
and thus lower latencies.

> 
> 
> > A single TCP flow easily can have more than 1024 MSS waiting in its
> > receive queue (typical receive window on linux is 6MB/2 )
> 
> So, you do need to increase the page-"cache" size, and need this for
> real-life cases, interesting.

I believe this sizing was done mostly to cope with normal system
scheduling constraints [1], reducing packet losses under incast blasts.

Sizing happened before I did my patches to switch to order-0 pages
anyway.

The fact that it allowed page-recycling to happen more often was nice of
course.


[1]
- One can not really assume host will always have the ability to process
the RX ring in time, unless maybe CPU are fully dedicated to the napi
polling logic.
- Recent work to shift softirqs to ksoftirqd is potentially magnifying
the problem.
