From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH next-next 5/7] gre: Create common functions for transmit
Date: Fri, 29 Apr 2016 17:12:19 -0700
Message-ID: <1461975141-954269-6-git-send-email-tom@herbertland.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:11749 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752650AbcD3AOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:14:47 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3U0Bpj9024645
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22mggpg9er-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:14:46 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 8ae925940e6811e6b5d224be0595f910-d43f7c50 for <netdev@vger.kernel.org>;	Fri,
 29 Apr 2016 17:14:45 -0700
In-Reply-To: <1461975141-954269-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create common functions for both IPv4 and IPv6 GRE in transmit. These
are put into gre.h.

Common functions are for:
  - GRE checksum calculation. Move gre_checksum to gre.h.
  - Building a GRE header. Move GRE build_header and rename
    gre_build_header.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/gre.h | 44 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c | 52 +++++-----------------------------------------------
 2 files changed, 49 insertions(+), 47 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 3959158..29e3732 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -85,4 +85,48 @@ static inline __be16 gre_tnl_flags_to_gre_flags(__be16 tflags)
 	return flags;
 }
 
+static inline __sum16 gre_checksum(struct sk_buff *skb)
+{
+	__wsum csum;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		csum = lco_csum(skb);
+	else
+		csum = skb_checksum(skb, 0, skb->len, 0);
+	return csum_fold(csum);
+}
+
+static inline void gre_build_header(struct sk_buff *skb, int hdr_len,
+				    __be16 flags, __be16 proto,
+				    __be32 key, __be32 seq)
+{
+	struct gre_base_hdr *greh;
+
+	skb_push(skb, hdr_len);
+
+	skb_reset_transport_header(skb);
+	greh = (struct gre_base_hdr *)skb->data;
+	greh->flags = gre_tnl_flags_to_gre_flags(flags);
+	greh->protocol = proto;
+
+	if (flags & (TUNNEL_KEY | TUNNEL_CSUM | TUNNEL_SEQ)) {
+		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
+
+		if (flags & TUNNEL_SEQ) {
+			*ptr = seq;
+			ptr--;
+		}
+		if (flags & TUNNEL_KEY) {
+			*ptr = key;
+			ptr--;
+		}
+		if (flags & TUNNEL_CSUM &&
+		    !(skb_shinfo(skb)->gso_type &
+		      (SKB_GSO_GRE | SKB_GSO_GRE_CSUM))) {
+			*ptr = 0;
+			*(__sum16 *)ptr = gre_checksum(skb);
+		}
+	}
+}
+
 #endif
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f6db3d6..2480d79 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -329,49 +329,6 @@ drop:
 	return 0;
 }
 
-static __sum16 gre_checksum(struct sk_buff *skb)
-{
-	__wsum csum;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		csum = lco_csum(skb);
-	else
-		csum = skb_checksum(skb, 0, skb->len, 0);
-	return csum_fold(csum);
-}
-
-static void build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
-			 __be16 proto, __be32 key, __be32 seq)
-{
-	struct gre_base_hdr *greh;
-
-	skb_push(skb, hdr_len);
-
-	skb_reset_transport_header(skb);
-	greh = (struct gre_base_hdr *)skb->data;
-	greh->flags = gre_tnl_flags_to_gre_flags(flags);
-	greh->protocol = proto;
-
-	if (flags & (TUNNEL_KEY | TUNNEL_CSUM | TUNNEL_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
-
-		if (flags & TUNNEL_SEQ) {
-			*ptr = seq;
-			ptr--;
-		}
-		if (flags & TUNNEL_KEY) {
-			*ptr = key;
-			ptr--;
-		}
-		if (flags & TUNNEL_CSUM &&
-		    !(skb_shinfo(skb)->gso_type &
-		      (SKB_GSO_GRE | SKB_GSO_GRE_CSUM))) {
-			*ptr = 0;
-			*(__sum16 *)ptr = gre_checksum(skb);
-		}
-	}
-}
-
 static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 		       const struct iphdr *tnl_params,
 		       __be16 proto)
@@ -382,8 +339,9 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 		tunnel->o_seqno++;
 
 	/* Push GRE header. */
-	build_header(skb, tunnel->tun_hlen, tunnel->parms.o_flags,
-		     proto, tunnel->parms.o_key, htonl(tunnel->o_seqno));
+	gre_build_header(skb, tunnel->tun_hlen,
+			 tunnel->parms.o_flags, proto, tunnel->parms.o_key,
+			 htonl(tunnel->o_seqno));
 
 	skb_set_inner_protocol(skb, proto);
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
@@ -460,8 +418,8 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_free_rt;
 
 	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
-	build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
-		     tunnel_id_to_key(tun_info->key.tun_id), 0);
+	gre_build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
+			 tunnel_id_to_key(tun_info->key.tun_id), 0);
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
 
-- 
2.8.0.rc2
