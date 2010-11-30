From: =?utf-8?q?Micha=C5=82?= =?utf-8?b?TWlyb3PFgmF3?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Fix drivers advertising HW_CSUM feature to use csum_start
Date: Tue, 30 Nov 2010 15:23:52 +0100
Message-ID: <20101130142352.3936.33510.stgit@rechot.qmqm.pl>
References: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vget.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56612 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab0K3OtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 09:49:18 -0500
In-Reply-To: <fddashfjkasdhklfjashlkjfs@rechot.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers are using skb_transport_offset(skb) instead of skb->csum_s=
tart.
This does not matter now, but if someone implements checksumming of
encapsulated packets then this will break silently.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/atl1c/atl1c_main.c    |    2 +-
 drivers/net/atl1e/atl1e_main.c    |    2 +-
 drivers/net/atlx/atl1.c           |    2 +-
 drivers/net/cassini.c             |    2 +-
 drivers/net/e1000/e1000_main.c    |    2 +-
 drivers/net/e1000e/netdev.c       |    2 +-
 drivers/net/enic/enic_main.c      |    2 +-
 drivers/net/ixgb/ixgb_main.c      |    2 +-
 drivers/net/ll_temac_main.c       |    2 +-
 drivers/net/macvtap.c             |    3 +--
 drivers/net/myri10ge/myri10ge.c   |    2 +-
 drivers/net/niu.c                 |    2 +-
 drivers/net/skge.c                |    2 +-
 drivers/net/sungem.c              |    2 +-
 drivers/net/sunhme.c              |    2 +-
 drivers/net/tun.c                 |    2 +-
 drivers/net/usb/smsc95xx.c        |    7 +++----
 drivers/net/virtio_net.c          |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c |    4 ++--
 include/linux/skbuff.h            |    5 +++++
 20 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 09b099b..e48ea95 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2078,7 +2078,7 @@ static int atl1c_tso_csum(struct atl1c_adapter *a=
dapter,
 check_sum:
 	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
 		u8 css, cso;
-		cso =3D skb_transport_offset(skb);
+		cso =3D skb_checksum_start_offset(skb);
=20
 		if (unlikely(cso & 0x1)) {
 			if (netif_msg_tx_err(adapter))
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index ef6349b..e28f8ba 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1649,7 +1649,7 @@ check_sum:
 	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
 		u8 css, cso;
=20
-		cso =3D skb_transport_offset(skb);
+		cso =3D skb_checksum_start_offset(skb);
 		if (unlikely(cso & 0x1)) {
 			netdev_err(adapter->netdev,
 				   "payload offset should not ant event number\n");
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 5336310..def8df8 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2174,7 +2174,7 @@ static int atl1_tx_csum(struct atl1_adapter *adap=
ter, struct sk_buff *skb,
 	u8 css, cso;
=20
 	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
-		css =3D (u8) (skb->csum_start - skb_headroom(skb));
+		css =3D skb_checksum_start_offset(skb);
 		cso =3D css + (u8) skb->csum_offset;
 		if (unlikely(css & 0x1)) {
 			/* L1 hardware requires an even number here */
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index d6b6d6a..35568c1 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2788,7 +2788,7 @@ static inline int cas_xmit_tx_ringN(struct cas *c=
p, int ring,
=20
 	ctrl =3D 0;
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-		const u64 csum_start_off =3D skb_transport_offset(skb);
+		const u64 csum_start_off =3D skb_checksum_start_offset(skb);
 		const u64 csum_stuff_off =3D csum_start_off + skb->csum_offset;
=20
 		ctrl =3D  TX_DESC_CSUM_EN |
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index dcb7f82..9426e04 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2720,7 +2720,7 @@ static bool e1000_tx_csum(struct e1000_adapter *a=
dapter,
 		break;
 	}
=20
-	css =3D skb_transport_offset(skb);
+	css =3D skb_checksum_start_offset(skb);
=20
 	i =3D tx_ring->next_to_use;
 	buffer_info =3D &tx_ring->buffer_info[i];
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0adcb79..9bb9406 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4473,7 +4473,7 @@ static bool e1000_tx_csum(struct e1000_adapter *a=
dapter, struct sk_buff *skb)
 		break;
 	}
=20
-	css =3D skb_transport_offset(skb);
+	css =3D skb_checksum_start_offset(skb);
=20
 	i =3D tx_ring->next_to_use;
 	buffer_info =3D &tx_ring->buffer_info[i];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index 9f293fa..78e9d8b 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -702,7 +702,7 @@ static inline void enic_queue_wq_skb_csum_l4(struct=
 enic *enic,
 {
 	unsigned int head_len =3D skb_headlen(skb);
 	unsigned int len_left =3D skb->len - head_len;
-	unsigned int hdr_len =3D skb_transport_offset(skb);
+	unsigned int hdr_len =3D skb_checksum_start_offset(skb);
 	unsigned int csum_offset =3D hdr_len + skb->csum_offset;
 	int eop =3D (len_left =3D=3D 0);
=20
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.=
c
index 211a169..23ec89e 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1250,7 +1250,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct=
 sk_buff *skb)
=20
 	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
 		struct ixgb_buffer *buffer_info;
-		css =3D skb_transport_offset(skb);
+		css =3D skb_checksum_start_offset(skb);
 		cso =3D css + skb->csum_offset;
=20
 		i =3D adapter->tx_ring.next_to_use;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 9f8e702..e2c2a72 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -692,7 +692,7 @@ static int temac_start_xmit(struct sk_buff *skb, st=
ruct net_device *ndev)
=20
 	cur_p->app0 =3D 0;
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-		unsigned int csum_start_off =3D skb_transport_offset(skb);
+		unsigned int csum_start_off =3D skb_checksum_start_offset(skb);
 		unsigned int csum_index_off =3D csum_start_off + skb->csum_offset;
=20
 		cur_p->app0 |=3D 1; /* TX Checksum Enabled */
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 4256727..21845af 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -504,8 +504,7 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_=
buff *skb,
=20
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 		vnet_hdr->flags =3D VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		vnet_hdr->csum_start =3D skb->csum_start -
-					skb_headroom(skb);
+		vnet_hdr->csum_start =3D skb_checksum_start_offset(skb);
 		vnet_hdr->csum_offset =3D skb->csum_offset;
 	} /* else everything is zero */
=20
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index 8524cc4..c504e29 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2736,7 +2736,7 @@ again:
 	odd_flag =3D 0;
 	flags =3D (MXGEFW_FLAGS_NO_TSO | MXGEFW_FLAGS_FIRST);
 	if (likely(skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
-		cksum_offset =3D skb_transport_offset(skb);
+		cksum_offset =3D skb_checksum_start_offset(skb);
 		pseudo_hdr_offset =3D cksum_offset + skb->csum_offset;
 		/* If the headers are excessively large, then we must
 		 * fall back to a software checksum */
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 781e368..f54d358 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6589,7 +6589,7 @@ static u64 niu_compute_tx_flags(struct sk_buff *s=
kb, struct ethhdr *ehdr,
 			     (ip_proto =3D=3D IPPROTO_UDP ?
 			      TXHDR_CSUM_UDP : TXHDR_CSUM_SCTP));
=20
-		start =3D skb_transport_offset(skb) -
+		start =3D skb_checksum_start_offset(skb) -
 			(pad_bytes + sizeof(struct tx_pkt_hdr));
 		stuff =3D start + skb->csum_offset;
=20
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 220e039..1959438 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2764,7 +2764,7 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff=
 *skb,
 	td->dma_hi =3D map >> 32;
=20
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-		const int offset =3D skb_transport_offset(skb);
+		const int offset =3D skb_checksum_start_offset(skb);
=20
 		/* This seems backwards, but it is what the sk98lin
 		 * does.  Looks like hardware is wrong?
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4ceb3cf..4842fca 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1004,7 +1004,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff =
*skb,
=20
 	ctrl =3D 0;
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-		const u64 csum_start_off =3D skb_transport_offset(skb);
+		const u64 csum_start_off =3D skb_checksum_start_offset(skb);
 		const u64 csum_stuff_off =3D csum_start_off + skb->csum_offset;
=20
 		ctrl =3D (TXDCTRL_CENAB |
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 5e28c41..55bbb9c 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2266,7 +2266,7 @@ static netdev_tx_t happy_meal_start_xmit(struct s=
k_buff *skb,
=20
 	tx_flags =3D TXFLAG_OWN;
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-		const u32 csum_start_off =3D skb_transport_offset(skb);
+		const u32 csum_start_off =3D skb_checksum_start_offset(skb);
 		const u32 csum_stuff_off =3D csum_start_off + skb->csum_offset;
=20
 		tx_flags =3D (TXFLAG_OWN | TXFLAG_CSENABLE |
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 55f3a3e..7599c45 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -757,7 +757,7 @@ static __inline__ ssize_t tun_put_user(struct tun_s=
truct *tun,
=20
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 			gso.flags =3D VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			gso.csum_start =3D skb->csum_start - skb_headroom(skb);
+			gso.csum_start =3D skb_checksum_start_offset(skb);
 			gso.csum_offset =3D skb->csum_offset;
 		} /* else everything is zero */
=20
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 65cb1ab..bc86f4b 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1163,9 +1163,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, =
struct sk_buff *skb)
=20
 static u32 smsc95xx_calc_csum_preamble(struct sk_buff *skb)
 {
-	int len =3D skb->data - skb->head;
-	u16 high_16 =3D (u16)(skb->csum_offset + skb->csum_start - len);
-	u16 low_16 =3D (u16)(skb->csum_start - len);
+	u16 low_16 =3D (u16)skb_checksum_start_offset(skb);
+	u16 high_16 =3D low_16 + skb->csum_offset;
 	return (high_16 << 16) | low_16;
 }
=20
@@ -1193,7 +1192,7 @@ static struct sk_buff *smsc95xx_tx_fixup(struct u=
sbnet *dev,
 		if (skb->len <=3D 45) {
 			/* workaround - hardware tx checksum does not work
 			 * properly with extremely small packets */
-			long csstart =3D skb->csum_start - skb_headroom(skb);
+			long csstart =3D skb_checksum_start_offset(skb);
 			__wsum calc =3D csum_partial(skb->data + csstart,
 				skb->len - csstart, 0);
 			*((__sum16 *)(skb->data + csstart
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b6d4028..90a23e4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -519,7 +519,7 @@ static int xmit_skb(struct virtnet_info *vi, struct=
 sk_buff *skb)
=20
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 		hdr->hdr.flags =3D VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		hdr->hdr.csum_start =3D skb->csum_start - skb_headroom(skb);
+		hdr->hdr.csum_start =3D skb_checksum_start_offset(skb);
 		hdr->hdr.csum_offset =3D skb->csum_offset;
 	} else {
 		hdr->hdr.flags =3D 0;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vm=
xnet3_drv.c
index 65860a9..3b61e21 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -798,7 +798,7 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, str=
uct vmxnet3_tx_queue *tq,
 {
 	struct Vmxnet3_TxDataDesc *tdd;
=20
-	if (ctx->mss) {
+	if (ctx->mss) {	/* GSO */
 		ctx->eth_ip_hdr_size =3D skb_transport_offset(skb);
 		ctx->l4_hdr_size =3D ((struct tcphdr *)
 				   skb_transport_header(skb))->doff * 4;
@@ -807,7 +807,7 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, str=
uct vmxnet3_tx_queue *tq,
 		unsigned int pull_size;
=20
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-			ctx->eth_ip_hdr_size =3D skb_transport_offset(skb);
+			ctx->eth_ip_hdr_size =3D skb_checksum_start_offset(skb);
=20
 			if (ctx->ipv4) {
 				struct iphdr *iph =3D (struct iphdr *)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19f37a6..0491da5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1355,6 +1355,11 @@ static inline void skb_set_mac_header(struct sk_=
buff *skb, const int offset)
 }
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
=20
+static inline int skb_checksum_start_offset(const struct sk_buff *skb)
+{
+	return skb->csum_start - skb_headroom(skb);
+}
+
 static inline int skb_transport_offset(const struct sk_buff *skb)
 {
 	return skb_transport_header(skb) - skb->data;

