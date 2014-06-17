From: Geir Ola Vaagland <geirola@gmail.com>
Subject: [PATCH net-next 5/6] Support for receiving SCTP_NXTINFO ancillary data
Date: Tue, 17 Jun 2014 13:57:52 +0200
Message-ID: <1403006273-27859-6-git-send-email-geirola@gmail.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:38707 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbaFQL6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:58:05 -0400
In-Reply-To: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Geir Ola Vaagland <geirola@gmail.com>
---
 include/net/sctp/ulpevent.h |  2 ++
 net/sctp/socket.c           | 16 +++++++++--
 net/sctp/ulpevent.c         | 67 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 2f42831..d15b835 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -133,6 +133,8 @@ void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 	struct msghdr *);
 void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
 	struct msghdr *);
+void sctp_ulpevent_read_nxtinfo(const struct sctp_ulpevent *event,
+	struct msghdr *, struct sk_buff *);
 __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event);
 
 /* Is this event type enabled? */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 10e12da..57106e8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2061,11 +2061,11 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len, int noblock,
 			int flags, int *addr_len)
 {
-	struct sctp_ulpevent *event = NULL;
+	struct sctp_ulpevent *event = NULL, *nxt_event = NULL;
 	struct sctp_sock *sp = sctp_sk(sk);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *nxtskb = NULL;
 	int copied;
-	int err = 0;
+	int err = 0, err2 = 0;
 	int skb_len;
 
 	pr_debug("%s: sk:%p, msghdr:%p, len:%zd, noblock:%d, flags:0x%x, "
@@ -2113,6 +2113,14 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 		sctp_ulpevent_read_rcvinfo(event, msg);
 	}
 
+	if(sp->recvnxtinfo){
+		nxtskb = sctp_skb_recv_datagram(sk, MSG_PEEK, 1, &err2);
+		if(nxtskb && nxtskb->len){
+			nxt_event = sctp_skb2event(nxtskb);
+			sctp_ulpevent_read_nxtinfo(nxt_event, msg, nxtskb);
+		}
+	}
+
 	/* Check if we allow SCTP_SNDRCVINFO. */
 	if (sp->subscribe.sctp_data_io_event)
 		sctp_ulpevent_read_sndrcvinfo(event, msg);
@@ -2162,6 +2170,8 @@ out_free:
 		sctp_ulpevent_free(event);
 	}
 out:
+	if(nxtskb)
+		kfree_skb(nxtskb);
 	sctp_release_sock(sk);
 	return err;
 }
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index d1b9a02..94da2b4 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -900,6 +900,73 @@ __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event)
 	return notification->sn_header.sn_type;
 }
 
+void sctp_ulpevent_read_nxtinfo(const struct sctp_ulpevent *event,
+		struct msghdr *msghdr, struct sk_buff* skb)
+{
+	struct sctp_nxtinfo nxtinfo;
+
+
+	/* Sockets API Extensions for SCTP
+	 * Section 5.3.6 SCTP Next Receive Information Structure (SCTP_NXTINFO)
+	 *
+	 * nxt_sid: 16 bits (unsigned integer)
+	 *
+	 * The SCTP stack places the next message's stream number in
+	 * this value.
+	 */
+	nxtinfo.nxt_sid = event->stream;
+
+	/* nxt_ppid: 32 bits (unsigned integer)
+	 *
+	 * This value is the same information that was passed by the
+	 * upper layer in the peer application for the next message.  Please
+	 * note  that the SCTP stack performs no byte order modification of
+	 * this field.  For example, if the DATA chunk has to contain a given
+	 * value in network byte order, the SCTP user has to perform the
+	 * ntohl() computation.
+	 */
+	nxtinfo.nxt_ppid = event->ppid;
+
+	/* nxt_flags: 16 bits (unsigned integer)
+	 *
+	 * This field may contain any of the following flags and is
+	 * composed of a bitwise OR of these values.
+	 */
+	nxtinfo.nxt_flags = event->flags;
+
+	/*
+	 * SCTP_NOTIFICATION is not set in Linux yet.
+	 *
+	 * if (sctp_ulpevent_is_notification(event)){
+	 *     nxtinfo.nxt_flags |= SCTP_NOTIFICATION;
+	 * }
+	 *
+	 */
+
+	/* nxt_length: 32 bits (unsigned integer)
+	 *
+	 * This value is the length of the message currently within
+	 * the socket buffer.  This might NOT be the entire length of the
+	 * message, since a partial delivery may be in progress.  Only if the
+	 * flag SCTP_COMPLETE is set in the nxt_flags field does this field
+	 * represent the size of the entire next message.
+	 */
+	nxtinfo.nxt_length = skb->len;
+
+	/* nxt_assoc_id: sizeof(sctp_assoc_t)
+	 * The association handle field of the next message,
+	 * nxt_assoc_id, holds the identifier for the association
+	 * announced in the SCTP_COMM_UP notification.  All
+	 * notifications for a given association have the same
+	 * identifier.  This field is ignored for one-to-one style
+	 * sockets.
+	 */
+	nxtinfo.nxt_assoc_id = sctp_assoc2id(event->asoc);
+
+	put_cmsg(msghdr, IPPROTO_SCTP, SCTP_NXTINFO,
+			sizeof(struct sctp_nxtinfo), (void *)&nxtinfo);
+}
+
 void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
 		struct msghdr *msghdr)
 {
