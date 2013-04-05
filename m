From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/3] netfilter: ipv6: propagate routing errors from ip6_route_me_harder()
Date: Fri,  5 Apr 2013 18:41:11 +0200
Message-ID: <1365180072-6182-3-git-send-email-kaber@trash.net>
References: <1365180072-6182-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162051Ab3DEQl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 12:41:27 -0400
In-Reply-To: <1365180072-6182-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate routing errors from ip_route_me_harder() when dropping a packet
using NF_DROP_ERR(). This makes userspace get the proper error instead of
EPERM for everything.

# ip -6 r a unreachable default table 100
# ip -6 ru add fwmark 0x1 lookup 100
# ip6tables -t mangle -A OUTPUT -d 2001:4860:4860::8888 -j MARK --set-mark 0x1

Old behaviour:

PING 2001:4860:4860::8888(2001:4860:4860::8888) 56 data bytes
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted

New behaviour:

PING 2001:4860:4860::8888(2001:4860:4860::8888) 56 data bytes
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter.c                 | 6 +++---
 net/ipv6/netfilter/ip6table_mangle.c | 9 ++++++---
 net/ipv6/netfilter/ip6table_nat.c    | 6 ++++--
 3 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 429089c..fc5fbd7 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -29,7 +29,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
 		dst_release(dst);
-		return -EINVAL;
+		return dst->error;
 	}
 
 	/* Drop old route. */
@@ -43,7 +43,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		skb_dst_set(skb, NULL);
 		dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), skb->sk, 0);
 		if (IS_ERR(dst))
-			return -1;
+			return PTR_ERR(dst);
 		skb_dst_set(skb, dst);
 	}
 #endif
@@ -53,7 +53,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	if (skb_headroom(skb) < hh_len &&
 	    pskb_expand_head(skb, HH_DATA_ALIGN(hh_len - skb_headroom(skb)),
 			     0, GFP_ATOMIC))
-		return -1;
+		return -ENOMEM;
 
 	return 0;
 }
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 6134a1e..e075399 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -38,7 +38,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	struct in6_addr saddr, daddr;
 	u_int8_t hop_limit;
 	u_int32_t flowlabel, mark;
-
+	int err;
 #if 0
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
@@ -65,8 +65,11 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	     !ipv6_addr_equal(&ipv6_hdr(skb)->daddr, &daddr) ||
 	     skb->mark != mark ||
 	     ipv6_hdr(skb)->hop_limit != hop_limit ||
-	     flowlabel != *((u_int32_t *)ipv6_hdr(skb))))
-		return ip6_route_me_harder(skb) == 0 ? ret : NF_DROP;
+	     flowlabel != *((u_int32_t *)ipv6_hdr(skb)))) {
+		err = ip6_route_me_harder(skb);
+		if (err < 0)
+			ret = NF_DROP_ERR(err);
+	}
 
 	return ret;
 }
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index e0e788d..97e2edd 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -215,6 +215,7 @@ nf_nat_ipv6_local_fn(unsigned int hooknum,
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
+	int err;
 
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct ipv6hdr))
@@ -227,8 +228,9 @@ nf_nat_ipv6_local_fn(unsigned int hooknum,
 
 		if (!nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3,
 				      &ct->tuplehash[!dir].tuple.src.u3)) {
-			if (ip6_route_me_harder(skb))
-				ret = NF_DROP;
+			err = ip6_route_me_harder(skb);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
 		}
 #ifdef CONFIG_XFRM
 		else if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
-- 
1.8.1.4
