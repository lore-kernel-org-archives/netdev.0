From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70+] bridge using alloc_netdev
Date: Mon, 9 Jun 2003 11:54:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609115408.6b90dc4e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This changes the bridge driver to encapsulate it's private information the same
way that ether drivers do.  This allows later delayed release to work properly.

Tested on my machine.

Since release_netdev isn't in yet, the destructor is just set to kfree -- that is why I wanted
the release_netdev hook to make it in part I, so all these sub drivers got patched only once.

diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_device.c	Mon Jun  9 11:42:38 2003
@@ -110,10 +110,6 @@
 	return -1;
 }
 
-static void br_dev_destruct(struct net_device *dev) 
-{
-	kfree(dev->priv);
-}
 
 void br_dev_setup(struct net_device *dev)
 {
@@ -124,10 +120,13 @@
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
-	dev->destructor = br_dev_destruct;
+	dev->destructor = (void (*)(struct net_device *))kfree;
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
 	dev->accept_fastpath = br_dev_accept_fastpath;
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = NULL;
+	dev->priv_flags = IFF_EBRIDGE;
+
+	ether_setup(dev);
 }
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_if.c	Mon Jun  9 11:42:38 2003
@@ -78,17 +78,14 @@
 	struct net_bridge *br;
 	struct net_device *dev;
 
-	if ((br = kmalloc(sizeof(*br), GFP_KERNEL)) == NULL)
+	dev = alloc_netdev(sizeof(struct net_bridge), name,
+			   br_dev_setup);
+	
+	if (!dev)
 		return NULL;
 
-	memset(br, 0, sizeof(*br));
-	dev = &br->dev;
-
-	strlcpy(dev->name, name, sizeof(dev->name));
-	dev->priv = br;
-	dev->priv_flags = IFF_EBRIDGE;
-	ether_setup(dev);
-	br_dev_setup(dev);
+	br = dev->priv;
+	br->dev = dev;
 
 	br->lock = SPIN_LOCK_UNLOCKED;
 	INIT_LIST_HEAD(&br->port_list);
@@ -159,9 +156,9 @@
 	if ((br = new_nb(name)) == NULL) 
 		return -ENOMEM;
 
-	ret = register_netdev(&br->dev);
+	ret = register_netdev(br->dev);
 	if (ret)
-		kfree(br);
+		kfree(br->dev);
 	return ret;
 }
 
@@ -219,7 +216,7 @@
 
 	br_stp_recalculate_bridge_id(br);
 	br_fdb_insert(br, p, dev->dev_addr, 1);
-	if ((br->dev.flags & IFF_UP) && (dev->flags & IFF_UP))
+	if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
 		br_stp_enable_port(p);
 	spin_unlock_bh(&br->lock);
 
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_input.c	Mon Jun  9 11:42:38 2003
@@ -40,7 +40,7 @@
 	br->statistics.rx_bytes += skb->len;
 
 	indev = skb->dev;
-	skb->dev = &br->dev;
+	skb->dev = br->dev;
 
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 			br_pass_frame_up_finish);
@@ -67,7 +67,7 @@
 
 	br = p->br;
 	passedup = 0;
-	if (br->dev.flags & IFF_PROMISC) {
+	if (br->dev->flags & IFF_PROMISC) {
 		struct sk_buff *skb2;
 
 		skb2 = skb_clone(skb, GFP_ATOMIC);
@@ -140,7 +140,7 @@
 			return -1;
 		}
 
-		if (!memcmp(p->br->dev.dev_addr, dest, ETH_ALEN))
+		if (!memcmp(p->br->dev->dev_addr, dest, ETH_ALEN))
 			skb->pkt_type = PACKET_HOST;
 
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
diff -Nru a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_netfilter.c	Mon Jun  9 11:42:38 2003
@@ -37,7 +37,7 @@
 				 sizeof(struct bridge_skb_cb)))
 
 #define has_bridge_parent(device)	((device)->br_port != NULL)
