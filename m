From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 2/6] netfilter: bridge: don't use nf_bridge_info to store mac header
Date: Thu, 12 Mar 2015 18:05:21 +0100
Message-ID: <1426179925-18220-3-git-send-email-fw@strlen.de>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426179925-18220-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently br_netfilter maintains an extra state, nf_bridge_info,
which is attached to skb via skb->nf_bridge pointer.  Amongst
other things we use skb->nf_bridge->data to store the original
mac header for every processed skb.

This is required for ip refragmentation when using conntrack
on top of bridge, because ip_fragment doesn't copy it from original skb.

However there is no need anymore to do this unconditionally.

Move this to the one place where its needed -- when br_netfilter calls
ip_fragment().

Also switch to percpu storage for this, there is no need to use
skb->nf_bridge->data.

After this change, only one user of skb->nf_bridge->data is left.
It will be removed by followup patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h | 12 --------
 net/bridge/br_netfilter.c        | 66 +++++++++++++++++++++++++---------------
 2 files changed, 42 insertions(+), 36 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index fbbd5de..b131613 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -23,18 +23,6 @@ enum nf_br_hook_priorities {
 #define BRNF_8021Q			0x10
 #define BRNF_PPPoE			0x20
 
-static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
-{
-	switch (skb->protocol) {
-	case __cpu_to_be16(ETH_P_8021Q):
-		return VLAN_HLEN;
-	case __cpu_to_be16(ETH_P_PPP_SES):
-		return PPPOE_SES_HLEN;
-	default:
-		return 0;
-	}
-}
-
 int br_handle_frame_finish(struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 550ee19..669b4fa 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -111,6 +111,27 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
 	 pppoe_proto(skb) == htons(PPP_IPV6) && \
 	 brnf_filter_pppoe_tagged)
 
+static unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case __cpu_to_be16(ETH_P_8021Q):
+		return VLAN_HLEN;
+	case __cpu_to_be16(ETH_P_PPP_SES):
+		return PPPOE_SES_HLEN;
+	default:
+		break;
+	}
+	return 0;
+}
+
+/* largest possible L2 header, see br_nf_dev_queue_xmit() */
+#define NF_BRIDGE_MAX_MAC_HEADER_LENGTH (PPPOE_SES_HLEN + ETH_HLEN)
+
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
+static DEFINE_PER_CPU(__u8 [NF_BRIDGE_MAX_MAC_HEADER_LENGTH],
+		      brnf_mac_header_storage);
+#endif
+
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
@@ -177,14 +198,6 @@ static inline void nf_bridge_pull_encap_header_rcsum(struct sk_buff *skb)
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
@@ -785,30 +798,28 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 }
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
-static bool nf_bridge_copy_header(struct sk_buff *skb)
+static int br_nf_push_frag_xmit(struct sk_buff *skb)
 {
-	int err;
 	unsigned int header_size;
+	unsigned int encap_size;
+	char *mac;
+	int err;
 
 	nf_bridge_update_protocol(skb);
-	header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
-	err = skb_cow_head(skb, header_size);
-	if (err)
-		return false;
 
-	skb_copy_to_linear_data_offset(skb, -header_size,
-				       skb->nf_bridge->data, header_size);
-	__skb_push(skb, nf_bridge_encap_header_len(skb));
-	return true;
-}
+	encap_size = nf_bridge_encap_header_len(skb);
+	header_size = ETH_HLEN + encap_size;
 
-static int br_nf_push_frag_xmit(struct sk_buff *skb)
-{
-	if (!nf_bridge_copy_header(skb)) {
+	err = skb_cow_head(skb, header_size);
+	if (err) {
 		kfree_skb(skb);
 		return 0;
 	}
 
+	mac = this_cpu_ptr(brnf_mac_header_storage);
+	skb_copy_to_linear_data_offset(skb, -header_size, mac, header_size);
+	__skb_push(skb, encap_size);
+
 	return br_dev_queue_push_xmit(skb);
 }
 
@@ -834,7 +845,8 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
 	if (skb->len + mtu_reserved > mtu) {
-		unsigned int llrs;
+		unsigned int llrs, header_size;
+		char *mac;
 
 		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
 		if (br_parse_ip_options(skb))
@@ -847,6 +859,13 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 		 */
 		llrs = nf_bridge_encap_header_len(skb);
 
+		mac = this_cpu_ptr(brnf_mac_header_storage);
+
+		header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
+
+		skb_copy_from_linear_data_offset(skb, -header_size, mac,
+						 header_size);
+
 		mtu -= mtu_reserved;
 		ret = ip_fragment(skb, mtu, llrs, br_nf_push_frag_xmit);
 	} else
@@ -898,7 +917,6 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	}
 
 	nf_bridge_pull_encap_header(skb);
-	nf_bridge_save_header(skb);
 	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
-- 
2.0.5

