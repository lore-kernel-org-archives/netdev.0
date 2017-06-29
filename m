From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/29] netfilter: ipt_CLUSTERIP: do not hold dev
Date: Fri, 30 Jun 2017 00:53:19 +0200
Message-ID: <1498776807-11124-22-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57606 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752403AbdF2Wx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 396F8BDF51
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2A4FCD1CB3
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D560DDA46B
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:39 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>

It's a terrible thing to hold dev in iptables target. When the dev is
being removed, unregister_netdevice has to wait for the dev to become
free. dmesg will keep logging the err:

  kernel:unregister_netdevice: waiting for veth0_in to become free. \
  Usage count = 1

until iptables rules with this target are removed manually.

The worse thing is when deleting a netns, a virtual nic will be deleted
instead of reset to init_net in default_device_ops exit/exit_batch. As
it is earlier than to flush the iptables rules in iptable_filter_net_ops
exit, unregister_netdevice will block to wait for the nic to become free.

As unregister_netdevice is actually waiting for iptables rules flushing
while iptables rules have to be flushed after unregister_netdevice. This
'dead lock' will cause unregister_netdevice to block there forever. As
the netns is not available to operate at that moment, iptables rules can
not even be flushed manually either.

The reproducer can be:

  # ip netns add test
  # ip link add veth0_in type veth peer name veth0_out
  # ip link set veth0_in netns test
  # ip netns exec test ip link set lo up
  # ip netns exec test ip link set veth0_in up
  # ip netns exec test iptables -I INPUT -d 1.2.3.4 -i veth0_in -j \
    CLUSTERIP --new --clustermac 89:d4:47:eb:9a:fa --total-nodes 3 \
    --local-node 1 --hashmode sourceip-sourceport
  # ip netns del test

This issue can be triggered by all virtual nics with ipt_CLUSTERIP.

This patch is to fix it by not holding dev in ipt_CLUSTERIP, but saving
the dev->ifindex instead of the dev.

As Pablo Neira Ayuso's suggestion, it will refresh c->ifindex and dev's
mc by registering a netdevice notifier, just as what xt_TEE does. So it
removes the old codes updating dev's mc, and also no need to initialize
c->ifindex with dev->ifindex.

But as one config can be shared by more than one targets, and the netdev
notifier is per config, not per target. It couldn't get e->ip.iniface
in the notifier handler. So e->ip.iniface has to be saved into config.

Note that for backwards compatibility, this patch doesn't remove the
codes checking if the dev exists before creating a config.

