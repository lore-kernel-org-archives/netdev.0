From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/3] netfilter: ipv4: propagate routing errors from ip_route_me_harder()
Date: Fri,  5 Apr 2013 18:41:10 +0200
Message-ID: <1365180072-6182-2-git-send-email-kaber@trash.net>
References: <1365180072-6182-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365180072-6182-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Propagate routing errors from ip_route_me_harder() when dropping a packet
using NF_DROP_ERR(). This makes userspace get the proper error instead of
EPERM for everything.

Example:

# ip r a unreachable default table 100
# ip ru add fwmark 0x1 lookup 100
# iptables -t mangle -A OUTPUT -d 8.8.8.8 -j MARK --set-mark 0x1

Current behaviour:

PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted

New behaviour:

PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable
ping: sendmsg: Network is unreachable

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter.c                | 8 ++++----
 net/ipv4/netfilter/iptable_mangle.c | 9 ++++++---
 net/ipv4/netfilter/iptable_nat.c    | 6 ++++--
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 4c0cf63..8b201e8 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -40,14 +40,14 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 	fl4.flowi4_flags = flags;
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
-		return -1;
+		return PTR_ERR(rt);
 
 	/* Drop old route. */
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
 
 	if (skb_dst(skb)->error)
-		return -1;
+		return skb_dst(skb)->error;
 
 #ifdef CONFIG_XFRM
 	if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
@@ -56,7 +56,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 		skb_dst_set(skb, NULL);
 		dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
 		if (IS_ERR(dst))
-			return -1;
+			return PTR_ERR(dst);;
 		skb_dst_set(skb, dst);
 	}
 #endif
@@ -66,7 +66,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 	if (skb_headroom(skb) < hh_len &&
 	    pskb_expand_head(skb, HH_DATA_ALIGN(hh_len - skb_headroom(skb)),
 				0, GFP_ATOMIC))
-		return -1;
+		return -ENOMEM;
 
 	return 0;
 }
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 85d88f2..cba5658 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -44,6 +44,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	u_int8_t tos;
 	__be32 saddr, daddr;
 	u_int32_t mark;
+	int err;
 
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
@@ -66,9 +67,11 @@ ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 		if (iph->saddr != saddr ||
 		    iph->daddr != daddr ||
 		    skb->mark != mark ||
-		    iph->tos != tos)
-			if (ip_route_me_harder(skb, RTN_UNSPEC))
-				ret = NF_DROP;
+		    iph->tos != tos) {
+			err = ip_route_me_harder(skb, RTN_UNSPEC);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
+		}
 	}
 
 	return ret;
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index eeaff7e..c2937c8 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -213,6 +213,7 @@ nf_nat_ipv4_local_fn(unsigned int hooknum,
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
+	int err;
 
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
@@ -226,8 +227,9 @@ nf_nat_ipv4_local_fn(unsigned int hooknum,
 
 		if (ct->tuplehash[dir].tuple.dst.u3.ip !=
 		    ct->tuplehash[!dir].tuple.src.u3.ip) {
-			if (ip_route_me_harder(skb, RTN_UNSPEC))
-				ret = NF_DROP;
+			err = ip_route_me_harder(skb, RTN_UNSPEC);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
 		}
 #ifdef CONFIG_XFRM
 		else if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
-- 
1.8.1.4

