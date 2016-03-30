From: Michael Ma <make0818@gmail.com>
Subject: qdisc spin lock
Date: Wed, 30 Mar 2016 00:20:03 -0700
Message-ID: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34122 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbcC3HUF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 03:20:05 -0400
Received: by mail-ig0-f170.google.com with SMTP id sy18so24058269igc.1
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 00:20:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

I know this might be an old topic so bare with me =E2=80=93 what we are=
 facing
is that applications are sending small packets using hundreds of
threads so the contention on spin lock in __dev_xmit_skb increases the
latency of dev_queue_xmit significantly. We=E2=80=99re building a netwo=
rk QoS
solution to avoid interference of different applications using HTB.
But in this case when some applications send massive small packets in
parallel, the application to be protected will get its throughput
affected (because it=E2=80=99s doing synchronous network communication =
using
multiple threads and throughput is sensitive to the increased latency)

Here is the profiling from perf:

-  67.57%   iperf  [kernel.kallsyms]     [k] _spin_lock
                                                         - 99.94%
dev_queue_xmit
                                                              96.91%
_spin_lock
                                                            - 2.62%
__qdisc_run
                                                               -
98.98% sch_direct_xmit

99.98% _spin_lock
                                                                 1.01%
_spin_lock

As far as I understand the design of TC is to simplify locking schema
and minimize the work in __qdisc_run so that throughput won=E2=80=99t b=
e
affected, especially with large packets. However if the scenario is
that multiple classes in the queueing discipline only have the shaping
limit, there isn=E2=80=99t really a necessary correlation between diffe=
rent
classes. The only synchronization point should be when the packet is
dequeued from the qdisc queue and enqueued to the transmit queue of
the device. My question is =E2=80=93 is it worth investing on avoiding =
the
locking contention by partitioning the queue/lock so that this
scenario is addressed with relatively smaller latency?

I must have oversimplified a lot of details since I=E2=80=99m not famil=
iar
with the TC implementation at this point =E2=80=93 just want to get you=
r input
in terms of whether this is a worthwhile effort or there is something
fundamental that I=E2=80=99m not aware of. If this is just a matter of =
quite
some additional work, would also appreciate helping to outline the
required work here.

Also would appreciate if there is any information about the latest
status of this work http://www.ijcset.com/docs/IJCSET13-04-04-113.pdf

Thanks,
Ke Ma
