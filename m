From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 2/7] sctp: add support for generating stream ssn reset event notification
Date: Fri, 17 Feb 2017 12:45:38 +0800
Message-ID: <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
 <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35887 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932202AbdBQEqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:09 -0500
In-Reply-To: <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Stream Reset Event described in rfc6525
section 6.1.1.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/ulpevent.h |  4 ++++
 include/uapi/linux/sctp.h   | 16 ++++++++++++++++
 net/sctp/ulpevent.c         | 29 +++++++++++++++++++++++++++++
 3 files changed, 49 insertions(+)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 2c098cd..324b596 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -128,6 +128,10 @@ struct sctp_ulpevent *sctp_ulpevent_make_authkey(
 struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 	const struct sctp_association *asoc, gfp_t gfp);
 
+struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
+	const struct sctp_association *asoc, __u16 flags,
+	__u16 stream_num, __u16 *stream_list, gfp_t gfp);
+
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 				   struct msghdr *);
 void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index a91a9cc..d3ae381 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -490,6 +490,18 @@ struct sctp_sender_dry_event {
 	sctp_assoc_t sender_dry_assoc_id;
 };
 
+#define SCTP_STREAM_RESET_INCOMING_SSN	0x0001
+#define SCTP_STREAM_RESET_OUTGOING_SSN	0x0002
+#define SCTP_STREAM_RESET_DENIED	0x0004
+#define SCTP_STREAM_RESET_FAILED	0x0008
+struct sctp_stream_reset_event {
+	__u16 strreset_type;
+	__u16 strreset_flags;
+	__u32 strreset_length;
+	sctp_assoc_t strreset_assoc_id;
+	__u16 strreset_stream_list[];
+};
+
 /*
  * Described in Section 7.3
  *   Ancillary Data and Notification Interest Options
@@ -505,6 +517,7 @@ struct sctp_event_subscribe {
 	__u8 sctp_adaptation_layer_event;
 	__u8 sctp_authentication_event;
 	__u8 sctp_sender_dry_event;
+	__u8 sctp_stream_reset_event;
 };
 
 /*
@@ -529,6 +542,7 @@ union sctp_notification {
 	struct sctp_pdapi_event sn_pdapi_event;
 	struct sctp_authkey_event sn_authkey_event;
 	struct sctp_sender_dry_event sn_sender_dry_event;
+	struct sctp_stream_reset_event sn_strreset_event;
 };
 
 /* Section 5.3.1
@@ -556,6 +570,8 @@ enum sctp_sn_type {
 #define SCTP_AUTHENTICATION_INDICATION	SCTP_AUTHENTICATION_EVENT
 	SCTP_SENDER_DRY_EVENT,
 #define SCTP_SENDER_DRY_EVENT		SCTP_SENDER_DRY_EVENT
+	SCTP_STREAM_RESET_EVENT,
+#define SCTP_STREAM_RESET_EVENT		SCTP_STREAM_RESET_EVENT
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index bea0005..c8881bc5 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -854,6 +854,35 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 	return event;
 }
 
+struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
+	const struct sctp_association *asoc, __u16 flags, __u16 stream_num,
+	__u16 *stream_list, gfp_t gfp)
+{
+	struct sctp_stream_reset_event *sreset;
+	struct sctp_ulpevent *event;
+	struct sk_buff *skb;
+	int length, i;
+
+	length = sizeof(struct sctp_stream_reset_event) + 2 * stream_num;
+	event = sctp_ulpevent_new(length, MSG_NOTIFICATION, gfp);
+	if (!event)
+		return NULL;
+
+	skb = sctp_event2skb(event);
+	sreset = (struct sctp_stream_reset_event *)skb_put(skb, length);
+
+	sreset->strreset_type = SCTP_STREAM_RESET_EVENT;
+	sreset->strreset_flags = flags;
+	sreset->strreset_length = length;
+	sctp_ulpevent_set_owner(event, asoc);
+	sreset->strreset_assoc_id = sctp_assoc2id(asoc);
+
+	for (i = 0; i < stream_num; i++)
+		sreset->strreset_stream_list[i] = ntohs(stream_list[i]);
+
+	return event;
+}
+
 /* Return the notification type, assuming this is a notification
  * event.
  */
-- 
2.1.0
