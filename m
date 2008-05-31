From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 5/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Sun, 1 Jun 2008 00:54:42 +0200
Message-ID: <20080531225442.GA2747@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:52297 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753759AbYEaWzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2008 18:55:15 -0400
Content-Disposition: inline
In-Reply-To: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Diedrich <ranma+kernel@tdiedrich.de>

We currently don't signal the kernel we that this device can wake
the system.  Call device_init_wakeup() to correct this.
Without this device_can_wakeup and device_may_wakeup will return
incorrect values.
Together with the minimized acpi wakeup patch (6/4 ;)), which will
follow in the next mail, this really makes wake-on-lan work for me
as expected (i.e. "ethtool -s eth0 wol g" is sufficient, no
additional magic needed).

Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

Index: linux-2.6.26-rc4.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc4.forcedwol.orig/drivers/net/forcedeth.c	2008-06-01 00:29:58.000000000 +0200
+++ linux-2.6.26-rc4.forcedwol/drivers/net/forcedeth.c	2008-06-01 00:30:48.000000000 +0200
@@ -5539,6 +5539,11 @@
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
 
+	/* Workaround current PCI init glitch:  wakeup bits aren't
+	 * being set from PCI PM capability.
+	 */
+	device_init_wakeup(&pci_dev->dev, 1);
+
 	/* disable WOL */
 	writel(0, base + NvRegWakeUpFlags);
 	np->wolenabled = 0;
