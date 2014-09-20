From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/3] tcp: move logic out of tcp_v[64]_gso_send_check
Date: Sat, 20 Sep 2014 14:52:28 -0700
Message-ID: <1411249950-6795-2-git-send-email-therbert@google.com>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:51373 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaITVxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:53:04 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so2036668pdb.38
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 14:53:04 -0700 (PDT)
In-Reply-To: <1411249950-6795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcp_v[46]_gso_send_check the TCP checksum is initialized to the
pseudo header checksum using __tcp_v[46]_send_check. We can move this
logic into new tcp[46]_gso_segment functions to be done when
ip_summed != CHECKSUM_PARTIAL (ip_summed == CHECKSUM_PARTIAL should be
the common case, possibly always true when taking GSO path). After this
change tcp_v[46]_gso_send_check is no-op.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/tcp_offload.c   | 39 +++++++++++++++++++++++----------------
 net/ipv6/tcpv6_offload.c | 37 ++++++++++++++++++++++++-------------
 2 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 7291253..7cd12b0 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -29,6 +29,28 @@ static void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq,
 	}
 }
 
+struct sk_buff *tcp4_gso_segment(struct sk_buff *skb,
+				 netdev_features_t features)
+{
+	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
+		return ERR_PTR(-EINVAL);
+
+	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+		const struct iphdr *iph = ip_hdr(skb);
+		struct tcphdr *th = tcp_hdr(skb);
+
+		/* Set up checksum pseudo header, usually expect stack to
+		 * have done this already.
+		 */
+
+		th->check = 0;
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		__tcp_v4_send_check(skb, iph->saddr, iph->daddr);
+	}
+
+	return tcp_gso_segment(skb, features);
+}
+
 struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features)
 {
@@ -44,9 +66,6 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	__sum16 newcheck;
 	bool ooo_okay, copy_destructor;
 
-	if (!pskb_may_pull(skb, sizeof(*th)))
-		goto out;
-
 	th = tcp_hdr(skb);
 	thlen = th->doff * 4;
 	if (thlen < sizeof(*th))
@@ -271,18 +290,6 @@ EXPORT_SYMBOL(tcp_gro_complete);
 
 static int tcp_v4_gso_send_check(struct sk_buff *skb)
 {
-	const struct iphdr *iph;
-	struct tcphdr *th;
-
-	if (!pskb_may_pull(skb, sizeof(*th)))
-		return -EINVAL;
-
-	iph = ip_hdr(skb);
-	th = tcp_hdr(skb);
-
-	th->check = 0;
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	__tcp_v4_send_check(skb, iph->saddr, iph->daddr);
 	return 0;
 }
 
@@ -314,7 +321,7 @@ static int tcp4_gro_complete(struct sk_buff *skb, int thoff)
 static const struct net_offload tcpv4_offload = {
 	.callbacks = {
 		.gso_send_check	=	tcp_v4_gso_send_check,
-		.gso_segment	=	tcp_gso_segment,
+		.gso_segment	=	tcp4_gso_segment,
 		.gro_receive	=	tcp4_gro_receive,
 		.gro_complete	=	tcp4_gro_complete,
 	},
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index dbb3d92..9625315 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -17,18 +17,6 @@
 
 static int tcp_v6_gso_send_check(struct sk_buff *skb)
 {
-	const struct ipv6hdr *ipv6h;
-	struct tcphdr *th;
-
-	if (!pskb_may_pull(skb, sizeof(*th)))
-		return -EINVAL;
-
-	ipv6h = ipv6_hdr(skb);
-	th = tcp_hdr(skb);
-
-	th->check = 0;
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	__tcp_v6_send_check(skb, &ipv6h->saddr, &ipv6h->daddr);
 	return 0;
 }
 
@@ -58,10 +46,33 @@ static int tcp6_gro_complete(struct sk_buff *skb, int thoff)
 	return tcp_gro_complete(skb);
 }
 
+struct sk_buff *tcp6_gso_segment(struct sk_buff *skb,
+				 netdev_features_t features)
+{
+	struct tcphdr *th;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		return ERR_PTR(-EINVAL);
+
+	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+		const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		struct tcphdr *th = tcp_hdr(skb);
+
+		/* Set up pseudo header, usually expect stack to have done
+		 * this.
+		 */
+
+		th->check = 0;
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		__tcp_v6_send_check(skb, &ipv6h->saddr, &ipv6h->daddr);
+	}
+
+	return tcp_gso_segment(skb, features);
+}
 static const struct net_offload tcpv6_offload = {
 	.callbacks = {
 		.gso_send_check	=	tcp_v6_gso_send_check,
-		.gso_segment	=	tcp_gso_segment,
+		.gso_segment	=	tcp6_gso_segment,
 		.gro_receive	=	tcp6_gro_receive,
 		.gro_complete	=	tcp6_gro_complete,
 	},
-- 
2.1.0.rc2.206.gedb03e5
