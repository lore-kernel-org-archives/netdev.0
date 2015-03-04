From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 7/8] netfilter: bridge: don't use nf_bridge_info data to store mac header
Date: Thu,  5 Mar 2015 00:52:39 +0100
Message-ID: <1425513160-496-8-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Andy Zhou <azhou@nicira.com>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33803 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753382AbbCDXw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 18:52:59 -0500
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently br_netfilter maintains an extra state, nf_bridge_info,
which is attached to skb via skb->nf_bridge pointer.

For every packet handed to POST_ROUTING ipv4/ipv6 netfilter we save
original mac header in nf_bridge_info->data space.

However, there appears to be no technical reason anymore.

In ancient times, netfilter had an ip_refrag() hook, invoked before
NF_POST_ROUTING.  It no longer exists, ip(6) netfilter hooks should not
be mangling the layer 2 headers.

Remove this unconditional saving of mac header and only do this when needed --
when br_netfilter has to fragment skb that was previously defragmented by
nf_defrag.  ip_fragment doesn't copy the mac header from the
to-be-fragmented skb.

Save a copy on the stack and extend ip_fragment to pass that to the output
function.

The ip_fragment changes are based on an earlier version from Andy Zhou.

Cc: Andy Zhou <azhou@nicira.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h | 12 ----------
 include/net/ip.h                 |  4 +++-
 net/bridge/br_netfilter.c        | 48 ++++++++++++++++++++++++++--------------
 net/ipv4/ip_output.c             | 19 +++++++++-------
 4 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index ab06213..20089bb 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -24,18 +24,6 @@ enum nf_br_hook_priorities {
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
diff --git a/include/net/ip.h b/include/net/ip.h
index 9c34441..4cf6bd1 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -109,7 +109,9 @@ int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_fragment(struct sk_buff *skb, unsigned int mtu_reserved,
-		unsigned int ll_reserved, int (*output)(struct sk_buff *));
+		unsigned int ll_reserved,
+		int (*output)(struct sk_buff *, const void *output_arg),
+		const void *output_arg);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 6ff7ed5..88e7656 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -150,6 +150,22 @@ static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
 	return nf_bridge;
 }
 
+#define NF_BRDIGE_MAX_MAC_HEADER_LENGTH (PPPOE_SES_HLEN + ETH_HLEN)
+
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
+
 static inline void nf_bridge_push_encap_header(struct sk_buff *skb)
 {
 	unsigned int len = nf_bridge_encap_header_len(skb);
@@ -174,14 +190,6 @@ static inline void nf_bridge_pull_encap_header_rcsum(struct sk_buff *skb)
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
@@ -780,7 +788,7 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 }
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
-static bool nf_bridge_copy_header(struct sk_buff *skb)
+static bool nf_bridge_copy_header(struct sk_buff *skb, const char *machdr)
 {
 	int err;
 	unsigned int header_size;
@@ -791,15 +799,14 @@ static bool nf_bridge_copy_header(struct sk_buff *skb)
 	if (err)
 		return false;
 
-	skb_copy_to_linear_data_offset(skb, -header_size,
-				       skb->nf_bridge->data, header_size);
+	skb_copy_to_linear_data_offset(skb, -header_size, machdr, header_size);
 	__skb_push(skb, nf_bridge_encap_header_len(skb));
 	return true;
 }
 
-static int br_nf_push_frag_xmit(struct sk_buff *skb)
+static int br_nf_push_frag_xmit(struct sk_buff *skb, const void *data)
 {
-	if (!nf_bridge_copy_header(skb)) {
+	if (!nf_bridge_copy_header(skb, data)) {
 		kfree_skb(skb);
 		return 0;
 	}
@@ -828,15 +835,23 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
 	if (skb->len + mtu_reserved > skb->dev->mtu) {
+		char brnf_mac_header[NF_BRDIGE_MAX_MAC_HEADER_LENGTH];
+		int headerlen, encaplen;
+
 		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
 		if (br_parse_ip_options(skb))
 			/* Drop invalid packet */
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = frag_max_size;
 
-		ret = ip_fragment(skb, mtu_reserved,
-				  nf_bridge_encap_header_len(skb),
-				  br_nf_push_frag_xmit);
+		encaplen = nf_bridge_encap_header_len(skb);
+		headerlen = ETH_HLEN + encaplen;
+
+		skb_copy_from_linear_data_offset(skb, -headerlen,
+						 brnf_mac_header, headerlen);
+
+		ret = ip_fragment(skb, mtu_reserved, encaplen,
+				  br_nf_push_frag_xmit, brnf_mac_header);
 	} else
 		ret = br_dev_queue_push_xmit(skb);
 
@@ -881,7 +896,6 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	}
 
 	nf_bridge_pull_encap_header(skb);
-	nf_bridge_save_header(skb);
 	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
 	else
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1b284eb..2d0cf84 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -163,7 +163,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
-static inline int ip_finish_output2(struct sk_buff *skb)
+static int ip_finish_output2(struct sk_buff *skb,
+			     const void *unused __always_unused)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
@@ -220,7 +221,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
 	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
-		return ip_finish_output2(skb);
+		return ip_finish_output2(skb, NULL);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
 	 *
@@ -243,7 +244,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(segs, 0, 0, ip_finish_output2);
+		err = ip_fragment(segs, 0, 0, ip_finish_output2, NULL);
 
 		if (err && ret == 0)
 			ret = err;
@@ -266,9 +267,9 @@ static int ip_finish_output(struct sk_buff *skb)
 		return ip_finish_output_gso(skb);
 
 	if (skb->len > ip_skb_dst_mtu(skb))
-		return ip_fragment(skb, 0, 0, ip_finish_output2);
+		return ip_fragment(skb, 0, 0, ip_finish_output2, NULL);
 
-	return ip_finish_output2(skb);
+	return ip_finish_output2(skb, NULL);
 }
 
 int ip_mc_output(struct sock *sk, struct sk_buff *skb)
@@ -479,6 +480,7 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  *	@mtu_reserved: extra MTU space required (used by bridge netfilter)
  *	@ll_rs: extra linklayer space required (used by bridge netfilter)
  *	@output: transmit function used to send fragments
+ *	@output_arg: pointer passed to transmit function as argument
  *
  *	This IP datagram is too large to be sent in one piece.  Break it up into
  *	smaller pieces (each of size equal to IP header plus
@@ -487,7 +489,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  */
 int ip_fragment(struct sk_buff *skb,
 		unsigned int mtu_reserved, unsigned int ll_rs,
-		int (*output)(struct sk_buff *))
+		int (*output)(struct sk_buff *, const void *output_arg),
+		const void *output_arg)
 {
 	struct iphdr *iph;
 	int ptr;
@@ -596,7 +599,7 @@ int ip_fragment(struct sk_buff *skb,
 				ip_send_check(iph);
 			}
 
-			err = output(skb);
+			err = output(skb, output_arg);
 
 			if (!err)
 				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
@@ -736,7 +739,7 @@ slow_path:
 
 		ip_send_check(iph);
 
-		err = output(skb2);
+		err = output(skb2, output_arg);
 		if (err)
 			goto fail;
 
-- 
2.0.5
