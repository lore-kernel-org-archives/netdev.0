From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/11] sfc: Support ARFS for IPv6 flows
Date: Sat, 21 Sep 2013 19:36:14 +0100
Message-ID: <1379788574.1681.44.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32643 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab3IUSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:36:18 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend efx_filter_rfs() to map TCP/IPv6 and UDP/IPv6 flows into
efx_filter_spec.  These are only supported on EF10; on Falcon and
Siena they will be rejected by efx_farch_filter_from_gen_spec().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 89 +++++++++++++++++++++++++++++--------------
 1 file changed, 61 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 4a59672..20c46f3 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -818,44 +818,70 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 	struct efx_filter_spec spec;
-	const struct iphdr *ip;
 	const __be16 *ports;
+	__be16 ether_type;
 	int nhoff;
 	int rc;
 
-	nhoff = skb_network_offset(skb);
+	/* The core RPS/RFS code has already parsed and validated
+	 * VLAN, IP and transport headers.  We assume they are in the
+	 * header area.
+	 */
 
 	if (skb->protocol == htons(ETH_P_8021Q)) {
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) <
-				    nhoff + sizeof(struct vlan_hdr));
-		if (((const struct vlan_hdr *)skb->data + nhoff)->
-		    h_vlan_encapsulated_proto != htons(ETH_P_IP))
-			return -EPROTONOSUPPORT;
+		const struct vlan_hdr *vh =
+			(const struct vlan_hdr *)skb->data;
 
-		/* This is IP over 802.1q VLAN.  We can't filter on the
-		 * IP 5-tuple and the vlan together, so just strip the
-		 * vlan header and filter on the IP part.
+		/* We can't filter on the IP 5-tuple and the vlan
+		 * together, so just strip the vlan header and filter
+		 * on the IP part.
 		 */
-		nhoff += sizeof(struct vlan_hdr);
-	} else if (skb->protocol != htons(ETH_P_IP)) {
-		return -EPROTONOSUPPORT;
+		EFX_BUG_ON_PARANOID(skb_headlen(skb) < sizeof(*vh));
+		ether_type = vh->h_vlan_encapsulated_proto;
+		nhoff = sizeof(struct vlan_hdr);
+	} else {
+		ether_type = skb->protocol;
+		nhoff = 0;
 	}
 
-	/* RFS must validate the IP header length before calling us */
-	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));
-	ip = (const struct iphdr *)(skb->data + nhoff);
-	if (ip_is_fragment(ip))
+	if (ether_type != htons(ETH_P_IP) && ether_type != htons(ETH_P_IPV6))
 		return -EPROTONOSUPPORT;
-	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + 4 * ip->ihl + 4);
-	ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
 
 	efx_filter_init_rx(&spec, EFX_FILTER_PRI_HINT,
 			   efx->rx_scatter ? EFX_FILTER_FLAG_RX_SCATTER : 0,
 			   rxq_index);
-	rc = efx_filter_set_ipv4_full(&spec, ip->protocol,
-				      ip->daddr, ports[1], ip->saddr, ports[0]);
-	if (rc)
-		return rc;
+	spec.match_flags =
+		EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILTER_MATCH_IP_PROTO |
+		EFX_FILTER_MATCH_LOC_HOST | EFX_FILTER_MATCH_LOC_PORT |
+		EFX_FILTER_MATCH_REM_HOST | EFX_FILTER_MATCH_REM_PORT;
+	spec.ether_type = ether_type;
+
+	if (ether_type == htons(ETH_P_IP)) {
+		const struct iphdr *ip =
+			(const struct iphdr *)(skb->data + nhoff);
+
+		EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));
+		if (ip_is_fragment(ip))
+			return -EPROTONOSUPPORT;
+		spec.ip_proto = ip->protocol;
+		spec.rem_host[0] = ip->saddr;
+		spec.loc_host[0] = ip->daddr;
+		EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + 4 * ip->ihl + 4);
+		ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
+	} else {
+		const struct ipv6hdr *ip6 =
+			(const struct ipv6hdr *)(skb->data + nhoff);
+
+		EFX_BUG_ON_PARANOID(skb_headlen(skb) <
+				    nhoff + sizeof(*ip6) + 4);
+		spec.ip_proto = ip6->nexthdr;
+		memcpy(spec.rem_host, &ip6->saddr, sizeof(ip6->saddr));
+		memcpy(spec.loc_host, &ip6->daddr, sizeof(ip6->daddr));
+		ports = (const __be16 *)(ip6 + 1);
+	}
+
+	spec.rem_port = ports[0];
+	spec.loc_port = ports[1];
 
 	rc = efx->type->filter_rfs_insert(efx, &spec);
 	if (rc < 0)
@@ -866,11 +892,18 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	channel = efx_get_channel(efx, skb_get_rx_queue(skb));
 	++channel->rfs_filters_added;
 
-	netif_info(efx, rx_status, efx->net_dev,
-		   "steering %s %pI4:%u:%pI4:%u to queue %u [flow %u filter %d]\n",
-		   (ip->protocol == IPPROTO_TCP) ? "TCP" : "UDP",
-		   &ip->saddr, ntohs(ports[0]), &ip->daddr, ntohs(ports[1]),
-		   rxq_index, flow_id, rc);
+	if (ether_type == htons(ETH_P_IP))
+		netif_info(efx, rx_status, efx->net_dev,
+			   "steering %s %pI4:%u:%pI4:%u to queue %u [flow %u filter %d]\n",
+			   (spec.ip_proto == IPPROTO_TCP) ? "TCP" : "UDP",
+			   spec.rem_host, ntohs(ports[0]), spec.loc_host,
+			   ntohs(ports[1]), rxq_index, flow_id, rc);
+	else
+		netif_info(efx, rx_status, efx->net_dev,
+			   "steering %s [%pI6]:%u:[%pI6]:%u to queue %u [flow %u filter %d]\n",
+			   (spec.ip_proto == IPPROTO_TCP) ? "TCP" : "UDP",
+			   spec.rem_host, ntohs(ports[0]), spec.loc_host,
+			   ntohs(ports[1]), rxq_index, flow_id, rc);
 
 	return rc;
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
