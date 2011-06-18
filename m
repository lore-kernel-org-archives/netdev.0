From: greearb@candelatech.com
Subject: [PATCH v2 3/5] e100:  Support receiving errored frames.
Date: Sat, 18 Jun 2011 13:47:23 -0700
Message-ID: <1308430045-24816-4-git-send-email-greearb@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33326 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab1FRUsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:48:20 -0400
In-Reply-To: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can be helpful when sniffing dodgy networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 647d8c6... aad303d... M	drivers/net/e100.c
 drivers/net/e100.c |   42 ++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 647d8c6..aad303d 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -588,6 +588,7 @@ struct nic {
 		wol_magic          = (1 << 3),
 		ich_10h_workaround = (1 << 4),
 		save_rxfcs         = (1 << 5),
+		save_rxerr         = (1 << 6),
 	} flags					____cacheline_aligned;
 
 	enum mac mac;
@@ -1126,9 +1127,13 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->full_duplex_force = 0x1;	/* 1=force, 0=auto */
 
 	if (nic->flags & promiscuous || nic->loopback) {
+		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
+	}
+
+	if (nic->flags & save_rxerr) {
+		config->rx_discard_overruns = 0x1;	/* 1=save, 0=discard */
 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
-		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
 	}
 
 	if (nic->flags & save_rxfcs)
@@ -1983,7 +1988,18 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	skb_put(skb, actual_size);
 	skb->protocol = eth_type_trans(skb, nic->netdev);
 
-	if (unlikely(!(rfd_status & cb_ok))) {
+	if (unlikely(nic->flags & save_rxerr)) {
+		if (!(rfd_status & cb_ok)) {
+			skb->pkt_type = PACKET_INVALID;
+		} else if (actual_size >
+			   ETH_DATA_LEN + VLAN_ETH_HLEN + rxfcs_pad) {
+			nic->rx_over_length_errors++;
+			skb->pkt_type = PACKET_INVALID;
+		}
+		goto process_skb;
+	}
+
+	if (unlikely((nic->flags & save_rxerr) && !(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
 		dev_kfree_skb_any(skb);
 	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN + rxfcs_pad) {
@@ -1991,6 +2007,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
 	} else {
+process_skb:
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += actual_size;
 		netif_receive_skb(skb);
@@ -2397,6 +2414,25 @@ static u32 e100_get_save_rxfcs(struct net_device *netdev)
 	return !!(nic->flags & save_rxfcs);
 }
 
+static int e100_set_save_rxerr(struct net_device *netdev, u32 data)
+{
+	struct nic *nic = netdev_priv(netdev);
+	if (data)
+		nic->flags |= save_rxerr;
+	else
+		nic->flags &= ~save_rxerr;
+
+	e100_exec_cb(nic, NULL, e100_configure);
+
+	return 0;
+}
+
+static u32 e100_get_save_rxerr(struct net_device *netdev)
+{
+	struct nic *nic = netdev_priv(netdev);
+	return !!(nic->flags & save_rxerr);
+}
+
 static void e100_get_drvinfo(struct net_device *netdev,
 	struct ethtool_drvinfo *info)
 {
@@ -2718,6 +2754,8 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.get_sset_count		= e100_get_sset_count,
 	.set_save_rxfcs		= e100_set_save_rxfcs,
 	.get_save_rxfcs		= e100_get_save_rxfcs,
+	.set_save_rxerr		= e100_set_save_rxerr,
+	.get_save_rxerr		= e100_get_save_rxerr,
 };
 
 static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-- 
1.7.3.4

