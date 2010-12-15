From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 2/3] net: Use skb_checksum_start_offset()
Date: Wed, 15 Dec 2010 02:24:08 +0100 (CET)
Message-ID: <86812f8565215eef6faef96b647bcef0b3b01758.1292372504.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59363 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756583Ab0LOBYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 20:24:11 -0500
In-Reply-To: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace skb->csum_start - skb_headroom(skb) with skb_checksum_start_off=
set().

Note for usb/smsc95xx: skb->data - skb->head =3D=3D skb_headroom(skb).

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

---
 drivers/net/atlx/atl1.c    |    2 +-
 drivers/net/macvtap.c      |    3 +--
 drivers/net/tun.c          |    2 +-
 drivers/net/usb/smsc95xx.c |    7 +++----
 drivers/net/virtio_net.c   |    2 +-
 net/core/dev.c             |    6 +++---
 net/core/skbuff.c          |    2 +-
 net/ipv4/udp.c             |    2 +-
 net/packet/af_packet.c     |    3 +--
 9 files changed, 13 insertions(+), 16 deletions(-)

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
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..f937726 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1761,7 +1761,7 @@ int skb_checksum_help(struct sk_buff *skb)
 		goto out_set_summed;
 	}
=20
-	offset =3D skb->csum_start - skb_headroom(skb);
+	offset =3D skb_checksum_start_offset(skb);
 	BUG_ON(offset >=3D skb_headlen(skb));
 	csum =3D skb_checksum(skb, offset, skb->len - offset, 0);
=20
@@ -2058,8 +2058,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 			 * checksumming here.
 			 */
 			if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
-				skb_set_transport_header(skb, skb->csum_start -
-					      skb_headroom(skb));
+				skb_set_transport_header(skb,
+					skb_checksum_start_offset(skb));
 				if (!dev_can_checksum(dev, skb) &&
 				     skb_checksum_help(skb))
 					goto out_kfree_skb;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8814a9a..19d6c21 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1824,7 +1824,7 @@ void skb_copy_and_csum_dev(const struct sk_buff *=
skb, u8 *to)
 	long csstart;
=20
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
-		csstart =3D skb->csum_start - skb_headroom(skb);
+		csstart =3D skb_checksum_start_offset(skb);
 	else
 		csstart =3D skb_headlen(skb);
=20
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b37181d..1198adf 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2226,7 +2226,7 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff =
*skb, int features)
 	/* Do software UFO. Complete and fill in the UDP checksum as HW canno=
t
 	 * do checksum of UDP packets sent as multiple IP fragments.
 	 */
-	offset =3D skb->csum_start - skb_headroom(skb);
+	offset =3D skb_checksum_start_offset(skb);
 	csum =3D skb_checksum(skb, offset, skb->len - offset, 0);
 	offset +=3D skb->csum_offset;
 	*(__sum16 *)(skb->data + offset) =3D csum_fold(csum);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e79efaf..91cb1d7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1650,8 +1650,7 @@ static int packet_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
=20
 		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 			vnet_hdr.flags =3D VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			vnet_hdr.csum_start =3D skb->csum_start -
-							skb_headroom(skb);
+			vnet_hdr.csum_start =3D skb_checksum_start_offset(skb);
 			vnet_hdr.csum_offset =3D skb->csum_offset;
 		} /* else everything is zero */
=20
--=20
1.7.2.3

