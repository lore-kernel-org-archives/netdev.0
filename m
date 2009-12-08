From: Joe Perches <joe@perches.com>
Subject: [PATCH 18/20] net/atm/signaling.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:57:14 -0800
Message-ID: <a292c2a815189dffb50ea6975a01d9a776e5dbf6.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1060 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693AbZLHF5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:15 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/signaling.c |  202 +++++++++++++++++++++++++-------------------------
 1 files changed, 101 insertions(+), 101 deletions(-)

diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 28df4ed..ad1d28a 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -18,7 +18,6 @@
 #include "resources.h"
 #include "signaling.h"
 
-
 #undef WAIT_FOR_DEMON		/* #define this if system calls on SVC sockets
 				   should block until the demon runs.
 				   Danger: may cause nasty hangs if the demon
@@ -29,20 +28,19 @@ struct atm_vcc *sigd = NULL;
 static DECLARE_WAIT_QUEUE_HEAD(sigd_sleep);
 #endif
 
-
 static void sigd_put_skb(struct sk_buff *skb)
 {
 #ifdef WAIT_FOR_DEMON
-	DECLARE_WAITQUEUE(wait,current);
+	DECLARE_WAITQUEUE(wait, current);
 
-	add_wait_queue(&sigd_sleep,&wait);
+	add_wait_queue(&sigd_sleep, &wait);
 	while (!sigd) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		pr_debug("atmsvc: waiting for signaling daemon...\n");
 		schedule();
 	}
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&sigd_sleep,&wait);
+	remove_wait_queue(&sigd_sleep, &wait);
 #else
 	if (!sigd) {
 		pr_debug("atmsvc: no signaling daemon\n");
@@ -50,39 +48,39 @@ static void sigd_put_skb(struct sk_buff *skb)
 		return;
 	}
 #endif
-	atm_force_charge(sigd,skb->truesize);
-	skb_queue_tail(&sk_atm(sigd)->sk_receive_queue,skb);
+	atm_force_charge(sigd, skb->truesize);
+	skb_queue_tail(&sk_atm(sigd)->sk_receive_queue, skb);
 	sk_atm(sigd)->sk_data_ready(sk_atm(sigd), skb->len);
 }
 
-
-static void modify_qos(struct atm_vcc *vcc,struct atmsvc_msg *msg)
+static void modify_qos(struct atm_vcc *vcc, struct atmsvc_msg *msg)
 {
 	struct sk_buff *skb;
 
-	if (test_bit(ATM_VF_RELEASED,&vcc->flags) ||
-	    !test_bit(ATM_VF_READY,&vcc->flags))
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+	    !test_bit(ATM_VF_READY, &vcc->flags))
 		return;
 	msg->type = as_error;
-	if (!vcc->dev->ops->change_qos) msg->reply = -EOPNOTSUPP;
+	if (!vcc->dev->ops->change_qos)
+		msg->reply = -EOPNOTSUPP;
 	else {
 		/* should lock VCC */
-		msg->reply = vcc->dev->ops->change_qos(vcc,&msg->qos,
-		    msg->reply);
-		if (!msg->reply) msg->type = as_okay;
+		msg->reply = vcc->dev->ops->change_qos(vcc, &msg->qos,
+						       msg->reply);
+		if (!msg->reply)
+			msg->type = as_okay;
 	}
 	/*
 	 * Should probably just turn around the old skb. But the, the buffer
 	 * space accounting needs to follow the change too. Maybe later.
 	 */
-	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg),GFP_KERNEL)))
+	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
 		schedule();
-	*(struct atmsvc_msg *) skb_put(skb,sizeof(struct atmsvc_msg)) = *msg;
+	*(struct atmsvc_msg *)skb_put(skb, sizeof(struct atmsvc_msg)) = *msg;
 	sigd_put_skb(skb);
 }
 
-
-static int sigd_send(struct atm_vcc *vcc,struct sk_buff *skb)
+static int sigd_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct atmsvc_msg *msg;
 	struct atm_vcc *session_vcc;
