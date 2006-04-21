From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] netdev sysfs failure handling
Date: Fri, 21 Apr 2006 13:42:05 -0700
Message-ID: <20060421134205.2786a0ee@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54444 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932426AbWDUUmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:42:07 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of sysfs failure, don't let device be brought up.
It can be cleared by unregister_netdevice so module can be unloaded
normally.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2-2.6.17.orig/net/core/dev.c	2006-04-21 12:21:45.000000000 -0700
+++ sky2-2.6.17/net/core/dev.c	2006-04-21 12:46:48.000000000 -0700
@@ -3043,10 +3043,17 @@
 
 		switch(dev->reg_state) {
 		case NETREG_REGISTERING:
+			/* Can't do proper error handling here because
+			 * this is a delayed call after register_netdevice
+			 * so no way to tell device driver what is wrong.
+			 */
 			err = netdev_register_sysfs(dev);
-			if (err)
+			if (err) {
 				printk(KERN_ERR "%s: failed sysfs registration (%d)\n",
 				       dev->name, err);
+				/* Don't let device be brought up */
+				clear_bit(__LINK_STATE_PRESENT, &dev->state);
+			}
 			dev->reg_state = NETREG_REGISTERED;
 			break;
 
