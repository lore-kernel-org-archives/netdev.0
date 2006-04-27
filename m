From: akpm@osdl.org
Subject: [patch 9/9] via-rhine: zero pad short packets on Rhine I ethernet cards
Date: Thu, 27 Apr 2006 02:30:46 -0700
Message-ID: <200604270932.k3R9WE6c025339@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, craigbrind@gmail.com,
	rl@hellgate.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24527 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965027AbWD0JcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:32:24 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Craig Brind <craigbrind@gmail.com>

Fixes Rhine I cards disclosing fragments of previously transmitted frames
in new transmissions.

Before transmission, any socket buffer (skb) shorter than the ethernet
minimum length of 60 bytes was zero-padded.  On Rhine I cards the data can
later be copied into an aligned transmission buffer without copying this
padding.  This resulted in the transmission of the frame with the extra
bytes beyond the provided content leaking the previous contents of this
buffer on to the network.

Now zero-padding is repeated in the local aligned buffer if one is used.

Following a suggestion from the via-rhine maintainer, no attempt is made
here to avoid the duplicated effort of padding the skb if it is known that
an aligned buffer will definitely be used.  This is to make the change
"obviously correct" and allow it to be applied to a stable kernel if
necessary.  There is no change to the flow of control and the changes are
only to the Rhine I code path.

The patch has run on an in-service Rhine-I host without incident.  Frames
shorter than 60 bytes are now correctly zero-padded when captured on a
separate host.  I see no unusual stats reported by ifconfig, and no unusual
log messages.

Signed-off-by: Craig Brind <craigbrind@gmail.com>
Signed-off-by: Roger Luethi <rl@hellgate.ch>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/via-rhine.c |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN drivers/net/via-rhine.c~via-rhine-zero-pad-short-packets-on-rhine-i-ethernet-cards drivers/net/via-rhine.c
--- devel/drivers/net/via-rhine.c~via-rhine-zero-pad-short-packets-on-rhine-i-ethernet-cards	2006-04-24 18:22:43.000000000 -0700
+++ devel-akpm/drivers/net/via-rhine.c	2006-04-24 18:22:43.000000000 -0700
@@ -129,6 +129,7 @@
 	- Massive clean-up
 	- Rewrite PHY, media handling (remove options, full_duplex, backoff)
 	- Fix Tx engine race for good
+	- Craig Brind: Zero padded aligned buffers for short packets.
 
 */
 
@@ -1326,7 +1327,12 @@ static int rhine_start_tx(struct sk_buff
 			rp->stats.tx_dropped++;
 			return 0;
 		}
+
+		/* Padding is not copied and so must be redone. */
 		skb_copy_and_csum_dev(skb, rp->tx_buf[entry]);
+		if (skb->len < ETH_ZLEN)
+			memset(rp->tx_buf[entry] + skb->len, 0,
+			       ETH_ZLEN - skb->len);
 		rp->tx_skbuff_dma[entry] = 0;
 		rp->tx_ring[entry].addr = cpu_to_le32(rp->tx_bufs_dma +
 						      (rp->tx_buf[entry] -
_
