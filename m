From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] gre: do not pull header in ICMP error processing
Date: Fri, 29 Apr 2016 23:31:32 +0200
Message-ID: <666d05a8cff4a89ce4fd77810902246aa3e7a13f.1461965458.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838AbcD2VcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 17:32:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iptunnel_pull_header expects that IP header was already pulled; with this
expectation, it pulls the tunnel header. This is not true in gre_err.
Furthermore, ipv4_update_pmtu and ipv4_redirect expect that skb->data points
to the IP header.

We cannot pull the tunnel header in this path. It's just a matter of not
calling iptunnel_pull_header - we don't need any of its effects.

Fixes: bda7bb463436 ("gre: Allow multiple protocol listener for gre protocol.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f502d34bcb40..205a2b8a5a84 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -179,6 +179,7 @@ static __be16 tnl_flags_to_gre_flags(__be16 tflags)
 	return flags;
 }
 
+/* Fills in tpi and returns header length to be pulled. */
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err)
 {
@@ -238,7 +239,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 				return -EINVAL;
 		}
 	}
-	return iptunnel_pull_header(skb, hdr_len, tpi->proto, false);
+	return hdr_len;
 }
 
 static void ipgre_err(struct sk_buff *skb, u32 info,
@@ -341,7 +342,7 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	struct tnl_ptk_info tpi;
 	bool csum_err = false;
 
-	if (parse_gre_header(skb, &tpi, &csum_err)) {
+	if (parse_gre_header(skb, &tpi, &csum_err) < 0) {
 		if (!csum_err)		/* ignore csum errors. */
 			return;
 	}
@@ -419,6 +420,7 @@ static int gre_rcv(struct sk_buff *skb)
 {
 	struct tnl_ptk_info tpi;
 	bool csum_err = false;
+	int hdr_len;
 
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	if (ipv4_is_multicast(ip_hdr(skb)->daddr)) {
@@ -428,7 +430,10 @@ static int gre_rcv(struct sk_buff *skb)
 	}
 #endif
 
-	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
+	hdr_len = parse_gre_header(skb, &tpi, &csum_err);
+	if (hdr_len < 0)
+		goto drop;
+	if (iptunnel_pull_header(skb, hdr_len, tpi.proto, false) < 0)
 		goto drop;
 
 	if (ipgre_rcv(skb, &tpi) == PACKET_RCVD)
-- 
1.8.3.1
