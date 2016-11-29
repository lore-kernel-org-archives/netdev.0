From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX checksum flag to stack
Date: Tue, 29 Nov 2016 13:09:45 +0000
Message-ID: <20161129130945.919372-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:50148 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752161AbcK2NKQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 08:10:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the RX checksum function to check the
status of the hardware calculated checksum and its error and
appropriately convey status to the upper stack in skb->ip_summed
field.

We only support checksum for IPv4, UDP(over IPv4 or IPv6),
TCP(over IPv4 or IPv6) and SCTP but we support many L3(IPv4, IPv6,
MPLS, PPPoE etc) and L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.)
protocols. We want to filter out L3 and L4 protocols early on for
which checksum is not supported.

Our present hardware RX Descriptor lacks L3/L4 "Checksum
Status & Error" bit (indicating whether checksum was calculated
and if there was an error encountered) for the supported protocol
received in the packet. Therefore, we do the following:
1. Filter the protocols for which checksum is not supported.
2. Check if there were any errors encountered in L3 or L4
   protocols. These errors might not just be Checksum errors but
   could be related to version, length of IPv4, UDP, TCP etc.
   2a. If L3 Errors amd L4 Errors exists, then return as our RX
       descriptor lacks Status-and-Error bits for checksum so
       cannot identify specifically if error was because of
       checksum error or other error for this packet.
   2b. If above errors do not exists, then we set checksum
       un-necessary for upper layers.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
Change Log:
Patch V2: Addressed the comment by David Miller
          Link: https://www.spinics.net/lists/netdev/msg406697.html
Patch V1: This patch is a result of the comments given by
          David Miller <davem@davemloft.net>
          Link: https://lkml.org/lkml/2016/6/15/27
---
 drivers/net/ethernet/hisilicon/hns/hnae.h     |    2 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   71 ++++++++++++++++++++++---
 2 files changed, 66 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 09602f1..8016854 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -99,6 +99,8 @@ enum hnae_led_state {
 #define HNS_RX_FLAG_L3ID_IPV6 0x1
 #define HNS_RX_FLAG_L4ID_UDP 0x0
 #define HNS_RX_FLAG_L4ID_TCP 0x1
+#define HNS_RX_FLAG_L4ID_SCTP 0x3
+
 
 #define HNS_TXD_ASID_S 0
 #define HNS_TXD_ASID_M (0xff << HNS_TXD_ASID_S)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 255fede..6450d0e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -565,6 +565,66 @@ static void get_rx_desc_bnum(u32 bnum_flag, int *out_bnum)
 				   HNS_RXD_BUFNUM_M, HNS_RXD_BUFNUM_S);
 }
 
+static void hns_nic_rx_checksum(struct hns_nic_ring_data *ring_data,
+				struct sk_buff *skb, u32 flag)
+{
+	struct net_device *netdev = ring_data->napi.dev;
+	u32 l3id;
+	u32 l4id;
+
+	/* check if RX checksum offload is enabled */
+	if (unlikely(!(netdev->features & NETIF_F_RXCSUM)))
+		return;
+
+	/* We only support checksum for IPv4,UDP(over IPv4 or IPv6), TCP(over
+	 * IPv4 or IPv6) and SCTP but we support many L3(IPv4, IPv6, MPLS,
+	 * PPPoE etc) and L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.) protocols.
+	 * We want to filter out L3 and L4 protocols early on for which checksum
+	 * is not supported.
+	 *
+	 * Our present hardware RX Descriptor lacks L3/L4 "Checksum Status &
+	 * Error" bit (indicating whether checksum was calculated and if there
+	 * was an error encountered) for the supported protocol received in the
+	 * packet. Therefore, we do the following:
+	 * 1. Filter the protocols for which checksum is not supported.
+	 * 2. Check if there were any errors encountered in L3 or L4 protocols.
+	 *    These errors might not just be Checksum errors but could be
+	 *    related to version, length of IPv4, UDP, TCP etc.
+	 *    2a. If L3 Errors amd L4 Errors exists, then return as our RX
+	 *        descriptor lacks Status-and-Error bits for checksum so cannot
+	 *        identify specifically if error was because of checksum error
+	 *        or other error for this packet.
+	 *    2b. If above errors do not exists, then we set checksum
+	 *        un-necessary for upper layers.
+	 */
+	l3id = hnae_get_field(flag, HNS_RXD_L3ID_M, HNS_RXD_L3ID_S);
+	l4id = hnae_get_field(flag, HNS_RXD_L4ID_M, HNS_RXD_L4ID_S);
+	if ((l3id != HNS_RX_FLAG_L3ID_IPV4) &&
+	    ((l3id != HNS_RX_FLAG_L3ID_IPV6) ||
+	     (l4id != HNS_RX_FLAG_L4ID_UDP)) &&
+	    ((l3id != HNS_RX_FLAG_L3ID_IPV6) ||
+	     (l4id != HNS_RX_FLAG_L4ID_TCP)) &&
+	    (l4id != HNS_RX_FLAG_L4ID_SCTP))
+		return;
+
+	/* We do not support checksum of fragmented packets */
+	if (unlikely(hnae_get_bit(flag, HNS_RXD_FRAG_B)))
+		return;
+
+	/* Check if there are any L3/L4 errors encountered during RX checksum */
+	if (unlikely(hnae_get_bit(flag, HNS_RXD_L3E_B) ||
+		     hnae_get_bit(flag, HNS_RXD_L4E_B))) {
+		/* we dont have any way to detect if this is checksum error or
+		 * any specific protocol error. Therefore, return no checksum
+		 * all protocol errors.
+		 */
+		return;
+	}
+
+	/* Now, this is a packet with valid RX checksum */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+}
+
 static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 			       struct sk_buff **out_skb, int *out_bnum)
 {
@@ -683,13 +743,10 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 	ring->stats.rx_pkts++;
 	ring->stats.rx_bytes += skb->len;
 
-	if (unlikely(hnae_get_bit(bnum_flag, HNS_RXD_L3E_B) ||
-		     hnae_get_bit(bnum_flag, HNS_RXD_L4E_B))) {
-		ring->stats.l3l4_csum_err++;
-		return 0;
-	}
-
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	/* indicate to upper stack if our hardware has already calculated
+	 * the RX checksum
+	 */
+	hns_nic_rx_checksum(ring_data, skb, bnum_flag);
 
 	return 0;
 }
-- 
1.7.9.5
