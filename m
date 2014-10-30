From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 3/4] iptunnels: advertise link netns via netlink
Date: Thu, 30 Oct 2014 16:25:27 +0100
Message-ID: <1414682728-4532-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
	<1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1414682728-4532-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Implement rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
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
 10 files changed, 26 insertions(+)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index a5593dab6af7..8648519f4555 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -69,6 +69,7 @@ int ip6_tnl_xmit_ctl(struct ip6_tnl *t);
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
+struct net *ip6_tnl_get_link_net(const struct net_device *dev);
 
 static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 5bc6edeb7143..ce4ff6161fab 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -122,6 +122,7 @@ struct ip_tunnel_net {
 int ip_tunnel_init(struct net_device *dev);
 void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
+struct net *ip_tunnel_get_link_net(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 12055fdbe716..9e2e29a8c989 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -827,6 +827,7 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
@@ -841,6 +842,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __net_init ipgre_tap_init_net(struct net *net)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0bb8e141eacc..3e1edd544b27 100644
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
index 3e861011e4a3..f0fab26e4ddc 100644
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
index 37096d64730e..e7a183baba0a 100644
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
index 12c3c8ef3849..5165ac7fde22 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1661,6 +1661,7 @@ static struct rtnl_link_ops ip6gre_link_ops __read_mostly = {
 	.dellink	= ip6gre_dellink,
 	.get_size	= ip6gre_get_size,
 	.fill_info	= ip6gre_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 static struct rtnl_link_ops ip6gre_tap_ops __read_mostly = {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9409887fb664..6b2534ea9c54 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1703,6 +1703,14 @@ nla_put_failure:
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
@@ -1726,6 +1734,7 @@ static struct rtnl_link_ops ip6_link_ops __read_mostly = {
 	.dellink	= ip6_tnl_dellink,
 	.get_size	= ip6_tnl_get_size,
 	.fill_info	= ip6_tnl_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d440bb585524..43966dcc9603 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -992,6 +992,7 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
 	.changelink	= vti6_changelink,
 	.get_size	= vti6_get_size,
 	.fill_info	= vti6_fill_info,
+	.get_link_net	= ip6_tnl_get_link_net,
 };
 
 static void __net_exit vti6_destroy_tunnels(struct vti6_net *ip6n)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 58e5b4710127..c858d0eb267a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1765,6 +1765,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
 	.dellink	= ipip6_dellink,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
-- 
2.1.0
