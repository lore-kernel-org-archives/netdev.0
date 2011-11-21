From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH 4/5] atm: Introduce vcc_process_recv_queue
Date: Mon, 21 Nov 2011 21:25:57 +0100
Message-ID: <1321907158-27857-5-git-send-email-jorge@dti2.net>
References: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56417 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406Ab1KUU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:26:18 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764597.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:26:15 +0100
In-Reply-To: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

    This function moves the implementation found in the clip and br2684
modules to common code, correctly unlinks the skb from the queue before
pushing it and makes pppoatm use it.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/atm/br2684.c  |   20 +++++---------------
 net/atm/clip.c    |   13 +------------
 net/atm/common.c  |   20 ++++++++++++++++++++
 net/atm/common.h  |    1 +
 net/atm/pppoatm.c |    4 ++++
 5 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 81cf33b..53b0aa1 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -489,15 +489,11 @@ free_skb:
  */
 static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 {
-	struct sk_buff_head queue;
-	int err;
 	struct br2684_vcc *brvcc;
-	struct sk_buff *skb, *tmp;
-	struct sk_buff_head *rq;
 	struct br2684_dev *brdev;
 	struct net_device *net_dev;
 	struct atm_backend_br2684 be;
-	unsigned long flags;
+	int err;
 
 	if (copy_from_user(&be, arg, sizeof be))
 		return -EFAULT;
@@ -550,16 +546,6 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	atmvcc->push = br2684_push;
 	atmvcc->pop = br2684_pop;
 
-	__skb_queue_head_init(&queue);
-	rq = &sk_atm(atmvcc)->sk_receive_queue;
-
-	spin_lock_irqsave(&rq->lock, flags);
-	skb_queue_splice_init(rq, &queue);
-	spin_unlock_irqrestore(&rq->lock, flags);
-
-	skb_queue_walk_safe(&queue, skb, tmp)
-		br2684_push(atmvcc, skb);
-
 	/* initialize netdev carrier state */
 	if (atmvcc->dev->signal == ATM_PHY_SIG_LOST)
 		netif_carrier_off(net_dev);
@@ -567,6 +553,10 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 		netif_carrier_on(net_dev);
 
 	__module_get(THIS_MODULE);
+
+	/* re-process everything received between connection setup and
+	   backend setup */
+	vcc_process_recv_queue(atmvcc);
 	return 0;
 
 error:
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 521b45b..3d2ac66 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -455,10 +455,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 
 static int clip_mkip(struct atm_vcc *vcc, int timeout)
 {
-	struct sk_buff_head *rq, queue;
 	struct clip_vcc *clip_vcc;
-	struct sk_buff *skb, *tmp;
-	unsigned long flags;
 
 	if (!vcc->push)
 		return -EBADFD;
@@ -479,16 +476,8 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 	vcc->push = clip_push;
 	vcc->pop = clip_pop;
 
-	__skb_queue_head_init(&queue);
-	rq = &sk_atm(vcc)->sk_receive_queue;
-
-	spin_lock_irqsave(&rq->lock, flags);
-	skb_queue_splice_init(rq, &queue);
-	spin_unlock_irqrestore(&rq->lock, flags);
-
 	/* re-process everything received between connection setup and MKIP */
-	skb_queue_walk_safe(&queue, skb, tmp)
-		clip_push(vcc, skb);
+	vcc_process_recv_queue(vcc);
 
 	return 0;
 }
diff --git a/net/atm/common.c b/net/atm/common.c
index 14ff9fe..0b4c58f 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -214,6 +214,26 @@ void vcc_release_async(struct atm_vcc *vcc, int reply)
 }
 EXPORT_SYMBOL(vcc_release_async);
 
+void vcc_process_recv_queue(struct atm_vcc *vcc)
+{
+	struct sk_buff_head queue, *rq;
+	struct sk_buff *skb, *tmp;
+	unsigned long flags;
+
+	__skb_queue_head_init(&queue);
+	rq = &sk_atm(vcc)->sk_receive_queue;
+
+	spin_lock_irqsave(&rq->lock, flags);
+	skb_queue_splice_init(rq, &queue);
+	spin_unlock_irqrestore(&rq->lock, flags);
+
+	skb_queue_walk_safe(&queue, skb, tmp) {
+		__skb_unlink(skb, &queue);
+		vcc->push(vcc, skb);
+	}
+}
+EXPORT_SYMBOL(vcc_process_recv_queue);
+
 void atm_dev_signal_change(struct atm_dev *dev, char signal)
 {
 	pr_debug("%s signal=%d dev=%p number=%d dev->signal=%d\n",
diff --git a/net/atm/common.h b/net/atm/common.h
index f48a76b..cc3c2da 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -24,6 +24,7 @@ int vcc_setsockopt(struct socket *sock, int level, int optname,
 		   char __user *optval, unsigned int optlen);
 int vcc_getsockopt(struct socket *sock, int level, int optname,
 		   char __user *optval, int __user *optlen);
+void vcc_process_recv_queue(struct atm_vcc *vcc);
 
 int atmpvc_init(void);
 void atmpvc_exit(void);
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index db4a11c..df35d9a 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -303,6 +303,10 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	atmvcc->push = pppoatm_push;
 	atmvcc->pop = pppoatm_pop;
 	__module_get(THIS_MODULE);
+
+	/* re-process everything received between connection setup and
+	   backend setup */
+	vcc_process_recv_queue(atmvcc);
 	return 0;
 }
 
-- 
1.7.7.1
