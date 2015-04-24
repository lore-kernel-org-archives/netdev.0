From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 09/15] flow_dissector: introduce programable flow_dissector
Date: Fri, 24 Apr 2015 17:51:35 +0200
Message-ID: <1429890701-30052-10-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:35521 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031301AbbDXPwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:52:00 -0400
Received: by wgyo15 with SMTP id o15so55181347wgy.2
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:59 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce dissector infrastructure which allows user to specify which
parts of skb he wants to dissect.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 61 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/flow_dissector.c    | 48 ++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 8a5bf48..3bdf6a1 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -1,6 +1,64 @@
 #ifndef _NET_FLOW_DISSECTOR_H
 #define _NET_FLOW_DISSECTOR_H
 
+/**
+ * struct flow_dissector_key_basic:
+ * @thoff: Transport header offset
+ * @n_proto: Network header protocol (eg. IPv4/IPv6)
+ * @ip_proto: Transport header protocol (eg. TCP/UDP)
+ */
+struct flow_dissector_key_basic {
+	u16	thoff;
+	__be16	n_proto;
+	u8	ip_proto;
+};
+
+/**
+ * struct flow_dissector_key_addrs:
+ * @src: source ip address in case of IPv4
+ *	 For IPv6 it contains 32bit hash of src address
+ * @dst: destination ip address in case of IPv4
+ *	 For IPv6 it contains 32bit hash of dst address
+ */
+struct flow_dissector_key_addrs {
+	/* (src,dst) must be grouped, in the same way than in IP header */
+	__be32 src;
+	__be32 dst;
+};
+
+/**
+ * flow_dissector_key_tp_ports:
+ *	@ports: port numbers of Transport header
+ *		port16[0]: src port number
+ *		port16[1]: dst port number
+ */
+struct flow_dissector_key_ports {
+	union {
+		__be32 ports;
+		__be16 port16[2];
+	};
+};
+
+enum flow_dissector_key_id {
+	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
+	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
+	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
+	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
+
+	FLOW_DISSECTOR_KEY_MAX,
+};
+
+struct flow_dissector_key {
+	enum flow_dissector_key_id key_id;
+	size_t offset; /* offset of struct flow_dissector_key_*
+			  in target the struct */
+};
+
+struct flow_dissector {
+	unsigned int used_keys; /* each bit repesents presence of one key id */
+	unsigned short int offset[FLOW_DISSECTOR_KEY_MAX];
+};
+
 /* struct flow_keys:
  *	@src: source ip address in case of IPv4
  *	      For IPv6 it contains 32bit hash of src address
@@ -27,6 +85,9 @@ struct flow_keys {
 	u8	ip_proto;
 };
 
+void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
+			     const struct flow_dissector_key *key,
+			     unsigned int key_count);
 bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
 			void *data, __be16 proto, int nhoff, int hlen);
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5213d73..1566768 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -1,3 +1,4 @@
+#include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/export.h>
 #include <linux/ip.h>
@@ -15,6 +16,53 @@
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
+static bool skb_flow_dissector_uses_key(struct flow_dissector *flow_dissector,
+					enum flow_dissector_key_id key_id)
+{
+	return flow_dissector->used_keys & (1 << key_id);
+}
+
+static void skb_flow_dissector_set_key(struct flow_dissector *flow_dissector,
+				       enum flow_dissector_key_id key_id)
+{
+	flow_dissector->used_keys |= (1 << key_id);
+}
+
+static void *skb_flow_dissector_target(struct flow_dissector *flow_dissector,
+				       enum flow_dissector_key_id key_id,
+				       void *target_container)
+{
+	return ((char *) target_container) + flow_dissector->offset[key_id];
+}
+
+void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
+			     const struct flow_dissector_key *key,
+			     unsigned int key_count)
+{
+	unsigned int i;
+
+	memset(flow_dissector, 0, sizeof(*flow_dissector));
+
+	for (i = 0; i < key_count; i++, key++) {
+		/* User should make sure that every key target offset is withing
+		 * boundaries of unsigned short.
+		 */
+		BUG_ON(key->offset > USHRT_MAX);
+		BUG_ON(skb_flow_dissector_uses_key(flow_dissector,
+						   key->key_id));
+
+		skb_flow_dissector_set_key(flow_dissector, key->key_id);
+		flow_dissector->offset[key->key_id] = key->offset;
+	}
+
+	/* Ensure that the dissector always includes basic key. That way
+	 * we are able to avoid handling lack of it in fast path.
+	 */
+	BUG_ON(!skb_flow_dissector_uses_key(flow_dissector,
+					    FLOW_DISSECTOR_KEY_BASIC));
+}
+EXPORT_SYMBOL(skb_flow_dissector_init);
+
 /* copy saddr & daddr, possibly using 64bit load/store
  * Equivalent to :	flow->src = iph->saddr;
  *			flow->dst = iph->daddr;
-- 
1.9.3
