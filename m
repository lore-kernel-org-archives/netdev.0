From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 13/15] flow_dissector: introduce support for Ethernet addresses
Date: Fri, 24 Apr 2015 17:51:39 +0200
Message-ID: <1429890701-30052-14-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36013 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031329AbbDXPwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:52:07 -0400
Received: by wizk4 with SMTP id k4so27231660wiz.1
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:52:06 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 13 +++++++++++++
 net/core/flow_dissector.c    | 12 ++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 7c9e84c..1fa625b 100644
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
index 95e9a21..b5e260e 100644
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
