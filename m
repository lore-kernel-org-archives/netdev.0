From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: MSI-X and interrupt affinity with Emulex be2net
Date: Thu, 19 Jan 2012 16:33:42 +0100
Message-ID: <1326987222.2249.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=g_Vc-r-wZphGhyuDcBmSLsuSRWgoSnSQBS0zS=_3xRVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33919 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab2ASPdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 10:33:46 -0500
Received: by wics10 with SMTP id s10so37281wic.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 07:33:45 -0800 (PST)
In-Reply-To: <CAL8zT=g_Vc-r-wZphGhyuDcBmSLsuSRWgoSnSQBS0zS=_3xRVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 janvier 2012 =C3=A0 15:33 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
> Hi all,
>=20
> I am using a be2net ethernet interface, and am on the master git
> repository, so the latest kernel available.
> I have MSI-X enabled of course, and as far as I can tell, all
> interrupts are bound to CPU0.
> I have several process and threads which use quite all the ethernet
> interfaces I have, and I reach 7180 IRQs/sec on CPU0.
>=20
> I have several questions regarding this :
> - I thought MSI-X would help in balancing IRQs on different CPUs

    with some help from admin (or irqbalance ?), yes...

> - Is this a good idea anyway to specify which IRQ is bound to which
> CPU manually, if I set the process using the IRQ to the same CPU ?

There is no general answer to this question unfortunately.

It all depends on the workload, the number of flows, balance between
transmits and receives ...

Also be2net has one single interrupt for the tx-completion side.

=46or example, IP defragmentation uses a rwlock, so splitting your traf=
ic
to several cpus might increase false sharing and contention.

About the "all interrupts on CPU0", this is what happens with default
smp_affinity settings.

Here I have a be2net and can change IRQ affinities with no problem

# grep eth3 /proc/interrupts=20
  76:    1418189          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-tx
  77:      24831          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq0
  78:       5147          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq1
  79:          7          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq2
  80:          2          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq3
  81:        118          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq4
# cat /proc/irq/77/smp_affinity=20
ffff
# echo 2 >/proc/irq/77/smp_affinity
# echo 4 >/proc/irq/78/smp_affinity
# echo 8 >/proc/irq/79/smp_affinity
# echo 10 >/proc/irq/80/smp_affinity
# echo 20 >/proc/irq/81/smp_affinity
# grep eth3 /proc/interrupts=20
  76:    1426698          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-tx
  77:      24832          7          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq0
  78:       5318          0       3489          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq1
  79:          7          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq2
  80:          3          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq3
  81:        167          0          0          0          0        229
0          0          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth3-rxq4


> - How can I measure performance impact (using perf, probably) of no
> balancing (ie, all on CPU0) versus balancing like explained above ?

Yes, perf is a good tool.
