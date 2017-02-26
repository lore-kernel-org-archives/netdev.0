From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: reception NAPI/IRQ race breaker
Date: Sun, 26 Feb 2017 09:34:17 -0800
Message-ID: <1488130457.9415.153.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG-OcTAKkRQQHXV=8N-m+yATaX76UpGE4eWgK_8N52YePg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36831 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdBZReT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 12:34:19 -0500
Received: by mail-pg0-f68.google.com with SMTP id 25so1297109pgy.3
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 09:34:19 -0800 (PST)
In-Reply-To: <CALzJLG-OcTAKkRQQHXV=8N-m+yATaX76UpGE4eWgK_8N52YePg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-02-26 at 18:32 +0200, Saeed Mahameed wrote:
> On Sat, Feb 25, 2017 at 4:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > While playing with hardware timestamping of RX packets, I found
> > that some packets were received by TCP stack with a ~200 ms delay...
> >
> > Since the timestamp was provided by the NIC, and my probe was added
> > in tcp_v4_rcv() while in BH handler, I was confident it was not
> > a sender issue, or a drop in the network.
> >
> > This would happen with a very low probability, but hurting RPC
> > workloads.
> >
> > I could track this down to the cx-3 (mlx4 driver) card that was
> > apparently sending an IRQ before we would arm it.
> >
> 
> Hi Eric,
> 
> This is highly unlikely, the hardware should not do that, and if this
> is really the case
> we need to hunt down the root cause and not work around it.

Well, I definitely see the interrupt coming while the napi bit is not
available.


> 
> > A NAPI driver normally arms the IRQ after the napi_complete_done(),
> > after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
> > it.
> >
> > This patch adds a new rx_irq_miss field that is incremented every time
> > the hard IRQ handler could not grab NAPI_STATE_SCHED.
> >
> > Then, mlx4_en_poll_rx_cq() is able to detect that rx_irq was incremented
> > and attempts to read more packets, if it can re-acquire NAPI_STATE_SCHED
> 
> Are you sure this is not some kind of race condition with the busy
> polling mechanism
> Introduced in ("net/mlx4_en: use napi_complete_done() return value") ?
> Maybe the busy polling thread when it detects that it wants to yield,
> it arms the CQ too early (when napi is not ready)?
> 

Good question.

No busy polling in my tests.

I have triggers by using on a 2x10 Gbit host

(bonding of two 10Gbit mlx4 ports)


ethtool -C eth1 adaptive-rx on rx-usecs-low 0
ethtool -C eth2 adaptive-rx on rx-usecs-low 0
./super_netperf 9 -H lpaa6 -t TCP_RR -l 10000 -- -r 1000000,1000000 &


4 rx and tx queues per NIC, fq packet scheduler on them.

TCP timestamps are on. (this might be important to get the last packet
of a given size. In my case 912 bytes, with a PSH flag)


> Anyway Tariq and I would like to further investigate the fired IRQ
> while CQ is not armed.  It smells
> like  a bug in the driver/napi level, it is not a HW expected behavior.
> 
> Any pointers on how to reproduce ?  how often would the "rx_irq_miss"
> counter advance on a linerate RX load ?


About 1000 times per second on my hosts, receiving about 1.2 Mpps.
But most of these misses are not an issue because next packet is
arriving maybe less than 10 usec later.

Note that the bug is hard to notice, because TCP would fast retransmit,
or the next packet was coming soon enough.

You have to be unlucky enough that the RX queue that missed the NAPI
schedule receive no more packets before the 200 ms RTO timer, and the
packet stuck in the RX ring is the last packet of the RPC.


I believe part of the problem is that NAPI_STATE_SCHED can be grabbed by
a process while hard irqs were not disabled.

I do not believe this bug is mlx4 specific.

Anything doing the following while hard irq were not masked :

local_bh_disable();
napi_reschedule(&priv->rx_cq[ring]->napi);
local_bh_enable();

Like in mlx4_en_recover_from_oom()

Can trigger the issue really.

Unfortunately I do not see how core layer can handle this.
Only the driver hard irq could possibly know that it could not grab
NAPI_STATE_SCHED
