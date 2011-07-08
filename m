From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCHv3] sctp: ABORT if receive, reassmbly, or reodering queue is
 not empty while closing socket
Date: Fri, 8 Jul 2011 10:37:46 -0400
Message-ID: <20110708143746.GB24249@canuck.infradead.org>
References: <20110629135704.GB10085@canuck.infradead.org>
 <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630133122.GB24074@canuck.infradead.org>
 <4E0C83FA.2090909@hp.com>
 <20110708105705.GA14583@canuck.infradead.org>
 <4E170B00.9080406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35944 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab1GHOhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 10:37:47 -0400
Content-Disposition: inline
In-Reply-To: <4E170B00.9080406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trigger user ABORT if application closes a socket which has data
queued on the socket receive queue or chunks waiting on the
reassembly or ordering queue as this would imply data being lost
which defeats the point of a graceful shutdown.

This behavior is already practiced in TCP.

We do not check the input queue because that would mean to parse
all chunks on it to look for unacknowledged data which seems too
much of an effort. Control chunks or duplicated chunks may also
be in the input queue and should not be stopping a graceful
shutdown.

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
index 08c6238..d3ccf79 100644
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
@@ -1410,7 +1415,9 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
 			}
 		}
 
-		if (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime) {
+		if (data_was_unread || !skb_queue_empty(&asoc->ulpq.lobby) ||
+		    !skb_queue_empty(&asoc->ulpq.reasm) ||
+		    (sock_flag(sk, SOCK_LINGER) && !sk->sk_lingertime)) {
 			struct sctp_chunk *chunk;
 
 			chunk = sctp_make_abort_user(asoc, NULL, 0);
@@ -1420,10 +1427,6 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
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
index e70e5fc..8a84017 100644
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
-		sctp_ulpevent_free(sctp_skb2event(skb));
+	unsigned int data_unread = 0;
+
+	while ((skb = skb_dequeue(list)) != NULL) {
+		struct sctp_ulpevent *event = sctp_skb2event(skb);
+
+		if (!sctp_ulpevent_is_notification(event))
+			data_unread += skb->len;
+
+		sctp_ulpevent_free(event);
+	}
+
+	return data_unread;
 }
