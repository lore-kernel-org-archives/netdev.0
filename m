From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 7/9] liquidio: New driver FW command structure
Date: Tue, 14 Jun 2016 16:54:49 -0700
Message-ID: <1465948491-10541-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0087.outbound.protection.outlook.com ([65.55.169.87]:43936
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752494AbcFOAKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:10:54 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is for new driver/firmware control command structure
(octnic_packet_params and octnic_cmd_setup ) and resultant code changes.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 109 +--------------------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  25 +++--
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |  15 +--
 3 files changed, 19 insertions(+), 130 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index aa28790..1f1a28d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2704,68 +2704,6 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 	return retval;
 }
 
-static inline int is_ipv4(struct sk_buff *skb)
-{
-	return (skb->protocol == htons(ETH_P_IP)) &&
-	       (ip_hdr(skb)->version == 4);
-}
-
-static inline int is_vlan(struct sk_buff *skb)
-{
-	return skb->protocol == htons(ETH_P_8021Q);
-}
-
-static inline int is_ip_fragmented(struct sk_buff *skb)
-{
-	/* The Don't fragment and Reserved flag fields are ignored.
-	 * IP is fragmented if
-	 * -  the More fragments bit is set (indicating this IP is a fragment
-	 * with more to follow; the current offset could be 0 ).
-	 * -  ths offset field is non-zero.
-	 */
-	return (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) ? 1 : 0;
-}
-
-static inline int is_ipv6(struct sk_buff *skb)
-{
-	return (skb->protocol == htons(ETH_P_IPV6)) &&
-	       (ipv6_hdr(skb)->version == 6);
-}
-
-static inline int is_with_extn_hdr(struct sk_buff *skb)
-{
-	return (ipv6_hdr(skb)->nexthdr != IPPROTO_TCP) &&
-	       (ipv6_hdr(skb)->nexthdr != IPPROTO_UDP);
-}
-
-static inline int is_tcpudp(struct sk_buff *skb)
-{
-	return (ip_hdr(skb)->protocol == IPPROTO_TCP) ||
-	       (ip_hdr(skb)->protocol == IPPROTO_UDP);
-}
-
-static inline u32 get_ipv4_5tuple_tag(struct sk_buff *skb)
-{
-	u32 tag;
-	struct iphdr *iphdr = ip_hdr(skb);
-
-	tag = crc32(0, &iphdr->protocol, 1);
-	tag = crc32(tag, (u8 *)&iphdr->saddr, 8);
-	tag = crc32(tag, skb_transport_header(skb), 4);
-	return tag;
-}
-
-static inline u32 get_ipv6_5tuple_tag(struct sk_buff *skb)
-{
-	u32 tag;
-	struct ipv6hdr *ipv6hdr = ipv6_hdr(skb);
-
-	tag = crc32(0, &ipv6hdr->nexthdr, 1);
-	tag = crc32(tag, (u8 *)&ipv6hdr->saddr, 32);
-	tag = crc32(tag, skb_transport_header(skb), 4);
-	return tag;
-}
-
 /** \brief Transmit networks packets to the Octeon interface
  * @param skbuff   skbuff struct to be passed to network layer.
  * @param netdev    pointer to network device
@@ -2852,52 +2790,11 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	cmdsetup.u64 = 0;
 	cmdsetup.s.ifidx = lio->linfo.ifidx;
+	cmdsetup.s.iq_no = iq_no;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (is_ipv4(skb) && !is_ip_fragmented(skb) && is_tcpudp(skb)) {
-			tag = get_ipv4_5tuple_tag(skb);
-
-			cmdsetup.s.cksum_offset = sizeof(struct ethhdr) + 1;
-
-			if (ip_hdr(skb)->ihl > 5)
-				cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV4OPTS;
-
-		} else if (is_ipv6(skb)) {
-			tag = get_ipv6_5tuple_tag(skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		cmdsetup.s.transport_csum = 1;
 
-			cmdsetup.s.cksum_offset = sizeof(struct ethhdr) + 1;
-
-			if (is_with_extn_hdr(skb))
-				cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV6EXTHDR;
-
-		} else if (is_vlan(skb)) {
-			if (vlan_eth_hdr(skb)->h_vlan_encapsulated_proto
-				== htons(ETH_P_IP) &&
-				!is_ip_fragmented(skb) && is_tcpudp(skb)) {
-				tag = get_ipv4_5tuple_tag(skb);
-
-				cmdsetup.s.cksum_offset =
-					sizeof(struct vlan_ethhdr) + 1;
-
-				if (ip_hdr(skb)->ihl > 5)
-					cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV4OPTS;
-
-			} else if (vlan_eth_hdr(skb)->h_vlan_encapsulated_proto
-				== htons(ETH_P_IPV6)) {
-				tag = get_ipv6_5tuple_tag(skb);
-
-				cmdsetup.s.cksum_offset =
-					sizeof(struct vlan_ethhdr) + 1;
-
-				if (is_with_extn_hdr(skb))
-					cmdsetup.s.ipv4opts_ipv6exthdr =
-						OCT_PKT_PARAM_IPV6EXTHDR;
-			}
-		}
-	}
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		cmdsetup.s.timestamp = 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 84ffcae..ebdb802 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -463,30 +463,27 @@ union octeon_rh {
 
 #define  OCT_RH_SIZE   (sizeof(union  octeon_rh))
 
-#define OCT_PKT_PARAM_IPV4OPTS   1
-#define OCT_PKT_PARAM_IPV6EXTHDR 2
-
 union octnic_packet_params {
 	u32 u32;
 	struct {
 #ifdef __BIG_ENDIAN_BITFIELD
-		u32 reserved:6;
+		u32 reserved:16;
+		u32 ip_csum:1;		/* Perform IP header checksum(s) */
+		/* Perform Outer transport header checksum */
+		u32 transport_csum:1;
+		/* Find tunnel, and perform transport csum. */
 		u32 tnl_csum:1;
