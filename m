From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 13/14] sctp: remove the typedef sctp_disposition_t
Date: Fri, 11 Aug 2017 10:23:57 +0800
Message-ID: <aba19eb36546ed6eaacf4efc264f1e1b209d7a7e.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
 <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
 <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
 <8a912c943fa40c635ac0dba8726c7e744031a446.1502417340.git.lucien.xin@gmail.com>
 <712be5d964dee4d7918781d7399ad564f2309259.1502417340.git.lucien.xin@gmail.com>
 <6ff85867e2eb2776e2dbec9a0140911dcaec3e18.1502417340.git.lucien.xin@gmail.com>
 <55bc9dd4073fded0138ef8074f092fb7ba148356.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35540 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdHKCZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:53 -0400
In-Reply-To: <55bc9dd4073fded0138ef8074f092fb7ba148356.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_disposition_t, and
replace with enum sctp_disposition in the places where it's
using this typedef.

It's also to fix the indent for many functions' defination.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h    |   19 +-
 net/sctp/probe.c         |   13 +-
 net/sctp/sm_sideeffect.c |   50 +-
 net/sctp/sm_statefuns.c  | 1316 ++++++++++++++++++++++++----------------------
 4 files changed, 717 insertions(+), 681 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 7ad2402..33077f3 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -53,7 +53,7 @@
 /*
  * Possible values for the disposition are:
  */
