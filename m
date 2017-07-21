From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next v3 1/1] geneve: add rtnl changelink support
Date: Thu, 20 Jul 2017 22:44:20 -0700
Message-ID: <1500615860-7081-1-git-send-email-girish.moodalbail@oracle.com>
To: <pshelar@ovn.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20320 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdGUFyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 01:54:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds changelink rtnl operation support for geneve devices
and the code changes involve:

  - added geneve_quiesce() which quiesces the geneve device data path
    for both TX and RX. This lets us perform the changelink operation
    atomically w.r.t data path. Also added geneve_unquiesce() to
    reverse the operation of geneve_quiesce().

  - refactor geneve_newlink into geneve_nl2info to be used by both
    geneve_newlink and geneve_changelink

  - geneve_nl2info takes a changelink boolean argument to isolate
    changelink checks.

  - Allow changing only a few attributes (ttl, tos, and remote tunnel
    endpoint IP address (within the same address family)):
    - return -EOPNOTSUPP for attributes that cannot be changed for
      now. Incremental patches can make the non-supported one
      available in the future if needed.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
v2 -> v3:
   - removed the use of inline for new functions in my patch
   - removed an extra check for socket in the datapath and instead
     I am piggybacking on an already existing check
   - added more comments to quiesce/unquiesce functions

v1 -> v2:
   - added geneve_quiesce() and geneve_unquiesce() functions to
     perform the changelink operation atomically w.r.t data path
---
---
 drivers/net/geneve.c | 218 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 176 insertions(+), 42 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index de8156c..0436a42 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -715,6 +715,7 @@ static int geneve_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 
 static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 				       struct net_device *dev,
+				       struct geneve_sock *gs4,
 				       struct flowi4 *fl4,
 				       const struct ip_tunnel_info *info)
 {
@@ -724,7 +725,7 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 	struct rtable *rt = NULL;
 	__u8 tos;
 
-	if (!rcu_dereference(geneve->sock4))
+	if (!gs4)
 		return ERR_PTR(-EIO);
 
 	memset(fl4, 0, sizeof(*fl4));
@@ -764,6 +765,7 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 					   struct net_device *dev,
+					   struct geneve_sock *gs6,
 					   struct flowi6 *fl6,
 					   const struct ip_tunnel_info *info)
 {
@@ -771,10 +773,8 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct dst_entry *dst = NULL;
 	struct dst_cache *dst_cache;
-	struct geneve_sock *gs6;
 	__u8 prio;
 
-	gs6 = rcu_dereference(geneve->sock6);
 	if (!gs6)
 		return ERR_PTR(-EIO);
 
@@ -827,7 +827,7 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	__be16 df;
 	int err;
 
-	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
+	rt = geneve_get_v4_rt(skb, dev, gs4, &fl4, info);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
@@ -866,7 +866,7 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	__be16 sport;
 	int err;
 
-	dst = geneve_get_v6_dst(skb, dev, &fl6, info);
+	dst = geneve_get_v6_dst(skb, dev, gs6, &fl6, info);
 	if (IS_ERR(dst))
 		return PTR_ERR(dst);
 
@@ -951,8 +951,9 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	if (ip_tunnel_info_af(info) == AF_INET) {
 		struct rtable *rt;
 		struct flowi4 fl4;
+		struct geneve_sock *gs4 = rcu_dereference(geneve->sock4);
 
-		rt = geneve_get_v4_rt(skb, dev, &fl4, info);
+		rt = geneve_get_v4_rt(skb, dev, gs4, &fl4, info);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 
@@ -962,8 +963,9 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	} else if (ip_tunnel_info_af(info) == AF_INET6) {
 		struct dst_entry *dst;
 		struct flowi6 fl6;
+		struct geneve_sock *gs6 = rcu_dereference(geneve->sock6);
 
-		dst = geneve_get_v6_dst(skb, dev, &fl6, info);
+		dst = geneve_get_v6_dst(skb, dev, gs6, &fl6, info);
 		if (IS_ERR(dst))
 			return PTR_ERR(dst);
 
@@ -1140,6 +1142,15 @@ static bool is_tnl_info_zero(const struct ip_tunnel_info *info)
 		return true;
 }
 
+static bool geneve_dst_addr_equal(struct ip_tunnel_info *a,
+				  struct ip_tunnel_info *b)
+{
+	if (ip_tunnel_info_af(a) == AF_INET)
+		return a->key.u.ipv4.dst == b->key.u.ipv4.dst;
+	else
+		return ipv6_addr_equal(&a->key.u.ipv6.dst, &b->key.u.ipv6.dst);
+}
+
 static int geneve_configure(struct net *net, struct net_device *dev,
 			    const struct ip_tunnel_info *info,
 			    bool metadata, bool ipv6_rx_csum)
@@ -1197,24 +1208,22 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
 	info->key.tp_dst = htons(dst_port);
 }
 
-static int geneve_newlink(struct net *net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[],
-			  struct netlink_ext_ack *extack)
+static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
+			  struct nlattr *data[], struct ip_tunnel_info *info,
+			  bool *metadata, bool *use_udp6_rx_checksums,
+			  bool changelink)
 {
-	bool use_udp6_rx_checksums = false;
-	struct ip_tunnel_info info;
-	bool metadata = false;
-
-	init_tnl_info(&info, GENEVE_UDP_PORT);
-
 	if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
 		return -EINVAL;
 
 	if (data[IFLA_GENEVE_REMOTE]) {
-		info.key.u.ipv4.dst =
+		if (changelink && (ip_tunnel_info_af(info) == AF_INET6))
+			return -EOPNOTSUPP;
+
+		info->key.u.ipv4.dst =
 			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
 
-		if (IN_MULTICAST(ntohl(info.key.u.ipv4.dst))) {
+		if (IN_MULTICAST(ntohl(info->key.u.ipv4.dst))) {
 			netdev_dbg(dev, "multicast remote is unsupported\n");
 			return -EINVAL;
 		}
@@ -1222,21 +1231,24 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 
 	if (data[IFLA_GENEVE_REMOTE6]) {
  #if IS_ENABLED(CONFIG_IPV6)
-		info.mode = IP_TUNNEL_INFO_IPV6;
-		info.key.u.ipv6.dst =
+		if (changelink && (ip_tunnel_info_af(info) == AF_INET))
+			return -EOPNOTSUPP;
+
+		info->mode = IP_TUNNEL_INFO_IPV6;
+		info->key.u.ipv6.dst =
 			nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);
 
-		if (ipv6_addr_type(&info.key.u.ipv6.dst) &
+		if (ipv6_addr_type(&info->key.u.ipv6.dst) &
 		    IPV6_ADDR_LINKLOCAL) {
 			netdev_dbg(dev, "link-local remote is unsupported\n");
 			return -EINVAL;
 		}
-		if (ipv6_addr_is_multicast(&info.key.u.ipv6.dst)) {
+		if (ipv6_addr_is_multicast(&info->key.u.ipv6.dst)) {
 			netdev_dbg(dev, "multicast remote is unsupported\n");
 			return -EINVAL;
 		}
-		info.key.tun_flags |= TUNNEL_CSUM;
-		use_udp6_rx_checksums = true;
+		info->key.tun_flags |= TUNNEL_CSUM;
+		*use_udp6_rx_checksums = true;
 #else
 		return -EPFNOSUPPORT;
 #endif
@@ -1245,48 +1257,169 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_GENEVE_ID]) {
 		__u32 vni;
 		__u8 tvni[3];
+		__be64 tunid;
 
 		vni = nla_get_u32(data[IFLA_GENEVE_ID]);
 		tvni[0] = (vni & 0x00ff0000) >> 16;
 		tvni[1] = (vni & 0x0000ff00) >> 8;
 		tvni[2] =  vni & 0x000000ff;
 
-		info.key.tun_id = vni_to_tunnel_id(tvni);
+		tunid = vni_to_tunnel_id(tvni);
+		if (changelink && (tunid != info->key.tun_id))
+			return -EOPNOTSUPP;
+		info->key.tun_id = tunid;
 	}
+
 	if (data[IFLA_GENEVE_TTL])
-		info.key.ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
+		info->key.ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
 
 	if (data[IFLA_GENEVE_TOS])
-		info.key.tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
+		info->key.tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
 
 	if (data[IFLA_GENEVE_LABEL]) {
-		info.key.label = nla_get_be32(data[IFLA_GENEVE_LABEL]) &
+		info->key.label = nla_get_be32(data[IFLA_GENEVE_LABEL]) &
 				  IPV6_FLOWLABEL_MASK;
-		if (info.key.label && (!(info.mode & IP_TUNNEL_INFO_IPV6)))
+		if (info->key.label && (!(info->mode & IP_TUNNEL_INFO_IPV6)))
 			return -EINVAL;
 	}
 
-	if (data[IFLA_GENEVE_PORT])
-		info.key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
+	if (data[IFLA_GENEVE_PORT]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		info->key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
+	}
 
-	if (data[IFLA_GENEVE_COLLECT_METADATA])
-		metadata = true;
+	if (data[IFLA_GENEVE_COLLECT_METADATA]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		*metadata = true;
+	}
 
-	if (data[IFLA_GENEVE_UDP_CSUM] &&
-	    nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
-		info.key.tun_flags |= TUNNEL_CSUM;
+	if (data[IFLA_GENEVE_UDP_CSUM]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
+			info->key.tun_flags |= TUNNEL_CSUM;
+	}
 
-	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
-	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
-		info.key.tun_flags &= ~TUNNEL_CSUM;
+	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
+			info->key.tun_flags &= ~TUNNEL_CSUM;
+	}
 
-	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX] &&
-	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
-		use_udp6_rx_checksums = false;
+	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
+			*use_udp6_rx_checksums = false;
+	}
+
+	return 0;
+}
+
+static int geneve_newlink(struct net *net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
+{
+	bool use_udp6_rx_checksums = false;
+	struct ip_tunnel_info info;
+	bool metadata = false;
+	int err;
+
+	init_tnl_info(&info, GENEVE_UDP_PORT);
+	err = geneve_nl2info(dev, tb, data, &info, &metadata,
+			     &use_udp6_rx_checksums, false);
+	if (err)
+		return err;
 
 	return geneve_configure(net, dev, &info, metadata, use_udp6_rx_checksums);
 }
 
+/* Quiesces the geneve device data path for both TX and RX.
+ *
+ * On transmit geneve checks for non-NULL geneve_sock before it proceeds.
+ * So, if we set that socket to NULL under RCU and wait for synchronize_net()
+ * to complete for the existing set of in-flight packets to be transmitted,
+ * then we would have quiesced the transmit data path. All the future packets
+ * will get dropped until we unquiesce the data path.
+ *
+ * On receive geneve dereference the geneve_sock stashed in the socket. So,
+ * if we set that to NULL under RCU and wait for synchronize_net() to
+ * complete, then we would have quiesced the receive data path.
+ */
+static void geneve_quiesce(struct geneve_dev *geneve, struct geneve_sock **gs4,
+			   struct geneve_sock **gs6)
+{
+	*gs4 = rtnl_dereference(geneve->sock4);
+	rcu_assign_pointer(geneve->sock4, NULL);
+	if (*gs4)
+		rcu_assign_sk_user_data((*gs4)->sock->sk, NULL);
+#if IS_ENABLED(CONFIG_IPV6)
+	*gs6 = rtnl_dereference(geneve->sock6);
+	rcu_assign_pointer(geneve->sock6, NULL);
+	if (*gs6)
+		rcu_assign_sk_user_data((*gs6)->sock->sk, NULL);
+#else
+	*gs6 = NULL;
+#endif
+	synchronize_net();
+}
+
+/* Resumes the geneve device data path for both TX and RX. */
+static void geneve_unquiesce(struct geneve_dev *geneve, struct geneve_sock *gs4,
+			     struct geneve_sock __maybe_unused *gs6)
+{
+	rcu_assign_pointer(geneve->sock4, gs4);
+	if (gs4)
+		rcu_assign_sk_user_data(gs4->sock->sk, gs4);
+#if IS_ENABLED(CONFIG_IPV6)
+	rcu_assign_pointer(geneve->sock6, gs6);
+	if (gs6)
+		rcu_assign_sk_user_data(gs6->sock->sk, gs6);
+#endif
+	synchronize_net();
+}
+
+static int geneve_changelink(struct net_device *dev, struct nlattr *tb[],
+			     struct nlattr *data[],
+			     struct netlink_ext_ack *extack)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs4, *gs6;
+	struct ip_tunnel_info info;
+	bool metadata;
+	bool use_udp6_rx_checksums;
+	int err;
+
+	/* If the geneve device is configured for metadata (or externally
+	 * controlled, for example, OVS), then nothing can be changed.
+	 */
+	if (geneve->collect_md)
+		return -EOPNOTSUPP;
+
+	/* Start with the existing info. */
+	memcpy(&info, &geneve->info, sizeof(info));
+	metadata = geneve->collect_md;
+	use_udp6_rx_checksums = geneve->use_udp6_rx_checksums;
+	err = geneve_nl2info(dev, tb, data, &info, &metadata,
+			     &use_udp6_rx_checksums, true);
+	if (err)
+		return err;
+
+	if (!geneve_dst_addr_equal(&geneve->info, &info))
+		dst_cache_reset(&info.dst_cache);
+
+	geneve_quiesce(geneve, &gs4, &gs6);
+	geneve->info = info;
+	geneve->collect_md = metadata;
+	geneve->use_udp6_rx_checksums = use_udp6_rx_checksums;
+	geneve_unquiesce(geneve, gs4, gs6);
+
+	return 0;
+}
+
 static void geneve_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
@@ -1375,6 +1508,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	.setup		= geneve_setup,
 	.validate	= geneve_validate,
 	.newlink	= geneve_newlink,
+	.changelink	= geneve_changelink,
 	.dellink	= geneve_dellink,
 	.get_size	= geneve_get_size,
 	.fill_info	= geneve_fill_info,
-- 
1.8.3.1
