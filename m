From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] bridge: fix RCU races with bridge port
Date: Mon, 15 Nov 2010 08:38:13 -0800
Message-ID: <20101115163828.394138705@vyatta.com>
References: <20101115163809.215552143@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38454 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757933Ab0KOQln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 11:41:43 -0500
Content-Disposition: inline; filename=br-port-rcu-race.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro br_port_exists() is not enough protection when only
RCU is being used. There is a tiny race where other CPU has cleared port
handler hook, but is bridge port flag might still be set.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_fdb.c             |   15 +++++++++------
 net/bridge/br_if.c              |    5 +----
 net/bridge/br_netfilter.c       |   13 +++++++------
 net/bridge/br_netlink.c         |   10 ++++++----
 net/bridge/br_notify.c          |    2 +-
 net/bridge/br_private.h         |   16 +++++++++++++---
 net/bridge/br_stp_bpdu.c        |    8 ++++----
 net/bridge/netfilter/ebtables.c |   11 +++++------
 8 files changed, 46 insertions(+), 34 deletions(-)

--- a/net/bridge/br_netfilter.c	2010-11-15 08:24:41.696606136 -0800
+++ b/net/bridge/br_netfilter.c	2010-11-15 08:25:50.037644994 -0800
@@ -131,17 +131,18 @@ void br_netfilter_rtable_init(struct net
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
-	if (!br_port_exists(dev))
-		return NULL;
-	return &br_port_get_rcu(dev)->br->fake_rtable;
+	struct net_bridge_port *port;
+
+	port = br_port_get_rcu(dev);
+	return port ? &port->br->fake_rtable : NULL;
 }
 
 static inline struct net_device *bridge_parent(const struct net_device *dev)
 {
-	if (!br_port_exists(dev))
-		return NULL;
+	struct net_bridge_port *port;
 
-	return br_port_get_rcu(dev)->br->dev;
+	port = br_port_get_rcu(dev);
+	return port ? port->br->dev : NULL;
 }
 
 static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
