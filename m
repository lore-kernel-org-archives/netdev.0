From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (3/9) bridge - jiffies_to_clock
Date: Tue, 13 Apr 2004 15:20:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413152037.5e28054d@dell_ss3.pdx.osdl.net>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than doing the math directly, use jiffies_to_clock functions
to convert from user hz to jiffies.

diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	Mon Apr 12 16:10:09 2004
+++ b/net/bridge/br_fdb.c	Mon Apr 12 16:10:09 2004
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/if_bridge.h>
+#include <linux/times.h>
 #include <asm/atomic.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -48,7 +49,7 @@
 	ent->compat_port_no = ent->port_no;
 	ent->is_local = f->is_local;
 	ent->ageing_timer_value = f->is_static ? 0 
-		: ((jiffies - f->ageing_timer) * USER_HZ) / HZ;
+		: jiffies_to_clock_t(jiffies - f->ageing_timer);
 }
 
 static __inline__ int br_mac_hash(const unsigned char *mac)
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Mon Apr 12 16:10:09 2004
+++ b/net/bridge/br_ioctl.c	Mon Apr 12 16:10:09 2004
@@ -16,26 +16,15 @@
 #include <linux/kernel.h>
 #include <linux/if_bridge.h>
 #include <linux/netdevice.h>
+#include <linux/times.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
 
-/* import values in USER_HZ  */
-static inline unsigned long user_to_ticks(unsigned long utick)
-{
-	return (utick * HZ) / USER_HZ;
-}
-
-/* export values in USER_HZ */
-static inline unsigned long ticks_to_user(unsigned long tick)
-{
-	return (tick * USER_HZ) / HZ;
-}
-
 /* Report time remaining in user HZ  */
 static unsigned long timer_residue(const struct timer_list *timer)
 {
-	return ticks_to_user(timer_pending(timer) 
-			     ? (timer->expires - jiffies) : 0);
+	return timer_pending(timer) 
+		? jiffies_to_clock_t(timer->expires - jiffies) : 0;
 }
 
 int br_ioctl_device(struct net_bridge *br, unsigned int cmd,
@@ -79,17 +68,17 @@
 		memcpy(&b.designated_root, &br->designated_root, 8);
 		memcpy(&b.bridge_id, &br->bridge_id, 8);
 		b.root_path_cost = br->root_path_cost;
-		b.max_age = ticks_to_user(br->max_age);
-		b.hello_time = ticks_to_user(br->hello_time);
+		b.max_age = jiffies_to_clock_t(br->max_age);
+		b.hello_time = jiffies_to_clock_t(br->hello_time);
 		b.forward_delay = br->forward_delay;
 		b.bridge_max_age = br->bridge_max_age;
 		b.bridge_hello_time = br->bridge_hello_time;
-		b.bridge_forward_delay = ticks_to_user(br->bridge_forward_delay);
+		b.bridge_forward_delay = jiffies_to_clock_t(br->bridge_forward_delay);
 		b.topology_change = br->topology_change;
 		b.topology_change_detected = br->topology_change_detected;
 		b.root_port = br->root_port;
 		b.stp_enabled = br->stp_enabled;
-		b.ageing_time = ticks_to_user(br->ageing_time);
+		b.ageing_time = jiffies_to_clock_t(br->ageing_time);
 		b.hello_timer_value = timer_residue(&br->hello_timer);
 		b.tcn_timer_value = timer_residue(&br->tcn_timer);
 		b.topology_change_timer_value = timer_residue(&br->topology_change_timer);
@@ -126,7 +115,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br->bridge_forward_delay = user_to_ticks(arg0);
+		br->bridge_forward_delay = clock_t_to_jiffies(arg0);
 		if (br_is_root_bridge(br))
 			br->forward_delay = br->bridge_forward_delay;
 		spin_unlock_bh(&br->lock);
@@ -137,7 +126,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br->bridge_hello_time = user_to_ticks(arg0);
+		br->bridge_hello_time = clock_t_to_jiffies(arg0);
 		if (br_is_root_bridge(br))
 			br->hello_time = br->bridge_hello_time;
 		spin_unlock_bh(&br->lock);
@@ -148,7 +137,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br->bridge_max_age = user_to_ticks(arg0);
+		br->bridge_max_age = clock_t_to_jiffies(arg0);
 		if (br_is_root_bridge(br))
 			br->max_age = br->bridge_max_age;
 		spin_unlock_bh(&br->lock);
@@ -158,7 +147,7 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		br->ageing_time = user_to_ticks(arg0);
+		br->ageing_time = clock_t_to_jiffies(arg0);
 		return 0;
 
 	case BRCTL_GET_PORT_INFO:
