From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/2] [PATCH] af_iucv: Change if condition in sendmsg() for more readability
Date: Thu, 18 Jun 2009 09:54:47 +0200
Message-ID: <20090618075522.107891000@linux.vnet.ibm.com>
References: <20090618075446.890351000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:44062 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbZFRH4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:56:03 -0400
Content-Disposition: inline; filename=601-af_iucv-sendmsg-readability.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

Change the if condition to exit sendmsg() if the socket in not connected.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |  165 ++++++++++++++++++++++++++---------------------------
 1 file changed, 82 insertions(+), 83 deletions(-)

Index: linux-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- linux-2.6-uschi.orig/net/iucv/af_iucv.c
+++ linux-2.6-uschi/net/iucv/af_iucv.c
@@ -864,108 +864,107 @@ static int iucv_sock_sendmsg(struct kioc
 		goto out;
 	}
 
-	if (sk->sk_state == IUCV_CONNECTED) {
-		/* initialize defaults */
-		cmsg_done   = 0;	/* check for duplicate headers */
-		txmsg.class = 0;
+	/* Return if the socket is not in connected state */
+	if (sk->sk_state != IUCV_CONNECTED) {
+		err = -ENOTCONN;
+		goto out;
+	}
 
-		/* iterate over control messages */
-		for (cmsg = CMSG_FIRSTHDR(msg); cmsg;
-		     cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	/* initialize defaults */
+	cmsg_done   = 0;	/* check for duplicate headers */
+	txmsg.class = 0;
+
+	/* iterate over control messages */
+	for (cmsg = CMSG_FIRSTHDR(msg); cmsg;
+		cmsg = CMSG_NXTHDR(msg, cmsg)) {
 
-			if (!CMSG_OK(msg, cmsg)) {
-				err = -EINVAL;
-				goto out;
-			}
+		if (!CMSG_OK(msg, cmsg)) {
+			err = -EINVAL;
+			goto out;
+		}
 
-			if (cmsg->cmsg_level != SOL_IUCV)
-				continue;
+		if (cmsg->cmsg_level != SOL_IUCV)
+			continue;
+
+		if (cmsg->cmsg_type & cmsg_done) {
+			err = -EINVAL;
+			goto out;
+		}
+		cmsg_done |= cmsg->cmsg_type;
 
-			if (cmsg->cmsg_type & cmsg_done) {
+		switch (cmsg->cmsg_type) {
+		case SCM_IUCV_TRGCLS:
+			if (cmsg->cmsg_len != CMSG_LEN(TRGCLS_SIZE)) {
 				err = -EINVAL;
 				goto out;
 			}
-			cmsg_done |= cmsg->cmsg_type;
 
-			switch (cmsg->cmsg_type) {
-			case SCM_IUCV_TRGCLS:
-				if (cmsg->cmsg_len != CMSG_LEN(TRGCLS_SIZE)) {
-					err = -EINVAL;
-					goto out;
-				}
-
-				/* set iucv message target class */
-				memcpy(&txmsg.class,
-					(void *) CMSG_DATA(cmsg), TRGCLS_SIZE);
+			/* set iucv message target class */
+			memcpy(&txmsg.class,
+				(void *) CMSG_DATA(cmsg), TRGCLS_SIZE);
 
-				break;
+			break;
 
-			default:
-				err = -EINVAL;
-				goto out;
-				break;
-			}
+		default:
+			err = -EINVAL;
+			goto out;
+			break;
 		}
+	}
 
-		/* allocate one skb for each iucv message:
-		 * this is fine for SOCK_SEQPACKET (unless we want to support
-		 * segmented records using the MSG_EOR flag), but
-		 * for SOCK_STREAM we might want to improve it in future */
-		if (!(skb = sock_alloc_send_skb(sk, len,
-						msg->msg_flags & MSG_DONTWAIT,
-						&err)))
-			goto out;
+	/* allocate one skb for each iucv message:
+	 * this is fine for SOCK_SEQPACKET (unless we want to support
+	 * segmented records using the MSG_EOR flag), but
+	 * for SOCK_STREAM we might want to improve it in future */
+	skb = sock_alloc_send_skb(sk, len, msg->msg_flags & MSG_DONTWAIT,
+				  &err);
+	if (!skb)
+		goto out;
+	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
+		err = -EFAULT;
+		goto fail;
+	}
 
-		if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
-			err = -EFAULT;
-			goto fail;
+	/* increment and save iucv message tag for msg_completion cbk */
+	txmsg.tag = iucv->send_tag++;
+	memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
+	skb_queue_tail(&iucv->send_skb_q, skb);
+
+	if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags)
+	      && skb->len <= 7) {
+		err = iucv_send_iprm(iucv->path, &txmsg, skb);
+
+		/* on success: there is no message_complete callback
+		 * for an IPRMDATA msg; remove skb from send queue */
+		if (err == 0) {
+			skb_unlink(skb, &iucv->send_skb_q);
+			kfree_skb(skb);
 		}
 
-		/* increment and save iucv message tag for msg_completion cbk */
-		txmsg.tag = iucv->send_tag++;
-		memcpy(CB_TAG(skb), &txmsg.tag, CB_TAG_LEN);
-		skb_queue_tail(&iucv->send_skb_q, skb);
-
-		if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags)
-		    && skb->len <= 7) {
-			err = iucv_send_iprm(iucv->path, &txmsg, skb);
-
-			/* on success: there is no message_complete callback
-			 * for an IPRMDATA msg; remove skb from send queue */
-			if (err == 0) {
-				skb_unlink(skb, &iucv->send_skb_q);
-				kfree_skb(skb);
-			}
-
-			/* this error should never happen since the
-			 * IUCV_IPRMDATA path flag is set... sever path */
-			if (err == 0x15) {
-				iucv_path_sever(iucv->path, NULL);
-				skb_unlink(skb, &iucv->send_skb_q);
-				err = -EPIPE;
-				goto fail;
-			}
-		} else
-			err = iucv_message_send(iucv->path, &txmsg, 0, 0,
-						(void *) skb->data, skb->len);
-		if (err) {
-			if (err == 3) {
-				user_id[8] = 0;
-				memcpy(user_id, iucv->dst_user_id, 8);
-				appl_id[8] = 0;
-				memcpy(appl_id, iucv->dst_name, 8);
-				pr_err("Application %s on z/VM guest %s"
-				       " exceeds message limit\n",
-				       user_id, appl_id);
-			}
+		/* this error should never happen since the
+		 * IUCV_IPRMDATA path flag is set... sever path */
+		if (err == 0x15) {
+			iucv_path_sever(iucv->path, NULL);
 			skb_unlink(skb, &iucv->send_skb_q);
 			err = -EPIPE;
 			goto fail;
 		}
-
-	} else {
-		err = -ENOTCONN;
-		goto out;
+	} else
+		err = iucv_message_send(iucv->path, &txmsg, 0, 0,
+					(void *) skb->data, skb->len);
+	if (err) {
+		if (err == 3) {
+			user_id[8] = 0;
+			memcpy(user_id, iucv->dst_user_id, 8);
+			appl_id[8] = 0;
+			memcpy(appl_id, iucv->dst_name, 8);
+			pr_err("Application %s on z/VM guest %s"
+				" exceeds message limit\n",
+				appl_id, user_id);
+		}
+		skb_unlink(skb, &iucv->send_skb_q);
+		err = -EPIPE;
+		goto fail;
 	}
 
 	release_sock(sk);

