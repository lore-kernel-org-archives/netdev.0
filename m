From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 2/2] Subject: [PATCH] af_iucv: drop skbs rejected by filter
Date: Fri,  7 Oct 2016 15:51:48 +0200
Message-ID: <bfcef2b67e296fbb5a479a23c6c38e48c4057188.1475846599.git.ursula.braun@de.ibm.com>
References: <cover.1475846599.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56707 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752952AbcJGNv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 09:51:56 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u97DnvGl117916
        for <netdev@vger.kernel.org>; Fri, 7 Oct 2016 09:51:56 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25xcft9bgw-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 09:51:55 -0400
Received: from localhost
        by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Oct 2016 14:51:54 +0100
In-Reply-To: <cover.1475846599.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1475846599.git.ursula.braun@de.ibm.com>
References: <cover.1475846599.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A packet filter might be installed for instance with setsockopt
SO_ATTACH_FILTER. af_iucv currently queues skbs rejected by filter
into the backlog queue. This does not make sense, since packets
rejected by filter can be dropped immediately. This patch adds
separate sk_filter return code checking, and dropping of packets
if applicable.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/iucv/af_iucv.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 88d0eaa..cfb9e5f 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1323,8 +1323,13 @@ static void iucv_process_message(struct sock *sk, struct sk_buff *skb,
 	}
 
 	IUCV_SKB_CB(skb)->offset = 0;
-	if (sock_queue_rcv_skb(sk, skb))
-		skb_queue_head(&iucv_sk(sk)->backlog_skb_q, skb);
+	if (sk_filter(sk, skb)) {
+		atomic_inc(&sk->sk_drops);	/* skb rejected by filter */
+		kfree_skb(skb);
+		return;
+	}
+	if (__sock_queue_rcv_skb(sk, skb))	/* handle rcv queue full */
+		skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
 }
 
 /* iucv_process_message_q() - Process outstanding IUCV messages
@@ -1438,13 +1443,13 @@ static int iucv_sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		rskb = skb_dequeue(&iucv->backlog_skb_q);
 		while (rskb) {
 			IUCV_SKB_CB(rskb)->offset = 0;
-			if (sock_queue_rcv_skb(sk, rskb)) {
+			if (__sock_queue_rcv_skb(sk, rskb)) {
+				/* handle rcv queue full */
 				skb_queue_head(&iucv->backlog_skb_q,
 						rskb);
 				break;
-			} else {
-				rskb = skb_dequeue(&iucv->backlog_skb_q);
 			}
+			rskb = skb_dequeue(&iucv->backlog_skb_q);
 		}
 		if (skb_queue_empty(&iucv->backlog_skb_q)) {
 			if (!list_empty(&iucv->message_q.list))
@@ -2124,12 +2129,17 @@ static int afiucv_hs_callback_rx(struct sock *sk, struct sk_buff *skb)
 	skb_reset_transport_header(skb);
 	skb_reset_network_header(skb);
 	IUCV_SKB_CB(skb)->offset = 0;
+	if (sk_filter(sk, skb)) {
+		atomic_inc(&sk->sk_drops);	/* skb rejected by filter */
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
 	spin_lock(&iucv->message_q.lock);
 	if (skb_queue_empty(&iucv->backlog_skb_q)) {
-		if (sock_queue_rcv_skb(sk, skb)) {
+		if (__sock_queue_rcv_skb(sk, skb))
 			/* handle rcv queue full */
 			skb_queue_tail(&iucv->backlog_skb_q, skb);
-		}
 	} else
 		skb_queue_tail(&iucv_sk(sk)->backlog_skb_q, skb);
 	spin_unlock(&iucv->message_q.lock);
-- 
2.8.4
