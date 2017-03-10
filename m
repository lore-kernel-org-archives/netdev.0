From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 1/7] sctp: add support for generating assoc reset event notification
Date: Fri, 10 Mar 2017 12:11:06 +0800
Message-ID: <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36273 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdCJELa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:11:30 -0500
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Association Reset Event described in rfc6525
section 6.1.2.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/ulpevent.h |  4 ++++
 include/uapi/linux/sctp.h   | 15 +++++++++++++++
 net/sctp/ulpevent.c         | 28 ++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 324b596..2ab7ed4 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -132,6 +132,10 @@ struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 	const struct sctp_association *asoc, __u16 flags,
 	__u16 stream_num, __u16 *stream_list, gfp_t gfp);
 
+struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
+	const struct sctp_association *asoc, __u16 flags,
+	 __u32 local_tsn, __u32 remote_tsn, gfp_t gfp);
+
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 				   struct msghdr *);
 void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index d3ae381..7735829 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -502,6 +502,17 @@ struct sctp_stream_reset_event {
 	__u16 strreset_stream_list[];
 };
 
+#define SCTP_ASSOC_RESET_DENIED		0x0004
+#define SCTP_ASSOC_RESET_FAILED		0x0008
+struct sctp_assoc_reset_event {
+	__u16 assocreset_type;
+	__u16 assocreset_flags;
+	__u32 assocreset_length;
+	sctp_assoc_t assocreset_assoc_id;
+	__u32 assocreset_local_tsn;
+	__u32 assocreset_remote_tsn;
+};
+
 /*
  * Described in Section 7.3
  *   Ancillary Data and Notification Interest Options
@@ -518,6 +529,7 @@ struct sctp_event_subscribe {
 	__u8 sctp_authentication_event;
 	__u8 sctp_sender_dry_event;
 	__u8 sctp_stream_reset_event;
+	__u8 sctp_assoc_reset_event;
 };
 
 /*
@@ -543,6 +555,7 @@ union sctp_notification {
 	struct sctp_authkey_event sn_authkey_event;
 	struct sctp_sender_dry_event sn_sender_dry_event;
 	struct sctp_stream_reset_event sn_strreset_event;
+	struct sctp_assoc_reset_event sn_assocreset_event;
 };
 
 /* Section 5.3.1
@@ -572,6 +585,8 @@ enum sctp_sn_type {
 #define SCTP_SENDER_DRY_EVENT		SCTP_SENDER_DRY_EVENT
 	SCTP_STREAM_RESET_EVENT,
 #define SCTP_STREAM_RESET_EVENT		SCTP_STREAM_RESET_EVENT
+	SCTP_ASSOC_RESET_EVENT,
+#define SCTP_ASSOC_RESET_EVENT		SCTP_ASSOC_RESET_EVENT
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index c8881bc5..420d7f3 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -883,6 +883,34 @@ struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 	return event;
 }
 
+struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
+	const struct sctp_association *asoc, __u16 flags, __u32 local_tsn,
+	__u32 remote_tsn, gfp_t gfp)
+{
+	struct sctp_assoc_reset_event *areset;
+	struct sctp_ulpevent *event;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_assoc_reset_event),
+				  MSG_NOTIFICATION, gfp);
+	if (!event)
+		return NULL;
+
+	skb = sctp_event2skb(event);
+	areset = (struct sctp_assoc_reset_event *)
+		skb_put(skb, sizeof(struct sctp_assoc_reset_event));
+
+	areset->assocreset_type = SCTP_ASSOC_RESET_EVENT;
+	areset->assocreset_flags = flags;
+	areset->assocreset_length = sizeof(struct sctp_assoc_reset_event);
+	sctp_ulpevent_set_owner(event, asoc);
+	areset->assocreset_assoc_id = sctp_assoc2id(asoc);
+	areset->assocreset_local_tsn = local_tsn;
+	areset->assocreset_remote_tsn = remote_tsn;
+
+	return event;
+}
+
 /* Return the notification type, assuming this is a notification
  * event.
  */
-- 
2.1.0