@@ -95,63 +93,64 @@ static int sigd_send(struct atm_vcc *vcc,struct sk_buff *skb)
 	sk = sk_atm(vcc);
 
 	switch (msg->type) {
-		case as_okay:
-			sk->sk_err = -msg->reply;
-			clear_bit(ATM_VF_WAITING, &vcc->flags);
-			if (!*vcc->local.sas_addr.prv &&
-			    !*vcc->local.sas_addr.pub) {
-				vcc->local.sas_family = AF_ATMSVC;
-				memcpy(vcc->local.sas_addr.prv,
-				    msg->local.sas_addr.prv,ATM_ESA_LEN);
-				memcpy(vcc->local.sas_addr.pub,
-				    msg->local.sas_addr.pub,ATM_E164_LEN+1);
-			}
-			session_vcc = vcc->session ? vcc->session : vcc;
-			if (session_vcc->vpi || session_vcc->vci) break;
-			session_vcc->itf = msg->pvc.sap_addr.itf;
-			session_vcc->vpi = msg->pvc.sap_addr.vpi;
-			session_vcc->vci = msg->pvc.sap_addr.vci;
-			if (session_vcc->vpi || session_vcc->vci)
-				session_vcc->qos = msg->qos;
-			break;
-		case as_error:
-			clear_bit(ATM_VF_REGIS,&vcc->flags);
-			clear_bit(ATM_VF_READY,&vcc->flags);
-			sk->sk_err = -msg->reply;
-			clear_bit(ATM_VF_WAITING, &vcc->flags);
+	case as_okay:
+		sk->sk_err = -msg->reply;
+		clear_bit(ATM_VF_WAITING, &vcc->flags);
+		if (!*vcc->local.sas_addr.prv && !*vcc->local.sas_addr.pub) {
+			vcc->local.sas_family = AF_ATMSVC;
+			memcpy(vcc->local.sas_addr.prv,
+			       msg->local.sas_addr.prv, ATM_ESA_LEN);
+			memcpy(vcc->local.sas_addr.pub,
+			       msg->local.sas_addr.pub, ATM_E164_LEN + 1);
+		}
+		session_vcc = vcc->session ? vcc->session : vcc;
+		if (session_vcc->vpi || session_vcc->vci)
 			break;
-		case as_indicate:
-			vcc = *(struct atm_vcc **) &msg->listen_vcc;
-			sk = sk_atm(vcc);
-			pr_debug("as_indicate!!!\n");
-			lock_sock(sk);
-			if (sk_acceptq_is_full(sk)) {
-				sigd_enq(NULL,as_reject,vcc,NULL,NULL);
-				dev_kfree_skb(skb);
-				goto as_indicate_complete;
-			}
-			sk->sk_ack_backlog++;
-			skb_queue_tail(&sk->sk_receive_queue, skb);
-			pr_debug("waking sk->sk_sleep 0x%p\n", sk->sk_sleep);
-			sk->sk_state_change(sk);
+		session_vcc->itf = msg->pvc.sap_addr.itf;
+		session_vcc->vpi = msg->pvc.sap_addr.vpi;
+		session_vcc->vci = msg->pvc.sap_addr.vci;
+		if (session_vcc->vpi || session_vcc->vci)
+			session_vcc->qos = msg->qos;
+		break;
+	case as_error:
+		clear_bit(ATM_VF_REGIS, &vcc->flags);
+		clear_bit(ATM_VF_READY, &vcc->flags);
+		sk->sk_err = -msg->reply;
+		clear_bit(ATM_VF_WAITING, &vcc->flags);
+		break;
+	case as_indicate:
+		vcc = *(struct atm_vcc **)&msg->listen_vcc;
+		sk = sk_atm(vcc);
+		pr_debug("as_indicate!!!\n");
+		lock_sock(sk);
+		if (sk_acceptq_is_full(sk)) {
+			sigd_enq(NULL, as_reject, vcc, NULL, NULL);
+			dev_kfree_skb(skb);
+			goto as_indicate_complete;
+		}
+		sk->sk_ack_backlog++;
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		pr_debug("waking sk->sk_sleep 0x%p\n", sk->sk_sleep);
+		sk->sk_state_change(sk);
 as_indicate_complete:
-			release_sock(sk);
-			return 0;
-		case as_close:
-			set_bit(ATM_VF_RELEASED,&vcc->flags);
-			vcc_release_async(vcc, msg->reply);
-			goto out;
-		case as_modify:
-			modify_qos(vcc,msg);
-			break;
-		case as_addparty:
-		case as_dropparty:
-			sk->sk_err_soft = msg->reply;	/* < 0 failure, otherwise ep_ref */
-			clear_bit(ATM_VF_WAITING, &vcc->flags);
-			break;
-		default:
-			pr_alert("bad message type %d\n", (int)msg->type);
-			return -EINVAL;
+		release_sock(sk);
+		return 0;
+	case as_close:
+		set_bit(ATM_VF_RELEASED, &vcc->flags);
+		vcc_release_async(vcc, msg->reply);
+		goto out;
+	case as_modify:
+		modify_qos(vcc, msg);
+		break;
+	case as_addparty:
+	case as_dropparty:
+		sk->sk_err_soft = msg->reply;
+					/* < 0 failure, otherwise ep_ref */
+		clear_bit(ATM_VF_WAITING, &vcc->flags);
+		break;
+	default:
+		pr_alert("bad message type %d\n", (int)msg->type);
+		return -EINVAL;
 	}
 	sk->sk_state_change(sk);
 out:
@@ -159,48 +158,52 @@ out:
 	return 0;
 }
 
