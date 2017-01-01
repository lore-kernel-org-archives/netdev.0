From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 10/27] sctp: add stream reconf primitive
Date: Sun,  1 Jan 2017 19:20:27 +0800
Message-ID: <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34617 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALWM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:22:12 -0500
In-Reply-To: <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add a primitive based on sctp primitive frame for
sending stream reconf request. It works as the other primitives,
and create a SCTP_CMD_REPLY command to send the request chunk out.

sctp_primitive_RECONF would be the api to send a reconf request
chunk.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  3 ++-
 include/net/sctp/sctp.h      |  2 ++
 include/net/sctp/sm.h        |  1 +
 net/sctp/primitive.c         |  3 +++
 net/sctp/sm_statefuns.c      | 13 +++++++++++++
 net/sctp/sm_statetable.c     | 20 ++++++++++++++++++++
 6 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 8307c86..3567c97 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -114,9 +114,10 @@ typedef enum {
 	SCTP_PRIMITIVE_SEND,
 	SCTP_PRIMITIVE_REQUESTHEARTBEAT,
 	SCTP_PRIMITIVE_ASCONF,
+	SCTP_PRIMITIVE_RECONF,
 } sctp_event_primitive_t;
 
-#define SCTP_EVENT_PRIMITIVE_MAX	SCTP_PRIMITIVE_ASCONF
+#define SCTP_EVENT_PRIMITIVE_MAX	SCTP_PRIMITIVE_RECONF
 #define SCTP_NUM_PRIMITIVE_TYPES	(SCTP_EVENT_PRIMITIVE_MAX + 1)
 
 /* We define here a utility type for manipulating subtypes.
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 598d938..bc0e049 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -141,6 +141,8 @@ int sctp_primitive_ABORT(struct net *, struct sctp_association *, void *arg);
 int sctp_primitive_SEND(struct net *, struct sctp_association *, void *arg);
 int sctp_primitive_REQUESTHEARTBEAT(struct net *, struct sctp_association *, void *arg);
 int sctp_primitive_ASCONF(struct net *, struct sctp_association *, void *arg);
+int sctp_primitive_RECONF(struct net *net, struct sctp_association *asoc,
+			  void *arg);
 
 /*
  * sctp/input.c
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 2ab0a8a..bcca913 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -157,6 +157,7 @@ sctp_state_fn_t sctp_sf_error_shutdown;
 sctp_state_fn_t sctp_sf_ignore_primitive;
 sctp_state_fn_t sctp_sf_do_prm_requestheartbeat;
 sctp_state_fn_t sctp_sf_do_prm_asconf;
+sctp_state_fn_t sctp_sf_do_prm_reconf;
 
 /* Prototypes for other event state functions.  */
 sctp_state_fn_t sctp_sf_do_no_pending_tsn;
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index ab8d9f9..f0553a0 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -211,3 +211,6 @@ DECLARE_PRIMITIVE(REQUESTHEARTBEAT);
 */
 
 DECLARE_PRIMITIVE(ASCONF);
+
+/* RE-CONFIG 5.1 */
+DECLARE_PRIMITIVE(RECONF);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b6828dc..c06b134 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5185,6 +5185,19 @@ sctp_disposition_t sctp_sf_do_prm_asconf(struct net *net,
 	return SCTP_DISPOSITION_CONSUME;
 }
 
+/* RE-CONFIG Section 5.1 RECONF Chunk Procedures */
+sctp_disposition_t sctp_sf_do_prm_reconf(struct net *net,
+					 const struct sctp_endpoint *ep,
+					 const struct sctp_association *asoc,
+					 const sctp_subtype_t type,
+					 void *arg, sctp_cmd_seq_t *commands)
+{
+	struct sctp_chunk *chunk = arg;
+
+	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(chunk));
+	return SCTP_DISPOSITION_CONSUME;
+}
+
 /*
  * Ignore the primitive event
  *
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 3da521a..b5438b4 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -643,6 +643,25 @@ chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
 } /* TYPE_SCTP_PRIMITIVE_ASCONF */
 
+#define TYPE_SCTP_PRIMITIVE_RECONF { \
+	/* SCTP_STATE_CLOSED */ \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
+	/* SCTP_STATE_COOKIE_WAIT */ \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
+	/* SCTP_STATE_COOKIE_ECHOED */ \
+	TYPE_SCTP_FUNC(sctp_sf_error_closed), \
+	/* SCTP_STATE_ESTABLISHED */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_reconf), \
+	/* SCTP_STATE_SHUTDOWN_PENDING */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_reconf), \
+	/* SCTP_STATE_SHUTDOWN_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_reconf), \
+	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_prm_reconf), \
+	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_error_shutdown), \
+} /* TYPE_SCTP_PRIMITIVE_RECONF */
+
 /* The primary index for this table is the primitive type.
  * The secondary index for this table is the state.
  */
@@ -653,6 +672,7 @@ static const sctp_sm_table_entry_t primitive_event_table[SCTP_NUM_PRIMITIVE_TYPE
 	TYPE_SCTP_PRIMITIVE_SEND,
 	TYPE_SCTP_PRIMITIVE_REQUESTHEARTBEAT,
 	TYPE_SCTP_PRIMITIVE_ASCONF,
+	TYPE_SCTP_PRIMITIVE_RECONF,
 };
 
 #define TYPE_SCTP_OTHER_NO_PENDING_TSN  { \
-- 
2.1.0
