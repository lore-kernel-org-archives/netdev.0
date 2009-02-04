From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Wed, 4 Feb 2009 21:25:47 +1030
Message-ID: <200902042125.48723.rusty@rustcorp.com.au>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au> <20090204101130.GB19498@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.cz>,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57072 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbZBDK4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 05:56:00 -0500
In-Reply-To: <20090204101130.GB19498@flint.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 February 2009 20:41:30 Russell King wrote:
> On Wed, Feb 04, 2009 at 02:18:08PM +1030, Rusty Russell wrote:
> >   gameport.c, serio.c and input.c increment their own refcount, but to get
> > into those init functions someone must be holding a refcount already (ie. a
> > module depends on this module).  Ditto cyber2000fb.c, and MTD.
> 
> Err, wrong.  cyber2000fb.c does it in its module initialization function
> to prevent the module (when built for Shark) from being unloaded.  It
> does this because it's from the days of 2.2 kernels and no one bothered
> writing the module unload support for Shark.  I'm certainly not in a
> position to do that.

Thanks, here's the patch then:

Subject: cyber2000fb.c: use proper method for stopping unload if CONFIG_ARCH_SHARK

Russell explains the __module_get():
> cyber2000fb.c does it in its module initialization function
> to prevent the module (when built for Shark) from being unloaded.  It
> does this because it's from the days of 2.2 kernels and no one bothered
> writing the module unload support for Shark.

Since 2.4, the correct answer has been to not define an unload fn.

Cc: Russell King <rmk+lkml@arm.linux.org.uk>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/video/cyber2000fb.c b/drivers/video/cyber2000fb.c
--- a/drivers/video/cyber2000fb.c
+++ b/drivers/video/cyber2000fb.c
@@ -1736,10 +1736,8 @@ static int __init cyber2000fb_init(void)
 
 #ifdef CONFIG_ARCH_SHARK
 	err = cyberpro_vl_probe();
-	if (!err) {
+	if (!err)
 		ret = 0;
-		__module_get(THIS_MODULE);
-	}
 #endif
 #ifdef CONFIG_PCI
 	err = pci_register_driver(&cyberpro_driver);
@@ -1749,14 +1747,15 @@ static int __init cyber2000fb_init(void)
 
 	return ret ? err : 0;
 }
+module_init(cyber2000fb_init);
 
+#ifndef CONFIG_ARCH_SHARK
 static void __exit cyberpro_exit(void)
 {
 	pci_unregister_driver(&cyberpro_driver);
 }
-
-module_init(cyber2000fb_init);
 module_exit(cyberpro_exit);
+#endif
 
 MODULE_AUTHOR("Russell King");
 MODULE_DESCRIPTION("CyberPro 2000, 2010 and 5000 framebuffer driver");
