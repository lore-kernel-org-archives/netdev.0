From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.68+] [BRIDGE] Inline and _rcu change.
Date: Mon, 28 Apr 2003 13:46:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428134639.0011347c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Two small changes:
* Need _rcu on the list_for_each_entry in br_get_port because called in
  read path for some ioctl's
* Move two small functions is_root_bridge and is_designated_port into
  inline's because they are so short.

diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Mon Apr 28 13:43:22 2003
+++ b/net/bridge/br_private.h	Mon Apr 28 13:43:22 2003
@@ -116,6 +116,13 @@
 extern struct notifier_block br_device_notifier;
 extern unsigned char bridge_ula[6];
 
+/* called under bridge lock */
+static inline int br_is_root_bridge(const struct net_bridge *br)
+{
+	return !memcmp(&br->bridge_id, &br->designated_root, 8);
+}
+
+
 /* br_device.c */
 extern void br_dev_setup(struct net_device *dev);
 extern int br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -182,7 +189,6 @@
 extern void br_netfilter_fini(void);
 
 /* br_stp.c */
-extern int br_is_root_bridge(struct net_bridge *br);
 extern struct net_bridge_port *br_get_port(struct net_bridge *br,
 				    int port_no);
 extern void br_init_port(struct net_bridge_port *p);
diff -Nru a/net/bridge/br_private_stp.h b/net/bridge/br_private_stp.h
--- a/net/bridge/br_private_stp.h	Mon Apr 28 13:43:22 2003
+++ b/net/bridge/br_private_stp.h	Mon Apr 28 13:43:22 2003
@@ -32,12 +32,18 @@
 	int		forward_delay;
 };
 
+/* called under bridge lock */
+static inline int br_is_designated_port(const struct net_bridge_port *p)
+{
+	return !memcmp(&p->designated_bridge, &p->br->bridge_id, 8) &&
+		(p->designated_port == p->port_id);
+}
+
+
 /* br_stp.c */
 extern void br_become_root_bridge(struct net_bridge *br);
 extern void br_config_bpdu_generation(struct net_bridge *);
 extern void br_configuration_update(struct net_bridge *);
-extern int  br_is_designated_port(struct net_bridge_port *p);
-extern int  br_is_root_bridge(struct net_bridge *br);
 extern void br_port_state_selection(struct net_bridge *);
 extern void br_received_config_bpdu(struct net_bridge_port *p, struct br_config_bpdu *bpdu);
 extern void br_received_tcn_bpdu(struct net_bridge_port *p);
diff -Nru a/net/bridge/br_stp.c b/net/bridge/br_stp.c
--- a/net/bridge/br_stp.c	Mon Apr 28 13:43:22 2003
+++ b/net/bridge/br_stp.c	Mon Apr 28 13:43:22 2003
@@ -20,27 +20,12 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-
-
-/* called under bridge lock */
-int br_is_root_bridge(struct net_bridge *br)
-{
-	return !memcmp(&br->bridge_id, &br->designated_root, 8);
-}
-
-/* called under bridge lock */
-int br_is_designated_port(struct net_bridge_port *p)
-{
-	return !memcmp(&p->designated_bridge, &p->br->bridge_id, 8) &&
-		(p->designated_port == p->port_id);
-}
-
 /* called under bridge lock */
 struct net_bridge_port *br_get_port(struct net_bridge *br, int port_no)
 {
 	struct net_bridge_port *p;
 
-	list_for_each_entry(p, &br->port_list, list) {
+	list_for_each_entry_rcu(p, &br->port_list, list) {
 		if (p->port_no == port_no)
 			return p;
 	}
