From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 5/5] atl1: use kernel provided ethernet length constants
Date: Thu, 19 Jul 2007 18:45:14 -0500
Message-ID: <1184888714353-git-send-email-jacliburn@bellsouth.net>
References: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf17aec.mail.bellsouth.net ([205.152.59.65]:60964 "EHLO
	imf17aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761026AbXGSXp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 19:45:26 -0400
In-Reply-To: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use constants already provided by the kernel for ethernet related lengths.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_hw.h   |    5 -----
 drivers/net/atl1/atl1_main.c |   13 +++++++------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atl1/atl1_hw.h
index f0d7e82..939aa0f 100644
--- a/drivers/net/atl1/atl1_hw.h
+++ b/drivers/net/atl1/atl1_hw.h
@@ -680,11 +680,6 @@ void atl1_check_options(struct atl1_adapter *adapter);
 #define AUTONEG_ADVERTISE_10_100_ALL	0x000F	/* All 10/100 speeds */
 #define AUTONEG_ADVERTISE_10_ALL	0x0003	/* 10Mbps Full & Half speeds */
 
-/* The size (in bytes) of a ethernet packet */
-#define ENET_HEADER_SIZE		14
-#define MAXIMUM_ETHERNET_FRAME_SIZE	1518	/* with FCS */
-#define MINIMUM_ETHERNET_FRAME_SIZE	64	/* with FCS */
-#define ETHERNET_FCS_SIZE		4
 #define MAX_JUMBO_FRAME_SIZE		0x2800
 
 #define PHY_AUTO_NEG_TIME	45	/* 4.5 Seconds */
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 6aa2dc3..993ed2a 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -59,6 +59,7 @@
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/if_ether.h>
 #include <linux/irqreturn.h>
 #include <linux/workqueue.h>
 #include <linux/timer.h>
@@ -120,8 +121,8 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
-	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
+	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	adapter->wol = 0;
 	adapter->rx_buffer_len = (hw->max_frame_size + 7) & ~7;
@@ -688,9 +689,9 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
+	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
 		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
 		return -EINVAL;
@@ -1337,7 +1338,7 @@ rrd_ok:
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
 
-		skb_put(skb, length - ETHERNET_FCS_SIZE);
+		skb_put(skb, length - ETH_FCS_LEN);
 
 		/* Receive Checksum Offload */
 		atl1_rx_checksum(adapter, rrd, skb);
@@ -1456,7 +1457,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
 				iph->daddr, 0, IPPROTO_TCP, 0);
 			ipofst = skb_network_offset(skb);
-			if (ipofst != ENET_HEADER_SIZE) /* 802.3 frame */
+			if (ipofst != ETH_HLEN) /* 802.3 frame */
 				tso->tsopl |= 1 << TSO_PARAM_ETHTYPE_SHIFT;
 
 			tso->tsopl |= (iph->ihl &
-- 
1.5.2.2

