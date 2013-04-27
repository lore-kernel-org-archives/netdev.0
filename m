From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/6] vxlan: source compatiablity with IFLA_VXLAN_GROUP (v2)
Date: Sat, 27 Apr 2013 14:31:55 -0700
Message-ID: <20130427213258.362485005@vyatta.com>
References: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52169 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753425Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Content-Disposition: inline; filename=vxlan-header-compat.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Source compatiability for build iproute2 was broken by:
  commit c7995c43facc6e5dea4de63fa9d283a337aabeb1
  Author: Atzm Watanabe <atzm@stratosphere.co.jp>
    vxlan: Allow setting destination to unicast address.

Since this commit has not made it upstream (still net-next),
and better to avoid gratitious changes to exported API's;
go back to original definition, and add a comment.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/uapi/linux/if_link.h	2013-04-27 13:55:37.311404520 -0700
+++ b/include/uapi/linux/if_link.h	2013-04-27 13:59:41.036252411 -0700
@@ -297,7 +297,7 @@ enum macvlan_mode {
 enum {
 	IFLA_VXLAN_UNSPEC,
 	IFLA_VXLAN_ID,
-	IFLA_VXLAN_REMOTE,
+	IFLA_VXLAN_GROUP,	/* group or remote address */
 	IFLA_VXLAN_LINK,
 	IFLA_VXLAN_LOCAL,
 	IFLA_VXLAN_TTL,
--- a/drivers/net/vxlan.c	2013-04-27 13:56:54.050412049 -0700
+++ b/drivers/net/vxlan.c	2013-04-27 13:59:41.040252358 -0700
@@ -1324,7 +1324,7 @@ static void vxlan_setup(struct net_devic
 
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
-	[IFLA_VXLAN_REMOTE]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
 	[IFLA_VXLAN_LINK]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LOCAL]	= { .len = FIELD_SIZEOF(struct iphdr, saddr) },
 	[IFLA_VXLAN_TOS]	= { .type = NLA_U8 },
@@ -1406,8 +1406,8 @@ static int vxlan_newlink(struct net *net
 	}
 	dst->remote_vni = vni;
 
-	if (data[IFLA_VXLAN_REMOTE])
-		dst->remote_ip = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
+	if (data[IFLA_VXLAN_GROUP])
+		dst->remote_ip = nla_get_be32(data[IFLA_VXLAN_GROUP]);
 
 	if (data[IFLA_VXLAN_LOCAL])
 		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
@@ -1488,7 +1488,7 @@ static size_t vxlan_get_size(const struc
 {
 
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_ID */
-		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_REMOTE */
+		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_GROUP */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LINK */
 		nla_total_size(sizeof(__be32))+	/* IFLA_VXLAN_LOCAL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
@@ -1516,7 +1516,7 @@ static int vxlan_fill_info(struct sk_buf
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, dst->remote_vni))
 		goto nla_put_failure;
 
-	if (dst->remote_ip && nla_put_be32(skb, IFLA_VXLAN_REMOTE, dst->remote_ip))
+	if (dst->remote_ip && nla_put_be32(skb, IFLA_VXLAN_GROUP, dst->remote_ip))
 		goto nla_put_failure;
 
 	if (dst->remote_ifindex && nla_put_u32(skb, IFLA_VXLAN_LINK, dst->remote_ifindex))