v1->v2:
  - As Pablo Neira Ayuso's suggestion, register a netdevice notifier to
    manage c->ifindex and dev's mc.

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 101 +++++++++++++++++++++++++++----------
 1 file changed, 73 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index f30bee8e407b..7d72decb80f9 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -47,7 +47,7 @@ struct clusterip_config {
 
 	__be32 clusterip;			/* the IP address */
 	u_int8_t clustermac[ETH_ALEN];		/* the MAC address */
-	struct net_device *dev;			/* device */
+	int ifindex;				/* device ifindex */
 	u_int16_t num_total_nodes;		/* total number of nodes */
 	unsigned long local_nodes;		/* node number array */
 
@@ -57,6 +57,9 @@ struct clusterip_config {
 	enum clusterip_hashmode hash_mode;	/* which hashing mode */
 	u_int32_t hash_initval;			/* hash initialization */
 	struct rcu_head rcu;
+
+	char ifname[IFNAMSIZ];			/* device ifname */
+	struct notifier_block notifier;		/* refresh c->ifindex in it */
 };
 
 #ifdef CONFIG_PROC_FS
@@ -98,9 +101,8 @@ clusterip_config_put(struct clusterip_config *c)
  * entry(rule) is removed, remove the config from lists, but don't free it
  * yet, since proc-files could still be holding references */
 static inline void
-clusterip_config_entry_put(struct clusterip_config *c)
+clusterip_config_entry_put(struct net *net, struct clusterip_config *c)
 {
-	struct net *net = dev_net(c->dev);
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 
 	local_bh_disable();
@@ -109,8 +111,7 @@ clusterip_config_entry_put(struct clusterip_config *c)
 		spin_unlock(&cn->lock);
 		local_bh_enable();
 
-		dev_mc_del(c->dev, c->clustermac);
-		dev_put(c->dev);
+		unregister_netdevice_notifier(&c->notifier);
 
 		/* In case anyone still accesses the file, the open/close
 		 * functions are also incrementing the refcount on their own,
@@ -170,19 +171,55 @@ clusterip_config_init_nodelist(struct clusterip_config *c,
 		set_bit(i->local_nodes[n] - 1, &c->local_nodes);
 }
 
-static struct clusterip_config *
-clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
-		      struct net_device *dev)
+static int
+clusterip_netdev_event(struct notifier_block *this, unsigned long event,
+		       void *ptr)
 {
-	struct net *net = dev_net(dev);
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct clusterip_config *c;
+
+	c = container_of(this, struct clusterip_config, notifier);
+	switch (event) {
+	case NETDEV_REGISTER:
+		if (!strcmp(dev->name, c->ifname)) {
+			c->ifindex = dev->ifindex;
+			dev_mc_add(dev, c->clustermac);
+		}
+		break;
+	case NETDEV_UNREGISTER:
+		if (dev->ifindex == c->ifindex) {
+			dev_mc_del(dev, c->clustermac);
+			c->ifindex = -1;
+		}
+		break;
+	case NETDEV_CHANGENAME:
+		if (!strcmp(dev->name, c->ifname)) {
+			c->ifindex = dev->ifindex;
+			dev_mc_add(dev, c->clustermac);
+		} else if (dev->ifindex == c->ifindex) {
+			dev_mc_del(dev, c->clustermac);
+			c->ifindex = -1;
+		}
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct clusterip_config *
+clusterip_config_init(struct net *net, const struct ipt_clusterip_tgt_info *i,
+		      __be32 ip, const char *iniface)
+{
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
+	struct clusterip_config *c;
+	int err;
 
 	c = kzalloc(sizeof(*c), GFP_ATOMIC);
 	if (!c)
 		return ERR_PTR(-ENOMEM);
 
-	c->dev = dev;
+	strcpy(c->ifname, iniface);
+	c->ifindex = -1;
 	c->clusterip = ip;
 	memcpy(&c->clustermac, &i->clustermac, ETH_ALEN);
 	c->num_total_nodes = i->num_total_nodes;
@@ -213,17 +250,27 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 					  cn->procdir,
 					  &clusterip_proc_fops, c);
 		if (!c->pde) {
-			spin_lock_bh(&cn->lock);
-			list_del_rcu(&c->list);
-			spin_unlock_bh(&cn->lock);
-			kfree(c);
-
-			return ERR_PTR(-ENOMEM);
+			err = -ENOMEM;
+			goto err;
 		}
 	}
 #endif
 
-	return c;
+	c->notifier.notifier_call = clusterip_netdev_event;
+	err = register_netdevice_notifier(&c->notifier);
+	if (!err)
+		return c;
+
+#ifdef CONFIG_PROC_FS
+	proc_remove(c->pde);
+err:
+#endif
+	spin_lock_bh(&cn->lock);
+	list_del_rcu(&c->list);
+	spin_unlock_bh(&cn->lock);
+	kfree(c);
+
+	return ERR_PTR(err);
 }
 
 #ifdef CONFIG_PROC_FS
@@ -425,14 +472,13 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 					e->ip.iniface);
 				return -ENOENT;
 			}
+			dev_put(dev);
 
-			config = clusterip_config_init(cipinfo,
-							e->ip.dst.s_addr, dev);
-			if (IS_ERR(config)) {
-				dev_put(dev);
+			config = clusterip_config_init(par->net, cipinfo,
+						       e->ip.dst.s_addr,
+						       e->ip.iniface);
+			if (IS_ERR(config))
 				return PTR_ERR(config);
-			}
-			dev_mc_add(config->dev, config->clustermac);
 		}
 	}
 	cipinfo->config = config;
@@ -458,7 +504,7 @@ static void clusterip_tg_destroy(const struct xt_tgdtor_param *par)
 
 	/* if no more entries are referencing the config, remove it
 	 * from the list and destroy the proc entry */
-	clusterip_config_entry_put(cipinfo->config);
+	clusterip_config_entry_put(par->net, cipinfo->config);
 
 	clusterip_config_put(cipinfo->config);
 
@@ -558,10 +604,9 @@ arp_mangle(void *priv,
 	 * addresses on different interfacs.  However, in the CLUSTERIP case
 	 * this wouldn't work, since we didn't subscribe the mcast group on
 	 * other interfaces */
-	if (c->dev != state->out) {
-		pr_debug("not mangling arp reply on different "
-			 "interface: cip'%s'-skb'%s'\n",
-			 c->dev->name, state->out->name);
+	if (c->ifindex != state->out->ifindex) {
+		pr_debug("not mangling arp reply on different interface: cip'%d'-skb'%d'\n",
+			 c->ifindex, state->out->ifindex);
 		clusterip_config_put(c);
 		return NF_ACCEPT;
 	}
-- 
2.1.4
