From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/2][SCTP]: Fix receive buffer accounting.
Date: Mon, 09 Oct 2006 17:43:09 -0700
Message-ID: <1160440989.27455.5.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:63708 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964880AbWJJAnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 20:43:12 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9A0hCMa014571
	for <netdev@vger.kernel.org>; Mon, 9 Oct 2006 20:43:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9A0hCVG090164
	for <netdev@vger.kernel.org>; Mon, 9 Oct 2006 20:43:12 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9A0hBYO009487
	for <netdev@vger.kernel.org>; Mon, 9 Oct 2006 20:43:11 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider the following 2 SCTP bug fixes for 2.6.19.

Thanks
Sridhar

[SCTP]: Fix receive buffer accounting.

When doing receiver buffer accounting, we always used skb->truesize.
This is problematic when processing bundled DATA chunks because for
every DATA chunk that could be small part of one large skb, we would
charge the size of the entire skb.  The new approach is to store the
size of the DATA chunk we are accounting for in the sctp_ulpevent
structure and use that stored value for accounting.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/sctp.h     |   14 ++++++++++++++
 include/net/sctp/ulpevent.h |    1 +
 net/sctp/socket.c           |   22 ++++++++++++++++++----
 net/sctp/ulpevent.c         |   25 +++++++++++++++----------
 net/sctp/ulpqueue.c         |    2 +-
 5 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ee68a31..764e3af 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -139,6 +139,7 @@ int sctp_inet_listen(struct socket *sock
 void sctp_write_space(struct sock *sk);
 unsigned int sctp_poll(struct file *file, struct socket *sock,
 		poll_table *wait);
+void sctp_sock_rfree(struct sk_buff *skb);
 
 /*
  * sctp/primitive.c
@@ -444,6 +445,19 @@ static inline struct list_head *sctp_lis
 	return result;
 }
 
+/* SCTP version of skb_set_owner_r.  We need this one because
+ * of the way we have to do receive buffer accounting on bundled
+ * chunks.
+ */
+static inline void sctp_skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
+{
+	struct sctp_ulpevent *event = sctp_skb2event(skb);
+
+	skb->sk = sk;
+	skb->destructor = sctp_sock_rfree;
+	atomic_add(event->rmem_len, &sk->sk_rmem_alloc);
+}
+
 /* Tests if the list has one and only one entry. */
 static inline int sctp_list_single_entry(struct list_head *head)
 {
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 6c40cfc..1a4ddc1 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -63,6 +63,7 @@ struct sctp_ulpevent {
 	__u32 cumtsn;
 	int msg_flags;
 	int iif;
+	unsigned int rmem_len;
 };
 
 /* Retrieve the skb this event sits inside of. */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 3fe906d..9deec43 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5362,6 +5362,20 @@ static void sctp_wfree(struct sk_buff *s
 	sctp_association_put(asoc);
 }
 
+/* Do accounting for the receive space on the socket.
+ * Accounting for the association is done in ulpevent.c
+ * We set this as a destructor for the cloned data skbs so that
+ * accounting is done at the correct time.
+ */
+void sctp_sock_rfree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	struct sctp_ulpevent *event = sctp_skb2event(skb);
+
+	atomic_sub(event->rmem_len, &sk->sk_rmem_alloc);
+}
+
+
 /* Helper function to wait for space in the sndbuf.  */
 static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
 				size_t msg_len)
