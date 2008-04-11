From: Daniel Barkalow <barkalow@iabervon.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 18:06:34 -0400 (EDT)
Message-ID: <alpine.LNX.1.00.0804111700550.19665@iabervon.org>
References: <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org>
 <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org> <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Hellwig <hch@infradead.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iabervon.org ([66.92.72.58]:39358 "EHLO iabervon.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178AbYDKWGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 18:06:39 -0400
In-Reply-To: <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Apr 2008, Linus Torvalds wrote:

> On Fri, 11 Apr 2008, Christoph Hellwig wrote:
> > 
> > As a start we could do two driver keyed off a single Kconfig variable.
> > And then find a way to get users informed that they might need to
> > enabled the other one
> 
> I think that's a great solution.
> 
> Here's a suggested patch. Not much tested, but it's fairly obvious.
> 
> It basically makes one top-level config option (E1000) to pick the driver 
> at all, and two sub-options (E1000_PCI and E1000_PCIE) that you can choose 
> between.
> 
> If you pick E1000 support, you're given the choice between "PCI only", 
> "PCI-E only" or "support both", and that will then pick the right 
> combination of support for E1000_PCI and E1000_PCIE.

Wouldn't it make more sense to turn E1000 into a option that does nothing 
except select both E1000E and E1000_PCI, and have those two be the options 
that build drivers? Then, after a while, we drop the E1000 option 
entirely, and people are fine as long as they used any of the kernels in 
between (since the system will have forgotten that E1000E was only set by 
an option that has disappeared).

Right now, E1000 means "support both PCI and PCI-E E1000" and E1000E means 
"support PCI-E E1000". I don't see any reason not to add a "support PCI 
E1000" option and keep the semantics of existing options the same and just 
change the implementation.

AFAICT, this makes "make oldconfig" always give the same support that the 
the earlier kernel had and people get set it to what they actually want if 
they notice.

I.e., something like this (plus removing the ID-stealing in e1000):

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f337800..9078bde 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1955,6 +1955,11 @@ config DL2K
 
 config E1000
 	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
+	select E1000_PCI
+	select E1000E
+
+config E1000_PCI
+	tristate "Intel(R) PRO/1000 PCI Gigabit Ethernet support"
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
@@ -1976,7 +1981,7 @@ config E1000
 
 config E1000_NAPI
 	bool "Use Rx Polling (NAPI)"
-	depends on E1000
+	depends on E1000_PCI
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
 	  when the driver is receiving lots of packets from the card. It is
@@ -1990,7 +1995,7 @@ config E1000_NAPI
 
 config E1000_DISABLE_PACKET_SPLIT
 	bool "Disable Packet Split for PCI express adapters"
-	depends on E1000
+	depends on E1000_PCI
 	help
 	  Say Y here if you want to use the legacy receive path for PCI express
 	  hardware.
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3b1ea32..8026e63 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -2,7 +2,7 @@
 # Makefile for the Linux network (ethercard) device drivers.
 #
 
-obj-$(CONFIG_E1000) += e1000/
+obj-$(CONFIG_E1000_PCI) += e1000/
 obj-$(CONFIG_E1000E) += e1000e/
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
