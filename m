From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 4/5] iptunnels: advertise link netns via netlink
Date: Wed,  2 Jul 2014 13:59:05 +0200
Message-ID: <1404302346-4507-5-git-send-email-nicolas.dichtel@6wind.com>
References: <537327F1.4060603@6wind.com>
 <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53377 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaGBMIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 08:08:43 -0400
In-Reply-To: <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip_tunnels.h | 1 +
 net/ipv4/ip_gre.c        | 2 ++
 net/ipv4/ip_tunnel.c     | 8 ++++++++
 net/ipv4/ip_vti.c        | 1 +
 net/ipv4/ipip.c          | 1 +
 net/ipv6/sit.c           | 1 +
 6 files changed, 14 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a4daf9eb8562..2da3d9deb33f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -105,6 +105,7 @@ struct ip_tunnel_net {
 int ip_tunnel_init(struct net_device *dev);
 void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
+struct net *ip_tunnel_get_link_net(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9b842544aea3..5a5034eb8367 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -745,6 +745,7 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
@@ -759,6 +760,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __net_init ipgre_tap_init_net(struct net *net)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 54b6731dab55..37efd17b4d08 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -854,6 +854,14 @@ void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_dellink);
 
+struct net *ip_tunnel_get_link_net(const struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	return tunnel->net;
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_get_link_net);
+
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 				  struct rtnl_link_ops *ops, char *devname)
 {
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index b8960f3527f3..11ec1ed545df 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -530,6 +530,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.changelink	= vti_changelink,
 	.get_size	= vti_get_size,
 	.fill_info	= vti_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __init vti_init(void)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62eaa005e146..aab4c231d2c5 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -420,6 +420,7 @@ static struct rtnl_link_ops ipip_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipip_get_size,
 	.fill_info	= ipip_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel ipip_handler __read_mostly = {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4f408176dc64..1ccf4f9e7bb0 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1673,6 +1673,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
 	.dellink	= ipip6_dellink,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
-- 
1.9.0
