From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/1] net/af_iucv: don't use paged skbs for TX on HiperSockets
Date: Tue, 10 Jan 2017 17:10:34 +0100
Message-ID: <20170110161034.82445-2-ubraun@linux.vnet.ibm.com>
References: <20170110161034.82445-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33523 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1030792AbdAJQKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:10:45 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0AG4heH076139
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 11:10:44 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27w1s6bdyy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 11:10:44 -0500
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 10 Jan 2017 16:10:42 -0000
In-Reply-To: <20170110161034.82445-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

With commit e53743994e21
("af_iucv: use paged SKBs for big outbound messages"),
we transmit paged skbs for both of AF_IUCV's transport modes
(IUCV or HiperSockets).
The qeth driver for Layer 3 HiperSockets currently doesn't
support NETIF_F_SG, so these skbs would just be linearized again
by the stack.
Avoid that overhead by using paged skbs only for IUCV transport.

cc stable, since this also circumvents a significant skb leak when
sending large messages (where the skb then needs to be linearized).

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Cc: <stable@vger.kernel.org> # v4.8+
Fixes: e53743994e21 ("af_iucv: use paged SKBs for big outbound messages")
---
 net/iucv/af_iucv.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index cfb9e5f..13190b3 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1044,7 +1044,8 @@ static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 {
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
-	size_t headroom, linear;
+	size_t headroom = 0;
+	size_t linear;
 	struct sk_buff *skb;
 	struct iucv_message txmsg = {0};
 	struct cmsghdr *cmsg;
@@ -1122,18 +1123,20 @@ static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	 * this is fine for SOCK_SEQPACKET (unless we want to support
 	 * segmented records using the MSG_EOR flag), but
 	 * for SOCK_STREAM we might want to improve it in future */
-	headroom = (iucv->transport == AF_IUCV_TRANS_HIPER)
-		   ? sizeof(struct af_iucv_trans_hdr) + ETH_HLEN : 0;
-	if (headroom + len < PAGE_SIZE) {
+	if (iucv->transport == AF_IUCV_TRANS_HIPER) {
+		headroom = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
 		linear = len;
 	} else {
-		/* In nonlinear "classic" iucv skb,
-		 * reserve space for iucv_array
-		 */
-		if (iucv->transport != AF_IUCV_TRANS_HIPER)
-			headroom += sizeof(struct iucv_array) *
-				    (MAX_SKB_FRAGS + 1);
-		linear = PAGE_SIZE - headroom;
+		if (len < PAGE_SIZE) {
+			linear = len;
+		} else {
+			/* In nonlinear "classic" iucv skb,
+			 * reserve space for iucv_array
+			 */
+			headroom = sizeof(struct iucv_array) *
+				   (MAX_SKB_FRAGS + 1);
+			linear = PAGE_SIZE - headroom;
+		}
 	}
 	skb = sock_alloc_send_pskb(sk, headroom + linear, len - linear,
 				   noblock, &err, 0);
-- 
2.8.4
