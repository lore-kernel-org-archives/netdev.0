From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 2/2] sctp: delay calls to sk_data_ready() as much as possible
Date: Tue, 29 Mar 2016 10:49:45 -0300
Message-ID: <2c0dd1671ae09b7a34ddd4834b0beb80c87d7cc5.1459259208.git.marcelo.leitner@gmail.com>
References: <cover.1459259208.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756788AbcC2Nty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 09:49:54 -0400
In-Reply-To: <cover.1459259208.git.marcelo.leitner@gmail.com>
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

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h | 3 ++-
 net/sctp/sm_sideeffect.c   | 5 +++++
 net/sctp/ulpqueue.c        | 4 ++--
 3 files changed, 9 insertions(+), 3 deletions(-)

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
index 7fe56d0acabf66cfd8fe29dfdb45f7620b470ac7..e7042f9ce63b0cfca50cae252f51b60b68cb5731 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1742,6 +1742,11 @@ out:
 			error = sctp_outq_uncork(&asoc->outqueue, gfp);
 	} else if (local_cork)
 		error = sctp_outq_uncork(&asoc->outqueue, gfp);
+
+	if (sctp_sk(ep->base.sk)->pending_data_ready) {
+		ep->base.sk->sk_data_ready(ep->base.sk);
+		sctp_sk(ep->base.sk)->pending_data_ready = 0;
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
