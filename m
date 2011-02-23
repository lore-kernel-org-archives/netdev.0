From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] f_phonet: avoid pskb_pull(), fix OOPS with CONFIG_HIGHMEM
Date: Wed, 23 Feb 2011 14:51:33 +0200
Message-ID: <1298465493-3787-1-git-send-email-remi.denis-courmont@nokia.com>
References: <linux-usb@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:31042 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754581Ab1BWMuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 07:50:51 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1NCooUK002962
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 14:50:50 +0200
In-Reply-To: <linux-usb@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is similar to what we already do in cdc-phonet.c in the same
situation. pskb_pull() refuses to work with HIGHMEM, even if it is
known that the socket buffer is entirely in "low" memory.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index 3c6e1a0..5e14950 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -346,14 +346,19 @@ static void pn_rx_complete(struct usb_ep *ep, str=
uct usb_request *req)
=20
 		if (unlikely(!skb))
 			break;
-		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page, 0,
-				req->actual);
-		page =3D NULL;
=20
-		if (req->actual < req->length) { /* Last fragment */
+		if (skb->len =3D=3D 0) { /* First fragment */
 			skb->protocol =3D htons(ETH_P_PHONET);
 			skb_reset_mac_header(skb);
-			pskb_pull(skb, 1);
+			/* Can't use pskb_pull() on page in IRQ */
+			memcpy(skb_put(skb, 1), page_address(page), 1);
+		}
+
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+				skb->len =3D=3D 0, req->actual);
+		page =3D NULL;
+
+		if (req->actual < req->length) { /* Last fragment */
 			skb->dev =3D dev;
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes +=3D skb->len;
--=20
1.7.1

