From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 03/12] gre: export gre_build_header() function.
Date: Thu, 13 Jun 2013 11:24:23 -0700
Message-ID: <1371147863-9205-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:60622 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758962Ab3FMSYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:24:49 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro2so10652830pbb.13
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:24:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required for ovs gre module.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/gre.h |    2 ++
 net/ipv4/gre.c    |   32 ++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c |   40 +---------------------------------------
 3 files changed, 35 insertions(+), 39 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index c6ea0c7..cbb9d51 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -32,6 +32,8 @@ struct gre_cisco_protocol {
 
 int gre_cisco_register(struct gre_cisco_protocol *proto);
 int gre_cisco_unregister(struct gre_cisco_protocol *proto);
+void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
+		      int hdr_len);
 
 static inline int ip_gre_calc_hlen(__be16 o_flags)
 {
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 8b9a373..1cbc465 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -61,6 +61,38 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
+void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
+		      int hdr_len)
+{
+	struct gre_base_hdr *greh;
+
+	skb_push(skb, hdr_len);
+
+	greh = (struct gre_base_hdr *)skb->data;
+	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
+	greh->protocol = tpi->proto;
+
+	if (tpi->flags&(TUNNEL_KEY|TUNNEL_CSUM|TUNNEL_SEQ)) {
+		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
+
+		if (tpi->flags&TUNNEL_SEQ) {
+			*ptr = tpi->seq;
+			ptr--;
+		}
+		if (tpi->flags&TUNNEL_KEY) {
+			*ptr = tpi->key;
+			ptr--;
+		}
+		if (tpi->flags&TUNNEL_CSUM &&
+		    !(skb_shinfo(skb)->gso_type & SKB_GSO_GRE)) {
+			*ptr = 0;
+			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
+								 skb->len, 0));
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(gre_build_header);
+
 static __sum16 check_checksum(struct sk_buff *skb)
 {
 	__sum16 csum = 0;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 19863a8..362c7c4 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -248,40 +248,6 @@ error:
 	return ERR_PTR(err);
 }
 
-static struct sk_buff *gre_build_header(struct sk_buff *skb,
-					const struct tnl_ptk_info *tpi,
-					int hdr_len)
-{
-	struct gre_base_hdr *greh;
-
-	skb_push(skb, hdr_len);
-
-	greh = (struct gre_base_hdr *)skb->data;
-	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
-	greh->protocol = tpi->proto;
-
-	if (tpi->flags&(TUNNEL_KEY|TUNNEL_CSUM|TUNNEL_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
-
-		if (tpi->flags&TUNNEL_SEQ) {
-			*ptr = tpi->seq;
-			ptr--;
-		}
-		if (tpi->flags&TUNNEL_KEY) {
-			*ptr = tpi->key;
-			ptr--;
-		}
-		if (tpi->flags&TUNNEL_CSUM &&
-		    !(skb_shinfo(skb)->gso_type & SKB_GSO_GRE)) {
-			*(__sum16 *)ptr = 0;
-			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
-								 skb->len, 0));
-		}
-	}
-
-	return skb;
-}
-
 static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 		       const struct iphdr *tnl_params,
 		       __be16 proto)
@@ -302,11 +268,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	tpi.seq = htonl(tunnel->o_seqno);
 
 	/* Push GRE header. */
-	skb = gre_build_header(skb, &tpi, tunnel->hlen);
-	if (unlikely(!skb)) {
-		dev->stats.tx_dropped++;
-		return;
-	}
+	gre_build_header(skb, &tpi, tunnel->hlen);
 
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
-- 
1.7.1
