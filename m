From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 1/7][RFC] nf: xt_socket: export the fancy sock finder code
Date: Fri, 21 Sep 2012 22:10:47 -0400
Message-ID: <1348279853-44499-2-git-send-email-john.stultz@linaro.org>
References: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
Cc: JP Abgrall <jpa@google.com>, netdev@vger.kernel.org,
	Ashish Sharma <ashishsharma@google.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	John Stultz <john.stultz@linaro.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348279853-44499-1-git-send-email-john.stultz@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: JP Abgrall <jpa@google.com>

The socket matching function has some nifty logic to get the struct sock
from the skb or from the connection tracker.
We export this so other xt_* can use it, similarly to ho how
xt_socket uses nf_tproxy_get_sock.

Cc: netdev@vger.kernel.org
Cc: JP Abgrall <jpa@google.com>
Cc: Ashish Sharma <ashishsharma@google.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: JP Abgrall <jpa@google.com>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/netfilter/xt_socket.h |    6 +++
 net/netfilter/xt_socket.c           |   69 +++++++++++++++++++++++------------
 2 files changed, 52 insertions(+), 23 deletions(-)

diff --git a/include/linux/netfilter/xt_socket.h b/include/linux/netfilter/xt_socket.h
index 26d7217..6359456 100644
--- a/include/linux/netfilter/xt_socket.h
+++ b/include/linux/netfilter/xt_socket.h
@@ -11,4 +11,10 @@ struct xt_socket_mtinfo1 {
 	__u8 flags;
 };
 
+void xt_socket_put_sk(struct sock *sk);
+struct sock *xt_socket_get4_sk(const struct sk_buff *skb,
+			       struct xt_action_param *par);
+struct sock *xt_socket_get6_sk(const struct sk_buff *skb,
+			       struct xt_action_param *par);
+
 #endif /* _XT_SOCKET_H */
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 9ea482d..ee8c5f5 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -35,7 +35,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
-static void
+void
 xt_socket_put_sk(struct sock *sk)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
@@ -43,6 +43,7 @@ xt_socket_put_sk(struct sock *sk)
 	else
 		sock_put(sk);
 }
+EXPORT_SYMBOL(xt_socket_put_sk);
 
 static int
 extract_icmp4_fields(const struct sk_buff *skb,
@@ -101,9 +102,8 @@ extract_icmp4_fields(const struct sk_buff *skb,
 	return 0;
 }
 
-static bool
-socket_match(const struct sk_buff *skb, struct xt_action_param *par,
-	     const struct xt_socket_mtinfo1 *info)
+struct sock*
+xt_socket_get4_sk(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct udphdr _hdr, *hp = NULL;
@@ -120,7 +120,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 		hp = skb_header_pointer(skb, ip_hdrlen(skb),
 					sizeof(_hdr), &_hdr);
 		if (hp == NULL)
-			return false;
+			return NULL;
 
 		protocol = iph->protocol;
 		saddr = iph->saddr;
@@ -131,9 +131,9 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	} else if (iph->protocol == IPPROTO_ICMP) {
 		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
 					&sport, &dport))
-			return false;
+			return NULL;
 	} else {
-		return false;
+		return NULL;
 	}
 
 #ifdef XT_SOCKET_HAVE_CONNTRACK
@@ -157,6 +157,23 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
 				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
+
+	pr_debug("proto %hhu %pI4:%hu -> %pI4:%hu (orig %pI4:%hu) sock %p\n",
+		 protocol, &saddr, ntohs(sport),
+		 &daddr, ntohs(dport),
+		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
+
+	return sk;
+}
+EXPORT_SYMBOL(xt_socket_get4_sk);
+
+static bool
+socket_match(const struct sk_buff *skb, struct xt_action_param *par,
+	     const struct xt_socket_mtinfo1 *info)
+{
+	struct sock *sk;
+
+	sk = xt_socket_get4_sk(skb, par);
 	if (sk != NULL) {
 		bool wildcard;
 		bool transparent = true;
@@ -179,11 +196,6 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 			sk = NULL;
 	}
 
-	pr_debug("proto %hhu %pI4:%hu -> %pI4:%hu (orig %pI4:%hu) sock %p\n",
-		 protocol, &saddr, ntohs(sport),
-		 &daddr, ntohs(dport),
-		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
-
 	return (sk != NULL);
 }
 
@@ -255,8 +267,8 @@ extract_icmp6_fields(const struct sk_buff *skb,
 	return 0;
 }
 
-static bool
-socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
+struct sock*
+xt_socket_get6_sk(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct udphdr _hdr, *hp = NULL;
@@ -276,7 +288,7 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 		hp = skb_header_pointer(skb, thoff,
 					sizeof(_hdr), &_hdr);
 		if (hp == NULL)
-			return false;
+			return NULL;
 
 		saddr = &iph->saddr;
 		sport = hp->source;
@@ -286,13 +298,30 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	} else if (tproto == IPPROTO_ICMPV6) {
 		if (extract_icmp6_fields(skb, thoff, &tproto, &saddr, &daddr,
 					 &sport, &dport))
-			return false;
+			return NULL;
 	} else {
-		return false;
+		return NULL;
 	}
 
 	sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
 				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
+	pr_debug("proto %hhd %pI6:%hu -> %pI6:%hu "
+		 "(orig %pI6:%hu) sock %p\n",
+		 tproto, saddr, ntohs(sport),
+		 daddr, ntohs(dport),
+		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
+	return sk;
+}
+EXPORT_SYMBOL(xt_socket_get6_sk);
+
+static bool
+socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	struct sock *sk;
+	const struct xt_socket_mtinfo1 *info;
+
+	info = (struct xt_socket_mtinfo1 *) par->matchinfo;
+	sk = xt_socket_get6_sk(skb, par);
 	if (sk != NULL) {
 		bool wildcard;
 		bool transparent = true;
@@ -315,12 +344,6 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 			sk = NULL;
 	}
 
-	pr_debug("proto %hhd %pI6:%hu -> %pI6:%hu "
-		 "(orig %pI6:%hu) sock %p\n",
-		 tproto, saddr, ntohs(sport),
-		 daddr, ntohs(dport),
-		 &iph->daddr, hp ? ntohs(hp->dest) : 0, sk);
-
 	return (sk != NULL);
 }
 #endif
-- 
1.7.9.5
