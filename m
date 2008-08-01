From: Chris Larson <clarson@mvista.com>
Subject: [PATCH 2/2] net: fix missing pneigh entries in the neighbor seq_file code
Date: Fri,  1 Aug 2008 14:49:49 -0700
Message-ID: <1217627389-9653-2-git-send-email-clarson@mvista.com>
References: <1217627389-9653-1-git-send-email-clarson@mvista.com>
Cc: Chris Larson <clarson@mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:20633 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760231AbYHAVtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 17:49:35 -0400
In-Reply-To: <1217627389-9653-1-git-send-email-clarson@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pneigh entries exist, but the user's read buffer isn't sufficient to
hold them all, one of the pneigh entries will be missing from the results.

In neigh_get_idx_any, the number of elements which neigh_get_idx
encountered is not correctly subtracted from the position number before
the call to pneigh_get_idx.  neigh_get_idx reduces the position by 1 for
each call to neigh_get_next, but it does not reduce it by one for the
first element (neigh_get_first). The patch alters the neigh_get_idx and
pneigh_get_idx functions to subtract one from pos, for the first element,
when pos is non-zero.

Signed-off-by: Chris Larson <clarson@mvista.com>
---
 net/core/neighbour.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a57de75..9d92e41 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2281,6 +2281,7 @@ static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
 	struct neighbour *n = neigh_get_first(seq);
 
 	if (n) {
+		--(*pos);
 		while (*pos) {
 			n = neigh_get_next(seq, n, pos);
 			if (!n)
@@ -2341,6 +2342,7 @@ static struct pneigh_entry *pneigh_get_idx(struct seq_file *seq, loff_t *pos)
 	struct pneigh_entry *pn = pneigh_get_first(seq);
 
 	if (pn) {
+		--(*pos);
 		while (*pos) {
 			pn = pneigh_get_next(seq, pn, pos);
 			if (!pn)
@@ -2354,10 +2356,11 @@ static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
 	void *rc;
+	loff_t idxpos = *pos;
 
-	rc = neigh_get_idx(seq, pos);
+	rc = neigh_get_idx(seq, &idxpos);
 	if (!rc && !(state->flags & NEIGH_SEQ_NEIGH_ONLY))
-		rc = pneigh_get_idx(seq, pos);
+		rc = pneigh_get_idx(seq, &idxpos);
 
 	return rc;
 }
@@ -2366,7 +2369,6 @@ void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl
 	__acquires(tbl->lock)
 {
 	struct neigh_seq_state *state = seq->private;
-	loff_t pos_minus_one;
 
 	state->tbl = tbl;
 	state->bucket = 0;
@@ -2374,8 +2376,7 @@ void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl
 
 	read_lock_bh(&tbl->lock);
 
-	pos_minus_one = *pos - 1;
-	return *pos ? neigh_get_idx_any(seq, &pos_minus_one) : SEQ_START_TOKEN;
+	return *pos ? neigh_get_idx_any(seq, pos) : SEQ_START_TOKEN;
 }
 EXPORT_SYMBOL(neigh_seq_start);
 
-- 
1.5.5.1.147.g867f

