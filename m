From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v2 6/7] via-velocity: Set tx checksum from ethtool instead
 of module parameter
Date: Mon, 23 Nov 2009 15:31:39 +0100
Message-ID: <20091123153139.402fc748@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:36165 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755004AbZKWObl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:31:41 -0500
In-Reply-To: <20091123152724.2871cf4d@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defaults to on (as before).

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |   18 ++++--------------
 drivers/net/via-velocity.h |    1 -
 2 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 92b41fc..4af16ba 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -297,14 +297,6 @@ VELOCITY_PARAM(DMA_length, "DMA length");
 */
 VELOCITY_PARAM(IP_byte_align, "Enable IP header dword aligned");
 
-#define TX_CSUM_DEF     1
-/* txcsum_offload[] is used for setting the checksum offload ability of NIC.
-   (We only support RX checksum offload now)
-   0: disable csum_offload[checksum offload
-   1: enable checksum offload. (Default)
-*/
-VELOCITY_PARAM(txcsum_offload, "Enable transmit packet checksum offload");
-
 #define FLOW_CNTL_DEF   1
 #define FLOW_CNTL_MIN   1
 #define FLOW_CNTL_MAX   5
@@ -503,7 +495,6 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 	velocity_set_int_opt(&opts->numrx, RxDescriptors[index], RX_DESC_MIN, RX_DESC_MAX, RX_DESC_DEF, "RxDescriptors", devname);
 	velocity_set_int_opt(&opts->numtx, TxDescriptors[index], TX_DESC_MIN, TX_DESC_MAX, TX_DESC_DEF, "TxDescriptors", devname);
 
-	velocity_set_bool_opt(&opts->flags, txcsum_offload[index], TX_CSUM_DEF, VELOCITY_FLAGS_TX_CSUM, "txcsum_offload", devname);
 	velocity_set_int_opt(&opts->flow_cntl, flow_control[index], FLOW_CNTL_MIN, FLOW_CNTL_MAX, FLOW_CNTL_DEF, "flow_control", devname);
 	velocity_set_bool_opt(&opts->flags, IP_byte_align[index], IP_ALIG_DEF, VELOCITY_FLAGS_IP_ALIGN, "IP_byte_align", devname);
 	velocity_set_bool_opt(&opts->flags, ValPktLen[index], VAL_PKT_LEN_DEF, VELOCITY_FLAGS_VAL_PKT_LEN, "ValPktLen", devname);
@@ -2612,7 +2603,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	/*
 	 *	Handle hardware checksum
 	 */
-	if ((vptr->flags & VELOCITY_FLAGS_TX_CSUM)
+	if ( (dev->features & NETIF_F_IP_CSUM)
 				 && (skb->ip_summed == CHECKSUM_PARTIAL)) {
 		const struct iphdr *ip = ip_hdr(skb);
 		if (ip->protocol == IPPROTO_TCP)
@@ -2858,10 +2849,7 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
 
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
-		NETIF_F_HW_VLAN_RX;
-
-	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM)
-		dev->features |= NETIF_F_IP_CSUM;
+		NETIF_F_HW_VLAN_RX | NETIF_F_IP_CSUM;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
@@ -3421,6 +3409,8 @@ static const struct ethtool_ops velocity_ethtool_ops = {
 	.get_settings	=	velocity_get_settings,
 	.set_settings	=	velocity_set_settings,
 	.get_drvinfo	=	velocity_get_drvinfo,
+	.set_tx_csum	=	ethtool_op_set_tx_csum,
+	.get_tx_csum	=	ethtool_op_get_tx_csum,
 	.get_wol	=	velocity_ethtool_get_wol,
 	.set_wol	=	velocity_ethtool_set_wol,
 	.get_msglevel	=	velocity_get_msglevel,
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 22bfea4..cf10801 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1423,7 +1423,6 @@ enum velocity_msg_level {
  */
 
 #define     VELOCITY_FLAGS_TAGGING         0x00000001UL
-#define     VELOCITY_FLAGS_TX_CSUM         0x00000002UL
 #define     VELOCITY_FLAGS_RX_CSUM         0x00000004UL
 #define     VELOCITY_FLAGS_IP_ALIGN        0x00000008UL
 #define     VELOCITY_FLAGS_VAL_PKT_LEN     0x00000010UL
-- 
1.6.0.4

