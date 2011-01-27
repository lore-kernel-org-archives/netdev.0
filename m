From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen: netfront: handle incoming GSO SKBs which are not CHECKSUM_PARTIAL
Date: Thu, 27 Jan 2011 14:14:03 +0000
Message-ID: <1296137643-24814-1-git-send-email-ian.campbell@citrix.com>
References: <1296042981.14780.6813.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	David Miller <davem@davemloft.net>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3370 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752925Ab1A0OOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 09:14:14 -0500
In-Reply-To: <1296042981.14780.6813.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Linux network stack expects all GSO SKBs to have ip_summed ==
CHECKSUM_PARTIAL (which implies that the frame contains a partial
checksum) and the Xen network ring protocol similarly expects an SKB
which has GSO set to also have NETRX_csum_blank (which also implies a
partial checksum).

However there have been cases of buggy guests which mark a frame as
GSO but do not set csum_blank. If we detect that we a receiving such a
frame (which manifests as ip_summed != PARTIAL && skb_is_gso) then
force the SKB to partial and recalculate the checksum, since we cannot
rely on the peer having done so if they have not set csum_blank.

Add an ethtool stat to track occurances of this event.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: David Miller <davem@davemloft.net>
Cc: xen-devel@lists.xensource.com
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c |   96 ++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 88 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 546de57..da1f121 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -120,6 +120,9 @@ struct netfront_info {
 	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
 	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+
+	/* Statistics */
+	int rx_gso_checksum_fixup;
 };
 
 struct netfront_rx_info {
@@ -770,11 +773,29 @@ static RING_IDX xennet_fill_frags(struct netfront_info *np,
 	return cons;
 }
 
-static int skb_checksum_setup(struct sk_buff *skb)
+static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 {
 	struct iphdr *iph;
 	unsigned char *th;
 	int err = -EPROTO;
+	int recalculate_partial_csum = 0;
+
+	/*
+	 * A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
+	 * peers can fail to set NETRXF_csum_blank when sending a GSO
+	 * frame. In this case force the SKB to CHECKSUM_PARTIAL and
+	 * recalculate the partial checksum.
+	 */
+	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb)) {
+		struct netfront_info *np = netdev_priv(dev);
+		np->rx_gso_checksum_fixup++;
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		recalculate_partial_csum = 1;
+	}
+
+	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
 
 	if (skb->protocol != htons(ETH_P_IP))
 		goto out;
@@ -788,9 +809,23 @@ static int skb_checksum_setup(struct sk_buff *skb)
 	switch (iph->protocol) {
 	case IPPROTO_TCP:
 		skb->csum_offset = offsetof(struct tcphdr, check);
+
+		if (recalculate_partial_csum) {
+			struct tcphdr *tcph = (struct tcphdr *)th;
+			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 skb->len - iph->ihl*4,
+							 IPPROTO_TCP, 0);
+		}
 		break;
 	case IPPROTO_UDP:
 		skb->csum_offset = offsetof(struct udphdr, check);
+
+		if (recalculate_partial_csum) {
+			struct udphdr *udph = (struct udphdr *)th;
+			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 skb->len - iph->ihl*4,
+							 IPPROTO_UDP, 0);
+		}
 		break;
 	default:
 		if (net_ratelimit())
@@ -829,13 +864,11 @@ static int handle_incoming_queue(struct net_device *dev,
 		/* Ethernet work: Delayed to here as it peeks the header. */
 		skb->protocol = eth_type_trans(skb, dev);
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			if (skb_checksum_setup(skb)) {
-				kfree_skb(skb);
-				packets_dropped++;
-				dev->stats.rx_errors++;
-				continue;
-			}
+		if (checksum_setup(dev, skb)) {
+			kfree_skb(skb);
+			packets_dropped++;
+			dev->stats.rx_errors++;
+			continue;
 		}
 
 		dev->stats.rx_packets++;
@@ -1632,12 +1665,59 @@ static void netback_changed(struct xenbus_device *dev,
 	}
 }
 
+static const struct xennet_stat {
+	char name[ETH_GSTRING_LEN];
+	u16 offset;
+} xennet_stats[] = {
+	{
+		"rx_gso_checksum_fixup",
+		offsetof(struct netfront_info, rx_gso_checksum_fixup)
+	},
+};
+
+static int xennet_get_sset_count(struct net_device *dev, int string_set)
+{
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(xennet_stats);
+	default:
+		return -EINVAL;
+	}
+}
+
+static void xennet_get_ethtool_stats(struct net_device *dev,
+				     struct ethtool_stats *stats, u64 * data)
+{
+	void *np = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(xennet_stats); i++)
+		data[i] = *(int *)(np + xennet_stats[i].offset);
+}
+
+static void xennet_get_strings(struct net_device *dev, u32 stringset, u8 * data)
+{
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < ARRAY_SIZE(xennet_stats); i++)
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       xennet_stats[i].name, ETH_GSTRING_LEN);
+		break;
+	}
+}
+
 static const struct ethtool_ops xennet_ethtool_ops =
 {
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = xennet_set_sg,
 	.set_tso = xennet_set_tso,
 	.get_link = ethtool_op_get_link,
+
+	.get_sset_count = xennet_get_sset_count,
+	.get_ethtool_stats = xennet_get_ethtool_stats,
+	.get_strings = xennet_get_strings,
 };
 
 #ifdef CONFIG_SYSFS
-- 
1.5.6.5

