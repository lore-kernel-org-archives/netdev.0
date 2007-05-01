From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [patch 31/33] m68k: kill skb_copy_from_linear_data compiler warnings
Date: Tue, 01 May 2007 22:33:05 +0200
Message-ID: <20070501203338.331311229@mail.of.borg>
References: <20070501203234.252205858@mail.of.borg>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423648AbXEAUgz@vger.kernel.org>
Content-Disposition: inline; filename=m68k-skb_copy_from_linear_data-warnings.diff
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recent conversion from `memcpy' to `skb_copy_from_linear_data' removed a
few casts, which were needed to silence compiler warnings. Re-add them.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/7990.c       |    6 +++---
 drivers/net/a2065.c      |    4 ++--
 drivers/net/sun3_82586.c |    5 +++--
 3 files changed, 8 insertions(+), 7 deletions(-)

--- linux-m68k-2.6.21.orig/drivers/net/7990.c
+++ linux-m68k-2.6.21/drivers/net/7990.c
@@ -565,9 +565,9 @@ int lance_start_xmit (struct sk_buff *sk
         ib->btx_ring [entry].length = (-len) | 0xf000;
         ib->btx_ring [entry].misc = 0;
 
-    	if (skb->len < ETH_ZLEN)
-    		memset((char *)&ib->tx_buf[entry][0], 0, ETH_ZLEN);
-        skb_copy_from_linear_data(skb, &ib->tx_buf[entry][0], skblen);
+	if (skb->len < ETH_ZLEN)
+		memset((void *)&ib->tx_buf[entry][0], 0, ETH_ZLEN);
+        skb_copy_from_linear_data(skb, (void *)&ib->tx_buf[entry][0], skblen);
 
         /* Now, give the packet to the lance */
         ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
--- linux-m68k-2.6.21.orig/drivers/net/a2065.c
+++ linux-m68k-2.6.21/drivers/net/a2065.c
@@ -597,11 +597,11 @@ static int lance_start_xmit (struct sk_b
 	ib->btx_ring [entry].length = (-len) | 0xf000;
 	ib->btx_ring [entry].misc = 0;
 
-	skb_copy_from_linear_data(skb, &ib->tx_buf [entry][0], skblen);
+	skb_copy_from_linear_data(skb, (void *)&ib->tx_buf [entry][0], skblen);
 
 	/* Clear the slack of the packet, do I need this? */
 	if (len != skblen)
-		memset ((char *) &ib->tx_buf [entry][skblen], 0, len - skblen);
+		memset ((void *) &ib->tx_buf [entry][skblen], 0, len - skblen);
 
 	/* Now, give the packet to the lance */
 	ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
--- linux-m68k-2.6.21.orig/drivers/net/sun3_82586.c
+++ linux-m68k-2.6.21/drivers/net/sun3_82586.c
@@ -1023,10 +1023,11 @@ static int sun3_82586_send_packet(struct
 	{
 		len = skb->len;
 		if (len < ETH_ZLEN) {
-			memset((char *)p->xmit_cbuffs[p->xmit_count], 0, ETH_ZLEN);
+			memset((void *)p->xmit_cbuffs[p->xmit_count], 0,
+			       ETH_ZLEN);
 			len = ETH_ZLEN;
 		}
-		skb_copy_from_linear_data(skb, p->xmit_cbuffs[p->xmit_count], skb->len);
+		skb_copy_from_linear_data(skb, (void *)p->xmit_cbuffs[p->xmit_count], skb->len);
 
 #if (NUM_XMIT_BUFFS == 1)
 #	ifdef NO_NOPCOMMANDS

--
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
