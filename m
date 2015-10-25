From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [PATCH] net: tso: add support for IPv6
Date: Sun, 25 Oct 2015 21:58:27 +0200
Message-ID: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: linux-wireless@vger.kernel.org, egrumbach@gmail.com,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62164 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbbJYT6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2015 15:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding IPv6 for the TSO helper API is trivial:
* Don't play with the id (which doesn't exist in IPv6)
* Correctly update the payload_len (don't include the
  length of the IP header itself)

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
 net/core/tso.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/tso.c b/net/core/tso.c
index 630b30b..ece4605 100644
--- a/net/core/tso.c
+++ b/net/core/tso.c
@@ -14,18 +14,25 @@ EXPORT_SYMBOL(tso_count_descs);
 void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
 		   int size, bool is_last)
 {
-	struct iphdr *iph;
 	struct tcphdr *tcph;
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	int mac_hdr_len = skb_network_offset(skb);
 
 	memcpy(hdr, skb->data, hdr_len);
-	iph = (struct iphdr *)(hdr + mac_hdr_len);
-	iph->id = htons(tso->ip_id);
-	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = (void *)(hdr + mac_hdr_len);
+
+		iph->id = htons(tso->ip_id);
+		iph->tot_len = htons(size + hdr_len - mac_hdr_len);
+		tso->ip_id++;
+	}
+	if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *iph = (void *)(hdr + mac_hdr_len);
+
+		iph->payload_len = htons(size + tcp_hdrlen(skb));
+	}
 	tcph = (struct tcphdr *)(hdr + skb_transport_offset(skb));
 	put_unaligned_be32(tso->tcp_seq, &tcph->seq);
-	tso->ip_id++;
 
 	if (!is_last) {
 		/* Clear all special flags for not last packet */
-- 
2.1.4
