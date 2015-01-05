From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 5/6] net: tcp: add RTAX_CC_ALGO fib handling
Date: Mon,  5 Jan 2015 23:57:47 +0100
Message-ID: <1420498668-4660-6-git-send-email-dborkman@redhat.com>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754714AbbAEW6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:05 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the minimum necessary for the RTAX_CC_ALGO congestion
control metric to be set up and dumped back to user space.

While the internal representation of RTAX_CC_ALGO is handled as a u32
key, we avoided to expose this implementation detail to user space, thus
instead, we chose the netlink attribute that is being exchanged between
user space to be the actual congestion control algorithm name, similarly
as in the setsockopt(2) API in order to allow for maximum flexibility,
even for 3rd party modules.

It is a bit unfortunate that RTAX_QUICKACK used up a whole RTAX slot as
it should have been stored in RTAX_FEATURES instead, we first thought
about reusing it for the congestion control key, but it brings more
complications and/or confusion than worth it.

Joint work with Florian Westphal.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/tcp.h              |  7 +++++++
 include/uapi/linux/rtnetlink.h |  2 ++
 net/core/rtnetlink.c           | 15 +++++++++++++--
 net/decnet/dn_fib.c            |  3 ++-
 net/decnet/dn_table.c          |  4 +++-
 net/ipv4/fib_semantics.c       | 14 ++++++++++++--
 net/ipv6/route.c               | 17 +++++++++++++++--
 7 files changed, 54 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 135b70c..95bb237 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -846,7 +846,14 @@ extern struct tcp_congestion_ops tcp_reno;
 
 struct tcp_congestion_ops *tcp_ca_find_key(u32 key);
 u32 tcp_ca_get_key_by_name(const char *name);
+#ifdef CONFIG_INET
 char *tcp_ca_get_name_by_key(u32 key, char *buffer);
+#else
+static inline char *tcp_ca_get_name_by_key(u32 key, char *buffer)
+{
+	return NULL;
+}
+#endif
 
 static inline bool tcp_ca_needs_ecn(const struct sock *sk)
 {
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 9c9b8b4..d81f22d 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -389,6 +389,8 @@ enum {
 #define RTAX_INITRWND RTAX_INITRWND
 	RTAX_QUICKACK,
 #define RTAX_QUICKACK RTAX_QUICKACK
+	RTAX_CC_ALGO,
+#define RTAX_CC_ALGO RTAX_CC_ALGO
 	__RTAX_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9cf6fe9..001372f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -50,6 +50,7 @@
 #include <net/arp.h>
 #include <net/route.h>
 #include <net/udp.h>
+#include <net/tcp.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <net/fib_rules.h>
@@ -669,9 +670,19 @@ int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 
 	for (i = 0; i < RTAX_MAX; i++) {
 		if (metrics[i]) {
+			if (i == RTAX_CC_ALGO - 1) {
+				char tmp[TCP_CA_NAME_MAX], *name;
+
+				name = tcp_ca_get_name_by_key(metrics[i], tmp);
+				if (!name)
+					continue;
+				if (nla_put_string(skb, i + 1, name))
+					goto nla_put_failure;
+			} else {
+				if (nla_put_u32(skb, i + 1, metrics[i]))
+					goto nla_put_failure;
+			}
 			valid++;
-			if (nla_put_u32(skb, i+1, metrics[i]))
-				goto nla_put_failure;
 		}
 	}
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index d332aef..df48034 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -298,7 +298,8 @@ struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, struct nlattr *att
 			int type = nla_type(attr);
 
 			if (type) {
-				if (type > RTAX_MAX || nla_len(attr) < 4)
+				if (type > RTAX_MAX || type == RTAX_CC_ALGO ||
+				    nla_len(attr) < 4)
 					goto err_inval;
 
 				fi->fib_metrics[type-1] = nla_get_u32(attr);
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 86e3807..3f19fcb 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -29,6 +29,7 @@
 #include <linux/route.h> /* RTF_xxx */
 #include <net/neighbour.h>
 #include <net/netlink.h>
+#include <net/tcp.h>
 #include <net/dst.h>
 #include <net/flow.h>
 #include <net/fib_rules.h>
@@ -273,7 +274,8 @@ static inline size_t dn_fib_nlmsg_size(struct dn_fib_info *fi)
 	size_t payload = NLMSG_ALIGN(sizeof(struct rtmsg))
 			 + nla_total_size(4) /* RTA_TABLE */
 			 + nla_total_size(2) /* RTA_DST */
-			 + nla_total_size(4); /* RTA_PRIORITY */
+			 + nla_total_size(4) /* RTA_PRIORITY */
+			 + nla_total_size(TCP_CA_NAME_MAX); /* RTAX_CC_ALGO */
 
 	/* space for nested metrics */
 	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index f99f41b..d2b7b55 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -360,7 +360,8 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 			 + nla_total_size(4) /* RTA_TABLE */
 			 + nla_total_size(4) /* RTA_DST */
 			 + nla_total_size(4) /* RTA_PRIORITY */
-			 + nla_total_size(4); /* RTA_PREFSRC */
+			 + nla_total_size(4) /* RTA_PREFSRC */
+			 + nla_total_size(TCP_CA_NAME_MAX); /* RTAX_CC_ALGO */
 
 	/* space for nested metrics */
 	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
@@ -859,7 +860,16 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 				if (type > RTAX_MAX)
 					goto err_inval;
-				val = nla_get_u32(nla);
+				if (type == RTAX_CC_ALGO) {
+					char tmp[TCP_CA_NAME_MAX];
+
+					nla_strlcpy(tmp, nla, sizeof(tmp));
+					val = tcp_ca_get_key_by_name(tmp);
+					if (val == TCP_CA_UNSPEC)
+						goto err_inval;
+				} else {
+					val = nla_get_u32(nla);
+				}
 				if (type == RTAX_ADVMSS && val > 65535 - 40)
 					val = 65535 - 40;
 				if (type == RTAX_MTU && val > 65535 - 15)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 454771d..34dcbb5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1488,10 +1488,22 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 		int type = nla_type(nla);
 
 		if (type) {
+			u32 val;
+
 			if (unlikely(type > RTAX_MAX))
 				goto err;
+			if (type == RTAX_CC_ALGO) {
+				char tmp[TCP_CA_NAME_MAX];
+
+				nla_strlcpy(tmp, nla, sizeof(tmp));
+				val = tcp_ca_get_key_by_name(tmp);
+				if (val == TCP_CA_UNSPEC)
+					goto err;
+			} else {
+				val = nla_get_u32(nla);
+			}
 
-			mp[type - 1] = nla_get_u32(nla);
+			mp[type - 1] = val;
 			__set_bit(type - 1, mxc->mx_valid);
 		}
 	}
@@ -2571,7 +2583,8 @@ static inline size_t rt6_nlmsg_size(void)
 	       + nla_total_size(4) /* RTA_OIF */
 	       + nla_total_size(4) /* RTA_PRIORITY */
 	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
-	       + nla_total_size(sizeof(struct rta_cacheinfo));
+	       + nla_total_size(sizeof(struct rta_cacheinfo))
+	       + nla_total_size(TCP_CA_NAME_MAX); /* RTAX_CC_ALGO */
 }
 
 static int rt6_fill_node(struct net *net,
-- 
1.7.11.7
