From: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Subject: [PATCH v3] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 10:31:29 +0200
Message-ID: <1445848289-26106-1-git-send-email-emmanuel.grumbach@intel.com>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: linux-wireless@vger.kernel.org, egrumbach@gmail.com,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20680 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbbJZIbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 04:31:36 -0400
In-Reply-To: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding IPv6 for the TSO helper API is trivial:
* Don't play with the id (which doesn't exist in IPv6)
* Correctly update the payload_len (don't include the
  length of the IP header itself)

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
---
v3: use vlan_get_protocol and call it once in tso_start
    store the result in tso_t
---
 include/net/tso.h |  1 +
 net/core/tso.c    | 18 +++++++++++++-----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/net/tso.h b/include/net/tso.h
index 47e5444..b7be852 100644
--- a/include/net/tso.h
+++ b/include/net/tso.h
@@ -8,6 +8,7 @@ struct tso_t {
 	void *data;
 	size_t size;
 	u16 ip_id;
+	bool ipv6;
 	u32 tcp_seq;
 };
 
diff --git a/net/core/tso.c b/net/core/tso.c
index 630b30b..5dca7ce 100644
--- a/net/core/tso.c
+++ b/net/core/tso.c
@@ -1,4 +1,5 @@
 #include <linux/export.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/tso.h>
 #include <asm/unaligned.h>
@@ -14,18 +15,24 @@ EXPORT_SYMBOL(tso_count_descs);
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
+	if (!tso->ipv6) {
+		struct iphdr *iph = (void *)(hdr + mac_hdr_len);
+
+		iph->id = htons(tso->ip_id);
+		iph->tot_len = htons(size + hdr_len - mac_hdr_len);
+		tso->ip_id++;
+	} else {
+		struct ipv6hdr *iph = (void *)(hdr + mac_hdr_len);
+
+		iph->payload_len = htons(size + tcp_hdrlen(skb));
+	}
 	tcph = (struct tcphdr *)(hdr + skb_transport_offset(skb));
 	put_unaligned_be32(tso->tcp_seq, &tcph->seq);
-	tso->ip_id++;
 
 	if (!is_last) {
 		/* Clear all special flags for not last packet */
@@ -61,6 +68,7 @@ void tso_start(struct sk_buff *skb, struct tso_t *tso)
 	tso->ip_id = ntohs(ip_hdr(skb)->id);
 	tso->tcp_seq = ntohl(tcp_hdr(skb)->seq);
 	tso->next_frag_idx = 0;
+	tso->ipv6 = vlan_get_protocol(skb) == htons(ETH_P_IPV6);
 
 	/* Build first data */
 	tso->size = skb_headlen(skb) - hdr_len;
-- 
2.1.4
