From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] mISDN: use memchr_inv
Date: Fri, 27 Jan 2012 23:24:55 +0900
Message-ID: <1327674295-3700-8-git-send-email-akinobu.mita@gmail.com>
References: <1327674295-3700-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327674295-3700-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use memchr_inv to check if the data contains all same bytes.  It is
faster than looping for each byte.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/mISDN/l1oip_core.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 22f8ec8..04f115a 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -1112,7 +1112,7 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 	struct l1oip			*hc = bch->hw;
 	int			ret = -EINVAL;
 	struct mISDNhead	*hh = mISDN_HEAD_P(skb);
-	int			l, ll, i;
+	int			l, ll;
 	unsigned char		*p;
 
 	switch (hh->prim) {
@@ -1128,13 +1128,8 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 			break;
 		}
 		/* check for AIS / ulaw-silence */
-		p = skb->data;
 		l = skb->len;
-		for (i = 0; i < l; i++) {
-			if (*p++ != 0xff)
-				break;
-		}
-		if (i == l) {
+		if (!memchr_inv(skb->data, 0xff, l)) {
 			if (debug & DEBUG_L1OIP_MSG)
 				printk(KERN_DEBUG "%s: got AIS, not sending, "
 					"but counting\n", __func__);
@@ -1144,13 +1139,8 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 			return 0;
 		}
 		/* check for silence */
-		p = skb->data;
 		l = skb->len;
-		for (i = 0; i < l; i++) {
-			if (*p++ != 0x2a)
-				break;
-		}
-		if (i == l) {
+		if (!memchr_inv(skb->data, 0x2a, l)) {
 			if (debug & DEBUG_L1OIP_MSG)
 				printk(KERN_DEBUG "%s: got silence, not sending"
 					", but counting\n", __func__);
-- 
1.7.4.4
