From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver and interrupt coalescence questions
Date: Tue, 27 Jun 2006 10:59:39 -0700
Message-ID: <1151431180.5678.27.camel@rh4>
References: <44A167EB.8000805@netgeeks.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:39184 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1161239AbWF0R6t
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 13:58:49 -0400
To: "Chris A. Icide" <chris@netgeeks.net>
In-Reply-To: <44A167EB.8000805@netgeeks.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 10:16 -0700, Chris A. Icide wrote:

> What version of the linux kernel & tg3 drivers are required to support both rx and tx mitigation?

ethtool -C for tg3 was added around July of 2005. The version with this
change added was 3.33.

> What do the ethtool coalescence settings actually do (I've not been able to find actual descriptions of the different parameters in the -C section)

They set the delay between the tx and rx events and the generation of
interrupts for those events.

These are the only parameters that are relevant for tg3:

rx-frames[-irq]
rx-usecs[-irq]
tx-frames[-irq]
tx-usecs[-irq]

The frames parameters specify how many packets are received/transmitted
before generating an interrupt.  The usecs parameters specify how many
microseconds after at least 1 packet is received/transmitted before
generating an interrupt.  The [-irq] parameters are the corresponding
delays in updating the status when the interrupt is disabled.

> Is there anything special that needs to be done when compiling a kernel to enable this feature for both the kernel and the tg3 driver.

No.

> 05:01.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704S
> Gigabit Ethernet (rev 10)
>         Subsystem: IBM: Unknown device 02e8
>         Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 201
>         Memory at dcfe0000 (64-bit, non-prefetchable) [size=64K]
>         Capabilities: [40] PCI-X non-bridge device.
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Message Signalled Interrupts: 64bit+
> Queue=0/3 Enable-
> 
> Linux version 2.6.9-34.ELsmp (buildcentos@nasha.karan.org) (gcc version
> 3.4.5 20051201 (Red Hat 3.4.5-2)) #1 SMP Thu Mar 9 06:23:23 GMT 2006
> 
> [root@db2 ~]# ethtool -c eth1
> Coalesce parameters for eth1:
> Adaptive RX: off  TX: off
> stats-block-usecs: 1000000
> sample-interval: 0
> pkt-rate-low: 0
> pkt-rate-high: 0
> 
> rx-usecs: 500
> rx-frames: 30
> rx-usecs-irq: 500
> rx-frames-irq: 20
> 

This means that the first interrupt will be generated after 30 packets
are received or 500 microseconds after the nth packet is received (1 <=
n < 30). When irq is disabled, 20 packets instead of 30 before updating
status.

> tx-usecs: 400
> tx-frames: 53
> tx-usecs-irq: 490
> tx-frames-irq: 5

The first tx interrupt will be generated after 53 packets are
transmitted or 400 microseconds after the nth packet is transmitted (1
<= n < 53). When irq is disabled, 5 packets or 490 micosecs before
updating status.

If the condition for generating a tx or rx interrupt is met, you get all
the accumulated tx and rx status during the interrupt.

Hope this helps.

