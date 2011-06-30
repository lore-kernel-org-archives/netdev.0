From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] sctp: ABORT if receive queue is not empty while closing
 socket
Date: Thu, 30 Jun 2011 09:31:22 -0400
Message-ID: <20110630133122.GB24074@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38405 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab1F3NbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 09:31:25 -0400
Content-Disposition: inline
In-Reply-To: <4E0B4F71.4020108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 29, 2011 at 12:14:41PM -0400, Vladislav Yasevich wrote:
> Right.  The lack of ABORT from the receive of data is a bug.  I was trying to point out
> that instead of modified the sender of data to send the ABORT, you modify the receiver
> to send the ABORT when it is being closed while having data queued.

Is this what you had in mind?

Trigger user ABORT when a socket is closed which has skbs sitting on
the receive queue. If data was lost, there is no point in doing a
graceful shutdown. This is consistent with TCP behaviour.

This also resolves the situation when a receiver cannot reopen its rwnd
and the sender continues retransmission attempts indefinitely before
initiating the shutdown.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 99b027b..ca4693b 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -80,7 +80,7 @@ static inline struct sctp_ulpevent *sctp_skb2event(struct sk_buff *skb)
 
 void sctp_ulpevent_free(struct sctp_ulpevent *);
 int sctp_ulpevent_is_notification(const struct sctp_ulpevent *);
-void sctp_queue_purge_ulpevents(struct sk_buff_head *list);
+unsigned int sctp_queue_purge_ulpevents(struct sk_buff_head *list);
 
 struct sctp_ulpevent *sctp_ulpevent_make_assoc_change(
 	const struct sctp_association *asoc,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6766913..958253a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1384,6 +1384,7 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
 	struct sctp_endpoint *ep;
 	struct sctp_association *asoc;
 	struct list_head *pos, *temp;
+	unsigned int data_was_unread;
 
 	SCTP_DEBUG_PRINTK("sctp_close(sk: 0x%p, timeout:%ld)\n", sk, timeout);
 
@@ -1393,6 +1394,10 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
 
 	ep = sctp_sk(sk)->ep;
 
+	/* Clean up any skbs sitting on the receive queue.  */
+	data_was_unread = sctp_queue_purge_ulpevents(&sk->sk_receive_queue);
+	data_was_unread += sctp_queue_purge_ulpevents(&sctp_sk(sk)->pd_lobby);
+
 	/* Walk all associations on an endpoint.  */
 	list_for_each_safe(pos, temp, &ep->asocs) {
 		asoc = list_entry(pos, struct sctp_association, asocs);
@@ -1410,7 +1415,8 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
 			}
 		}
 
-		if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
+		if (data_was_unread ||
+		    (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime)) {
 			struct sctp_chunk *chunk;
 
 			chunk = sctp_make_abort_user(asoc, NULL, 0);
@@ -1420,10 +1426,6 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
 			sctp_primitive_SHUTDOWN(asoc, NULL);
 	}
 
-	/* Clean up any skbs sitting on the receive queue.  */
-	sctp_queue_purge_ulpevents(&sk->sk_receive_queue);
-	sctp_queue_purge_ulpevents(&sctp_sk(sk)->pd_lobby);
-
 	/* On a TCP-style socket, block for at most linger_time if set. */
 	if (sctp_style(sk, TCP) && timeout)
 		sctp_wait_for_close(sk, timeout);
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index e70e5fc..aab3184 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -1081,9 +1081,19 @@ void sctp_ulpevent_free(struct sctp_ulpevent *event)
 }
 
 /* Purge the skb lists holding ulpevents. */
-void sctp_queue_purge_ulpevents(struct sk_buff_head *list)
+unsigned int sctp_queue_purge_ulpevents(struct sk_buff_head *list)
 {
 	struct sk_buff *skb;
-	while ((skb = skb_dequeue(list)) != NULL)
+	unsigned int data_unread = 0;
+
+	while ((skb = skb_dequeue(list)) != NULL) {
+		struct sctp_ulpevent *event = sctp_skb2event(skb);
+
+		if (!sctp_ulpevent_is_notification(event))
+			data_unread += skb->len;
+
 		sctp_ulpevent_free(sctp_skb2event(skb));
+	}
+
+	return data_unread;
 }
