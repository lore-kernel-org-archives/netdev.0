From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/15] flow_dissector: introduce support for ipv6 addressses
Date: Sat,  9 May 2015 15:10:35 +0200
Message-ID: <1431177038-11555-13-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37461 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbEINL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:11:29 -0400
Received: by widdi4 with SMTP id di4so53543503wid.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:11:28 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, only hashes made out of ipv6 addresses could be dissected. This
patch introduces support for dissection of full ipv6 addresses.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 13 +++++++++++++
 net/core/flow_dissector.c    | 29 +++++++++++++++++++++--------
 2 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 1add891..586b123 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <linux/skbuff.h>
+#include <linux/in6.h>
 
 /**
  * struct flow_dissector_key_basic:
@@ -42,11 +43,23 @@ struct flow_dissector_key_ports {
 	};
 };
 
+/**
+ * struct flow_dissector_key_ipv6_addrs:
+ * @src: source ip address
+ * @dst: destination ip address
+ */
+struct flow_dissector_key_ipv6_addrs {
+	/* (src,dst) must be grouped, in the same way than in IP header */
+	struct in6_addr src;
+	struct in6_addr dst;
+};
+
 enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
+	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 6a49aca..1b95d5c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -175,16 +175,29 @@ ipv6:
 		ip_proto = iph->nexthdr;
 		nhoff += sizeof(struct ipv6hdr);
 
-		if (!skb_flow_dissector_uses_key(flow_dissector,
-						 FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS))
-			break;
-		key_addrs = skb_flow_dissector_target(flow_dissector,
-						      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
-						      target_container);
+		if (skb_flow_dissector_uses_key(flow_dissector,
+						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
+			key_addrs = skb_flow_dissector_target(flow_dissector,
+							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
+							      target_container);
 
-		key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
-		key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
+			key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
+			key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
+			goto flow_label;
+		}
+		if (skb_flow_dissector_uses_key(flow_dissector,
+						FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
+			struct flow_dissector_key_ipv6_addrs *key_ipv6_addrs;
 
+			key_ipv6_addrs = skb_flow_dissector_target(flow_dissector,
+								   FLOW_DISSECTOR_KEY_IPV6_ADDRS,
+								   target_container);
+
+			memcpy(key_ipv6_addrs, &iph->saddr, sizeof(*key_ipv6_addrs));
+			goto flow_label;
+		}
+		break;
+flow_label:
 		flow_label = ip6_flowlabel(iph);
 		if (flow_label) {
 			/* Awesome, IPv6 packet has a flow label so we can
-- 
1.9.3
