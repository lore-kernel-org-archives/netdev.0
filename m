From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v5 3/4] tunnels: advertise link netns via netlink
Date: Thu, 15 Jan 2015 15:11:17 +0100
Message-ID: <1421331078-21622-4-git-send-email-nicolas.dichtel@6wind.com>
References: <87wq7g831b.fsf@x220.int.ebiederm.org>
 <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net, cwang@twopensource.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49135 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754863AbbAOOLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 09:11:43 -0500
In-Reply-To: <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c      | 8 ++++++++
 include/net/ip6_tunnel.h | 1 +
 include/net/ip_tunnels.h | 1 +
 net/ipv4/ip_gre.c        | 2 ++
 net/ipv4/ip_tunnel.c     | 8 ++++++++
 net/ipv4/ip_vti.c        | 1 +
 net/ipv4/ipip.c          | 1 +
 net/ipv6/ip6_gre.c       | 1 +
 net/ipv6/ip6_tunnel.c    | 9 +++++++++
 net/ipv6/ip6_vti.c       | 1 +
 net/ipv6/sit.c           | 1 +
 11 files changed, 34 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6b6b45622a0a..88dbb1edea6e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2922,6 +2922,13 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static struct net *vxlan_get_link_net(const struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	return vxlan->net;
+}
+
 static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.kind		= "vxlan",
 	.maxtype	= IFLA_VXLAN_MAX,
@@ -2933,6 +2940,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
+	.get_link_net	= vxlan_get_link_net,
 };
 
 static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 9326c41c2d7f..76c091b53dae 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -70,6 +70,7 @@ int ip6_tnl_xmit_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
+struct net *ip6_tnl_get_link_net(const struct net_device *dev);
 
 static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index ce4db3cc5647..2c47061a6954 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -141,6 +141,7 @@ int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
 int ip_tunnel_init(struct net_device *dev);
 void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
+struct net *ip_tunnel_get_link_net(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 942576e27df1..6e7727f27393 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -829,6 +829,7 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
@@ -843,6 +844,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __net_init ipgre_tap_init_net(struct net *net)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index d3e447936720..2cd08280c77b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -972,6 +972,14 @@ void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_dellink);
 
+struct net *ip_tunnel_get_link_net(const struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	return tunnel->net;
+}
+EXPORT_SYMBOL(ip_tunnel_get_link_net);
+
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 				  struct rtnl_link_ops *ops, char *devname)
 {
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 1a7e979e80ba..94efe148181c 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -531,6 +531,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.dellink        = ip_tunnel_dellink,
 	.get_size	= vti_get_size,
 	.fill_info	= vti_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __init vti_init(void)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 40403114f00a..b58d6689874c 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -498,6 +498,7 @@ static struct rtnl_link_ops ipip_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipip_get_size,
 	.fill_info	= ipip_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel ipip_handler __read_mostly = {
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 13cda4c6313b..9306a5ff9149 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1662,6 +1662,7 @@ static struct rtnl_link_ops ip6gre_link_ops __read_mostly = {
 	.dellink	= ip6gre_dellink,
 	.get_size	= ip6gre_get_size,
 	.fill_info	= ip6gre_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 static struct rtnl_link_ops ip6gre_tap_ops __read_mostly = {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 92b3da571980..266a264ec212 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1760,6 +1760,14 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+struct net *ip6_tnl_get_link_net(const struct net_device *dev)
+{
+	struct ip6_tnl *tunnel = netdev_priv(dev);
+
+	return tunnel->net;
+}
+EXPORT_SYMBOL(ip6_tnl_get_link_net);
+
 static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_LINK]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_LOCAL]		= { .len = sizeof(struct in6_addr) },
@@ -1783,6 +1791,7 @@ static struct rtnl_link_ops ip6_link_ops __read_mostly = {
 	.dellink	= ip6_tnl_dellink,
 	.get_size	= ip6_tnl_get_size,
 	.fill_info	= ip6_tnl_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ace10d0b3aac..5fb9e212eca8 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -1016,6 +1016,7 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
 	.changelink	= vti6_changelink,
 	.get_size	= vti6_get_size,
 	.fill_info	= vti6_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 213546bd6d5d..3cc197c72b59 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1763,6 +1763,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
 	.dellink	= ipip6_dellink,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
-- 
2.2.2
