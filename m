From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: implement IPv6 NFC (and IPV4_USER_FLOW)
Date: Tue, 2 Feb 2016 18:49:55 +0000
Message-ID: <56B0FA53.2040405@solarflare.com>
References: <56B0F9A8.7010202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:16667 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965114AbcBBSu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:50:58 -0500
In-Reply-To: <56B0F9A8.7010202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c | 176 +++++++++++++++++++++++++++++++++++++
 1 file changed, 176 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 0347976..49fac36 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -783,14 +783,26 @@ static int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 static const u8 mac_addr_ig_mask[ETH_ALEN] __aligned(2) = {0x01, 0, 0, 0, 0, 0};
 
 #define IP4_ADDR_FULL_MASK	((__force __be32)~0)
+#define IP_PROTO_FULL_MASK	0xFF
 #define PORT_FULL_MASK		((__force __be16)~0)
 #define ETHER_TYPE_FULL_MASK	((__force __be16)~0)
 
+static inline void ip6_fill_mask(__be32 *mask)
+{
+	mask[0] = mask[1] = mask[2] = mask[3] = ~(__be32)0;
+}
+
 static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 				      struct ethtool_rx_flow_spec *rule)
 {
 	struct ethtool_tcpip4_spec *ip_entry = &rule->h_u.tcp_ip4_spec;
 	struct ethtool_tcpip4_spec *ip_mask = &rule->m_u.tcp_ip4_spec;
+	struct ethtool_usrip4_spec *uip_entry = &rule->h_u.usr_ip4_spec;
+	struct ethtool_usrip4_spec *uip_mask = &rule->m_u.usr_ip4_spec;
+	struct ethtool_tcpip6_spec *ip6_entry = &rule->h_u.tcp_ip6_spec;
+	struct ethtool_tcpip6_spec *ip6_mask = &rule->m_u.tcp_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_entry = &rule->h_u.usr_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_mask = &rule->m_u.usr_ip6_spec;
 	struct ethhdr *mac_entry = &rule->h_u.ether_spec;
 	struct ethhdr *mac_mask = &rule->m_u.ether_spec;
 	struct efx_filter_spec spec;
@@ -833,6 +845,35 @@ static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 			ip_entry->psrc = spec.rem_port;
 			ip_mask->psrc = PORT_FULL_MASK;
 		}
+	} else if ((spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE) &&
+	    spec.ether_type == htons(ETH_P_IPV6) &&
+	    (spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) &&
+	    (spec.ip_proto == IPPROTO_TCP || spec.ip_proto == IPPROTO_UDP) &&
+	    !(spec.match_flags &
+	      ~(EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILTER_MATCH_OUTER_VID |
+		EFX_FILTER_MATCH_LOC_HOST | EFX_FILTER_MATCH_REM_HOST |
+		EFX_FILTER_MATCH_IP_PROTO |
+		EFX_FILTER_MATCH_LOC_PORT | EFX_FILTER_MATCH_REM_PORT))) {
+		rule->flow_type = ((spec.ip_proto == IPPROTO_TCP) ?
+				   TCP_V6_FLOW : UDP_V6_FLOW);
+		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
+			memcpy(ip6_entry->ip6dst, spec.loc_host,
+			       sizeof(ip6_entry->ip6dst));
+			ip6_fill_mask(ip6_mask->ip6dst);
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
+			memcpy(ip6_entry->ip6src, spec.rem_host,
+			       sizeof(ip6_entry->ip6src));
+			ip6_fill_mask(ip6_mask->ip6src);
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_LOC_PORT) {
+			ip6_entry->pdst = spec.loc_port;
+			ip6_mask->pdst = PORT_FULL_MASK;
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_REM_PORT) {
+			ip6_entry->psrc = spec.rem_port;
+			ip6_mask->psrc = PORT_FULL_MASK;
+		}
 	} else if (!(spec.match_flags &
 		     ~(EFX_FILTER_MATCH_LOC_MAC | EFX_FILTER_MATCH_LOC_MAC_IG |
 		       EFX_FILTER_MATCH_REM_MAC | EFX_FILTER_MATCH_ETHER_TYPE |
@@ -855,6 +896,39 @@ static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 			mac_entry->h_proto = spec.ether_type;
 			mac_mask->h_proto = ETHER_TYPE_FULL_MASK;
 		}
+	} else if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE &&
+		   spec.ether_type == htons(ETH_P_IP)) {
+		rule->flow_type = IPV4_USER_FLOW;
+		uip_entry->ip_ver = ETH_RX_NFC_IP4;
+		if (spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) {
+			uip_mask->proto = IP_PROTO_FULL_MASK;
+			uip_entry->proto = spec.ip_proto;
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
+			uip_entry->ip4dst = spec.loc_host[0];
+			uip_mask->ip4dst = IP4_ADDR_FULL_MASK;
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
+			uip_entry->ip4src = spec.rem_host[0];
+			uip_mask->ip4src = IP4_ADDR_FULL_MASK;
+		}
+	} else if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE &&
+		   spec.ether_type == htons(ETH_P_IPV6)) {
+		rule->flow_type = IPV6_USER_FLOW;
+		if (spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) {
+			uip6_mask->l4_proto = IP_PROTO_FULL_MASK;
+			uip6_entry->l4_proto = spec.ip_proto;
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
+			memcpy(uip6_entry->ip6dst, spec.loc_host,
+			       sizeof(uip6_entry->ip6dst));
+			ip6_fill_mask(uip6_mask->ip6dst);
+		}
+		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
+			memcpy(uip6_entry->ip6src, spec.rem_host,
+			       sizeof(uip6_entry->ip6src));
+			ip6_fill_mask(uip6_mask->ip6src);
+		}
 	} else {
 		/* The above should handle all filters that we insert */
 		WARN_ON(1);
@@ -946,11 +1020,27 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 	}
 }
 
