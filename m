From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.17-mm4
Date: Thu, 29 Jun 2006 23:09:50 +0200
Message-ID: <20060629210950.GA300@elte.hu>
References: <20060629013643.4b47e8bd.akpm@osdl.org> <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com> <20060629204330.GC13619@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:17621 "EHLO mx3.mail.elte.hu")
	by vger.kernel.org with ESMTP id S932464AbWF2VOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 17:14:34 -0400
To: Dave Jones <davej@redhat.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060629204330.GC13619@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Dave Jones <davej@redhat.com> wrote:

> On Thu, Jun 29, 2006 at 10:39:33PM +0200, Michal Piotrowski wrote:
> 
>  > This looks very strange.
>  > 
>  > BUG: unable to handle kernel paging request at virtual address 6b6b6c07
> 
> Looks like a use after free.

i'm too hunting use-after-free bugs - the ones fixed below fix certain 
crashes, but i'm still seeing a nasty one.

the crash is independent on lockdep enabled or disabled. See:

  http://redhat.com/~mingo/misc/

for the config and the crash.log.

	Ingo

-----------------
Subject: fix platform_device_put/del mishaps
From: Ingo Molnar <mingo@elte.hu>

this fixes drivers/char/pc8736x_gpio.c and drivers/char/scx200_gpio.c
to use the platform_device_del/put ops correctly.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/char/pc8736x_gpio.c |    5 +++--
 drivers/char/scx200_gpio.c  |    6 +++---
 2 files changed, 6 insertions(+), 5 deletions(-)

Index: linux/drivers/char/pc8736x_gpio.c
===================================================================
--- linux.orig/drivers/char/pc8736x_gpio.c
+++ linux/drivers/char/pc8736x_gpio.c
@@ -319,9 +319,10 @@ static int __init pc8736x_gpio_init(void
 	return 0;
 
 undo_platform_dev_add:
-	platform_device_put(pdev);
+	platform_device_del(pdev);
 undo_platform_dev_alloc:
-	kfree(pdev);
+	platform_device_put(pdev);
+
 	return rc;
 }
 
Index: linux/drivers/char/scx200_gpio.c
===================================================================
--- linux.orig/drivers/char/scx200_gpio.c
+++ linux/drivers/char/scx200_gpio.c
@@ -126,9 +126,10 @@ static int __init scx200_gpio_init(void)
 undo_chrdev_region:
 	unregister_chrdev_region(dev, num_pins);
 undo_platform_device_add:
-	platform_device_put(pdev);
+	platform_device_del(pdev);
 undo_malloc:
-	kfree(pdev);
+	platform_device_put(pdev);
+
 	return rc;
 }
 
@@ -136,7 +137,6 @@ static void __exit scx200_gpio_cleanup(v
 {
 	kfree(scx200_devices);
 	unregister_chrdev_region(MKDEV(major, 0), num_pins);
-	platform_device_put(pdev);
 	platform_device_unregister(pdev);
 	/* kfree(pdev); */
 }
