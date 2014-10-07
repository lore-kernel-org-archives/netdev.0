From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH] net: fec: fix regression on i.MX28 introduced by rx_copybreak support
Date: Tue,  7 Oct 2014 15:19:37 +0200
Message-ID: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve rx pe=
rformance")
introduced a regression for i.MX28. The swap_buffer() function doing
the endian conversion of the received data on i.MX28 may access memory
beyond the actual packet size in the DMA buffer. fec_enet_copybreak()
does not copy those bytes, so that the last bytes of a packet may be
filled with invalid data after swapping.
This will likely lead to checksum errors on received packets.
E.g. when trying to mount an NFS rootfs:
UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 ulen =
36

Do the byte swapping and copying to the new skb in one go if
necessary.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c |   25 +++++++++++++++++++++=
----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 87975b5..eaaebad 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -339,6 +339,18 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
=20
+static void *swap_buffer2(void *dst_buf, void *src_buf, int len)
+{
+	int i;
+	unsigned int *src =3D src_buf;
+	unsigned int *dst =3D dst_buf;
+
+	for (i =3D 0; i < DIV_ROUND_UP(len, 4); i++, src++, dst++)
+		*dst =3D cpu_to_be32(*src);
+
+	return dst_buf;
+}
+
 static void fec_dump(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
@@ -1348,7 +1360,7 @@ fec_enet_new_rxbdp(struct net_device *ndev, struc=
t bufdesc *bdp, struct sk_buff
 }
=20
 static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff=
 **skb,
-			       struct bufdesc *bdp, u32 length)
+			       struct bufdesc *bdp, u32 length, int swap)
 {
 	struct  fec_enet_private *fep =3D netdev_priv(ndev);
 	struct sk_buff *new_skb;
@@ -1363,7 +1375,10 @@ static bool fec_enet_copybreak(struct net_device=
 *ndev, struct sk_buff **skb,
 	dma_sync_single_for_cpu(&fep->pdev->dev, bdp->cbd_bufaddr,
 				FEC_ENET_RX_FRSIZE - fep->rx_align,
 				DMA_FROM_DEVICE);
-	memcpy(new_skb->data, (*skb)->data, length);
+	if (!swap)
+		memcpy(new_skb->data, (*skb)->data, length);
+	else
+		swap_buffer2(new_skb->data, (*skb)->data, length);
 	*skb =3D new_skb;
=20
 	return true;
@@ -1393,6 +1408,7 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
dget, u16 queue_id)
 	u16	vlan_tag;
 	int	index =3D 0;
 	bool	is_copybreak;
+	bool need_swap =3D id_entry->driver_data & FEC_QUIRK_SWAP_FRAME;
=20
 #ifdef CONFIG_M532x
 	flush_cache_all();
@@ -1456,7 +1472,8 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
dget, u16 queue_id)
 		 * include that when passing upstream as it messes up
 		 * bridging applications.
 		 */
-		is_copybreak =3D fec_enet_copybreak(ndev, &skb, bdp, pkt_len - 4);
+		is_copybreak =3D fec_enet_copybreak(ndev, &skb, bdp, pkt_len - 4,
+						  need_swap);
 		if (!is_copybreak) {
 			skb_new =3D netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 			if (unlikely(!skb_new)) {
@@ -1471,7 +1488,7 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
dget, u16 queue_id)
 		prefetch(skb->data - NET_IP_ALIGN);
 		skb_put(skb, pkt_len - 4);
 		data =3D skb->data;
-		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
+		if (!is_copybreak && need_swap)
 			swap_buffer(data, pkt_len);
=20
 		/* Extract the enhanced buffer descriptor */
--=20
1.7.10.4