-		u32 ip_csum:1;
-		u32 ipv4opts_ipv6exthdr:2;
-		u32 ipsec_ops:4;
-		u32 tsflag:1;
-		u32 csoffset:9;
+		u32 tsflag:1;		/* Timestamp this packet */
+		u32 ipsec_ops:4;	/* IPsec operation */
 		u32 ifidx:8;
 #else
 		u32 ifidx:8;
-		u32 csoffset:9;
-		u32 tsflag:1;
 		u32 ipsec_ops:4;
-		u32 ipv4opts_ipv6exthdr:2;
-		u32 ip_csum:1;
+		u32 tsflag:1;
 		u32 tnl_csum:1;
-		u32 reserved:6;
+		u32 transport_csum:1;
+		u32 ip_csum:1;
+		u32 reserved:16;
 #endif
 	} s;
 };
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 0238857..a61dea3 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -94,15 +94,15 @@ struct octnic_data_pkt {
  */
 union octnic_cmd_setup {
 	struct {
-		u32 ifidx:8;
-		u32 cksum_offset:7;
+		u32 iq_no:8;
 		u32 gather:1;
 		u32 timestamp:1;
-		u32 ipv4opts_ipv6exthdr:2;
 		u32 ip_csum:1;
+		u32 transport_csum:1;
 		u32 tnl_csum:1;
-
+		u32 ifidx:8;
 		u32 rsvd:11;
+
 		union {
 			u32 datasize;
 			u32 gatherptrs;
@@ -172,13 +172,8 @@ octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
 
 	packet_params.u32 = 0;
 
-	if (setup->s.cksum_offset) {
-		packet_params.s.csoffset = setup->s.cksum_offset;
-		packet_params.s.ipv4opts_ipv6exthdr =
-						setup->s.ipv4opts_ipv6exthdr;
-	}
-
 	packet_params.s.ip_csum = setup->s.ip_csum;
+	packet_params.s.transport_csum = setup->s.transport_csum;
 	packet_params.s.tnl_csum = setup->s.tnl_csum;
 	packet_params.s.ifidx = setup->s.ifidx;
 	packet_params.s.tsflag = setup->s.timestamp;
-- 
1.8.3.1
