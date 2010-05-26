From: Dan Carpenter <error27@gmail.com>
Subject: [patch] caif: unlock on error path in cfserl_receive()
Date: Wed, 26 May 2010 17:16:48 +0200
Message-ID: <20100526151648.GA15439@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53327 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab0EZPRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 11:17:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was an spin_unlock missing on the error path.  The spin_lock was
tucked in with the declarations so it was hard to spot.  I added a new
line.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index cb4325a..965c5ba 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -59,16 +59,18 @@ static int cfserl_receive(struct cflayer *l, struct cfpkt *newpkt)
 	u8 stx = CFSERL_STX;
 	int ret;
 	u16 expectlen = 0;
+
 	caif_assert(newpkt != NULL);
 	spin_lock(&layr->sync);
 
 	if (layr->incomplete_frm != NULL) {
-
 		layr->incomplete_frm =
 		    cfpkt_append(layr->incomplete_frm, newpkt, expectlen);
 		pkt = layr->incomplete_frm;
-		if (pkt == NULL)
+		if (pkt == NULL) {
+			spin_unlock(&layr->sync);
 			return -ENOMEM;
+		}
 	} else {
 		pkt = newpkt;
 	}
