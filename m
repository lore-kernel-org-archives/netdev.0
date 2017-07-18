From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next v2 1/1] geneve: add rtnl changelink support
Date: Tue, 18 Jul 2017 16:33:06 -0700
Message-ID: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
To: <pshelar@ovn.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34441 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752102AbdGRXm7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 19:42:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds changelink rtnl operation support for geneve devices
and the code changes involve:

  - add geneve_quiesce() which quiesces the geneve device data path
    for both TX and RX. This lets us perform the changelink operation
    atomically w.r.t data path. Also add geneve_unquiesce() to
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
v0 -> v1:
   - added geneve_quiesce() and geneve_unquiesce() functions to
     perform the changelink operation atomically w.r.t data path
---
 drivers/net/geneve.c | 192 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 157 insertions(+), 35 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index de8156c..829f541 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -827,6 +827,9 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	__be16 df;
 	int err;
 
+	if (!gs4)
+		return -EIO;
+
 	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
@@ -866,6 +869,9 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	__be16 sport;
 	int err;
 
+	if (!gs6)
+		return -EIO;
+
 	dst = geneve_get_v6_dst(skb, dev, &fl6, info);
 	if (IS_ERR(dst))
 		return PTR_ERR(dst);
@@ -1140,6 +1146,15 @@ static bool is_tnl_info_zero(const struct ip_tunnel_info *info)
 		return true;
 }
 
+static inline bool geneve_dst_addr_equal(struct ip_tunnel_info *a,
+					 struct ip_tunnel_info *b)
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
@@ -1197,24 +1212,22 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
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
@@ -1222,21 +1235,24 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 
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
@@ -1245,48 +1261,153 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
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
+
+	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
+		if (changelink)
+			return -EOPNOTSUPP;
+		if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
+			*use_udp6_rx_checksums = false;
+	}
+
+	return 0;
+}
 
-	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX] &&
-	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
-		use_udp6_rx_checksums = false;
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
 
+/* Quiesces the geneve device data path for both TX and RX. */
+static inline void geneve_quiesce(struct geneve_dev *geneve,
+				  struct geneve_sock **gs4,
+				  struct geneve_sock **gs6)
+{
+	*gs4 = rtnl_dereference(geneve->sock4);
+	rcu_assign_pointer(geneve->sock4, NULL);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	*gs6 = rtnl_dereference(geneve->sock6);
+	rcu_assign_pointer(geneve->sock6, NULL);
+#else
+	*gs6 = NULL;
+#endif
+	synchronize_net();
+}
+
+/* Resumes the geneve device data path for both TX and RX. */
+static inline void geneve_unquiesce(struct geneve_dev *geneve,
+				    struct geneve_sock *gs4,
+				    struct geneve_sock __maybe_unused *gs6)
+{
+	rcu_assign_pointer(geneve->sock4, gs4);
+#if IS_ENABLED(CONFIG_IPV6)
+	rcu_assign_pointer(geneve->sock6, gs6);
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
@@ -1375,6 +1496,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	.setup		= geneve_setup,
 	.validate	= geneve_validate,
 	.newlink	= geneve_newlink,
+	.changelink	= geneve_changelink,
 	.dellink	= geneve_dellink,
 	.get_size	= geneve_get_size,
 	.fill_info	= geneve_fill_info,
-- 
1.8.3.1
