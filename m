From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/3] af_iucv: use paged SKBs for big outbound messages
Date: Mon, 13 Jun 2016 18:46:14 +0200
Message-ID: <1465836376-24452-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:24010 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964994AbcFMQrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:47:02 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5DGhvQA037307
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:47:02 -0400
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com [195.75.94.112])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23getkwfac-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:47:01 -0400
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 17:47:00 +0100
In-Reply-To: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

When an outbound message is bigger than a page, allocate and fill
a paged SKB, and subsequently use IUCV send primitive with IPBUFLST
flag. This relaxes the pressure to allocate big contiguous kernel
buffers.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 124 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 77 insertions(+), 47 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index fc3598a..38448d1 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1033,6 +1033,7 @@ static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 {
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
+	size_t headroom, linear;
 	struct sk_buff *skb;
 	struct iucv_message txmsg = {0};
 	struct cmsghdr *cmsg;
@@ -1110,20 +1111,31 @@ static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	 * this is fine for SOCK_SEQPACKET (unless we want to support
 	 * segmented records using the MSG_EOR flag), but
 	 * for SOCK_STREAM we might want to improve it in future */
-	if (iucv->transport == AF_IUCV_TRANS_HIPER)
-		skb = sock_alloc_send_skb(sk,
-			len + sizeof(struct af_iucv_trans_hdr) + ETH_HLEN,
-			noblock, &err);
-	else
-		skb = sock_alloc_send_skb(sk, len, noblock, &err);
+	headroom = (iucv->transport == AF_IUCV_TRANS_HIPER)
+		   ? sizeof(struct af_iucv_trans_hdr) + ETH_HLEN : 0;
+	if (headroom + len < PAGE_SIZE) {
+		linear = len;
+	} else {
+		/* In nonlinear "classic" iucv skb,
+		 * reserve space for iucv_array
+		 */
+		if (iucv->transport != AF_IUCV_TRANS_HIPER)
+			headroom += sizeof(struct iucv_array) *
+				    (MAX_SKB_FRAGS + 1);
+		linear = PAGE_SIZE - headroom;
+	}
+	skb = sock_alloc_send_pskb(sk, headroom + linear, len - linear,
+				   noblock, &err, 0);
 	if (!skb)
 		goto out;
-	if (iucv->transport == AF_IUCV_TRANS_HIPER)
-		skb_reserve(skb, sizeof(struct af_iucv_trans_hdr) + ETH_HLEN);
-	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
-		err = -EFAULT;
+	if (headroom)
+		skb_reserve(skb, headroom);
+	skb_put(skb, linear);
+	skb->len = len;
+	skb->data_len = len - linear;
+	err = skb_copy_datagram_from_iter(skb, 0, &msg->msg_iter, len);
+	if (err)
 		goto fail;
-	}
 
 	/* wait if outstanding messages for iucv path has reached */
 	timeo = sock_sndtimeo(sk, noblock);
@@ -1148,49 +1160,67 @@ static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 			atomic_dec(&iucv->msg_sent);
 			goto fail;
 		}
-		goto release;
-	}
-	skb_queue_tail(&iucv->send_skb_q, skb);
-
-	if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags)
-	      && skb->len <= 7) {
-		err = iucv_send_iprm(iucv->path, &txmsg, skb);
+	} else { /* Classic VM IUCV transport */
+		skb_queue_tail(&iucv->send_skb_q, skb);
+
+		if (((iucv->path->flags & IUCV_IPRMDATA) & iucv->flags) &&
+		    skb->len <= 7) {
+			err = iucv_send_iprm(iucv->path, &txmsg, skb);
+
+			/* on success: there is no message_complete callback */
+			/* for an IPRMDATA msg; remove skb from send queue   */
+			if (err == 0) {
+				skb_unlink(skb, &iucv->send_skb_q);
+				kfree_skb(skb);
+			}
 
-		/* on success: there is no message_complete callback
-		 * for an IPRMDATA msg; remove skb from send queue */
-		if (err == 0) {
-			skb_unlink(skb, &iucv->send_skb_q);
-			kfree_skb(skb);
+			/* this error should never happen since the	*/
+			/* IUCV_IPRMDATA path flag is set... sever path */
+			if (err == 0x15) {
+				pr_iucv->path_sever(iucv->path, NULL);
+				skb_unlink(skb, &iucv->send_skb_q);
+				err = -EPIPE;
+				goto fail;
+			}
+		} else if (skb_is_nonlinear(skb)) {
+			struct iucv_array *iba = (struct iucv_array *)skb->head;
+			int i;
+
+			/* skip iucv_array lying in the headroom */
+			iba[0].address = (u32)(addr_t)skb->data;
+			iba[0].length = (u32)skb_headlen(skb);
+			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+				iba[i + 1].address =
+					(u32)(addr_t)skb_frag_address(frag);
+				iba[i + 1].length = (u32)skb_frag_size(frag);
+			}
+			err = pr_iucv->message_send(iucv->path, &txmsg,
+						    IUCV_IPBUFLST, 0,
+						    (void *)iba, skb->len);
+		} else { /* non-IPRM Linear skb */
+			err = pr_iucv->message_send(iucv->path, &txmsg,
+					0, 0, (void *)skb->data, skb->len);
 		}
-
-		/* this error should never happen since the
-		 * IUCV_IPRMDATA path flag is set... sever path */
-		if (err == 0x15) {
-			pr_iucv->path_sever(iucv->path, NULL);
+		if (err) {
+			if (err == 3) {
+				user_id[8] = 0;
+				memcpy(user_id, iucv->dst_user_id, 8);
+				appl_id[8] = 0;
+				memcpy(appl_id, iucv->dst_name, 8);
+				pr_err(
+		"Application %s on z/VM guest %s exceeds message limit\n",
+					appl_id, user_id);
+				err = -EAGAIN;
+			} else {
+				err = -EPIPE;
+			}
 			skb_unlink(skb, &iucv->send_skb_q);
-			err = -EPIPE;
 			goto fail;
 		}
-	} else
-		err = pr_iucv->message_send(iucv->path, &txmsg, 0, 0,
-					(void *) skb->data, skb->len);
-	if (err) {
-		if (err == 3) {
-			user_id[8] = 0;
-			memcpy(user_id, iucv->dst_user_id, 8);
-			appl_id[8] = 0;
-			memcpy(appl_id, iucv->dst_name, 8);
-			pr_err("Application %s on z/VM guest %s"
-				" exceeds message limit\n",
-				appl_id, user_id);
-			err = -EAGAIN;
-		} else
-			err = -EPIPE;
-		skb_unlink(skb, &iucv->send_skb_q);
-		goto fail;
 	}
 
-release:
 	release_sock(sk);
 	return len;
 
-- 
2.6.6
