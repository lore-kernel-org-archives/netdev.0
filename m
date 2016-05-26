From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: use flow dissector helpers for aRFS
Date: Thu, 26 May 2016 21:46:05 +0100
Message-ID: <5747608D.1090509@solarflare.com>
References: <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:51605 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754467AbcEZUqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 16:46:21 -0400
In-Reply-To: <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
This seems to work in my testing, but I first looked at the flow dissector
API less than four hours ago, so I might be doing it wrong.

I still think that this is too big a change for 'net' and that it's better
to take the original fix now and then I'll respin this patch for net-next
when it opens up.  But I'm also happy for you to take this now in which
case I'll respin Jon's patch 2/2 on top of the result.  Your choice.

 drivers/net/ethernet/sfc/rx.c | 76 +++++++++++++------------------------------
 1 file changed, 23 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8956995..adbce33 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -842,33 +842,15 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 	struct efx_filter_spec spec;
-	const __be16 *ports;
-	__be16 ether_type;
-	int nhoff;
+	struct flow_keys fk;
 	int rc;
 
-	/* The core RPS/RFS code has already parsed and validated
-	 * VLAN, IP and transport headers.  We assume they are in the
-	 * header area.
-	 */
-
-	if (skb->protocol == htons(ETH_P_8021Q)) {
-		const struct vlan_hdr *vh =
-			(const struct vlan_hdr *)skb->data;
-
-		/* We can't filter on the IP 5-tuple and the vlan
-		 * together, so just strip the vlan header and filter
-		 * on the IP part.
-		 */
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) < sizeof(*vh));
-		ether_type = vh->h_vlan_encapsulated_proto;
-		nhoff = sizeof(struct vlan_hdr);
-	} else {
-		ether_type = skb->protocol;
-		nhoff = 0;
-	}
+	if (!skb_flow_dissect_flow_keys(skb, &fk, 0))
+		return -EPROTONOSUPPORT;
 
-	if (ether_type != htons(ETH_P_IP) && ether_type != htons(ETH_P_IPV6))
+	if (fk.basic.n_proto != htons(ETH_P_IP) && fk.basic.n_proto != htons(ETH_P_IPV6))
+		return -EPROTONOSUPPORT;
+	if (fk.control.flags & FLOW_DIS_IS_FRAGMENT)
 		return -EPROTONOSUPPORT;
 
 	efx_filter_init_rx(&spec, EFX_FILTER_PRI_HINT,
@@ -878,34 +863,19 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 		EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILTER_MATCH_IP_PROTO |
 		EFX_FILTER_MATCH_LOC_HOST | EFX_FILTER_MATCH_LOC_PORT |
 		EFX_FILTER_MATCH_REM_HOST | EFX_FILTER_MATCH_REM_PORT;
-	spec.ether_type = ether_type;
-
-	if (ether_type == htons(ETH_P_IP)) {
-		const struct iphdr *ip =
-			(const struct iphdr *)(skb->data + nhoff);
-
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));
-		if (ip_is_fragment(ip))
-			return -EPROTONOSUPPORT;
-		spec.ip_proto = ip->protocol;
-		spec.rem_host[0] = ip->saddr;
-		spec.loc_host[0] = ip->daddr;
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + 4 * ip->ihl + 4);
-		ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
+	spec.ether_type = fk.basic.n_proto;
+	spec.ip_proto = fk.basic.ip_proto;
+
+	if (fk.basic.n_proto == htons(ETH_P_IP)) {
+		spec.rem_host[0] = fk.addrs.v4addrs.src;
+		spec.loc_host[0] = fk.addrs.v4addrs.dst;
 	} else {
-		const struct ipv6hdr *ip6 =
-			(const struct ipv6hdr *)(skb->data + nhoff);
-
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) <
-				    nhoff + sizeof(*ip6) + 4);
-		spec.ip_proto = ip6->nexthdr;
-		memcpy(spec.rem_host, &ip6->saddr, sizeof(ip6->saddr));
-		memcpy(spec.loc_host, &ip6->daddr, sizeof(ip6->daddr));
-		ports = (const __be16 *)(ip6 + 1);
+		memcpy(spec.rem_host, &fk.addrs.v6addrs.src, sizeof(struct in6_addr));
+		memcpy(spec.loc_host, &fk.addrs.v6addrs.dst, sizeof(struct in6_addr));
 	}
 
-	spec.rem_port = ports[0];
-	spec.loc_port = ports[1];
+	spec.rem_port = fk.ports.src;
+	spec.loc_port = fk.ports.dst;
 
 	rc = efx->type->filter_rfs_insert(efx, &spec);
 	if (rc < 0)
@@ -916,18 +886,18 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	channel = efx_get_channel(efx, skb_get_rx_queue(skb));
 	++channel->rfs_filters_added;
 
-	if (ether_type == htons(ETH_P_IP))
+	if (spec.ether_type == htons(ETH_P_IP))
 		netif_info(efx, rx_status, efx->net_dev,
 			   "steering %s %pI4:%u:%pI4:%u to queue %u [flow %u filter %d]\n",
 			   (spec.ip_proto == IPPROTO_TCP) ? "TCP" : "UDP",
-			   spec.rem_host, ntohs(ports[0]), spec.loc_host,
-			   ntohs(ports[1]), rxq_index, flow_id, rc);
+			   spec.rem_host, ntohs(spec.rem_port), spec.loc_host,
+			   ntohs(spec.loc_port), rxq_index, flow_id, rc);
 	else
 		netif_info(efx, rx_status, efx->net_dev,
 			   "steering %s [%pI6]:%u:[%pI6]:%u to queue %u [flow %u filter %d]\n",
 			   (spec.ip_proto == IPPROTO_TCP) ? "TCP" : "UDP",
-			   spec.rem_host, ntohs(ports[0]), spec.loc_host,
-			   ntohs(ports[1]), rxq_index, flow_id, rc);
+			   spec.rem_host, ntohs(spec.rem_port), spec.loc_host,
+			   ntohs(spec.loc_port), rxq_index, flow_id, rc);
 
 	return rc;
 }
