From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 1/8] net: cdc_ncm: reduce skb truesize in rx path
Date: Mon, 26 May 2014 12:53:38 +0200
Message-ID: <1401101625-12342-2-git-send-email-bjorn@mork.no>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401101625-12342-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cloning the big skbs we use for USB buffering chokes up TCP and
SCTP because the socket memory limits are hitting earlier than
they should. It is better to unconditionally copy the unwrapped
packets to freshly allocated skbs.

Reported-by: Jim Baxter <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
