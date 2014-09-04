From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 1/3] net: Add function for parsing the header length out
 of linear ethernet frames
Date: Thu, 04 Sep 2014 19:13:33 -0400
Message-ID: <20140904231333.12376.9881.stgit@ahduyck-bv4.jf.intel.com>
References: <20140904230958.12376.2845.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17306 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725AbaIDXWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 19:22:40 -0400
In-Reply-To: <20140904230958.12376.2845.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates some of the flow_dissector api so that it can be used to
parse the length of ethernet buffers stored in fragments.  Most of the
changes needed were to __skb_get_poff as it needed to be updated to support
sending a linear buffer instead of a skb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/etherdevice.h |    1 +
 include/linux/skbuff.h      |    2 ++
 include/net/flow_keys.h     |    2 ++
 net/core/flow_dissector.c   |   41 ++++++++++++++++++++++++++---------------
 net/ethernet/eth.c          |   27 +++++++++++++++++++++++++++
 5 files changed, 58 insertions(+), 15 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 9c5529d..733980f 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -29,6 +29,7 @@
 #include <asm/bitsperlong.h>
 
 #ifdef __KERNEL__
+u32 eth_get_headlen(void *data, unsigned int max_len);
 __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev);
 extern const struct header_ops eth_header_ops;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 02529fc..77d4d6f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3217,6 +3217,8 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
 u32 __skb_get_poff(const struct sk_buff *skb);
+u32 ___skb_get_poff(const struct sk_buff *skb, void *data,
+	 	    const struct flow_keys *keys, int hlen);
 
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 9a03f73..7ee2df0 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -40,4 +40,6 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8
 	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
 }
 u32 flow_hash_from_keys(struct flow_keys *keys);
+unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
+			   __be16 protocol);
 #endif
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 12f48ca..f55667e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -13,6 +13,7 @@
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
 #include <net/flow_keys.h>
+#include <scsi/fc/fc_fcoe.h>
 
 /* copy saddr & daddr, possibly using 64bit load/store
  * Equivalent to :	flow->src = iph->saddr;
@@ -118,7 +119,7 @@ ipv6:
 		nhoff += sizeof(struct ipv6hdr);
 
 		flow_label = ip6_flowlabel(iph);
-		if (flow_label) {
+		if (flow_label && skb) {
 			/* Awesome, IPv6 packet has a flow label so we can
 			 * use that to represent the ports without any
 			 * further dissection.
@@ -165,6 +166,9 @@ ipv6:
 			return false;
 		}
 	}
+	case htons(ETH_P_FCOE):
+		flow->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
+		/* fall through */
 	default:
 		return false;
 	}
@@ -316,26 +320,18 @@ u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
-/* __skb_get_poff() returns the offset to the payload as far as it could
- * be dissected. The main user is currently BPF, so that we can dynamically
- * truncate packets without needing to push actual payload to the user
- * space and can analyze headers only, instead.
- */
-u32 __skb_get_poff(const struct sk_buff *skb)
+u32 ___skb_get_poff(const struct sk_buff *skb, void *data,
+	 	    const struct flow_keys *keys, int hlen)
 {
-	struct flow_keys keys;
-	u32 poff = 0;
-
-	if (!skb_flow_dissect(skb, &keys))
-		return 0;
+	u32 poff = keys->thoff;
 
-	poff += keys.thoff;
-	switch (keys.ip_proto) {
+	switch (keys->ip_proto) {
 	case IPPROTO_TCP: {
 		const struct tcphdr *tcph;
 		struct tcphdr _tcph;
 
-		tcph = skb_header_pointer(skb, poff, sizeof(_tcph), &_tcph);
+		tcph = __skb_header_pointer(skb, poff, sizeof(_tcph),
+					    data, hlen, &_tcph);
 		if (!tcph)
 			return poff;
 
@@ -369,6 +365,21 @@ u32 __skb_get_poff(const struct sk_buff *skb)
 	return poff;
 }
 
+/* __skb_get_poff() returns the offset to the payload as far as it could
+ * be dissected. The main user is currently BPF, so that we can dynamically
+ * truncate packets without needing to push actual payload to the user
+ * space and can analyze headers only, instead.
+ */
+u32 __skb_get_poff(const struct sk_buff *skb)
+{
+	struct flow_keys keys;
+
+	if (!skb_flow_dissect(skb, &keys))
+		return 0;
+
+	return ___skb_get_poff(skb, skb->data, &keys, skb->len);
+}
+
 static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_XPS
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5cebca1..f0299ac 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -146,6 +146,33 @@ int eth_rebuild_header(struct sk_buff *skb)
 EXPORT_SYMBOL(eth_rebuild_header);
 
 /**
+ * eth_get_headlen - determine the the length of header for an ethernet frame
+ * @data: pointer to start of frame
+ * @len: total length of frame
+ *
+ * Make a best effort attempt to pull the length for all of the headers for
+ * a given frame in a linear buffer.
+ */
+u32 eth_get_headlen(void *data, unsigned int len)
+{
+	const struct ethhdr *eth = (const struct ethhdr *)data;
+	struct flow_keys keys;
+
+	/* this should never happen, but better safe than sorry */
+	if (len < sizeof(*eth))
+		return len;
+
+	/* parse any remaining L2/L3 headers, check for L4 */
+	if (!__skb_flow_dissect(NULL, &keys, data,
+				eth->h_proto, sizeof(*eth), len))
+		return max_t(u32, keys.thoff, sizeof(*eth));
+
+	/* parse for any L4 headers */
+	return min_t(u32, ___skb_get_poff(NULL, data, &keys, len), len);
+}
+EXPORT_SYMBOL(eth_get_headlen);
+
+/**
  * eth_type_trans - determine the packet's protocol ID.
  * @skb: received socket data
  * @dev: receiving network device
