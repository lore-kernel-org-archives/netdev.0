From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Subject: [PATCH] USB CDC NCM: Don't deref NULL in cdc_ncm_rx_fixup() and
 don't use uninitialized variable.
Date: Thu, 13 Jan 2011 22:40:11 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101132229260.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-2038640018-1294954811=:11347"
Cc: Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Hans Petter Selasky <hans.petter.selasky-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-2038640018-1294954811=:11347
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: 8BIT

skb_clone() dynamically allocates memory and may fail. If it does it 
returns NULL. This means we'll dereference a NULL pointer in 
drivers/net/usb/cdc_ncm.c::cdc_ncm_rx_fixup().
As far as I can tell, the proper way to deal with this is simply to goto 
the error label.

Furthermore gcc complains that 'skb' may be used uninitialized:
  drivers/net/usb/cdc_ncm.c: In function ¡cdc_ncm_rx_fixup¢:
  drivers/net/usb/cdc_ncm.c:922:18: warning: ¡skb¢ may be used uninitialized in this function
and I believe it is right. On the line where we
  pr_debug("invalid frame detected (ignored)" ...
we are using the local variable 'skb' but nothing has ever been assigned 
to that variable yet. I believe the correct fix for that is to use 
'skb_in' instead.

Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
---
 cdc_ncm.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

  compile tested only.

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 593c104..d776c4a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1021,13 +1021,15 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 		    (temp > CDC_NCM_MAX_DATAGRAM_SIZE) || (temp < ETH_HLEN)) {
 			pr_debug("invalid frame detected (ignored)"
 				"offset[%u]=%u, length=%u, skb=%p\n",
-							x, offset, temp, skb);
+							x, offset, temp, skb_in);
 			if (!x)
 				goto error;
 			break;
 
 		} else {
 			skb = skb_clone(skb_in, GFP_ATOMIC);
+			if (!skb)
+				goto error;
 			skb->len = temp;
 			skb->data = ((u8 *)skb_in->data) + offset;
 			skb_set_tail_pointer(skb, temp);



-- 
Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-2038640018-1294954811=:11347--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
