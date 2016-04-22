From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/9] libnl: nla_put_net64(): align on a 64-bit area
Date: Fri, 22 Apr 2016 17:31:19 +0200
Message-ID: <1461339084-3849-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53583 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbcDVPcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:04 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_data() is now aligned on a 64-bit area.

The temporary function nla_put_be64_32bit() is removed in this patch.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netfilter/ipset/ip_set.h      |  9 ++++++---
 include/net/netlink.h                       | 14 ++++++--------
 include/uapi/linux/netfilter/ipset/ip_set.h |  1 +
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index f48b8a664b0f..83b9a2e0d8d4 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -351,7 +351,8 @@ ip_set_put_skbinfo(struct sk_buff *skb, struct ip_set_skbinfo *skbinfo)
 	return ((skbinfo->skbmark || skbinfo->skbmarkmask) &&
 		nla_put_net64(skb, IPSET_ATTR_SKBMARK,
 			      cpu_to_be64((u64)skbinfo->skbmark << 32 |
-					  skbinfo->skbmarkmask))) ||
+					  skbinfo->skbmarkmask),
+			      IPSET_ATTR_PAD)) ||
 	       (skbinfo->skbprio &&
 		nla_put_net32(skb, IPSET_ATTR_SKBPRIO,
 			      cpu_to_be32(skbinfo->skbprio))) ||
@@ -374,9 +375,11 @@ static inline bool
 ip_set_put_counter(struct sk_buff *skb, struct ip_set_counter *counter)
 {
 	return nla_put_net64(skb, IPSET_ATTR_BYTES,
-			     cpu_to_be64(ip_set_get_bytes(counter))) ||
+			     cpu_to_be64(ip_set_get_bytes(counter)),
+			     IPSET_ATTR_PAD) ||
 	       nla_put_net64(skb, IPSET_ATTR_PACKETS,
-			     cpu_to_be64(ip_set_get_packets(counter)));
+			     cpu_to_be64(ip_set_get_packets(counter)),
+			     IPSET_ATTR_PAD);
 }
 
 static inline void
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 47d7d1356fa3..066a921e7cbe 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -868,20 +868,18 @@ static inline int nla_put_be64(struct sk_buff *skb, int attrtype, __be64 value,
 	return nla_put_64bit(skb, attrtype, sizeof(__be64), &value, padattr);
 }
 
-static inline int nla_put_be64_32bit(struct sk_buff *skb, int attrtype,
-				     __be64 value)
-{
-	return nla_put(skb, attrtype, sizeof(__be64), &value);
-}
 /**
- * nla_put_net64 - Add 64-bit network byte order netlink attribute to a socket buffer
+ * nla_put_net64 - Add 64-bit network byte order nlattr to a skb and align it
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
  * @value: numeric value
+ * @padattr: attribute type for the padding
  */
-static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value)
+static inline int nla_put_net64(struct sk_buff *skb, int attrtype, __be64 value,
+				int padattr)
 {
-	return nla_put_be64_32bit(skb, attrtype | NLA_F_NET_BYTEORDER, value);
+	return nla_put_be64(skb, attrtype | NLA_F_NET_BYTEORDER, value,
+			    padattr);
 }
 
 /**
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index 63b2e34f1b60..ebb5154976de 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -118,6 +118,7 @@ enum {
 	IPSET_ATTR_SKBMARK,
 	IPSET_ATTR_SKBPRIO,
 	IPSET_ATTR_SKBQUEUE,
+	IPSET_ATTR_PAD,
 	__IPSET_ATTR_ADT_MAX,
 };
 #define IPSET_ATTR_ADT_MAX	(__IPSET_ATTR_ADT_MAX - 1)
-- 
2.8.1
