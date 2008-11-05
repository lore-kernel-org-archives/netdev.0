From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not respected
Date: Wed, 05 Nov 2008 07:33:21 +0100
Message-ID: <49113E31.8080106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48708 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbYKEGdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 01:33:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

One more problem it seems on 2.6.28-rc3

I wanted to get maximal throughput from my machine on a network bench with 3 Gigabit
links delivering 600.000 packets per second, so I tried to play with smp_affinity to
dedicate one CPU for each NIC.

It worked with 2.6.27, so there is a regression on this part.

Unfortunatly, git bisect is nearly impossible for me as after two steps
the resulting kernel doesnt event boot on this machine (same for oprofile
regression I mentioned earlier)

# grep eth1 /proc/interrupts
 45:      20425      20418      20445      20441      20345      20349      20384      20397   PCI-MSI-edge      eth1
# cat /proc/irq/45/smp_affinity
ff
# echo 1 >/proc/irq/45/smp_affinity
# cat /proc/irq/45/smp_affinity
01
# grep eth1 /proc/interrupts
 45:      20928      20920      20943      20940      20845      20847      20887      20898   PCI-MSI-edge      eth1
# grep eth1 /proc/interrupts
 45:      21037      21030      21053      21049      20953      20956      20997      21007   PCI-MSI-edge      eth1
# grep eth1 /proc/interrupts
 45:      21141      21134      21156      21154      21057      21059      21101      21110   PCI-MSI-edge      eth1

You can see interrupts keep being spreaded on all CPUS instead of CPU0 only.

That *kills* performance on high end routers and servers.

07:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S Gigabit Ethernet (rev 12)
        Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction Gigabit Server Adapter
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 45
        Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at d1000000 [disabled] [size=16K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+

bnx2 driver

Thanks
