From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 17/27] sctp: add rfc6525 section 6.1.1
Date: Sun,  1 Jan 2017 19:20:34 +0800
Message-ID: <1e8e248c38fd3874cf80c4b88e4699c8a617066d.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
 <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
 <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
 <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
 <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36489 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALXI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:08 -0500
In-Reply-To: <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Stream Reset Event described in section 6.1.1.

It's added earlier here so that the codes for other sections could
invoked them.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/ulpevent.h |  4 ++++
 include/uapi/linux/sctp.h   | 36 ++++++++++++++++++++++++++----------
 net/sctp/ulpevent.c         | 30 ++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+), 10 deletions(-)

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
index 4401a40..97b8a96 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -491,21 +491,34 @@ struct sctp_sender_dry_event {
 	sctp_assoc_t sender_dry_assoc_id;
 };
 
+#define SCTP_STREAM_RESET_INCOMING_SSN	0x0001
+#define SCTP_STREAM_RESET_OUTGOING_SSN	0x0002
+#define SCTP_STREAM_RESET_DENIED	0x0004
+#define SCTP_STREAM_RESET_FAILED	0x0008
+struct sctp_stream_reset_event {
+	uint16_t strreset_type;
+	uint16_t strreset_flags;
+	uint32_t strreset_length;
+	sctp_assoc_t strreset_assoc_id;
+	uint16_t strreset_stream_list[];
+};
+
 /*
  * Described in Section 7.3
  *   Ancillary Data and Notification Interest Options
  */
 struct sctp_event_subscribe {
-	__u8 sctp_data_io_event;
-	__u8 sctp_association_event;
-	__u8 sctp_address_event;
-	__u8 sctp_send_failure_event;
-	__u8 sctp_peer_error_event;
-	__u8 sctp_shutdown_event;
-	__u8 sctp_partial_delivery_event;
-	__u8 sctp_adaptation_layer_event;
-	__u8 sctp_authentication_event;
-	__u8 sctp_sender_dry_event;
+	uint8_t sctp_data_io_event;
+	uint8_t sctp_association_event;
+	uint8_t sctp_address_event;
+	uint8_t sctp_send_failure_event;
+	uint8_t sctp_peer_error_event;
+	uint8_t sctp_shutdown_event;
+	uint8_t sctp_partial_delivery_event;
+	uint8_t sctp_adaptation_layer_event;
+	uint8_t sctp_authentication_event;
+	uint8_t sctp_sender_dry_event;
+	uint8_t sctp_stream_reset_event;
 };
 
 /*
@@ -530,6 +543,7 @@ union sctp_notification {
 	struct sctp_pdapi_event sn_pdapi_event;
 	struct sctp_authkey_event sn_authkey_event;
 	struct sctp_sender_dry_event sn_sender_dry_event;
+	struct sctp_stream_reset_event sn_strreset_event;
 };
 
 /* Section 5.3.1
@@ -557,6 +571,8 @@ enum sctp_sn_type {
 #define SCTP_AUTHENTICATION_INDICATION	SCTP_AUTHENTICATION_EVENT
 	SCTP_SENDER_DRY_EVENT,
 #define SCTP_SENDER_DRY_EVENT		SCTP_SENDER_DRY_EVENT
+	SCTP_STREAM_RESET_EVENT,
+#define SCTP_STREAM_RESET_EVENT		SCTP_STREAM_RESET_EVENT
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index bea0005..490d573 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -854,6 +854,36 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 	return event;
 }
 
+struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
+	const struct sctp_association *asoc, __u16 flags, __u16 stream_num,
+	__u16 *stream_list, gfp_t gfp)
+{
+	struct sctp_stream_reset_event *sreset;
+	struct sctp_ulpevent *event;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_stream_reset_event) +
+				  2 * stream_num, MSG_NOTIFICATION, gfp);
+	if (!event)
+		return NULL;
+
+	skb = sctp_event2skb(event);
+	sreset = (struct sctp_stream_reset_event *)skb_put(skb,
+		sizeof(struct sctp_stream_reset_event) + 2 * stream_num);
+
+	sreset->strreset_type = SCTP_STREAM_RESET_EVENT;
+	sreset->strreset_flags = flags;
+	sreset->strreset_length = sizeof(struct sctp_stream_reset_event);
+	sctp_ulpevent_set_owner(event, asoc);
+	sreset->strreset_assoc_id = sctp_assoc2id(asoc);
+
+	if (stream_num)
+		memcpy(sreset->strreset_stream_list, stream_list,
+		       2 * stream_num);
+
+	return event;
+}
+
 /* Return the notification type, assuming this is a notification
  * event.
  */
-- 
2.1.0