-
-void sigd_enq2(struct atm_vcc *vcc,enum atmsvc_msg_type type,
-    struct atm_vcc *listen_vcc,const struct sockaddr_atmpvc *pvc,
-    const struct sockaddr_atmsvc *svc,const struct atm_qos *qos,int reply)
+void sigd_enq2(struct atm_vcc *vcc, enum atmsvc_msg_type type,
+	       struct atm_vcc *listen_vcc, const struct sockaddr_atmpvc *pvc,
+	       const struct sockaddr_atmsvc *svc, const struct atm_qos *qos,
+	       int reply)
 {
 	struct sk_buff *skb;
 	struct atmsvc_msg *msg;
 	static unsigned session = 0;
 
 	pr_debug("%d (0x%p)\n", (int)type, vcc);
-	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg),GFP_KERNEL)))
+	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg), GFP_KERNEL)))
 		schedule();
-	msg = (struct atmsvc_msg *) skb_put(skb,sizeof(struct atmsvc_msg));
-	memset(msg,0,sizeof(*msg));
+	msg = (struct atmsvc_msg *)skb_put(skb, sizeof(struct atmsvc_msg));
+	memset(msg, 0, sizeof(*msg));
 	msg->type = type;
 	*(struct atm_vcc **) &msg->vcc = vcc;
 	*(struct atm_vcc **) &msg->listen_vcc = listen_vcc;
 	msg->reply = reply;
-	if (qos) msg->qos = *qos;
-	if (vcc) msg->sap = vcc->sap;
-	if (svc) msg->svc = *svc;
-	if (vcc) msg->local = vcc->local;
-	if (pvc) msg->pvc = *pvc;
+	if (qos)
+		msg->qos = *qos;
+	if (vcc)
+		msg->sap = vcc->sap;
+	if (svc)
+		msg->svc = *svc;
+	if (vcc)
+		msg->local = vcc->local;
+	if (pvc)
+		msg->pvc = *pvc;
 	if (vcc) {
 		if (type == as_connect && test_bit(ATM_VF_SESSION, &vcc->flags))
 			msg->session = ++session;
 			/* every new pmp connect gets the next session number */
 	}
 	sigd_put_skb(skb);
-	if (vcc) set_bit(ATM_VF_REGIS,&vcc->flags);
+	if (vcc)
+		set_bit(ATM_VF_REGIS, &vcc->flags);
 }
 
-
-void sigd_enq(struct atm_vcc *vcc,enum atmsvc_msg_type type,
-    struct atm_vcc *listen_vcc,const struct sockaddr_atmpvc *pvc,
-    const struct sockaddr_atmsvc *svc)
+void sigd_enq(struct atm_vcc *vcc, enum atmsvc_msg_type type,
+	      struct atm_vcc *listen_vcc, const struct sockaddr_atmpvc *pvc,
+	      const struct sockaddr_atmsvc *svc)
 {
-	sigd_enq2(vcc,type,listen_vcc,pvc,svc,vcc ? &vcc->qos : NULL,0);
+	sigd_enq2(vcc, type, listen_vcc, pvc, svc, vcc ? &vcc->qos : NULL, 0);
 	/* other ISP applications may use "reply" */
 }
 
-
 static void purge_vcc(struct atm_vcc *vcc)
 {
 	if (sk_atm(vcc)->sk_family == PF_ATMSVC &&
@@ -211,7 +214,6 @@ static void purge_vcc(struct atm_vcc *vcc)
 	}
 }
 
-
 static void sigd_close(struct atm_vcc *vcc)
 {
 	struct hlist_node *node;
@@ -225,7 +227,7 @@ static void sigd_close(struct atm_vcc *vcc)
 	skb_queue_purge(&sk_atm(vcc)->sk_receive_queue);
 
 	read_lock(&vcc_sklist_lock);
-	for(i = 0; i < VCC_HTABLE_SIZE; ++i) {
+	for (i = 0; i < VCC_HTABLE_SIZE; ++i) {
 		struct hlist_head *head = &vcc_hash[i];
 
 		sk_for_each(s, node, head) {
@@ -237,13 +239,11 @@ static void sigd_close(struct atm_vcc *vcc)
 	read_unlock(&vcc_sklist_lock);
 }
 
-
 static struct atmdev_ops sigd_dev_ops = {
 	.close = sigd_close,
 	.send =	sigd_send
 };
 
-
 static struct atm_dev sigd_dev = {
 	.ops =		&sigd_dev_ops,
 	.type =		"sig",
@@ -251,16 +251,16 @@ static struct atm_dev sigd_dev = {
 	.lock =		__SPIN_LOCK_UNLOCKED(sigd_dev.lock)
 };
 
-
 int sigd_attach(struct atm_vcc *vcc)
 {
-	if (sigd) return -EADDRINUSE;
+	if (sigd)
+		return -EADDRINUSE;
 	pr_debug("\n");
 	sigd = vcc;
 	vcc->dev = &sigd_dev;
 	vcc_insert_socket(sk_atm(vcc));
-	set_bit(ATM_VF_META,&vcc->flags);
-	set_bit(ATM_VF_READY,&vcc->flags);
+	set_bit(ATM_VF_META, &vcc->flags);
+	set_bit(ATM_VF_READY, &vcc->flags);
 #ifdef WAIT_FOR_DEMON
 	wake_up(&sigd_sleep);
 #endif
-- 
1.6.6.rc0.57.gad7a

