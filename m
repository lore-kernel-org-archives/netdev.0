From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Thu, 08 Dec 2016 13:13:15 -0800
Message-ID: <1481231595.4930.142.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
         <20161208214819.30138d12@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33197 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752443AbcLHVOS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 16:14:18 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so27905748pgd.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 13:14:18 -0800 (PST)
In-Reply-To: <20161208214819.30138d12@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 21:48 +0100, Jesper Dangaard Brouer wrote:
> On Thu,  8 Dec 2016 09:38:55 -0800
> Eric Dumazet <edumazet@google.com> wrote:
> 
> > This patch series provides about 100 % performance increase under flood. 
> 
> Could you please explain a bit more about what kind of testing you are
> doing that can show 100% performance improvement?
> 
> I've tested this patchset and my tests show *huge* speeds ups, but
> reaping the performance benefit depend heavily on setup and enabling
> the right UDP socket settings, and most importantly where the
> performance bottleneck is: ksoftirqd(producer) or udp_sink(consumer).

Right.

So here at Google we do not try (yet) to downgrade our expensive
Multiqueue Nics into dumb NICS from last decade by using a single queue
on them. Maybe it will happen when we can process 10Mpps per core,
but we are not there yet  ;)

So my test is using a NIC, programmed with 8 queues, on a dual-socket
machine. (2 physical packages)

4 queues are handled by 4 cpus on socket0 (NUMA node 0)
4 queues are handled by 4 cpus on socket1 (NUMA node 1)

So I explicitly put my poor single thread UDP application in the worst
condition, having skbs produced on two NUMA nodes. 

Then my load generator use trafgen, with spoofed UDP source addresses,
like a UDP flood would use. Or typical DNS traffic, malicious or not.

So I have 8 cpus all trying to queue packets in a single UDP socket.

Of course, a real high performance server would use 8 UDP sockets, and
SO_REUSEPORT with nice eBPF filter to spread the packets based on the
queue/cpu they arrived.


In the case you have one cpu that you need to share between ksoftirq and
all user threads, then your test results depend on process scheduler
decisions more than anything we can code in network land.

It is actually easy for user space to get more than 50% of the cycles,
and 'starve' ksoftirqd.
