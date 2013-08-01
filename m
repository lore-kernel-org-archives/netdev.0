From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] ax88179_178a: avoid copy of tx tcp packets
Date: Thu, 01 Aug 2013 06:49:52 -0700
Message-ID: <1375364992.10515.141.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <1375329066.10515.125.camel@edumazet-glaptop>
	 <CACVXFVNSZJ+ojjBCwYDKsWWvs03aL8BugcX7u483MvBCQCH1sg@mail.gmail.com>
	 <1375333461.10515.133.camel@edumazet-glaptop>
	 <CACVXFVMt-TgRVU+iA3NVuUzJSeXUPGvV89OnDdHaLEB1Ua6aAw@mail.gmail.com>
	 <1375363300.10515.135.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375363300.10515.135.camel@edumazet-glaptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

ax88179_tx_fixup() has quite complex code trying to push 8 bytes
of control data (len/mss), but fails to do it properly for TCP packets,
incurring an extra copy and point of memory allocation failure.

Lets use the simple and approved way.

dev->needed_headroom being 8, all frames should have 8 bytes of
headroom, so the extra copy should be unlikely anyway.

This patch should improve performance for TCP xmits.

Reported-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Tested-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/ax88179_178a.c |   21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 2bc87e3..e2120d6 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1166,31 +1166,18 @@ ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	int frame_size = dev->maxpacket;
 	int mss = skb_shinfo(skb)->gso_size;
 	int headroom;
-	int tailroom;
 
 	tx_hdr1 = skb->len;
 	tx_hdr2 = mss;
 	if (((skb->len + 8) % frame_size) == 0)
 		tx_hdr2 |= 0x80008000;	/* Enable padding */
 
-	headroom = skb_headroom(skb);
-	tailroom = skb_tailroom(skb);
+	headroom = skb_headroom(skb) - 8;
 
-	if (!skb_header_cloned(skb) &&
-	    !skb_cloned(skb) &&
-	    (headroom + tailroom) >= 8) {
-		if (headroom < 8) {
-			skb->data = memmove(skb->head + 8, skb->data, skb->len);
-			skb_set_tail_pointer(skb, skb->len);
-		}
-	} else {
-		struct sk_buff *skb2;
