From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 3/3] sctp: implement event notification SCTP_SENDER_DRY_EVENT
Date: Mon, 18 Apr 2011 11:29:03 +0800
Message-ID: <4DABAFFF.6010204@cn.fujitsu.com>
References: <4DABAEF1.1010506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49443 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab1DRD3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:29:04 -0400
In-Reply-To: <4DABAEF1.1010506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implement event notification SCTP_SENDER_DRY_EVENT.
SCTP Socket API Extensions:

  6.1.9. SCTP_SENDER_DRY_EVENT

  When the SCTP stack has no more user data to send or retransmit, this
  notification is given to the user. Also, at the time when a user app
  subscribes to this event, if there is no data to be sent or
  retransmit, the stack will immediately send up this notification.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/sm.h       |    1 +
 include/net/sctp/ulpevent.h |    3 +++
 include/net/sctp/user.h     |   17 +++++++++++++++++
 net/sctp/sm_statefuns.c     |   24 ++++++++++++++++++++++++
 net/sctp/sm_statetable.c    |    2 +-
 net/sctp/ulpevent.c         |   28 ++++++++++++++++++++++++++++
 6 files changed, 74 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 9352d12..49db0c7 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -165,6 +165,7 @@ sctp_state_fn_t sctp_sf_do_prm_requestheartbeat;
 sctp_state_fn_t sctp_sf_do_prm_asconf;
 
 /* Prototypes for other event state functions.  */
+sctp_state_fn_t sctp_sf_do_no_pending_tsn;
 sctp_state_fn_t sctp_sf_do_9_2_start_shutdown;
 sctp_state_fn_t sctp_sf_do_9_2_shutdown_ack;
 sctp_state_fn_t sctp_sf_ignore_other;
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 7ea12e8..99b027b 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -132,6 +132,9 @@ struct sctp_ulpevent *sctp_ulpevent_make_authkey(
 	const struct sctp_association *asoc, __u16 key_id,
 	__u32 indication, gfp_t gfp);
 
+struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
+	const struct sctp_association *asoc, gfp_t gfp);
+
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 	struct msghdr *);
 __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event);
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 4525d8c..32fd512 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -354,6 +354,20 @@ struct sctp_authkey_event {
 
 enum { SCTP_AUTH_NEWKEY = 0, };
 
+/*
+ * 6.1.9. SCTP_SENDER_DRY_EVENT
+ *
+ * When the SCTP stack has no more user data to send or retransmit, this
+ * notification is given to the user. Also, at the time when a user app
+ * subscribes to this event, if there is no data to be sent or
+ * retransmit, the stack will immediately send up this notification.
+ */
+struct sctp_sender_dry_event {
+	__u16 sender_dry_type;
+	__u16 sender_dry_flags;
+	__u32 sender_dry_length;
+	sctp_assoc_t sender_dry_assoc_id;
+};
 
 /*
  * Described in Section 7.3
@@ -369,6 +383,7 @@ struct sctp_event_subscribe {
 	__u8 sctp_partial_delivery_event;
 	__u8 sctp_adaptation_layer_event;
 	__u8 sctp_authentication_event;
+	__u8 sctp_sender_dry_event;
 };
 
 /*
@@ -392,6 +407,7 @@ union sctp_notification {
 	struct sctp_adaptation_event sn_adaptation_event;
 	struct sctp_pdapi_event sn_pdapi_event;
 	struct sctp_authkey_event sn_authkey_event;
+	struct sctp_sender_dry_event sn_sender_dry_event;
 };
 
 /* Section 5.3.1
@@ -410,6 +426,7 @@ enum sctp_sn_type {
 	SCTP_ADAPTATION_INDICATION,
 	SCTP_AUTHENTICATION_EVENT,
 #define SCTP_AUTHENTICATION_INDICATION	SCTP_AUTHENTICATION_EVENT
+	SCTP_SENDER_DRY_EVENT,
 };
 
 /* Notification error codes used to fill up the error fields in some
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7679208..95257b2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5056,6 +5056,30 @@ sctp_disposition_t sctp_sf_ignore_primitive(
  ***************************************************************************/
 
 /*
+ * When the SCTP stack has no more user data to send or retransmit, this
+ * notification is given to the user. Also, at the time when a user app
+ * subscribes to this event, if there is no data to be sent or
+ * retransmit, the stack will immediately send up this notification.
+ */
+sctp_disposition_t sctp_sf_do_no_pending_tsn(
+	const struct sctp_endpoint *ep,
+	const struct sctp_association *asoc,
+	const sctp_subtype_t type,
+	void *arg,
+	sctp_cmd_seq_t *commands)
+{
+	struct sctp_ulpevent *event;
+
+	event = sctp_ulpevent_make_sender_dry_event(asoc, GFP_ATOMIC);
+	if (!event)
+		return SCTP_DISPOSITION_NOMEM;
+
+	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(event));
+
+	return SCTP_DISPOSITION_CONSUME;
+}
+
+/*
  * Start the shutdown negotiation.
  *
  * From Section 9.2:
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 546d438..382fa40 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -722,7 +722,7 @@ static const sctp_sm_table_entry_t primitive_event_table[SCTP_NUM_PRIMITIVE_TYPE
 	/* SCTP_STATE_COOKIE_ECHOED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
 	/* SCTP_STATE_ESTABLISHED */ \
-	TYPE_SCTP_FUNC(sctp_sf_ignore_other), \
+	TYPE_SCTP_FUNC(sctp_sf_do_no_pending_tsn), \
 	/* SCTP_STATE_SHUTDOWN_PENDING */ \
 	TYPE_SCTP_FUNC(sctp_sf_do_9_2_start_shutdown), \
 	/* SCTP_STATE_SHUTDOWN_SENT */ \
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 62d4a7b..c962c60 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -862,6 +862,34 @@ fail:
 	return NULL;
 }
 
+/*
+ * Socket Extensions for SCTP
+ * 6.3.10. SCTP_SENDER_DRY_EVENT
+ */
+struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
+	const struct sctp_association *asoc, gfp_t gfp)
+{
+	struct sctp_ulpevent *event;
+	struct sctp_sender_dry_event *sdry;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_sender_dry_event),
+				  MSG_NOTIFICATION, gfp);
+	if (!event)
+		return NULL;
+
+	skb = sctp_event2skb(event);
+	sdry = (struct sctp_sender_dry_event *)
+		skb_put(skb, sizeof(struct sctp_sender_dry_event));
+
+	sdry->sender_dry_type = SCTP_SENDER_DRY_EVENT;
+	sdry->sender_dry_flags = 0;
+	sdry->sender_dry_length = sizeof(struct sctp_sender_dry_event);
+	sctp_ulpevent_set_owner(event, asoc);
+	sdry->sender_dry_assoc_id = sctp_assoc2id(asoc);
+
+	return event;
+}
 
 /* Return the notification type, assuming this is a notification
  * event.
-- 
1.6.5.2


