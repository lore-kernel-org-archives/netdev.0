From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 7/7] sctp: add reconf chunk event
Date: Fri, 17 Feb 2017 12:45:43 +0800
Message-ID: <5ba2cf6d699a77d6eadd75496d955402bd3c2d2d.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
 <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
 <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
 <07abdfdccbb39c94418b7a7887e82c5c12adf0c7.1487306585.git.lucien.xin@gmail.com>
 <3b70615422bf6d43013332d4b37c70160a0c1d32.1487306585.git.lucien.xin@gmail.com>
 <c90e5eac92a42c0d9ab69f7362fc6debf5512bad.1487306585.git.lucien.xin@gmail.com>
 <c226e65af5c013263d702ee4ee3fb1a7c6cac32f.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35135 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbdBQEqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:49 -0500
In-Reply-To: <c226e65af5c013263d702ee4ee3fb1a7c6cac32f.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add reconf chunk event based on the sctp event
frame in rx path, it will call sctp_sf_do_reconf to process the
reconf chunk.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  3 +++
 net/sctp/sm_statetable.c     | 30 ++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 3567c97..b07a745 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -60,11 +60,14 @@ enum { SCTP_DEFAULT_INSTREAMS = SCTP_MAX_STREAM };
 
 #define SCTP_NUM_PRSCTP_CHUNK_TYPES	1
 
+#define SCTP_NUM_RECONF_CHUNK_TYPES	1
+
 #define SCTP_NUM_AUTH_CHUNK_TYPES	1
 
 #define SCTP_NUM_CHUNK_TYPES		(SCTP_NUM_BASE_CHUNK_TYPES + \
 					 SCTP_NUM_ADDIP_CHUNK_TYPES +\
 					 SCTP_NUM_PRSCTP_CHUNK_TYPES +\
+					 SCTP_NUM_RECONF_CHUNK_TYPES +\
 					 SCTP_NUM_AUTH_CHUNK_TYPES)
 
 /* These are the different flavours of event.  */
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index b5438b4..419b18e 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -482,6 +482,32 @@ static const sctp_sm_table_entry_t prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUN
 	TYPE_SCTP_FWD_TSN,
 }; /*state_fn_t prsctp_chunk_event_table[][] */
 
+#define TYPE_SCTP_RECONF { \
+	/* SCTP_STATE_CLOSED */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_COOKIE_WAIT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_COOKIE_ECHOED */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_ESTABLISHED */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_reconf), \
+	/* SCTP_STATE_SHUTDOWN_PENDING */ \
+	TYPE_SCTP_FUNC(sctp_sf_do_reconf), \
+	/* SCTP_STATE_SHUTDOWN_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+} /* TYPE_SCTP_RECONF */
+
+/* The primary index for this table is the chunk type.
+ * The secondary index for this table is the state.
+ */
+static const sctp_sm_table_entry_t reconf_chunk_event_table[SCTP_NUM_RECONF_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+	TYPE_SCTP_RECONF,
+}; /*state_fn_t reconf_chunk_event_table[][] */
+
 #define TYPE_SCTP_AUTH { \
 	/* SCTP_STATE_CLOSED */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
@@ -964,6 +990,10 @@ static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(struct net *net,
 			return &addip_chunk_event_table[1][state];
 	}
 
+	if (net->sctp.reconf_enable)
+		if (cid == SCTP_CID_RECONF)
+			return &reconf_chunk_event_table[0][state];
+
 	if (net->sctp.auth_enable) {
 		if (cid == SCTP_CID_AUTH)
 			return &auth_chunk_event_table[0][state];
-- 
2.1.0
