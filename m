From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] udp: In udp_flow_src_port use random hash value if skb_get_hash fails
Date: Tue, 24 Feb 2015 09:17:31 -0800
Message-ID: <1424798251-21075-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:32968 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbbBXRRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 12:17:48 -0500
Received: by iecar1 with SMTP id ar1so33933037iec.0
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 09:17:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the unlikely event that skb_get_hash is unable to deduce a hash
in udp_flow_src_port we use a consistent random value instead.
This is specified in GRE/UDP draft section 3.2.1:
https://tools.ietf.org/html/draft-ietf-tsvwg-gre-in-udp-encap-04

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp.h | 21 +++++++++++++++------
 net/ipv4/udp.c    | 10 ++++++++++
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 07f9b70..32d8d9f 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -194,6 +194,8 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		     int (*)(const struct sock *, const struct sock *),
 		     unsigned int hash2_nulladdr);
 
+u32 udp_flow_hashrnd(void);
+
 static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 				       int min, int max, bool use_eth)
 {
@@ -205,12 +207,19 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 	}
 
 	hash = skb_get_hash(skb);
-	if (unlikely(!hash) && use_eth) {
-		/* Can't find a normal hash, caller has indicated an Ethernet
-		 * packet so use that to compute a hash.
-		 */
-		hash = jhash(skb->data, 2 * ETH_ALEN,
-			     (__force u32) skb->protocol);
+	if (unlikely(!hash)) {
+		if (use_eth) {
+			/* Can't find a normal hash, caller has indicated an
+			 * Ethernet packet so use that to compute a hash.
+			 */
+			hash = jhash(skb->data, 2 * ETH_ALEN,
+				     (__force u32) skb->protocol);
+		} else {
+			/* Can't derive any sort of hash for the packet, set
+			 * to some consistent random value.
+			 */
+			hash = udp_flow_hashrnd();
+		}
 	}
 
 	/* Since this is being sent on the wire obfuscate hash a bit
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 97ef1f8b..0224f93 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2525,6 +2525,16 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 	}
 }
 
+u32 udp_flow_hashrnd(void)
+{
+	static u32 hashrnd __read_mostly;
+
+	net_get_random_once(&hashrnd, sizeof(hashrnd));
+
+	return hashrnd;
+}
+EXPORT_SYMBOL(udp_flow_hashrnd);
+
 void __init udp_init(void)
 {
 	unsigned long limit;
-- 
2.2.0.rc0.207.ga3a616c