-typedef enum {
+enum sctp_disposition {
 	SCTP_DISPOSITION_DISCARD,	 /* No further processing.  */
 	SCTP_DISPOSITION_CONSUME,	 /* Process return values normally.  */
 	SCTP_DISPOSITION_NOMEM,		 /* We ran out of memory--recover.  */
@@ -63,14 +63,15 @@ typedef enum {
 	SCTP_DISPOSITION_NOT_IMPL,	 /* This entry is not implemented.  */
 	SCTP_DISPOSITION_ERROR,		 /* This is plain old user error.  */
 	SCTP_DISPOSITION_BUG,		 /* This is a bug.  */
-} sctp_disposition_t;
-
-typedef sctp_disposition_t (sctp_state_fn_t) (struct net *,
-					      const struct sctp_endpoint *,
-					      const struct sctp_association *,
-					      const union sctp_subtype type,
-					      void *arg,
-					      struct sctp_cmd_seq *);
+};
+
+typedef enum sctp_disposition (sctp_state_fn_t) (
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands);
 typedef void (sctp_timer_event_t) (unsigned long);
 struct sctp_sm_table_entry {
 	sctp_state_fn_t *fn;
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 34097a1..1280f85 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -127,12 +127,13 @@ static const struct file_operations sctpprobe_fops = {
 	.llseek = noop_llseek,
 };
 
-static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
-					    const struct sctp_endpoint *ep,
-					    const struct sctp_association *asoc,
-					    const union sctp_subtype type,
-					    void *arg,
-					    struct sctp_cmd_seq *commands)
+static enum sctp_disposition jsctp_sf_eat_sack(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 2bc1204..e6a2974 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -57,7 +57,7 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 				struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
 				void *event_arg,
-				sctp_disposition_t status,
+				enum sctp_disposition status,
 				struct sctp_cmd_seq *commands,
 				gfp_t gfp);
 static int sctp_side_effects(enum sctp_event event_type,
@@ -66,7 +66,7 @@ static int sctp_side_effects(enum sctp_event event_type,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
 			     void *event_arg,
-			     sctp_disposition_t status,
+			     enum sctp_disposition status,
 			     struct sctp_cmd_seq *commands,
 			     gfp_t gfp);
 
@@ -97,8 +97,8 @@ static void sctp_do_ecn_ce_work(struct sctp_association *asoc,
  * that was originally marked with the CE bit.
  */
 static struct sctp_chunk *sctp_do_ecn_ecne_work(struct sctp_association *asoc,
-					   __u32 lowest_tsn,
-					   struct sctp_chunk *chunk)
+						__u32 lowest_tsn,
+						struct sctp_chunk *chunk)
 {
 	struct sctp_chunk *repl;
 
@@ -152,9 +152,9 @@ static void sctp_do_ecn_cwr_work(struct sctp_association *asoc,
 static int sctp_gen_sack(struct sctp_association *asoc, int force,
 			 struct sctp_cmd_seq *commands)
 {
+	struct sctp_transport *trans = asoc->peer.last_data_from;
 	__u32 ctsn, max_tsn_seen;
 	struct sctp_chunk *sack;
-	struct sctp_transport *trans = asoc->peer.last_data_from;
 	int error = 0;
 
 	if (force ||
@@ -244,11 +244,11 @@ static int sctp_gen_sack(struct sctp_association *asoc, int force,
  */
 void sctp_generate_t3_rtx_event(unsigned long peer)
 {
-	int error;
 	struct sctp_transport *transport = (struct sctp_transport *) peer;
 	struct sctp_association *asoc = transport->asoc;
 	struct sock *sk = asoc->base.sk;
 	struct net *net = sock_net(sk);
+	int error;
 
 	/* Check whether a task is in the sock.  */
 
@@ -361,12 +361,12 @@ static void sctp_generate_autoclose_event(unsigned long data)
  */
 void sctp_generate_heartbeat_event(unsigned long data)
 {
-	int error = 0;
 	struct sctp_transport *transport = (struct sctp_transport *) data;
 	struct sctp_association *asoc = transport->asoc;
 	struct sock *sk = asoc->base.sk;
 	struct net *net = sock_net(sk);
 	u32 elapsed, timeout;
+	int error = 0;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -406,7 +406,7 @@ void sctp_generate_heartbeat_event(unsigned long data)
  */
 void sctp_generate_proto_unreach_event(unsigned long data)
 {
-	struct sctp_transport *transport = (struct sctp_transport *) data;
+	struct sctp_transport *transport = (struct sctp_transport *)data;
 	struct sctp_association *asoc = transport->asoc;
 	struct sock *sk = asoc->base.sk;
 	struct net *net = sock_net(sk);
@@ -472,7 +472,7 @@ void sctp_generate_reconf_event(unsigned long data)
 /* Inject a SACK Timeout event into the state machine.  */
 static void sctp_generate_sack_event(unsigned long data)
 {
-	struct sctp_association *asoc = (struct sctp_association *) data;
+	struct sctp_association *asoc = (struct sctp_association *)data;
 	sctp_generate_timeout_event(asoc, SCTP_EVENT_TIMEOUT_SACK);
 }
 
@@ -610,6 +610,7 @@ static void sctp_cmd_assoc_failed(struct sctp_cmd_seq *commands,
 {
 	struct sctp_ulpevent *event;
 	struct sctp_chunk *abort;
+
 	/* Cancel any partial delivery in progress. */
 	sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
 
@@ -991,6 +992,7 @@ static void sctp_cmd_process_fwdtsn(struct sctp_ulpq *ulpq,
 				    struct sctp_chunk *chunk)
 {
 	struct sctp_fwdtsn_skip *skip;
+
 	/* Walk through all the skipped SSNs */
 	sctp_walk_fwdtsn(skip, chunk) {
 		sctp_ulpq_skip(ulpq, ntohs(skip->stream), ntohs(skip->ssn));
@@ -1003,8 +1005,8 @@ static void sctp_cmd_process_fwdtsn(struct sctp_ulpq *ulpq,
 static void sctp_cmd_del_non_primary(struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
-	struct list_head *pos;
 	struct list_head *temp;
+	struct list_head *pos;
 
 	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
 		t = list_entry(pos, struct sctp_transport, transports);
@@ -1145,15 +1147,15 @@ int sctp_do_sm(struct net *net, enum sctp_event event_type,
 	       struct sctp_endpoint *ep, struct sctp_association *asoc,
 	       void *event_arg, gfp_t gfp)
 {
-	struct sctp_cmd_seq commands;
-	const struct sctp_sm_table_entry *state_fn;
-	sctp_disposition_t status;
-	int error = 0;
 	typedef const char *(printfn_t)(union sctp_subtype);
 	static printfn_t *table[] = {
 		NULL, sctp_cname, sctp_tname, sctp_oname, sctp_pname,
 	};
 	printfn_t *debug_fn  __attribute__ ((unused)) = table[event_type];
+	const struct sctp_sm_table_entry *state_fn;
+	struct sctp_cmd_seq commands;
+	enum sctp_disposition status;
+	int error = 0;
 
 	/* Look up the state function, run it, and then process the
 	 * side effects.  These three steps are the heart of lksctp.
@@ -1183,7 +1185,7 @@ static int sctp_side_effects(enum sctp_event event_type,
 			     struct sctp_endpoint *ep,
 			     struct sctp_association **asoc,
 			     void *event_arg,
-			     sctp_disposition_t status,
+			     enum sctp_disposition status,
 			     struct sctp_cmd_seq *commands,
 			     gfp_t gfp)
 {
@@ -1269,23 +1271,21 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 				struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
 				void *event_arg,
-				sctp_disposition_t status,
+				enum sctp_disposition status,
 				struct sctp_cmd_seq *commands,
 				gfp_t gfp)
 {
-	struct sock *sk = ep->base.sk;
-	struct sctp_sock *sp = sctp_sk(sk);
-	int error = 0;
-	int force;
-	struct sctp_cmd *cmd;
-	struct sctp_chunk *new_obj;
-	struct sctp_chunk *chunk = NULL;
+	struct sctp_sock *sp = sctp_sk(ep->base.sk);
+	struct sctp_chunk *chunk = NULL, *new_obj;
 	struct sctp_packet *packet;
+	struct sctp_sackhdr sackh;
 	struct timer_list *timer;
-	unsigned long timeout;
 	struct sctp_transport *t;
-	struct sctp_sackhdr sackh;
+	unsigned long timeout;
+	struct sctp_cmd *cmd;
 	int local_cork = 0;
+	int error = 0;
+	int force;
 
 	if (SCTP_EVENT_T_TIMEOUT != event_type)
 		chunk = event_arg;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index adc1dde..8f8ccde 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -59,37 +59,41 @@
 #include <net/sctp/sm.h>
 #include <net/sctp/structs.h>
 
-static struct sctp_packet *sctp_abort_pkt_new(struct net *net,
-				  const struct sctp_endpoint *ep,
-				  const struct sctp_association *asoc,
-				  struct sctp_chunk *chunk,
-				  const void *payload,
-				  size_t paylen);
+static struct sctp_packet *sctp_abort_pkt_new(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					struct sctp_chunk *chunk,
+					const void *payload, size_t paylen);
 static int sctp_eat_data(const struct sctp_association *asoc,
 			 struct sctp_chunk *chunk,
 			 struct sctp_cmd_seq *commands);
-static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
-					     const struct sctp_association *asoc,
-					     const struct sctp_chunk *chunk);
+static struct sctp_packet *sctp_ootb_pkt_new(
+					struct net *net,
+					const struct sctp_association *asoc,
+					const struct sctp_chunk *chunk);
 static void sctp_send_stale_cookie_err(struct net *net,
 				       const struct sctp_endpoint *ep,
 				       const struct sctp_association *asoc,
 				       const struct sctp_chunk *chunk,
 				       struct sctp_cmd_seq *commands,
 				       struct sctp_chunk *err_chunk);
-static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
-						 const struct sctp_endpoint *ep,
-						 const struct sctp_association *asoc,
-						 const union sctp_subtype type,
-						 void *arg,
-						 struct sctp_cmd_seq *commands);
-static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
-					     const struct sctp_endpoint *ep,
-					     const struct sctp_association *asoc,
-					     const union sctp_subtype type,
-					     void *arg,
-					     struct sctp_cmd_seq *commands);
-static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
+static enum sctp_disposition sctp_sf_do_5_2_6_stale(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands);
+static enum sctp_disposition sctp_sf_shut_8_4_5(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands);
+static enum sctp_disposition sctp_sf_tabort_8_4_8(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -97,61 +101,63 @@ static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
 					struct sctp_cmd_seq *commands);
 static struct sctp_sackhdr *sctp_sm_pull_sack(struct sctp_chunk *chunk);
 
-static sctp_disposition_t sctp_stop_t1_and_abort(struct net *net,
-					   struct sctp_cmd_seq *commands,
-					   __be16 error, int sk_err,
-					   const struct sctp_association *asoc,
-					   struct sctp_transport *transport);
+static enum sctp_disposition sctp_stop_t1_and_abort(
+					struct net *net,
+					struct sctp_cmd_seq *commands,
+					__be16 error, int sk_err,
+					const struct sctp_association *asoc,
+					struct sctp_transport *transport);
 
-static sctp_disposition_t sctp_sf_abort_violation(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     void *arg,
-				     struct sctp_cmd_seq *commands,
-				     const __u8 *payload,
-				     const size_t paylen);
+static enum sctp_disposition sctp_sf_abort_violation(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					void *arg,
+					struct sctp_cmd_seq *commands,
+					const __u8 *payload,
+					const size_t paylen);
 
-static sctp_disposition_t sctp_sf_violation_chunklen(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands);
+static enum sctp_disposition sctp_sf_violation_chunklen(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands);
 
-static sctp_disposition_t sctp_sf_violation_paramlen(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg, void *ext,
-				     struct sctp_cmd_seq *commands);
+static enum sctp_disposition sctp_sf_violation_paramlen(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg, void *ext,
+					struct sctp_cmd_seq *commands);
 
-static sctp_disposition_t sctp_sf_violation_ctsn(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands);
+static enum sctp_disposition sctp_sf_violation_ctsn(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands);
 
-static sctp_disposition_t sctp_sf_violation_chunk(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands);
+static enum sctp_disposition sctp_sf_violation_chunk(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands);
 
 static enum sctp_ierror sctp_sf_authenticate(
-				struct net *net,
-				const struct sctp_endpoint *ep,
-				const struct sctp_association *asoc,
-				const union sctp_subtype type,
-				struct sctp_chunk *chunk);
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					struct sctp_chunk *chunk);
 
-static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
+static enum sctp_disposition __sctp_sf_do_9_1_abort(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -165,8 +171,8 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
  * 		   false = Invalid length
  *
  */
-static inline bool
-sctp_chunk_length_valid(struct sctp_chunk *chunk, __u16 required_length)
+static inline bool sctp_chunk_length_valid(struct sctp_chunk *chunk,
+					   __u16 required_length)
 {
 	__u16 chunk_length = ntohs(chunk->chunk_hdr->length);
 
@@ -214,12 +220,11 @@ sctp_chunk_length_valid(struct sctp_chunk *chunk, __u16 required_length)
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_4_C(struct net *net,
-				  const struct sctp_endpoint *ep,
-				  const struct sctp_association *asoc,
-				  const union sctp_subtype type,
-				  void *arg,
-				  struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_4_C(struct net *net,
+				     const struct sctp_endpoint *ep,
+				     const struct sctp_association *asoc,
+				     const union sctp_subtype type,
+				     void *arg, struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ulpevent *ev;
@@ -300,12 +305,12 @@ sctp_disposition_t sctp_sf_do_4_C(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_5_1B_init(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
 	struct sctp_unrecognized_param *unk_param;
@@ -494,15 +499,15 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
-				       const struct sctp_endpoint *ep,
-				       const struct sctp_association *asoc,
-				       const union sctp_subtype type,
-				       void *arg,
-				       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_5_1C_ack(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  const union sctp_subtype type,
+					  void *arg,
+					  struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk = arg;
 	struct sctp_init_chunk *initchunk;
+	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
 
@@ -644,20 +649,21 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
-				      const struct sctp_endpoint *ep,
-				      const struct sctp_association *asoc,
-				      const union sctp_subtype type, void *arg,
-				      struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_5_1D_ce(struct net *net,
+					 const struct sctp_endpoint *ep,
+					 const struct sctp_association *asoc,
+					 const union sctp_subtype type,
+					 void *arg,
+					 struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk = arg;
+	struct sctp_ulpevent *ev, *ai_ev = NULL;
 	struct sctp_association *new_asoc;
 	struct sctp_init_chunk *peer_init;
-	struct sctp_chunk *repl;
-	struct sctp_ulpevent *ev, *ai_ev = NULL;
-	int error = 0;
+	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *err_chk_p;
+	struct sctp_chunk *repl;
 	struct sock *sk;
+	int error = 0;
 
 	/* If the packet is an OOTB packet which is temporarily on the
 	 * control endpoint, respond with an ABORT.
@@ -871,11 +877,12 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
-				      const struct sctp_endpoint *ep,
-				      const struct sctp_association *asoc,
-				      const union sctp_subtype type, void *arg,
-				      struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_5_1E_ca(struct net *net,
+					 const struct sctp_endpoint *ep,
+					 const struct sctp_association *asoc,
+					 const union sctp_subtype type,
+					 void *arg,
+					 struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ulpevent *ev;
@@ -949,11 +956,12 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
 }
 
 /* Generate and sendout a heartbeat packet.  */
-static sctp_disposition_t sctp_sf_heartbeat(const struct sctp_endpoint *ep,
-					    const struct sctp_association *asoc,
-					    const union sctp_subtype type,
-					    void *arg,
-					    struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_heartbeat(
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = (struct sctp_transport *) arg;
 	struct sctp_chunk *reply;
@@ -974,12 +982,12 @@ static sctp_disposition_t sctp_sf_heartbeat(const struct sctp_endpoint *ep,
 }
 
 /* Generate a HEARTBEAT packet on the given transport.  */
-sctp_disposition_t sctp_sf_sendbeat_8_3(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_sendbeat_8_3(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = (struct sctp_transport *) arg;
 
@@ -1022,11 +1030,12 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(struct net *net,
 }
 
 /* resend asoc strreset_chunk.  */
-sctp_disposition_t sctp_sf_send_reconf(struct net *net,
-				       const struct sctp_endpoint *ep,
-				       const struct sctp_association *asoc,
-				       const union sctp_subtype type, void *arg,
-				       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_send_reconf(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  const union sctp_subtype type,
+					  void *arg,
+					  struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = arg;
 
@@ -1073,12 +1082,11 @@ sctp_disposition_t sctp_sf_send_reconf(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const union sctp_subtype type,
-				    void *arg,
-				    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_beat_8_3(struct net *net,
+				       const struct sctp_endpoint *ep,
+				       const struct sctp_association *asoc,
+				       const union sctp_subtype type,
+				       void *arg, struct sctp_cmd_seq *commands)
 {
 	struct sctp_paramhdr *param_hdr;
 	struct sctp_chunk *chunk = arg;
@@ -1148,12 +1156,12 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_backbeat_8_3(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_sender_hb_info *hbinfo;
 	struct sctp_chunk *chunk = arg;
@@ -1227,13 +1235,13 @@ static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
 				      struct sctp_chunk *init,
 				      struct sctp_cmd_seq *commands)
 {
-	int len;
-	struct sctp_packet *pkt;
+	struct sctp_af *af = sctp_get_af_specific(ssa->v4.sin_family);
 	union sctp_addr_param *addrparm;
 	struct sctp_errhdr *errhdr;
-	struct sctp_endpoint *ep;
 	char buffer[sizeof(*errhdr) + sizeof(*addrparm)];
-	struct sctp_af *af = sctp_get_af_specific(ssa->v4.sin_family);
+	struct sctp_endpoint *ep;
+	struct sctp_packet *pkt;
+	int len;
 
 	/* Build the error on the stack.   We are way to malloc crazy
 	 * throughout the code today.
@@ -1410,18 +1418,19 @@ static char sctp_tietags_compare(struct sctp_association *new_asoc,
 /* Common helper routine for both duplicate and simulataneous INIT
  * chunk handling.
  */
-static sctp_disposition_t sctp_sf_do_unexpected_init(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg, struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_do_unexpected_init(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
 	struct sctp_unrecognized_param *unk_param;
 	struct sctp_association *new_asoc;
+	enum sctp_disposition retval;
 	struct sctp_packet *packet;
-	sctp_disposition_t retval;
 	int len;
 
 	/* 6.10 Bundling
@@ -1622,12 +1631,13 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_2_1_siminit(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const union sctp_subtype type,
-				    void *arg,
-				    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_5_2_1_siminit(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* Call helper to do the real work for both simulataneous and
 	 * duplicate INIT chunk handling.
@@ -1676,7 +1686,8 @@ sctp_disposition_t sctp_sf_do_5_2_1_siminit(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_2_2_dupinit(struct net *net,
+enum sctp_disposition sctp_sf_do_5_2_2_dupinit(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -1699,12 +1710,13 @@ sctp_disposition_t sctp_sf_do_5_2_2_dupinit(struct net *net,
  * An unexpected INIT ACK usually indicates the processing of an old or
  * duplicated INIT chunk.
 */
-sctp_disposition_t sctp_sf_do_5_2_3_initack(struct net *net,
-					    const struct sctp_endpoint *ep,
-					    const struct sctp_association *asoc,
-					    const union sctp_subtype type,
-					    void *arg,
-					    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_5_2_3_initack(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* Per the above section, we'll discard the chunk if we have an
 	 * endpoint.  If this is an OOTB INIT-ACK, treat it as such.
@@ -1720,7 +1732,8 @@ sctp_disposition_t sctp_sf_do_5_2_3_initack(struct net *net,
  * Section 5.2.4
  *  A)  In this case, the peer may have restarted.
  */
-static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
+static enum sctp_disposition sctp_sf_do_dupcook_a(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
@@ -1728,10 +1741,10 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
 					struct sctp_association *new_asoc)
 {
 	struct sctp_init_chunk *peer_init;
+	enum sctp_disposition disposition;
 	struct sctp_ulpevent *ev;
 	struct sctp_chunk *repl;
 	struct sctp_chunk *err;
-	sctp_disposition_t disposition;
 
 	/* new_asoc is a brand-new association, so these are not yet
 	 * side effects--it is safe to run them here.
@@ -1835,7 +1848,8 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
  *      after responding to the local endpoint's INIT
  */
 /* This case represents an initialization collision.  */
-static sctp_disposition_t sctp_sf_do_dupcook_b(struct net *net,
+static enum sctp_disposition sctp_sf_do_dupcook_b(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
@@ -1906,7 +1920,8 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(struct net *net,
  *     but a new tag of its own.
  */
 /* This case represents an initialization collision.  */
-static sctp_disposition_t sctp_sf_do_dupcook_c(struct net *net,
+static enum sctp_disposition sctp_sf_do_dupcook_c(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
@@ -1928,7 +1943,8 @@ static sctp_disposition_t sctp_sf_do_dupcook_c(struct net *net,
  *    enter the ESTABLISHED state, if it has not already done so.
  */
 /* This case represents an initialization collision.  */
-static sctp_disposition_t sctp_sf_do_dupcook_d(struct net *net,
+static enum sctp_disposition sctp_sf_do_dupcook_d(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					struct sctp_chunk *chunk,
@@ -2023,19 +2039,20 @@ static sctp_disposition_t sctp_sf_do_dupcook_d(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
+enum sctp_disposition sctp_sf_do_5_2_4_dupcook(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
 					struct sctp_cmd_seq *commands)
 {
-	sctp_disposition_t retval;
-	struct sctp_chunk *chunk = arg;
 	struct sctp_association *new_asoc;
+	struct sctp_chunk *chunk = arg;
+	enum sctp_disposition retval;
+	struct sctp_chunk *err_chk_p;
 	int error = 0;
 	char action;
-	struct sctp_chunk *err_chk_p;
 
 	/* Make sure that the chunk has a valid length from the protocol
 	 * perspective.  In this case check to make sure we have at least
@@ -2141,13 +2158,13 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
  *
  * See sctp_sf_do_9_1_abort().
  */
-sctp_disposition_t sctp_sf_shutdown_pending_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_shutdown_pending_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -2184,7 +2201,8 @@ sctp_disposition_t sctp_sf_shutdown_pending_abort(
  *
  * See sctp_sf_do_9_1_abort().
  */
-sctp_disposition_t sctp_sf_shutdown_sent_abort(struct net *net,
+enum sctp_disposition sctp_sf_shutdown_sent_abort(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -2234,13 +2252,13 @@ sctp_disposition_t sctp_sf_shutdown_sent_abort(struct net *net,
  *
  * See sctp_sf_do_9_1_abort().
  */
-sctp_disposition_t sctp_sf_shutdown_ack_sent_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_shutdown_ack_sent_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* The same T2 timer, so we should be able to use
 	 * common function with the SHUTDOWN-SENT state.
@@ -2262,7 +2280,8 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_abort(
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
+enum sctp_disposition sctp_sf_cookie_echoed_err(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -2326,12 +2345,13 @@ sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
-						 const struct sctp_endpoint *ep,
-						 const struct sctp_association *asoc,
-						 const union sctp_subtype type,
-						 void *arg,
-						 struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_do_5_2_6_stale(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	int attempts = asoc->init_err_counter + 1;
 	struct sctp_chunk *chunk = arg, *reply;
@@ -2448,7 +2468,8 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_9_1_abort(struct net *net,
+enum sctp_disposition sctp_sf_do_9_1_abort(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -2485,16 +2506,17 @@ sctp_disposition_t sctp_sf_do_9_1_abort(struct net *net,
 	return __sctp_sf_do_9_1_abort(net, ep, asoc, type, arg, commands);
 }
 
-static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
+static enum sctp_disposition __sctp_sf_do_9_1_abort(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
 					void *arg,
 					struct sctp_cmd_seq *commands)
 {
+	__be16 error = SCTP_ERROR_NO_ERROR;
 	struct sctp_chunk *chunk = arg;
 	unsigned int len;
-	__be16 error = SCTP_ERROR_NO_ERROR;
 
 	/* See if we have an error cause code in the chunk.  */
 	len = ntohs(chunk->chunk_hdr->length);
@@ -2523,16 +2545,17 @@ static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
  *
  * See sctp_sf_do_9_1_abort() above.
  */
-sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_cookie_wait_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
+	__be16 error = SCTP_ERROR_NO_ERROR;
 	struct sctp_chunk *chunk = arg;
 	unsigned int len;
-	__be16 error = SCTP_ERROR_NO_ERROR;
 
 	if (!sctp_vtag_verify_either(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
@@ -2562,7 +2585,8 @@ sctp_disposition_t sctp_sf_cookie_wait_abort(struct net *net,
 /*
  * Process an incoming ICMP as an ABORT.  (COOKIE-WAIT state)
  */
-sctp_disposition_t sctp_sf_cookie_wait_icmp_abort(struct net *net,
+enum sctp_disposition sctp_sf_cookie_wait_icmp_abort(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -2577,12 +2601,13 @@ sctp_disposition_t sctp_sf_cookie_wait_icmp_abort(struct net *net,
 /*
  * Process an ABORT.  (COOKIE-ECHOED state)
  */
-sctp_disposition_t sctp_sf_cookie_echoed_abort(struct net *net,
-					       const struct sctp_endpoint *ep,
-					       const struct sctp_association *asoc,
-					       const union sctp_subtype type,
-					       void *arg,
-					       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_cookie_echoed_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
 	 * common function with the COOKIE-WAIT state.
@@ -2595,11 +2620,12 @@ sctp_disposition_t sctp_sf_cookie_echoed_abort(struct net *net,
  *
  * This is common code called by several sctp_sf_*_abort() functions above.
  */
-static sctp_disposition_t sctp_stop_t1_and_abort(struct net *net,
-					   struct sctp_cmd_seq *commands,
-					   __be16 error, int sk_err,
-					   const struct sctp_association *asoc,
-					   struct sctp_transport *transport)
+static enum sctp_disposition sctp_stop_t1_and_abort(
+					struct net *net,
+					struct sctp_cmd_seq *commands,
+					__be16 error, int sk_err,
+					const struct sctp_association *asoc,
+					struct sctp_transport *transport)
 {
 	pr_debug("%s: ABORT received (INIT)\n", __func__);
 
@@ -2649,15 +2675,16 @@ static sctp_disposition_t sctp_stop_t1_and_abort(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
-					   const struct sctp_endpoint *ep,
-					   const struct sctp_association *asoc,
-					   const union sctp_subtype type,
-					   void *arg,
-					   struct sctp_cmd_seq *commands)
-{
+enum sctp_disposition sctp_sf_do_9_2_shutdown(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
+{
+	enum sctp_disposition disposition;
 	struct sctp_chunk *chunk = arg;
-	sctp_disposition_t disposition;
 	struct sctp_shutdownhdr *sdh;
 	struct sctp_ulpevent *ev;
 	__u32 ctsn;
@@ -2738,12 +2765,13 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
  * The Cumulative TSN Ack of the received SHUTDOWN chunk
  * MUST be processed.
  */
-sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
-					   const struct sctp_endpoint *ep,
-					   const struct sctp_association *asoc,
-					   const union sctp_subtype type,
-					   void *arg,
-					   struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_2_shut_ctsn(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_shutdownhdr *sdh;
@@ -2791,14 +2819,15 @@ sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
  * that belong to this association, it should discard the INIT chunk and
  * retransmit the SHUTDOWN ACK chunk.
  */
-sctp_disposition_t sctp_sf_do_9_2_reshutack(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const union sctp_subtype type,
-				    void *arg,
-				    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_2_reshutack(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk = (struct sctp_chunk *) arg;
+	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *reply;
 
 	/* Make sure that the chunk has a valid length */
@@ -2855,12 +2884,12 @@ sctp_disposition_t sctp_sf_do_9_2_reshutack(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
-				      const struct sctp_endpoint *ep,
-				      const struct sctp_association *asoc,
-				      const union sctp_subtype type,
-				      void *arg,
-				      struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_ecn_cwr(struct net *net,
+					 const struct sctp_endpoint *ep,
+					 const struct sctp_association *asoc,
+					 const union sctp_subtype type,
+					 void *arg,
+					 struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_cwrhdr *cwr;
@@ -2911,12 +2940,11 @@ sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_ecne(struct net *net,
-				   const struct sctp_endpoint *ep,
-				   const struct sctp_association *asoc,
-				   const union sctp_subtype type,
-				   void *arg,
-				   struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_ecne(struct net *net,
+				      const struct sctp_endpoint *ep,
+				      const struct sctp_association *asoc,
+				      const union sctp_subtype type,
+				      void *arg, struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_ecnehdr *ecne;
@@ -2968,12 +2996,12 @@ sctp_disposition_t sctp_sf_do_ecne(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_eat_data_6_2(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	union sctp_arg force = SCTP_NOFORCE();
 	struct sctp_chunk *chunk = arg;
@@ -3088,12 +3116,13 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_eat_data_fast_4_4(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	int error;
@@ -3179,12 +3208,12 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_eat_sack_6_2(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_sackhdr *sackh;
@@ -3253,7 +3282,8 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
  *
  * The return value is the disposition of the chunk.
 */
-static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
+static enum sctp_disposition sctp_sf_tabort_8_4_8(
+					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const union sctp_subtype type,
@@ -3303,12 +3333,12 @@ static sctp_disposition_t sctp_sf_tabort_8_4_8(struct net *net,
  *
  * The return value is the disposition of the chunk.
 */
-sctp_disposition_t sctp_sf_operr_notify(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_operr_notify(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_errhdr *err;
@@ -3341,12 +3371,12 @@ sctp_disposition_t sctp_sf_operr_notify(struct net *net,
  *
  * The return value is the disposition.
  */
-sctp_disposition_t sctp_sf_do_9_2_final(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_2_final(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *reply;
@@ -3424,20 +3454,19 @@ sctp_disposition_t sctp_sf_do_9_2_final(struct net *net,
  *    receiver of the OOTB packet shall discard the OOTB packet and take
  *    no further action.
  */
-sctp_disposition_t sctp_sf_ootb(struct net *net,
-				const struct sctp_endpoint *ep,
-				const struct sctp_association *asoc,
-				const union sctp_subtype type,
-				void *arg,
-				struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_ootb(struct net *net,
+				   const struct sctp_endpoint *ep,
+				   const struct sctp_association *asoc,
+				   const union sctp_subtype type,
+				   void *arg, struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
 	struct sctp_chunkhdr *ch;
 	struct sctp_errhdr *err;
-	__u8 *ch_end;
-	int ootb_shut_ack = 0;
 	int ootb_cookie_ack = 0;
+	int ootb_shut_ack = 0;
+	__u8 *ch_end;
 
 	SCTP_INC_STATS(net, SCTP_MIB_OUTOFBLUES);
 
@@ -3513,16 +3542,17 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
  * (endpoint, asoc, type, arg, commands)
  *
  * Outputs
- * (sctp_disposition_t)
+ * (enum sctp_disposition)
  *
  * The return value is the disposition of the chunk.
  */
-static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
-					     const struct sctp_endpoint *ep,
-					     const struct sctp_association *asoc,
-					     const union sctp_subtype type,
-					     void *arg,
-					     struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_shut_8_4_5(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_packet *packet = NULL;
 	struct sctp_chunk *chunk = arg;
@@ -3579,12 +3609,12 @@ static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
  *   chunks. --piggy ]
  *
  */
-sctp_disposition_t sctp_sf_do_8_5_1_E_sa(struct net *net,
-				      const struct sctp_endpoint *ep,
-				      const struct sctp_association *asoc,
-				      const union sctp_subtype type,
-				      void *arg,
-				      struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_8_5_1_E_sa(struct net *net,
+					    const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const union sctp_subtype type,
+					    void *arg,
+					    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -3604,17 +3634,18 @@ sctp_disposition_t sctp_sf_do_8_5_1_E_sa(struct net *net,
 }
 
 /* ADDIP Section 4.2 Upon reception of an ASCONF Chunk.  */
-sctp_disposition_t sctp_sf_do_asconf(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type, void *arg,
-				     struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_asconf(struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk	*chunk = arg;
-	struct sctp_chunk	*asconf_ack = NULL;
-	struct sctp_paramhdr	*err_param = NULL;
-	struct sctp_addiphdr	*hdr;
-	__u32			serial;
+	struct sctp_paramhdr *err_param = NULL;
+	struct sctp_chunk *asconf_ack = NULL;
+	struct sctp_chunk *chunk = arg;
+	struct sctp_addiphdr *hdr;
+	__u32 serial;
 
 	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
@@ -3721,19 +3752,19 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
  * When building TLV parameters for the ASCONF Chunk that will add or
  * delete IP addresses the D0 to D13 rules should be applied:
  */
-sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
-					 const struct sctp_endpoint *ep,
-					 const struct sctp_association *asoc,
-					 const union sctp_subtype type,
-					 void *arg,
-					 struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_asconf_ack(struct net *net,
+					    const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const union sctp_subtype type,
+					    void *arg,
+					    struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk	*asconf_ack = arg;
-	struct sctp_chunk	*last_asconf = asoc->addip_last_asconf;
-	struct sctp_chunk	*abort;
-	struct sctp_paramhdr	*err_param = NULL;
-	struct sctp_addiphdr	*addip_hdr;
-	__u32			sent_serial, rcvd_serial;
+	struct sctp_chunk *last_asconf = asoc->addip_last_asconf;
+	struct sctp_paramhdr *err_param = NULL;
+	struct sctp_chunk *asconf_ack = arg;
+	struct sctp_addiphdr *addip_hdr;
+	__u32 sent_serial, rcvd_serial;
+	struct sctp_chunk *abort;
 
 	if (!sctp_vtag_verify(asconf_ack, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
@@ -3840,11 +3871,12 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 }
 
 /* RE-CONFIG Section 5.2 Upon reception of an RECONF Chunk. */
-sctp_disposition_t sctp_sf_do_reconf(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type, void *arg,
-				     struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_reconf(struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_paramhdr *err_param = NULL;
 	struct sctp_chunk *chunk = arg;
@@ -3916,15 +3948,15 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
-				       const struct sctp_endpoint *ep,
-				       const struct sctp_association *asoc,
-				       const union sctp_subtype type,
-				       void *arg,
-				       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_eat_fwd_tsn(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  const union sctp_subtype type,
+					  void *arg,
+					  struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_hdr *fwdtsn_hdr;
+	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_skip *skip;
 	__u16 len;
 	__u32 tsn;
@@ -3986,16 +4018,16 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
 	return SCTP_DISPOSITION_DISCARD;
 }
 
-sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_eat_fwd_tsn_fast(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_hdr *fwdtsn_hdr;
+	struct sctp_chunk *chunk = arg;
 	struct sctp_fwdtsn_skip *skip;
 	__u16 len;
 	__u32 tsn;
@@ -4079,18 +4111,17 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
  * The return value is the disposition of the chunk.
  */
 static enum sctp_ierror sctp_sf_authenticate(
-				struct net *net,
-				const struct sctp_endpoint *ep,
-				const struct sctp_association *asoc,
-				const union sctp_subtype type,
-				struct sctp_chunk *chunk)
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					struct sctp_chunk *chunk)
 {
 	struct sctp_authhdr *auth_hdr;
+	__u8 *save_digest, *digest;
 	struct sctp_hmac *hmac;
 	unsigned int sig_len;
 	__u16 key_id;
-	__u8 *save_digest;
-	__u8 *digest;
 
 	/* Pull in the auth header, so we can do some more verification */
 	auth_hdr = (struct sctp_authhdr *)chunk->skb->data;
@@ -4154,12 +4185,11 @@ static enum sctp_ierror sctp_sf_authenticate(
 	return SCTP_IERROR_NOMEM;
 }
 
-sctp_disposition_t sctp_sf_eat_auth(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const union sctp_subtype type,
-				    void *arg,
-				    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_eat_auth(struct net *net,
+				       const struct sctp_endpoint *ep,
+				       const struct sctp_association *asoc,
+				       const union sctp_subtype type,
+				       void *arg, struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_authhdr *auth_hdr;
@@ -4251,12 +4281,12 @@ sctp_disposition_t sctp_sf_eat_auth(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_unk_chunk(struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *unk_chunk = arg;
 	struct sctp_chunk *err_chunk;
@@ -4331,12 +4361,12 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_discard_chunk(struct net *net,
-					 const struct sctp_endpoint *ep,
-					 const struct sctp_association *asoc,
-					 const union sctp_subtype type,
-					 void *arg,
-					 struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_discard_chunk(struct net *net,
+					    const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const union sctp_subtype type,
+					    void *arg,
+					    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -4371,12 +4401,11 @@ sctp_disposition_t sctp_sf_discard_chunk(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_pdiscard(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const union sctp_subtype type,
-				    void *arg,
-				    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_pdiscard(struct net *net,
+				       const struct sctp_endpoint *ep,
+				       const struct sctp_association *asoc,
+				       const union sctp_subtype type,
+				       void *arg, struct sctp_cmd_seq *commands)
 {
 	SCTP_INC_STATS(net, SCTP_MIB_IN_PKT_DISCARDS);
 	sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
@@ -4399,12 +4428,12 @@ sctp_disposition_t sctp_sf_pdiscard(struct net *net,
  * We simply tag the chunk as a violation.  The state machine will log
  * the violation and continue.
  */
-sctp_disposition_t sctp_sf_violation(struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_violation(struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -4419,14 +4448,14 @@ sctp_disposition_t sctp_sf_violation(struct net *net,
 /*
  * Common function to handle a protocol violation.
  */
-static sctp_disposition_t sctp_sf_abort_violation(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     void *arg,
-				     struct sctp_cmd_seq *commands,
-				     const __u8 *payload,
-				     const size_t paylen)
+static enum sctp_disposition sctp_sf_abort_violation(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					void *arg,
+					struct sctp_cmd_seq *commands,
+					const __u8 *payload,
+					const size_t paylen)
 {
 	struct sctp_packet *packet = NULL;
 	struct sctp_chunk *chunk =  arg;
@@ -4536,18 +4565,18 @@ static sctp_disposition_t sctp_sf_abort_violation(
  *
  * Generate an  ABORT chunk and terminate the association.
  */
-static sctp_disposition_t sctp_sf_violation_chunklen(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_violation_chunklen(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	static const char err_str[] = "The following chunk had invalid length:";
 
 	return sctp_sf_abort_violation(net, ep, asoc, arg, commands, err_str,
-					sizeof(err_str));
+				       sizeof(err_str));
 }
 
 /*
@@ -4556,17 +4585,17 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
  * or accumulated length in multi parameters exceeds the end of the chunk,
  * the length is considered as invalid.
  */
-static sctp_disposition_t sctp_sf_violation_paramlen(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg, void *ext,
-				     struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_violation_paramlen(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg, void *ext,
+					struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk =  arg;
 	struct sctp_paramhdr *param = ext;
 	struct sctp_chunk *abort = NULL;
+	struct sctp_chunk *chunk = arg;
 
 	if (sctp_auth_recv_cid(SCTP_CID_ABORT, asoc))
 		goto discard;
@@ -4599,18 +4628,18 @@ static sctp_disposition_t sctp_sf_violation_paramlen(
  * We inform the other end by sending an ABORT with a Protocol Violation
  * error code.
  */
-static sctp_disposition_t sctp_sf_violation_ctsn(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_violation_ctsn(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	static const char err_str[] = "The cumulative tsn ack beyond the max tsn currently sent:";
 
 	return sctp_sf_abort_violation(net, ep, asoc, arg, commands, err_str,
-					sizeof(err_str));
+				       sizeof(err_str));
 }
 
 /* Handle protocol violation of an invalid chunk bundling.  For example,
@@ -4619,13 +4648,13 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
  * statement from the specs.  Additionally, there might be an attacker
  * on the path and we may not want to continue this communication.
  */
-static sctp_disposition_t sctp_sf_violation_chunk(
-				     struct net *net,
-				     const struct sctp_endpoint *ep,
-				     const struct sctp_association *asoc,
-				     const union sctp_subtype type,
-				     void *arg,
-				     struct sctp_cmd_seq *commands)
+static enum sctp_disposition sctp_sf_violation_chunk(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	static const char err_str[] = "The following chunk violates protocol:";
 
@@ -4633,7 +4662,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 		return sctp_sf_violation(net, ep, asoc, type, arg, commands);
 
 	return sctp_sf_abort_violation(net, ep, asoc, arg, commands, err_str,
-					sizeof(err_str));
+				       sizeof(err_str));
 }
 /***************************************************************************
  * These are the state functions for handling primitive (Section 10) events.
@@ -4695,15 +4724,15 @@ static sctp_disposition_t sctp_sf_violation_chunk(
  *
  * The return value is a disposition.
  */
-sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
-				       const struct sctp_endpoint *ep,
-				       const struct sctp_association *asoc,
-				       const union sctp_subtype type,
-				       void *arg,
-				       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_prm_asoc(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  const union sctp_subtype type,
+					  void *arg,
+					  struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *repl;
 	struct sctp_association *my_asoc;
+	struct sctp_chunk *repl;
 
 	/* The comment below says that we enter COOKIE-WAIT AFTER
 	 * sending the INIT, but that doesn't actually work in our
@@ -4807,12 +4836,12 @@ sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
  *
  * The return value is the disposition.
  */
-sctp_disposition_t sctp_sf_do_prm_send(struct net *net,
-				       const struct sctp_endpoint *ep,
-				       const struct sctp_association *asoc,
-				       const union sctp_subtype type,
-				       void *arg,
-				       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_prm_send(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  const union sctp_subtype type,
+					  void *arg,
+					  struct sctp_cmd_seq *commands)
 {
 	struct sctp_datamsg *msg = arg;
 
@@ -4846,15 +4875,15 @@ sctp_disposition_t sctp_sf_do_prm_send(struct net *net,
  *
  * The return value is the disposition.
  */
-sctp_disposition_t sctp_sf_do_9_2_prm_shutdown(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_2_prm_shutdown(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	int disposition;
+	enum sctp_disposition disposition;
 
 	/* From 9.2 Shutdown of an Association
 	 * Upon receipt of the SHUTDOWN primitive from its upper
@@ -4872,6 +4901,7 @@ sctp_disposition_t sctp_sf_do_9_2_prm_shutdown(
 		disposition = sctp_sf_do_9_2_start_shutdown(net, ep, asoc, type,
 							    arg, commands);
 	}
+
 	return disposition;
 }
 
@@ -4902,13 +4932,13 @@ sctp_disposition_t sctp_sf_do_9_2_prm_shutdown(
  *
  * The return value is the disposition.
  */
-sctp_disposition_t sctp_sf_do_9_1_prm_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_1_prm_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* From 9.1 Abort of an Association
 	 * Upon receipt of the ABORT primitive from its upper
@@ -4940,12 +4970,12 @@ sctp_disposition_t sctp_sf_do_9_1_prm_abort(
 }
 
 /* We tried an illegal operation on an association which is closed.  */
-sctp_disposition_t sctp_sf_error_closed(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_error_closed(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_ERROR, SCTP_ERROR(-EINVAL));
 	return SCTP_DISPOSITION_CONSUME;
@@ -4954,12 +4984,13 @@ sctp_disposition_t sctp_sf_error_closed(struct net *net,
 /* We tried an illegal operation on an association which is shutting
  * down.
  */
-sctp_disposition_t sctp_sf_error_shutdown(struct net *net,
-					  const struct sctp_endpoint *ep,
-					  const struct sctp_association *asoc,
-					  const union sctp_subtype type,
-					  void *arg,
-					  struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_error_shutdown(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_ERROR,
 			SCTP_ERROR(-ESHUTDOWN));
@@ -4980,13 +5011,13 @@ sctp_disposition_t sctp_sf_error_shutdown(struct net *net,
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_cookie_wait_prm_shutdown(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_cookie_wait_prm_shutdown(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
@@ -5015,12 +5046,13 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_shutdown(
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_cookie_echoed_prm_shutdown(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg, struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_cookie_echoed_prm_shutdown(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
 	 * common function with the COOKIE-WAIT state.
@@ -5042,13 +5074,13 @@ sctp_disposition_t sctp_sf_cookie_echoed_prm_shutdown(
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_cookie_wait_prm_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *abort = arg;
 
@@ -5091,13 +5123,13 @@ sctp_disposition_t sctp_sf_cookie_wait_prm_abort(
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_cookie_echoed_prm_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_cookie_echoed_prm_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* There is a single T1 timer, so we should be able to use
 	 * common function with the COOKIE-WAIT state.
@@ -5117,13 +5149,13 @@ sctp_disposition_t sctp_sf_cookie_echoed_prm_abort(
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_shutdown_pending_prm_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_shutdown_pending_prm_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* Stop the T5-shutdown guard timer.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
@@ -5144,13 +5176,13 @@ sctp_disposition_t sctp_sf_shutdown_pending_prm_abort(
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_shutdown_sent_prm_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_shutdown_sent_prm_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* Stop the T2-shutdown timer.  */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
@@ -5175,13 +5207,13 @@ sctp_disposition_t sctp_sf_shutdown_sent_prm_abort(
  * Outputs
  * (timers)
  */
-sctp_disposition_t sctp_sf_shutdown_ack_sent_prm_abort(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_shutdown_ack_sent_prm_abort(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	/* The same T2 timer, so we should be able to use
 	 * common function with the SHUTDOWN-SENT state.
@@ -5211,7 +5243,7 @@ sctp_disposition_t sctp_sf_shutdown_ack_sent_prm_abort(
  * o destination transport address - the transport address of the
  *   association on which a heartbeat should be issued.
  */
-sctp_disposition_t sctp_sf_do_prm_requestheartbeat(
+enum sctp_disposition sctp_sf_do_prm_requestheartbeat(
 					struct net *net,
 					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
@@ -5244,12 +5276,12 @@ sctp_disposition_t sctp_sf_do_prm_requestheartbeat(
  * When an endpoint has an ASCONF signaled change to be sent to the
  * remote endpoint it should do A1 to A9
  */
-sctp_disposition_t sctp_sf_do_prm_asconf(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_prm_asconf(struct net *net,
+					    const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const union sctp_subtype type,
+					    void *arg,
+					    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -5261,12 +5293,12 @@ sctp_disposition_t sctp_sf_do_prm_asconf(struct net *net,
 }
 
 /* RE-CONFIG Section 5.1 RECONF Chunk Procedures */
-sctp_disposition_t sctp_sf_do_prm_reconf(struct net *net,
-					 const struct sctp_endpoint *ep,
-					 const struct sctp_association *asoc,
-					 const union sctp_subtype type,
-					 void *arg,
-					 struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_prm_reconf(struct net *net,
+					    const struct sctp_endpoint *ep,
+					    const struct sctp_association *asoc,
+					    const union sctp_subtype type,
+					    void *arg,
+					    struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = arg;
 
@@ -5279,13 +5311,13 @@ sctp_disposition_t sctp_sf_do_prm_reconf(struct net *net,
  *
  * The return value is the disposition of the primitive.
  */
-sctp_disposition_t sctp_sf_ignore_primitive(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_ignore_primitive(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	pr_debug("%s: primitive type:%d is ignored\n", __func__,
 		 type.primitive);
@@ -5303,13 +5335,13 @@ sctp_disposition_t sctp_sf_ignore_primitive(
  * subscribes to this event, if there is no data to be sent or
  * retransmit, the stack will immediately send up this notification.
  */
-sctp_disposition_t sctp_sf_do_no_pending_tsn(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_no_pending_tsn(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_ulpevent *event;
 
@@ -5335,13 +5367,13 @@ sctp_disposition_t sctp_sf_do_no_pending_tsn(
  *
  * The return value is the disposition.
  */
-sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_2_start_shutdown(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *reply;
 
@@ -5405,15 +5437,15 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
  *
  * The return value is the disposition.
  */
-sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_9_2_shutdown_ack(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *chunk = (struct sctp_chunk *) arg;
+	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *reply;
 
 	/* There are 2 ways of getting here:
@@ -5479,12 +5511,12 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
  *
  * The return value is the disposition of the event.
  */
-sctp_disposition_t sctp_sf_ignore_other(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_ignore_other(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	pr_debug("%s: the event other type:%d is ignored\n",
 		 __func__, type.other);
@@ -5507,12 +5539,12 @@ sctp_disposition_t sctp_sf_ignore_other(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_6_3_3_rtx(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	struct sctp_transport *transport = arg;
 
@@ -5595,12 +5627,12 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
  * allow. However, an SCTP transmitter MUST NOT be more aggressive than
  * the following algorithms allow.
  */
-sctp_disposition_t sctp_sf_do_6_2_sack(struct net *net,
-				       const struct sctp_endpoint *ep,
-				       const struct sctp_association *asoc,
-				       const union sctp_subtype type,
-				       void *arg,
-				       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_do_6_2_sack(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  const union sctp_subtype type,
+					  void *arg,
+					  struct sctp_cmd_seq *commands)
 {
 	SCTP_INC_STATS(net, SCTP_MIB_DELAY_SACK_EXPIREDS);
 	sctp_add_cmd_sf(commands, SCTP_CMD_GEN_SACK, SCTP_FORCE());
@@ -5626,16 +5658,17 @@ sctp_disposition_t sctp_sf_do_6_2_sack(struct net *net,
  * (timers, events)
  *
  */
-sctp_disposition_t sctp_sf_t1_init_timer_expire(struct net *net,
-					   const struct sctp_endpoint *ep,
-					   const struct sctp_association *asoc,
-					   const union sctp_subtype type,
-					   void *arg,
-					   struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_t1_init_timer_expire(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
+	int attempts = asoc->init_err_counter + 1;
 	struct sctp_chunk *repl = NULL;
 	struct sctp_bind_addr *bp;
-	int attempts = asoc->init_err_counter + 1;
 
 	pr_debug("%s: timer T1 expired (INIT)\n", __func__);
 
@@ -5690,15 +5723,16 @@ sctp_disposition_t sctp_sf_t1_init_timer_expire(struct net *net,
  * (timers, events)
  *
  */
-sctp_disposition_t sctp_sf_t1_cookie_timer_expire(struct net *net,
-					   const struct sctp_endpoint *ep,
-					   const struct sctp_association *asoc,
-					   const union sctp_subtype type,
-					   void *arg,
-					   struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_t1_cookie_timer_expire(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	struct sctp_chunk *repl = NULL;
 	int attempts = asoc->init_err_counter + 1;
+	struct sctp_chunk *repl = NULL;
 
 	pr_debug("%s: timer T1 expired (COOKIE-ECHO)\n", __func__);
 
@@ -5740,12 +5774,13 @@ sctp_disposition_t sctp_sf_t1_cookie_timer_expire(struct net *net,
  * the T2-Shutdown timer,  giving its peer ample opportunity to transmit
  * all of its queued DATA chunks that have not yet been sent.
  */
-sctp_disposition_t sctp_sf_t2_timer_expire(struct net *net,
-					   const struct sctp_endpoint *ep,
-					   const struct sctp_association *asoc,
-					   const union sctp_subtype type,
-					   void *arg,
-					   struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_t2_timer_expire(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *reply = NULL;
 
@@ -5810,13 +5845,13 @@ sctp_disposition_t sctp_sf_t2_timer_expire(struct net *net,
  * ADDIP Section 4.1 ASCONF CHunk Procedures
  * If the T4 RTO timer expires the endpoint should do B1 to B5
  */
-sctp_disposition_t sctp_sf_t4_timer_expire(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_t4_timer_expire(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *chunk = asoc->addip_last_asconf;
 	struct sctp_transport *transport = chunk->transport;
@@ -5882,12 +5917,13 @@ sctp_disposition_t sctp_sf_t4_timer_expire(
  * At the expiration of this timer the sender SHOULD abort the association
  * by sending an ABORT chunk.
  */
-sctp_disposition_t sctp_sf_t5_timer_expire(struct net *net,
-					   const struct sctp_endpoint *ep,
-					   const struct sctp_association *asoc,
-					   const union sctp_subtype type,
-					   void *arg,
-					   struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_t5_timer_expire(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
 	struct sctp_chunk *reply = NULL;
 
@@ -5918,15 +5954,15 @@ sctp_disposition_t sctp_sf_t5_timer_expire(struct net *net,
  * The work that needs to be done is same as when SHUTDOWN is initiated by
  * the user.  So this routine looks same as sctp_sf_do_9_2_prm_shutdown().
  */
-sctp_disposition_t sctp_sf_autoclose_timer_expire(
-	struct net *net,
-	const struct sctp_endpoint *ep,
-	const struct sctp_association *asoc,
-	const union sctp_subtype type,
-	void *arg,
-	struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_autoclose_timer_expire(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const union sctp_subtype type,
+					void *arg,
+					struct sctp_cmd_seq *commands)
 {
-	int disposition;
+	enum sctp_disposition disposition;
 
 	SCTP_INC_STATS(net, SCTP_MIB_AUTOCLOSE_EXPIREDS);
 
@@ -5946,6 +5982,7 @@ sctp_disposition_t sctp_sf_autoclose_timer_expire(
 		disposition = sctp_sf_do_9_2_start_shutdown(net, ep, asoc, type,
 							    arg, commands);
 	}
+
 	return disposition;
 }
 
@@ -5961,12 +5998,11 @@ sctp_disposition_t sctp_sf_autoclose_timer_expire(
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_not_impl(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const union sctp_subtype type,
-				    void *arg,
-				    struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_not_impl(struct net *net,
+				       const struct sctp_endpoint *ep,
+				       const struct sctp_association *asoc,
+				       const union sctp_subtype type,
+				       void *arg, struct sctp_cmd_seq *commands)
 {
 	return SCTP_DISPOSITION_NOT_IMPL;
 }
@@ -5979,12 +6015,11 @@ sctp_disposition_t sctp_sf_not_impl(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_bug(struct net *net,
-			       const struct sctp_endpoint *ep,
-			       const struct sctp_association *asoc,
-			       const union sctp_subtype type,
-			       void *arg,
-			       struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_bug(struct net *net,
+				  const struct sctp_endpoint *ep,
+				  const struct sctp_association *asoc,
+				  const union sctp_subtype type,
+				  void *arg, struct sctp_cmd_seq *commands)
 {
 	return SCTP_DISPOSITION_BUG;
 }
@@ -6000,12 +6035,12 @@ sctp_disposition_t sctp_sf_bug(struct net *net,
  *
  * The return value is the disposition of the chunk.
  */
-sctp_disposition_t sctp_sf_timer_ignore(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					const union sctp_subtype type,
-					void *arg,
-					struct sctp_cmd_seq *commands)
+enum sctp_disposition sctp_sf_timer_ignore(struct net *net,
+					   const struct sctp_endpoint *ep,
+					   const struct sctp_association *asoc,
+					   const union sctp_subtype type,
+					   void *arg,
+					   struct sctp_cmd_seq *commands)
 {
 	pr_debug("%s: timer %d ignored\n", __func__, type.chunk);
 
@@ -6020,9 +6055,9 @@ sctp_disposition_t sctp_sf_timer_ignore(struct net *net,
 static struct sctp_sackhdr *sctp_sm_pull_sack(struct sctp_chunk *chunk)
 {
 	struct sctp_sackhdr *sack;
+	__u16 num_dup_tsns;
 	unsigned int len;
 	__u16 num_blocks;
-	__u16 num_dup_tsns;
 
 	/* Protect ourselves from reading too far into
 	 * the skb from a bogus sender.
@@ -6044,12 +6079,12 @@ static struct sctp_sackhdr *sctp_sm_pull_sack(struct sctp_chunk *chunk)
 /* Create an ABORT packet to be sent as a response, with the specified
  * error causes.
  */
-static struct sctp_packet *sctp_abort_pkt_new(struct net *net,
-				  const struct sctp_endpoint *ep,
-				  const struct sctp_association *asoc,
-				  struct sctp_chunk *chunk,
-				  const void *payload,
-				  size_t paylen)
+static struct sctp_packet *sctp_abort_pkt_new(
+					struct net *net,
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					struct sctp_chunk *chunk,
+					const void *payload, size_t paylen)
 {
 	struct sctp_packet *packet;
 	struct sctp_chunk *abort;
@@ -6086,14 +6121,14 @@ static struct sctp_packet *sctp_abort_pkt_new(struct net *net,
 }
 
 /* Allocate a packet for responding in the OOTB conditions.  */
-static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
-					     const struct sctp_association *asoc,
-					     const struct sctp_chunk *chunk)
+static struct sctp_packet *sctp_ootb_pkt_new(
+					struct net *net,
+					const struct sctp_association *asoc,
+					const struct sctp_chunk *chunk)
 {
-	struct sctp_packet *packet;
 	struct sctp_transport *transport;
-	__u16 sport;
-	__u16 dport;
+	struct sctp_packet *packet;
+	__u16 sport, dport;
 	__u32 vtag;
 
 	/* Get the source and destination port from the inbound packet.  */
@@ -6202,18 +6237,17 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 			 struct sctp_chunk *chunk,
 			 struct sctp_cmd_seq *commands)
 {
-	struct sctp_datahdr *data_hdr;
-	struct sctp_chunk *err;
-	size_t datalen;
-	enum sctp_verb deliver;
-	int tmp;
-	__u32 tsn;
 	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
 	struct sock *sk = asoc->base.sk;
 	struct net *net = sock_net(sk);
-	u16 ssn;
-	u16 sid;
+	struct sctp_datahdr *data_hdr;
+	struct sctp_chunk *err;
+	enum sctp_verb deliver;
+	size_t datalen;
 	u8 ordered = 0;
+	u16 ssn, sid;
+	__u32 tsn;
+	int tmp;
 
 	data_hdr = (struct sctp_datahdr *)chunk->skb->data;
 	chunk->subh.data_hdr = data_hdr;
-- 
2.1.0
