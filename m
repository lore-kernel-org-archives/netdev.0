From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv4 1/1] net: fec: fix regression on i.MX28 introduced by rx_copybreak support
Date: Fri,  7 Nov 2014 10:02:47 +0100
Message-ID: <1415350967-2238-2-git-send-email-LW@KARO-electronics.de>
References: <1415350967-2238-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415350967-2238-1-git-send-email-LW@KARO-electronics.de>
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
 drivers/net/ethernet/freescale/fec_main.c |   23 +++++++++++++++++++--=
--
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index c27128d..3dca494 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -298,6 +298,16 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
=20
+static void swap_buffer2(void *dst_buf, void *src_buf, int len)
+{
+	int i;
+	unsigned int *src =3D src_buf;
+	unsigned int *dst =3D dst_buf;
+
+	for (i =3D 0; i < len; i +=3D 4, src++, dst++)
+		*dst =3D swab32p(src);
+}
+
 static void fec_dump(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
@@ -1307,7 +1317,7 @@ fec_enet_new_rxbdp(struct net_device *ndev, struc=
t bufdesc *bdp, struct sk_buff
 }
=20
 static bool fec_enet_copybreak(struct net_device *ndev, struct sk_buff=
 **skb,
-			       struct bufdesc *bdp, u32 length)
+			       struct bufdesc *bdp, u32 length, bool swap)
 {
 	struct  fec_enet_private *fep =3D netdev_priv(ndev);
 	struct sk_buff *new_skb;
@@ -1322,7 +1332,10 @@ static bool fec_enet_copybreak(struct net_device=
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
@@ -1352,6 +1365,7 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
dget, u16 queue_id)
 	u16	vlan_tag;
 	int	index =3D 0;
 	bool	is_copybreak;
+	bool	need_swap =3D id_entry->driver_data & FEC_QUIRK_SWAP_FRAME;
=20
 #ifdef CONFIG_M532x
 	flush_cache_all();
@@ -1415,7 +1429,8 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
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
@@ -1430,7 +1445,7 @@ fec_enet_rx_queue(struct net_device *ndev, int bu=
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
