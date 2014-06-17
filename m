From: Geir Ola Vaagland <geirola@gmail.com>
Subject: [PATCH net-next 2/6] Support for SCTP_RCVINFO ancillary data
Date: Tue, 17 Jun 2014 13:57:49 +0200
Message-ID: <1403006273-27859-3-git-send-email-geirola@gmail.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:61691 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756231AbaFQL6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:58:01 -0400
In-Reply-To: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Geir Ola Vaagland <geirola@gmail.com>
---
 include/net/sctp/ulpevent.h |  2 +
 include/uapi/linux/sctp.h   | 23 ++++++++++++
 net/sctp/socket.c           |  6 +++
 net/sctp/ulpevent.c         | 91 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 122 insertions(+)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 27b9f5c..2f42831 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -131,6 +131,8 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 	struct msghdr *);
+void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
+	struct msghdr *);
 __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event);
 
 /* Is this event type enabled? */
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index a7db3b3..7e8736b 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -158,6 +158,27 @@ struct sctp_sndrcvinfo {
 };
 
 /*
+ *  5.3.5 SCTP Receive Information Structure (SCTP_RCVINFO)
+ *
+ *   This cmsghdr structure specifies SCTP options for sendmsg().
+ *
+ *   cmsg_level    cmsg_type      cmsg_data[]
+ *   ------------  ------------   -------------------
+ *   IPPROTO_SCTP  SCTP_RCVINFO   struct sctp_rcvinfo
+ *
+ */
+struct sctp_rcvinfo {
+	__u16 rcv_sid;
+	__u16 rcv_ssn;
+	__u16 rcv_flags;
+	__u32 rcv_ppid;
+	__u32 rcv_tsn;
+	__u32 rcv_cumtsn;
+	__u32 rcv_context;
+	sctp_assoc_t rcv_assoc_id;
+};
+
+/*
  *  sinfo_flags: 16 bits (unsigned integer)
  *
  *   This field may contain any of the following flags and is composed of
@@ -184,6 +205,8 @@ typedef enum sctp_cmsg_type {
 #define SCTP_INIT	SCTP_INIT
 	SCTP_SNDRCV,            /* 5.2.2 SCTP Header Information Structure */
 #define SCTP_SNDRCV	SCTP_SNDRCV
+	SCTP_RCVINFO,
+#define SCTP_RCVINFO SCTP_RCVINFO
 } sctp_cmsg_t;
 
 /*
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1f3281b..aee161b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2094,6 +2094,12 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 		sp->pf->skb_msgname(skb, msg->msg_name, addr_len);
 	}
 
+
+	/* Check if SCTP_RCVINFO should be included */
+	if(sp->recvrcvinfo){
+		sctp_ulpevent_read_rcvinfo(event, msg);
+	}
+
 	/* Check if we allow SCTP_SNDRCVINFO. */
 	if (sp->subscribe.sctp_data_io_event)
 		sctp_ulpevent_read_sndrcvinfo(event, msg);
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 81089ed..d1b9a02 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -900,6 +900,97 @@ __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event)
 	return notification->sn_header.sn_type;
 }
 
+void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
+		struct msghdr *msghdr)
+{
+	struct sctp_rcvinfo rinfo;
+
+	if (sctp_ulpevent_is_notification(event)){
+		return;
+	}
+
+	/* Sockets API Extensions for SCTP
+	 * Section 5.3.5 SCTP Receive Information Structure (SCTP_SNDRCV)
+	 *
+	 * rcv_sid: 16 bits (unsigned integer)
+	 *
+	 * The SCTP stack places the message's stream number in this
+	 * value.
+	 */
+	rinfo.rcv_sid = event->stream;
+
+	/* rcv_ssn: 16 bits (unsigned integer)
+	 * This value contains the stream sequence number that the
+	 * remote endpoint placed in the DATA chunk.  For fragmented
+	 * messages, this is the same number for all deliveries of the
+	 * message (if more than one recvmsg() is needed to read
+	 * the message)
+	 */
+	rinfo.rcv_ssn = event->ssn;
+
+
+	/* rcv_ppid: 32 bits (unsigned integer)
+	 *
+	 * This value is the same information that was passed by the
+	 * upper layer in the peer application.  Please note that the SCTP
+	 * stack performs no byte order modification of this field.
+	 * For example, if the DATA chunk has to contain a given
+	 * value in network byte order, the SCTP user has to perform the
+	 * ntohl() computation.
+	 */
+	rinfo.rcv_ppid = event->ppid;
+
+	/* rcv_flags: 16 bits (unsigned integer)
+	 *
+	 * This field may contain any of the following flags and is composed of
+	 * a bitwise OR of these values.
+	 *
+	 * recvmsg() flags:
+	 *
+	 * SCTP_UNORDERED - This flag is present when the message was sent
+	 *                 non-ordered.
+	 */
+
+	rinfo.rcv_flags = event->flags;
+
+	/* rcv_tsn: 32 bits (unsigned integer)
+	 *
+	 * This field holds a TSN that was assigned to one of the SCTP
+	 * DATA chunks.
+	 */
+	rinfo.rcv_tsn = event->tsn;
+
+	/* rcv_cumtsn: 32 bits (unsigned integer)
+	 *
+	 * This field will hold the current cumulative TSN as known
+	 * by the underlying SCTP layer.
+	 */
+	rinfo.rcv_cumtsn = event->cumtsn;
+
+	/* rcv_assoc_id: sizeof (sctp_assoc_t)
+	 *
+	 * The association handle field, sinfo_assoc_id, holds the identifier
+	 * for the association announced in the COMMUNICATION_UP notification.
+	 * All notifications for a given association have the same identifier.
+	 * Ignored for one-to-one style sockets.
+	 */
+	rinfo.rcv_assoc_id = sctp_assoc2id(event->asoc);
+
+	/* rcv_context: 32 bits (unsigned integer)
+	 *
+	 * This value is an opaque 32-bit context datum that was
+	 * set by the user with the SCTP_CONTEXT socket option.  This
+	 * value is passed back to the upper layer if an error occurs on
+	 * the send of a message and is retrieved with each undelivered
+	 * message.
+	 */
+	rinfo.rcv_context = event->asoc->default_rcv_context;
+
+	put_cmsg(msghdr, IPPROTO_SCTP, SCTP_RCVINFO,
+			sizeof(struct sctp_rcvinfo), (void *)&rinfo);
+}
+
+
 /* Copy out the sndrcvinfo into a msghdr.  */
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 				   struct msghdr *msghdr)
