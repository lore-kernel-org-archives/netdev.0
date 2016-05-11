From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] gre: Fix wrong tpi->proto in WCCP
Date: Wed, 11 May 2016 18:48:32 +0800
Message-ID: <1462963712-13781-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1462963712-13781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Dmitry Kozlov <xeb@mail.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462963712-13781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When dealing with WCCP in gre6 tunnel, it sets the wrong tpi->protocol,
that is, ETH_P_IP instead of ETH_P_IPV6 for the encapuslated traffic.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/gre.h    | 2 +-
 net/ipv4/gre_demux.c | 6 +++---
 net/ipv4/ip_gre.c    | 4 ++--
 net/ipv6/ip6_gre.c   | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index a14093c..5dce30a 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -26,7 +26,7 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 				       u8 name_assign_type);
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-		     bool *csum_err);
+		     bool *csum_err, __be16 proto);
 
 static inline int gre_calc_hlen(__be16 o_flags)
 {
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index d78e2ee..4c39f4f 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL_GPL(gre_del_protocol);
 
 /* Fills in tpi and returns header length to be pulled. */
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-		     bool *csum_err)
+		     bool *csum_err, __be16 proto)
 {
 	const struct gre_base_hdr *greh;
 	__be32 *options;
@@ -109,11 +109,11 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 		tpi->seq = 0;
 	}
 	/* WCCP version 1 and 2 protocol decoding.
-	 * - Change protocol to IP
+	 * - Change protocol to IPv4/IPv6
 	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
 	 */
 	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
-		tpi->proto = htons(ETH_P_IP);
+		tpi->proto = proto;
 		if ((*(u8 *)options & 0xF0) != 0x40)
 			hdr_len += 4;
 	}
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2b267e7..aaeb478 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -222,7 +222,7 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	struct tnl_ptk_info tpi;
 	bool csum_err = false;
 
-	if (gre_parse_header(skb, &tpi, &csum_err) < 0) {
+	if (gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP)) < 0) {
 		if (!csum_err)		/* ignore csum errors. */
 			return;
 	}
@@ -335,7 +335,7 @@ static int gre_rcv(struct sk_buff *skb)
 	}
 #endif
 
-	hdr_len = gre_parse_header(skb, &tpi, &csum_err);
+	hdr_len = gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IP));
 	if (hdr_len < 0)
 		goto drop;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3c25fe6..4541fa5 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -468,7 +468,7 @@ static int gre_rcv(struct sk_buff *skb)
 	bool csum_err = false;
 	int hdr_len;
 
-	hdr_len = gre_parse_header(skb, &tpi, &csum_err);
+	hdr_len = gre_parse_header(skb, &tpi, &csum_err, htons(ETH_P_IPV6));
 	if (hdr_len < 0)
 		goto drop;
 
-- 
1.8.3.1
