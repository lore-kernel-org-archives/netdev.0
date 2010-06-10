From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 3/3] bridge: use rx_handler_data pointer to
 store net_bridge_port pointer
Date: Thu, 10 Jun 2010 15:36:29 +0200
Message-ID: <20100610133628.GF2618@psychotron.lab.eng.brq.redhat.com>
References: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421Ab0FJNgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 09:36:35 -0400
Content-Disposition: inline
In-Reply-To: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register net_bridge_port pointer as rx_handler data pointer. As br_port is
removed from struct net_device, another netdev priv_flag is added to indicate
the device serves as a bridge port. Also rcuized pointers are now correctly
dereferenced in br_fdb.c and in netfilter parts.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ksz884x.c                       |    2 +-
 drivers/staging/batman-adv/hard-interface.c |    2 +-
 include/linux/if.h                          |    1 +
 include/linux/netdevice.h                   |    2 --
 net/bridge/br_fdb.c                         |    4 ++--
 net/bridge/br_if.c                          |   23 +++++++++++++----------
 net/bridge/br_input.c                       |    9 ++++-----
 net/bridge/br_netfilter.c                   |   11 ++++++-----
 net/bridge/br_netlink.c                     |    9 +++++----
 net/bridge/br_notify.c                      |    5 +++--
 net/bridge/br_private.h                     |    4 ++++
 net/bridge/br_stp_bpdu.c                    |    5 +++--
 net/bridge/netfilter/ebt_redirect.c         |    3 ++-
 net/bridge/netfilter/ebt_ulog.c             |    8 +++++---
 net/bridge/netfilter/ebtables.c             |   11 +++++++----
 net/core/dev.c                              |    3 ++-
 net/netfilter/nfnetlink_log.c               |    6 ++++--
 net/netfilter/nfnetlink_queue.c             |    6 ++++--
 net/wireless/nl80211.c                      |    2 +-
 net/wireless/util.c                         |    4 ++--
 20 files changed, 70 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 7805bbf..b0c876d 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -5718,7 +5718,7 @@ static void dev_set_promiscuous(struct net_device *dev, struct dev_priv *priv,
 		 * from the bridge.
 		 */
 		if ((hw->features & STP_SUPPORT) && !promiscuous &&
-				dev->br_port) {
+	            dev->priv_flags & IFF_BRIDGE_PORT) {
 			struct ksz_switch *sw = hw->ksz_switch;
 			int port = priv->port.first_port;
 
diff --git a/drivers/staging/batman-adv/hard-interface.c b/drivers/staging/batman-adv/hard-interface.c
index 7a582e8..5ede9c2 100644
--- a/drivers/staging/batman-adv/hard-interface.c
+++ b/drivers/staging/batman-adv/hard-interface.c
@@ -71,7 +71,7 @@ static int is_valid_iface(struct net_device *net_dev)
 #endif
 
 	/* Device is being bridged */
-	/* if (net_dev->br_port != NULL)
+	/* if (net_dev->priv_flags & IFF_BRIDGE_PORT)
 		return 0; */
 
 	return 1;
diff --git a/include/linux/if.h b/include/linux/if.h
index 31f2e27..53558ec 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -74,6 +74,7 @@
 #define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
 #define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
 #define IFF_MACVLAN_PORT	0x4000	/* device used as macvlan port */
+#define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 37faf51..f4e1f75 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1028,8 +1028,6 @@ struct net_device {
 	/* mid-layer private */
 	void			*ml_priv;
 
-	/* bridge stuff */
-	struct net_bridge_port	*br_port;
 	/* GARP */
 	struct garp_port	*garp_port;
 
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 2663743..6818e60 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -242,11 +242,11 @@ int br_fdb_test_addr(struct net_device *dev, unsigned char *addr)
 	struct net_bridge_fdb_entry *fdb;
 	int ret;
 
-	if (!dev->br_port)
+	if (!br_port_exists(dev))
 		return 0;
 
 	rcu_read_lock();
-	fdb = __br_fdb_get(dev->br_port->br, addr);
+	fdb = __br_fdb_get(br_port_get_rcu(dev)->br, addr);
 	ret = fdb && fdb->dst->dev != dev &&
 		fdb->dst->state == BR_STATE_FORWARDING;
 	rcu_read_unlock();
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 90ac003..099495e 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -147,8 +147,9 @@ static void del_nbp(struct net_bridge_port *p)
 
 	list_del_rcu(&p->list);
 
+	dev->priv_flags &= ~IFF_BRIDGE_PORT;
+
 	netdev_rx_handler_unregister(dev);
-	rcu_assign_pointer(dev->br_port, NULL);
 
 	br_multicast_del_port(p);
 
@@ -401,7 +402,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		return -ELOOP;
 
 	/* Device is already being bridged */
-	if (dev->br_port != NULL)
+	if (br_port_exists(dev))
 		return -EBUSY;
 
 	/* No bridging devices that dislike that (e.g. wireless) */
@@ -429,11 +430,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err2;
 
-	rcu_assign_pointer(dev->br_port, p);
-
-	err = netdev_rx_handler_register(dev, br_handle_frame, NULL);
+	err = netdev_rx_handler_register(dev, br_handle_frame, p);
 	if (err)
-		goto err3;
+		goto err2;
+
+	dev->priv_flags |= IFF_BRIDGE_PORT;
 
 	dev_disable_lro(dev);
 
@@ -457,8 +458,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	br_netpoll_enable(br, dev);
 
 	return 0;
-err3:
-	rcu_assign_pointer(dev->br_port, NULL);
 err2:
 	br_fdb_delete_by_port(br, p, 1);
 err1:
@@ -475,9 +474,13 @@ put_back:
 /* called with RTNL */
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
-	struct net_bridge_port *p = dev->br_port;
+	struct net_bridge_port *p;
+
+	if (!br_port_exists(dev))
+		return -EINVAL;
 
-	if (!p || p->br != br)
+	p = br_port_get(dev);
+	if (p->br != br)
 		return -EINVAL;
 
 	del_nbp(p);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 99647d8..f076c9d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -41,7 +41,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 int br_handle_frame_finish(struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
-	struct net_bridge_port *p = rcu_dereference(skb->dev->br_port);
+	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	struct net_bridge *br;
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
@@ -111,10 +111,9 @@ drop:
 /* note: already called with rcu_read_lock (preempt_disabled) */
 static int br_handle_local_finish(struct sk_buff *skb)
 {
-	struct net_bridge_port *p = rcu_dereference(skb->dev->br_port);
+	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 
-	if (p)
-		br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
 	return 0;	 /* process further */
 }
 
@@ -151,7 +150,7 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
 	if (!skb)
 		return NULL;
 
-	p = rcu_dereference(skb->dev->br_port);
+	p = br_port_get_rcu(skb->dev);
 
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4442099..7d7af6e 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -127,16 +127,17 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
-	struct net_bridge_port *port = rcu_dereference(dev->br_port);
-
-	return port ? &port->br->fake_rtable : NULL;
+	if (!br_port_exists(dev))
+		return NULL;
+	return &br_port_get_rcu(dev)->br->fake_rtable;
 }
 
 static inline struct net_device *bridge_parent(const struct net_device *dev)
 {
-	struct net_bridge_port *port = rcu_dereference(dev->br_port);
+	if (!br_port_exists(dev))
+		return NULL;
 
-	return port ? port->br->dev : NULL;
+	return br_port_get_rcu(dev)->br->dev;
 }
 
 static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index fe0a790..4a6a378 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -120,10 +120,11 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	idx = 0;
 	for_each_netdev(net, dev) {
 		/* not a bridge port */
-		if (dev->br_port == NULL || idx < cb->args[0])
+		if (!br_port_exists(dev) || idx < cb->args[0])
 			goto skip;
 
-		if (br_fill_ifinfo(skb, dev->br_port, NETLINK_CB(cb->skb).pid,
+		if (br_fill_ifinfo(skb, br_port_get(dev),
+				   NETLINK_CB(cb->skb).pid,
 				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
 				   NLM_F_MULTI) < 0)
 			break;
@@ -168,9 +169,9 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	if (!dev)
 		return -ENODEV;
 
-	p = dev->br_port;
-	if (!p)
+	if (!br_port_exists(dev))
 		return -EINVAL;
+	p = br_port_get(dev);
 
 	/* if kernel STP is running, don't allow changes */
 	if (p->br->stp_enabled == BR_KERNEL_STP)
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 717e1fd..404d4e1 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -32,14 +32,15 @@ struct notifier_block br_device_notifier = {
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct net_bridge_port *p = dev->br_port;
+	struct net_bridge_port *p = br_port_get(dev);
 	struct net_bridge *br;
 	int err;
 
 	/* not a port of a bridge */
-	if (p == NULL)
+	if (!br_port_exists(dev))
 		return NOTIFY_DONE;
 
+	p = br_port_get(dev);
 	br = p->br;
 
 	switch (event) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c83519b..94f41b7 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -145,6 +145,10 @@ struct net_bridge_port
 #endif
 };
 
+#define br_port_get_rcu(dev) ((struct net_bridge_port *) rcu_dereference(dev->rx_handler_data))
+#define br_port_get(dev) ((struct net_bridge_port *) dev->rx_handler_data)
+#define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
+
 struct br_cpu_netstats {
 	unsigned long	rx_packets;
 	unsigned long	rx_bytes;
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 217bd22..70aecb4 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -137,12 +137,13 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 		struct net_device *dev)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
-	struct net_bridge_port *p = rcu_dereference(dev->br_port);
+	struct net_bridge_port *p;
 	struct net_bridge *br;
 	const unsigned char *buf;
 
-	if (!p)
+	if (!br_port_exists(dev))
 		goto err;
+	p = br_port_get_rcu(dev);
 
 	if (!pskb_may_pull(skb, 4))
 		goto err;
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 9e19166..46624bb 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -24,8 +24,9 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		return EBT_DROP;
 
 	if (par->hooknum != NF_BR_BROUTING)
+		/* rcu_read_lock()ed by nf_hook_slow */
 		memcpy(eth_hdr(skb)->h_dest,
-		       par->in->br_port->br->dev->dev_addr, ETH_ALEN);
+		       br_port_get_rcu(par->in)->br->dev->dev_addr, ETH_ALEN);
 	else
 		memcpy(eth_hdr(skb)->h_dest, par->in->dev_addr, ETH_ALEN);
 	skb->pkt_type = PACKET_HOST;
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index ae3c7ce..26377e9 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -177,8 +177,9 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	if (in) {
 		strcpy(pm->physindev, in->name);
 		/* If in isn't a bridge, then physindev==indev */
-		if (in->br_port)
-			strcpy(pm->indev, in->br_port->br->dev->name);
+		if (br_port_exists(in))
+			/* rcu_read_lock()ed by nf_hook_slow */
+			strcpy(pm->indev, br_port_get_rcu(in)->br->dev->name);
 		else
 			strcpy(pm->indev, in->name);
 	} else
@@ -187,7 +188,8 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 	if (out) {
 		/* If out exists, then out is a bridge port */
 		strcpy(pm->physoutdev, out->name);
-		strcpy(pm->outdev, out->br_port->br->dev->name);
+		/* rcu_read_lock()ed by nf_hook_slow */
+		strcpy(pm->outdev, br_port_get_rcu(out)->br->dev->name);
 	} else
 		pm->outdev[0] = pm->physoutdev[0] = '\0';
 
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 59ca00e..bcc102e 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -140,11 +140,14 @@ ebt_basic_match(const struct ebt_entry *e, const struct ethhdr *h,
 		return 1;
 	if (FWINV2(ebt_dev_check(e->out, out), EBT_IOUT))
 		return 1;
-	if ((!in || !in->br_port) ? 0 : FWINV2(ebt_dev_check(
-	   e->logical_in, in->br_port->br->dev), EBT_ILOGICALIN))
+	/* rcu_read_lock()ed by nf_hook_slow */
+	if (in && br_port_exists(in) &&
+	    FWINV2(ebt_dev_check(e->logical_in, br_port_get_rcu(in)->br->dev),
+		   EBT_ILOGICALIN))
 		return 1;
-	if ((!out || !out->br_port) ? 0 : FWINV2(ebt_dev_check(
-	   e->logical_out, out->br_port->br->dev), EBT_ILOGICALOUT))
+	if (out && br_port_exists(out) &&
+	    FWINV2(ebt_dev_check(e->logical_out, br_port_get_rcu(out)->br->dev),
+		   EBT_ILOGICALOUT))
 		return 1;
 
 	if (e->bitmask & EBT_SOURCEMAC) {
diff --git a/net/core/dev.c b/net/core/dev.c
index c49dda0..cf95489 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2767,7 +2767,8 @@ int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 	if (master->priv_flags & IFF_MASTER_ARPMON)
 		dev->last_rx = jiffies;
 
-	if ((master->priv_flags & IFF_MASTER_ALB) && master->br_port) {
+	if ((master->priv_flags & IFF_MASTER_ALB) &&
+	    (master->priv_flags & IFF_BRIDGE_PORT)) {
 		/* Do address unmangle. The local destination address
 		 * will be always the one master has. Provides the right
 		 * functionality in a bridge.
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index fc9a211..e0504e9 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -403,8 +403,9 @@ __build_packet_message(struct nfulnl_instance *inst,
 			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_PHYSINDEV,
 				     htonl(indev->ifindex));
 			/* this is the bridge group "brX" */
+			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
 			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_INDEV,
-				     htonl(indev->br_port->br->dev->ifindex));
+				     htonl(br_port_get_rcu(indev)->br->dev->ifindex));
 		} else {
 			/* Case 2: indev is bridge group, we need to look for
 			 * physical device (when called from ipv4) */
@@ -430,8 +431,9 @@ __build_packet_message(struct nfulnl_instance *inst,
 			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
 				     htonl(outdev->ifindex));
 			/* this is the bridge group "brX" */
+			/* rcu_read_lock()ed by nf_hook_slow or nf_log_packet */
 			NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_OUTDEV,
-				     htonl(outdev->br_port->br->dev->ifindex));
+				     htonl(br_port_get_rcu(outdev)->br->dev->ifindex));
 		} else {
 			/* Case 2: indev is a bridge group, we need to look
 			 * for physical device (when called from ipv4) */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 12e1ab3..cc3ae86 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -296,8 +296,9 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			NLA_PUT_BE32(skb, NFQA_IFINDEX_PHYSINDEV,
 				     htonl(indev->ifindex));
 			/* this is the bridge group "brX" */
+			/* rcu_read_lock()ed by __nf_queue */
 			NLA_PUT_BE32(skb, NFQA_IFINDEX_INDEV,
-				     htonl(indev->br_port->br->dev->ifindex));
+				     htonl(br_port_get_rcu(indev)->br->dev->ifindex));
 		} else {
 			/* Case 2: indev is bridge group, we need to look for
 			 * physical device (when called from ipv4) */
@@ -321,8 +322,9 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			NLA_PUT_BE32(skb, NFQA_IFINDEX_PHYSOUTDEV,
 				     htonl(outdev->ifindex));
 			/* this is the bridge group "brX" */
+			/* rcu_read_lock()ed by __nf_queue */
 			NLA_PUT_BE32(skb, NFQA_IFINDEX_OUTDEV,
-				     htonl(outdev->br_port->br->dev->ifindex));
+				     htonl(br_port_get_rcu(outdev)->br->dev->ifindex));
 		} else {
 			/* Case 2: outdev is bridge group, we need to look for
 			 * physical output device (when called from ipv4) */
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index db71150..9ee021f 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1107,7 +1107,7 @@ static int nl80211_valid_4addr(struct cfg80211_registered_device *rdev,
 			       enum nl80211_iftype iftype)
 {
 	if (!use_4addr) {
-		if (netdev && netdev->br_port)
+		if (netdev && (netdev->priv_flags & IFF_BRIDGE_PORT))
 			return -EBUSY;
 		return 0;
 	}
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 3416373..0c8a1e8 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -770,8 +770,8 @@ int cfg80211_change_iface(struct cfg80211_registered_device *rdev,
 		return -EOPNOTSUPP;
 
 	/* if it's part of a bridge, reject changing type to station/ibss */
-	if (dev->br_port && (ntype == NL80211_IFTYPE_ADHOC ||
-			     ntype == NL80211_IFTYPE_STATION))
+	if ((dev->priv_flags & IFF_BRIDGE_PORT) &&
+	    (ntype == NL80211_IFTYPE_ADHOC || ntype == NL80211_IFTYPE_STATION))
 		return -EBUSY;
 
 	if (ntype != otype) {
-- 
1.7.0.1

