From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 3/7] ipv4: Support TOU
Date: Mon, 23 May 2016 15:48:22 -0700
Message-ID: <1464043706-2843932-4-git-send-email-tom@herbertland.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:61185 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369AbcEWWsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:48:41 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4NMl215024411
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 234ann83ch-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:40 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7e5f07d4213811e697a70002c9931860-31cbd6d0 for <netdev@vger.kernel.org>;	Mon,
 23 May 2016 15:48:40 -0700
In-Reply-To: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tou_encap structure to inet_sock. In transmit path (ip_queue_xmit)
check if encapsulation is enabled and call the build header op
if it is. Add IP_TOU_ENCAP setsockopt for IPv4 sockets.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/inet_sock.h |  1 +
 include/uapi/linux/in.h |  1 +
 net/ipv4/ip_output.c    | 40 ++++++++++++++++++++++++++++++++++------
 net/ipv4/ip_sockglue.c  |  7 +++++++
 net/ipv4/tou.c          |  2 +-
 5 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 012b1f9..ce22bc9 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -209,6 +209,7 @@ struct inet_sock {
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
 	struct inet_cork_full	cork;
+	struct ip_tunnel_encap	*tou_encap;
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index eaf9491..9827bff 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -152,6 +152,7 @@ struct in_addr {
 #define MCAST_MSFILTER			48
 #define IP_MULTICAST_ALL		49
 #define IP_UNICAST_IF			50
+#define IP_TOU_ENCAP			51
 
 #define MCAST_EXCLUDE	0
 #define MCAST_INCLUDE	1
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 124bf0a..e7dbded 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -78,6 +78,7 @@
 #include <linux/netfilter_bridge.h>
 #include <linux/netlink.h>
 #include <linux/tcp.h>
+#include <net/ip_tunnels.h>
 
 static int
 ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
@@ -382,11 +383,36 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 	struct rtable *rt;
 	struct iphdr *iph;
 	int res;
+	__be16 dport, sport;
+	u8 protocol = sk->sk_protocol;
 
 	/* Skip all of this if the packet is already routed,
 	 * f.e. by something like SCTP.
 	 */
 	rcu_read_lock();
+
+	if (inet->tou_encap) {
+		struct ip_tunnel_encap *e = inet->tou_encap;
+		const struct ip_tunnel_encap_ops *ops;
+
+		/* Transport layer protocol over UDP enapsulation */
+		dport = e->dport;
+		sport = e->sport;
+		ops = rcu_dereference(iptun_encaps[e->type]);
+		if (likely(ops && ops->build_header)) {
+			res = ops->build_header(skb, e, &protocol,
+						(struct flowi4 *)fl);
+			if (res < 0)
+				goto fail;
+		} else {
+			res = -EINVAL;
+			goto fail;
+		}
+	} else {
+		dport = inet->inet_dport;
+		sport = inet->inet_sport;
+	}
+
 	inet_opt = rcu_dereference(inet->inet_opt);
 	fl4 = &fl->u.ip4;
 	rt = skb_rtable(skb);
@@ -409,9 +435,9 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 		 */
 		rt = ip_route_output_ports(net, fl4, sk,
 					   daddr, inet->inet_saddr,
-					   inet->inet_dport,
-					   inet->inet_sport,
-					   sk->sk_protocol,
+					   dport,
+					   sport,
+					   protocol,
 					   RT_CONN_FLAGS(sk),
 					   sk->sk_bound_dev_if);
 		if (IS_ERR(rt))
@@ -434,7 +460,7 @@ packet_routed:
 	else
 		iph->frag_off = 0;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
-	iph->protocol = sk->sk_protocol;
+	iph->protocol = protocol;
 	ip_copy_addrs(iph, fl4);
 
 	/* Transport layer set skb->h.foo itself. */
@@ -456,10 +482,12 @@ packet_routed:
 	return res;
 
 no_route:
-	rcu_read_unlock();
 	IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
+	res = -EHOSTUNREACH;
+fail:
+	rcu_read_unlock();
 	kfree_skb(skb);
-	return -EHOSTUNREACH;
+	return res;
 }
 EXPORT_SYMBOL(ip_queue_xmit);
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 71a52f4..0c9d3f0 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -42,6 +42,7 @@
 #include <net/transp_v6.h>
 #endif
 #include <net/ip_fib.h>
+#include <net/tou.h>
 
 #include <linux/errqueue.h>
 #include <asm/uaccess.h>
@@ -1162,6 +1163,10 @@ mc_msf_out:
 		inet->min_ttl = val;
 		break;
 
+	case IP_TOU_ENCAP:
+		err = tou_encap_setsockopt(sk, optval, optlen, false);
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -1493,6 +1498,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MINTTL:
 		val = inet->min_ttl;
 		break;
+	case IPV6_TOU_ENCAP:
+		return tou_encap_getsockopt(sk, optval, len, optlen, false);
 	default:
 		release_sock(sk);
 		return -ENOPROTOOPT;
diff --git a/net/ipv4/tou.c b/net/ipv4/tou.c
index 601466a..bbb44b6 100644
--- a/net/ipv4/tou.c
+++ b/net/ipv4/tou.c
@@ -61,7 +61,7 @@ int tou_encap_setsockopt(struct sock *sk, char __user *optval, int optlen,
 	encap.dport = te.dport;
 	encap.flags = te.flags;
 
-	hlen = is_ipv6 ? ip6_encap_hlen(e) : ip_encap_hlen(e);
+	hlen = is_ipv6 ? ip6_encap_hlen(&encap) : ip_encap_hlen(&encap);
 	if (hlen < 0)
 		return hlen;
 
-- 
2.8.0.rc2
