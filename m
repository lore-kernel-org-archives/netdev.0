From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/11) bridge -- expose timer_residue function for use by
 sysfs
Date: Fri, 21 May 2004 16:39:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521163911.10e1a07d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Move the local function timer_residue to br_timer_value so it can
be used by both ioctl and sysfs code.
 
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	2004-05-20 10:22:21 -07:00
+++ b/net/bridge/br_ioctl.c	2004-05-20 10:22:21 -07:00
@@ -20,13 +20,6 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
-/* Report time remaining in user HZ  */
-static unsigned long timer_residue(const struct timer_list *timer)
-{
-	return timer_pending(timer) 
-		? jiffies_to_clock_t(timer->expires - jiffies) : 0;
-}
-
 /* called with RTNL */
 static int get_bridge_ifindices(int *indices, int num)
 {
@@ -139,10 +132,10 @@
 		b.root_port = br->root_port;
 		b.stp_enabled = br->stp_enabled;
 		b.ageing_time = jiffies_to_clock_t(br->ageing_time);
-		b.hello_timer_value = timer_residue(&br->hello_timer);
-		b.tcn_timer_value = timer_residue(&br->tcn_timer);
-		b.topology_change_timer_value = timer_residue(&br->topology_change_timer);
-		b.gc_timer_value = timer_residue(&br->gc_timer);
+		b.hello_timer_value = br_timer_value(&br->hello_timer);
+		b.tcn_timer_value = br_timer_value(&br->tcn_timer);
+		b.topology_change_timer_value = br_timer_value(&br->topology_change_timer);
+		b.gc_timer_value = br_timer_value(&br->gc_timer);
 	        rcu_read_unlock();
 
 		if (copy_to_user((void *)args[1], &b, sizeof(b)))
@@ -237,9 +230,9 @@
 		p.state = pt->state;
 		p.top_change_ack = pt->topology_change_ack;
 		p.config_pending = pt->config_pending;
-		p.message_age_timer_value = timer_residue(&pt->message_age_timer);
-		p.forward_delay_timer_value = timer_residue(&pt->forward_delay_timer);
-		p.hold_timer_value = timer_residue(&pt->hold_timer);
+		p.message_age_timer_value = br_timer_value(&pt->message_age_timer);
+		p.forward_delay_timer_value = br_timer_value(&pt->forward_delay_timer);
+		p.hold_timer_value = br_timer_value(&pt->hold_timer);
 
 		rcu_read_unlock();
 
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-05-20 10:22:21 -07:00
+++ b/net/bridge/br_private.h	2004-05-20 10:22:21 -07:00
@@ -208,5 +208,6 @@
 /* br_stp_timer.c */
 extern void br_stp_timer_init(struct net_bridge *br);
 extern void br_stp_port_timer_init(struct net_bridge_port *p);
+extern unsigned long br_timer_value(const struct timer_list *timer);
 
 #endif
diff -Nru a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
--- a/net/bridge/br_stp_timer.c	2004-05-20 10:22:21 -07:00
+++ b/net/bridge/br_stp_timer.c	2004-05-20 10:22:21 -07:00
@@ -14,6 +14,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/times.h>
 #include <linux/smp_lock.h>
 
 #include "br_private.h"
@@ -178,3 +179,10 @@
 	br_timer_init(&p->hold_timer, br_hold_timer_expired,
 		      (unsigned long) p);
 }	
+
+/* Report ticks left (in USER_HZ) used for API */
+unsigned long br_timer_value(const struct timer_list *timer)
+{
+	return timer_pending(timer)
+		? jiffies_to_clock_t(timer->expires - jiffies) : 0;
+}
