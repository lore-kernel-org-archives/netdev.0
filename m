From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 28/31] CAPI: Drop handle_minor_send return value
Date: Fri, 8 Jan 2010 15:11:11 +0100
Message-ID: <506756781e11cfe356b16c3c74f86fe1719b04a7.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:34198 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756339Ab0AVX2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:28:09 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We did not evaluate handle_minor_send's return value, just (void)'ed it
away. Time for a cleanup.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 7a04492..a91b9ae 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -477,11 +477,10 @@ static void handle_minor_recv(struct capiminor *mp)
 		}
 }
 
-static int handle_minor_send(struct capiminor *mp)
+static void handle_minor_send(struct capiminor *mp)
 {
 	struct sk_buff *skb;
 	u16 len;
-	int count = 0;
 	u16 errcode;
 	u16 datahandle;
 
@@ -489,7 +488,7 @@ static int handle_minor_send(struct capiminor *mp)
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: send: tty stoppedn");
 #endif
-		return 0;
+		return;
 	}
 
 	while (1) {
@@ -525,11 +524,10 @@ static int handle_minor_send(struct capiminor *mp)
 			mp->outbytes += len;
 			spin_unlock_bh(&mp->outlock);
 
-			return count;
+			break;
 		}
 		errcode = capi20_put_message(mp->ap, skb);
 		if (errcode == CAPI_NOERROR) {
-			count++;
 #ifdef _DEBUG_DATAFLOW
 			printk(KERN_DEBUG "capi: DATA_B3_REQ %u len=%un",
 							datahandle, len);
@@ -553,7 +551,6 @@ static int handle_minor_send(struct capiminor *mp)
 		printk(KERN_ERR "capi: put_message = %xn", errcode);
 		kfree_skb(skb);
 	}
-	return count;
 }
 
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
@@ -629,7 +626,8 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 		if (mp->tty)
 			tty_wakeup(mp->tty);
 		mutex_unlock(&mp->ttylock);
-		(void)handle_minor_send(mp);
+
+		handle_minor_send(mp);
 
 	} else {
 		/* ups, let capi application handle it :-) */
@@ -1063,7 +1061,7 @@ static int capinc_tty_write(struct tty_struct * tty,
 	mp->outbytes += skb->len;
 	spin_unlock_bh(&mp->outlock);
 
-	(void)handle_minor_send(mp);
+	handle_minor_send(mp);
 
 	return count;
 }
@@ -1106,7 +1104,7 @@ unlock_out:
 	spin_unlock_bh(&mp->outlock);
 
 	if (invoke_send)
-		(void)handle_minor_send(mp);
+		handle_minor_send(mp);
 
 	return ret;
 }
@@ -1128,7 +1126,7 @@ static void capinc_tty_flush_chars(struct tty_struct *tty)
 		mp->outbytes += skb->len;
 		spin_unlock_bh(&mp->outlock);
 
-		(void)handle_minor_send(mp);
+		handle_minor_send(mp);
 	} else
 		spin_unlock_bh(&mp->outlock);
 
@@ -1217,7 +1215,7 @@ static void capinc_tty_start(struct tty_struct *tty)
 	printk(KERN_DEBUG "capinc_tty_startn");
 #endif
 	mp->ttyoutstop = 0;
-	(void)handle_minor_send(mp);
+	handle_minor_send(mp);
 }
 
 static void capinc_tty_hangup(struct tty_struct *tty)
-- 
1.6.0.2

