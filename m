From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next] geneve: use netlink_ext_ack for error reporting in rtnl operations
Date: Wed,  9 Aug 2017 01:09:28 -0700
Message-ID: <1502266168-12107-1-git-send-email-girish.moodalbail@oracle.com>
To: <pshelar@ovn.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33302 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752442AbdHIIWH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 04:22:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack error messages for failure paths while creating/modifying
geneve devices. Once extack support is added to iproute2, more
meaningful and helpful error messages will be displayed making it easy
for users to discern what went wrong.

Before:
=======
$ ip link add gen1 address 0:1:2:3:4:5:6 type geneve id 200 \
  remote 192.168.13.2
RTNETLINK answers: Invalid argument

After:
======
$ ip link add gen1 address 0:1:2:3:4:5:6 type geneve id 200 \
  remote 192.168.13.2
Error: Provided link layer address is not Ethernet

Also, netdev_dbg() calls used to log errors associated with Netlink
request have been removed.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/geneve.c | 128 ++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 92 insertions(+), 36 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 745d57ae..977dbcc 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1086,21 +1086,33 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[],
 			   struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
-		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
+					    "Provided link layer address is not Ethernet");
 			return -EINVAL;
+		}
 
-		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
+			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
+					    "Provided Ethernet address is not unicast");
 			return -EADDRNOTAVAIL;
+		}
 	}
 
-	if (!data)
+	if (!data) {
+		NL_SET_ERR_MSG(extack,
+			       "Not enough attributes provided to perform the operation");
 		return -EINVAL;
+	}
 
 	if (data[IFLA_GENEVE_ID]) {
 		__u32 vni =  nla_get_u32(data[IFLA_GENEVE_ID]);
 
-		if (vni >= GENEVE_VID_MASK)
+		if (vni >= GENEVE_VID_MASK) {
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_GENEVE_ID],
+					    "Geneve ID must be lower than 16777216");
 			return -ERANGE;
+		}
 	}
 
 	return 0;
@@ -1158,6 +1170,7 @@ static bool geneve_dst_addr_equal(struct ip_tunnel_info *a,
 }
 
 static int geneve_configure(struct net *net, struct net_device *dev,
+			    struct netlink_ext_ack *extack,
 			    const struct ip_tunnel_info *info,
 			    bool metadata, bool ipv6_rx_csum)
 {
@@ -1166,8 +1179,11 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	bool tun_collect_md, tun_on_same_port;
 	int err, encap_len;
 
-	if (metadata && !is_tnl_info_zero(info))
+	if (metadata && !is_tnl_info_zero(info)) {
+		NL_SET_ERR_MSG(extack,
+			       "Device is externally controlled, so attributes (VNI, Port, and so on) must not be specified");
 		return -EINVAL;
+	}
 
 	geneve->net = net;
 	geneve->dev = dev;
@@ -1188,11 +1204,17 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	dev->needed_headroom = encap_len + ETH_HLEN;
 
 	if (metadata) {
-		if (tun_on_same_port)
+		if (tun_on_same_port) {
+			NL_SET_ERR_MSG(extack,
+				       "There can be only one externally controlled device on a destination port");
 			return -EPERM;
+		}
 	} else {
-		if (tun_collect_md)
+		if (tun_collect_md) {
+			NL_SET_ERR_MSG(extack,
+				       "There already exists an externally controlled device on this destination port");
 			return -EPERM;
+		}
 	}
 
 	dst_cache_reset(&geneve->info.dst_cache);
@@ -1214,31 +1236,41 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
 	info->key.tp_dst = htons(dst_port);
 }
 
-static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
-			  struct nlattr *data[], struct ip_tunnel_info *info,
-			  bool *metadata, bool *use_udp6_rx_checksums,
-			  bool changelink)
+static int geneve_nl2info(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack,
+			  struct ip_tunnel_info *info, bool *metadata,
+			  bool *use_udp6_rx_checksums, bool changelink)
 {
-	if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
+	int attrtype;
+
+	if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6]) {
+		NL_SET_ERR_MSG(extack,
+			       "Cannot specify both IPv4 and IPv6 Remote addresses");
 		return -EINVAL;
+	}
 
 	if (data[IFLA_GENEVE_REMOTE]) {
-		if (changelink && (ip_tunnel_info_af(info) == AF_INET6))
-			return -EOPNOTSUPP;
+		if (changelink && (ip_tunnel_info_af(info) == AF_INET6)) {
+			attrtype = IFLA_GENEVE_REMOTE;
+			goto change_notsup;
+		}
 
 		info->key.u.ipv4.dst =
 			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
 
 		if (IN_MULTICAST(ntohl(info->key.u.ipv4.dst))) {
-			netdev_dbg(dev, "multicast remote is unsupported\n");
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_GENEVE_REMOTE],
+					    "Remote IPv4 address cannot be Multicast");
 			return -EINVAL;
 		}
 	}
 
 	if (data[IFLA_GENEVE_REMOTE6]) {
  #if IS_ENABLED(CONFIG_IPV6)
-		if (changelink && (ip_tunnel_info_af(info) == AF_INET))
-			return -EOPNOTSUPP;
+		if (changelink && (ip_tunnel_info_af(info) == AF_INET)) {
+			attrtype = IFLA_GENEVE_REMOTE6;
+			goto change_notsup;
+		}
 
 		info->mode = IP_TUNNEL_INFO_IPV6;
 		info->key.u.ipv6.dst =
@@ -1246,16 +1278,20 @@ static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
 
 		if (ipv6_addr_type(&info->key.u.ipv6.dst) &
 		    IPV6_ADDR_LINKLOCAL) {
-			netdev_dbg(dev, "link-local remote is unsupported\n");
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_GENEVE_REMOTE6],
+					    "Remote IPv6 address cannot be link-local");
 			return -EINVAL;
 		}
 		if (ipv6_addr_is_multicast(&info->key.u.ipv6.dst)) {
-			netdev_dbg(dev, "multicast remote is unsupported\n");
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_GENEVE_REMOTE6],
+					    "Remote IPv6 address cannot be Multicast");
 			return -EINVAL;
 		}
 		info->key.tun_flags |= TUNNEL_CSUM;
 		*use_udp6_rx_checksums = true;
 #else
