From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 15:06:30 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain> <alpine.DEB.2.00.0901282049040.5026@parag-desktop> <20090129184215.GA13459@xw6200.broadcom.net> <alpine.DEB.2.00.0901291700130.5149@parag-desktop>
 <20090129222247.GA13861@xw6200.broadcom.net> <alpine.DEB.2.00.0901291730030.5149@parag-desktop> <20090130184030.GA14933@xw6200.broadcom.net> <alpine.DEB.2.00.0901301743410.4989@parag-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52875 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753483AbZA3XGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:06:34 -0500
In-Reply-To: <alpine.DEB.2.00.0901301743410.4989@parag-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 30 Jan 2009, Parag Warudkar wrote:
> 
> [  245.924484] eth0: PCI_COMMAND reg = 0x406 (bit 1 is on)
> [  245.924487] eth0: Reg value at offset 0x0 is 0xffffffff
> [  247.317971] tg3: eth0: No firmware running.
> [  258.710634] ADDRCONF(NETDEV_UP): eth0: link is not ready
> ^^^ Post-Suspend
> 
> So it looks like the memory space IO is enabled before and after suspend.
> The device/vendor id goes 0xffffffff after resume - just like before.
> Does that one matter? (Firmware may be looking at it?) 

One thing strikes me - are there any bridges between the host (CPU) and 
that tg3 device?

Because we obviously have two people who say that their tg3 suspend/resume 
works fine, so the tg3 driver is obviously not _totally_ broken. So I'm 
wondering if there is something funny in between the CPU and the tg3, like 
a hotplug bridge that needs magic to wake up properly.

Because clearly the PCI config space addresses are working fine, but the 
thing is, while PCI config space accesses are routed by the device number 
(and the bridges notion of secondary bridging), the PCI memory space 
routing is based on address. So a PCI bridge can easily get one right (in 
fact, it's really hard to get config space accesses wrong without the 
bridges being _totally_ screwed up), while not routing the other at all.

So just do that "lspci -vvxxx" for the whole box, before and after, and 
send us the "before" and the "diff -u before after" thing, and maybe that 
shows something interesting. Because some bridge chip being confused would 
also explain why a total re-init of the whole tg3 chip by a driver unload 
and reload doesn't seem to help.

		Linus