-#define bridge_parent(device)		(&((device)->br_port->br->dev))
+#define bridge_parent(device)		((device)->br_port->br->dev)
 
 /* We need these fake structures to make netfilter happy --
  * lots of places assume that skb->dst != NULL, which isn't
diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_notify.c	Mon Jun  9 11:42:38 2003
@@ -52,7 +52,7 @@
 		break;
 
 	case NETDEV_DOWN:
-		if (br->dev.flags & IFF_UP) {
+		if (br->dev->flags & IFF_UP) {
 			spin_lock_bh(&br->lock);
 			br_stp_disable_port(p);
 			spin_unlock_bh(&br->lock);
@@ -60,7 +60,7 @@
 		break;
 
 	case NETDEV_UP:
-		if (!(br->dev.flags & IFF_UP)) {
+		if (!(br->dev->flags & IFF_UP)) {
 			spin_lock_bh(&br->lock);
 			br_stp_enable_port(p);
 			spin_unlock_bh(&br->lock);
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_private.h	Mon Jun  9 11:42:38 2003
@@ -81,7 +81,7 @@
 {
 	spinlock_t			lock;
 	struct list_head		port_list;
-	struct net_device		dev;
+	struct net_device		*dev;
 	struct net_device_stats		statistics;
 	rwlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
diff -Nru a/net/bridge/br_stp.c b/net/bridge/br_stp.c
--- a/net/bridge/br_stp.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_stp.c	Mon Jun  9 11:42:38 2003
@@ -26,7 +26,7 @@
 void br_log_state(const struct net_bridge_port *p)
 {
 	pr_info("%s: port %d(%s) entering %s state\n",
-		p->br->dev.name, p->port_no, p->dev->name, 
+		p->br->dev->name, p->port_no, p->dev->name, 
 		br_port_state_names[p->state]);
 
 }
@@ -130,7 +130,7 @@
 	br_topology_change_detection(br);
 	del_timer(&br->tcn_timer);
 
-	if (br->dev.flags & IFF_UP) {
+	if (br->dev->flags & IFF_UP) {
 		br_config_bpdu_generation(br);
 		mod_timer(&br->hello_timer, jiffies + br->hello_time);
 	}
@@ -289,10 +289,10 @@
 /* called under bridge lock */
 void br_topology_change_detection(struct net_bridge *br)
 {
-	if (!(br->dev.flags & IFF_UP))
+	if (!(br->dev->flags & IFF_UP))
 		return;
 
-	pr_info("%s: topology change detected", br->dev.name);
+	pr_info("%s: topology change detected", br->dev->name);
 	if (br_is_root_bridge(br)) {
 		printk(", propagating");
 		br->topology_change = 1;
@@ -446,7 +446,7 @@
 {
 	if (br_is_designated_port(p)) {
 		pr_info("%s: received tcn bpdu on port %i(%s)\n",
-		       p->br->dev.name, p->port_no, p->dev->name);
+		       p->br->dev->name, p->port_no, p->dev->name);
 
 		br_topology_change_detection(p->br);
 		br_topology_change_acknowledge(p);
diff -Nru a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
--- a/net/bridge/br_stp_bpdu.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_stp_bpdu.c	Mon Jun  9 11:42:38 2003
@@ -145,7 +145,7 @@
 
 	spin_lock_bh(&br->lock);
 	if (p->state == BR_STATE_DISABLED 
-	    || !(br->dev.flags & IFF_UP)
+	    || !(br->dev->flags & IFF_UP)
 	    || !br->stp_enabled 
 	    || memcmp(buf, header, 6)) 
 		goto out;
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_stp_if.c	Mon Jun  9 11:42:38 2003
@@ -93,7 +93,7 @@
 
 	br = p->br;
 	printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-	       br->dev.name, p->port_no, p->dev->name, "disabled");
+	       br->dev->name, p->port_no, p->dev->name, "disabled");
 
 	wasroot = br_is_root_bridge(br);
 	br_become_designated_port(p);
@@ -124,7 +124,7 @@
 
 	memcpy(oldaddr, br->bridge_id.addr, ETH_ALEN);
 	memcpy(br->bridge_id.addr, addr, ETH_ALEN);
-	memcpy(br->dev.dev_addr, addr, ETH_ALEN);
+	memcpy(br->dev->dev_addr, addr, ETH_ALEN);
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (!memcmp(p->designated_bridge.addr, oldaddr, ETH_ALEN))
diff -Nru a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
--- a/net/bridge/br_stp_timer.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/br_stp_timer.c	Mon Jun  9 11:42:38 2003
@@ -38,9 +38,9 @@
 {
 	struct net_bridge *br = (struct net_bridge *)arg;
 	
-	pr_debug("%s: hello timer expired\n", br->dev.name);
+	pr_debug("%s: hello timer expired\n", br->dev->name);
 	spin_lock_bh(&br->lock);
-	if (br->dev.flags & IFF_UP) {
+	if (br->dev->flags & IFF_UP) {
 		br_config_bpdu_generation(br);
 
 		br->hello_timer.expires = jiffies + br->hello_time;
@@ -61,7 +61,7 @@
 
 	
 	pr_info("%s: neighbor %.2x%.2x.%.2x:%.2x:%.2x:%.2x:%.2x:%.2x lost on port %d(%s)\n",
-		br->dev.name, 
+		br->dev->name, 
 		id->prio[0], id->prio[1], 
 		id->addr[0], id->addr[1], id->addr[2], 
 		id->addr[3], id->addr[4], id->addr[5],
@@ -89,7 +89,7 @@
 	struct net_bridge *br = p->br;
 
 	pr_debug("%s: %d(%s) forward delay timer\n",
-		 br->dev.name, p->port_no, p->dev->name);
+		 br->dev->name, p->port_no, p->dev->name);
 	spin_lock_bh(&br->lock);
 	if (p->state == BR_STATE_LISTENING) {
 		p->state = BR_STATE_LEARNING;
@@ -108,9 +108,9 @@
 {
 	struct net_bridge *br = (struct net_bridge *) arg;
 
-	pr_debug("%s: tcn timer expired\n", br->dev.name);
+	pr_debug("%s: tcn timer expired\n", br->dev->name);
 	spin_lock_bh(&br->lock);
-	if (br->dev.flags & IFF_UP) {
+	if (br->dev->flags & IFF_UP) {
 		br_transmit_tcn(br);
 	
 		br->tcn_timer.expires = jiffies + br->bridge_hello_time;
@@ -123,7 +123,7 @@
 {
 	struct net_bridge *br = (struct net_bridge *) arg;
 
-	pr_debug("%s: topo change timer expired\n", br->dev.name);
+	pr_debug("%s: topo change timer expired\n", br->dev->name);
 	spin_lock_bh(&br->lock);
 	br->topology_change_detected = 0;
 	br->topology_change = 0;
@@ -135,7 +135,7 @@
 	struct net_bridge_port *p = (struct net_bridge_port *) arg;
 
 	pr_debug("%s: %d(%s) hold timer expired\n", 
-		 p->br->dev.name,  p->port_no, p->dev->name);
+		 p->br->dev->name,  p->port_no, p->dev->name);
 
 	spin_lock_bh(&p->br->lock);
 	if (p->config_pending)
diff -Nru a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
--- a/net/bridge/netfilter/ebt_redirect.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/netfilter/ebt_redirect.c	Mon Jun  9 11:42:38 2003
@@ -22,7 +22,7 @@
 
 	if (hooknr != NF_BR_BROUTING)
 		memcpy((**pskb).mac.ethernet->h_dest,
-		   in->br_port->br->dev.dev_addr, ETH_ALEN);
+		   in->br_port->br->dev->dev_addr, ETH_ALEN);
 	else {
 		memcpy((**pskb).mac.ethernet->h_dest,
 		   in->dev_addr, ETH_ALEN);
diff -Nru a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
--- a/net/bridge/netfilter/ebtables.c	Mon Jun  9 11:42:38 2003
+++ b/net/bridge/netfilter/ebtables.c	Mon Jun  9 11:42:38 2003
@@ -135,10 +135,10 @@
 	if (FWINV2(ebt_dev_check(e->out, out), EBT_IOUT))
 		return 1;
 	if ((!in || !in->br_port) ? 0 : FWINV2(ebt_dev_check(
-	   e->logical_in, &in->br_port->br->dev), EBT_ILOGICALIN))
+	   e->logical_in, in->br_port->br->dev), EBT_ILOGICALIN))
 		return 1;
 	if ((!out || !out->br_port) ? 0 : FWINV2(ebt_dev_check(
-	   e->logical_out, &out->br_port->br->dev), EBT_ILOGICALOUT))
+	   e->logical_out, out->br_port->br->dev), EBT_ILOGICALOUT))
 		return 1;
 
 	if (e->bitmask & EBT_SOURCEMAC) {
