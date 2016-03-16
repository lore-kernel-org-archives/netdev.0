From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf, dst: add and use dst_tclassid helper
Date: Wed, 16 Mar 2016 01:42:50 +0100
Message-ID: <27b04002c41af19d7532a627a7497b109b6d2e24.1458085814.git.daniel@iogearbox.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38428 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbcCPAnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 20:43:06 -0400
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can just add a small helper dst_tclassid() for retrieving the
dst->tclassid value. It makes the code a bit better in that we can
get rid of the ifdef from filter.c by moving this into the header.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/dst.h | 12 ++++++++++++
 net/core/filter.c |  9 +--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index c7329dc..5c98443 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -398,6 +398,18 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
 	__skb_tunnel_rx(skb, dev, net);
 }
 
+static inline u32 dst_tclassid(const struct sk_buff *skb)
+{
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	const struct dst_entry *dst;
+
+	dst = skb_dst(skb);
+	if (dst)
+		return dst->tclassid;
+#endif
+	return 0;
+}
+
 int dst_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb);
 static inline int dst_discard(struct sk_buff *skb)
 {
diff --git a/net/core/filter.c b/net/core/filter.c
index 69c7b2f..4c35d83 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1682,14 +1682,7 @@ static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
 
 static u64 bpf_get_route_realm(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	const struct dst_entry *dst;
-
-	dst = skb_dst((struct sk_buff *) (unsigned long) r1);
-	if (dst)
-		return dst->tclassid;
-#endif
-	return 0;
+	return dst_tclassid((struct sk_buff *) (unsigned long) r1);
 }
 
 static const struct bpf_func_proto bpf_get_route_realm_proto = {
-- 
1.9.3
