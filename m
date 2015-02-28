From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next] Driver: Vmxnet3: Copy TCP header to mapped frame for IPv6 packets
Date: Sat, 28 Feb 2015 11:58:29 -0800
Message-ID: <1425153509-31582-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Amitabha Banerjee <banerjeea@vmware.com>
To: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:59258 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbbB1T7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 14:59:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows for packet parsing to be done by the fast path. This performance
optimization already exists for IPv4. Add similar logic for IPv6.

Signed-off-by: Amitabha Banerjee <banerjeea@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 26 ++++++++++++++++----------
 drivers/net/vmxnet3/vmxnet3_int.h |  5 +++--
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 294214c..9216e6a 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -819,6 +819,7 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 			   struct vmxnet3_adapter *adapter)
 {
 	struct Vmxnet3_TxDataDesc *tdd;
+	u8 protocol = 0;
 
 	if (ctx->mss) {	/* TSO */
 		ctx->eth_ip_hdr_size = skb_transport_offset(skb);
@@ -831,16 +832,20 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 			if (ctx->ipv4) {
 				const struct iphdr *iph = ip_hdr(skb);
 
-				if (iph->protocol == IPPROTO_TCP)
-					ctx->l4_hdr_size = tcp_hdrlen(skb);
-				else if (iph->protocol == IPPROTO_UDP)
-					ctx->l4_hdr_size = sizeof(struct udphdr);
-				else
-					ctx->l4_hdr_size = 0;
-			} else {
-				/* for simplicity, don't copy L4 headers */
-				ctx->l4_hdr_size = 0;
+				protocol = iph->protocol;
+			} else if (ctx->ipv6) {
+				const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+
+				protocol = ipv6h->nexthdr;
 			}
+
+			if (protocol == IPPROTO_TCP)
+				ctx->l4_hdr_size = tcp_hdrlen(skb);
+			else if (protocol == IPPROTO_UDP)
+				ctx->l4_hdr_size = sizeof(struct udphdr);
+			else
+				ctx->l4_hdr_size = 0;
+
 			ctx->copy_size = min(ctx->eth_ip_hdr_size +
 					 ctx->l4_hdr_size, skb->len);
 		} else {
@@ -887,7 +892,7 @@ vmxnet3_prepare_tso(struct sk_buff *skb,
 		iph->check = 0;
 		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, 0,
 						 IPPROTO_TCP, 0);
-	} else {
+	} else if (ctx->ipv6) {
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		tcph->check = ~csum_ipv6_magic(&iph->saddr, &iph->daddr, 0,
@@ -938,6 +943,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	count = txd_estimate(skb);
 
 	ctx.ipv4 = (vlan_get_protocol(skb) == cpu_to_be16(ETH_P_IP));
+	ctx.ipv6 = (vlan_get_protocol(skb) == cpu_to_be16(ETH_P_IPV6));
 
 	ctx.mss = skb_shinfo(skb)->gso_size;
 	if (ctx.mss) {
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index cd71c77..6bb769a 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.3.4.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.3.5.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01030400
+#define VMXNET3_DRIVER_VERSION_NUM      0x01030500
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
@@ -211,6 +211,7 @@ struct vmxnet3_tq_driver_stats {
 
 struct vmxnet3_tx_ctx {
 	bool   ipv4;
+	bool   ipv6;
 	u16 mss;
 	u32 eth_ip_hdr_size; /* only valid for pkts requesting tso or csum
 				 * offloading
-- 
1.8.5.6
