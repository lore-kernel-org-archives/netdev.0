From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v3 2/2] sctp: delay calls to sk_data_ready() as much as possible
Date: Fri,  8 Apr 2016 16:41:28 -0300
Message-ID: <4aedc87e2e85386352aeb50f2bc57d4c3cc796d8.1460144373.git.marcelo.leitner@gmail.com>
References: <cover.1460144373.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Jakub Sitnicki <jkbs@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758663AbcDHTln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 15:41:43 -0400
In-Reply-To: <cover.1460144373.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently processing of multiple chunks in a single SCTP packet leads to
multiple calls to sk_data_ready, causing multiple wake up signals which
are costy and doesn't make it wake up any faster.

With this patch it will note that the wake up is pending and will do it
before leaving the state machine interpreter, latest place possible to
do it realiably and cleanly.

Note that sk_data_ready events are not dependent on asocs, unlike waking
up writers.

v2: series re-checked
v3: use local vars to cleanup the code, suggested by Jakub Sitnicki
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h | 3 ++-
 net/sctp/sm_sideeffect.c   | 7 +++++++
 net/sctp/ulpqueue.c        | 4 ++--
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 1a6a626904bba4223b7921bbb4be41c2550271a7..21cb11107e378b4da1e7efde22fab4349496e35a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -217,7 +217,8 @@ struct sctp_sock {
 		v4mapped:1,
 		frag_interleave:1,
 		recvrcvinfo:1,
-		recvnxtinfo:1;
+		recvnxtinfo:1,
+		pending_data_ready:1;
 
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 7fe56d0acabf66cfd8fe29dfdb45f7620b470ac7..d06317de873090be359ce768fe291224ee50658f 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1222,6 +1222,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_cmd_seq_t *commands,
 				gfp_t gfp)
 {
+	struct sock *sk = ep->base.sk;
+	struct sctp_sock *sp = sctp_sk(sk);
 	int error = 0;
 	int force;
 	sctp_cmd_t *cmd;
@@ -1742,6 +1744,11 @@ out:
 			error = sctp_outq_uncork(&asoc->outqueue, gfp);
 	} else if (local_cork)
 		error = sctp_outq_uncork(&asoc->outqueue, gfp);
+
+	if (sp->pending_data_ready) {
+		sk->sk_data_ready(sk);
+		sp->pending_data_ready = 0;
+	}
 	return error;
 nomem:
 	error = -ENOMEM;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index ce469d648ffbe166f9ae1c5650f481256f31a7f8..72e5b3e41cddf9d79371de8ab01484e4601b97b6 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -264,7 +264,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 		sctp_ulpq_clear_pd(ulpq);
 
 	if (queue == &sk->sk_receive_queue)
-		sk->sk_data_ready(sk);
+		sctp_sk(sk)->pending_data_ready = 1;
 	return 1;
 
 out_free:
@@ -1140,5 +1140,5 @@ void sctp_ulpq_abort_pd(struct sctp_ulpq *ulpq, gfp_t gfp)
 
 	/* If there is data waiting, send it up the socket now. */
 	if (sctp_ulpq_clear_pd(ulpq) || ev)
-		sk->sk_data_ready(sk);
+		sctp_sk(sk)->pending_data_ready = 1;
 }
-- 
2.5.0
