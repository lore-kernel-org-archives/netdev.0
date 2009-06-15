From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Mon, 15 Jun 2009 17:33:10 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>
To: "bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:34661 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756191AbZFORdd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 13:33:33 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic Virtual Ethernet Port Aggregator (VEPA)
capabilities to the Linux kernel Ethernet bridging code.

A Virtual Ethernet Port Aggregator (VEPA) is a capability within
a physical end station that collaborates with an adjacent, external
bridge to provide distributed bridging support between multiple
virtual end stations and external networks. The VEPA collaborates
by forwarding all station-originated frames to the adjacent bridge
for frame processing and frame relay (including so-called 'hairpin'
forwarding) and by steering and replicating frames received from
the VEPA uplink to the appropriate destinations. A VEPA may be
implemented in software or in conjunction with embedded hardware.

In particular, the patch extends the Linux Ethernet bridge to act as
(1) a VEPA - for this we have added VEPA forwarding functionality and
    added a configuration option for a VEPA uplink port, or as
(2) a bridge supporting 'hairpin' forwarding - for this we have added a
    bridge port 'hairpin' mode which allows sending frames back out
    through the port the frame was received on.

Configuration of VEPA capabilities through Linux userspace bridge
utilities is provided by an additional patch 'bridge-utils: add
basic VEPA support'.

You can find additional information on VEPA here:
http://tech.groups.yahoo.com/group/evb/
http://www.ieee802.org/1/files/public/docs2009/new-hudson-vepa_seminar-20090514d.pdf

Signed-off-by: Paul Congdon <paul.congdon@hp.com>
Signed-off-by: Anna Fischer <anna.fischer@hp.com>

---

 net/bridge/br_fdb.c      |   22 ++++++++++++++
 net/bridge/br_forward.c  |   24 ++++++++++++++-
 net/bridge/br_if.c       |    3 ++
 net/bridge/br_input.c    |    9 ++++++
 net/bridge/br_private.h  |   12 ++++++++
 net/bridge/br_sysfs_br.c |   69 ++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_sysfs_if.c |   17 +++++++++++
 7 files changed, 154 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index a48f5ef..7d0f6ed 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -394,6 +394,15 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 
 	fdb = fdb_find(head, addr);
 	if (likely(fdb)) {
+		/*
+		 * If we are a VEPA and the source port is the uplink,
+		 * this could be a reflected packet, so don't learn any
+		 * addresses that already are in the fdb but on other ports
+		 */
+		if ((br->flags & BR_VEPA_MODE) && br->uplink == source &&
+		    fdb->dst != br->uplink)
+			return;
+
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
 			if (net_ratelimit())
@@ -415,3 +424,16 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		spin_unlock(&br->hash_lock);
 	}
 }
+
+struct net_bridge_port *br_vepa_find_src(struct net_bridge *br,
+		   const unsigned char *addr)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct net_bridge_fdb_entry *fdb;
+
+	fdb = fdb_find(head, addr);
+	if (fdb)
+		return fdb->dst;
+	else
+		return NULL;
+}
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d2c27c8..ff1135e 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -22,7 +22,8 @@
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
-	return (skb->dev != p->dev && p->state == BR_STATE_FORWARDING);
+	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		p->state == BR_STATE_FORWARDING);
 }
 
 static inline unsigned packet_length(const struct sk_buff *skb)
@@ -92,6 +93,17 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 }
 
 /* called with rcu_read_lock */