@@ -5634,10 +5648,10 @@ static void sctp_sock_migrate(struct soc
 	sctp_skb_for_each(skb, &oldsk->sk_receive_queue, tmp) {
 		event = sctp_skb2event(skb);
 		if (event->asoc == assoc) {
-			sock_rfree(skb);
+			sctp_sock_rfree(skb);
 			__skb_unlink(skb, &oldsk->sk_receive_queue);
 			__skb_queue_tail(&newsk->sk_receive_queue, skb);
-			skb_set_owner_r(skb, newsk);
+			sctp_skb_set_owner_r(skb, newsk);
 		}
 	}
 
@@ -5665,10 +5679,10 @@ static void sctp_sock_migrate(struct soc
 		sctp_skb_for_each(skb, &oldsp->pd_lobby, tmp) {
 			event = sctp_skb2event(skb);
 			if (event->asoc == assoc) {
-				sock_rfree(skb);
+				sctp_sock_rfree(skb);
 				__skb_unlink(skb, &oldsp->pd_lobby);
 				__skb_queue_tail(queue, skb);
-				skb_set_owner_r(skb, newsk);
+				sctp_skb_set_owner_r(skb, newsk);
 			}
 		}
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index ee23678..a015283 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -55,10 +55,13 @@ static void sctp_ulpevent_release_frag_d
 
 
 /* Initialize an ULP event from an given skb.  */
-SCTP_STATIC void sctp_ulpevent_init(struct sctp_ulpevent *event, int msg_flags)
+SCTP_STATIC void sctp_ulpevent_init(struct sctp_ulpevent *event,
+				    int msg_flags,
+				    unsigned int len)
 {
 	memset(event, 0, sizeof(struct sctp_ulpevent));
 	event->msg_flags = msg_flags;
+	event->rmem_len = len;
 }
 
 /* Create a new sctp_ulpevent.  */
@@ -73,7 +76,7 @@ SCTP_STATIC struct sctp_ulpevent *sctp_u
 		goto fail;
 
 	event = sctp_skb2event(skb);
-	sctp_ulpevent_init(event, msg_flags);
+	sctp_ulpevent_init(event, msg_flags, skb->truesize);
 
 	return event;
 
@@ -101,17 +104,16 @@ static inline void sctp_ulpevent_set_own
 	sctp_association_hold((struct sctp_association *)asoc);
 	skb = sctp_event2skb(event);
 	event->asoc = (struct sctp_association *)asoc;
-	atomic_add(skb->truesize, &event->asoc->rmem_alloc);
-	skb_set_owner_r(skb, asoc->base.sk);
+	atomic_add(event->rmem_len, &event->asoc->rmem_alloc);
+	sctp_skb_set_owner_r(skb, asoc->base.sk);
 }
 
 /* A simple destructor to give up the reference to the association. */
 static inline void sctp_ulpevent_release_owner(struct sctp_ulpevent *event)
 {
 	struct sctp_association *asoc = event->asoc;
-	struct sk_buff *skb = sctp_event2skb(event);
 
-	atomic_sub(skb->truesize, &asoc->rmem_alloc);
+	atomic_sub(event->rmem_len, &asoc->rmem_alloc);
 	sctp_association_put(asoc);
 }
 
@@ -372,7 +374,7 @@ struct sctp_ulpevent *sctp_ulpevent_make
 
 	/* Embed the event fields inside the cloned skb.  */
 	event = sctp_skb2event(skb);
-	sctp_ulpevent_init(event, MSG_NOTIFICATION);
+	sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
 	sre = (struct sctp_remote_error *)
 		skb_push(skb, sizeof(struct sctp_remote_error));
@@ -464,7 +466,7 @@ struct sctp_ulpevent *sctp_ulpevent_make
 
 	/* Embed the event fields inside the cloned skb.  */
 	event = sctp_skb2event(skb);
-	sctp_ulpevent_init(event, MSG_NOTIFICATION);
+	sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
 
 	ssf = (struct sctp_send_failed *)
 		skb_push(skb, sizeof(struct sctp_send_failed));
@@ -682,8 +684,11 @@ struct sctp_ulpevent *sctp_ulpevent_make
 	/* Embed the event fields inside the cloned skb.  */
 	event = sctp_skb2event(skb);
 
-	/* Initialize event with flags 0.  */
-	sctp_ulpevent_init(event, 0);
+	/* Initialize event with flags 0  and correct length
+	 * Since this is a clone of the original skb, only account for
+	 * the data of this chunk as other chunks will be accounted separately.
+	 */
+	sctp_ulpevent_init(event, 0, skb->len + sizeof(struct sk_buff));
 
 	sctp_ulpevent_receive_data(event, asoc);
 
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 575e556..e1d1442 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -309,7 +309,7 @@ static struct sctp_ulpevent *sctp_make_r
  			if (!new)
  				return NULL;	/* try again later */
 
- 			new->sk = f_frag->sk;
+ 			sctp_skb_set_owner_r(new, f_frag->sk);
 
  			skb_shinfo(new)->frag_list = pos;
  		} else



