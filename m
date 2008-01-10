From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: SMP code / network stack
Date: Thu, 10 Jan 2008 15:45:48 +0100
Message-ID: <20080110154548.4b78ec7c.dada1@cosmosbay.com>
References: <1199973946.29856.27.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthew.hattersley@vaioni.com
To: Jeba Anandhan <jeba.anandhan@vaioni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42068 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437AbYAJOps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 09:45:48 -0500
In-Reply-To: <1199973946.29856.27.camel@vglwks010.vgl2.office.vaioni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jan 2008 14:05:46 +0000
Jeba Anandhan <jeba.anandhan@vaioni.com> wrote:

> Hi All,
> 
> If a server has multiple processors and N number of ethernet cards, is
> it possible to handle transmission by each processor separately? .In
> other words, each processor will be responsible for tx of few ethernet
> cards?.
> 
> 
> 
> Example: Server has 4 processors and 8 ethernet cards. is it possible
> for each processor for transmission using 2 ethernet cards only?. So
> that, at a instant , data will be send out from 8 ethernet cards.

Hi Jeba

Modern ethernet cards have a big TX queue, so that even one CPU is enough
to keep several cards busy in //

You can check /proc/interrupts and change /proc/irq/*/smp_affinities to direct IRQ to 
particular cpus, but transmit is usually trigered by processes that might run on different
cpus.

If all ethernet cards are on the same IRQ, then you might have a problem...

Example on a dual processor :
# cat /proc/interrupts 
           CPU0       CPU1       
  0:   11472559   74291833    IO-APIC-edge  timer
  2:          0          0          XT-PIC  cascade
  8:          0          1    IO-APIC-edge  rtc
 81:          0          0   IO-APIC-level  ohci_hcd
 97: 1830022231        847   IO-APIC-level  ehci_hcd, eth0
121:  163095662  166443627   IO-APIC-level  libata
NMI:          0          0 
LOC:   85887285   85887193 
ERR:          0
MIS:          0

You can see eth0 is on IRQ 97
Then :
# cat /proc/irq/97/smp_affinity 
00000001
# echo 2 >/proc/irq/97/smp_affinity
# grep 97 /proc/interrupts
 97: 1830035216       2259   IO-APIC-level  ehci_hcd, eth0
# sleep 10
# grep 97 /proc/interrupts
 97: 1830035216       5482   IO-APIC-level  ehci_hcd, eth0

You can see only CPU1 is now handling IRQ 97 (but CPU0 is allowed to give to eth0 some transmit work)

You might want to check /proc/net/softnet_stat too.

If your server is doing something very special (network trafic, no disk accesses or number crunching),
 you might need to bind application processes to cpus, not only network irqs.

process A, using nic eth0 & eth1, bound to CPU 0 (process and IRQs)
process B, using nic eth2 & eth3, bound to CPU 1
process C, using nic eth4 & eth5, bound to CPU 2
process D, using nic eth6 & eth7, bound to CPU 3


Also, take a look at "ethtool -c ethX" command
