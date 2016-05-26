From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 1/2] sfc: handle nonlinear SKBs in efx_filter_rfs()
Date: Thu, 26 May 2016 17:01:57 +0100
Message-ID: <57471DF5.8010901@solarflare.com>
References: <57471D92.2000708@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:31179 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbcEZQCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 12:02:08 -0400
In-Reply-To: <57471D92.2000708@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously efx_filter_rfs() assumed that the headers it needed (802.1Q, IP)
 would be present in the linear data area of the SKB.
When running with debugging I found that this is not always the case and
 that in fact the data may all be paged.
So now use skb_header_pointer() to extract the data.

Also replace EFX_BUG_ON_PARANOID checks for insufficient data with checks
 that return -EINVAL, as this case is possible if the received packet was
 too short.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 39 +++++++++++++++++++++++----------------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8956995..52790f0 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -842,25 +842,32 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 	struct efx_filter_spec spec;
+	/* 60 octets is the maximum length of an IPv4 header (all IPv6 headers
+	 * are 40 octets), and we pull 4 more to get the port numbers
+	 */
+	#define EFX_RFS_HEADER_LENGTH	(sizeof(struct vlan_hdr) + 60 + 4)
+	unsigned char header[EFX_RFS_HEADER_LENGTH];
+	int headlen = min_t(int, EFX_RFS_HEADER_LENGTH, skb->len);
+	#undef EFX_RFS_HEADER_LENGTH
+	void *hptr;
 	const __be16 *ports;
 	__be16 ether_type;
 	int nhoff;
 	int rc;
 
-	/* The core RPS/RFS code has already parsed and validated
-	 * VLAN, IP and transport headers.  We assume they are in the
-	 * header area.
-	 */
+	hptr = skb_header_pointer(skb, 0, headlen, header);
+	if (!hptr)
+		return -EINVAL;
 
 	if (skb->protocol == htons(ETH_P_8021Q)) {
-		const struct vlan_hdr *vh =
-			(const struct vlan_hdr *)skb->data;
+		const struct vlan_hdr *vh = hptr;
 
 		/* We can't filter on the IP 5-tuple and the vlan
 		 * together, so just strip the vlan header and filter
 		 * on the IP part.
 		 */
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) < sizeof(*vh));
+		if (headlen < sizeof(*vh))
+			return -EINVAL;
 		ether_type = vh->h_vlan_encapsulated_proto;
 		nhoff = sizeof(struct vlan_hdr);
 	} else {
@@ -881,23 +888,23 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	spec.ether_type = ether_type;
 
 	if (ether_type == htons(ETH_P_IP)) {
-		const struct iphdr *ip =
-			(const struct iphdr *)(skb->data + nhoff);
+		const struct iphdr *ip = hptr + nhoff;
 
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));
+		if (headlen < nhoff + sizeof(*ip))
+			return -EINVAL;
 		if (ip_is_fragment(ip))
 			return -EPROTONOSUPPORT;
 		spec.ip_proto = ip->protocol;
 		spec.rem_host[0] = ip->saddr;
 		spec.loc_host[0] = ip->daddr;
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + 4 * ip->ihl + 4);
-		ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
+		if (headlen < nhoff + 4 * ip->ihl + 4)
+			return -EINVAL;
+		ports = (const __be16 *)(hptr + nhoff + 4 * ip->ihl);
 	} else {
-		const struct ipv6hdr *ip6 =
-			(const struct ipv6hdr *)(skb->data + nhoff);
+		const struct ipv6hdr *ip6 = (hptr + nhoff);
 
-		EFX_BUG_ON_PARANOID(skb_headlen(skb) <
-				    nhoff + sizeof(*ip6) + 4);
+		if (headlen < nhoff + sizeof(*ip6) + 4)
+			return -EINVAL;
 		spec.ip_proto = ip6->nexthdr;
 		memcpy(spec.rem_host, &ip6->saddr, sizeof(ip6->saddr));
 		memcpy(spec.loc_host, &ip6->daddr, sizeof(ip6->daddr));
