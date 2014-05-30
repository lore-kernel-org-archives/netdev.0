From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 1/8] net: cdc_ncm: reduce skb truesize in rx path
Date: Fri, 30 May 2014 09:31:03 +0200
Message-ID: <1401435070-26721-2-git-send-email-bjorn@mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51797 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932093AbaE3HdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 03:33:21 -0400
In-Reply-To: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cloning the big skbs we use for USB buffering chokes up TCP and
SCTP because the socket memory limits are hitting earlier than
they should. It is better to unconditionally copy the unwrapped
packets to freshly allocated skbs.

Reported-by: Jim Baxter <jim_baxter@mentor.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 93c9ca9924eb..2bbbd65591c7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1289,12 +1289,11 @@ next_ndp:
 			break;
=20
 		} else {
-			skb =3D skb_clone(skb_in, GFP_ATOMIC);
+			/* create a fresh copy to reduce truesize */
+			skb =3D netdev_alloc_skb_ip_align(dev->net,  len);
 			if (!skb)
 				goto error;
-			skb->len =3D len;
-			skb->data =3D ((u8 *)skb_in->data) + offset;
-			skb_set_tail_pointer(skb, len);
+			memcpy(skb_put(skb, len), skb_in->data + offset, len);
 			usbnet_skb_return(dev, skb);
 			payload +=3D len;	/* count payload bytes in this NTB */
 		}
--=20
2.0.0.rc4
