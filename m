From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v3 net-next 4/5] net: sctp: improve sctp_select_active_and_retran_path selection
Date: Wed, 11 Jun 2014 18:19:31 +0200
Message-ID: <1402503572-32237-5-git-send-email-dborkman@redhat.com>
References: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933112AbaFKQTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:19:41 -0400
In-Reply-To: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function sctp_select_active_and_retran_path(), we walk the
transport list in order to look for the two most recently used
ACTIVE transports (trans_pri, trans_sec). In case we didn't find
anything ACTIVE, we currently just camp on a possibly PF or
INACTIVE transport that is primary path; this behavior actually
dates back to linux-history tree of the very early days of
lksctp, and can yield a behavior that chooses suboptimal
transport paths.

Instead, be a bit more clever by reusing and extending the
recently introduced sctp_trans_elect_best() handler. In case
both transports are evaluated to have the same score resulting
from their states, break the tie by looking at: 1) transport
patch error count 2) last_time_heard value from each transport.

This is analogous to Nishida's Quick Failover draft [1],
section 5.1, 3:

  The sender SHOULD avoid data transmission to PF destinations.
  When all destinations are in either PF or Inactive state,
  the sender MAY either move the destination from PF to active
  state (and transmit data to the active destination) or the
  sender MAY transmit data to a PF destination. In the former
  scenario, (i) the sender MUST NOT notify the ULP about the
  state transition, and (ii) MUST NOT clear the destination's
  error counter. It is recommended that the sender picks the
  PF destination with least error count (fewest consecutive
  timeouts) for data transmission. In case of a tie (multiple PF
  destinations with same error count), the sender MAY choose the
  last active destination.

Thus for sctp_select_active_and_retran_path(), we keep track of
the best, if any, transport that is in PF state and in case no
ACTIVE transport has been found (hence trans_{pri,sec} is NULL),
we select the best out of the three: current primary_path and
retran_path as well as a possible PF transport.

The secondary may still camp on the original primary_path as
before. The change in sctp_trans_elect_best() with a more fine
grained tie selection also improves at the same time path selection
for sctp_assoc_update_retran_path() in case of non-ACTIVE states.

  [1] http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/associola.c | 50 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 45 insertions(+), 5 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 620c99e..58bbb73 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1224,13 +1224,41 @@ static u8 sctp_trans_score(const struct sctp_transport *trans)
 	return sctp_trans_state_to_prio_map[trans->state];
 }
 
+static struct sctp_transport *sctp_trans_elect_tie(struct sctp_transport *trans1,
+						   struct sctp_transport *trans2)
+{
+	if (trans1->error_count > trans2->error_count) {
+		return trans2;
+	} else if (trans1->error_count == trans2->error_count &&
+		   ktime_after(trans2->last_time_heard,
+			       trans1->last_time_heard)) {
+		return trans2;
+	} else {
+		return trans1;
+	}
+}
+
 static struct sctp_transport *sctp_trans_elect_best(struct sctp_transport *curr,
 						    struct sctp_transport *best)
 {
+	u8 score_curr, score_best;
+
 	if (best == NULL)
 		return curr;
 
-	return sctp_trans_score(curr) > sctp_trans_score(best) ? curr : best;
+	score_curr = sctp_trans_score(curr);
+	score_best = sctp_trans_score(best);
+
+	/* First, try a score-based selection if both transport states
+	 * differ. If we're in a tie, lets try to make a more clever
+	 * decision here based on error counts and last time heard.
+	 */
+	if (score_curr > score_best)
+		return curr;
+	else if (score_curr == score_best)
+		return sctp_trans_elect_tie(curr, best);
+	else
+		return best;
 }
 
 void sctp_assoc_update_retran_path(struct sctp_association *asoc)
@@ -1274,14 +1302,23 @@ void sctp_assoc_update_retran_path(struct sctp_association *asoc)
 static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
 {
 	struct sctp_transport *trans, *trans_pri = NULL, *trans_sec = NULL;
+	struct sctp_transport *trans_pf = NULL;
 
 	/* Look for the two most recently used active transports. */
 	list_for_each_entry(trans, &asoc->peer.transport_addr_list,
 			    transports) {
+		/* Skip uninteresting transports. */
 		if (trans->state == SCTP_INACTIVE ||
-		    trans->state == SCTP_UNCONFIRMED ||
-		    trans->state == SCTP_PF)
+		    trans->state == SCTP_UNCONFIRMED)
 			continue;
+		/* Keep track of the best PF transport from our
+		 * list in case we don't find an active one.
+		 */
+		if (trans->state == SCTP_PF) {
+			trans_pf = sctp_trans_elect_best(trans, trans_pf);
+			continue;
+		}
+		/* For active transports, pick the most recent ones. */
 		if (trans_pri == NULL ||
 		    ktime_after(trans->last_time_heard,
 				trans_pri->last_time_heard)) {
@@ -1317,10 +1354,13 @@ static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
 		trans_sec = trans_pri;
 
 	/* If we failed to find a usable transport, just camp on the
-	 * primary, even if they are inactive.
+	 * primary or retran, even if they are inactive, if possible
+	 * pick a PF iff it's the better choice.
 	 */
 	if (trans_pri == NULL) {
-		trans_pri = asoc->peer.primary_path;
+		trans_pri = sctp_trans_elect_best(asoc->peer.primary_path,
+						  asoc->peer.retran_path);
+		trans_pri = sctp_trans_elect_best(trans_pri, trans_pf);
 		trans_sec = asoc->peer.primary_path;
 	}
 
-- 
1.7.11.7
