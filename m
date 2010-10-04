From: David Miller <davem@davemloft.net>
Subject: ipvs: Use frag walker helper in SCTP proto support.
Date: Sun, 03 Oct 2010 23:46:01 -0700 (PDT)
Message-ID: <20101003.234601.232735559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: horms@verge.net.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 4c0855c..2f982a4 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -61,6 +61,7 @@ sctp_snat_handler(struct sk_buff *skb,
 {
 	sctp_sctphdr_t *sctph;
 	unsigned int sctphoff;
+	struct sk_buff *iter;
 	__be32 crc32;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -89,8 +90,8 @@ sctp_snat_handler(struct sk_buff *skb,
 
 	/* Calculate the checksum */
 	crc32 = sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
-	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next)
-		crc32 = sctp_update_cksum((u8 *) skb->data, skb_headlen(skb),
+	skb_walk_frags(skb, iter)
+		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
 				          crc32);
 	crc32 = sctp_end_cksum(crc32);
 	sctph->checksum = crc32;
@@ -102,9 +103,9 @@ static int
 sctp_dnat_handler(struct sk_buff *skb,
 		  struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
-
 	sctp_sctphdr_t *sctph;
 	unsigned int sctphoff;
+	struct sk_buff *iter;
 	__be32 crc32;
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -133,8 +134,8 @@ sctp_dnat_handler(struct sk_buff *skb,
 
 	/* Calculate the checksum */
 	crc32 = sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
-	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next)
-		crc32 = sctp_update_cksum((u8 *) skb->data, skb_headlen(skb),
+	skb_walk_frags(skb, iter)
+		crc32 = sctp_update_cksum((u8 *) iter->data, skb_headlen(iter),
 					  crc32);
 	crc32 = sctp_end_cksum(crc32);
 	sctph->checksum = crc32;
@@ -145,9 +146,9 @@ sctp_dnat_handler(struct sk_buff *skb,
 static int
 sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 {
-	struct sk_buff *list = skb_shinfo(skb)->frag_list;
 	unsigned int sctphoff;
 	struct sctphdr *sh, _sctph;
+	struct sk_buff *iter;
 	__le32 cmp;
 	__le32 val;
 	__u32 tmp;
@@ -166,9 +167,9 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 	cmp = sh->checksum;
 
 	tmp = sctp_start_cksum((__u8 *) sh, skb_headlen(skb));
-	for (; list; list = list->next)
-		tmp = sctp_update_cksum((__u8 *) list->data,
-					skb_headlen(list), tmp);
+	skb_walk_frags(skb, iter)
+		tmp = sctp_update_cksum((__u8 *) iter->data,
+					skb_headlen(iter), tmp);
 
 	val = sctp_end_cksum(tmp);
 
-- 
1.7.3.1

