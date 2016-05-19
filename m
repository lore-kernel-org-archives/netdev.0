From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 11:56:30 -0700
Message-ID: <1463684190.18194.228.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34115 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754835AbcESS4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:56:38 -0400
Received: by mail-pa0-f68.google.com with SMTP id yl2so8649782pac.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 11:56:38 -0700 (PDT)
In-Reply-To: <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 11:03 -0700, Alexander Duyck wrote:
> On Thu, May 19, 2016 at 10:08 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > busylock was added at the time we had expensive ticket spinlocks
> >
> > (commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527 ("net: add additio=
nal
> > lock to qdisc to increase throughput")
> >
> > Now kernel spinlocks are MCS, this busylock things is no longer
> > relevant. It is slowing down things a bit.
> >
> >
> > With HTB qdisc, here are the numbers for 200 concurrent TCP_RR, on =
a host with 48 hyperthreads.
> >
> > lpaa5:~# sar -n DEV 4 4 |grep eth0
> > 10:05:44         eth0 798951.25 798951.75  52276.22  52275.26      =
0.00      0.00      0.50
> > 10:05:48         eth0 798576.00 798572.75  52251.24  52250.39      =
0.00      0.00      0.75
> > 10:05:52         eth0 798746.00 798748.75  52262.89  52262.13      =
0.00      0.00      0.50
> > 10:05:56         eth0 798303.25 798291.50  52235.22  52233.10      =
0.00      0.00      0.50
> > Average:         eth0 798644.12 798641.19  52256.39  52255.22      =
0.00      0.00      0.56
> >
> > Disabling busylock (by using a local sysctl)
> >
> > lpaa5:~# sar -n DEV 4 4 |grep eth0
> > 10:05:14         eth0 864085.75 864091.50  56538.09  56537.46      =
0.00      0.00      0.50
> > 10:05:18         eth0 864734.75 864729.25  56580.35  56579.05      =
0.00      0.00      0.75
> > 10:05:22         eth0 864366.00 864361.50  56556.74  56555.00      =
0.00      0.00      0.50
> > 10:05:26         eth0 864246.50 864248.75  56549.19  56547.65      =
0.00      0.00      0.50
> > Average:         eth0 864358.25 864357.75  56556.09  56554.79      =
0.00      0.00      0.56
> >
> > That would be a 8 % increase.
>=20
> The main point of the busy lock is to deal with the bulk throughput
> case, not the latency case which would be relatively well behaved.
> The problem wasn't really related to lock bouncing slowing things
> down.  It was the fairness between the threads that was killing us
> because the dequeue needs to have priority.



>=20
> The main problem that the busy lock solved was the fact that you coul=
d
> start a number of stream tests equal to the number of CPUs in a given
> system and the result was that the performance would drop off a cliff
> and you would drop almost all the packets for almost all the streams
> because the qdisc never had a chance to drain because it would be CPU
> - 1 enqueues, followed by 1 dequeue.
>=20
> What we need if we are going to get rid of busy lock would be some
> sort of priority locking mechanism that would allow the dequeue threa=
d
> to jump to the head of the line if it is attempting to take the lock.
> Otherwise you end up spending all your time enqueuing packets into
> oblivion because the qdiscs just overflow without the busy lock in
> place.


Removing busylock helped in all cases I tested. (at least on x86 as
David pointed out)

As I said, we need to revisit busylock now that spinlocks are different=
=2E

In one case (20 concurrent UDP netperf), I even got a 500 % increase.

With busylock :

lpaa5:~# sar -n DEV 4 4|grep eth0
11:33:34         eth0      9.00 115057.00      1.60  38426.92      0.00=
      0.00      0.50
11:33:38         eth0     13.50 113237.75      2.04  37819.69      0.00=
      0.00      0.75
11:33:42         eth0     13.50 111492.25      1.76  37236.58      0.00=
      0.00      0.75
11:33:46         eth0     12.75 111401.50      2.40  37205.93      0.00=
      0.00      0.75
Average:         eth0     12.19 112797.12      1.95  37672.28      0.00=
      0.00      0.69

Packets are dropped in HTB because we hit a limit of 1000 packets there

- 100.00%  netperf  [kernel.kallsyms]  [k] kfree_skb           =E2=96=92
   - kfree_skb                                                 =E2=96=92
      -  100.00% htb_enqueue                                   =E2=96=92
            __dev_queue_xmit                                   =E2=96=92
            dev_queue_xmit                                     =E2=96=92
            ip_finish_output2                                  =E2=96=92
            ip_finish_output                                   =E2=96=92
            ip_output                                          =E2=96=92
            ip_local_out                                       =E2=96=92
         +  ip_send_skb     =20


Presumably it would tremendously help if the actual kfree_skb()
was done after qdisc lock is released, ie not from the qdisc->enqueue()
method.


Without busylock :

lpaa5:~# sar -n DEV 4 4|grep eth0
11:41:12         eth0     11.00 669053.50      1.99 223452.30      0.00=
      0.00      0.75
11:41:16         eth0      8.50 669513.25      2.27 223605.55      0.00=
      0.00      0.75
11:41:20         eth0      3.50 669426.50      0.90 223577.19      0.00=
      0.00      0.50
11:41:24         eth0      8.25 669284.00      1.42 223529.79      0.00=
      0.00      0.50
Average:         eth0      7.81 669319.31      1.65 223541.21      0.00=
      0.00      0.62
