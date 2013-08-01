From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports
 sg dma
Date: Wed, 31 Jul 2013 22:04:21 -0700
Message-ID: <1375333461.10515.133.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <1375329066.10515.125.camel@edumazet-glaptop>
	 <CACVXFVNSZJ+ojjBCwYDKsWWvs03aL8BugcX7u483MvBCQCH1sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40971 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab3HAFEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 01:04:23 -0400
In-Reply-To: <CACVXFVNSZJ+ojjBCwYDKsWWvs03aL8BugcX7u483MvBCQCH1sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 12:41 +0800, Ming Lei wrote:

> From my trace result, lots of linear SKBs are cloned or header-cloned, so
> it needs skb copy too.
> 
> Is it normal in xmit path to see cloned SKBs for driver? If not, I can add check
> to avoid allocation of 8 bytes header for non-cloned skb.

Existing code is not very friendly and very complex.

Sure TCP stack does a clone for every skb from socket write queue,
but header should be available for pushing 8 bytes.

The !skb_cloned(skb) test should be removed if the memmove() is not
needed.

Could you try following patch ?

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
-
-		skb2 = skb_copy_expand(skb, 8, 0, flags);
+	if ((skb_header_cloned(skb) || headroom < 0) &&
+	    pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
 		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
+		return NULL;
 	}
 
 	skb_push(skb, 4);
