From: pablo@netfilter.org
Subject: [PATCH 4/7] ipvs: fix sctp chunk length order
Date: Wed, 20 Mar 2013 11:49:31 +0100
Message-ID: <1363776574-4766-5-git-send-email-pablo@netfilter.org>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51293 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab3CTKtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 06:49:51 -0400
In-Reply-To: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

Fix wrong but non-fatal access to chunk length.
sch->length should be in network order, next chunk should
be aligned to 4 bytes. Problem noticed in sparse output.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index ae8ec6f..cd1d729 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -906,7 +906,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	sctp_chunkhdr_t _sctpch, *sch;
 	unsigned char chunk_type;
 	int event, next_state;
-	int ihl;
+	int ihl, cofs;
 
 #ifdef CONFIG_IP_VS_IPV6
 	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
@@ -914,8 +914,8 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	ihl = ip_hdrlen(skb);
 #endif
 
-	sch = skb_header_pointer(skb, ihl + sizeof(sctp_sctphdr_t),
-				sizeof(_sctpch), &_sctpch);
+	cofs = ihl + sizeof(sctp_sctphdr_t);
+	sch = skb_header_pointer(skb, cofs, sizeof(_sctpch), &_sctpch);
 	if (sch == NULL)
 		return;
 
@@ -933,10 +933,12 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	 */
 	if ((sch->type == SCTP_CID_COOKIE_ECHO) ||
 	    (sch->type == SCTP_CID_COOKIE_ACK)) {
-		sch = skb_header_pointer(skb, (ihl + sizeof(sctp_sctphdr_t) +
-				sch->length), sizeof(_sctpch), &_sctpch);
-		if (sch) {
-			if (sch->type == SCTP_CID_ABORT)
+		int clen = ntohs(sch->length);
+
+		if (clen >= sizeof(sctp_chunkhdr_t)) {
+			sch = skb_header_pointer(skb, cofs + ALIGN(clen, 4),
+						 sizeof(_sctpch), &_sctpch);
+			if (sch && sch->type == SCTP_CID_ABORT)
 				chunk_type = sch->type;
 		}
 	}
-- 
1.7.10.4
