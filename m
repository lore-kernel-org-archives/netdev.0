From: gfree.wind@foxmail.com
Subject: [PATCH net v2] net: dev: Fix possible memleaks when fail to register_netdevice
Date: Fri, 28 Apr 2017 11:19:28 +0800
Message-ID: <1493349568-58635-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: jiri@resnulli.us, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau2.qq.com ([54.206.34.216]:48114 "EHLO smtpbgau2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754183AbdD1DUS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 23:20:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

These drivers allocate kinds of resources in init routine, and free
some resources in the destructor of net_device. It may cause memleak
when some errors happen after register_netdevice invokes the init
callback. Because only the uninit callback is invoked in the error
handler of register_netdevice, but the destructor not. As a result,
some resources are lost forever.

Now create one new function to free the resource in the destructor.
When ndo_uninit func is invoked, it would invoke this func to perform
the free instead of destructor if the dev is not registered at all.
It could cleanup all resources and follow original design that the
resources would be freed in destructor normally after register device
successfully.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 drivers/net/dummy.c     | 14 +++++++++++---
 drivers/net/ifb.c       | 33 +++++++++++++++++++++++----------
 drivers/net/loopback.c  | 15 ++++++++++++++-
 drivers/net/team/team.c | 15 ++++++++++++---
 drivers/net/veth.c      | 15 ++++++++++++++-
 net/8021q/vlan_dev.c    | 17 +++++++++++++----
 net/ipv4/ip_tunnel.c    | 11 ++++++++++-
 net/ipv6/ip6_gre.c      | 18 ++++++++++++++----
 net/ipv6/ip6_tunnel.c   | 11 ++++++++++-
 net/ipv6/ip6_vti.c      | 11 ++++++++++-
 net/ipv6/sit.c          | 17 +++++++++++++----
 11 files changed, 144 insertions(+), 33 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2c80611..0b3c1cc 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -153,9 +153,19 @@ static int dummy_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void dummy_destructor_free(struct net_device *dev)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	kfree(priv->vfinfo);
+}
+
 static void dummy_dev_uninit(struct net_device *dev)
 {
 	free_percpu(dev->dstats);
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		dummy_destructor_free(dev);
 }
 
 static int dummy_change_carrier(struct net_device *dev, bool new_carrier)
@@ -310,9 +320,7 @@ static void dummy_get_drvinfo(struct net_device *dev,
 
 static void dummy_free_netdev(struct net_device *dev)
 {
-	struct dummy_priv *priv = netdev_priv(dev);
-
-	kfree(priv->vfinfo);
+	dummy_destructor_free(dev);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 312fce7..b25aea1 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -180,6 +180,27 @@ static int ifb_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void ifb_destructor_free(struct net_device *dev)
+{
+	struct ifb_dev_private *dp = netdev_priv(dev);
+	struct ifb_q_private *txp = dp->tx_private;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++, txp++) {
+		tasklet_kill(&txp->ifb_tasklet);
+		__skb_queue_purge(&txp->rq);
+		__skb_queue_purge(&txp->tq);
+	}
+	kfree(dp->tx_private);
+}
+
+static void ifb_dev_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ifb_destructor_free(dev);
+}
+
 static const struct net_device_ops ifb_netdev_ops = {
 	.ndo_open	= ifb_open,
 	.ndo_stop	= ifb_close,
@@ -187,6 +208,7 @@ static int ifb_dev_init(struct net_device *dev)
 	.ndo_start_xmit	= ifb_xmit,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_init	= ifb_dev_init,
+	.ndo_uninit	= ifb_dev_uninit,
 };
 
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
@@ -197,16 +219,7 @@ static int ifb_dev_init(struct net_device *dev)
 
 static void ifb_dev_free(struct net_device *dev)
 {
-	struct ifb_dev_private *dp = netdev_priv(dev);
-	struct ifb_q_private *txp = dp->tx_private;
-	int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++,txp++) {
-		tasklet_kill(&txp->ifb_tasklet);
-		__skb_queue_purge(&txp->rq);
-		__skb_queue_purge(&txp->tq);
-	}
-	kfree(dp->tx_private);
+	ifb_destructor_free(dev);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b23b719..d7c1016 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -141,15 +141,28 @@ static int loopback_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void loopback_dev_free(struct net_device *dev)
+static void loopback_destructor_free(struct net_device *dev)
 {
 	dev_net(dev)->loopback_dev = NULL;
 	free_percpu(dev->lstats);
+}
+
+static void loopback_dev_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		loopback_destructor_free(dev);
+}
+
+static void loopback_dev_free(struct net_device *dev)
+{
+	loopback_destructor_free(dev);
 	free_netdev(dev);
 }
 
 static const struct net_device_ops loopback_ops = {
 	.ndo_init      = loopback_dev_init,
+	.ndo_uninit = loopback_dev_uninit,
 	.ndo_start_xmit= loopback_xmit,
 	.ndo_get_stats64 = loopback_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f8c81f1..34753b3 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1619,6 +1619,13 @@ static int team_init(struct net_device *dev)
 	return err;
 }
 
