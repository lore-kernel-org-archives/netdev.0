From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 08/14] sctp: remove the typedef sctp_cmd_seq_t
Date: Fri, 11 Aug 2017 10:23:52 +0800
Message-ID: <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
 <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33294 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752381AbdHKCZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:10 -0400
In-Reply-To: <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cmd_seq_t, and
replace with struct sctp_cmd_seq in the places where it's
using this typedef.

Note that it doesn't fix many indents although it should,
as sctp_disposition_t's removal would mess them up again.
So better to fix them when removing sctp_disposition_t in
the later patch.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/command.h |  14 +--
 include/net/sctp/sm.h      |   2 +-
 net/sctp/probe.c           |   2 +-
 net/sctp/sm_sideeffect.c   |  54 ++++++------
 net/sctp/sm_statefuns.c    | 216 +++++++++++++++++++++++----------------------
 5 files changed, 145 insertions(+), 143 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 4e9e589..cbf6798 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -110,7 +110,7 @@ typedef enum {
 	SCTP_CMD_LAST
 } sctp_verb_t;
 
-/* How many commands can you put in an sctp_cmd_seq_t?
+/* How many commands can you put in an struct sctp_cmd_seq?
  * This is a rather arbitrary number, ideally derived from a careful
  * analysis of the state functions, but in reality just taken from
  * thin air in the hopes othat we don't trigger a kernel panic.
@@ -201,17 +201,17 @@ struct sctp_cmd {
 	sctp_verb_t verb;
 };
 
-typedef struct {
+struct sctp_cmd_seq {
 	struct sctp_cmd cmds[SCTP_MAX_NUM_COMMANDS];
 	struct sctp_cmd *last_used_slot;
 	struct sctp_cmd *next_cmd;
-} sctp_cmd_seq_t;
+};
 
 
 /* Initialize a block of memory as a command sequence.
  * Return 0 if the initialization fails.
  */
-static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
+static inline int sctp_init_cmd_seq(struct sctp_cmd_seq *seq)
 {
 	/* cmds[] is filled backwards to simplify the overflow BUG() check */
 	seq->last_used_slot = seq->cmds + SCTP_MAX_NUM_COMMANDS;
@@ -220,12 +220,12 @@ static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 }
 
 
-/* Add a command to an sctp_cmd_seq_t.
+/* Add a command to an struct sctp_cmd_seq.
  *
  * Use the SCTP_* constructors defined by SCTP_ARG_CONSTRUCTOR() above
  * to wrap data which goes in the obj argument.
  */
