From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (7/9) bridge - STP unsigned fields
Date: Tue, 13 Apr 2004 15:30:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413153046.4f47fe0f@dell_ss3.pdx.osdl.net>
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

Use correct types for fields related to spanning tree protocols.
  * costs are 32 bit unsigned
  * ports are 16 bit unsigned
  * booleans are bytes rather than bitfield
  * arrange for better packing

diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Mon Apr 12 16:11:03 2004
+++ b/net/bridge/br_private.h	Mon Apr 12 16:11:03 2004
@@ -56,19 +56,19 @@
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
-	__u8				port_no;
-	__u8				priority;
 
 	/* STP */
+	u8				priority;
+	u8				state;
+	u16				port_no;
+	unsigned char			topology_change_ack;
+	unsigned char			config_pending;
 	port_id				port_id;
-	int				state;
-	int				path_cost;
+	port_id				designated_port;
 	bridge_id			designated_root;
-	int				designated_cost;
 	bridge_id			designated_bridge;
-	port_id				designated_port;
-	unsigned			topology_change_ack:1;
-	unsigned			config_pending:1;
+	u32				path_cost;
+	u32				designated_cost;
 
 	struct timer_list		forward_delay_timer;
 	struct timer_list		hold_timer;
@@ -88,25 +88,25 @@
 
 	/* STP */
 	bridge_id			designated_root;
-	int				root_path_cost;
-	int				root_port;
-	int				max_age;
-	int				hello_time;
-	int				forward_delay;
 	bridge_id			bridge_id;
-	int				bridge_max_age;
-	int				bridge_hello_time;
-	int				bridge_forward_delay;
-	unsigned			stp_enabled:1;
-	unsigned			topology_change:1;
-	unsigned			topology_change_detected:1;
+	u32				root_path_cost;
+	unsigned long			max_age;
+	unsigned long			hello_time;
+	unsigned long			forward_delay;
+	unsigned long			bridge_max_age;
+	unsigned long			ageing_time;
+	unsigned long			bridge_hello_time;
+	unsigned long			bridge_forward_delay;
+
+	u16				root_port;
+	unsigned char			stp_enabled;
+	unsigned char			topology_change;
+	unsigned char			topology_change_detected;
 
 	struct timer_list		hello_timer;
 	struct timer_list		tcn_timer;
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
-
-	int				ageing_time;
 };
 
 extern struct notifier_block br_device_notifier;
@@ -185,7 +185,7 @@
 /* br_stp.c */
 extern void br_log_state(const struct net_bridge_port *p);
 extern struct net_bridge_port *br_get_port(struct net_bridge *br,
-				    int port_no);
+				    	   u16 port_no);
 extern void br_init_port(struct net_bridge_port *p);
 extern void br_become_designated_port(struct net_bridge_port *p);
 
@@ -196,11 +196,11 @@
 extern void br_stp_disable_port(struct net_bridge_port *p);
 extern void br_stp_recalculate_bridge_id(struct net_bridge *br);
 extern void br_stp_set_bridge_priority(struct net_bridge *br,
-				int newprio);
+				       u16 newprio);
 extern void br_stp_set_port_priority(struct net_bridge_port *p,
-			      int newprio);
+				     u8 newprio);
 extern void br_stp_set_path_cost(struct net_bridge_port *p,
-			  int path_cost);
+				 u32 path_cost);
 
 /* br_stp_bpdu.c */
 extern int br_stp_handle_bpdu(struct sk_buff *skb);
diff -Nru a/net/bridge/br_stp.c b/net/bridge/br_stp.c
--- a/net/bridge/br_stp.c	Mon Apr 12 16:11:03 2004
+++ b/net/bridge/br_stp.c	Mon Apr 12 16:11:03 2004
@@ -35,7 +35,7 @@
 }
 
 /* called under bridge lock */
-struct net_bridge_port *br_get_port(struct net_bridge *br, int port_no)
+struct net_bridge_port *br_get_port(struct net_bridge *br, u16 port_no)
 {
 	struct net_bridge_port *p;
 
@@ -49,7 +49,7 @@
 
 /* called under bridge lock */
 static int br_should_become_root_port(const struct net_bridge_port *p, 
-				      int root_port)
+				      u16 root_port)
 {
 	struct net_bridge *br;
 	struct net_bridge_port *rp;
@@ -102,9 +102,7 @@
 static void br_root_selection(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-	int root_port;
-
-	root_port = 0;
+	u16 root_port = 0;
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (br_should_become_root_port(p, root_port))
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Mon Apr 12 16:11:03 2004
+++ b/net/bridge/br_stp_if.c	Mon Apr 12 16:11:03 2004
@@ -158,7 +158,7 @@
 }
 
 /* called under bridge lock */
-void br_stp_set_bridge_priority(struct net_bridge *br, int newprio)
+void br_stp_set_bridge_priority(struct net_bridge *br, u16 newprio)
 {
 	struct net_bridge_port *p;
 	int wasroot;
@@ -183,7 +183,7 @@
 }
 
 /* called under bridge lock */
-void br_stp_set_port_priority(struct net_bridge_port *p, int newprio)
+void br_stp_set_port_priority(struct net_bridge_port *p, u8 newprio)
 {
 	__u16 new_port_id;
 
@@ -202,7 +202,7 @@
 }
 
 /* called under bridge lock */
-void br_stp_set_path_cost(struct net_bridge_port *p, int path_cost)
+void br_stp_set_path_cost(struct net_bridge_port *p, u32 path_cost)
 {
 	p->path_cost = path_cost;
 	br_configuration_update(p->br);
