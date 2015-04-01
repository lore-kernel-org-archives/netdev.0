From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 03/14] netfilter: bridge: don't use nf_bridge_info data to store mac header
Date: Wed,  1 Apr 2015 22:36:29 +0200
Message-ID: <1427920600-20366-4-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42840 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752935AbbDAUgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:36:55 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently br_netfilter maintains an extra state, nf_bridge_info,
which is attached to skb via skb->nf_bridge pointer.  Amongst
other things we use skb->nf_bridge->data to store the original
mac header for every processed skb.

This is required for ip refragmentation when using conntrack
on top of bridge, because ip_fragment doesn't copy it from original skb.

However there is no need anymore to do this unconditionally.

Move this to the one place where its needed -- when br_netfilter calls
ip_fragment().

Also switch to percpu storage for this so we can handle fragmenting
without accessing nf_bridge meta data.

After this change, only one user of skb->nf_bridge->data is left.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 57 ++++++++++++++++++++++++++---------------------
 1 file changed, 32 insertions(+), 25 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c0c8700..6ccb1af 100644
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
-
-	skb_copy_to_linear_data_offset(skb, -header_size,
-				       skb->nf_bridge->data, header_size);
-	__skb_push(skb, nf_bridge_encap_header_len(skb));
-	return true;
-}
+	data = this_cpu_ptr(&brnf_frag_data_storage);
+	err = skb_cow_head(skb, data->size);
 
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
 
@@ -864,6 +861,8 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	 * size as mtu if it is set.
 	 */
 	if (skb->len > mtu) {
+		struct brnf_frag_data *data;
+
 		if (!skb->ignore_df) /* was not a defragmented */
 			goto err_out;
 
@@ -877,6 +876,15 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 		if (br_parse_ip_options(skb))
 			goto err_out;
 
+		nf_bridge_update_protocol(skb);
+
+		data = this_cpu_ptr(&brnf_frag_data_storage);
+		data->encap_size = nf_bridge_encap_header_len(skb);
+		data->size = ETH_HLEN + data->encap_size;
+
+		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
+						 data->size);
+
 		ret = ip_fragment(skb, mtu, br_nf_push_frag_xmit);
 	} else {
 		ret = br_dev_queue_push_xmit(skb);
@@ -932,7 +940,6 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	}
 
 	nf_bridge_pull_encap_header(skb);
-	nf_bridge_save_header(skb);
 	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
-- 
2.0.5
