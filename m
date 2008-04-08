From: Ingo Molnar <mingo@elte.hu>
Subject: [regression] e1000e broke e1000 (was: Re: [ANNOUNCE]
	e1000 to	e1000e migration of PCI Express devices)
Date: Tue, 8 Apr 2008 20:39:21 +0200
Message-ID: <20080408183921.GA20803@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <47FB9ABB.9080403@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> > such driver transitions are never smooth. For example there's an 
> > open e1000e/e1000 regression in .25 in this area that i just noticed 
> > on a testbox while doing randconfig testing. (that's why i noticed 
> > this message of yours on lkml, i was searching for e1000 regression 
> > reports).

> This is really a vague report. Maybe you need to adjust your network 
> setup to explicitly load the correct driver at boot? The adapter works 
> correct here and I have a stock T60 here as well, just as you.

this is a simple bzImage kernel, no modules at all. Here's the full 
regression report:

kernel used: latest -git, head 7180c4c9e09888db0a188f729c96c6d7bd61fa83. 
Regression seems to have been introduced into v2.6.25 by this commit:

| commit 040babf9d84e7010c457e9ce69e9eb1c27927c9e
| Author: Auke Kok <auke-jan.h.kok@intel.com>
| Date:   Wed Oct 31 15:22:05 2007 -0700
|
|    e1000/e1000e: Move PCI-Express device IDs over to e1000e

v2.6.25-rc8 regresses relative to v2.6.24, with the following config, 
which config works fine in v2.6.24:

   http://redhat.com/~mingo/misc/config.e1000.bad

the eth0 interface is not detected at all:

   http://redhat.com/~mingo/misc/dmesg.e1000.bad

after more than an hour of experimenting around and bisecting the 
.config variances it turned out that turning off E1000E driver _module_ 
completely (which isnt even loaded, nor attempted to be loaded) made the 
kernel boot again:

   http://redhat.com/~mingo/misc/config.e1000.good

and the e1000 interface is detected fine just like it was in v2.6.24:

   http://redhat.com/~mingo/misc/dmesg.e1000.good

the difference in the config is:

--- config.e1000.good	2008-04-08 20:24:30.000000000 +0200
+++ config.e1000.bad	2008-04-08 20:20:53.000000000 +0200
@@ -1400,8 +1400,8 @@ CONFIG_DL2K=m
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
-# CONFIG_E1000E is not set
-# CONFIG_E1000E_ENABLED is not set
+CONFIG_E1000E=m
+CONFIG_E1000E_ENABLED=y
 # CONFIG_IP1000 is not set
 # CONFIG_IGB is not set
 CONFIG_NS83820=m

it results in the following bootup difference:

--- dmesg.e1000.good	2008-04-08 20:27:20.000000000 +0200
+++ dmesg.e1000.bad	2008-04-08 20:27:20.000000000 +0200
@@ -1269,14 +1269,8 @@ initcall 0xc06b7ce9 ran for 0 msecs: cpq
 Calling initcall 0xc06b81e1: e1000_init_module+0x0/0x6e()
 Intel(R) PRO/1000 Network Driver - version 7.3.20-k2-NAPI
 Copyright (c) 1999-2006 Intel Corporation.
-ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
-PCI: Setting latency timer of device 0000:02:00.0 to 64
-e1000: 0000:02:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:16:41:17:49:d2
-e1000: 0000:02:00.0: e1000_probe: This device (id 8086:109a) will no longer be supported by this driver in the future.
-e1000: 0000:02:00.0: e1000_probe: please use the "e1000e" driver instead.
-e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
 initcall 0xc06b81e1: e1000_init_module+0x0/0x6e() returned 0.
-initcall 0xc06b81e1 ran for 81 msecs: e1000_init_module+0x0/0x6e()
+initcall 0xc06b81e1 ran for 0 msecs: e1000_init_module+0x0/0x6e()
 Calling initcall 0xc06b824f: e100_init_module+0x0/0x4d()
 e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
 e100: Copyright(c) 1999-2006 Intel Corporation
@@ -2087,7 +2080,6 @@ warning: `dbus-daemon' uses 32-bit capab
 	Capabilities: [e0] Express Endpoint, MSI 00
 	Capabilities: [100] Advanced Error Reporting <?>
 	Capabilities: [140] Device Serial Number d2-49-17-ff-ff-41-16-00
-	Kernel driver in use: e1000
 
 03:00.0 Network controller: Intel Corporation PRO/Wireless 3945ABG Network Connection (rev 02)
 	Subsystem: Intel Corporation Unknown device 1010

so the pure presence of the e1000e module breaks the e1000 driver. That 
is a regression and a bug that should be fixed.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
