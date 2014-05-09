From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] net: cdc_mbim: handle unaccelerated VLAN tagged frames
Date: Fri,  9 May 2014 14:45:00 +0200
Message-ID: <1399639500-13907-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48040 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbaEIMpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 08:45:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver maps 802.1q VLANs to MBIM sessions. The mapping is based on
a bogus assumption that all tagged frames will use the acceleration API
because we enable NETIF_F_HW_VLAN_CTAG_TX. This fails for e.g. frames
tagged in userspace using packet sockets. Such frames will erroneously
be considered as untagged and silently dropped based on not being IP.

=46ix by falling back to looking into the ethernet header for a tag if =
no
accelerated tag was found.

=46ixes: a82c7ce5bc5b ("net: cdc_ncm: map MBIM IPS SessionID to VLAN ID=
")
Cc: Greg Suarez <gsuarez@smithmicro.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
This bug has been present since the driver was introduced in v3.8, and
should therefore be applied to all maintained stable kernels from v3.8
and onwards.  I have verified that it applies cleanly to the original
v3.8 version as well as the current net/master, so I believe it should
apply unmodified all versions in between.


Thanks,
Bj=C3=B8rn


 drivers/net/usb/cdc_mbim.c | 39 ++++++++++++++++++++++++++++----------=
-
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 13f7705fd679..2e025ddcef21 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -120,6 +120,16 @@ static void cdc_mbim_unbind(struct usbnet *dev, st=
ruct usb_interface *intf)
 	cdc_ncm_unbind(dev, intf);
 }
=20
+/* verify that the ethernet protocol is IPv4 or IPv6 */
+static bool is_ip_proto(__be16 proto)
+{
+	switch (proto) {
+	case htons(ETH_P_IP):
+	case htons(ETH_P_IPV6):
+		return true;
+	}
+	return false;
+}
=20
 static struct sk_buff *cdc_mbim_tx_fixup(struct usbnet *dev, struct sk=
_buff *skb, gfp_t flags)
 {
@@ -128,6 +138,7 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usb=
net *dev, struct sk_buff *skb
 	struct cdc_ncm_ctx *ctx =3D info->ctx;
 	__le32 sign =3D cpu_to_le32(USB_CDC_MBIM_NDP16_IPS_SIGN);
 	u16 tci =3D 0;
+	bool is_ip;
 	u8 *c;
=20
 	if (!ctx)
@@ -137,25 +148,32 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct u=
sbnet *dev, struct sk_buff *skb
 		if (skb->len <=3D ETH_HLEN)
 			goto error;
=20
+		/* Some applications using e.g. packet sockets will
+		 * bypass the VLAN acceleration and create tagged
+		 * ethernet frames directly.  We primarily look for
+		 * the accelerated out-of-band tag, but fall back if
+		 * required
+		 */
+		skb_reset_mac_header(skb);
+		if (vlan_get_tag(skb, &tci) < 0 && skb->len > VLAN_ETH_HLEN &&
+		    __vlan_get_tag(skb, &tci) =3D=3D 0) {
+			is_ip =3D is_ip_proto(vlan_eth_hdr(skb)->h_vlan_encapsulated_proto)=
;
+			skb_pull(skb, VLAN_ETH_HLEN);
+		} else {
+			is_ip =3D is_ip_proto(eth_hdr(skb)->h_proto);
+			skb_pull(skb, ETH_HLEN);
+		}
+
 		/* mapping VLANs to MBIM sessions:
 		 *   no tag     =3D> IPS session <0>
 		 *   1 - 255    =3D> IPS session <vlanid>
 		 *   256 - 511  =3D> DSS session <vlanid - 256>
 		 *   512 - 4095 =3D> unsupported, drop
 		 */
-		vlan_get_tag(skb, &tci);
-
 		switch (tci & 0x0f00) {
 		case 0x0000: /* VLAN ID 0 - 255 */
-			/* verify that datagram is IPv4 or IPv6 */
-			skb_reset_mac_header(skb);
-			switch (eth_hdr(skb)->h_proto) {
-			case htons(ETH_P_IP):
-			case htons(ETH_P_IPV6):
-				break;
-			default:
+			if (!is_ip)
 				goto error;
-			}
 			c =3D (u8 *)&sign;
 			c[3] =3D tci;
 			break;
@@ -169,7 +187,6 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usb=
net *dev, struct sk_buff *skb
 				  "unsupported tci=3D0x%04x\n", tci);
 			goto error;
 		}
-		skb_pull(skb, ETH_HLEN);
 	}
=20
 	spin_lock_bh(&ctx->mtx);
--=20
2.0.0.rc2
