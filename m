From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/5] net: flow_dissector: add support for dissection of tcp flags
Date: Tue, 23 May 2017 18:40:44 +0200
Message-ID: <20170523164048.16514-2-jiri@resnulli.us>
References: <20170523164048.16514-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36025 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763437AbdEWQkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:40:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so39524004wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:40:52 -0700 (PDT)
In-Reply-To: <20170523164048.16514-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add support for dissection of tcp flags. Uses similar function call to
tcp dissection function as arp, mpls and others.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/net/flow_dissector.h |  9 +++++++++
 net/core/flow_dissector.c    | 29 +++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 8d21d44..efe34eec 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -157,6 +157,14 @@ struct flow_dissector_key_eth_addrs {
 	unsigned char src[ETH_ALEN];
 };
 
+/**
+ * struct flow_dissector_key_tcp:
+ * @flags: flags
+ */
+struct flow_dissector_key_tcp {
+	__be16 flags;
+};
+
 enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
@@ -177,6 +185,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_ENC_CONTROL, /* struct flow_dissector_key_control */
 	FLOW_DISSECTOR_KEY_ENC_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
+	FLOW_DISSECTOR_KEY_TCP, /* struct flow_dissector_key_tcp */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 28d94bc..5a45943 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -18,6 +18,7 @@
 #include <linux/stddef.h>
 #include <linux/if_ether.h>
 #include <linux/mpls.h>
+#include <linux/tcp.h>
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
@@ -342,6 +343,30 @@ __skb_flow_dissect_gre(const struct sk_buff *skb,
 	return FLOW_DISSECT_RET_OUT_PROTO_AGAIN;
 }
 
+static void
+__skb_flow_dissect_tcp(const struct sk_buff *skb,
+		       struct flow_dissector *flow_dissector,
+		       void *target_container, void *data, int thoff, int hlen)
+{
+	struct flow_dissector_key_tcp *key_tcp;
+	struct tcphdr *th, _th;
+
+	if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_TCP))
+		return;
+
+	th = __skb_header_pointer(skb, thoff, sizeof(_th), data, hlen, &_th);
+	if (!th)
+		return;
+
+	if (unlikely(__tcp_hdrlen(th) < sizeof(_th)))
+		return;
+
+	key_tcp = skb_flow_dissector_target(flow_dissector,
+					    FLOW_DISSECTOR_KEY_TCP,
+					    target_container);
+	key_tcp->flags = (*(__be16 *) &tcp_flag_word(th) & htons(0x0FFF));
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -683,6 +708,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case IPPROTO_MPLS:
 		proto = htons(ETH_P_MPLS_UC);
 		goto mpls;
+	case IPPROTO_TCP:
+		__skb_flow_dissect_tcp(skb, flow_dissector, target_container,
+				       data, nhoff, hlen);
+		break;
 	default:
 		break;
 	}
-- 
2.9.3
