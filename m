From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 13:28:45 +0300
Message-ID: <20090506102845.GA24920@francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0069F3.5030607@cosmosbay.com> <20090505174135.GA29716@francoudi.com> <4A008A72.6030607@cosmosbay.com> <20090505235008.GA17690@francoudi.com> <4A0105A8.3060707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:4518 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbZEFK2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 06:28:47 -0400
Content-Disposition: inline
In-Reply-To: <4A0105A8.3060707@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2009 at 05:36:08AM +0200, Eric Dumazet wrote:

> > Is there any way at least to balance individual NICs on per core basis?
> > 
> 
> Problem of this setup is you have four NICS, but two logical devices (bond0
> & bond1) and a central HTB thing. This essentialy makes flows go through the same
> locks (some rwlocks guarding bonding driver, and others guarding HTB structures).
> 
> Also when a cpu receives a frame on ethX, it has to forward it on ethY, and
> another lock guards access to TX queue of ethY device. If another cpus receives
> a frame on ethZ and want to forward it to ethY device, this other cpu will
> need same locks and everything slowdown.
> 
> I am pretty sure you could get good results choosing two cpus sharing same L2
> cache. L2 on your cpu is 6MB. Another point would be to carefuly choose size
> of RX rings on ethX devices. You could try to *reduce* them so that number
> of inflight skb is small enough that everything fits in this 6MB cache.
> 
> Problem is not really CPU power, but RAM bandwidth. Having two cores instead of one
> attached to one central memory bank wont increase ram bandwidth, but reduce it.

Thanks for the detailed explanation.

On the particular server I reported, I worked around the problem by getting rid of classes 
and switching to ingress policers.

However, I have one central box doing HTB, small amount of classes, but 850 mbps of
traffic. The CPU is dual-core 5160 @ 3 Ghz. With 2.6.29 + bond I'm experiencing strange problems 
with HTB, under high load borrowing doesn't seem to work properly. This box has two 
BNX2 and two E1000 NICs, and for some reason I cannot force BNX2 to sit on a single IRQ -
even though I put only one CPU into smp_affinity, it keeps balancing on both. So I cannot
figure out if its related to IRQ balancing or not.

[root@tshape3 tshaper]# cat /proc/irq/63/smp_affinity
01
[root@tshape3 tshaper]# cat /proc/interrupts | grep eth0
 63:   44610754   95469129   PCI-MSI-edge      eth0
[root@tshape3 tshaper]# cat /proc/interrupts | grep eth0
 63:   44614125   95472512   PCI-MSI-edge      eth0

lspci -v:

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
        Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction Gigabit Server Adapter
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 63
        Memory at f8000000 (64-bit, non-prefetchable) [size=32M]
        [virtual] Expansion ROM at 88200000 [disabled] [size=2K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
        Kernel driver in use: bnx2
        Kernel modules: bnx2


Any ideas on how to force it on a single CPU ?

Thanks for the new patch, I will try it and let you know.

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com
