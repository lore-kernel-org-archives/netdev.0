From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/4] net: flow_dissector: add __skb_get_poff to get a start offset to payload
Date: Tue, 19 Mar 2013 14:28:25 +0100
Message-ID: <74269b9aada15ffa486a259e5611909715e55d1f.1363699285.git.dborkman@redhat.com>
References: <cover.1363699285.git.dborkman@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jasowang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362Ab3CSN2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 09:28:34 -0400
In-Reply-To: <cover.1363699285.git.dborkman@redhat.com>
In-Reply-To: <cover.1363699285.git.dborkman@redhat.com>
References: <cover.1363699285.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__skb_get_poff() returns the offset to the payload as far as it could
be dissected. The main user is currently BPF, so that we can dynamically
truncate packets without needing to push actual payload to the user
space and instead can analyze headers only.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/skbuff.h    |  2 ++
 net/core/flow_dissector.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index eb2106f..0e84fd8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2835,6 +2835,8 @@ static inline void skb_checksum_none_assert(const struct sk_buff *skb)
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
+u32 __skb_get_poff(const struct sk_buff *skb);
+
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
  * @skb: skb to check
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index eb9dde1..8213da7 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -5,6 +5,10 @@
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <linux/igmp.h>
+#include <linux/icmp.h>
+#include <linux/sctp.h>
+#include <linux/dccp.h>
 #include <linux/if_tunnel.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
@@ -229,6 +233,59 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
+/* __skb_get_poff() returns the offset to the payload as far as it could
+ * be dissected. The main user is currently BPF, so that we can dynamically
+ * truncate packets without needing to push actual payload to the user
+ * space and can analyze headers only, instead.
+ */
+u32 __skb_get_poff(const struct sk_buff *skb)
+{
+	struct flow_keys keys;
+	u32 poff = 0;
+
+	if (!skb_flow_dissect(skb, &keys))
+		return 0;
+
+	poff += keys.thoff;
+	switch (keys.ip_proto) {
+	case IPPROTO_TCP: {
+		const struct tcphdr *tcph;
+		struct tcphdr _tcph;
+
+		tcph = skb_header_pointer(skb, poff, sizeof(_tcph), &_tcph);
+		if (!tcph)
+			return poff;
+
+		poff += max_t(u32, sizeof(struct tcphdr), tcph->doff * 4);
+		break;
+	}
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
+		poff += sizeof(struct udphdr);
+		break;
+	/* For the rest, we do not really care about header
+	 * extensions at this point for now.
+	 */
+	case IPPROTO_ICMP:
+		poff += sizeof(struct icmphdr);
+		break;
+	case IPPROTO_ICMPV6:
+		poff += sizeof(struct icmp6hdr);
+		break;
+	case IPPROTO_IGMP:
+		poff += sizeof(struct igmphdr);
+		break;
+	case IPPROTO_DCCP:
+		poff += sizeof(struct dccp_hdr);
+		break;
+	case IPPROTO_SCTP:
+		poff += sizeof(struct sctphdr);
+		break;
+	}
+
+	return poff;
+}
+
 static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
-- 
1.7.11.7
