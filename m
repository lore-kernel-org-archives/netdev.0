From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] adm8211: Restore frame header after TX
Date: Sun, 23 Jul 2006 01:04:31 -0700
Message-ID: <200607230104.38326.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2590223.j4gLnklMDC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:46746 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1750888AbWGWIEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 04:04:45 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2590223.j4gLnklMDC
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

adm8211: Restore frame header after TX

This patch makes the adm8211 driver restore the TX frame's header to
the original 802.11 header before returning it to the 802.11 stack. This al=
lows
the d80211 rate control algorithm to work correctly.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c |   79 +++++++++++++--------=
=2D---
 drivers/net/wireless/d80211/adm8211/adm8211.h |   13 +++-
 2 files changed, 49 insertions(+), 43 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wi=
reless/d80211/adm8211/adm8211.c
index 4cfddf1..be4a058 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -423,7 +423,6 @@ static void adm8211_interrupt_tci(struct
 	     priv->cur_tx - dirty_tx > 0; dirty_tx++) {
 		unsigned entry =3D dirty_tx % priv->tx_ring_size;
 		u32 status =3D le32_to_cpu(priv->tx_ring[entry].status);
=2D		struct sk_buff *skb;
=20
 		if (status & TDES0_CONTROL_OWN ||
 		    !(status & TDES0_CONTROL_DONE))
@@ -438,15 +437,19 @@ static void adm8211_interrupt_tci(struct
 		} else
 			priv->tx_buffers[entry].tx_status.ack =3D 1;
=20
=2D		skb =3D priv->tx_buffers[entry].skb;
 		pci_unmap_single(priv->pdev, priv->tx_buffers[entry].mapping,
=2D				 skb->len, PCI_DMA_TODEVICE);
+				 priv->tx_buffers[entry].skb->len, PCI_DMA_TODEVICE);
=20
 		if (priv->tx_buffers[entry].tx_status.control.req_tx_status ||
=2D		    priv->tx_buffers[entry].unicast)
+		    !is_multicast_ether_addr(ieee80211_get_DA(&priv->tx_buffers[entry].h=
dr))) {
+			struct ieee80211_hdr *hdr;
+			size_t hdrlen =3D ieee80211_get_hdrlen(le16_to_cpu(priv->tx_buffers[ent=
ry].hdr.frame_control));
+			hdr =3D (struct ieee80211_hdr *) skb_pull(priv->tx_buffers[entry].skb,
+								sizeof(struct adm8211_tx_hdr) - hdrlen);
+			memcpy(hdr, &priv->tx_buffers[entry].hdr, hdrlen);
 			ieee80211_tx_status_irqsafe(dev, priv->tx_buffers[entry].skb,
 						    &priv->tx_buffers[entry].tx_status);
=2D		else
+		} else
 			dev_kfree_skb_irq(priv->tx_buffers[entry].skb);
 		priv->tx_buffers[entry].skb =3D NULL;
 	}
