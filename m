From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/5] net: sctp: migrate most recently used transport to ktime
Date: Wed, 11 Jun 2014 16:34:55 +0200
Message-ID: <1402497297-27100-4-git-send-email-dborkman@redhat.com>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbaFKOfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 10:35:07 -0400
In-Reply-To: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Be more precise in transport path selection and use ktime
helpers instead of jiffies to compare and pick the better
primary and secondary recently used transports. This also
avoids any side-effects during a possible roll-over, and
could lead to better path decision-making.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h | 6 +++---
 net/sctp/associola.c       | 8 +++++---
 net/sctp/endpointola.c     | 2 +-
 net/sctp/transport.c       | 2 +-
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0dfcc92..f38588b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -838,10 +838,10 @@ struct sctp_transport {
 	unsigned long sackdelay;
 	__u32 sackfreq;
 
-	/* When was the last time (in jiffies) that we heard from this
-	 * transport?  We use this to pick new active and retran paths.
+	/* When was the last time that we heard from this transport? We use
+	 * this to pick new active and retran paths.
 	 */
-	unsigned long last_time_heard;
+	ktime_t last_time_heard;
 
 	/* Last time(in jiffies) when cwnd is reduced due to the congestion
 	 * indication based on ECNE chunk.
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 9f1cc6f..620c99e 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1036,7 +1036,7 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
 		}
 
 		if (chunk->transport)
-			chunk->transport->last_time_heard = jiffies;
+			chunk->transport->last_time_heard = ktime_get();
 
 		/* Run through the state machine. */
 		error = sctp_do_sm(net, SCTP_EVENT_T_CHUNK, subtype,
@@ -1283,11 +1283,13 @@ static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
 		    trans->state == SCTP_PF)
 			continue;
 		if (trans_pri == NULL ||
-		    trans->last_time_heard > trans_pri->last_time_heard) {
+		    ktime_after(trans->last_time_heard,
+				trans_pri->last_time_heard)) {
 			trans_sec = trans_pri;
 			trans_pri = trans;
 		} else if (trans_sec == NULL ||
-			   trans->last_time_heard > trans_sec->last_time_heard) {
+			   ktime_after(trans->last_time_heard,
+				       trans_sec->last_time_heard)) {
 			trans_sec = trans;
 		}
 	}
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 3d9f429..9da76ba 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -481,7 +481,7 @@ normal:
 		}
 
 		if (chunk->transport)
-			chunk->transport->last_time_heard = jiffies;
+			chunk->transport->last_time_heard = ktime_get();
 
 		error = sctp_do_sm(net, SCTP_EVENT_T_CHUNK, subtype, state,
 				   ep, asoc, chunk, GFP_ATOMIC);
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 1d348d1..7dd672f 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -72,7 +72,7 @@ static struct sctp_transport *sctp_transport_init(struct net *net,
 	 */
 	peer->rto = msecs_to_jiffies(net->sctp.rto_initial);
 
-	peer->last_time_heard = jiffies;
+	peer->last_time_heard = ktime_get();
 	peer->last_time_ecne_reduced = jiffies;
 
 	peer->param_flags = SPP_HB_DISABLE |
-- 
1.7.11.7
