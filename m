From: Robert.Olsson@data.slu.se (Robert Olsson)
Subject: (no subject)
Date: Thu, 18 Sep 2003 20:35:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F69FAF8.mail2M211N69M@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com, jgarzik@pobox.com, akpm@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Robert Olsson <robert@robur.slu.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16233.64248.666702.679433@robur.slu.se>
Date: Thu, 18 Sep 2003 20:35:36 +0200
To: Andrew Morton <akpm@osdl.org>
Cc: Jeff Garzik <jgarzik@pobox.com>,
    davem@redhat.com,
    netdev@oss.sgi.com
Subject: Re: netif_poll_disable() hangs
In-Reply-To: <20030908002914.737122a9.akpm@osdl.org>
References: <20030907232145.6ec197fd.akpm@osdl.org>
	<3F5C2D1A.5050500@pobox.com>
	<20030908002914.737122a9.akpm@osdl.org>
X-Mailer: VM 6.92 under Emacs 21.2.1


Andrew Morton writes:
 > > > 
 > > > 	ifup eth0
 > > > 	ifdown eth0
 > > > 	ifup eth0
 > > > 	ifdown eth0	<- hangs in dev_close -> netif_poll_disable()

 > 2.4 does test_bit, 2.6 does test_and_set_bit.

 
 Yeep. I noticed this too in 2.6.0-test5


--- include/linux/netdevice.h.orig	2003-09-08 21:50:31.000000000 +0200
+++ include/linux/netdevice.h	2003-09-17 17:27:58.000000000 +0200
@@ -830,9 +830,9 @@
 	local_irq_restore(flags);
 }
 
-static inline void netif_poll_disable(struct net_device *dev)
+static inline void netif_poll_sync(struct net_device *dev)
 {
-	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
+	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
 		/* No hurry. */
 		current->state = TASK_INTERRUPTIBLE;
 		schedule_timeout(1);
--- net/core/dev.c.orig	2003-09-08 21:50:06.000000000 +0200
+++ net/core/dev.c	2003-09-17 17:28:32.000000000 +0200
@@ -841,7 +841,7 @@
 	 * engine, but this requires more changes in devices. */
 
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	netif_poll_disable(dev);
+	netif_poll_sync(dev);
 
 	/*
 	 *	Call the device specific close. This cannot fail.


Cheers.

					--ro
