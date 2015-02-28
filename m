From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] fm10k: Modify tunnel length header check when offloading
Date: Sat, 28 Feb 2015 03:29:32 -0800
Message-ID: <1425122989-354-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Joe Stringer <joestringer@nicira.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49619 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbbB1L3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:53 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

The FM10000 host interface can only support up to 184 bytes when
performing tunnel offloads. Because of this, a check was added to
prevent the driver from attempting to feed a header to the hardware too
big for it to parse. Make this check a little more robust by calculating
the inner L4 header length based on whether it is TCP or UDP.

Cc: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 33 +++++++++++++++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h |  3 +++
 2 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 84ab9ee..a7d3798 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -711,10 +711,6 @@ static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
 	if (nvgre_hdr->flags & FM10K_NVGRE_RESERVED0_FLAGS)
 		return NULL;
 
-	/* verify protocol is transparent Ethernet bridging */
-	if (nvgre_hdr->proto != htons(ETH_P_TEB))
-		return NULL;
-
 	/* report start of ethernet header */
 	if (nvgre_hdr->flags & NVGRE_TNI)
 		return (struct ethhdr *)(nvgre_hdr + 1);
@@ -724,13 +720,11 @@ static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
 
 static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
 {
+	u8 l4_hdr = 0, inner_l4_hdr = 0, inner_l4_hlen;
 	struct ethhdr *eth_hdr;
-	u8 l4_hdr = 0;
 
-/* fm10k supports 184 octets of outer+inner headers. Minus 20 for inner L4. */
-#define FM10K_MAX_ENCAP_TRANSPORT_OFFSET	164
-	if (skb_inner_transport_header(skb) - skb_mac_header(skb) >
-	    FM10K_MAX_ENCAP_TRANSPORT_OFFSET)
+	if (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
+	    skb->inner_protocol != htons(ETH_P_TEB))
 		return 0;
 
 	switch (vlan_get_protocol(skb)) {
@@ -760,12 +754,33 @@ static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
 
 	switch (eth_hdr->h_proto) {
 	case htons(ETH_P_IP):
+		inner_l4_hdr = inner_ip_hdr(skb)->protocol;
+		break;
 	case htons(ETH_P_IPV6):
+		inner_l4_hdr = inner_ipv6_hdr(skb)->nexthdr;
 		break;
 	default:
 		return 0;
 	}
 
+	switch (inner_l4_hdr) {
+	case IPPROTO_TCP:
+		inner_l4_hlen = inner_tcp_hdrlen(skb);
+		break;
+	case IPPROTO_UDP:
+		inner_l4_hlen = 8;
+		break;
+	default:
+		return 0;
+	}
+
+	/* The hardware allows tunnel offloads only if the combined inner and
+	 * outer header is 184 bytes or less
+	 */
+	if (skb_inner_transport_header(skb) + inner_l4_hlen -
+	    skb_mac_header(skb) > FM10K_TUNNEL_HEADER_LENGTH)
+		return 0;
+
 	return eth_hdr->h_proto;
 }
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 7c6d9d5..abb8a03 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -356,6 +356,9 @@ struct fm10k_hw;
 #define FM10K_QUEUE_DISABLE_TIMEOUT		100
 #define FM10K_RESET_TIMEOUT			150
 
+/* Maximum supported combined inner and outer header length for encapsulation */
+#define FM10K_TUNNEL_HEADER_LENGTH	184
+
 /* VF registers */
 #define FM10K_VFCTRL		0x00000
 #define FM10K_VFCTRL_RST			0x00000008
-- 
1.9.3