+static inline bool ip6_mask_is_full(__be32 mask[4])
+{
+	return !~(mask[0] & mask[1] & mask[2] & mask[3]);
+}
+
+static inline bool ip6_mask_is_empty(__be32 mask[4])
+{
+	return !(mask[0] | mask[1] | mask[2] | mask[3]);
+}
+
 static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 				      struct ethtool_rx_flow_spec *rule)
 {
 	struct ethtool_tcpip4_spec *ip_entry = &rule->h_u.tcp_ip4_spec;
 	struct ethtool_tcpip4_spec *ip_mask = &rule->m_u.tcp_ip4_spec;
+	struct ethtool_usrip4_spec *uip_entry = &rule->h_u.usr_ip4_spec;
+	struct ethtool_usrip4_spec *uip_mask = &rule->m_u.usr_ip4_spec;
+	struct ethtool_tcpip6_spec *ip6_entry = &rule->h_u.tcp_ip6_spec;
+	struct ethtool_tcpip6_spec *ip6_mask = &rule->m_u.tcp_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_entry = &rule->h_u.usr_ip6_spec;
+	struct ethtool_usrip6_spec *uip6_mask = &rule->m_u.usr_ip6_spec;
 	struct ethhdr *mac_entry = &rule->h_u.ether_spec;
 	struct ethhdr *mac_mask = &rule->m_u.ether_spec;
 	struct efx_filter_spec spec;
@@ -1012,6 +1102,92 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 			return -EINVAL;
 		break;
 
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+		spec.match_flags = (EFX_FILTER_MATCH_ETHER_TYPE |
+				    EFX_FILTER_MATCH_IP_PROTO);
+		spec.ether_type = htons(ETH_P_IPV6);
+		spec.ip_proto = ((rule->flow_type & ~FLOW_EXT) == TCP_V6_FLOW ?
+				 IPPROTO_TCP : IPPROTO_UDP);
+		if (!ip6_mask_is_empty(ip6_mask->ip6dst)) {
+			if (!ip6_mask_is_full(ip6_mask->ip6dst))
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_LOC_HOST;
+			memcpy(spec.loc_host, ip6_entry->ip6dst, sizeof(spec.loc_host));
+		}
+		if (!ip6_mask_is_empty(ip6_mask->ip6src)) {
+			if (!ip6_mask_is_full(ip6_mask->ip6src))
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_REM_HOST;
+			memcpy(spec.rem_host, ip6_entry->ip6src, sizeof(spec.rem_host));
+		}
+		if (ip6_mask->pdst) {
+			if (ip6_mask->pdst != PORT_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_LOC_PORT;
+			spec.loc_port = ip6_entry->pdst;
+		}
+		if (ip6_mask->psrc) {
+			if (ip6_mask->psrc != PORT_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_REM_PORT;
+			spec.rem_port = ip6_entry->psrc;
+		}
+		if (ip6_mask->tos)
+			return -EINVAL;
+		break;
+
+	case IPV4_USER_FLOW:
+		if (uip_mask->l4_4_bytes || uip_mask->tos || uip_mask->ip_ver ||
+		    uip_entry->ip_ver != ETH_RX_NFC_IP4)
+			return -EINVAL;
+		spec.match_flags = EFX_FILTER_MATCH_ETHER_TYPE;
+		spec.ether_type = htons(ETH_P_IP);
+		if (uip_mask->ip4dst) {
+			if (uip_mask->ip4dst != IP4_ADDR_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_LOC_HOST;
+			spec.loc_host[0] = uip_entry->ip4dst;
+		}
+		if (uip_mask->ip4src) {
+			if (uip_mask->ip4src != IP4_ADDR_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_REM_HOST;
+			spec.rem_host[0] = uip_entry->ip4src;
+		}
+		if (uip_mask->proto) {
+			if (uip_mask->proto != IP_PROTO_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_IP_PROTO;
+			spec.ip_proto = uip_entry->proto;
+		}
+		break;
+
+	case IPV6_USER_FLOW:
+		if (uip6_mask->l4_4_bytes || uip6_mask->tos)
+			return -EINVAL;
+		spec.match_flags = EFX_FILTER_MATCH_ETHER_TYPE;
+		spec.ether_type = htons(ETH_P_IPV6);
+		if (!ip6_mask_is_empty(ip6_mask->ip6dst)) {
+			if (!ip6_mask_is_full(uip6_mask->ip6dst))
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_LOC_HOST;
+			memcpy(spec.loc_host, uip6_entry->ip6dst, sizeof(spec.loc_host));
+		}
+		if (!ip6_mask_is_empty(ip6_mask->ip6src)) {
+			if (!ip6_mask_is_full(uip6_mask->ip6src))
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_REM_HOST;
+			memcpy(spec.rem_host, uip6_entry->ip6src, sizeof(spec.rem_host));
+		}
+		if (uip6_mask->l4_proto) {
+			if (uip6_mask->l4_proto != IP_PROTO_FULL_MASK)
+				return -EINVAL;
+			spec.match_flags |= EFX_FILTER_MATCH_IP_PROTO;
+			spec.ip_proto = uip6_entry->l4_proto;
+		}
+		break;
+
 	case ETHER_FLOW:
 		if (!is_zero_ether_addr(mac_mask->h_dest)) {
 			if (ether_addr_equal(mac_mask->h_dest,