-static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
+static inline void sctp_add_cmd_sf(struct sctp_cmd_seq *seq, sctp_verb_t verb,
 				   sctp_arg_t obj)
 {
 	struct sctp_cmd *cmd = seq->last_used_slot - 1;
@@ -240,7 +240,7 @@ static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
 /* Return the next command structure in an sctp_cmd_seq.
  * Return NULL at the end of the sequence.
  */
-static inline struct sctp_cmd *sctp_next_cmd(sctp_cmd_seq_t *seq)
+static inline struct sctp_cmd *sctp_next_cmd(struct sctp_cmd_seq *seq)
 {
 	if (seq->next_cmd <= seq->last_used_slot)
 		return NULL;
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 1e7651c..9af64b9 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -75,7 +75,7 @@ typedef sctp_disposition_t (sctp_state_fn_t) (struct net *,
 					      const struct sctp_association *,
 					      const union sctp_subtype type,
 					      void *arg,
-					      sctp_cmd_seq_t *);
+					      struct sctp_cmd_seq *);
 typedef void (sctp_timer_event_t) (unsigned long);
 typedef struct {
 	sctp_state_fn_t *fn;
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 43837df..34097a1 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -132,7 +132,7 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
 					    const struct sctp_association *asoc,
 					    const union sctp_subtype type,
 					    void *arg,
-					    sctp_cmd_seq_t *commands)
+					    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 0cb3d5a..6dd5934 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -58,7 +58,7 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 				struct sctp_association *asoc,
 				void *event_arg,
 				sctp_disposition_t status,
-				sctp_cmd_seq_t *commands,
+				struct sctp_cmd_seq *commands,
 				gfp_t gfp);
 static int sctp_side_effects(enum sctp_event event_type,
 			     union sctp_subtype subtype,
@@ -67,7 +67,7 @@ static int sctp_side_effects(enum sctp_event event_type,
 			     struct sctp_association **asoc,
 			     void *event_arg,
 			     sctp_disposition_t status,
-			     sctp_cmd_seq_t *commands,
+			     struct sctp_cmd_seq *commands,
 			     gfp_t gfp);
 
 /********************************************************************
@@ -150,7 +150,7 @@ static void sctp_do_ecn_cwr_work(struct sctp_association *asoc,
 
 /* Generate SACK if necessary.  We call this at the end of a packet.  */
 static int sctp_gen_sack(struct sctp_association *asoc, int force,
-			 sctp_cmd_seq_t *commands)
+			 struct sctp_cmd_seq *commands)
 {
 	__u32 ctsn, max_tsn_seen;
 	struct sctp_chunk *sack;
@@ -506,7 +506,7 @@ sctp_timer_event_t *sctp_timer_events[SCTP_NUM_TIMEOUT_TYPES] = {
  * notification SHOULD be sent to the upper layer.
  *
  */
-static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
+static void sctp_do_8_2_transport_strike(struct sctp_cmd_seq *commands,
 					 struct sctp_association *asoc,
 					 struct sctp_transport *transport,
 					 int is_hb)
@@ -578,7 +578,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 }
 
 /* Worker routine to handle INIT command failure.  */
-static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
+static void sctp_cmd_init_failed(struct sctp_cmd_seq *commands,
 				 struct sctp_association *asoc,
 				 unsigned int error)
 {
@@ -601,7 +601,7 @@ static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
 }
 
 /* Worker routine to handle SCTP_CMD_ASSOC_FAILED.  */
-static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
+static void sctp_cmd_assoc_failed(struct sctp_cmd_seq *commands,
 				  struct sctp_association *asoc,
 				  enum sctp_event event_type,
 				  union sctp_subtype subtype,
@@ -645,7 +645,7 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
  * since all other cases use "temporary" associations and can do all
  * their work in statefuns directly.
  */
-static int sctp_cmd_process_init(sctp_cmd_seq_t *commands,
+static int sctp_cmd_process_init(struct sctp_cmd_seq *commands,
 				 struct sctp_association *asoc,
 				 struct sctp_chunk *chunk,
 				 struct sctp_init_chunk *peer_init,
@@ -667,7 +667,7 @@ static int sctp_cmd_process_init(sctp_cmd_seq_t *commands,
 }
 
 /* Helper function to break out starting up of heartbeat timers.  */
-static void sctp_cmd_hb_timers_start(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_hb_timers_start(struct sctp_cmd_seq *cmds,
 				     struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
@@ -680,7 +680,7 @@ static void sctp_cmd_hb_timers_start(sctp_cmd_seq_t *cmds,
 		sctp_transport_reset_hb_timer(t);
 }
 
-static void sctp_cmd_hb_timers_stop(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_hb_timers_stop(struct sctp_cmd_seq *cmds,
 				    struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
@@ -695,7 +695,7 @@ static void sctp_cmd_hb_timers_stop(sctp_cmd_seq_t *cmds,
 }
 
 /* Helper function to stop any pending T3-RTX timers */
-static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_t3_rtx_timers_stop(struct sctp_cmd_seq *cmds,
 					struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
@@ -709,7 +709,7 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
 
 
 /* Helper function to handle the reception of an HEARTBEAT ACK.  */
-static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_transport_on(struct sctp_cmd_seq *cmds,
 				  struct sctp_association *asoc,
 				  struct sctp_transport *t,
 				  struct sctp_chunk *chunk)
@@ -780,7 +780,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 
 
 /* Helper function to process the process SACK command.  */
-static int sctp_cmd_process_sack(sctp_cmd_seq_t *cmds,
+static int sctp_cmd_process_sack(struct sctp_cmd_seq *cmds,
 				 struct sctp_association *asoc,
 				 struct sctp_chunk *chunk)
 {
@@ -802,7 +802,7 @@ static int sctp_cmd_process_sack(sctp_cmd_seq_t *cmds,
 /* Helper function to set the timeout value for T2-SHUTDOWN timer and to set
  * the transport for a shutdown chunk.
  */
-static void sctp_cmd_setup_t2(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_setup_t2(struct sctp_cmd_seq *cmds,
 			      struct sctp_association *asoc,
 			      struct sctp_chunk *chunk)
 {
@@ -819,7 +819,7 @@ static void sctp_cmd_setup_t2(sctp_cmd_seq_t *cmds,
 	asoc->timeouts[SCTP_EVENT_TIMEOUT_T2_SHUTDOWN] = t->rto;
 }
 
-static void sctp_cmd_assoc_update(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_assoc_update(struct sctp_cmd_seq *cmds,
 				  struct sctp_association *asoc,
 				  struct sctp_association *new)
 {
@@ -842,7 +842,7 @@ static void sctp_cmd_assoc_update(sctp_cmd_seq_t *cmds,
 }
 
 /* Helper function to change the state of an association. */
-static void sctp_cmd_new_state(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_new_state(struct sctp_cmd_seq *cmds,
 			       struct sctp_association *asoc,
 			       enum sctp_state state)
 {
@@ -902,7 +902,7 @@ static void sctp_cmd_new_state(sctp_cmd_seq_t *cmds,
 }
 
 /* Helper function to delete an association. */
-static void sctp_cmd_delete_tcb(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_delete_tcb(struct sctp_cmd_seq *cmds,
 				struct sctp_association *asoc)
 {
 	struct sock *sk = asoc->base.sk;
@@ -924,9 +924,9 @@ static void sctp_cmd_delete_tcb(sctp_cmd_seq_t *cmds,
  * destination address (we use active path instead of primary path just
  * because primary path may be inactive.
  */
-static void sctp_cmd_setup_t4(sctp_cmd_seq_t *cmds,
-				struct sctp_association *asoc,
-				struct sctp_chunk *chunk)
+static void sctp_cmd_setup_t4(struct sctp_cmd_seq *cmds,
+			      struct sctp_association *asoc,
+			      struct sctp_chunk *chunk)
 {
 	struct sctp_transport *t;
 
@@ -936,7 +936,7 @@ static void sctp_cmd_setup_t4(sctp_cmd_seq_t *cmds,
 }
 
 /* Process an incoming Operation Error Chunk. */
-static void sctp_cmd_process_operr(sctp_cmd_seq_t *cmds,
+static void sctp_cmd_process_operr(struct sctp_cmd_seq *cmds,
 				   struct sctp_association *asoc,
 				   struct sctp_chunk *chunk)
 {
@@ -1025,9 +1025,9 @@ static void sctp_cmd_set_sk_err(struct sctp_association *asoc, int error)
 }
 
 /* Helper function to generate an association change event */
-static void sctp_cmd_assoc_change(sctp_cmd_seq_t *commands,
-				 struct sctp_association *asoc,
-				 u8 state)
+static void sctp_cmd_assoc_change(struct sctp_cmd_seq *commands,
+				  struct sctp_association *asoc,
+				  u8 state)
 {
 	struct sctp_ulpevent *ev;
 
@@ -1040,7 +1040,7 @@ static void sctp_cmd_assoc_change(sctp_cmd_seq_t *commands,
 }
 
 /* Helper function to generate an adaptation indication event */
-static void sctp_cmd_adaptation_ind(sctp_cmd_seq_t *commands,
+static void sctp_cmd_adaptation_ind(struct sctp_cmd_seq *commands,
 				    struct sctp_association *asoc)
 {
 	struct sctp_ulpevent *ev;
@@ -1145,7 +1145,7 @@ int sctp_do_sm(struct net *net, enum sctp_event event_type,
 	       struct sctp_endpoint *ep, struct sctp_association *asoc,
 	       void *event_arg, gfp_t gfp)
 {
-	sctp_cmd_seq_t commands;
+	struct sctp_cmd_seq commands;
 	const sctp_sm_table_entry_t *state_fn;
 	sctp_disposition_t status;
 	int error = 0;
@@ -1184,7 +1184,7 @@ static int sctp_side_effects(enum sctp_event event_type,
 			     struct sctp_association **asoc,
 			     void *event_arg,
 			     sctp_disposition_t status,
-			     sctp_cmd_seq_t *commands,
+			     struct sctp_cmd_seq *commands,
 			     gfp_t gfp)
 {
 	int error;
@@ -1270,7 +1270,7 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 				struct sctp_association *asoc,
 				void *event_arg,
 				sctp_disposition_t status,
-				sctp_cmd_seq_t *commands,
+				struct sctp_cmd_seq *commands,
 				gfp_t gfp)
 {
 	struct sock *sk = ep->base.sk;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index af93419..93b6f42 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -67,7 +67,7 @@ static struct sctp_packet *sctp_abort_pkt_new(struct net *net,
 				  size_t paylen);
 static int sctp_eat_data(const struct sctp_association *asoc,
 			 struct sctp_chunk *chunk,
-			 sctp_cmd_seq_t *commands);
+			 struct sctp_cmd_seq *commands);
 static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 					     const struct sctp_association *asoc,
 					     const struct sctp_chunk *chunk);
@@ -75,30 +75,30 @@ static void sctp_send_stale_cookie_err(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
 				       const struct sctp_chunk *chunk,
-				       sctp_cmd_seq_t *commands,
+				       struct sctp_cmd_seq *commands,
 				       struct sctp_chunk *err_chunk);
 static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 						 const struct sctp_endpoint *ep,
 						 const struct sctp_association *asoc,
 						 const union sctp_subtype type,
 						 void *arg,
-						 sctp_cmd_seq_t *commands);
+						 struct sctp_cmd_seq *commands);
 static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 					     const struct sctp_endpoint *ep,
 					     const struct sctp_association *asoc,
 					     const union sctp_subtype type,
 					     void *arg,
-					     sctp_cmd_seq_t *commands);
+					     struct sctp_cmd_seq *commands);
 static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands);
+					struct sctp_cmd_seq *commands);
 static struct sctp_sackhdr *sctp_sm_pull_sack(struct sctp_chunk *chunk);
 
 static sctp_disposition_t sctp_stop_t1_and_abort(struct net *net,
-					   sctp_cmd_seq_t *commands,
+					   struct sctp_cmd_seq *commands,
 					   __be16 error, int sk_err,
 					   const struct sctp_association *asoc,
 					   struct sctp_transport *transport);
@@ -108,7 +108,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     void *arg,
-				     sctp_cmd_seq_t *commands,
+				     struct sctp_cmd_seq *commands,
 				     const __u8 *payload,
 				     const size_t paylen);
 
@@ -118,7 +118,7 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands);
+				     struct sctp_cmd_seq *commands);
 
 static sctp_disposition_t sctp_sf_violation_paramlen(
 				     struct net *net,
@@ -126,7 +126,7 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg, void *ext,
-				     sctp_cmd_seq_t *commands);
+				     struct sctp_cmd_seq *commands);
 
 static sctp_disposition_t sctp_sf_violation_ctsn(
 				     struct net *net,
@@ -134,7 +134,7 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands);
+				     struct sctp_cmd_seq *commands);
 
 static sctp_disposition_t sctp_sf_violation_chunk(
 				     struct net *net,
@@ -142,7 +142,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands);
+				     struct sctp_cmd_seq *commands);
 
 static enum sctp_ierror sctp_sf_authenticate(
 				struct net *net,
@@ -156,7 +156,7 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands);
+					struct sctp_cmd_seq *commands);
 
 /* Small helper function that checks if the chunk length
  * is of the appropriate length.  The 'required_length' argument
@@ -219,7 +219,7 @@ sctp_disposition_t sctp_sf_do_4_C(struct net *net,
 				  const struct sctp_association *asoc,
 				  const union sctp_subtype type,
 				  void *arg,
-				  sctp_cmd_seq_t *commands)
+				  struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ulpevent *ev;
@@ -305,7 +305,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
 	struct sctp_unrecognized_param *unk_param;
@@ -499,7 +499,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 				       const struct sctp_association *asoc,
 				       const union sctp_subtype type,
 				       void *arg,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_init_chunk *initchunk;
@@ -648,7 +648,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 				      const struct sctp_endpoint *ep,
 				      const struct sctp_association *asoc,
 				      const union sctp_subtype type, void *arg,
-				      sctp_cmd_seq_t *commands)
+				      struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_association *new_asoc;
@@ -875,7 +875,7 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
 				      const struct sctp_endpoint *ep,
 				      const struct sctp_association *asoc,
 				      const union sctp_subtype type, void *arg,
-				      sctp_cmd_seq_t *commands)
+				      struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ulpevent *ev;
@@ -953,7 +953,7 @@ static sctp_disposition_t sctp_sf_heartbeat(const struct sctp_endpoint *ep,
 					    const struct sctp_association *asoc,
 					    const union sctp_subtype type,
 					    void *arg,
-					    sctp_cmd_seq_t *commands)
+					    struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = (struct sctp_transport *) arg;
 	struct sctp_chunk *reply;
@@ -979,7 +979,7 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = (struct sctp_transport *) arg;
 
@@ -1026,7 +1026,7 @@ sctp_disposition_t sctp_sf_send_reconf(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
 				       const union sctp_subtype type, void *arg,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = arg;
 
@@ -1078,7 +1078,7 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 				    const struct sctp_association *asoc,
 				    const union sctp_subtype type,
 				    void *arg,
-				    sctp_cmd_seq_t *commands)
+				    struct sctp_cmd_seq *commands)
 {
 	struct sctp_paramhdr *param_hdr;
 	struct sctp_chunk *chunk = arg;
@@ -1153,7 +1153,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_sender_hb_info *hbinfo;
 	struct sctp_chunk *chunk = arg;
@@ -1225,7 +1225,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
  */
 static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
 				      struct sctp_chunk *init,
-				      sctp_cmd_seq_t *commands)
+				      struct sctp_cmd_seq *commands)
 {
 	int len;
 	struct sctp_packet *pkt;
@@ -1290,7 +1290,7 @@ static bool list_has_sctp_addr(const struct list_head *list,
 static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 				       const struct sctp_association *asoc,
 				       struct sctp_chunk *init,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	struct net *net = sock_net(new_asoc->base.sk);
 	struct sctp_transport *new_addr;
@@ -1415,7 +1415,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
-	void *arg, sctp_cmd_seq_t *commands)
+	void *arg, struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
 	struct sctp_unrecognized_param *unk_param;
@@ -1627,7 +1627,7 @@ sctp_disposition_t sctp_sf_do_5_2_1_siminit(struct net *net,
 				    const struct sctp_association *asoc,
 				    const union sctp_subtype type,
 				    void *arg,
-				    sctp_cmd_seq_t *commands)
+				    struct sctp_cmd_seq *commands)
 {
 	/* Call helper to do the real work for both simulataneous and
 	 * duplicate INIT chunk handling.
@@ -1681,7 +1681,7 @@ sctp_disposition_t sctp_sf_do_5_2_2_dupinit(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	/* Call helper to do the real work for both simulataneous and
 	 * duplicate INIT chunk handling.
@@ -1703,7 +1703,8 @@ sctp_disposition_t sctp_sf_do_5_2_3_initack(struct net *net,
 					    const struct sctp_endpoint *ep,
 					    const struct sctp_association *asoc,
 					    const union sctp_subtype type,
-					    void *arg, sctp_cmd_seq_t *commands)
+					    void *arg,
+					    struct sctp_cmd_seq *commands)
 {
 	/* Per the above section, we'll discard the chunk if we have an
 	 * endpoint.  If this is an OOTB INIT-ACK, treat it as such.
@@ -1723,7 +1724,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
-					sctp_cmd_seq_t *commands,
+					struct sctp_cmd_seq *commands,
 					struct sctp_association *new_asoc)
 {
 	struct sctp_init_chunk *peer_init;
@@ -1838,7 +1839,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
-					sctp_cmd_seq_t *commands,
+					struct sctp_cmd_seq *commands,
 					struct sctp_association *new_asoc)
 {
 	struct sctp_init_chunk *peer_init;
@@ -1909,7 +1910,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_c(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
-					sctp_cmd_seq_t *commands,
+					struct sctp_cmd_seq *commands,
 					struct sctp_association *new_asoc)
 {
 	/* The cookie should be silently discarded.
@@ -1931,7 +1932,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_d(struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
-					sctp_cmd_seq_t *commands,
+					struct sctp_cmd_seq *commands,
 					struct sctp_association *new_asoc)
 {
 	struct sctp_ulpevent *ev = NULL, *ai_ev = NULL;
@@ -2027,7 +2028,7 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	sctp_disposition_t retval;
 	struct sctp_chunk *chunk = arg;
@@ -2146,7 +2147,7 @@ sctp_disposition_t sctp_sf_shutdown_pending_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -2188,7 +2189,7 @@ sctp_disposition_t sctp_sf_shutdown_sent_abort(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -2239,7 +2240,7 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	/* The same T2 timer, so we should be able to use
 	 * common function with the SHUTDOWN-SENT state.
@@ -2266,7 +2267,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_errhdr *err;
@@ -2330,7 +2331,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 						 const struct sctp_association *asoc,
 						 const union sctp_subtype type,
 						 void *arg,
-						 sctp_cmd_seq_t *commands)
+						 struct sctp_cmd_seq *commands)
 {
 	int attempts = asoc->init_err_counter + 1;
 	struct sctp_chunk *chunk = arg, *reply;
@@ -2452,7 +2453,7 @@ sctp_disposition_t sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -2489,7 +2490,7 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	unsigned int len;
@@ -2527,7 +2528,7 @@ sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	unsigned int len;
@@ -2566,7 +2567,7 @@ sctp_disposition_t sctp_sf_cookie_wait_icmp_abort(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	return sctp_stop_t1_and_abort(net, commands, SCTP_ERROR_NO_ERROR,
 				      ENOPROTOOPT, asoc,
@@ -2581,7 +2582,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_abort(struct net *net,
 					       const struct sctp_association *asoc,
 					       const union sctp_subtype type,
 					       void *arg,
-					       sctp_cmd_seq_t *commands)
+					       struct sctp_cmd_seq *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
 	 * common function with the COOKIE-WAIT state.
@@ -2595,7 +2596,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_abort(struct net *net,
  * This is common code called by several sctp_sf_*_abort() functions above.
  */
 static sctp_disposition_t sctp_stop_t1_and_abort(struct net *net,
-					   sctp_cmd_seq_t *commands,
+					   struct sctp_cmd_seq *commands,
 					   __be16 error, int sk_err,
 					   const struct sctp_association *asoc,
 					   struct sctp_transport *transport)
@@ -2653,7 +2654,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
 					   const struct sctp_association *asoc,
 					   const union sctp_subtype type,
 					   void *arg,
-					   sctp_cmd_seq_t *commands)
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	sctp_disposition_t disposition;
@@ -2742,7 +2743,7 @@ sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
 					   const struct sctp_association *asoc,
 					   const union sctp_subtype type,
 					   void *arg,
-					   sctp_cmd_seq_t *commands)
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_shutdownhdr *sdh;
@@ -2795,7 +2796,7 @@ sctp_disposition_t sctp_sf_do_9_2_reshutack(struct net *net,
 				    const struct sctp_association *asoc,
 				    const union sctp_subtype type,
 				    void *arg,
-				    sctp_cmd_seq_t *commands)
+				    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = (struct sctp_chunk *) arg;
 	struct sctp_chunk *reply;
@@ -2859,7 +2860,7 @@ sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
 				      const struct sctp_association *asoc,
 				      const union sctp_subtype type,
 				      void *arg,
-				      sctp_cmd_seq_t *commands)
+				      struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_cwrhdr *cwr;
@@ -2915,7 +2916,7 @@ sctp_disposition_t sctp_sf_do_ecne(struct net *net,
 				   const struct sctp_association *asoc,
 				   const union sctp_subtype type,
 				   void *arg,
-				   sctp_cmd_seq_t *commands)
+				   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ecnehdr *ecne;
@@ -2972,7 +2973,7 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	sctp_arg_t force = SCTP_NOFORCE();
@@ -3092,7 +3093,7 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	int error;
@@ -3183,7 +3184,7 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_sackhdr *sackh;
@@ -3257,7 +3258,7 @@ static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_packet *packet = NULL;
 	struct sctp_chunk *chunk = arg;
@@ -3307,7 +3308,7 @@ sctp_disposition_t sctp_sf_operr_notify(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_errhdr *err;
@@ -3345,7 +3346,7 @@ sctp_disposition_t sctp_sf_do_9_2_final(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *reply;
@@ -3428,7 +3429,7 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 				const struct sctp_association *asoc,
 				const union sctp_subtype type,
 				void *arg,
-				sctp_cmd_seq_t *commands)
+				struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
@@ -3521,7 +3522,7 @@ static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 					     const struct sctp_association *asoc,
 					     const union sctp_subtype type,
 					     void *arg,
-					     sctp_cmd_seq_t *commands)
+					     struct sctp_cmd_seq *commands)
 {
 	struct sctp_packet *packet = NULL;
 	struct sctp_chunk *chunk = arg;
@@ -3583,7 +3584,7 @@ sctp_disposition_t sctp_sf_do_8_5_1_E_sa(struct net *net,
 				      const struct sctp_association *asoc,
 				      const union sctp_subtype type,
 				      void *arg,
-				      sctp_cmd_seq_t *commands)
+				      struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -3607,7 +3608,7 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type, void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk	*chunk = arg;
 	struct sctp_chunk	*asconf_ack = NULL;
@@ -3725,7 +3726,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 					 const struct sctp_association *asoc,
 					 const union sctp_subtype type,
 					 void *arg,
-					 sctp_cmd_seq_t *commands)
+					 struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk	*asconf_ack = arg;
 	struct sctp_chunk	*last_asconf = asoc->addip_last_asconf;
@@ -3843,7 +3844,7 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type, void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_paramhdr *err_param = NULL;
 	struct sctp_chunk *chunk = arg;
@@ -3920,7 +3921,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
 				       const struct sctp_association *asoc,
 				       const union sctp_subtype type,
 				       void *arg,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_hdr *fwdtsn_hdr;
@@ -3991,7 +3992,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_hdr *fwdtsn_hdr;
@@ -4158,7 +4159,7 @@ sctp_disposition_t sctp_sf_eat_auth(struct net *net,
 				    const struct sctp_association *asoc,
 				    const union sctp_subtype type,
 				    void *arg,
-				    sctp_cmd_seq_t *commands)
+				    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_authhdr *auth_hdr;
@@ -4255,7 +4256,7 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *unk_chunk = arg;
 	struct sctp_chunk *err_chunk;
@@ -4335,7 +4336,7 @@ sctp_disposition_t sctp_sf_discard_chunk(struct net *net,
 					 const struct sctp_association *asoc,
 					 const union sctp_subtype type,
 					 void *arg,
-					 sctp_cmd_seq_t *commands)
+					 struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -4375,7 +4376,7 @@ sctp_disposition_t sctp_sf_pdiscard(struct net *net,
 				    const struct sctp_association *asoc,
 				    const union sctp_subtype type,
 				    void *arg,
-				    sctp_cmd_seq_t *commands)
+				    struct sctp_cmd_seq *commands)
 {
 	SCTP_INC_STATS(net, SCTP_MIB_IN_PKT_DISCARDS);
 	sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
@@ -4403,7 +4404,7 @@ sctp_disposition_t sctp_sf_violation(struct net *net,
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -4423,7 +4424,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
 				     const struct sctp_endpoint *ep,
 				     const struct sctp_association *asoc,
 				     void *arg,
-				     sctp_cmd_seq_t *commands,
+				     struct sctp_cmd_seq *commands,
 				     const __u8 *payload,
 				     const size_t paylen)
 {
@@ -4541,7 +4542,7 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	static const char err_str[] = "The following chunk had invalid length:";
 
@@ -4561,7 +4562,7 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg, void *ext,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk =  arg;
 	struct sctp_paramhdr *param = ext;
@@ -4604,7 +4605,7 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	static const char err_str[] = "The cumulative tsn ack beyond the max tsn currently sent:";
 
@@ -4624,7 +4625,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     const struct sctp_association *asoc,
 				     const union sctp_subtype type,
 				     void *arg,
-				     sctp_cmd_seq_t *commands)
+				     struct sctp_cmd_seq *commands)
 {
 	static const char err_str[] = "The following chunk violates protocol:";
 
@@ -4699,7 +4700,7 @@ sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
 				       const struct sctp_association *asoc,
 				       const union sctp_subtype type,
 				       void *arg,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *repl;
 	struct sctp_association *my_asoc;
@@ -4811,7 +4812,7 @@ sctp_disposition_t sctp_sf_do_prm_send(struct net *net,
 				       const struct sctp_association *asoc,
 				       const union sctp_subtype type,
 				       void *arg,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	struct sctp_datamsg *msg = arg;
 
@@ -4851,7 +4852,7 @@ sctp_disposition_t sctp_sf_do_9_2_prm_shutdown(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	int disposition;
 
@@ -4907,7 +4908,7 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	/* From 9.1 Abort of an Association
 	 * Upon receipt of the ABORT primitive from its upper
@@ -4944,7 +4945,7 @@ sctp_disposition_t sctp_sf_error_closed(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_ERROR, SCTP_ERROR(-EINVAL));
 	return SCTP_DISPOSITION_CONSUME;
@@ -4958,7 +4959,7 @@ sctp_disposition_t sctp_sf_error_shutdown(struct net *net,
 					  const struct sctp_association *asoc,
 					  const union sctp_subtype type,
 					  void *arg,
-					  sctp_cmd_seq_t *commands)
+					  struct sctp_cmd_seq *commands)
 {
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_ERROR,
 			SCTP_ERROR(-ESHUTDOWN));
@@ -4985,7 +4986,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_shutdown(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
@@ -5019,7 +5020,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_prm_shutdown(
 	const struct sctp_endpoint *ep,
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
-	void *arg, sctp_cmd_seq_t *commands)
+	void *arg, struct sctp_cmd_seq *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
 	 * common function with the COOKIE-WAIT state.
@@ -5047,7 +5048,7 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *abort = arg;
 
@@ -5096,7 +5097,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_prm_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
 	 * common function with the COOKIE-WAIT state.
@@ -5122,7 +5123,7 @@ sctp_disposition_t sctp_sf_shutdown_pending_prm_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	/* Stop the T5-shutdown guard timer.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
@@ -5149,7 +5150,7 @@ sctp_disposition_t sctp_sf_shutdown_sent_prm_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	/* Stop the T2-shutdown timer.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
@@ -5180,7 +5181,7 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_prm_abort(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	/* The same T2 timer, so we should be able to use
 	 * common function with the SHUTDOWN-SENT state.
@@ -5216,7 +5217,7 @@ sctp_disposition_t sctp_sf_do_prm_requestheartbeat(
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	if (SCTP_DISPOSITION_NOMEM == sctp_sf_heartbeat(ep, asoc, type,
 				      (struct sctp_transport *)arg, commands))
@@ -5248,7 +5249,7 @@ sctp_disposition_t sctp_sf_do_prm_asconf(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -5264,7 +5265,8 @@ sctp_disposition_t sctp_sf_do_prm_reconf(struct net *net,
 					 const struct sctp_endpoint *ep,
 					 const struct sctp_association *asoc,
 					 const union sctp_subtype type,
-					 void *arg, sctp_cmd_seq_t *commands)
+					 void *arg,
+					 struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -5283,7 +5285,7 @@ sctp_disposition_t sctp_sf_ignore_primitive(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	pr_debug("%s: primitive type:%d is ignored\n", __func__,
 		 type.primitive);
@@ -5307,7 +5309,7 @@ sctp_disposition_t sctp_sf_do_no_pending_tsn(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_ulpevent *event;
 
@@ -5339,7 +5341,7 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *reply;
 
@@ -5409,7 +5411,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = (struct sctp_chunk *) arg;
 	struct sctp_chunk *reply;
@@ -5482,7 +5484,7 @@ sctp_disposition_t sctp_sf_ignore_other(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	pr_debug("%s: the event other type:%d is ignored\n",
 		 __func__, type.other);
@@ -5510,7 +5512,7 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = arg;
 
@@ -5598,7 +5600,7 @@ sctp_disposition_t sctp_sf_do_6_2_sack(struct net *net,
 				       const struct sctp_association *asoc,
 				       const union sctp_subtype type,
 				       void *arg,
-				       sctp_cmd_seq_t *commands)
+				       struct sctp_cmd_seq *commands)
 {
 	SCTP_INC_STATS(net, SCTP_MIB_DELAY_SACK_EXPIREDS);
 	sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, SCTP_FORCE());
@@ -5629,7 +5631,7 @@ sctp_disposition_t sctp_sf_t1_init_timer_expire(struct net *net,
 					   const struct sctp_association *asoc,
 					   const union sctp_subtype type,
 					   void *arg,
-					   sctp_cmd_seq_t *commands)
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *repl = NULL;
 	struct sctp_bind_addr *bp;
@@ -5693,7 +5695,7 @@ sctp_disposition_t sctp_sf_t1_cookie_timer_expire(struct net *net,
 					   const struct sctp_association *asoc,
 					   const union sctp_subtype type,
 					   void *arg,
-					   sctp_cmd_seq_t *commands)
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *repl = NULL;
 	int attempts = asoc->init_err_counter + 1;
@@ -5743,7 +5745,7 @@ sctp_disposition_t sctp_sf_t2_timer_expire(struct net *net,
 					   const struct sctp_association *asoc,
 					   const union sctp_subtype type,
 					   void *arg,
-					   sctp_cmd_seq_t *commands)
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *reply = NULL;
 
@@ -5814,7 +5816,7 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = asoc->addip_last_asconf;
 	struct sctp_transport *transport = chunk->transport;
@@ -5885,7 +5887,7 @@ sctp_disposition_t sctp_sf_t5_timer_expire(struct net *net,
 					   const struct sctp_association *asoc,
 					   const union sctp_subtype type,
 					   void *arg,
-					   sctp_cmd_seq_t *commands)
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *reply = NULL;
 
@@ -5922,7 +5924,7 @@ sctp_disposition_t sctp_sf_autoclose_timer_expire(
 	const struct sctp_association *asoc,
 	const union sctp_subtype type,
 	void *arg,
-	sctp_cmd_seq_t *commands)
+	struct sctp_cmd_seq *commands)
 {
 	int disposition;
 
@@ -5964,7 +5966,7 @@ sctp_disposition_t sctp_sf_not_impl(struct net *net,
 				    const struct sctp_association *asoc,
 				    const union sctp_subtype type,
 				    void *arg,
-				    sctp_cmd_seq_t *commands)
+				    struct sctp_cmd_seq *commands)
 {
 	return SCTP_DISPOSITION_NOT_IMPL;
 }
@@ -5982,7 +5984,7 @@ sctp_disposition_t sctp_sf_bug(struct net *net,
 			       const struct sctp_association *asoc,
 			       const union sctp_subtype type,
 			       void *arg,
-			       sctp_cmd_seq_t *commands)
+			       struct sctp_cmd_seq *commands)
 {
 	return SCTP_DISPOSITION_BUG;
 }
@@ -6003,7 +6005,7 @@ sctp_disposition_t sctp_sf_timer_ignore(struct net *net,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
-					sctp_cmd_seq_t *commands)
+					struct sctp_cmd_seq *commands)
 {
 	pr_debug("%s: timer %d ignored\n", __func__, type.chunk);
 
@@ -6169,7 +6171,7 @@ static void sctp_send_stale_cookie_err(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
 				       const struct sctp_chunk *chunk,
-				       sctp_cmd_seq_t *commands,
+				       struct sctp_cmd_seq *commands,
 				       struct sctp_chunk *err_chunk)
 {
 	struct sctp_packet *packet;
@@ -6198,7 +6200,7 @@ static void sctp_send_stale_cookie_err(struct net *net,
 /* Process a data chunk */
 static int sctp_eat_data(const struct sctp_association *asoc,
 			 struct sctp_chunk *chunk,
-			 sctp_cmd_seq_t *commands)
+			 struct sctp_cmd_seq *commands)
 {
 	struct sctp_datahdr *data_hdr;
 	struct sctp_chunk *err;
-- 
2.1.0