+		NL_SET_ERR_MSG_ATTR(extack, data[IFLA_GENEVE_REMOTE6],
+				    "IPv6 support not enabled in the kernel");
 		return -EPFNOSUPPORT;
 #endif
 	}
@@ -1271,8 +1307,10 @@ static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
 		tvni[2] =  vni & 0x000000ff;
 
 		tunid = vni_to_tunnel_id(tvni);
-		if (changelink && (tunid != info->key.tun_id))
-			return -EOPNOTSUPP;
+		if (changelink && (tunid != info->key.tun_id)) {
+			attrtype = IFLA_GENEVE_ID;
+			goto change_notsup;
+		}
 		info->key.tun_id = tunid;
 	}
 
@@ -1285,44 +1323,61 @@ static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
 	if (data[IFLA_GENEVE_LABEL]) {
 		info->key.label = nla_get_be32(data[IFLA_GENEVE_LABEL]) &
 				  IPV6_FLOWLABEL_MASK;
-		if (info->key.label && (!(info->mode & IP_TUNNEL_INFO_IPV6)))
+		if (info->key.label && (!(info->mode & IP_TUNNEL_INFO_IPV6))) {
+			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_GENEVE_LABEL],
+					    "Label attribute only applies for IPv6 Geneve devices");
 			return -EINVAL;
+		}
 	}
 
 	if (data[IFLA_GENEVE_PORT]) {
-		if (changelink)
-			return -EOPNOTSUPP;
+		if (changelink) {
+			attrtype = IFLA_GENEVE_PORT;
+			goto change_notsup;
+		}
 		info->key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
 	}
 
 	if (data[IFLA_GENEVE_COLLECT_METADATA]) {
-		if (changelink)
-			return -EOPNOTSUPP;
+		if (changelink) {
+			attrtype = IFLA_GENEVE_COLLECT_METADATA;
+			goto change_notsup;
+		}
 		*metadata = true;
 	}
 
 	if (data[IFLA_GENEVE_UDP_CSUM]) {
-		if (changelink)
-			return -EOPNOTSUPP;
+		if (changelink) {
+			attrtype = IFLA_GENEVE_UDP_CSUM;
+			goto change_notsup;
+		}
 		if (nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
 			info->key.tun_flags |= TUNNEL_CSUM;
 	}
 
 	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]) {
-		if (changelink)
-			return -EOPNOTSUPP;
+		if (changelink) {
+			attrtype = IFLA_GENEVE_UDP_ZERO_CSUM6_TX;
+			goto change_notsup;
+		}
 		if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
 			info->key.tun_flags &= ~TUNNEL_CSUM;
 	}
 
 	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
-		if (changelink)
-			return -EOPNOTSUPP;
+		if (changelink) {
+			attrtype = IFLA_GENEVE_UDP_ZERO_CSUM6_RX;
+			goto change_notsup;
+		}
 		if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
 			*use_udp6_rx_checksums = false;
 	}
 
 	return 0;
+change_notsup:
+	NL_SET_ERR_MSG_ATTR(extack, data[attrtype],
+			    "Changing VNI, Port, endpoint IP address family, external, and UDP checksum attributes are not supported");
+	return -EOPNOTSUPP;
 }
 
 static int geneve_newlink(struct net *net, struct net_device *dev,
@@ -1335,12 +1390,13 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	int err;
 
 	init_tnl_info(&info, GENEVE_UDP_PORT);
-	err = geneve_nl2info(dev, tb, data, &info, &metadata,
+	err = geneve_nl2info(tb, data, extack, &info, &metadata,
 			     &use_udp6_rx_checksums, false);
 	if (err)
 		return err;
 
-	return geneve_configure(net, dev, &info, metadata, use_udp6_rx_checksums);
+	return geneve_configure(net, dev, extack, &info, metadata,
+				use_udp6_rx_checksums);
 }
 
 /* Quiesces the geneve device data path for both TX and RX.
@@ -1409,7 +1465,7 @@ static int geneve_changelink(struct net_device *dev, struct nlattr *tb[],
 	memcpy(&info, &geneve->info, sizeof(info));
 	metadata = geneve->collect_md;
 	use_udp6_rx_checksums = geneve->use_udp6_rx_checksums;
-	err = geneve_nl2info(dev, tb, data, &info, &metadata,
+	err = geneve_nl2info(tb, data, extack, &info, &metadata,
 			     &use_udp6_rx_checksums, true);
 	if (err)
 		return err;
@@ -1536,7 +1592,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 		return dev;
 
 	init_tnl_info(&info, dst_port);
-	err = geneve_configure(net, dev, &info, true, true);
+	err = geneve_configure(net, dev, NULL, &info, true, true);
 	if (err) {
 		free_netdev(dev);
 		return ERR_PTR(err);
-- 
1.8.3.1
