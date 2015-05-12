From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 13/15] flow_dissector: introduce support for Ethernet addresses
Date: Tue, 12 May 2015 09:39:21 +0200
Message-ID: <1431416363-5675-14-git-send-email-jiri@resnulli.us>
References: <1431416363-5675-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33240 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbbELHkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 03:40:22 -0400
Received: by wgin8 with SMTP id n8so155464376wgi.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 00:40:21 -0700 (PDT)
In-Reply-To: <1431416363-5675-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 13 +++++++++++++
 net/core/flow_dissector.c    | 12 ++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 586b123..5eac987 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 #include <linux/skbuff.h>
 #include <linux/in6.h>
+#include <uapi/linux/if_ether.h>
 
 /**
  * struct flow_dissector_key_basic:
@@ -54,12 +55,24 @@ struct flow_dissector_key_ipv6_addrs {
 	struct in6_addr dst;
 };
 
+/**
+ * struct flow_dissector_key_eth_addrs:
+ * @src: source Ethernet address
+ * @dst: destination Ethernet address
+ */
+struct flow_dissector_key_eth_addrs {
+	/* (dst,src) must be grouped, in the same way than in ETH header */
+	unsigned char dst[ETH_ALEN];
+	unsigned char src[ETH_ALEN];
+};
+
 enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
+	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1b95d5c..7a0b391 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -14,6 +14,7 @@
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
 #include <linux/stddef.h>
+#include <linux/if_ether.h>
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
@@ -138,6 +139,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 					      FLOW_DISSECTOR_KEY_BASIC,
 					      target_container);
 
+	if (skb_flow_dissector_uses_key(flow_dissector,
+					FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
+		struct ethhdr *eth = eth_hdr(skb);
+		struct flow_dissector_key_eth_addrs *key_eth_addrs;
+
+		key_eth_addrs = skb_flow_dissector_target(flow_dissector,
+							  FLOW_DISSECTOR_KEY_ETH_ADDRS,
+							  target_container);
+		memcpy(key_eth_addrs, &eth->h_dest, sizeof(*key_eth_addrs));
+	}
+
 again:
 	switch (proto) {
 	case htons(ETH_P_IP): {
-- 
1.9.3
