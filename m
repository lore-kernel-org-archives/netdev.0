From: Graham Murray <gmurray@webwayone.co.uk>
Subject: Re: [PATCH 2/9] sky2: more receive shutdown
Date: Sat, 20 Jun 2009 08:14:52 +0100
Message-ID: <7wiqirz89f.fsf@gmdev.webwayone.co.uk>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.582840975@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from procserver.webwayone.co.uk ([62.8.115.202]:57505 "EHLO
	procserver.webwayone.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750718AbZFTH3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 03:29:14 -0400
Received: from gmdev.webwayone.co.uk (gmdev.webwayone.co.uk [192.168.50.45])
	by procserver.webwayone.co.uk (8.14.2/8.14.2) with ESMTP id n5K7EqFv026977
	for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 08:14:53 +0100
In-Reply-To: <20090617173139.582840975@vyatta.com> (Stephen Hemminger's
	message of "Wed, 17 Jun 2009 10:30:33 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Reset more parts of the receive path when device is take offline.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/drivers/net/sky2.c	2009-06-17 10:29:50.630937431 -0700
> +++ b/drivers/net/sky2.c	2009-06-17 10:29:52.005685817 -0700
> @@ -1151,7 +1151,14 @@ stopped:
>  
>  	/* reset the Rx prefetch unit */
>  	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
> -	mmiowb();
> +
> +	/* Reset the RAM Buffer receive queue */
> +	sky2_write8(hw, RB_ADDR(rxq, RB_CTRL), RB_RST_SET);
> +
> +	/* Reset Rx MAC FIFO */
> +	sky2_write8(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), GMF_RST_SET);
> +
> +	sky2_read8(hw, B0_CTST);
>  }
>  
>  /* Clean out receive buffer area, assumes receiver hardware stopped */

With this this patch applied, the receive on my network card does not
work from boot. Git bisect identified this as the 'bad' commit and after
reverting it all works properly.

Here are the entries for sky2 and eth0 from the system log for a boot
with the patch enabled:-

Jun 20 06:38:25 newton sky2 driver version 1.23
Jun 20 06:38:25 newton sky2 0000:04:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
Jun 20 06:38:25 newton sky2 0000:04:00.0: setting latency timer to 64
Jun 20 06:38:25 newton sky2 0000:04:00.0: Yukon-2 EC chip revision 2
Jun 20 06:38:25 newton sky2 0000:04:00.0: irq 30 for MSI/MSI-X
Jun 20 06:38:25 newton sky2 eth0: addr 00:1b:fc:65:82:93
Jun 20 06:38:25 newton sky2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Jun 20 06:38:25 newton sky2 0000:03:00.0: setting latency timer to 64
Jun 20 06:38:25 newton sky2 0000:03:00.0: Yukon-2 EC chip revision 2
Jun 20 06:38:25 newton sky2 0000:03:00.0: irq 31 for MSI/MSI-X
Jun 20 06:38:25 newton sky2 eth1: addr 00:1b:fc:65:7c:be
Jun 20 06:38:25 newton sky2 eth0: enabling interface
Jun 20 06:38:25 newton ADDRCONF(NETDEV_UP): eth0: link is not ready
Jun 20 06:38:28 newton sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
Jun 20 06:38:28 newton ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

lspci -v
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 20)
        Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet controller PCIe (Asus)
        Flags: bus master, fast devsel, latency 0, IRQ 31
        Memory at ff7fc000 (64-bit, non-prefetchable) [size=16K]
        I/O ports at a800 [size=256]
        Expansion ROM at ff7c0000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [5c] MSI: Mask- 64bit+ Count=1/2 Enable+
        Capabilities: [e0] Express Legacy Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: sky2
        Kernel modules: sky2