+void br_vepa_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
+{
+	if (!skb_warn_if_lro(skb) && (to != NULL)) {
+		__br_forward(to, skb);
+		return;
+	}
+
+	kfree_skb(skb);
+}
+
+/* called with rcu_read_lock */
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	if (should_deliver(to, skb)) {
@@ -109,11 +121,19 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
+	struct net_bridge_port *sp = NULL;
+
+	/*
+	 * If we are a VEPA, then we do not want to send the frame
+	 * to the port it came from originally.
+	 */
+	if (br->flags & BR_VEPA_MODE)
+		sp = br_vepa_find_src(br, eth_hdr(skb)->h_source);
 
 	prev = NULL;
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
-		if (should_deliver(p, skb)) {
+		if (should_deliver(p, skb) && p != sp) {
 			if (prev != NULL) {
 				struct sk_buff *skb2;
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8a96672..22239ef 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -146,6 +146,8 @@ static void del_nbp(struct net_bridge_port *p)
 	list_del_rcu(&p->list);
 
 	rcu_assign_pointer(dev->br_port, NULL);
+	if (br->uplink == p)
+		br->uplink = NULL;
 
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
 	kobject_del(&p->kobj);
@@ -203,6 +205,7 @@ static struct net_device *new_bridge_dev(struct net *net, const char *name)
 	br->topology_change = 0;
 	br->topology_change_detected = 0;
 	br->ageing_time = 300 * HZ;
+	br->uplink = NULL;
 
 	br_netfilter_rtable_init(br);
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 5ee1a36..8027156 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -50,6 +50,15 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
 
+	/*
+	 * If we are a VEPA, and the receiving port is not the uplink we
+	 * simply want to send this frame to the uplink (after learning)
+	 */
+	if ((br->flags & BR_VEPA_MODE) && p != br->uplink) {
+		br_vepa_deliver(br->uplink, skb);
+		goto out;
+	}
+
 	if (p->state == BR_STATE_LEARNING)
 		goto drop;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b6c3b71..0c7ee4c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -82,6 +82,9 @@ struct net_bridge_port
 	struct timer_list		message_age_timer;
 	struct kobject			kobj;
 	struct rcu_head			rcu;
+
+	unsigned long 			flags;
+#define BR_HAIRPIN_MODE		0x00000001
 };
 
 struct net_bridge
@@ -98,6 +101,7 @@ struct net_bridge
 #endif
 	unsigned long			flags;
 #define BR_SET_MAC_ADDR		0x00000001
+#define BR_VEPA_MODE		0x00000010
 
 	/* STP */
 	bridge_id			designated_root;
@@ -128,6 +132,9 @@ struct net_bridge
 	struct timer_list		topology_change_timer;
 	struct timer_list		gc_timer;
 	struct kobject			*ifobj;
+
+	/* VEPA */
+	struct net_bridge_port		*uplink;
 };
 
 extern struct notifier_block br_device_notifier;
@@ -165,6 +172,9 @@ extern int br_fdb_insert(struct net_bridge *br,
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
+extern struct net_bridge_port *br_vepa_find_src(struct net_bridge *br,
+						const unsigned char *addr);
+
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,
@@ -175,6 +185,8 @@ extern void br_forward(const struct net_bridge_port *to,
 extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
 extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb);
+extern void br_vepa_deliver(const struct net_bridge_port *to,
+		struct sk_buff *skb);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 603d892..557d7c3 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -344,6 +344,73 @@ static ssize_t store_flush(struct device *d,
 }
 static DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
 
+static ssize_t show_vepa_mode(struct device *d,
+			      struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	int vepa_mode = (br->flags & BR_VEPA_MODE) ? 1 : 0;
+	return sprintf(buf, "%d\n", vepa_mode);
+}
+
+static ssize_t store_vepa_mode(struct device *d,
+			       struct device_attribute *attr, const char *buf,
+			       size_t len)
+{
+	struct net_bridge *br = to_bridge(d);
+	int vepa_mode = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (sscanf(buf, "%d", &vepa_mode) != 1)
+		return -EINVAL;
+
+	rtnl_lock();
+	if (vepa_mode)
+		br->flags |= BR_VEPA_MODE;
+	else
+		br->flags &= ~BR_VEPA_MODE;
+	rtnl_unlock();
+
+	return len;
+}
+static DEVICE_ATTR(vepa_mode, S_IRUGO | S_IWUSR, show_vepa_mode,
+		   store_vepa_mode);
+
+static ssize_t show_uplink_port(struct device *d, struct device_attribute *attr,
+				char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	if (br->uplink && br->uplink->dev)
+		return sprintf(buf, "%s\n", br->uplink->dev->name);
+	else
+		return sprintf(buf, "\n");
+}
+
+static ssize_t store_uplink_port(struct device *d,
+				 struct device_attribute *attr, const char *buf,
+				 size_t len)
+{
+	struct net_bridge *br = to_bridge(d);
+	struct net_device *dev;
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	dev = dev_get_by_name(&init_net, buf);
+	if (!dev || !dev->br_port || (dev->br_port->br != br)) {
+		br->uplink = NULL;
+		return -EINVAL;
+	}
+
+	rtnl_lock();
+	br->uplink = dev->br_port;
+	rtnl_unlock();
+
+	return len;
+}
+static DEVICE_ATTR(uplink_port, S_IRUGO | S_IWUSR, show_uplink_port,
+		   store_uplink_port);
+
 static struct attribute *bridge_attrs[] = {
 	&dev_attr_forward_delay.attr,
 	&dev_attr_hello_time.attr,
@@ -363,6 +430,8 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_vepa_mode.attr,
+	&dev_attr_uplink_port.attr,
 	NULL
 };
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 02b2d50..0e79531 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -143,6 +143,22 @@ static ssize_t store_flush(struct net_bridge_port *p, unsigned long v)
 }
 static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 
+static ssize_t show_hairpin_mode(struct net_bridge_port *p, char *buf)
+{
+	int hairpin_mode = (p->flags & BR_HAIRPIN_MODE) ? 1 : 0;
+	return sprintf(buf, "%d\n", hairpin_mode);
+}
+static ssize_t store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
+{
+	if (v)
+		p->flags |= BR_HAIRPIN_MODE;
+	else
+		p->flags &= ~BR_HAIRPIN_MODE;
+	return 0;
+}
+static BRPORT_ATTR(hairpin_mode, S_IRUGO | S_IWUSR,
+		   show_hairpin_mode, store_hairpin_mode);
+
 static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
@@ -159,6 +175,7 @@ static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_forward_delay_timer,
 	&brport_attr_hold_timer,
 	&brport_attr_flush,
+	&brport_attr_hairpin_mode,
 	NULL
 };
