From: Tommi Virtanen <tv@debian.org>
Subject: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 12:13:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818091312.GA4889@lapdog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi. There are cases when you want to change your MAC address,
	such as in Linux-HA when the other box fails, and your hot
	standby activates itself.

	Some NICs, such as e100, e1000 and uml ;) allow you to do that
	without bringing the interface down. Which is nice, because it
	allows the link to stay up, and not make switches scratch their
	head for up to a minute.

	The problem is, if you do that, the old MAC address is stored
	in the hh_cache entries, and used in future traffic also.


	Here's a patch that

	1. makes eth_header_cache_update also update the source MAC in
	   hh_cache.

	2. adds a NETDEV_CHANGEADDR notifier in net/core/neighbour.c
	   that walks through all the neighbour entries and updates
	   the hh_cache's for all the neighbour entries related to
	   given device.

	3. adds neighbour_init() to allow registration of said notifier.


	Please comment.



===== include/net/neighbour.h 1.1 vs edited =====
--- 1.1/include/net/neighbour.h	Tue Feb  5 19:39:48 2002
+++ edited/include/net/neighbour.h	Mon Aug 18 11:17:25 2003
@@ -275,6 +275,8 @@
 	return neigh_create(tbl, pkey, dev);
 }
 
+extern void		neighbour_init(void);
+
 #endif
 #endif
 
===== net/core/dev.c 1.36 vs edited =====
--- 1.36/net/core/dev.c	Fri May 23 20:59:51 2003
+++ edited/net/core/dev.c	Mon Aug 18 11:54:30 2003
@@ -93,6 +93,7 @@
 #include <linux/if_bridge.h>
 #include <linux/divert.h>
 #include <net/dst.h>
+#include <net/neighbour.h>
 #include <net/pkt_sched.h>
 #include <net/profile.h>
 #include <net/checksum.h>
@@ -2849,6 +2850,7 @@
 	open_softirq(NET_RX_SOFTIRQ, net_rx_action, NULL);
 
 	dst_init();
+	neighbour_init();
 	dev_mcast_init();
 
 #ifdef CONFIG_NET_SCHED
===== net/core/neighbour.c 1.9 vs edited =====
--- 1.9/net/core/neighbour.c	Thu Jun 12 09:24:41 2003
+++ edited/net/core/neighbour.c	Mon Aug 18 11:53:50 2003
@@ -1558,3 +1558,46 @@
 }
 
 #endif	/* CONFIG_SYSCTL */
+
+static int neighbour_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	switch (event) {
+		struct neigh_table *tbl;
+	case NETDEV_CHANGEADDR:
+		read_lock(&neigh_tbl_lock);
+		for (tbl = neigh_tables; tbl; tbl=tbl->next) {
+			int i;
+
+			for (i=0; i<=NEIGH_HASHMASK; i++) {
+				struct neighbour *n, **np;
+
+				np = &tbl->hash_buckets[i];
+				write_lock(&tbl->lock);
+
+				while ((n = *np) != NULL) {
+					if (n->dev == dev) {
+						neigh_update_hhs(n);
+					}
+					np = &n->next;
+				}
+				write_unlock(&tbl->lock);
+			}
+		}
+		read_unlock(&neigh_tbl_lock);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+struct notifier_block neighbour_dev_notifier = {
+	neighbour_dev_event,
+	NULL,
+	0
+};
+
+void __init neighbour_init(void)
+{
+	register_netdevice_notifier(&neighbour_dev_notifier);
+}
===== net/ethernet/eth.c 1.3 vs edited =====
--- 1.3/net/ethernet/eth.c	Fri Jun 20 00:22:53 2003
+++ edited/net/ethernet/eth.c	Mon Aug 18 11:55:36 2003
@@ -238,6 +238,11 @@
 
 void eth_header_cache_update(struct hh_cache *hh, struct net_device *dev, unsigned char * haddr)
 {
-	memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
-	       haddr, dev->addr_len);
+	struct ethhdr *eth;
+
+	eth = (struct ethhdr*)
+		(((u8*)hh->hh_data) + (HH_DATA_OFF(sizeof(*eth))));
+
+	memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
+	memcpy(eth->h_dest, haddr, dev->addr_len);
 }


-- 
:(){ :|:&};:
