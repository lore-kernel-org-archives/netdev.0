From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 5/7] net: add dst_cache to ovs vxlan lwtunnel
Date: Fri, 12 Feb 2016 15:43:57 +0100
Message-ID: <46362baeaba562ce72ace9570fbf0855b2b6547b.1455287867.git.pabeni@redhat.com>
References: <cover.1455287867.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbcBLOo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:44:29 -0500
In-Reply-To: <cover.1455287867.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of UDP traffic with datagram length
below MTU this give about 2% performance increase
when tunneling over ipv4 and about 60% when tunneling
over ipv6

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

---
v2: move the dst_cache inside the dst_metadata, so that it's
properly refcounted upon usage; remove unneeded dst_cache
check on lookup
---
 drivers/net/vxlan.c            | 15 ++++++++-------
 include/net/dst_metadata.h     |  1 +
 include/net/ip_tunnels.h       |  3 +++
 net/core/dst.c                 | 10 +++++++++-
 net/openvswitch/Kconfig        |  1 +
 net/openvswitch/flow_netlink.c |  6 ++++++
 6 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5723b64..5912233 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1777,7 +1777,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 	/* when the ip_tunnel_info is availble, the tos used for lookup is
 	 * packet independent, so we can use the cache
 	 */
-	if (dst_cache && !skb->mark && (!tos || info)) {
+	if (!skb->mark && (!tos || info)) {
 		use_cache = true;
 		rt = dst_cache_get_ip4(dst_cache, saddr);
 		if (rt)
@@ -1808,13 +1808,11 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct in6_addr *saddr,
 					  struct dst_cache *dst_cache)
 {
-	bool use_cache = false;
 	struct dst_entry *ndst;
 	struct flowi6 fl6;
 	int err;
 
-	if (dst_cache && !skb->mark) {
-		use_cache = true;
+	if (!skb->mark) {
 		ndst = dst_cache_get_ip6(dst_cache, saddr);
 		if (ndst)
 			return ndst;
@@ -1834,7 +1832,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 		return ERR_PTR(err);
 
 	*saddr = fl6.saddr;
-	if (use_cache)
+	if (!skb->mark)
 		dst_cache_set_ip6(dst_cache, ndst, saddr);
 	return ndst;
 }
@@ -1888,6 +1886,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
+	struct dst_cache *dst_cache;
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk;
@@ -1912,6 +1911,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = rdst->remote_vni;
 		dst = &rdst->remote_ip;
+		dst_cache = &rdst->dst_cache;
 	} else {
 		if (!info) {
 			WARN_ONCE(1, "%s: Missing encapsulation instructions\n",
@@ -1926,6 +1926,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		else
 			remote_ip.sin6.sin6_addr = info->key.u.ipv6.dst;
 		dst = &remote_ip;
+		dst_cache = &info->dst_cache;
 	}
 
 	if (vxlan_addr_any(dst)) {
@@ -1978,7 +1979,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		rt = vxlan_get_route(vxlan, skb,
 				     rdst ? rdst->remote_ifindex : 0, tos,
 				     dst->sin.sin_addr.s_addr, &saddr,
-				     rdst ? &rdst->dst_cache : NULL, info);
+				     dst_cache, info);
 		if (IS_ERR(rt)) {
 			netdev_dbg(dev, "no route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
@@ -2031,7 +2032,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		ndst = vxlan6_get_route(vxlan, skb,
 					rdst ? rdst->remote_ifindex : 0,
 					&dst->sin6.sin6_addr, &saddr,
-					rdst ? &rdst->dst_cache : NULL);
+					dst_cache);
 		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
 				   &dst->sin6.sin6_addr);
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 30a56ab..84b833a 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -62,6 +62,7 @@ static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
 		      sizeof(a->u.tun_info) + a->u.tun_info.options_len);
 }
 
+void metadata_dst_free(struct metadata_dst *);
 struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
 struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d66797e..12b3a20 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -58,6 +58,9 @@ struct ip_tunnel_key {
 
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
+#ifdef CONFIG_DST_CACHE
+	struct dst_cache	dst_cache;
+#endif
 	u8			options_len;
 	u8			mode;
 };
diff --git a/net/core/dst.c b/net/core/dst.c
index a1656e3..b5cbbe0 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -265,7 +265,7 @@ again:
 	lwtstate_put(dst->lwtstate);
 
 	if (dst->flags & DST_METADATA)
-		kfree(dst);
+		metadata_dst_free((struct metadata_dst *)dst);
 	else
 		kmem_cache_free(dst->ops->kmem_cachep, dst);
 
@@ -395,6 +395,14 @@ struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags)
 }
 EXPORT_SYMBOL_GPL(metadata_dst_alloc);
 
+void metadata_dst_free(struct metadata_dst *md_dst)
+{
+#ifdef CONFIG_DST_CACHE
+	dst_cache_destroy(&md_dst->u.tun_info.dst_cache);
+#endif
+	kfree(md_dst);
+}
+
 struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags)
 {
 	int cpu;
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index d143aa9..cd5fd9d 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -10,6 +10,7 @@ config OPENVSWITCH
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
+	select DST_CACHE
 	---help---
 	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
 	  environments.  In addition to supporting a variety of features
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d1bd4a4..58b8efc 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1959,6 +1959,12 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (!tun_dst)
 		return -ENOMEM;
 
+	err = dst_cache_init(&tun_dst->u.tun_info.dst_cache, GFP_KERNEL);
+	if (err) {
+		dst_release((struct dst_entry *)tun_dst);
+		return err;
+	}
+
 	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
 			 sizeof(*ovs_tun), log);
 	if (IS_ERR(a)) {
-- 
1.8.3.1
