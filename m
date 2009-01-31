From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 15:39:18 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311534340.3067@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312242.17273.rjw@sisk.pl> <alpine.LFD.2.00.0901311348000.4064@localhost.localdomain> <200902010008.32126.rjw@sisk.pl> <alpine.LFD.2.00.0901311516360.2978@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51128 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751380AbZAaXjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 18:39:52 -0500
In-Reply-To: <alpine.LFD.2.00.0901311516360.2978@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Linus Torvalds wrote:
> 
> But how many people test STR while doing a "ping -f" from another machine?
> 
> It _should_ work. Do you guarantee that it does?

Btw, this really only is interesting if there's a shared interrupt. 

I'm sure that there are network drivers that will crash even on their own 
with _just_ the right timing (imagine having a delayed interrupt pending, 
then doing the "pci_set_power_state(PCI_D3hot)" thing, and then get the 
interrupt handler invoked on another CPU _just_ afterwards), but it's 
probably really hard to trigger, and a bug in that specific driver anyway.

But what's much more interesting (and not necessarily a driver bug, but a 
general PM infrastructure problem) is if we have that shared interrupt 
case, and the network driver gets lots of interrupts just as "driver X" is 
shutting down with that interrupt shared. Then, "driver X" will get 
interrupts after the PM layer has put its device to sleep, and now "driver 
X" is quite understandably confused - it didn't even do the "put to sleep" 
itself, but now its device is no longer responding.

And now it's not a really unlikely race condition any more. 

			Linus
