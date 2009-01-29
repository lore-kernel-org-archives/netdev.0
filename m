From: Vladimir Kukushkin <v.kukushkin@gmail.com>
Subject: How-to use Miltiqueue Rx on SMP ?
Date: Thu, 29 Jan 2009 15:15:00 +0300
Message-ID: <b4e9c0400901290415y39bc3c89haac2beb8cc9eb81a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladimir Kukushkin <v.kukushkin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:41808 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbZA2MPD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 07:15:03 -0500
Received: by fk-out-0910.google.com with SMTP id f33so4281325fkf.5
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 04:15:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I need in advice for multiqueue Rx in SMP environment.

We have a task for high performance analyzer on SMP system. The system
includes 1Gb multiqueue Ethernet cards, say Intel 1000/PRO series.
Also we use multiqueue capable eth driver like igb. The system also
have additional ethernet card for control (ssh, etc.).
Most important requirements for the system
- high performance on Rx
- reliable response under any load

Could you criticize approach described below ?
Would Rx throughput be raised using Rx multiqueue card/driver and SMP ?
Would the system be responsible if we separate Rx traffic handling
from other processes by using dedicated CPUs ?

Principles:

1) Separation of CPUs in two groups: dedicated CPUs and other CPUs.
Critical processes (in user and kernel space) of the data receive and
analyze are executed on dedicated CPUs,
however system services and other applications are running on rest CPUs=
=2E
To start user-space tasks on selected CPUs I use "taskset" command.
To set default process affinity I use kernel parameter "default_affinit=
y".

2) Rx interrupts are processed on dedicated CPUs using smp_affinity fea=
ture.
I configure this with the help of "smp_affinity" mask in
/proc/irq/XX/smp_affinitiy

3) The daemon irqbalance has to be configured to ignore dedicated CPUs.
I set mask IRQ_AFFINITY_MASK in the config file /etc/sysconfig/irqbalan=
ce.
Note: irqbalance may be switched off (or should be ?)

Example:
-------------

Assume we have 4 CPUs - cpu0..cpu3 and we have 2 NICs for data -
  eth1 on irq=3D18, and
  eth2 on irq=3D223.
Also we use 1 more NIC for system control stuff -
  eth0 on irq=3D44

We want to use CPUs in such manner:
Cpu0 - handles eth0
Cpu1 - handles eth1
Cpu0 and cpu1 also handle our data analyzis application.

Cpu2 cpu3 - handle system services and other applications

 Setup (NB: bit masks)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

1) Start kernel with default affinity mask so that all processes will
be executed on cpu2 and cpu3 by default
i.e. add "default_affinity" mask to boot/grub.conf (or lilo by your cho=
ice)

kernel /boot/linux... default_affinity=3D0xC

2) Set SMP affinity for NICs

$ echo 0x1 > /proc/irq/18/smp_affinitiy  // eth1 (irq=3D18) on cpu0
$ echo 0x2 > /proc/irq/223/smp_affinitiy // eth2 (irq=3D223) on cpu1
$ echo 0xC > /proc/irq/44/smp_affinitiy // eth0 (irq=3D44) on cpu2 cpu3

3) Hide cpu0 =C9 cpu1 for system services (mask 0xC=3D01100)

i.e. set IRQ_AFFINITY_MASK=3D0xC (1100) to file /etc/sysconfig/irqbalan=
ce

4) Run analyzer application on cpu0 cpu1 (mask=3D0x3=3D0011)

$ taskset 0x3 <analyzer app>

--=20
Vladimir
