From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/8] udp: Add function to make source port for UDP tunnels
Date: Tue, 1 Jul 2014 21:32:39 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012058220.22605@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:52696 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbaGBEck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:32:40 -0400
Received: by mail-yh0-f74.google.com with SMTP id b6so1170667yha.3
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:32:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds udp_flow_src_port function which is intended to be
a common function that UDP tunnel implementations call to set the source
port. The source port is chosen so that a hash over the outer headers
(IP addresses and UDP ports) acts as suitable hash for the flow of the
encapsulated packet. In this manner, UDP encapsulation works with RSS
and ECMP based wrt the inner flow.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp.h | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 68a1fef..70f9413 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -176,6 +176,35 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		     int (*)(const struct sock *, const struct sock *),
 		     unsigned int hash2_nulladdr);
 
+static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
+				       int min, int max, bool use_eth)
+{
+	u32 hash;
+
+	if (min >= max) {
+		/* Use default range */
+		inet_get_local_port_range(net, &min, &max);
+	}
+
+	hash = skb_get_hash(skb);
+	if (unlikely(!hash) && use_eth) {
+		/* Can't find a normal hash, caller has indicated an Ethernet
+		 * packet so use that to compute a hash.
+		 */
+		hash = jhash(skb->data, 2 * ETH_ALEN,
+			     (__force u32) skb->protocol);
+	}
+
+	/* Since this is being sent on the wire obfuscate hash a bit
+	 * to minimize possbility that any useful information to an
+	 * attacker is leaked. Only upper 16 bits are relevant in the
+	 * computation for 16 bit port value.
+	 */
+	hash ^= hash << 16;
+
+	return htons((((u64) hash * (max - min)) >> 32) + min);
+}
+
 /* net/ipv4/udp.c */
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
-- 
2.0.0.526.g5318336
