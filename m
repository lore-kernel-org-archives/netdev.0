From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] net: modify tunnel's name when changing link's name
Date: Tue, 20 May 2014 13:27:45 +0800
Message-ID: <537AE7D1.4090702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	stephen hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:3303 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750703AbaETGBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 02:01:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After executing command "ip tunnel add before local 192.168.0.19 mode gre",
the tunnel "before" and the link "before" are created.

Now if user executes command "ip link set dev before name after",
the tunnel's name is still "before", but the link's name is
"after". At last, user executes command "ip tunnel del before",
and error "No such device" will arise.

ip-tunnel uses ioctl to handle command. It firstly gets link through
tunnel name, but because link has a different name with tunnel, so
the error "No such device" arised.

In order to handle this situation, tunnel's name should be modified
when changing link's name.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 include/linux/netdevice.h | 3 +++
 include/net/ip6_tunnel.h  | 1 +
 include/net/ip_tunnels.h  | 1 +
 net/core/dev.c            | 4 ++++
 net/ipv4/ip_gre.c         | 2 ++
 net/ipv4/ip_tunnel.c      | 8 ++++++++
 net/ipv4/ip_vti.c         | 1 +
 net/ipv4/ipip.c           | 1 +
 net/ipv6/ip6_gre.c        | 2 ++
 net/ipv6/ip6_tunnel.c     | 8 ++++++++
 net/ipv6/ip6_vti.c        | 1 +
 net/ipv6/sit.c            | 1 +
 12 files changed, 33 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2dea98c..6a5fe67 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -995,6 +995,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ * void (*ndo_tunnel_rename)(struct net_device *dev)
+ * 	Callback to use for renaming tunnel when rename net_device.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1141,6 +1143,7 @@ struct net_device_ops {
 	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
 							struct net_device *dev,
 							void *priv);
+	void			(*ndo_tunnel_rename) (struct net_device *dev);
 };
 
 /**
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index a5593da..08cb9c7 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -69,6 +69,7 @@ int ip6_tnl_xmit_ctl(struct ip6_tnl *t);
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
+void ip6_tunnel_rename(struct net_device *dev);
 
 static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a4daf9e..b951ebb 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -113,6 +113,7 @@ void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
 int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
+void ip_tunnel_rename(struct net_device *dev);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
 struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 867adb2..7afc216 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1086,6 +1086,7 @@ int dev_change_name(struct net_device *dev, const char *newname)
 	int err = 0;
 	int ret;
 	struct net *net;
+	struct net_device_ops *ops = dev->netdev_ops;
 
 	ASSERT_RTNL();
 	BUG_ON(!dev_net(dev));
@@ -1148,6 +1149,9 @@ rollback:
 		}
 	}
 
+	if (ops->ndo_tunnel_rename)
+		ops->ndo_tunnel_rename(dev);
+
 	return err;
 }
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c5a557a..960a57d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -453,6 +453,7 @@ static const struct net_device_ops ipgre_netdev_ops = {
 	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
 	.ndo_change_mtu		= ip_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_tunnel_rename	= ip_tunnel_rename,
 };
 
 #define GRE_FEATURES (NETIF_F_SG |		\
@@ -643,6 +644,7 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= ip_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_tunnel_rename	= ip_tunnel_rename,
 };
 
 static void ipgre_tap_setup(struct net_device *dev)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 059176d..7d13c6a 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -818,6 +818,14 @@ done:
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_ioctl);
 
+void ip_tunnel_rename(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	strcpy(tunnel->parms.name, dev->name);
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_rename);
+
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index afcee51..397c02b 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -332,6 +332,7 @@ static const struct net_device_ops vti_netdev_ops = {
 	.ndo_do_ioctl	= vti_tunnel_ioctl,
 	.ndo_change_mtu	= ip_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_tunnel_rename = ip_tunnel_rename,
 };
 
 static void vti_tunnel_setup(struct net_device *dev)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 812b183..b759acb 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -270,6 +270,7 @@ static const struct net_device_ops ipip_netdev_ops = {
 	.ndo_do_ioctl	= ipip_tunnel_ioctl,
 	.ndo_change_mtu = ip_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_tunnel_rename = ip_tunnel_rename,
 };
 
 #define IPIP_FEATURES (NETIF_F_SG |		\
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3873181..e9fb229 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1208,6 +1208,7 @@ static const struct net_device_ops ip6gre_netdev_ops = {
 	.ndo_do_ioctl		= ip6gre_tunnel_ioctl,
 	.ndo_change_mtu		= ip6gre_tunnel_change_mtu,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
+	.ndo_tunnel_rename	= ip6_tunnel_rename,
 };
 
 static void ip6gre_dev_free(struct net_device *dev)
@@ -1481,6 +1482,7 @@ static const struct net_device_ops ip6gre_tap_netdev_ops = {
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = ip6gre_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_tunnel_rename = ip6_tunnel_rename,
 };
 
 static void ip6gre_tap_setup(struct net_device *dev)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index b05b609..bd6ba9b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1453,6 +1453,13 @@ ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+void ip6_tunnel_rename(struct net_device *dev)
+{
+	struct ip6_tnl *tnl = netdev_priv(dev);
+
+	strcpy(tnl->parms.name, dev->name);
+}
+EXPORT_SYMBOL_GPL(ip6_tunnel_rename);
 
 static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_uninit	= ip6_tnl_dev_uninit,
@@ -1460,6 +1467,7 @@ static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_do_ioctl	= ip6_tnl_ioctl,
 	.ndo_change_mtu = ip6_tnl_change_mtu,
 	.ndo_get_stats	= ip6_get_stats,
+	.ndo_tunnel_rename = ip6_tunnel_rename,
 };
 
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 2953c0c..fa48539 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -781,6 +781,7 @@ static const struct net_device_ops vti6_netdev_ops = {
 	.ndo_do_ioctl	= vti6_ioctl,
 	.ndo_change_mtu = vti6_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_tunnel_rename = ip6_tunnel_rename,
 };
 
 /**
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e5a453c..31c9561 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1318,6 +1318,7 @@ static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
 	.ndo_get_stats64 = ip_tunnel_get_stats64,
+	.ndo_tunnel_rename = ip6_tunnel_rename,
 };
 
 static void ipip6_dev_free(struct net_device *dev)
-- 
1.8.3.1
