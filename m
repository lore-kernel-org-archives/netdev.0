From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 4/4] tcp: use dctcp if enabled on the route to the initiator
Date: Mon, 31 Aug 2015 15:58:47 +0200
Message-ID: <f599fcdc7f32e6c0b9abf4d77dcb14271e21f988.1441027533.git.daniel@iogearbox.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Cc: fw@strlen.de, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34943 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbbHaN6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 09:58:54 -0400
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the following case doesn't use DCTCP, even if it should:
A responder has f.e. Cubic as system wide default, but for a specific
route to the initiating host, DCTCP is being set in RTAX_CC_ALGO. The
initiating host then uses DCTCP as congestion control, but since the
initiator sets ECT(0), tcp_ecn_create_request() doesn't set ecn_ok,
and we have to fall back to Reno after 3WHS completes.

We were thinking on how to solve this in a minimal, non-intrusive
way without bloating tcp_ecn_create_request() needlessly: lets cache
the CA ecn option flag in RTAX_FEATURES. In other words, when ECT(0)
is set on the SYN packet, set ecn_ok=1 iff route RTAX_FEATURES
contains the unexposed (internal-only) DST_FEATURE_ECN_CA. This allows
to only do a single metric feature lookup inside tcp_ecn_create_request().

Joint work with Florian Westphal.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/dst.h        | 6 ++++++
 include/net/tcp.h        | 2 +-
 net/core/rtnetlink.c     | 6 ++++++
 net/ipv4/fib_semantics.c | 6 +++++-
 net/ipv4/tcp_cong.c      | 9 ++++++---
 net/ipv4/tcp_input.c     | 7 +++++--
 net/ipv6/route.c         | 9 +++++++--
 7 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 4c48016..9261d92 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -207,6 +207,12 @@ static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
 		p[metric-1] = val;
 }
 
+/* Kernel-internal feature bits that are unallocated in user space. */
+#define DST_FEATURE_ECN_CA	(1 << 31)
+
+#define DST_FEATURE_MASK	(DST_FEATURE_ECN_CA)
+#define DST_FEATURE_ECN_MASK	(DST_FEATURE_ECN_CA | RTAX_FEATURE_ECN)
+
 static inline u32
 dst_feature(const struct dst_entry *dst, u32 feature)
 {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4a7b039..0cab28c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -888,7 +888,7 @@ void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
 
 struct tcp_congestion_ops *tcp_ca_find_key(u32 key);
-u32 tcp_ca_get_key_by_name(const char *name);
+u32 tcp_ca_get_key_by_name(const char *name, bool *ecn_ca);
 #ifdef CONFIG_INET
 char *tcp_ca_get_name_by_key(u32 key, char *buffer);
 #else
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 788ceed..a466821 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -678,6 +678,12 @@ int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 					continue;
 				if (nla_put_string(skb, i + 1, name))
 					goto nla_put_failure;
+			} else if (i == RTAX_FEATURES - 1) {
+				u32 user_features = metrics[i] & RTAX_FEATURE_MASK;
+
+				BUILD_BUG_ON(RTAX_FEATURE_MASK & DST_FEATURE_MASK);
+				if (nla_put_u32(skb, i + 1, user_features))
+					goto nla_put_failure;
 			} else {
 				if (nla_put_u32(skb, i + 1, metrics[i]))
 					goto nla_put_failure;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 115a08e..992a959 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -879,6 +879,7 @@ static bool fib_valid_prefsrc(struct fib_config *cfg, __be32 fib_prefsrc)
 static int
 fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 {
+	bool ecn_ca = false;
 	struct nlattr *nla;
 	int remaining;
 
@@ -898,7 +899,7 @@ fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 			char tmp[TCP_CA_NAME_MAX];
 
 			nla_strlcpy(tmp, nla, sizeof(tmp));
-			val = tcp_ca_get_key_by_name(tmp);
+			val = tcp_ca_get_key_by_name(tmp, &ecn_ca);
 			if (val == TCP_CA_UNSPEC)
 				return -EINVAL;
 		} else {
@@ -913,6 +914,9 @@ fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 		fi->fib_metrics[type - 1] = val;
 	}
 
+	if (ecn_ca)
+		fi->fib_metrics[RTAX_FEATURES - 1] |= DST_FEATURE_ECN_CA;
+
 	return 0;
 }
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index a2ed23c..93c4dc3 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -114,16 +114,19 @@ void tcp_unregister_congestion_control(struct tcp_congestion_ops *ca)
 }
 EXPORT_SYMBOL_GPL(tcp_unregister_congestion_control);
 
-u32 tcp_ca_get_key_by_name(const char *name)
+u32 tcp_ca_get_key_by_name(const char *name, bool *ecn_ca)
 {
 	const struct tcp_congestion_ops *ca;
-	u32 key;
+	u32 key = TCP_CA_UNSPEC;
 
 	might_sleep();
 
 	rcu_read_lock();
 	ca = __tcp_ca_find_autoload(name);
-	key = ca ? ca->key : TCP_CA_UNSPEC;
+	if (ca) {
+		key = ca->key;
+		*ecn_ca = ca->flags & TCP_CONG_NEEDS_ECN;
+	}
 	rcu_read_unlock();
 
 	return key;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dc08e23..a8f515b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6003,14 +6003,17 @@ static void tcp_ecn_create_request(struct request_sock *req,
 	const struct net *net = sock_net(listen_sk);
 	bool th_ecn = th->ece && th->cwr;
 	bool ect, ecn_ok;
+	u32 ecn_ok_dst;
 
 	if (!th_ecn)
 		return;
 
 	ect = !INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield);
-	ecn_ok = net->ipv4.sysctl_tcp_ecn || dst_feature(dst, RTAX_FEATURE_ECN);
+	ecn_ok_dst = dst_feature(dst, DST_FEATURE_ECN_MASK);
+	ecn_ok = net->ipv4.sysctl_tcp_ecn || ecn_ok_dst;
 
-	if ((!ect && ecn_ok) || tcp_ca_needs_ecn(listen_sk))
+	if ((!ect && ecn_ok) || tcp_ca_needs_ecn(listen_sk) ||
+	    (ecn_ok_dst & DST_FEATURE_ECN_CA))
 		inet_rsk(req)->ecn_ok = 1;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8771530..f45cac6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1698,6 +1698,7 @@ out:
 static int ip6_convert_metrics(struct mx6_config *mxc,
 			       const struct fib6_config *cfg)
 {
+	bool ecn_ca = false;
 	struct nlattr *nla;
 	int remaining;
 	u32 *mp;
@@ -1722,7 +1723,7 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 			char tmp[TCP_CA_NAME_MAX];
 
 			nla_strlcpy(tmp, nla, sizeof(tmp));
-			val = tcp_ca_get_key_by_name(tmp);
+			val = tcp_ca_get_key_by_name(tmp, &ecn_ca);
 			if (val == TCP_CA_UNSPEC)
 				goto err;
 		} else {
@@ -1735,8 +1736,12 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 		__set_bit(type - 1, mxc->mx_valid);
 	}
 
-	mxc->mx = mp;
+	if (ecn_ca) {
+		__set_bit(RTAX_FEATURES - 1, mxc->mx_valid);
+		mp[RTAX_FEATURES - 1] |= DST_FEATURE_ECN_CA;
+	}
 
+	mxc->mx = mp;
 	return 0;
  err:
 	kfree(mp);
-- 
1.9.3
