From: PRAGATI KUMAR DHINGRA <pragati.k@samsung.com>
Subject: Re :Re: in-driver QoS
Date: Wed, 09 Jun 2004 11:26:33 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6286748.1086780401662.JavaMail.weblogic@ep_app25>
Reply-To: pragati.k@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7BIT
Cc: Vladimir Kondratiev <vkondra@mail.ru>,
        "netdev@oss.sgi.com " <netdev@oss.sgi.com>,
        "jt@hpl.hp.com " <jt@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-return: prohibited
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


----- Original Message ----- 
From: "Vladimir Kondratiev" <vkondra@mail.ru>
To: <netdev@oss.sgi.com>; <hadi@cyberus.ca>
Cc: <jt@hpl.hp.com>
Sent: Wednesday, June 09, 2004 11:21 AM
Subject: Re: in-driver QoS


> > > With respect to the 4 different hardware queue, you should see
> > > them only as an extension of the netdev queues. Basically, you just
> > > have a pipeline between the scheduler and the MAC which is almost a
> > > FIFO, but not exactly a FIFO. Those queues may do packet reordering
> > > between themselves, based on priorities. But at the end of the day
> > > they are only going to send what the scheduler is feeding them, and
> > > every packet the scheduler pass to those queues is eventually sent, so
> > > they are totally slave to the scheduler.
> >
> > Is it a FIFO or there are several DMA rings involved? If the later:
> > when do you stop the netdevice (i.e call netif_stop_queue())?
> You hit the problem. Due to single queue, I can't provide separate back
> pressure for different access categories. What I do now, I do some
internal
> buffering and netif_stop_queue() when total number of packets (or bytes)
> exceed some threshold. Of course, with watermarks to fight jitter.
>
> Let's consider real example. Some application do FTP transfer, lots of
data.
> Simultaneously, voice-over-IP connection invoked. Now question is: how to
> assure voice quality? Accordingly to TGe, voice is send either with high
> priority, or in TSPEC. If we will send all packets with high priority, we
> will hit ourselves. If we can't provide some back pressure for low
priority
> traffic, it will block voice packets, since some moment you should
> netif_stop_queue().
>
> Ideal would be if I can call netif_stop_queue(id), separately for each id.

Two alternatives that I can think of:
1. Maintain only one queue as Jean suggested
    As a hypothetical example, let max queue length be 100. Given 4 priority
levels (1-4 with 4 being the highest) we can define minimum and maximum
threshold for number of slots for each level.

Level              Min                  Max
 4                    35                    55
 3                    25                    45
 2                    15                    35
 1                    5                      25
At any given time, we have 80 slots reserved in proprotion to the priority
and a free pool of 20 slots to support whaichever level is experiencing high
volume.

ofcourse this scheme invalidates the assumption:
> Most likely, the FIFOs will share the same memory pool on the
> card, so when a FIFO is full, most likely the other FIFOs will be full
> or close to it.

2. If all traffic is from a single level, dedicate entire queue to it ... If
there are multiple levels, decide ration the slots ...
If levels 4 and 3 are co-existing, for every 5 packets of level 4, we send 3
packets of level 3 or something like that ... As soon as a new level traffic
begins, the appropriate ratio of slots in the queue are reserved for it ...
They may be full, in that case we can wait for them to empty (150Mbps) or we
can drop some of them and notify failure to higher layers.

Regards
Pragati
