From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH RFC] net/macb: Fix UDPv4 checksum offload
Date: Mon, 27 Apr 2015 17:43:30 -0500
Message-ID: <1430174610-6834-1-git-send-email-jaeden.amero@ni.com>
Cc: Jeff Westfahl <jeff.westfahl@ni.com>,
	Mihai Neagu <mihai.neagu@ni.com>,
	Jaeden Amero <jaeden.amero@ni.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Westfahl <jeff.westfahl@ni.com>

Some Cadence MACB hardware generates incorrect UDP checksums for
outgoing UDP packets with a payload of 2 bytes of less. If the UDP data
payload is 0, 1 or 2 bytes, transmit checksum offloading can compute an
incorrect UDPv4 header checksum (e.g. 0xffff). If we set the checksum
field in the UDP header to 0, the checksum is computed correctly.

Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
Signed-off-by: Mihai Neagu <mihai.neagu@ni.com>
Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>
---

Hey Nicolas,

We see this bug on the Zynq 7000 series chips, but it's unclear as to whether
it applies to other MACB hardware implementations.

We've scoped it to only apply to MACB_MID == 0x20118 (which is the MID we see
used on Zynq), but we, unfortunately, do not know how to identify which MACBs
have this bug.


Reproducing the Bug
-------------------
The bug is pretty easy to reproduce with two networked systems (at least one
using a MACB) and netcat.

Here is some captured data that goes out on the wire when sending the string
"a\n" and "ab\n" via netcat (UDP).

Here is a hexdump of what I observed. I underlined the UDP checksum with
"^^^^". I censored my MACs and IPs with X.

"a\n"
0000000 XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX
0000010 XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX
0000020 XXXX 4282 2923 0a00 ffff 0a61 0000 0000
                            ^^^^
0000030 0000 0000 0000 0000 0000 0000

"ab\n"
0000000 XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX
0000010 XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX
0000020 XXXX 4282 2923 0b00 c4d2 6261 000a 0000
                            ^^^^
0000030 0000 0000 0000 0000 0000 0000

As you can see, with the two byte payload, the checksum field of the UDP header
is 0xffff.


This Patch's Workaround
-----------------------
Xilinx implements a "fix" for this bug in their out-of-tree xilinx-xemacps
duplicate macb driver here[1].

The workaround is to zero the UDP checksum field in the packet before sending
the packet to the hardware.

What I'm attempting to do in this patch is to implement a real fix in a way
that is suitable for the normal Cadence MACB driver and will work with all
Cadence MACB implementations, not just those used in the Zynq.

Thanks for any feedback you can provide.

Cheers,
Jaeden


[1] https://github.com/Xilinx/linux-xlnx/commit/af2c4ebb7ac56cc5a55cbe55db05470d6e91cbe2


 drivers/net/ethernet/cadence/macb.c | 48 +++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb.h |  7 ++++++
 2 files changed, 55 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9f53872..a9214a6 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -30,6 +30,8 @@
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
 
 #include "macb.h"
 
@@ -1219,6 +1221,38 @@ dma_error:
 	return 0;
 }
 
+static void macb_handle_broken_udp_csum(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	/* Transmit checksum offloading can compute an incorrect UDPv4 header
+	 * checksum if the checksum value is not already zero.
+	 */
+	if (dev->features & NETIF_F_HW_CSUM) {
+		/* The Ethernet header is never set. */
+		skb_reset_mac_header(skb);
+		/* If the packet is IP. */
+		if (ntohs(eth_hdr(skb)->h_proto) == ETH_P_IP) {
+			/* Usually the IP header is already set. */
+			if (unlikely(!ip_hdr(skb)))
+				skb_set_network_header(skb, ETH_HLEN);
+			/* If the packet is UDPv4. */
+			if ((ip_hdr(skb)->version == 4) &&
+			    (ip_hdr(skb)->protocol == IPPROTO_UDP)) {
+				/* Sometimes the UDP header is set, sometimes
+				 * not.
+				 */
+				if (!udp_hdr(skb))
+					skb_set_transport_header(
+						skb,
+						ETH_HLEN +
+						  (ip_hdr(skb)->ihl << 2));
+					/* Clear the checksum field. */
+					udp_hdr(skb)->check = 0;
+			}
+		}
+	}
+}
+
 static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	u16 queue_index = skb_get_queue_mapping(skb);
@@ -1258,6 +1292,9 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	if (bp->quirks & MACB_QUIRK_BROKEN_UDP_CSUM_OFFLOAD)
+		macb_handle_broken_udp_csum(skb, dev);
+
 	/* Map socket buffer for DMA transfer */
 	if (!macb_tx_map(bp, queue, skb)) {
 		dev_kfree_skb_any(skb);
@@ -2153,6 +2190,14 @@ static void macb_configure_caps(struct macb *bp, const struct macb_config *dt_co
 	netdev_dbg(bp->dev, "Cadence caps 0x%08x\n", bp->caps);
 }
 
+static void macb_configure_quirks(struct macb *bp)
+{
+	if (macb_readl(bp, MID) == MACB_ZYNQ)
+		bp->quirks |= MACB_QUIRK_BROKEN_UDP_CSUM_OFFLOAD;
+
+	netdev_dbg(bp->dev, "Cadence quirks 0x%08x\n", bp->quirks);
+}
+
 static void macb_probe_queues(void __iomem *mem,
 			      unsigned int *queue_mask,
 			      unsigned int *num_queues)
@@ -2289,6 +2334,9 @@ static int macb_init(struct platform_device *pdev)
 	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 
+	/* setup quirks */
+	macb_configure_quirks(bp);
+
 	/* setup appropriated routines according to adapter type */
 	if (macb_is_gem(bp)) {
 		bp->max_tx_length = GEM_MAX_TX_LEN;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index eb7d76f..5d4ba94 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -398,6 +398,12 @@
 #define MACB_CAPS_SG_DISABLED			0x40000000
 #define MACB_CAPS_MACB_IS_GEM			0x80000000
 
+/* Quirk mask bits */
+#define MACB_QUIRK_BROKEN_UDP_CSUM_OFFLOAD	0x00000001
+
+/* Revision IDs */
+#define MACB_ZYNQ				0x20118
+
 /* Bit manipulation macros */
 #define MACB_BIT(name)					\
 	(1 << MACB_##name##_OFFSET)
@@ -815,6 +821,7 @@ struct macb {
 	unsigned int 		duplex;
 
 	u32			caps;
+	u32			quirks;
 	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
-- 
2.1.4
