From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 17:09:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105170915.14793157.shemminger@osdl.org>
References: <OF919647C5.E8CC7ED3-ON88256DD6.0003A8F5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF919647C5.E8CC7ED3-ON88256DD6.0003A8F5@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Try this. Instead of dropping the last reference in unregister, it does it
after all other references are gone (sort of like the old 2.4 code).

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Wed Nov  5 17:04:57 2003
+++ b/net/core/dev.c	Wed Nov  5 17:04:57 2003
@@ -2743,7 +2743,7 @@
 	unsigned long rebroadcast_time, warning_time;
 
 	rebroadcast_time = warning_time = jiffies;
-	while (atomic_read(&dev->refcnt) != 0) {
+	while (atomic_read(&dev->refcnt) > 1) {
 		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
 			rtnl_shlock();
 			rtnl_exlock();
@@ -2838,6 +2838,7 @@
 			dev->reg_state = NETREG_UNREGISTERED;
 
 			netdev_wait_allrefs(dev);
+			dev_put(dev);
 
 			/* paranoia */
 			BUG_ON(atomic_read(&dev->refcnt));
@@ -2974,7 +2975,6 @@
 	/* Finish processing unregister after unlock */
 	net_set_todo(dev);
 
-	dev_put(dev);
 	return 0;
 }
 
