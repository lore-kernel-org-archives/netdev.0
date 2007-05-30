From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: limit the number of recoveries
Date: Wed, 30 May 2007 21:14:30 +0200
Message-ID: <465DCD16.8050907@myri.com>
References: <465DCCB4.5040404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1783 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753408AbXE3TOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:14:16 -0400
In-Reply-To: <465DCCB4.5040404@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Limit the number of recoveries from a NIC hw watchdog reset to 1 by default.
It enables detection of defective NICs immediately since these memory parity
errors are expected to happen very rarely (less than once per century*NIC).
However, a defective NIC (very rare, fortunately) can see such an error
quite often, ie. every few minutes under high load.

Make the limit tunable to allow people with mission critical installations
to crank up the tunable and recover an INTMAX number of times while waiting
for a downtime window to replace the NIC. The performance won't be optimal,
but at least, it will still work.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-05-30 20:58:22.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-05-30 20:58:34.000000000 +0200
@@ -279,6 +279,11 @@
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
 
+static int myri10ge_reset_recover = 1;
+module_param(myri10ge_reset_recover, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(myri10ge_reset_recover,
+		 "Number of recoveries allowed from NIC hw reset\n");
+
 static int myri10ge_wcfifo = 0;
 module_param(myri10ge_wcfifo, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
@@ -2730,8 +2735,14 @@
 		 * For now, just report it */
 		reboot = myri10ge_read_reboot(mgp);
 		printk(KERN_ERR
-		       "myri10ge: %s: NIC rebooted (0x%x), resetting\n",
-		       mgp->dev->name, reboot);
+		       "myri10ge: %s: NIC rebooted (0x%x),%s resetting\n",
+		       mgp->dev->name, reboot,
+		       myri10ge_reset_recover ? " " : " not");
+		if (myri10ge_reset_recover == 0)
+			return;
+
+		myri10ge_reset_recover--;
+
 		/*
 		 * A rebooted nic will come back with config space as
 		 * it was after power was applied to PCIe bus.


