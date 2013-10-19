From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/6] ipv4: generalize gre_handle_offloads
Date: Sat, 19 Oct 2013 11:42:55 -0700
Message-ID: <1382208178-22347-4-git-send-email-edumazet@google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:63144 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab3JSSnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:43:10 -0400
Received: by mail-qe0-f74.google.com with SMTP id 1so302797qec.5
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:43:09 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes gre_handle_offloads() more generic
and rename it to iptunnel_handle_offloads()

This will be used to add GSO/TSO support to IPIP tunnels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/gre.h         |  8 +++++++-
 include/net/ip_tunnels.h  |  3 +++
 net/ipv4/gre_demux.c      | 29 -----------------------------
 net/ipv4/ip_tunnel_core.c | 33 +++++++++++++++++++++++++++++++++
 4 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 57e4afd..dcd9ae3 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -38,7 +38,13 @@ void gre_offload_exit(void);
 
 void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		      int hdr_len);
-struct sk_buff *gre_handle_offloads(struct sk_buff *skb, bool gre_csum);
+
+static inline struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
+						  bool gre_csum)
+{
+	return iptunnel_handle_offloads(skb, gre_csum, SKB_GSO_GRE);
+}
+
 
 static inline int ip_gre_calc_hlen(__be16 o_flags)
 {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a0a4a10..732f8c6 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -150,6 +150,9 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df, bool xnet);
 
+struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
+					 int gso_type_mask);
+
 static inline void iptunnel_xmit_stats(int err,
 				       struct net_device_stats *err_stats,
 				       struct pcpu_tstats __percpu *stats)
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 736c9fc3..5893e99 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -93,35 +93,6 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 }
 EXPORT_SYMBOL_GPL(gre_build_header);
 
-struct sk_buff *gre_handle_offloads(struct sk_buff *skb, bool gre_csum)
-{
-	int err;
-
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
-
-	if (skb_is_gso(skb)) {
-		err = skb_unclone(skb, GFP_ATOMIC);
-		if (unlikely(err))
-			goto error;
-		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
-		return skb;
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL && gre_csum) {
-		err = skb_checksum_help(skb);
-		if (unlikely(err))
-			goto error;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
-		skb->ip_summed = CHECKSUM_NONE;
-
-	return skb;
-error:
-	kfree_skb(skb);
-	return ERR_PTR(err);
-}
-EXPORT_SYMBOL_GPL(gre_handle_offloads);
-
 static __sum16 check_checksum(struct sk_buff *skb)
 {
 	__sum16 csum = 0;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index c31e3ad..42ffbc8 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -116,3 +116,36 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(iptunnel_pull_header);
+
+struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
+					 bool csum_help,
+					 int gso_type_mask)
+{
+	int err;
+
+	if (likely(!skb->encapsulation)) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	if (skb_is_gso(skb)) {
+		err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			goto error;
+		skb_shinfo(skb)->gso_type |= gso_type_mask;
+		return skb;
+	}
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL && csum_help) {
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	return skb;
+error:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(iptunnel_handle_offloads);
-- 
1.8.4
