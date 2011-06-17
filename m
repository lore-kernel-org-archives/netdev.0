From: greearb@candelatech.com
Subject: [RFC 2/2] e100:  Support receiving Ethernet FCS.
Date: Thu, 16 Jun 2011 21:30:07 -0700
Message-ID: <1308285007-11302-3-git-send-email-greearb@candelatech.com>
References: <1308285007-11302-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56841 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431Ab1FQEah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:30:37 -0400
In-Reply-To: <1308285007-11302-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Helps when sniffing packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 e336c79... 80fcadf... M	drivers/net/e100.c
 drivers/net/e100.c |   39 ++++++++++++++++++++++++++++++++++++---
 1 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e336c79..80fcadf 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -587,6 +587,7 @@ struct nic {
 		multicast_all      = (1 << 2),
 		wol_magic          = (1 << 3),
 		ich_10h_workaround = (1 << 4),
+		save_fcs           = (1 << 5),
 	} flags					____cacheline_aligned;
 
 	enum mac mac;
@@ -1130,6 +1131,9 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
 	}
 
+	if (nic->flags & save_fcs)
+		config->rx_crc_transfer = 0x1;	/* 1=save, 0=discard */
+
 	if (nic->flags & multicast_all)
 		config->multicast_all = 0x1;		/* 1=accept, 0=no */
 
@@ -1917,6 +1921,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	struct sk_buff *skb = rx->skb;
 	struct rfd *rfd = (struct rfd *)skb->data;
 	u16 rfd_status, actual_size;
+	u16 fcs_pad = 0;
 
 	if (unlikely(work_done && *work_done >= work_to_do))
 		return -EAGAIN;
@@ -1949,9 +1954,11 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	}
 
 	/* Get actual data size */
+	if (nic->flags & save_fcs)
+		fcs_pad = 4;
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
-	if (unlikely(actual_size > RFD_BUF_LEN - sizeof(struct rfd)))
-		actual_size = RFD_BUF_LEN - sizeof(struct rfd);
+	if (unlikely(actual_size > RFD_BUF_LEN + fcs_pad - sizeof(struct rfd)))
+		actual_size = RFD_BUF_LEN + fcs_pad - sizeof(struct rfd);
 
 	/* Get data */
 	pci_unmap_single(nic->pdev, rx->dma_addr,
@@ -1978,7 +1985,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	if (unlikely(!(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
 		dev_kfree_skb_any(skb);
-	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
+	} else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN + fcs_pad) {
 		/* Don't indicate oversized frames */
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
@@ -2370,6 +2377,30 @@ static int e100_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	return err;
 }
 
+static int e100_set_save_fcs(struct net_device *netdev, u32 data)
+{
+	struct nic *nic = netdev_priv(netdev);
+	if (data)
+		nic->flags |= save_fcs;
+	else
+		nic->flags &= ~save_fcs;
+
+	e100_exec_cb(nic, NULL, e100_configure);
+
+	return 0;
+}
+
+static int e100_get_save_fcs(struct net_device *netdev, u32* data)
+{
+	struct nic *nic = netdev_priv(netdev);
+	if (nic->flags & save_fcs)
+		*data = 1;
+	else
+		*data = 0;
+
+	return 0;
+}
+
 static void e100_get_drvinfo(struct net_device *netdev,
 	struct ethtool_drvinfo *info)
 {
@@ -2689,6 +2720,8 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.set_phys_id		= e100_set_phys_id,
 	.get_ethtool_stats	= e100_get_ethtool_stats,
 	.get_sset_count		= e100_get_sset_count,
+	.set_save_fcs           = e100_set_save_fcs,
+	.get_save_fcs           = e100_get_save_fcs,
 };
 
 static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-- 
1.7.3.4