+static void team_destructor_free(struct net_device *dev)
+{
+	struct team *team = netdev_priv(dev);
+
+	free_percpu(team->pcpu_stats);
+}
+
 static void team_uninit(struct net_device *dev)
 {
 	struct team *team = netdev_priv(dev);
@@ -1636,13 +1643,15 @@ static void team_uninit(struct net_device *dev)
 	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
 	netdev_change_features(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		team_destructor_free(dev);
 }
 
 static void team_destructor(struct net_device *dev)
 {
-	struct team *team = netdev_priv(dev);
-
-	free_percpu(team->pcpu_stats);
+	team_destructor_free(dev);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8c39d6d..418376a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -224,9 +224,21 @@ static int veth_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void veth_dev_free(struct net_device *dev)
+static void veth_destructor_free(struct net_device *dev)
 {
 	free_percpu(dev->vstats);
+}
+
+static void veth_dev_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		veth_destructor_free(dev);
+}
+
+static void veth_dev_free(struct net_device *dev)
+{
+	veth_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -284,6 +296,7 @@ static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
 
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
+	.ndo_uninit          = veth_dev_uninit,
 	.ndo_open            = veth_open,
 	.ndo_stop            = veth_close,
 	.ndo_start_xmit      = veth_xmit,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e97ab82..adcaa39 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -608,6 +608,14 @@ static int vlan_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void vlan_destructor_free(struct net_device *dev)
+{
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+
+	free_percpu(vlan->vlan_pcpu_stats);
+	vlan->vlan_pcpu_stats = NULL;
+}
+
 static void vlan_dev_uninit(struct net_device *dev)
 {
 	struct vlan_priority_tci_mapping *pm;
@@ -620,6 +628,10 @@ static void vlan_dev_uninit(struct net_device *dev)
 			kfree(pm);
 		}
 	}
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		vlan_destructor_free(dev);
 }
 
 static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
@@ -803,10 +815,7 @@ static int vlan_dev_get_iflink(const struct net_device *dev)
 
 static void vlan_dev_free(struct net_device *dev)
 {
-	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
-
-	free_percpu(vlan->vlan_pcpu_stats);
-	vlan->vlan_pcpu_stats = NULL;
+	vlan_destructor_free(dev);
 	free_netdev(dev);
 }
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 823abae..96a3005 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -954,13 +954,18 @@ int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_change_mtu);
 
-static void ip_tunnel_dev_free(struct net_device *dev)
+static void ip_tunnel_destructor_free(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	gro_cells_destroy(&tunnel->gro_cells);
 	dst_cache_destroy(&tunnel->dst_cache);
 	free_percpu(dev->tstats);
+}
+
+static void ip_tunnel_dev_free(struct net_device *dev)
+{
+	ip_tunnel_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -1192,6 +1197,10 @@ void ip_tunnel_uninit(struct net_device *dev)
 		ip_tunnel_del(itn, netdev_priv(dev));
 
 	dst_cache_reset(&tunnel->dst_cache);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ip_tunnel_destructor_free(dev);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6fcb7cb..c86d593 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -77,6 +77,7 @@ struct ip6gre_net {
 static void ip6gre_tunnel_setup(struct net_device *dev);
 static void ip6gre_tunnel_link(struct ip6gre_net *ign, struct ip6_tnl *t);
 static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu);
+static void ip6gre_dev_free(struct net_device *dev);
 
 /* Tunnel hash table */
 
@@ -355,6 +356,14 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	return NULL;
 }
 
+static void ip6gre_destructor_free(struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	dst_cache_destroy(&t->dst_cache);
+	free_percpu(dev->tstats);
+}
+
 static void ip6gre_tunnel_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
@@ -363,6 +372,10 @@ static void ip6gre_tunnel_uninit(struct net_device *dev)
 	ip6gre_tunnel_unlink(ign, t);
 	dst_cache_reset(&t->dst_cache);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ip6gre_destructor_free(dev);
 }
 
 
@@ -981,10 +994,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 
 static void ip6gre_dev_free(struct net_device *dev)
 {
-	struct ip6_tnl *t = netdev_priv(dev);
-
-	dst_cache_destroy(&t->dst_cache);
-	free_percpu(dev->tstats);
+	ip6gre_destructor_free(dev);
 	free_netdev(dev);
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 75fac93..1e10334 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -247,13 +247,18 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 	}
 }
 
-static void ip6_dev_free(struct net_device *dev)
+static void ip6_tnl_destructor_free(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 
 	gro_cells_destroy(&t->gro_cells);
 	dst_cache_destroy(&t->dst_cache);
 	free_percpu(dev->tstats);
+}
+
+static void ip6_dev_free(struct net_device *dev)
+{
+	ip6_tnl_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -387,6 +392,10 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
 		ip6_tnl_unlink(ip6n, t);
 	dst_cache_reset(&t->dst_cache);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ip6_tnl_destructor_free(dev);
 }
 
 /**
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 3d8a3b6..3b3f49a 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -177,9 +177,14 @@ struct vti6_net {
 	}
 }
 
-static void vti6_dev_free(struct net_device *dev)
+static void vti6_destructor_free(struct net_device *dev)
 {
 	free_percpu(dev->tstats);
+}
+
+static void vti6_dev_free(struct net_device *dev)
+{
+	vti6_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -296,6 +301,10 @@ static void vti6_dev_uninit(struct net_device *dev)
 	else
 		vti6_tnl_unlink(ip6n, t);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		vti6_destructor_free(dev);
 }
 
 static int vti6_rcv(struct sk_buff *skb)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 99853c6..28c1649 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -464,6 +464,14 @@ static void prl_list_destroy_rcu(struct rcu_head *head)
 	return ok;
 }
 
+static void ipip6_destructor_free(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	dst_cache_destroy(&tunnel->dst_cache);
+	free_percpu(dev->tstats);
+}
+
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -477,6 +485,10 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	}
 	dst_cache_reset(&tunnel->dst_cache);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ipip6_destructor_free(dev);
 }
 
 static int ipip6_err(struct sk_buff *skb, u32 info)
@@ -1329,10 +1341,7 @@ static bool ipip6_valid_ip_proto(u8 ipproto)
 
 static void ipip6_dev_free(struct net_device *dev)
 {
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-
-	dst_cache_destroy(&tunnel->dst_cache);
-	free_percpu(dev->tstats);
+	ipip6_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
1.9.1
