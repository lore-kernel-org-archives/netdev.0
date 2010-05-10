From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] bridge: change console message interface
Date: Mon, 10 May 2010 12:31:09 -0700
Message-ID: <20100510193320.859557093@vyatta.com>
References: <20100510193107.722574297@vyatta.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43065 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053Ab0EJTfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 15:35:23 -0400
Content-Disposition: inline; filename=bridge-msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use one set of macro's for all bridge messages.

Note: can't use netdev_XXX macro's because bridge is purely
virtual and has no device parent.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br.c           |    2 +-
 net/bridge/br_fdb.c       |    9 ++++-----
 net/bridge/br_ioctl.c     |    2 +-
 net/bridge/br_multicast.c |   32 +++++++++++++-------------------
 net/bridge/br_netlink.c   |    8 +++++---
 net/bridge/br_private.h   |   15 +++++++++++++++
 net/bridge/br_stp.c       |   11 +++++------
 net/bridge/br_stp_if.c    |   16 ++++++----------
 net/bridge/br_stp_timer.c |   24 ++++++++++--------------
 9 files changed, 60 insertions(+), 59 deletions(-)

--- a/net/bridge/br.c	2010-05-10 11:50:28.856612469 -0700
+++ b/net/bridge/br.c	2010-05-10 11:50:34.547229645 -0700
@@ -38,7 +38,7 @@ static int __init br_init(void)
 
 	err = stp_proto_register(&br_stp_proto);
 	if (err < 0) {
-		printk(KERN_ERR "bridge: can't register sap for STP\n");
+		pr_err("bridge: can't register sap for STP\n");
 		return err;
 	}
 
