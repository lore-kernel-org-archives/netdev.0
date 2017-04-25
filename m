From: gfree.wind@foxmail.com
Subject: [PATCH net] driver/net: Fix possible memleaks when fail to register_netdevice
Date: Tue, 25 Apr 2017 20:01:50 +0800
Message-ID: <1493121710-27910-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: jiri@resnulli.us, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:45999 "EHLO
        smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762905AbdDYMCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 08:02:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

These drivers allocate kinds of resources in init routine, and free
some resources in the destructor of net_device. It may cause memleak
when some errors happen after register_netdevice invokes the init
callback. Because only the uninit callback is invoked in the error
handler of register_netdevice, but the destructor not. As a result,
some resources are lost forever.

Now invokes the destructor instead of free_netdev somewhere, and free
the left resources in the newlink func when fail to register_netdevice.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/dummy.c      |  2 +-
 drivers/net/ifb.c        |  2 +-
 drivers/net/loopback.c   |  2 +-
 drivers/net/team/team.c  | 11 ++++++++++-
 drivers/net/veth.c       |  4 ++--
 net/8021q/vlan_netlink.c |  6 +++++-
 net/ipv4/ip_tunnel.c     |  9 ++++++++-
 net/ipv6/ip6_gre.c       |  6 +++++-
 net/ipv6/ip6_tunnel.c    | 12 ++++++++++--
 net/ipv6/ip6_vti.c       |  7 ++++++-
 net/ipv6/sit.c           |  5 ++++-
 11 files changed, 53 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2c80611..55b8a50 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -383,7 +383,7 @@ static int __init dummy_init_one(void)
 	return 0;
 
 err:
-	free_netdev(dev_dummy);
+	dummy_free_netdev(dev_dummy);
 	return err;
 }
 
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 312fce7..a298371 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -318,7 +318,7 @@ static int __init ifb_init_one(int index)
 	return 0;
 
 err:
-	free_netdev(dev_ifb);
+	ifb_dev_free(dev_ifb);
 	return err;
 }
 
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b23b719..c4e1d4c 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -208,7 +208,7 @@ static __net_init int loopback_net_init(struct net *net)
 
 
 out_free_netdev:
-	free_netdev(dev);
+	loopback_dev_free(dev);
 out:
 	if (net_eq(net, &init_net))
 		panic("loopback: Failed to register netdevice: %d\n", err);
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f8c81f1..0bc80fb 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2109,10 +2109,19 @@ static void team_setup(struct net_device *dev)
 static int team_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
+	int ret;
+
 	if (tb[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(dev);
 
-	return register_netdevice(dev);
+	ret = register_netdevice(dev);
+	if (ret) {
+		struct team *team = netdev_priv(dev);
+
+		free_percpu(team->pcpu_stats);
+	}
+
+	return ret;
 }
 
 static int team_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8c39d6d..f60f5ee 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -457,13 +457,13 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	return 0;
 
 err_register_dev:
-	/* nothing to do */
+	free_percpu(dev->vstats);
 err_configure_peer:
 	unregister_netdevice(peer);
 	return err;
 
 err_register_peer:
-	free_netdev(peer);
+	veth_dev_free(peer);
 	return err;
 }
 
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 1270207..a15826a 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -156,7 +156,11 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		return err;
 
-	return register_vlan_dev(dev);
+	err = register_vlan_dev(dev);
+	if (err)
+		free_percpu(vlan->vlan_pcpu_stats);
+
+	return err;
 }
 
 static inline size_t vlan_qos_map_size(unsigned int n)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 823abae..4acb296 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -63,6 +63,8 @@
 #include <net/ip6_route.h>
 #endif
 
+static void ip_tunnel_dev_free(struct net_device *dev);
+
 static unsigned int ip_tunnel_hash(__be32 key, __be32 remote)
 {
 	return hash_32((__force u32)key ^ (__force u32)remote,
@@ -285,7 +287,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 	return dev;
 
 failed_free:
-	free_netdev(dev);
+	ip_tunnel_dev_free(dev);
 failed:
 	return ERR_PTR(err);
 }
@@ -1099,7 +1101,12 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		dev->mtu = mtu;
 
 	ip_tunnel_add(itn, nt);
+
+	return 0;
 out:
+	gro_cells_destroy(&nt->gro_cells);
+	dst_cache_destroy(&nt->dst_cache);
+	free_percpu(dev->tstats);
 	return err;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_newlink);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6fcb7cb..d409ad1 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -77,6 +77,7 @@ struct ip6gre_net {
 static void ip6gre_tunnel_setup(struct net_device *dev);
 static void ip6gre_tunnel_link(struct ip6gre_net *ign, struct ip6_tnl *t);
 static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu);
+static void ip6gre_dev_free(struct net_device *dev);
 
 /* Tunnel hash table */
 
@@ -351,7 +352,7 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	return nt;
 
 failed_free:
-	free_netdev(dev);
+	ip6gre_dev_free(dev);
 	return NULL;
 }
 
@@ -1388,7 +1389,10 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 	dev_hold(dev);
 	ip6gre_tunnel_link(ign, nt);
 
+	return 0;
 out:
+	dst_cache_destroy(&nt->dst_cache);
+	free_percpu(dev->tstats);
 	return err;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 75fac93..95f512c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1960,11 +1960,12 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	struct ip6_tnl *nt, *t;
 	struct ip_tunnel_encap ipencap;
+	int err;
 
 	nt = netdev_priv(dev);
 
 	if (ip6_tnl_netlink_encap_parms(data, &ipencap)) {
-		int err = ip6_tnl_encap_setup(nt, &ipencap);
+		err = ip6_tnl_encap_setup(nt, &ipencap);
 
 		if (err < 0)
 			return err;
@@ -1981,7 +1982,14 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 			return -EEXIST;
 	}
 
-	return ip6_tnl_create2(dev);
+	err = ip6_tnl_create2(dev);
+	if (err) {
+		gro_cells_destroy(&t->gro_cells);
+		dst_cache_destroy(&t->dst_cache);
+		free_percpu(dev->tstats);
+	}
+
+	return err;
 }
 
 static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 3d8a3b6..b201eef 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -940,6 +940,7 @@ static int vti6_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct net *net = dev_net(dev);
 	struct ip6_tnl *nt;
+	int ret;
 
 	nt = netdev_priv(dev);
 	vti6_netlink_parms(data, &nt->parms);
@@ -949,7 +950,11 @@ static int vti6_newlink(struct net *src_net, struct net_device *dev,
 	if (vti6_locate(net, &nt->parms, 0))
 		return -EEXIST;
 
-	return vti6_tnl_create2(dev);
+	ret = vti6_tnl_create2(dev);
+	if (ret)
+		free_percpu(dev->tstats);
+
+	return ret;
 }
 
 static void vti6_dellink(struct net_device *dev, struct list_head *head)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 99853c6..f45dc4a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1555,8 +1555,11 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 		return -EEXIST;
 
 	err = ipip6_tunnel_create(dev);
-	if (err < 0)
+	if (err < 0) {
+		dst_cache_destroy(&nt->dst_cache);
+		free_percpu(dev->tstats);
 		return err;
+	}
 
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipip6_netlink_6rd_parms(data, &ip6rd))
-- 
1.9.1