@@ -1527,7 +1530,8 @@ static int adm8211_init_rings(struct net
 {
 	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
 	struct adm8211_desc *desc =3D NULL;
=2D	struct adm8211_ring_info *info;
+	struct adm8211_rx_ring_info *rx_info;
+	struct adm8211_tx_ring_info *tx_info;
 	unsigned int i;
=20
 	for (i =3D 0; i < priv->rx_ring_size; i++) {
@@ -1542,26 +1546,26 @@ static int adm8211_init_rings(struct net
=20
 	for (i =3D 0; i < priv->rx_ring_size; i++) {
 		desc =3D &priv->rx_ring[i];
=2D		info =3D &priv->rx_buffers[i];
+		rx_info =3D &priv->rx_buffers[i];
=20
=2D		info->skb =3D dev_alloc_skb(RX_PKT_SIZE);
=2D		if (info->skb =3D=3D NULL)
+		rx_info->skb =3D dev_alloc_skb(RX_PKT_SIZE);
+		if (rx_info->skb =3D=3D NULL)
 			break;
=2D		info->mapping =3D pci_map_single(priv->pdev, info->skb->tail,
=2D					       RX_PKT_SIZE,
=2D					       PCI_DMA_FROMDEVICE);
=2D		info->skb->dev =3D dev;
=2D		desc->buffer1 =3D cpu_to_le32(info->mapping);
=2D		desc->status =3D cpu_to_le32( RDES0_STATUS_OWN | RDES0_STATUS_SQL );
+		rx_info->mapping =3D pci_map_single(priv->pdev, rx_info->skb->tail,
+						  RX_PKT_SIZE,
+						  PCI_DMA_FROMDEVICE);
+		rx_info->skb->dev =3D dev;
+		desc->buffer1 =3D cpu_to_le32(rx_info->mapping);
+		desc->status =3D cpu_to_le32(RDES0_STATUS_OWN | RDES0_STATUS_SQL);
 	}
=20
 	/* Setup TX ring. TX buffers descriptors will be filled in as needed */
 	for (i =3D 0; i < priv->tx_ring_size; i++) {
 		desc =3D &priv->tx_ring[i];
=2D		info =3D &priv->tx_buffers[i];
+		tx_info =3D &priv->tx_buffers[i];
=20
=2D		info->skb =3D NULL;
=2D		info->mapping =3D 0;
+		tx_info->skb =3D NULL;
+		tx_info->mapping =3D 0;
 		desc->status =3D 0;
 	}
 	desc->length =3D cpu_to_le32(TDES1_CONTROL_TER);
@@ -1750,7 +1754,8 @@ #define IEEE80211_DUR_DS_SIFS		10
=20
 /* Transmit skb w/adm8211_tx_hdr (802.11 header created by hardware) */
 static void adm8211_tx_raw(struct net_device *dev, struct sk_buff *skb,
=2D			   u16 plcp_signal, struct ieee80211_tx_control *control, int unicast)
+			   u16 plcp_signal, struct ieee80211_tx_control *control,
+			   struct ieee80211_hdr *hdr)
 {
 	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
 	unsigned long flags;
@@ -1780,7 +1785,7 @@ static void adm8211_tx_raw(struct net_de
 	priv->tx_buffers[entry].skb =3D skb;
 	priv->tx_buffers[entry].mapping =3D mapping;
 	memcpy(&priv->tx_buffers[entry].tx_status.control, control, sizeof(*contr=
ol));
=2D	priv->tx_buffers[entry].unicast =3D unicast;
+	memcpy(&priv->tx_buffers[entry].hdr, hdr, sizeof(*hdr));
 	priv->tx_ring[entry].buffer1 =3D cpu_to_le32(mapping);
=20
 	if (entry =3D=3D priv->tx_ring_size - 1)
@@ -1806,14 +1811,12 @@ static int adm8211_tx(struct net_device=20
 		      struct ieee80211_tx_control *control)
 {
 	struct adm8211_tx_hdr *txhdr;
=2D	struct ieee80211_hdr *hdr;
=2D	u16 fc_;
=2D	__le16 fc;
=2D	u8 dst[ETH_ALEN];
+	u16 fc;
 	size_t payload_len, hdrlen;
 	int plcp, dur, len;
 	int plcp_signal;
 	int short_preamble;
+	struct ieee80211_hdr hdr;
=20
 	if (control->tx_rate < 0) {
 		short_preamble =3D 1;
@@ -1823,14 +1826,11 @@ static int adm8211_tx(struct net_device=20
 		plcp_signal =3D control->tx_rate;
 	}
=20
=2D	hdr =3D (struct ieee80211_hdr *)skb->data;
=2D	fc  =3D hdr->frame_control;
=2D	fc_ =3D le16_to_cpu(fc);
=2D	memcpy(dst, ieee80211_get_DA(hdr), ETH_ALEN);
+	memcpy(&hdr, skb->data, sizeof(hdr));
=20
=2D	hdrlen =3D ieee80211_get_hdrlen(fc_);
+	fc =3D le16_to_cpu(hdr.frame_control) & ~WLAN_FC_ISWEP;
+	hdrlen =3D ieee80211_get_hdrlen(fc);
 	skb_pull(skb, hdrlen);
=2D	fc_ &=3D ~WLAN_FC_ISWEP;
 	payload_len =3D skb->len;
=20
 	if (skb_headroom(skb) < sizeof(struct adm8211_tx_hdr)) {
@@ -1844,13 +1844,13 @@ static int adm8211_tx(struct net_device=20
=20
 	txhdr =3D (struct adm8211_tx_hdr *) skb_push(skb, sizeof(*txhdr));
 	memset(txhdr, 0, sizeof(*txhdr));
=2D	memcpy(txhdr->da, dst, ETH_ALEN);
+	memcpy(txhdr->da, ieee80211_get_DA(&hdr), ETH_ALEN);
 	txhdr->signal =3D plcp_signal;
 	txhdr->frame_body_size =3D cpu_to_le16(payload_len);
=2D	txhdr->frame_control =3D fc;
+	txhdr->frame_control =3D hdr.frame_control;
=20
 	len =3D hdrlen + payload_len + FCS_LEN;
=2D	if (fc_ & WLAN_FC_ISWEP)
+	if (fc & WLAN_FC_ISWEP)
 		len +=3D 8;
=20
 	txhdr->frag =3D cpu_to_le16(0x0FFF);
@@ -1869,12 +1869,12 @@ static int adm8211_tx(struct net_device=20
 	if (control->use_rts_cts)
 		txhdr->header_control |=3D cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
=20
=2D	if (fc_ & WLAN_FC_ISWEP)
+	if (fc & WLAN_FC_ISWEP)
 		txhdr->header_control |=3D cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_WEP_ENGIN=
E);
=20
 	txhdr->retry_limit =3D control->retry_limit;
=20
=2D	adm8211_tx_raw(dev, skb, plcp_signal, control, !is_multicast_ether_addr=
(dst));
+	adm8211_tx_raw(dev, skb, plcp_signal, control, &hdr);
=20
 	return NETDEV_TX_OK;
 }
@@ -1884,12 +1884,12 @@ static int adm8211_alloc_rings(struct ne
 	struct adm8211_priv *priv =3D ieee80211_dev_hw_data(dev);
 	unsigned int ring_size;
=20
=2D	priv->rx_buffers =3D kmalloc(sizeof(struct adm8211_ring_info) *
=2D				(priv->rx_ring_size + priv->tx_ring_size), GFP_KERNEL);
+	priv->rx_buffers =3D kmalloc(sizeof(struct adm8211_rx_ring_info) * priv->=
rx_ring_size +
+				   sizeof(struct adm8211_tx_ring_info) * priv->tx_ring_size, GFP_KERNE=
L);
 	if (!priv->rx_buffers)
 		return -ENOMEM;
=20
=2D	priv->tx_buffers =3D ((void *)priv->rx_buffers) + sizeof(struct adm8211=
_ring_info) * priv->tx_ring_size;
+	priv->tx_buffers =3D ((void *)priv->rx_buffers) + sizeof(struct adm8211_r=
x_ring_info) * priv->rx_ring_size;
=20
 	/* Allocate TX/RX descriptors */
 	ring_size =3D sizeof(struct adm8211_desc) * priv->rx_ring_size +
@@ -1899,7 +1899,8 @@ static int adm8211_alloc_rings(struct ne
=20
 	if (!priv->rx_ring) {
 		kfree(priv->rx_buffers);
=2D		priv->rx_buffers =3D priv->tx_buffers =3D NULL;
+		priv->rx_buffers =3D NULL;
+		priv->tx_buffers =3D NULL;
 		return -ENOMEM;
 	}
=20
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.h b/drivers/net/wi=
reless/d80211/adm8211/adm8211.h
index 13965b4..89e0fdf 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.h
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.h
@@ -439,11 +439,16 @@ #define ADM8211_SRAM_A_SIZE      0x0200
 #define ADM8211_SRAM_B_SIZE      0x01c0
 #define ADM8211_SRAM_SIZE ADM8211_SRAM(SIZE)
=20
=2Dstruct adm8211_ring_info {
+struct adm8211_rx_ring_info {
+	struct sk_buff *skb;
+	dma_addr_t mapping;
+};
+
+struct adm8211_tx_ring_info {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
 	struct ieee80211_tx_status tx_status;
=2D	int unicast;
+	struct ieee80211_hdr hdr;
 };
=20
 struct adm8211_eeprom {
@@ -521,8 +526,8 @@ struct adm8211_priv {
 	struct adm8211_desc *tx_ring;
 	dma_addr_t rx_ring_dma;
 	dma_addr_t tx_ring_dma;
=2D	struct adm8211_ring_info *rx_buffers;
=2D	struct adm8211_ring_info *tx_buffers;
+	struct adm8211_rx_ring_info *rx_buffers;
+	struct adm8211_tx_ring_info *tx_buffers;
 	unsigned rx_ring_size, tx_ring_size;
 	unsigned cur_tx, dirty_tx, cur_rx;
=20

--nextPart2590223.j4gLnklMDC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEwy2WT3Oqt9AH4aERAtbFAJ9aKqBJ6g45jtzR9iP2LTz5RH/bHQCfQnv6
iHcfXxxuedGqZjojevlSkKs=
=EAk0
-----END PGP SIGNATURE-----

--nextPart2590223.j4gLnklMDC--
