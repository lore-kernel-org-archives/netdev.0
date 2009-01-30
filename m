From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 00:59:16 +0100
Message-ID: <200901310059.17746.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain> <alpine.DEB.2.00.0901301826490.5027@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:50923 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753173AbZAaAAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 19:00:01 -0500
In-Reply-To: <alpine.DEB.2.00.0901301826490.5027@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Parag Warudkar wrote:
> 
> On Fri, 30 Jan 2009, Linus Torvalds wrote:
> 
> > 
> > Because we obviously have two people who say that their tg3 suspend/resume 
> > works fine, so the tg3 driver is obviously not _totally_ broken. So I'm 
> > wondering if there is something funny in between the CPU and the tg3, like 
> > a hotplug bridge that needs magic to wake up properly.
> > 
> > Because clearly the PCI config space addresses are working fine, but the 
> > thing is, while PCI config space accesses are routed by the device number 
> > (and the bridges notion of secondary bridging), the PCI memory space 
> > routing is based on address. So a PCI bridge can easily get one right (in 
> > fact, it's really hard to get config space accesses wrong without the 
> > bridges being _totally_ screwed up), while not routing the other at all.
> > 
> > So just do that "lspci -vvxxx" for the whole box, before and after, and 
> > send us the "before" and the "diff -u before after" thing, and maybe that 
> > shows something interesting. Because some bridge chip being confused would 
> > also explain why a total re-init of the whole tg3 chip by a driver unload 
> > and reload doesn't seem to help.
> 
> Totally worth having this problem from a "getting an opportunity to 
> understand" standpoint. This confirms my long standing suspicion that bugs 
> in Linux kernel are merely a handiwork of few clever people to get more 
> people to understand and contribute :)
> 
> Any how  here is the pre-suspend lspci -vvxxx output followed by diff -u -
> 

[--snip--]

I think this is what we're looking for:

> @@ -472,7 +472,7 @@
>  f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00
>  
>  00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
> -	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> +	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
>  	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>  	Latency: 0, Cache Line Size: 64 bytes
>  	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0

and the PCIe port driver may be at fault.

Can you try to remove the pci_save_state(dev) from pcie_port_suspend_late()
and see if that helps?

Rafael
