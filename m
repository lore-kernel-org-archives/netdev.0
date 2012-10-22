From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 13/13] net: cdc_mbim: Device Service Stream support
Date: Mon, 22 Oct 2012 22:56:40 +0200
Message-ID: <1350939400-27209-14-git-send-email-bjorn@mork.no>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48598 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756329Ab2JVU5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 16:57:19 -0400
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MBIM devices can support up to 256 generic streams called
Device Service Streams (DSS). The MBIM spec says

   The format of the Device Service Stream payload depends
   on the device service (as identified by the corresponding
   UUID) that is used when opening the data stream.

Example use cases are serial AT command interfaces and NMEA
data streams. We cannot make any assumptions about these
device services.

Adding support for Device Service Stream by extending
the MBIM session to VLAN mapping scheme, allocating
VLAN IDs 256 to 511 for DSS, using the DSS SessionID
as the lower 8bit of the VLAN ID.

Using a netdev for DSS keeps the device framing intact and
allows userspace to do whatever it want with the streams.
=46or example, exporting an AT command interface using DSS
session #0 to a PTY for use with a terminal application like
minicom:

  vconfig add wwan0 256
  ip link set dev wwan0 up
  ip link set dev wwan0.256 up
  socat INTERFACE:wwan0.256,type=3D2 PTY:,echo=3D0,link=3D/tmp/modem

Device configuration must be done using MBIM control commands
over the /dev/cdc-wdmx device. The userspace management
application should coordinate host VLAN configuration and the
device MBIM configuration using the device capabilities to
find out if it needs to set up PTY mappings etc.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c |   58 ++++++++++++++++++++++++++----------=
--------
 1 file changed, 35 insertions(+), 23 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 45f5f50..42f51c7 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -149,12 +149,27 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct u=
sbnet *dev, struct sk_buff *skb
 		/* mapping VLANs to MBIM sessions:
 		 *   no tag     =3D> IPS session <0>
 		 *   1 - 255    =3D> IPS session <vlanid>
-		 *   256 - 4095 =3D> unsupported, drop
+		 *   256 - 511  =3D> DSS session <vlanid - 256>
+		 *   512 - 4095 =3D> unsupported, drop
 		 */
 		vlan_get_tag(skb, &tci);
=20
 		switch (tci & 0x0f00) {
 		case 0x0000: /* VLAN ID 0 - 255 */
+			/* verify that datagram is IPv4 or IPv6 */
+			skb_reset_mac_header(skb);
+			switch (eth_hdr(skb)->h_proto) {
+			case htons(ETH_P_IP):
+			case htons(ETH_P_IPV6):
+				break;
+			default:
+				goto error;
+			}
+			c =3D (u8 *)&sign;
+			c[3] =3D tci;
+			break;
+		case 0x0100: /* VLAN ID 256 - 511 */
+			sign =3D cpu_to_le32(USB_CDC_MBIM_NDP16_DSS_SIGN);
 			c =3D (u8 *)&sign;
 			c[3] =3D tci;
 			break;
@@ -163,16 +178,7 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct us=
bnet *dev, struct sk_buff *skb
 				  "unsupported tci=3D0x%04x\n", tci);
 			goto error;
 		}
-
-		skb_reset_mac_header(skb);
-		switch (eth_hdr(skb)->h_proto) {
-		case htons(ETH_P_IP):
-		case htons(ETH_P_IPV6):
-			skb_pull(skb, ETH_HLEN);
-			break;
-		default:
-			goto error;
-		}
+		skb_pull(skb, ETH_HLEN);
 	}
=20
 	spin_lock_bh(&ctx->mtx);
@@ -189,21 +195,23 @@ error:
=20
 static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *=
buf, size_t len, u16 tci)
 {
-	__be16 proto;
+	__be16 proto =3D htons(ETH_P_802_3);
 	struct sk_buff *skb =3D NULL;
=20
-	if (len < sizeof(struct iphdr))
-		goto err;
+	if (tci < 256) { /* IPS session? */
+		if (len < sizeof(struct iphdr))
+			goto err;
=20
-	switch (*buf & 0xf0) {
-	case 0x40:
-		proto =3D htons(ETH_P_IP);
-		break;
-	case 0x60:
-		proto =3D htons(ETH_P_IPV6);
-		break;
-	default:
-		goto err;
+		switch (*buf & 0xf0) {
+		case 0x40:
+			proto =3D htons(ETH_P_IP);
+			break;
+		case 0x60:
+			proto =3D htons(ETH_P_IPV6);
+			break;
+		default:
+			goto err;
+		}
 	}
=20
 	skb =3D netdev_alloc_skb_ip_align(dev->net,  len + ETH_HLEN);
@@ -259,6 +267,10 @@ next_ndp:
 		c =3D (u8 *)&ndp16->dwSignature;
 		tci =3D c[3];
 		break;
+	case cpu_to_le32(USB_CDC_MBIM_NDP16_DSS_SIGN):
+		c =3D (u8 *)&ndp16->dwSignature;
+		tci =3D c[3] + 256;
+		break;
 	default:
 		netif_dbg(dev, rx_err, dev->net,
 			  "unsupported NDP signature <0x%08x>\n",
--=20
1.7.10.4
