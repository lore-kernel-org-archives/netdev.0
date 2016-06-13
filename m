From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/3] af_iucv: use paged SKBs for big inbound messages
Date: Mon, 13 Jun 2016 18:46:16 +0200
Message-ID: <1465836376-24452-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:23319 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1161324AbcFMQrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:47:06 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5DGi1ls074144
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:47:06 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23gc8w95jf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:47:06 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 17:47:04 +0100
In-Reply-To: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

When an inbound message is bigger than a page, allocate a paged SKB,
and subsequently use IUCV receive primitive with IPBUFLST flag.
This relaxes the pressure to allocate big contiguous kernel buffers.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 50 insertions(+), 6 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 9ed2adf..37d674e 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1231,6 +1231,34 @@ out:
 	return err;
 }
 
+static struct sk_buff *alloc_iucv_recv_skb(unsigned long len)
+{
+	size_t headroom, linear;
+	struct sk_buff *skb;
+	int err;
+
+	if (len < PAGE_SIZE) {
+		headroom = 0;
+		linear = len;
+	} else {
+		headroom = sizeof(struct iucv_array) * (MAX_SKB_FRAGS + 1);
+		linear = PAGE_SIZE - headroom;
+	}
+	skb = alloc_skb_with_frags(headroom + linear, len - linear,
+				   0, &err, GFP_ATOMIC | GFP_DMA);
+	WARN_ONCE(!skb,
+		  "alloc of recv iucv skb len=%lu failed with errcode=%d\n",
+		  len, err);
+	if (skb) {
+		if (headroom)
+			skb_reserve(skb, headroom);
+		skb_put(skb, linear);
+		skb->len = len;
+		skb->data_len = len - linear;
+	}
+	return skb;
+}
+
 /* iucv_process_message() - Receive a single outstanding IUCV message
  *
  * Locking: must be called with message_q.lock held
@@ -1255,16 +1283,32 @@ static void iucv_process_message(struct sock *sk, struct sk_buff *skb,
 			skb->len = 0;
 		}
 	} else {
-		rc = pr_iucv->message_receive(path, msg,
+		if (skb_is_nonlinear(skb)) {
+			struct iucv_array *iba = (struct iucv_array *)skb->head;
+			int i;
+
+			iba[0].address = (u32)(addr_t)skb->data;
+			iba[0].length = (u32)skb_headlen(skb);
+			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+				iba[i + 1].address =
+					(u32)(addr_t)skb_frag_address(frag);
+				iba[i + 1].length = (u32)skb_frag_size(frag);
+			}
+			rc = pr_iucv->message_receive(path, msg,
+					      IUCV_IPBUFLST,
+					      (void *)iba, len, NULL);
+		} else {
+			rc = pr_iucv->message_receive(path, msg,
 					      msg->flags & IUCV_IPRMDATA,
 					      skb->data, len, NULL);
+		}
 		if (rc) {
 			kfree_skb(skb);
 			return;
 		}
-		skb_reset_transport_header(skb);
-		skb_reset_network_header(skb);
-		skb->len = len;
+		WARN_ON_ONCE(skb->len != len);
 	}
 
 	IUCV_SKB_CB(skb)->offset = 0;
@@ -1283,7 +1327,7 @@ static void iucv_process_message_q(struct sock *sk)
 	struct sock_msg_q *p, *n;
 
 	list_for_each_entry_safe(p, n, &iucv->message_q.list, list) {
-		skb = alloc_skb(iucv_msg_length(&p->msg), GFP_ATOMIC | GFP_DMA);
+		skb = alloc_iucv_recv_skb(iucv_msg_length(&p->msg));
 		if (!skb)
 			break;
 		iucv_process_message(sk, skb, p->path, &p->msg);
@@ -1778,7 +1822,7 @@ static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 	if (len > sk->sk_rcvbuf)
 		goto save_message;
 
-	skb = alloc_skb(iucv_msg_length(msg), GFP_ATOMIC | GFP_DMA);
+	skb = alloc_iucv_recv_skb(iucv_msg_length(msg));
 	if (!skb)
 		goto save_message;
 
-- 
2.6.6
