From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] net: add protocol level recvmmsg support
Date: Fri, 25 Nov 2016 13:16:22 -0800
Message-ID: <1480108582.8455.568.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33076 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbcKYVQY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 16:16:24 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so6371189pgd.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 13:16:24 -0800 (PST)
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 16:39 +0100, Paolo Abeni wrote:
> The goal of recvmmsg() is to amortize the syscall overhead on a possible
> long messages batch, but for most networking protocols, e.g. udp the
> syscall overhead is negligible compared to the protocol specific operations
> like dequeuing.

Problem of recvmmsg() is that it blows up L1/L2 cache of the cpu.
It gives false 'good results' until other threads sharing the same cache
hierarchy are competing with you. Then performance is actually lower
than regular recvmsg().

And I presume your tests did not really use the data once copied to user
space, like doing the typical operations a UDP server does on incoming
packets ?

I would rather try to optimize normal recvmsg(), instead of adding so
much code in the kernel for this horrible recvmmsg() super system call.

Looking at how buggy sendmmsg() was until commit 3023898b7d4aac6
("sock: fix sendmmsg for partial sendmsg"), I fear that these 'super'
system calls are way too complex.

How could we improve UDP ?

For example, we could easily have 2 queues to reduce false sharing and
lock contention.

1) One queue accessed by softirq to append packets.

2) One queue accessed by recvmsg(). Make sure these two queues do not
share a cache line.

When 2nd queue is empty, transfer whole first queue in one operation.

Look in net/core/dev.c , process_backlog() for an example of this
strategy.

Alternative would be to use a ring buffer, although the forward_alloc
stuff might be complex.
