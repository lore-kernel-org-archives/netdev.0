From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.68] [BRIDGE] More user hz conversions
Date: Mon, 28 Apr 2003 13:48:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428134854.21622b2b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several more places need USER/KERNEL HZ conversion.  Without these the timer
values in 'brctl showmacs' and 'brctl showstp' are off.

diff -Nru a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
--- a/net/bridge/br_fdb.c	Mon Apr 28 13:42:51 2003
+++ b/net/bridge/br_fdb.c	Mon Apr 28 13:42:51 2003
@@ -41,15 +41,15 @@
 	return 0;
 }
 
-static __inline__ void copy_fdb(struct __fdb_entry *ent, struct net_bridge_fdb_entry *f)
+static __inline__ void copy_fdb(struct __fdb_entry *ent, 
+				const struct net_bridge_fdb_entry *f)
 {
 	memset(ent, 0, sizeof(struct __fdb_entry));
 	memcpy(ent->mac_addr, f->addr.addr, ETH_ALEN);
 	ent->port_no = f->dst?f->dst->port_no:0;
 	ent->is_local = f->is_local;
-	ent->ageing_timer_value = 0;
-	if (!f->is_static)
-		ent->ageing_timer_value = jiffies - f->ageing_timer;
+	ent->ageing_timer_value = f->is_static ? 0 
+		: ((jiffies - f->ageing_timer) * USER_HZ) / HZ;
 }
 
 static __inline__ int br_mac_hash(unsigned char *mac)
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Mon Apr 28 13:43:08 2003
+++ b/net/bridge/br_ioctl.c	Mon Apr 28 13:43:08 2003
@@ -19,19 +19,22 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
+/* import values in USER_HZ  */
+static inline unsigned long user_to_ticks(unsigned long utick)
+{
+	return (utick * HZ) / USER_HZ;
+}
 
-/* Report time remaining in user HZ for compatibility. */
-static inline unsigned long timer_residue(const struct br_timer *timer)
+/* export values in USER_HZ */
+static inline unsigned long ticks_to_user(unsigned long tick)
 {
-	return timer->running 
-		? ((jiffies - timer->expires) * USER_HZ)/HZ 
-		: 0;
+	return (tick * USER_HZ) / HZ;
 }
 
-/* Convert API times in USER_HZ to kernel */
-static inline unsigned long user_to_ticks(unsigned long utick)
+/* Report time remaining in user HZ  */
+static unsigned long timer_residue(const struct br_timer *timer)
 {
-	return (utick * HZ) / USER_HZ;
+	return ticks_to_user(timer->running ? (jiffies - timer->expires) : 0);
 }
 
 static int br_ioctl_device(struct net_bridge *br,
@@ -73,18 +76,18 @@
 		memcpy(&b.designated_root, &br->designated_root, 8);
 		memcpy(&b.bridge_id, &br->bridge_id, 8);
 		b.root_path_cost = br->root_path_cost;
-		b.max_age = br->max_age;
-		b.hello_time = br->hello_time;
+		b.max_age = ticks_to_user(br->max_age);
+		b.hello_time = ticks_to_user(br->hello_time);
 		b.forward_delay = br->forward_delay;
 		b.bridge_max_age = br->bridge_max_age;
 		b.bridge_hello_time = br->bridge_hello_time;
-		b.bridge_forward_delay = br->bridge_forward_delay;
+		b.bridge_forward_delay = ticks_to_user(br->bridge_forward_delay);
 		b.topology_change = br->topology_change;
 		b.topology_change_detected = br->topology_change_detected;
 		b.root_port = br->root_port;
 		b.stp_enabled = br->stp_enabled;
-		b.ageing_time = br->ageing_time;
-		b.gc_interval = br->gc_interval;
+		b.ageing_time = ticks_to_user(br->ageing_time);
+		b.gc_interval = ticks_to_user(br->gc_interval);
 		b.hello_timer_value = timer_residue(&br->hello_timer);
 		b.tcn_timer_value = timer_residue(&br->tcn_timer);
 		b.topology_change_timer_value = timer_residue(&br->topology_change_timer);
