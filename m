From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: qdisc spin lock
Date: Thu, 31 Mar 2016 21:18:52 +0200
Message-ID: <20160331211852.2d228976@redhat.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757239AbcCaTS4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:18:56 -0400
In-Reply-To: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 30 Mar 2016 00:20:03 -0700 Michael Ma <make0818@gmail.com> wrot=
e:

> I know this might be an old topic so bare with me =E2=80=93 what we a=
re facing
> is that applications are sending small packets using hundreds of
> threads so the contention on spin lock in __dev_xmit_skb increases th=
e
> latency of dev_queue_xmit significantly. We=E2=80=99re building a net=
work QoS
> solution to avoid interference of different applications using HTB.

Yes, as you have noticed with HTB there is a single qdisc lock, and
congestion obviously happens :-)

It is possible with different tricks to make it scale.  I believe
Google is using a variant of HTB, and it scales for them.  They have
not open source their modifications to HTB (which likely also involves
a great deal of setup tricks).

If your purpose it to limit traffic/bandwidth per "cloud" instance,
then you can just use another TC setup structure.  Like using MQ and
assigning a HTB per MQ queue (where the MQ queues are bound to each
CPU/HW queue)... But you have to figure out this setup yourself...


> But in this case when some applications send massive small packets in
> parallel, the application to be protected will get its throughput
> affected (because it=E2=80=99s doing synchronous network communicatio=
n using
> multiple threads and throughput is sensitive to the increased latency=
)
>=20
> Here is the profiling from perf:
>=20
> -  67.57%   iperf  [kernel.kallsyms]     [k] _spin_lock
>   - 99.94% dev_queue_xmit
>   -  96.91% _spin_lock                                               =
           =20
>  - 2.62%  __qdisc_run                                                =
               =20
>   - 98.98% sch_direct_xmit
> - 99.98% _spin_lock
>=20
> As far as I understand the design of TC is to simplify locking schema
> and minimize the work in __qdisc_run so that throughput won=E2=80=99t=
 be
> affected, especially with large packets. However if the scenario is
> that multiple classes in the queueing discipline only have the shapin=
g
> limit, there isn=E2=80=99t really a necessary correlation between dif=
ferent
> classes. The only synchronization point should be when the packet is
> dequeued from the qdisc queue and enqueued to the transmit queue of
> the device. My question is =E2=80=93 is it worth investing on avoidin=
g the
> locking contention by partitioning the queue/lock so that this
> scenario is addressed with relatively smaller latency?

Yes, there is a lot go gain, but it is not easy ;-)

> I must have oversimplified a lot of details since I=E2=80=99m not fam=
iliar
> with the TC implementation at this point =E2=80=93 just want to get y=
our input
> in terms of whether this is a worthwhile effort or there is something
> fundamental that I=E2=80=99m not aware of. If this is just a matter o=
f quite
> some additional work, would also appreciate helping to outline the
> required work here.
>=20
> Also would appreciate if there is any information about the latest
> status of this work http://www.ijcset.com/docs/IJCSET13-04-04-113.pdf

This article seems to be very low quality... spelling errors, only 5
pages, no real code, etc.=20

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