--- a/net/bridge/br_fdb.c	2010-05-10 11:50:28.886629735 -0700
+++ b/net/bridge/br_fdb.c	2010-05-10 12:00:32.239308637 -0700
@@ -353,8 +353,7 @@ static int fdb_insert(struct net_bridge 
 		 */
 		if (fdb->is_local)
 			return 0;
-
-		printk(KERN_WARNING "%s adding interface with same address "
+		br_warn(br, "adding interface %s with same address "
 		       "as a received packet\n",
 		       source->dev->name);
 		fdb_delete(fdb);
@@ -397,9 +396,9 @@ void br_fdb_update(struct net_bridge *br
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {
 			if (net_ratelimit())
-				printk(KERN_WARNING "%s: received packet with "
-				       "own address as source address\n",
-				       source->dev->name);
+				br_warn(br, "received packet on %s with "
+					"own address as source address\n",
+					source->dev->name);
 		} else {
 			/* fastpath: update of existing entry */
 			fdb->dst = source;
--- a/net/bridge/br_multicast.c	2010-05-10 11:50:28.936627985 -0700
+++ b/net/bridge/br_multicast.c	2010-05-10 12:04:33.316906966 -0700
@@ -585,10 +585,9 @@ static struct net_bridge_mdb_entry *br_m
 
 	if (unlikely(count > br->hash_elasticity && count)) {
 		if (net_ratelimit())
-			printk(KERN_INFO "%s: Multicast hash table "
-			       "chain limit reached: %s\n",
-			       br->dev->name, port ? port->dev->name :
-						     br->dev->name);
+			br_info(br, "Multicast hash table "
+				"chain limit reached: %s\n",
+				port ? port->dev->name : br->dev->name);
 
 		elasticity = br->hash_elasticity;
 	}
@@ -596,11 +595,9 @@ static struct net_bridge_mdb_entry *br_m
 	if (mdb->size >= max) {
 		max *= 2;
 		if (unlikely(max >= br->hash_max)) {
-			printk(KERN_WARNING "%s: Multicast hash table maximum "
-			       "reached, disabling snooping: %s, %d\n",
-			       br->dev->name, port ? port->dev->name :
-						     br->dev->name,
-			       max);
+			br_warn(br, "Multicast hash table maximum "
+				"reached, disabling snooping: %s, %d\n",
+				port ? port->dev->name : br->dev->name, max);
 			err = -E2BIG;
 disable:
 			br->multicast_disabled = 1;
@@ -611,22 +608,19 @@ disable:
 	if (max > mdb->max || elasticity) {
 		if (mdb->old) {
 			if (net_ratelimit())
-				printk(KERN_INFO "%s: Multicast hash table "
-				       "on fire: %s\n",
-				       br->dev->name, port ? port->dev->name :
-							     br->dev->name);
+				br_info(br, "Multicast hash table "
+					"on fire: %s\n",
+					port ? port->dev->name : br->dev->name);
 			err = -EEXIST;
 			goto err;
 		}
 
 		err = br_mdb_rehash(&br->mdb, max, elasticity);
 		if (err) {
-			printk(KERN_WARNING "%s: Cannot rehash multicast "
-			       "hash table, disabling snooping: "
-			       "%s, %d, %d\n",
-			       br->dev->name, port ? port->dev->name :
-						     br->dev->name,
-			       mdb->size, err);
+			br_warn(br, "Cannot rehash multicast "
+				"hash table, disabling snooping: %s, %d, %d\n",
+				port ? port->dev->name : br->dev->name,
+				mdb->size, err);
 			goto disable;
 		}
 
--- a/net/bridge/br_stp_if.c	2010-05-10 11:50:28.916629479 -0700
+++ b/net/bridge/br_stp_if.c	2010-05-10 12:04:37.100899166 -0700
@@ -85,17 +85,16 @@ void br_stp_enable_port(struct net_bridg
 {
 	br_init_port(p);
 	br_port_state_selection(p->br);
+	br_log_state(p);
 }
 
 /* called under bridge lock */
 void br_stp_disable_port(struct net_bridge_port *p)
 {
-	struct net_bridge *br;
+	struct net_bridge *br = p->br;
 	int wasroot;
 
-	br = p->br;
-	printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
-	       br->dev->name, p->port_no, p->dev->name, "disabled");
+	br_log_state(p);
 
 	wasroot = br_is_root_bridge(br);
 	br_become_designated_port(p);
@@ -127,11 +126,10 @@ static void br_stp_start(struct net_brid
 	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
 	if (r == 0) {
 		br->stp_enabled = BR_USER_STP;
-		printk(KERN_INFO "%s: userspace STP started\n", br->dev->name);
+		br_debug(br, "userspace STP started\n");
 	} else {
 		br->stp_enabled = BR_KERNEL_STP;
-		printk(KERN_INFO "%s: starting userspace STP failed, "
-				"starting kernel STP\n", br->dev->name);
+		br_debug(br, "using kernel STP\n");
 
 		/* To start timers on any ports left in blocking */
 		spin_lock_bh(&br->lock);
@@ -148,9 +146,7 @@ static void br_stp_stop(struct net_bridg
 
 	if (br->stp_enabled == BR_USER_STP) {
 		r = call_usermodehelper(BR_STP_PROG, argv, envp, 1);
-		printk(KERN_INFO "%s: userspace STP stopped, return code %d\n",
-			br->dev->name, r);
-
+		br_info(br, "userspace STP stopped, return code %d\n", r);
 
 		/* To start timers on any ports left in blocking */
 		spin_lock_bh(&br->lock);
--- a/net/bridge/br_ioctl.c	2010-05-10 11:50:28.906610162 -0700
+++ b/net/bridge/br_ioctl.c	2010-05-10 12:00:40.326906216 -0700
@@ -412,6 +412,6 @@ int br_dev_ioctl(struct net_device *dev,
 
 	}
 
-	pr_debug("Bridge does not support ioctl 0x%x\n", cmd);
+	br_debug(br, "Bridge does not support ioctl 0x%x\n", cmd);
 	return -EOPNOTSUPP;
 }
--- a/net/bridge/br_netlink.c	2010-05-10 11:50:28.876606911 -0700
+++ b/net/bridge/br_netlink.c	2010-05-10 12:11:33.095469978 -0700
@@ -42,8 +42,8 @@ static int br_fill_ifinfo(struct sk_buff
 	struct nlmsghdr *nlh;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 
-	pr_debug("br_fill_info event %d port %s master %s\n",
-		 event, dev->name, br->dev->name);
+	br_debug(br, "br_fill_info event %d port %s master %s\n",
+		     event, dev->name, br->dev->name);
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
 	if (nlh == NULL)
@@ -87,7 +87,9 @@ void br_ifinfo_notify(int event, struct 
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	pr_debug("bridge notify event=%d\n", event);
+	br_debug(port->br, "port %u(%s) event %d\n",
+		 (unsigned)port->port_no, port->dev->name, event);
+
 	skb = nlmsg_new(br_nlmsg_size(), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
--- a/net/bridge/br_stp_timer.c	2010-05-10 11:50:28.916629479 -0700
+++ b/net/bridge/br_stp_timer.c	2010-05-10 12:09:57.504418884 -0700
@@ -35,7 +35,7 @@ static void br_hello_timer_expired(unsig
 {
 	struct net_bridge *br = (struct net_bridge *)arg;
 
-	pr_debug("%s: hello timer expired\n", br->dev->name);
+	br_debug(br, "hello timer expired\n");
 	spin_lock(&br->lock);
 	if (br->dev->flags & IFF_UP) {
 		br_config_bpdu_generation(br);
@@ -55,13 +55,9 @@ static void br_message_age_timer_expired
 	if (p->state == BR_STATE_DISABLED)
 		return;
 
-
-	pr_info("%s: neighbor %.2x%.2x.%.2x:%.2x:%.2x:%.2x:%.2x:%.2x lost on port %d(%s)\n",
-		br->dev->name,
-		id->prio[0], id->prio[1],
-		id->addr[0], id->addr[1], id->addr[2],
-		id->addr[3], id->addr[4], id->addr[5],
-		p->port_no, p->dev->name);
+	br_info(br, "port %u(%s) neighbor %.2x%.2x.%pM lost\n",
+		(unsigned) p->port_no, p->dev->name,
+		id->prio[0], id->prio[1], &id->addr);
 
 	/*
 	 * According to the spec, the message age timer cannot be
@@ -87,8 +83,8 @@ static void br_forward_delay_timer_expir
 	struct net_bridge_port *p = (struct net_bridge_port *) arg;
 	struct net_bridge *br = p->br;
 
-	pr_debug("%s: %d(%s) forward delay timer\n",
-		 br->dev->name, p->port_no, p->dev->name);
+	br_debug(br, "port %u(%s) forward delay timer\n",
+		 (unsigned) p->port_no, p->dev->name);
 	spin_lock(&br->lock);
 	if (p->state == BR_STATE_LISTENING) {
 		p->state = BR_STATE_LEARNING;
@@ -107,7 +103,7 @@ static void br_tcn_timer_expired(unsigne
 {
 	struct net_bridge *br = (struct net_bridge *) arg;
 
-	pr_debug("%s: tcn timer expired\n", br->dev->name);
+	br_debug(br, "tcn timer expired\n");
 	spin_lock(&br->lock);
 	if (br->dev->flags & IFF_UP) {
 		br_transmit_tcn(br);
@@ -121,7 +117,7 @@ static void br_topology_change_timer_exp
 {
 	struct net_bridge *br = (struct net_bridge *) arg;
 
-	pr_debug("%s: topo change timer expired\n", br->dev->name);
+	br_debug(br, "topo change timer expired\n");
 	spin_lock(&br->lock);
 	br->topology_change_detected = 0;
 	br->topology_change = 0;
@@ -132,8 +128,8 @@ static void br_hold_timer_expired(unsign
 {
 	struct net_bridge_port *p = (struct net_bridge_port *) arg;
 
-	pr_debug("%s: %d(%s) hold timer expired\n",
-		 p->br->dev->name,  p->port_no, p->dev->name);
+	br_debug(p->br, "port %u(%s) hold timer expired\n",
+		 (unsigned) p->port_no, p->dev->name);
 
 	spin_lock(&p->br->lock);
 	if (p->config_pending)
--- a/net/bridge/br_stp.c	2010-05-10 11:50:28.896578146 -0700
+++ b/net/bridge/br_stp.c	2010-05-10 12:01:40.080530431 -0700
@@ -31,10 +31,9 @@ static const char *const br_port_state_n
 
 void br_log_state(const struct net_bridge_port *p)
 {
-	pr_info("%s: port %d(%s) entering %s state\n",
-		p->br->dev->name, p->port_no, p->dev->name,
+	br_info(p->br, "port %u(%s) entering %s state\n",
+		(unsigned) p->port_no, p->dev->name,
 		br_port_state_names[p->state]);
-
 }
 
 /* called under bridge lock */
@@ -300,7 +299,7 @@ void br_topology_change_detection(struct
 	if (br->stp_enabled != BR_KERNEL_STP)
 		return;
 
-	pr_info("%s: topology change detected, %s\n", br->dev->name,
+	br_info(br, "topology change detected, %s\n",
 		isroot ? "propagating" : "sending tcn bpdu");
 
 	if (isroot) {
@@ -469,8 +468,8 @@ void br_received_config_bpdu(struct net_
 void br_received_tcn_bpdu(struct net_bridge_port *p)
 {
 	if (br_is_designated_port(p)) {
-		pr_info("%s: received tcn bpdu on port %i(%s)\n",
-		       p->br->dev->name, p->port_no, p->dev->name);
+		br_info(p->br, "port %u(%s) received tcn bpdu\n",
+			(unsigned) p->port_no, p->dev->name);
 
 		br_topology_change_detection(p->br);
 		br_topology_change_acknowledge(p);
--- a/net/bridge/br_private.h	2010-05-10 11:50:37.646944750 -0700
+++ b/net/bridge/br_private.h	2010-05-10 12:28:44.137056465 -0700
@@ -240,6 +240,21 @@ struct br_input_skb_cb {
 # define BR_INPUT_SKB_CB_MROUTERS_ONLY(__skb)	(0)
 #endif
 
+#define br_printk(level, br, format, args...)	\
+	printk(level "%s: " format, (br)->dev->name, ##args)
+
+#define br_err(__br, format, args...)			\
+	br_printk(KERN_ERR, __br, format, ##args)
+#define br_warn(__br, format, args...)			\
+	br_printk(KERN_WARNING, __br, format, ##args)
+#define br_notice(__br, format, args...)		\
+	br_printk(KERN_NOTICE, __br, format, ##args)
+#define br_info(__br, format, args...)			\
+	br_printk(KERN_INFO, __br, format, ##args)
+
+#define br_debug(br, format, args...)			\
+	pr_debug("%s: " format,  (br)->dev->name, ##args)
+
 extern struct notifier_block br_device_notifier;
 extern const u8 br_group_address[ETH_ALEN];
 
--- a/net/bridge/br_device.c	2010-05-10 12:29:30.308306178 -0700
+++ b/net/bridge/br_device.c	2010-05-10 12:30:13.027074884 -0700
@@ -255,9 +255,8 @@ void br_netpoll_enable(struct net_bridge
 			dev->npinfo = br->dev->npinfo;
 	} else if (!(br->dev->priv_flags & IFF_DISABLE_NETPOLL)) {
 		br->dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		printk(KERN_INFO "%s:new device %s"
-			" does not support netpoll (disabling)",
-			br->dev->name, dev->name);
+		br_info(br,"new device %s does not support netpoll (disabling)",
+			dev->name);
 	}
 }
 


