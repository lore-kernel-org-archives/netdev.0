From: Michael Ma <make0818@gmail.com>
Subject: Re: qdisc spin lock
Date: Thu, 31 Mar 2016 16:41:30 -0700
Message-ID: <CAAmHdhwpVOCv=4Y+pb9PfGKWV0ooqnr7eC58ZYfRTtYjC35EFw@mail.gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	<20160331211852.2d228976@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34002 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbcCaXlb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:41:31 -0400
Received: by mail-ig0-f176.google.com with SMTP id sy18so3572961igc.1
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 16:41:31 -0700 (PDT)
In-Reply-To: <20160331211852.2d228976@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the suggestion - I'll try the MQ solution out. It seems to
be able to solve the problem well with the assumption that bandwidth
can be statically partitioned.

2016-03-31 12:18 GMT-07:00 Jesper Dangaard Brouer <brouer@redhat.com>:
>
> On Wed, 30 Mar 2016 00:20:03 -0700 Michael Ma <make0818@gmail.com> wr=
ote:
>
>> I know this might be an old topic so bare with me =E2=80=93 what we =
are facing
>> is that applications are sending small packets using hundreds of
>> threads so the contention on spin lock in __dev_xmit_skb increases t=
he
>> latency of dev_queue_xmit significantly. We=E2=80=99re building a ne=
twork QoS
>> solution to avoid interference of different applications using HTB.
>
> Yes, as you have noticed with HTB there is a single qdisc lock, and
> congestion obviously happens :-)
>
> It is possible with different tricks to make it scale.  I believe
> Google is using a variant of HTB, and it scales for them.  They have
> not open source their modifications to HTB (which likely also involve=
s
> a great deal of setup tricks).
>
> If your purpose it to limit traffic/bandwidth per "cloud" instance,
> then you can just use another TC setup structure.  Like using MQ and
> assigning a HTB per MQ queue (where the MQ queues are bound to each
> CPU/HW queue)... But you have to figure out this setup yourself...
>
>
>> But in this case when some applications send massive small packets i=
n
>> parallel, the application to be protected will get its throughput
>> affected (because it=E2=80=99s doing synchronous network communicati=
on using
>> multiple threads and throughput is sensitive to the increased latenc=
y)
>>
>> Here is the profiling from perf:
>>
>> -  67.57%   iperf  [kernel.kallsyms]     [k] _spin_lock
>>   - 99.94% dev_queue_xmit
>>   -  96.91% _spin_lock
>>  - 2.62%  __qdisc_run
>>   - 98.98% sch_direct_xmit
>> - 99.98% _spin_lock
>>
>> As far as I understand the design of TC is to simplify locking schem=
a
>> and minimize the work in __qdisc_run so that throughput won=E2=80=99=
t be
>> affected, especially with large packets. However if the scenario is
>> that multiple classes in the queueing discipline only have the shapi=
ng
>> limit, there isn=E2=80=99t really a necessary correlation between di=
fferent
>> classes. The only synchronization point should be when the packet is
>> dequeued from the qdisc queue and enqueued to the transmit queue of
>> the device. My question is =E2=80=93 is it worth investing on avoidi=
ng the
>> locking contention by partitioning the queue/lock so that this
>> scenario is addressed with relatively smaller latency?
>
> Yes, there is a lot go gain, but it is not easy ;-)
>
>> I must have oversimplified a lot of details since I=E2=80=99m not fa=
miliar
>> with the TC implementation at this point =E2=80=93 just want to get =
your input
>> in terms of whether this is a worthwhile effort or there is somethin=
g
>> fundamental that I=E2=80=99m not aware of. If this is just a matter =
of quite
>> some additional work, would also appreciate helping to outline the
>> required work here.
>>
>> Also would appreciate if there is any information about the latest
>> status of this work http://www.ijcset.com/docs/IJCSET13-04-04-113.pd=
f
>
> This article seems to be very low quality... spelling errors, only 5
> pages, no real code, etc.
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