--- a/net/bridge/br_stp_bpdu.c	2010-11-15 08:24:41.696606136 -0800
+++ b/net/bridge/br_stp_bpdu.c	2010-11-15 08:25:50.037644994 -0800
@@ -141,10 +141,6 @@ void br_stp_rcv(const struct stp_proto *
 	struct net_bridge *br;
 	const unsigned char *buf;
 
-	if (!br_port_exists(dev))
-		goto err;
-	p = br_port_get_rcu(dev);
-
 	if (!pskb_may_pull(skb, 4))
 		goto err;
 
@@ -153,6 +149,10 @@ void br_stp_rcv(const struct stp_proto *
 	if (buf[0] != 0 || buf[1] != 0 || buf[2] != 0)
 		goto err;
 
+	p = br_port_get_rcu(dev);
+	if (!p)
+		goto err;
+
 	br = p->br;
 	spin_lock(&br->lock);
 
--- a/net/bridge/netfilter/ebtables.c	2010-11-15 08:24:41.696606136 -0800
+++ b/net/bridge/netfilter/ebtables.c	2010-11-15 08:25:50.041645485 -0800
@@ -128,6 +128,7 @@ ebt_basic_match(const struct ebt_entry *
                 const struct net_device *in, const struct net_device *out)
 {
 	const struct ethhdr *h = eth_hdr(skb);
+	const struct net_bridge_port *p;
 	__be16 ethproto;
 	int verdict, i;
 
@@ -148,13 +149,11 @@ ebt_basic_match(const struct ebt_entry *
 	if (FWINV2(ebt_dev_check(e->out, out), EBT_IOUT))
 		return 1;
 	/* rcu_read_lock()ed by nf_hook_slow */
-	if (in && br_port_exists(in) &&
-	    FWINV2(ebt_dev_check(e->logical_in, br_port_get_rcu(in)->br->dev),
-		   EBT_ILOGICALIN))
+	if (in && (p = br_port_get_rcu(in)) != NULL &&
+	    FWINV2(ebt_dev_check(e->logical_in, p->br->dev), EBT_ILOGICALIN))
 		return 1;
-	if (out && br_port_exists(out) &&
-	    FWINV2(ebt_dev_check(e->logical_out, br_port_get_rcu(out)->br->dev),
-		   EBT_ILOGICALOUT))
+	if (out && (p = br_port_get_rcu(out)) != NULL &&
+	    FWINV2(ebt_dev_check(e->logical_out, p->br->dev), EBT_ILOGICALOUT))
 		return 1;
 
 	if (e->bitmask & EBT_SOURCEMAC) {
--- a/net/bridge/br_fdb.c	2010-11-15 08:20:20.020385965 -0800
+++ b/net/bridge/br_fdb.c	2010-11-15 08:25:50.041645485 -0800
@@ -238,15 +238,18 @@ struct net_bridge_fdb_entry *__br_fdb_ge
 int br_fdb_test_addr(struct net_device *dev, unsigned char *addr)
 {
 	struct net_bridge_fdb_entry *fdb;
+	struct net_bridge_port *port;
 	int ret;
 
-	if (!br_port_exists(dev))
-		return 0;
-
 	rcu_read_lock();
-	fdb = __br_fdb_get(br_port_get_rcu(dev)->br, addr);
-	ret = fdb && fdb->dst->dev != dev &&
-		fdb->dst->state == BR_STATE_FORWARDING;
+	port = br_port_get_rcu(dev);
+	if (!port)
+		ret = 0;
+	else {
+		fdb = __br_fdb_get(port->br, addr);
+		ret = fdb && fdb->dst->dev != dev &&
+			fdb->dst->state == BR_STATE_FORWARDING;
+	}
 	rcu_read_unlock();
 
 	return ret;
--- a/net/bridge/br_notify.c	2010-11-15 08:24:41.696606136 -0800
+++ b/net/bridge/br_notify.c	2010-11-15 08:25:50.045645976 -0800
@@ -32,7 +32,7 @@ struct notifier_block br_device_notifier
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct net_bridge_port *p = br_port_get(dev);
+	struct net_bridge_port *p;
 	struct net_bridge *br;
 	int err;
 
--- a/net/bridge/br_private.h	2010-11-15 08:24:47.829474102 -0800
+++ b/net/bridge/br_private.h	2010-11-15 08:27:46.747612478 -0800
@@ -151,11 +151,19 @@ struct net_bridge_port
 #endif
 };
 
-#define br_port_get_rcu(dev) \
-	((struct net_bridge_port *) rcu_dereference(dev->rx_handler_data))
-#define br_port_get(dev) ((struct net_bridge_port *) dev->rx_handler_data)
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
 
+static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
+{
+	struct net_bridge_port *port = rcu_dereference(dev->rx_handler_data);
+	return br_port_exists(dev) ? port : NULL;
+}
+
+static inline struct net_bridge_port *br_port_get(struct net_device *dev)
+{
+	return br_port_exists(dev) ? dev->rx_handler_data : NULL;
+}
+
 struct br_cpu_netstats {
 	u64			rx_packets;
 	u64			rx_bytes;
--- a/net/bridge/br_if.c	2010-11-15 08:20:20.084389475 -0800
+++ b/net/bridge/br_if.c	2010-11-15 08:25:50.049646467 -0800
@@ -475,11 +475,8 @@ int br_del_if(struct net_bridge *br, str
 {
 	struct net_bridge_port *p;
 
-	if (!br_port_exists(dev))
-		return -EINVAL;
-
 	p = br_port_get(dev);
-	if (p->br != br)
+	if (!p || p->br != br)
 		return -EINVAL;
 
 	del_nbp(p);
--- a/net/bridge/br_netlink.c	2010-11-15 08:24:41.696606136 -0800
+++ b/net/bridge/br_netlink.c	2010-11-15 08:25:50.049646467 -0800
@@ -119,11 +119,13 @@ static int br_dump_ifinfo(struct sk_buff
 
 	idx = 0;
 	for_each_netdev(net, dev) {
+		struct net_bridge_port *port = br_port_get(dev);
+
 		/* not a bridge port */
-		if (!br_port_exists(dev) || idx < cb->args[0])
+		if (!port || idx < cb->args[0])
 			goto skip;
 
-		if (br_fill_ifinfo(skb, br_port_get(dev),
+		if (br_fill_ifinfo(skb, port,
 				   NETLINK_CB(cb->skb).pid,
 				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
 				   NLM_F_MULTI) < 0)
@@ -169,9 +171,9 @@ static int br_rtm_setlink(struct sk_buff
 	if (!dev)
 		return -ENODEV;
 
-	if (!br_port_exists(dev))
-		return -EINVAL;
 	p = br_port_get(dev);
+	if (!p)
+		return -EINVAL;
 
 	/* if kernel STP is running, don't allow changes */
 	if (p->br->stp_enabled == BR_KERNEL_STP)


