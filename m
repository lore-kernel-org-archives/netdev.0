From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/20] netfilter: bridge: don't use nf_bridge_info data to store mac header
Date: Thu,  9 Apr 2015 13:34:54 +0200
Message-ID: <1428579304-5520-11-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33122 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932861AbbDILbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:17 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

br_netfilter maintains an extra state, nf_bridge_info, which is attached
to skb via skb->nf_bridge pointer.

Amongst other things we use skb->nf_bridge->data to store the original
mac header for every processed skb.

This is required for ip refragmentation when using conntrack
on top of bridge, because ip_fragment doesn't copy it from original skb.

However there is no need anymore to do this unconditionally.

Move this to the one place where its needed -- when br_netfilter calls
ip_fragment().

Also switch to percpu storage for this so we can handle fragmenting
without accessing nf_bridge meta data.

Only user left is neigh resolution when DNAT is detected, to hold
the original source mac address (neigh resolution builds new mac header
using bridge mac), so rename ->data and reduce its size to whats needed.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h    |    2 +-
 net/bridge/br_netfilter.c |   70 ++++++++++++++++++++++++++-------------------
 2 files changed, 42 insertions(+), 30 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 36f3f43..f66a089 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -169,7 +169,7 @@ struct nf_bridge_info {
 	unsigned int		mask;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
-	unsigned long		data[32 / sizeof(unsigned long)];
+	char			neigh_header[8];
 };
 #endif
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 282ed76..ca1cb67 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -111,6 +111,19 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
+/* largest possible L2 header, see br_nf_dev_queue_xmit() */
+#define NF_BRIDGE_MAX_MAC_HEADER_LENGTH (PPPOE_SES_HLEN + ETH_HLEN)
+
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
+struct brnf_frag_data {
+	char mac[NF_BRIDGE_MAX_MAC_HEADER_LENGTH];
+	u8 encap_size;
+	u8 size;
+};
+
+static DEFINE_PER_CPU(struct brnf_frag_data, brnf_frag_data_storage);
+#endif
+
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
@@ -189,14 +202,6 @@ static inline void nf_bridge_pull_encap_header_rcsum(struct sk_buff *skb)
 	skb->network_header += len;
 }
 
-static inline void nf_bridge_save_header(struct sk_buff *skb)
-{
-	int header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
-
-	skb_copy_from_linear_data_offset(skb, -header_size,
-					 skb->nf_bridge->data, header_size);
-}
-
 /* When handing a packet over to the IP layer
  * check whether we have a skb that is in the
  * expected format
@@ -318,7 +323,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 			 */
 			skb_copy_from_linear_data_offset(skb,
 							 -(ETH_HLEN-ETH_ALEN),
-							 skb->nf_bridge->data,
+							 nf_bridge->neigh_header,
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
 			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
@@ -810,30 +815,22 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 }
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
-static bool nf_bridge_copy_header(struct sk_buff *skb)
+static int br_nf_push_frag_xmit(struct sk_buff *skb)
 {
+	struct brnf_frag_data *data;
 	int err;
-	unsigned int header_size;
 
-	nf_bridge_update_protocol(skb);
-	header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
-	err = skb_cow_head(skb, header_size);
-	if (err)
-		return false;
+	data = this_cpu_ptr(&brnf_frag_data_storage);
+	err = skb_cow_head(skb, data->size);
 
-	skb_copy_to_linear_data_offset(skb, -header_size,
-				       skb->nf_bridge->data, header_size);
-	__skb_push(skb, nf_bridge_encap_header_len(skb));
-	return true;
-}
-
-static int br_nf_push_frag_xmit(struct sk_buff *skb)
-{
-	if (!nf_bridge_copy_header(skb)) {
+	if (err) {
 		kfree_skb(skb);
 		return 0;
 	}
 
+	skb_copy_to_linear_data_offset(skb, -data->size, data->mac, data->size);
+	__skb_push(skb, data->encap_size);
+
 	return br_dev_queue_push_xmit(skb);
 }
 
@@ -851,14 +848,27 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
 	if (skb->len + mtu_reserved > skb->dev->mtu) {
+		struct brnf_frag_data *data;
+
 		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
 		if (br_parse_ip_options(skb))
 			/* Drop invalid packet */
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = frag_max_size;
+
+		nf_bridge_update_protocol(skb);
+
+		data = this_cpu_ptr(&brnf_frag_data_storage);
+		data->encap_size = nf_bridge_encap_header_len(skb);
+		data->size = ETH_HLEN + data->encap_size;
+
+		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
+						 data->size);
+
 		ret = ip_fragment(skb, br_nf_push_frag_xmit);
-	} else
+	} else {
 		ret = br_dev_queue_push_xmit(skb);
+	}
 
 	return ret;
 }
@@ -906,7 +916,6 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	}
 
 	nf_bridge_pull_encap_header(skb);
-	nf_bridge_save_header(skb);
 	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
@@ -951,8 +960,11 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	skb_pull(skb, ETH_HLEN);
 	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
 
-	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
-				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
+	BUILD_BUG_ON(sizeof(nf_bridge->neigh_header) != (ETH_HLEN - ETH_ALEN));
+
+	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN - ETH_ALEN),
+				       nf_bridge->neigh_header,
+				       ETH_HLEN - ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
 	br_handle_frame_finish(skb);
 }
-- 
1.7.10.4
