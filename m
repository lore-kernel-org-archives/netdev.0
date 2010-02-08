From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 34/41] CAPI: Use atomics for capiminor's datahandle and msgid
Date: Mon,  8 Feb 2010 21:12:38 +0100
Message-ID: <2eb4b76c5496b13e970a4e034d14dcd617502f1c.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The capiminor members datahandle and msgid are incremented outside any
lock, so better do this atomically.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 9d4750a..08d5a8a 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -87,10 +87,10 @@ struct capiminor {
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
 
 	struct tty_port port;
 	int                ttyinstop;
@@ -227,7 +227,6 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 
 	mp->ap = ap;
 	mp->ncci = ncci;
-	mp->msgid = 0;
 	INIT_LIST_HEAD(&mp->ackqueue);
 	spin_lock_init(&mp->ackqlock);
 
@@ -427,7 +426,7 @@ gen_data_b3_resp_for(struct capiminor *mp, struct sk_buff *skb)
 		capimsg_setu16(s, 2, mp->ap->applid);
 		capimsg_setu8 (s, 4, CAPI_DATA_B3);
 		capimsg_setu8 (s, 5, CAPI_RESP);
-		capimsg_setu16(s, 6, mp->msgid++);
+		capimsg_setu16(s, 6, atomic_inc_return(&mp->msgid));
 		capimsg_setu32(s, 8, mp->ncci);
 		capimsg_setu16(s, 12, datahandle);
 	}
@@ -554,7 +553,7 @@ static int handle_minor_send(struct capiminor *mp)
 	}
 
 	while ((skb = skb_dequeue(&mp->outqueue)) != NULL) {
-		datahandle = mp->datahandle;
+		datahandle = atomic_inc_return(&mp->datahandle);
 		len = (u16)skb->len;
 		skb_push(skb, CAPI_DATA_B3_REQ_LEN);
 		memset(skb->data, 0, CAPI_DATA_B3_REQ_LEN);
@@ -562,7 +561,7 @@ static int handle_minor_send(struct capiminor *mp)
 		capimsg_setu16(skb->data, 2, mp->ap->applid);
 		capimsg_setu8 (skb->data, 4, CAPI_DATA_B3);
 		capimsg_setu8 (skb->data, 5, CAPI_REQ);
-		capimsg_setu16(skb->data, 6, mp->msgid++);
+		capimsg_setu16(skb->data, 6, atomic_inc_return(&mp->msgid));
 		capimsg_setu32(skb->data, 8, mp->ncci);	/* NCCI */
 		capimsg_setu32(skb->data, 12, (u32)(long)skb->data);/* Data32 */
 		capimsg_setu16(skb->data, 16, len);	/* Data length */
@@ -577,7 +576,6 @@ static int handle_minor_send(struct capiminor *mp)
 		}
 		errcode = capi20_put_message(mp->ap, skb);
 		if (errcode == CAPI_NOERROR) {
-			mp->datahandle++;
 			count++;
 			mp->outbytes -= len;
 #ifdef _DEBUG_DATAFLOW
-- 
1.6.0.2
