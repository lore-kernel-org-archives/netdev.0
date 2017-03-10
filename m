From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/7] sctp: add support for generating add stream change event notification
Date: Fri, 10 Mar 2017 12:11:08 +0800
Message-ID: <70b0da1e9de612702d0ddcdeab67e56b6d11fd78.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
 <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
 <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36592 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753926AbdCJELq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:11:46 -0500
In-Reply-To: <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Stream Change Event described in rfc6525
section 6.1.3.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/ulpevent.h |  4 ++++
 include/uapi/linux/sctp.h   | 15 +++++++++++++++
 net/sctp/ulpevent.c         | 28 ++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 2ab7ed4..1060494 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -136,6 +136,10 @@ struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
 	const struct sctp_association *asoc, __u16 flags,
 	 __u32 local_tsn, __u32 remote_tsn, gfp_t gfp);
 
+struct sctp_ulpevent *sctp_ulpevent_make_stream_change_event(
+	const struct sctp_association *asoc, __u16 flags,
+	__u32 strchange_instrms, __u32 strchange_outstrms, gfp_t gfp);
+
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 				   struct msghdr *);
 void sctp_ulpevent_read_rcvinfo(const struct sctp_ulpevent *event,
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 7735829..fd652e6 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -513,6 +513,17 @@ struct sctp_assoc_reset_event {
 	__u32 assocreset_remote_tsn;
 };
 
+#define SCTP_ASSOC_CHANGE_DENIED	0x0004
+#define SCTP_ASSOC_CHANGE_FAILED	0x0008
+struct sctp_stream_change_event {
+	__u16 strchange_type;
+	__u16 strchange_flags;
+	__u32 strchange_length;
+	sctp_assoc_t strchange_assoc_id;
+	__u16 strchange_instrms;
+	__u16 strchange_outstrms;
+};
+
 /*
  * Described in Section 7.3
  *   Ancillary Data and Notification Interest Options
@@ -530,6 +541,7 @@ struct sctp_event_subscribe {
 	__u8 sctp_sender_dry_event;
 	__u8 sctp_stream_reset_event;
 	__u8 sctp_assoc_reset_event;
+	__u8 sctp_stream_change_event;
 };
 
 /*
@@ -556,6 +568,7 @@ union sctp_notification {
 	struct sctp_sender_dry_event sn_sender_dry_event;
 	struct sctp_stream_reset_event sn_strreset_event;
 	struct sctp_assoc_reset_event sn_assocreset_event;
+	struct sctp_stream_change_event sn_strchange_event;
 };
 
 /* Section 5.3.1
@@ -587,6 +600,8 @@ enum sctp_sn_type {
 #define SCTP_STREAM_RESET_EVENT		SCTP_STREAM_RESET_EVENT
 	SCTP_ASSOC_RESET_EVENT,
 #define SCTP_ASSOC_RESET_EVENT		SCTP_ASSOC_RESET_EVENT
+	SCTP_STREAM_CHANGE_EVENT,
+#define SCTP_STREAM_CHANGE_EVENT	SCTP_STREAM_CHANGE_EVENT
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 420d7f3..ec2b3e0 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -911,6 +911,34 @@ struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
 	return event;
 }
 
+struct sctp_ulpevent *sctp_ulpevent_make_stream_change_event(
+	const struct sctp_association *asoc, __u16 flags,
+	__u32 strchange_instrms, __u32 strchange_outstrms, gfp_t gfp)
+{
+	struct sctp_stream_change_event *schange;
+	struct sctp_ulpevent *event;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_stream_change_event),
+				  MSG_NOTIFICATION, gfp);
+	if (!event)
+		return NULL;
+
+	skb = sctp_event2skb(event);
+	schange = (struct sctp_stream_change_event *)
+		skb_put(skb, sizeof(struct sctp_stream_change_event));
+
+	schange->strchange_type = SCTP_STREAM_CHANGE_EVENT;
+	schange->strchange_flags = flags;
+	schange->strchange_length = sizeof(struct sctp_stream_change_event);
+	sctp_ulpevent_set_owner(event, asoc);
+	schange->strchange_assoc_id = sctp_assoc2id(asoc);
+	schange->strchange_instrms = strchange_instrms;
+	schange->strchange_outstrms = strchange_outstrms;
+
+	return event;
+}
+
 /* Return the notification type, assuming this is a notification
  * event.
  */
-- 
2.1.0
