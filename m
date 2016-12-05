From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 net-next] net: hns: Fix to conditionally convey RX checksum flag to stack
Date: Mon, 5 Dec 2016 15:37:57 +0000
Message-ID: <20161205153757.386156-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the RX checksum function to check the
status of the hardware calculated checksum and its error and
appropriately convey status to the upper stack in skb->ip_summed
field.

In hardware, we only support checksum for the following
protocols:
1) IPv4,
2) TCP(over IPv4 or IPv6),
3) UDP(over IPv4 or IPv6),
4) SCTP(over IPv4 or IPv6)
but we support many L3(IPv4, IPv6, MPLS, PPPoE etc) and
L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.) protocols.

Hardware limitation:
Our present hardware RX Descriptor lacks L3/L4 checksum
"Status & Error" bit (which usually can be used to indicate whether
checksum was calculated by the hardware and if there was any error
encountered during checksum calculation).

Software workaround:
We do get info within the RX descriptor about the kind of
L3/L4 protocol coming in the packet and the error status. These
errors might not just be checksum errors but could be related to
version, length of IPv4, UDP, TCP etc.
Because there is no-way of knowing if it is a L3/L4 error due
to bad checksum or any other L3/L4 error, we will not (cannot)
convey hardware checksum status(CHECKSUM_UNNECESSARY) for such
cases to upper stack and will not maintain the RX L3/L4 checksum
counters as well.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
Change Log:
Patch V3: Re-structured the code.
Patch V2: Addressed the comment by David Miller
          Link: https://www.spinics.net/lists/netdev/msg406697.html
Patch V1: This patch is a result of the comments given by
          David Miller <davem@davemloft.net>
          Link: https://lkml.org/lkml/2016/6/15/27
---
 drivers/net/ethernet/hisilicon/hns/hnae.h     |    2 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   73 ++++++++++++++++++++++---
 2 files changed, 68 insertions(+), 7 deletions(-)

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
index 255fede..2296345 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -565,6 +565,68 @@ static void get_rx_desc_bnum(u32 bnum_flag, int *out_bnum)
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
+	/* In hardware, we only support checksum for the following protocols:
+	 * 1) IPv4,
+	 * 2) TCP(over IPv4 or IPv6),
+	 * 3) UDP(over IPv4 or IPv6),
+	 * 4) SCTP(over IPv4 or IPv6)
+	 * but we support many L3(IPv4, IPv6, MPLS, PPPoE etc) and L4(TCP,
+	 * UDP, GRE, SCTP, IGMP, ICMP etc.) protocols.
+	 *
+	 * Hardware limitation:
+	 * Our present hardware RX Descriptor lacks L3/L4 checksum "Status &
+	 * Error" bit (which usually can be used to indicate whether checksum
+	 * was calculated by the hardware and if there was any error encountered
+	 * during checksum calculation).
+	 *
+	 * Software workaround:
+	 * We do get info within the RX descriptor about the kind of L3/L4
+	 * protocol coming in the packet and the error status. These errors
+	 * might not just be checksum errors but could be related to version,
+	 * length of IPv4, UDP, TCP etc.
+	 * Because there is no-way of knowing if it is a L3/L4 error due to bad
+	 * checksum or any other L3/L4 error, we will not (cannot) convey
+	 * checksum status for such cases to upper stack and will not maintain
+	 * the RX L3/L4 checksum counters as well.
+	 */
+
+	/*  check L3 protocol for which checksum is supported */
+	if ((l3id != HNS_RX_FLAG_L3ID_IPV4) && (l3id != HNS_RX_FLAG_L3ID_IPV6))
+		return;
+
+	/* check for any(not just checksum)flagged L3 protocol errors */
+	if (unlikely(hnae_get_bit(flag, HNS_RXD_L3E_B)))
+		return;
+
+	/* we do not support checksum of fragmented packets */
+	if (unlikely(hnae_get_bit(flag, HNS_RXD_FRAG_B)))
+		return;
+
+	/*  check L4 protocol for which checksum is supported */
+	if ((l4id != HNS_RX_FLAG_L4ID_TCP) &&
+	    (l4id != HNS_RX_FLAG_L4ID_UDP) &&
+	    (l4id != HNS_RX_FLAG_L4ID_SCTP))
+		return;
+
+	/* check for any(not just checksum)flagged L4 protocol errors */
+	if (unlikely(hnae_get_bit(flag, HNS_RXD_L4E_B)))
+		return;
+
+	/* now, this has to be a packet with valid RX checksum */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+}
+
 static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 			       struct sk_buff **out_skb, int *out_bnum)
 {
@@ -683,13 +745,10 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
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
