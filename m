From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] [SK_BUFF]: '< 0' and '>= 0' test on unsigned
Date: Tue, 17 Mar 2009 14:43:06 +0100
Message-ID: <49BFA8EA.4000702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f168.google.com ([209.85.219.168]:63502 "EHLO
	mail-ew0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023AbZCQNsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 09:48:32 -0400
Received: by ewy12 with SMTP id 12so52616ewy.37
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 06:48:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was this patch missed?

struct sk_buff is located at vi include/linux/skbuff.h +357: 
maybe a different test is needed in x25_rx_call_request()?
------------------------------>8-------------8<---------------------------------
skb->len is an unsigned int, so the test in x25_rx_call_request() always
evaluates to true.

len in x25_sendmsg() is unsigned as well. so -ERRORS returned by x25_output()
are not noticed.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 9fc5b02..c57a09f 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -951,10 +951,8 @@ int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 	/*
 	 *	Incoming Call User Data.
 	 */
-	if (skb->len >= 0) {
-		skb_copy_from_linear_data(skb, makex25->calluserdata.cuddata, skb->len);
-		makex25->calluserdata.cudlength = skb->len;
-	}
+	skb_copy_from_linear_data(skb, makex25->calluserdata.cuddata, skb->len);
+	makex25->calluserdata.cudlength = skb->len;
 
 	sk->sk_ack_backlog++;
 
@@ -1122,8 +1120,9 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (msg->msg_flags & MSG_OOB)
 		skb_queue_tail(&x25->interrupt_out_queue, skb);
 	else {
-		len = x25_output(sk, skb);
-		if (len < 0)
+		rc = x25_output(sk, skb);
+		len = rc;
+		if (rc < 0)
 			kfree_skb(skb);
 		else if (x25->qbitincl)
 			len++;

