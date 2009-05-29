From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/10]: decnet: Use SKB queue and list helpers instead of
 doing it by-hand.
Date: Fri, 29 May 2009 01:40:18 -0700 (PDT)
Message-ID: <20090529.014018.242524642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56924
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757342AbZE2IkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/af_decnet.c  |   19 +++++--------------
 net/decnet/dn_nsp_out.c |    8 ++------
 2 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 9647d91..bccb388 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1250,14 +1250,8 @@ static int dn_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		if (skb) {
 			amount = skb->len;
 		} else {
-			skb = sk->sk_receive_queue.next;
-			for (;;) {
-				if (skb ==
-				    (struct sk_buff *)&sk->sk_receive_queue)
-					break;
+			skb_queue_walk(&sk->sk_receive_queue, skb)
 				amount += skb->len;
-				skb = skb->next;
-			}
 		}
 		release_sock(sk);
 		err = put_user(amount, (int __user *)arg);
@@ -1644,13 +1638,13 @@ static int __dn_getsockopt(struct socket *sock, int level,int optname, char __us
 
 static int dn_data_ready(struct sock *sk, struct sk_buff_head *q, int flags, int target)
 {
-	struct sk_buff *skb = q->next;
+	struct sk_buff *skb;
 	int len = 0;
 
 	if (flags & MSG_OOB)
 		return !skb_queue_empty(q) ? 1 : 0;
 
-	while(skb != (struct sk_buff *)q) {
+	skb_queue_walk(q, skb) {
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
 		len += skb->len;
 
@@ -1666,8 +1660,6 @@ static int dn_data_ready(struct sock *sk, struct sk_buff_head *q, int flags, int
 		/* minimum data length for read exceeded */
 		if (len >= target)
 			return 1;
-
-		skb = skb->next;
 	}
 
 	return 0;
@@ -1683,7 +1675,7 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 	size_t target = size > 1 ? 1 : 0;
 	size_t copied = 0;
 	int rv = 0;
-	struct sk_buff *skb, *nskb;
+	struct sk_buff *skb, *n;
 	struct dn_skb_cb *cb = NULL;
 	unsigned char eor = 0;
 	long timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
@@ -1758,7 +1750,7 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 		finish_wait(sk->sk_sleep, &wait);
 	}
 
-	for(skb = queue->next; skb != (struct sk_buff *)queue; skb = nskb) {
+	skb_queue_walk_safe(queue, skb, n) {
 		unsigned int chunk = skb->len;
 		cb = DN_SKB_CB(skb);
 
@@ -1775,7 +1767,6 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 			skb_pull(skb, chunk);
 
 		eor = cb->nsp_flags & 0x40;
-		nskb = skb->next;
 
 		if (skb->len == 0) {
 			skb_unlink(skb, queue);
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 2013c25..da04f45 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -382,7 +382,7 @@ int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 	struct dn_scp *scp = DN_SK(sk);
-	struct sk_buff *skb2, *list, *ack = NULL;
+	struct sk_buff *skb2, *n, *ack = NULL;
 	int wakeup = 0;
 	int try_retrans = 0;
 	unsigned long reftime = cb->stamp;
@@ -390,9 +390,7 @@ int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff
 	unsigned short xmit_count;
 	unsigned short segnum;
 
-	skb2 = q->next;
-	list = (struct sk_buff *)q;
-	while(list != skb2) {
+	skb_queue_walk_safe(q, skb2, n) {
 		struct dn_skb_cb *cb2 = DN_SKB_CB(skb2);
 
 		if (dn_before_or_equal(cb2->segnum, acknum))
@@ -400,8 +398,6 @@ int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff
 
 		/* printk(KERN_DEBUG "ack: %s %04x %04x\n", ack ? "ACK" : "SKIP", (int)cb2->segnum, (int)acknum); */
 
-		skb2 = skb2->next;
-
 		if (ack == NULL)
 			continue;
 
-- 
1.6.3

