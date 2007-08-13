From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH] e100 module loads 1/2 times
Date: Mon, 13 Aug 2007 09:54:53 +0200
Message-ID: <20070813075453.GA4257@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: uke Kok <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1682 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968318AbXHMH4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 03:56:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke, Jesse,

for a long time, I've been annoyed by version 3.5.17 of the e100 driver
which refuses to load on first time and only loads on second time. Since
I always had the original 2.3.43 driver in kernel 2.4, I did not care
that much. Recently, I encountered real troubles with 2.3.43 in a 802.1q
setup (basically it did not untag incoming frames). So I decided to give
3.5.17 a second try. Same problem, I had to load it twice.

I finally found the problem in e100_init_module(). Up to 3.5.14, the
return of pci_module_init() was returned. This one equals zero if
everything went fine, <0 otherwise, which is compatible with init_module().

With 3.5.17, the result comes from pci_register_driver(), which returns
the number of devices registered. So the problem now makes sense :

- first call: the driver registers itself and returns non-zero, which
  is an error for insmod

- second call: the driver cannot register again and returns zero new
  drivers, which is good for insmod.

Note that e1000 has a related bug : it uses the return from pci_module_init()
to decide whether or not to register a reboot notifier. Fortunately, the
test is performed with ret>=0, which matches ==0 and not <0 (errors), so
this works as a side effect.

The obvious fix for e100 reusing pci_module_init is below. Also, since
e100-2.3.43 does not work at all with vlans in 2.4, I was thinking about
upgrading it to 3.5.17. It would also be the same version as in 2.6,
simplifying its long-term maintenance. What do you think about this ?

Best regards,
Willy


--- e100-3.5.17/src/e100.c.orig	2007-08-13 08:53:18 +0200
+++ e100-3.5.17/src/e100.c	2007-08-13 09:24:56 +0200
@@ -2934,13 +2934,13 @@
 		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	}
 #ifdef E100_USE_REBOOT_NOTIFIER
-	retval = pci_register_driver(&e100_driver);
-	if (retval >= 0)
+	retval = pci_module_init(&e100_driver);
+	if (retval == 0)
 		register_reboot_notifier(&e100_notifier_reboot);
 
 	return retval;
 #else
-	return pci_register_driver(&e100_driver);
+	return pci_module_init(&e100_driver);
 #endif
 }
 


