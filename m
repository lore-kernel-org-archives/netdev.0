From: Daniel Axtens <dja@axtens.net>
Subject: [PATCH] bnx2x: drop packets where gso_size is too big for hardware
Date: Thu, 31 Aug 2017 15:46:42 +1000
Message-ID: <20170831054642.13721-1-dja@axtens.net>
Cc: tlfalcon@linux.vnet.ibm.com, Yuval.Mintz@cavium.com,
        ariel.elior@cavium.com, everest-linux-l2@cavium.com,
        jay.vosburgh@canonical.com, Daniel Axtens <dja@axtens.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32867 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdHaFqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 01:46:54 -0400
Received: by mail-pf0-f196.google.com with SMTP id r62so2892312pfj.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 22:46:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a bnx2x card is passed a GSO packet with a gso_size larger than
~9700 bytes, it will cause a firmware error that will bring the card
down:

bnx2x: [bnx2x_attn_int_deasserted3:4323(enP24p1s0f0)]MC assert!
bnx2x: [bnx2x_mc_assert:720(enP24p1s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
bnx2x: [bnx2x_mc_assert:736(enP24p1s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43e47 0x00463e01 0x00010052
bnx2x: [bnx2x_mc_assert:750(enP24p1s0f0)]Chip Revision: everest3, FW Version: 7_13_1
... (dump of values continues) ...

Detect when gso_size + header length is greater than the maximum
packet size (9700 bytes) and drop the packet.

This raises the obvious question - how do we end up with a packet with
a gso_size that's greater than 9700? This has been observed on an
powerpc system when Open vSwitch is forwarding a packet from an
ibmveth device.

ibmveth is a bit special. It's the driver for communication between
virtual machines (aka 'partitions'/LPARs) running under IBM's
proprietary hypervisor on ppc machines. It allows sending very large
packets (up to 64kB) between LPARs. This involves some quite
'interesting' things: for example, when talking TCP, the MSS is stored
the checksum field (see ibmveth_rx_mss_helper() in ibmveth.c).

Normally on a box like this, there would be a Virtual I/O Server
(VIOS) partition that owns the physical network card. VIOS lets the
AIX partitions know when they're talking to a real network and that
they should drop their MSS. This works fine if VIOS owns the physical
network card.

However, in this case, a Linux partition owns the card (this is known
as a NovaLink setup). The negotiation between VIOS and AIX uses a
non-standard TCP option, so Linux has never supported that.  Instead,
Linux just supports receiving large packets. It doesn't support any
form of messaging/MSS negotiation back to other LPARs.

To get some clarity about where the large MSS was coming from, I asked
Thomas Falcon, the maintainer of ibmveth, for some background:

"In most cases, large segments are an aggregation of smaller packets
by the Virtual I/O Server (VIOS) partition and then are forwarded to
the Linux LPAR / ibmveth driver. These segments can be as large as
64KB. In this case, since the customer is using Novalink, I believe
what is happening is pretty straightforward: the large segments are
created by the AIX partition and then forwarded to the Linux
partition, ... The ibmveth driver doesn't do any aggregation itself
but just ensures the proper bits are set before sending the frame up
to avoid giving the upper layers indigestion."

It is possible to stop AIX from sending these large segments, but it
requires configuration on each LPAR. While ibmveth's behaviour is
admittedly weird, we should fix this here: it shouldn't be possible
for it to cause a firmware panic on another card.

Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com> # ibmveth
Cc: Yuval Mintz <Yuval.Mintz@cavium.com> # bnx2x
Thanks-to: Jay Vosburgh <jay.vosburgh@canonical.com> # veth info
Signed-off-by: Daniel Axtens <dja@axtens.net>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 33 +++++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  1 -
 3 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 352beff796ae..b36d54737d70 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2517,4 +2517,6 @@ void bnx2x_set_rx_ts(struct bnx2x *bp, struct sk_buff *skb);
  */
 int bnx2x_vlan_reconfigure_vid(struct bnx2x *bp);
 
+#define MAX_PACKET_SIZE	(9700)
+
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1216c1f1e052..1c5517a9348c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3742,6 +3742,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	__le16 pkt_size = 0;
 	struct ethhdr *eth;
 	u8 mac_type = UNICAST_ADDRESS;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -4029,6 +4030,14 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		   skb->len, hlen, skb_headlen(skb),
 		   skb_shinfo(skb)->gso_size);
 
+		if (unlikely(skb_shinfo(skb)->gso_size + hlen > MAX_PACKET_SIZE)) {
+			BNX2X_ERR("reported gso segment size plus headers "
+				  "(%d + %d) > MAX_PACKET_SIZE; dropping pkt!",
+				  skb_shinfo(skb)->gso_size, hlen);
+
+			goto free_and_drop;
+		}
+
 		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
 
 		if (unlikely(skb_headlen(skb) > hlen)) {
@@ -4061,21 +4070,10 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		mapping = skb_frag_dma_map(&bp->pdev->dev, frag, 0,
 					   skb_frag_size(frag), DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-			unsigned int pkts_compl = 0, bytes_compl = 0;
-
 			DP(NETIF_MSG_TX_QUEUED,
 			   "Unable to map page - dropping packet...\n");
 
-			/* we need unmap all buffers already mapped
-			 * for this SKB;
-			 * first_bd->nbd need to be properly updated
-			 * before call to bnx2x_free_tx_pkt
-			 */
-			first_bd->nbd = cpu_to_le16(nbd);
-			bnx2x_free_tx_pkt(bp, txdata,
-					  TX_BD(txdata->tx_pkt_prod),
-					  &pkts_compl, &bytes_compl);
-			return NETDEV_TX_OK;
+			goto free_and_drop;
 		}
 
 		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
@@ -4176,6 +4174,17 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txdata->tx_pkt++;
 
 	return NETDEV_TX_OK;
+
+free_and_drop:
+	/*
+	 * we need unmap all buffers already mapped for this SKB;
+	 * first_bd->nbd need to be properly updated before call to
+	 * bnx2x_free_tx_pkt
+	 */
+	first_bd->nbd = cpu_to_le16(nbd);
+	bnx2x_free_tx_pkt(bp, txdata, TX_BD(txdata->tx_pkt_prod),
+			  &pkts_compl, &bytes_compl);
+	return NETDEV_TX_OK;
 }
 
 void bnx2x_get_c2s_mapping(struct bnx2x *bp, u8 *c2s_map, u8 *c2s_default)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 7dd83d0ef0a0..59a3a9419cde 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -189,7 +189,6 @@ typedef int (*read_sfp_module_eeprom_func_p)(struct bnx2x_phy *phy,
 #define ETS_E3B0_NIG_MIN_W_VAL_20GBPS			(2720)
 #define ETS_E3B0_PBF_MIN_W_VAL				(10000)
 
-#define MAX_PACKET_SIZE					(9700)
 #define MAX_KR_LINK_RETRY				4
 #define DEFAULT_TX_DRV_BRDCT		2
 #define DEFAULT_TX_DRV_IFIR		0
-- 
2.11.0
