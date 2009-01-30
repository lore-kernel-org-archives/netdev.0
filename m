From: Bill Fink <billfink@mindspring.com>
Subject: Re: How-to use Miltiqueue Rx on SMP ?
Date: Fri, 30 Jan 2009 02:42:51 -0500
Message-ID: <20090130024251.c58dcf84.billfink@mindspring.com>
References: <b4e9c0400901290415y39bc3c89haac2beb8cc9eb81a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Kukushkin <v.kukushkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:51897
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069AbZA3Hmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 02:42:53 -0500
In-Reply-To: <b4e9c0400901290415y39bc3c89haac2beb8cc9eb81a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jan 2009, Vladimir Kukushkin wrote:

> I need in advice for multiqueue Rx in SMP environment.
> 
> We have a task for high performance analyzer on SMP system. The system
> includes 1Gb multiqueue Ethernet cards, say Intel 1000/PRO series.
> Also we use multiqueue capable eth driver like igb. The system also
> have additional ethernet card for control (ssh, etc.).
> Most important requirements for the system
> - high performance on Rx
> - reliable response under any load
> 
> Could you criticize approach described below ?
> Would Rx throughput be raised using Rx multiqueue card/driver and SMP ?
> Would the system be responsible if we separate Rx traffic handling
> from other processes by using dedicated CPUs ?
> 
> Principles:
> 
> 1) Separation of CPUs in two groups: dedicated CPUs and other CPUs.
> Critical processes (in user and kernel space) of the data receive and
> analyze are executed on dedicated CPUs,
> however system services and other applications are running on rest CPUs.
> To start user-space tasks on selected CPUs I use "taskset" command.
> To set default process affinity I use kernel parameter "default_affinity".
> 
> 2) Rx interrupts are processed on dedicated CPUs using smp_affinity feature.
> I configure this with the help of "smp_affinity" mask in
> /proc/irq/XX/smp_affinitiy
> 
> 3) The daemon irqbalance has to be configured to ignore dedicated CPUs.
> I set mask IRQ_AFFINITY_MASK in the config file /etc/sysconfig/irqbalance.
> Note: irqbalance may be switched off (or should be ?)
> 
> Example:
> -------------
> 
> Assume we have 4 CPUs - cpu0..cpu3 and we have 2 NICs for data -
>   eth1 on irq=18, and
>   eth2 on irq=223.
> Also we use 1 more NIC for system control stuff -
>   eth0 on irq=44
> 
> We want to use CPUs in such manner:
> Cpu0 - handles eth0
> Cpu1 - handles eth1
> Cpu0 and cpu1 also handle our data analyzis application.
> 
> Cpu2 cpu3 - handle system services and other applications
> 
>  Setup (NB: bit masks)
> =================
> 
> 1) Start kernel with default affinity mask so that all processes will
> be executed on cpu2 and cpu3 by default
> i.e. add "default_affinity" mask to boot/grub.conf (or lilo by your choice)
> 
> kernel /boot/linux... default_affinity=0xC
> 
> 2) Set SMP affinity for NICs
> 
> $ echo 0x1 > /proc/irq/18/smp_affinitiy  // eth1 (irq=18) on cpu0
> $ echo 0x2 > /proc/irq/223/smp_affinitiy // eth2 (irq=223) on cpu1
> $ echo 0xC > /proc/irq/44/smp_affinitiy // eth0 (irq=44) on cpu2 cpu3
> 
> 3) Hide cpu0 __ cpu1 for system services (mask 0xC=01100)
> 
> i.e. set IRQ_AFFINITY_MASK=0xC (1100) to file /etc/sysconfig/irqbalance
> 
> 4) Run analyzer application on cpu0 cpu1 (mask=0x3=0011)
> 
> $ taskset 0x3 <analyzer app>

You might want to also force disk interrupts to cpus 2 and 3.

						-Bill
