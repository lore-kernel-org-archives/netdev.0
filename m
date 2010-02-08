From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 25/41] CAPI: Use tty_port to keep track of capiminor's tty
Date: Mon,  8 Feb 2010 21:12:29 +0100
Message-ID: <6062c259462cbca4c2e3cbc3f7a9d26085a3fc59.1265659935.git.jan.kiszka@web.de>
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

Use the reference management features of tty_port to look up and drop
again the tty_struct associated with a capiminor.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   94 ++++++++++++++++++++++++++++++----------------
 1 files changed, 62 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 3e4997a..e164a8f 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -94,7 +94,7 @@ struct capiminor {
 	u16		 datahandle;
 	u16		 msgid;
 
-	struct tty_struct *tty;
+	struct tty_port port;
 	int                ttyinstop;
 	int                ttyoutstop;
 	struct sk_buff    *ttyskb;
@@ -212,6 +212,8 @@ static void capiminor_del_all_ack(struct capiminor *mp)
 
 /* -------- struct capiminor ---------------------------------------- */
 
+static const struct tty_port_operations capiminor_port_ops; /* we have none */
+
 static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 {
 	struct capiminor *mp;
@@ -237,6 +239,9 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	skb_queue_head_init(&mp->inqueue);
 	skb_queue_head_init(&mp->outqueue);
 
+	tty_port_init(&mp->port);
+	mp->port.ops = &capiminor_port_ops;
+
 	/* Allocate the least unused minor number. */
 	write_lock_irqsave(&capiminors_lock, flags);
 	for (minor = 0; minor < capi_ttyminors; minor++)
@@ -335,18 +340,22 @@ static void capincci_alloc_minor(struct capidev *cdev, struct capincci *np)
 static void capincci_free_minor(struct capincci *np)
 {
 	struct capiminor *mp = np->minorp;
+	struct tty_struct *tty;
 
 	if (mp) {
 		capifs_free_ncci(mp->capifs_dentry);
-		if (mp->tty) {
+
+		tty = tty_port_tty_get(&mp->port);
+		if (tty) {
 			mp->nccip = NULL;
 #ifdef _DEBUG_REFCOUNT
 			printk(KERN_DEBUG "reset mp->nccip\n");
 #endif
-			tty_hangup(mp->tty);
-		} else {
-			capiminor_free(mp);
+			tty_hangup(tty);
+			tty_kref_put(tty);
 		}
+
+		capiminor_free(mp);
 	}
 }
 
@@ -433,44 +442,48 @@ gen_data_b3_resp_for(struct capiminor *mp, struct sk_buff *skb)
 
 static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 {
+	struct tty_struct *tty;
 	struct sk_buff *nskb;
 	int datalen;
 	u16 errcode, datahandle;
 	struct tty_ldisc *ld;
-	
+	int ret = -1;
+
 	datalen = skb->len - CAPIMSG_LEN(skb->data);
-	if (mp->tty == NULL)
-	{
+
+	tty = tty_port_tty_get(&mp->port);
+	if (!tty) {
 #ifdef _DEBUG_DATAFLOW
 		printk(KERN_DEBUG "capi: currently no receiver\n");
 #endif
 		return -1;
 	}
 	
-	ld = tty_ldisc_ref(mp->tty);
-	if (ld == NULL)
-		return -1;
+	ld = tty_ldisc_ref(tty);
+	if (!ld)
+		goto out1;
+
 	if (ld->ops->receive_buf == NULL) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: ldisc has no receive_buf function\n");
 #endif
-		goto bad;
+		goto out2;
 	}
 	if (mp->ttyinstop) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: recv tty throttled\n");
 #endif
-		goto bad;
+		goto out2;
 	}
-	if (mp->tty->receive_room < datalen) {
+	if (tty->receive_room < datalen) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: no room in tty\n");
 #endif
-		goto bad;
+		goto out2;
 	}
 	if ((nskb = gen_data_b3_resp_for(mp, skb)) == NULL) {
 		printk(KERN_ERR "capi: gen_data_b3_resp failed\n");
-		goto bad;
+		goto out2;
 	}
 	datahandle = CAPIMSG_U16(skb->data,CAPIMSG_BASELEN+4);
 	errcode = capi20_put_message(mp->ap, nskb);
@@ -478,20 +491,21 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 		printk(KERN_ERR "capi: send DATA_B3_RESP failed=%x\n",
 				errcode);
 		kfree_skb(nskb);
-		goto bad;
+		goto out2;
 	}
 	(void)skb_pull(skb, CAPIMSG_LEN(skb->data));
 #ifdef _DEBUG_DATAFLOW
 	printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldisc\n",
 				datahandle, skb->len);
 #endif
-	ld->ops->receive_buf(mp->tty, skb->data, NULL, skb->len);
+	ld->ops->receive_buf(tty, skb->data, NULL, skb->len);
 	kfree_skb(skb);
+	ret = 0;
+out2:
 	tty_ldisc_deref(ld);
-	return 0;
-bad:
-	tty_ldisc_deref(ld);
-	return -1;
+out1:
+	tty_kref_put(tty);
+	return ret;
 }
 
 static void handle_minor_recv(struct capiminor *mp)
