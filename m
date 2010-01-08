From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 24/31] CAPI: Use atomics for capiminor's datahandle and msgid
Date: Fri, 8 Jan 2010 12:46:35 +0100
Message-ID: <01a234271a58f2f2f8b7b1a7174e0f3d741b0601.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:49672 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182Ab0AVX0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:26:07 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The capiminor members datahandle and msgid are incremented outside any
lock, so better do this atomically.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index b8019a1..6ab496c 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -88,10 +88,10 @@ struct capiminor {
 	unsigned int      minor;
 	struct dentry *capifs_dentry;
 
-	struct capi20_appl *ap;
-	u32		 ncci;
-	u16		 datahandle;
-	u16		 msgid;
+	struct capi20_appl	*ap;
+	u32			ncci;
+	atomic_t		datahandle;
+	atomic_t		msgid;
 
 	struct tty_struct	*tty;
 	struct mutex		ttylock;
@@ -222,7 +222,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 
 	mp->ap = ap;
 	mp->ncci = ncci;
-	mp->msgid = 0;
 	INIT_LIST_HEAD(&mp->ackqueue);
 	spin_lock_init(&mp->ackqlock);
 
@@ -396,7 +395,7 @@ gen_data_b3_resp_for(struct capiminor *mp, struct sk_buff *skb)
 		capimsg_setu16(s, 2, mp->ap->applid);
 		capimsg_setu8 (s, 4, CAPI_DATA_B3);
 		capimsg_setu8 (s, 5, CAPI_RESP);
-		capimsg_setu16(s, 6, mp->msgid++);
+		capimsg_setu16(s, 6, atomic_inc_return(&mp->msgid));
 		capimsg_setu32(s, 8, mp->ncci);
 		capimsg_setu16(s, 12, datahandle);
 	}
@@ -509,7 +508,7 @@ static int handle_minor_send(struct capiminor *mp)
 	}
 
 	while ((skb = skb_dequeue(&mp->outqueue)) != NULL) {
-		datahandle = mp->datahandle;
+		datahandle = atomic_inc_return(&mp->datahandle);
 		len = (u16)skb->len;
 		skb_push(skb, CAPI_DATA_B3_REQ_LEN);
 		memset(skb->data, 0, CAPI_DATA_B3_REQ_LEN);
@@ -517,7 +516,7 @@ static int handle_minor_send(struct capiminor *mp)
 		capimsg_setu16(skb->data, 2, mp->ap->applid);
 		capimsg_setu8 (skb->data, 4, CAPI_DATA_B3);
 		capimsg_setu8 (skb->data, 5, CAPI_REQ);
-		capimsg_setu16(skb->data, 6, mp->msgid++);
+		capimsg_setu16(skb->data, 6, atomic_inc_return(&mp->msgid));
 		capimsg_setu32(skb->data, 8, mp->ncci);	/* NCCI */
 		capimsg_setu32(skb->data, 12, (u32)(long)skb->data);/* Data32 */
 		capimsg_setu16(skb->data, 16, len);	/* Data length */
@@ -531,7 +530,6 @@ static int handle_minor_send(struct capiminor *mp)
 		}
 		errcode = capi20_put_message(mp->ap, skb);
 		if (errcode == CAPI_NOERROR) {
-			mp->datahandle++;
 			count++;
 			mp->outbytes -= len;
 #ifdef _DEBUG_DATAFLOW
-- 
1.6.0.2

