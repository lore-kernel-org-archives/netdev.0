From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next] net: hns: Fix to conditionally convey RX checksum flag to stack
Date: Fri, 25 Nov 2016 13:32:40 +0000
Message-ID: <20161125133240.1264224-1-salil.mehta@huawei.com>
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

We only support checksum for IPv4, UDP(over IPv4 or IPv6),
TCP(over IPv4 or IPv6) and SCTP but we support many L3(IPv4, IPv6,
MPLS, PPPoE etc) and L4(TCP, UDP, GRE, SCTP, IGMP, ICMP etc.)
protocols. We want to filter out L3 and L4 protocols early on for
which checksum is not supported.

Our present hardware RX Descriptor lacks L3/L4 "Checksum
Status & Error" bit (indicating whether checksum was calculated
and if there was an error encountered) for the supported protocol
received in the packet. Therefore, we do the following to optimize
the logic:
1. Filter the protocols for which checksum is not supported.
2. Check if there were any errors encountered in L3 or L4
   protocols. These errors might not just be Checksum errors but
   could be related to version, length of IPv4, UDP, TCP etc.
   2a. If L3 Errors amd L4 Errors exists, then try to check
       if any of  these errors were the RX checksum errors of
       IPv4, TCP or UDP. This is done by accessing the register
       in the HNS hardware.
   2b. If above errors do not exists, then we set checksum
       un-necessary for upper layers.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
Change Log:
Patch V1: This patch is a result of the comments given by
          David Miller <davem@davemloft.net>
          Link: https://lkml.org/lkml/2016/6/15/27
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |    3 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |   30 ++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    6 ++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     |   76 +++++++++++++++++++--
 4 files changed, 108 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 09602f1..fc6ff5e 100644
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
@@ -513,6 +515,7 @@ struct hnae_ae_ops {
 			  enum hnae_led_state status);
 	void (*get_regs)(struct hnae_handle *handle, void *data);
 	int (*get_regs_len)(struct hnae_handle *handle);
+	bool (*is_l3l4csum_err)(struct hnae_handle *handle);
 	u32	(*get_rss_key_size)(struct hnae_handle *handle);
 	u32	(*get_rss_indir_size)(struct hnae_handle *handle);
 	int	(*get_rss)(struct hnae_handle *handle, u32 *indir, u8 *key,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 0a9cdf0..4ca130f4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -778,6 +778,35 @@ int hns_ae_get_regs_len(struct hnae_handle *handle)
 	return total_num;
 }
 
+static bool hns_ae_is_l3l4_csum_err(struct hnae_handle *handle)
+{
+	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
+	u32 regval;
+	bool retval = false;
+
+	/* read PPE_HIS_PRO_ERR register and check for the checksum errors */
+	regval = dsaf_read_dev(ppe_cb, PPE_HIS_PRO_ERR_REG);
+
+	if (dsaf_get_bit(regval, PPE_L4_TCP_CSUM_ERR_B)) {
+		dsaf_set_bit(regval, PPE_L4_TCP_CSUM_ERR_B, 0);
+		retval = true;
+	} else if (dsaf_get_bit(regval, PPE_L4_IPV6_UDP_CSUM_ERR_B)) {
+		dsaf_set_bit(regval, PPE_L4_IPV6_UDP_CSUM_ERR_B, 0);
+		retval = true;
+	} else if (dsaf_get_bit(regval, PPE_L4_IPV4_UDP_CSUM_ERR_B)) {
+		dsaf_set_bit(regval, PPE_L4_IPV4_UDP_CSUM_ERR_B, 0);
+		retval = true;
+	} else if (dsaf_get_bit(regval, PPE_L3_IPV4_CSUM_ERR_B)) {
+		dsaf_set_bit(regval, PPE_L3_IPV4_CSUM_ERR_B, 0);
+		retval = true;
+	} else if (dsaf_get_bit(regval, PPE_L4_SCTP_CSUM_ERR_B)) {
+		dsaf_set_bit(regval, PPE_L4_SCTP_CSUM_ERR_B, 0);
+		retval = true;
+	}
+
+	return retval;
+}
+
 static u32 hns_ae_get_rss_key_size(struct hnae_handle *handle)
 {
 	return HNS_PPEV2_RSS_KEY_SIZE;
@@ -866,6 +895,7 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 	.set_led_id = hns_ae_cpld_set_led_id,
 	.get_regs = hns_ae_get_regs,
 	.get_regs_len = hns_ae_get_regs_len,
+	.is_l3l4csum_err = hns_ae_is_l3l4_csum_err,
 	.get_rss_key_size = hns_ae_get_rss_key_size,
 	.get_rss_indir_size = hns_ae_get_rss_indir_size,
 	.get_rss = hns_ae_get_rss,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 8722668..5f9cb4f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -904,6 +904,12 @@
 #define PPE_INT_GAPTIME_B	0
 #define PPE_INT_GAPTIME_M	0x3ff
 
+#define PPE_L4_TCP_CSUM_ERR_B 4
+#define PPE_L4_IPV6_UDP_CSUM_ERR_B 5
+#define PPE_L4_IPV4_UDP_CSUM_ERR_B 6
+#define PPE_L3_IPV4_CSUM_ERR_B 16
+#define PPE_L4_SCTP_CSUM_ERR_B 28
+
 #define PPE_COMMON_CNT_CLR_CE_B	0
 #define PPE_COMMON_CNT_CLR_SNAP_EN_B	1
 #define RCB_COM_TSO_MODE_B	0
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 776d81e..2c69596 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -566,6 +566,71 @@ static void get_rx_desc_bnum(u32 bnum_flag, int *out_bnum)
 				   HNS_RXD_BUFNUM_M, HNS_RXD_BUFNUM_S);
 }
 
+static void hns_nic_rx_checksum(struct hns_nic_ring_data *ring_data,
+				struct sk_buff *skb, u32 flag)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	struct net_device *netdev = ring_data->napi.dev;
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *aeh = priv->ae_handle;
+	struct hnae_ae_ops *ops = aeh->dev->ops;
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
+	 * packet. Therefore, we do the following to optimize the logic:
+	 * 1. Filter the protocols for which checksum is not supported.
+	 * 2. Check if there were any errors encountered in L3 or L4 protocols.
+	 *    These errors might not just be Checksum errors but could be
+	 *    related to version, length of IPv4, UDP, TCP etc.
+	 *    2a. If L3 Errors amd L4 Errors exists, then try to check if any of
+	 *        these errors were the RX checksum errors of IPv4, TCP or UDP.
+	 *        This is done by accessing the register in the HNS hardware.
+	 *    2b. If above errors do not exists, then we set checsum
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
+		/* this is bit clumsy, we have to read the register to
+		 * know if this is actually a checksum error
+		 */
+		if (ops->is_l3l4csum_err && ops->is_l3l4csum_err(aeh)) {
+			ring->stats.l3l4_csum_err++;
+			return;
+		}
+	}
+
+	/* Now, this is a packet with valid RX checksum */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+}
+
 static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 			       struct sk_buff **out_skb, int *out_bnum)
 {
@@ -684,13 +749,10 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
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