@@ -510,16 +524,22 @@ static void handle_minor_recv(struct capiminor *mp)
 
 static int handle_minor_send(struct capiminor *mp)
 {
+	struct tty_struct *tty;
 	struct sk_buff *skb;
 	u16 len;
 	int count = 0;
 	u16 errcode;
 	u16 datahandle;
 
-	if (mp->tty && mp->ttyoutstop) {
+	tty = tty_port_tty_get(&mp->port);
+	if (!tty)
+		return 0;
+
+	if (mp->ttyoutstop) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: send: tty stopped\n");
 #endif
+		tty_kref_put(tty);
 		return 0;
 	}
 
@@ -542,6 +562,7 @@ static int handle_minor_send(struct capiminor *mp)
 		if (capiminor_add_ack(mp, datahandle) < 0) {
 			skb_pull(skb, CAPI_DATA_B3_REQ_LEN);
 			skb_queue_head(&mp->outqueue, skb);
+			tty_kref_put(tty);
 			return count;
 		}
 		errcode = capi20_put_message(mp->ap, skb);
@@ -568,6 +589,7 @@ static int handle_minor_send(struct capiminor *mp)
 		mp->outbytes -= len;
 		kfree_skb(skb);
 	}
+	tty_kref_put(tty);
 	return count;
 }
 
@@ -578,6 +600,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 {
 	struct capidev *cdev = ap->private;
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
+	struct tty_struct *tty;
 	struct capiminor *mp;
 	u16 datahandle;
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
@@ -641,8 +664,11 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 #endif
 		kfree_skb(skb);
 		(void)capiminor_del_ack(mp, datahandle);
-		if (mp->tty)
-			tty_wakeup(mp->tty);
+		tty = tty_port_tty_get(&mp->port);
+		if (tty) {
+			tty_wakeup(tty);
+			tty_kref_put(tty);
+		}
 		(void)handle_minor_send(mp);
 
 	} else {
@@ -1029,14 +1055,17 @@ static void capinc_tty_cleanup(struct tty_struct *tty)
 	capiminor_put(mp);
 }
 
-static int capinc_tty_open(struct tty_struct * tty, struct file * file)
+static int capinc_tty_open(struct tty_struct *tty, struct file *filp)
 {
 	struct capiminor *mp = tty->driver_data;
 	unsigned long flags;
+	int err;
+
+	err = tty_port_open(&mp->port, tty, filp);
+	if (err)
+		return err;
 
 	spin_lock_irqsave(&workaround_lock, flags);
-	if (atomic_read(&mp->ttyopencount) == 0)
-		mp->tty = tty;
 	atomic_inc(&mp->ttyopencount);
 #ifdef _DEBUG_REFCOUNT
 	printk(KERN_DEBUG "capinc_tty_open ocount=%d\n", atomic_read(&mp->ttyopencount));
@@ -1046,7 +1075,7 @@ static int capinc_tty_open(struct tty_struct * tty, struct file * file)
 	return 0;
 }
 
-static void capinc_tty_close(struct tty_struct * tty, struct file * file)
+static void capinc_tty_close(struct tty_struct *tty, struct file *filp)
 {
 	struct capiminor *mp = tty->driver_data;
 
@@ -1054,17 +1083,15 @@ static void capinc_tty_close(struct tty_struct * tty, struct file * file)
 #ifdef _DEBUG_REFCOUNT
 			printk(KERN_DEBUG "capinc_tty_close lastclose\n");
 #endif
-			mp->tty = NULL;
 		}
 #ifdef _DEBUG_REFCOUNT
 		printk(KERN_DEBUG "capinc_tty_close ocount=%d\n", atomic_read(&mp->ttyopencount));
 #endif
-		if (mp->nccip == NULL)
-			capiminor_free(mp);
 
 #ifdef _DEBUG_REFCOUNT
 	printk(KERN_DEBUG "capinc_tty_close\n");
 #endif
+	tty_port_close(&mp->port, tty, filp);
 }
 
 static int capinc_tty_write(struct tty_struct * tty,
@@ -1292,9 +1319,12 @@ static void capinc_tty_start(struct tty_struct *tty)
 
 static void capinc_tty_hangup(struct tty_struct *tty)
 {
+	struct capiminor *mp = tty->driver_data;
+
 #ifdef _DEBUG_TTYFUNCS
 	printk(KERN_DEBUG "capinc_tty_hangup\n");
 #endif
+	tty_port_hangup(&mp->port);
 }
 
 static int capinc_tty_break_ctl(struct tty_struct *tty, int state)
-- 
1.6.0.2
