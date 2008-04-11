From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 10:34:01 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
References: <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org>
 <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
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
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46964 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760441AbYDKRfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 13:35:46 -0400
In-Reply-To: <20080411164542.GA4066@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 11 Apr 2008, Christoph Hellwig wrote:
> 
> As a start we could do two driver keyed off a single Kconfig variable.
> And then find a way to get users informed that they might need to
> enabled the other one

I think that's a great solution.

Here's a suggested patch. Not much tested, but it's fairly obvious.

It basically makes one top-level config option (E1000) to pick the driver 
at all, and two sub-options (E1000_PCI and E1000_PCIE) that you can choose 
between.

If you pick E1000 support, you're given the choice between "PCI only", 
"PCI-E only" or "support both", and that will then pick the right 
combination of support for E1000_PCI and E1000_PCIE.

This also does imply that you cannot mix the "module-ness" of the two 
drivers, because you choose whether the E1000 support (in general) is 
going to be a module or built-in, and that choice will automatically 
affect the sub-choices.

I do think that this makes the whole driver status much more obvious.

(It does mean that if you chose E1000E before, and chose _not_ to support 
E1000 at all, you will now not even be asked about PCI-E support, because 
you've effectively said "no" to E1000 support in the first place. If we 
want to avoid that, then the top-level E1000 config variable should 
probably be renamed to E1000_SUPPORT or something like that).

		Linus

---
 drivers/net/Kconfig         |   52 +++++++++++++++++++++++-------------------
 drivers/net/Makefile        |    4 +-
 drivers/net/e1000/Makefile  |    2 +-
 drivers/net/e1000e/Makefile |    2 +-
 4 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3a0b20a..6968e20 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1979,9 +1979,35 @@ config E1000
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000.
 
+choice
+	prompt "E1000 bus type support"
+	depends on E1000
+	default E1000_BOTH
+	help
+	  Choose PCI or PCI-E support for E1000 driver
+
+config E1000_PCI_ONLY
+	bool "Support only older E1000 PCI cards"
+
+config E1000_PCIE_ONLY
+	bool "Support newer E1000 PCI-E cards"
+
+config E1000_BOTH
+	bool "Support all E1000 cards"
+
+endchoice
+
+config E1000_PCI
+	tristate
+	default E1000 && !E1000_PCIE_ONLY
+
+config E1000_PCIE
+	tristate
+	default E1000 && !E1000_PCI_ONLY
+
 config E1000_NAPI
 	bool "Use Rx Polling (NAPI)"
-	depends on E1000
+	depends on E1000_PCI
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
 	  when the driver is receiving lots of packets from the card. It is
@@ -1995,35 +2021,13 @@ config E1000_NAPI
 
 config E1000_DISABLE_PACKET_SPLIT
 	bool "Disable Packet Split for PCI express adapters"
-	depends on E1000
+	depends on E1000_PCI
 	help
 	  Say Y here if you want to use the legacy receive path for PCI express
 	  hardware.
 
 	  If in doubt, say N.
 
-config E1000E
-	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
-	depends on PCI
-	---help---
-	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
-	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
-	  use the regular e1000 driver For more information on how to
-	  identify your adapter, go to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e1000e.
-
-config E1000E_ENABLED
-	def_bool E1000E != n
-
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI && EXPERIMENTAL
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3b1ea32..c1bead0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -2,8 +2,8 @@
 # Makefile for the Linux network (ethercard) device drivers.
 #
 
-obj-$(CONFIG_E1000) += e1000/
-obj-$(CONFIG_E1000E) += e1000e/
+obj-$(CONFIG_E1000_PCI) += e1000/
+obj-$(CONFIG_E1000_PCIE) += e1000e/
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
 obj-$(CONFIG_IGB) += igb/
diff --git a/drivers/net/e1000/Makefile b/drivers/net/e1000/Makefile
index 4a6ab15..431052b 100644
--- a/drivers/net/e1000/Makefile
+++ b/drivers/net/e1000/Makefile
@@ -30,6 +30,6 @@
 # Makefile for the Intel(R) PRO/1000 ethernet driver
 #
 
-obj-$(CONFIG_E1000) += e1000.o
+obj-$(CONFIG_E1000_PCI) += e1000.o
 
 e1000-objs := e1000_main.o e1000_hw.o e1000_ethtool.o e1000_param.o
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/e1000e/Makefile
index 650f866..a1e977e 100644
--- a/drivers/net/e1000e/Makefile
+++ b/drivers/net/e1000e/Makefile
@@ -30,7 +30,7 @@
 # Makefile for the Intel(R) PRO/1000 ethernet driver
 #
 
-obj-$(CONFIG_E1000E) += e1000e.o
+obj-$(CONFIG_E1000_PCIE) += e1000e.o
 
 e1000e-objs := 82571.o ich8lan.o es2lan.o \
 	       lib.o phy.o param.o ethtool.o netdev.o
