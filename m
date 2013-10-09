From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/7] xfrm: Fix aevent generation for each received packet
Date: Wed,  9 Oct 2013 12:59:09 +0200
Message-ID: <1381316351-14418-6-git-send-email-steffen.klassert@secunet.com>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51345 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757037Ab3JIK7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:30 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Egerer <thomas.egerer@secunet.com>

If asynchronous events are enabled for a particular netlink socket,
the notify function is called by the advance function. The notify
function creates and dispatches a km_event if a replay timeout occurred,
or at least replay_maxdiff packets have been received since the last
asynchronous event has been sent. The function is supposed to return if
neither of the two events were detected for a state, or replay_maxdiff
is equal to zero.
Replay_maxdiff is initialized in xfrm_state_construct to the value of
the xfrm.sysctl_aevent_rseqth (2 by default), and updated if for a state
if the netlink attribute XFRMA_REPLAY_THRESH is set.
If, however, replay_maxdiff is set to zero, then all of the three notify
implementations perform a break from the switch statement instead of
checking whether a timeout occurred, and -- if not -- return.  As a
result an asynchronous event is generated for every replay update of a
state that has a zero replay_maxdiff value.
This patch modifies the notify functions such that they immediately
return if replay_maxdiff has the value zero, unless a timeout occurred.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |   51 +++++++++++++++++++++++++-----------------------
 1 file changed, 27 insertions(+), 24 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index eeca388..dab57da 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -61,9 +61,9 @@ static void xfrm_replay_notify(struct xfrm_state *x, int event)
 
 	switch (event) {
 	case XFRM_REPLAY_UPDATE:
-		if (x->replay_maxdiff &&
-		    (x->replay.seq - x->preplay.seq < x->replay_maxdiff) &&
-		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff)) {
+		if (!x->replay_maxdiff ||
+		    ((x->replay.seq - x->preplay.seq < x->replay_maxdiff) &&
+		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff))) {
 			if (x->xflags & XFRM_TIME_DEFER)
 				event = XFRM_REPLAY_TIMEOUT;
 			else
@@ -301,9 +301,10 @@ static void xfrm_replay_notify_bmp(struct xfrm_state *x, int event)
 
 	switch (event) {
 	case XFRM_REPLAY_UPDATE:
-		if (x->replay_maxdiff &&
-		    (replay_esn->seq - preplay_esn->seq < x->replay_maxdiff) &&
-		    (replay_esn->oseq - preplay_esn->oseq < x->replay_maxdiff)) {
+		if (!x->replay_maxdiff ||
+		    ((replay_esn->seq - preplay_esn->seq < x->replay_maxdiff) &&
+		    (replay_esn->oseq - preplay_esn->oseq
+		     < x->replay_maxdiff))) {
 			if (x->xflags & XFRM_TIME_DEFER)
 				event = XFRM_REPLAY_TIMEOUT;
 			else
@@ -352,28 +353,30 @@ static void xfrm_replay_notify_esn(struct xfrm_state *x, int event)
 
 	switch (event) {
 	case XFRM_REPLAY_UPDATE:
-		if (!x->replay_maxdiff)
-			break;
-
-		if (replay_esn->seq_hi == preplay_esn->seq_hi)
-			seq_diff = replay_esn->seq - preplay_esn->seq;
-		else
-			seq_diff = ~preplay_esn->seq + replay_esn->seq + 1;
-
-		if (replay_esn->oseq_hi == preplay_esn->oseq_hi)
-			oseq_diff = replay_esn->oseq - preplay_esn->oseq;
-		else
-			oseq_diff = ~preplay_esn->oseq + replay_esn->oseq + 1;
-
-		if (seq_diff < x->replay_maxdiff &&
-		    oseq_diff < x->replay_maxdiff) {
+		if (x->replay_maxdiff) {
+			if (replay_esn->seq_hi == preplay_esn->seq_hi)
+				seq_diff = replay_esn->seq - preplay_esn->seq;
+			else
+				seq_diff = ~preplay_esn->seq + replay_esn->seq
+					   + 1;
 
-			if (x->xflags & XFRM_TIME_DEFER)
-				event = XFRM_REPLAY_TIMEOUT;
+			if (replay_esn->oseq_hi == preplay_esn->oseq_hi)
+				oseq_diff = replay_esn->oseq
+					    - preplay_esn->oseq;
 			else
-				return;
+				oseq_diff = ~preplay_esn->oseq
+					    + replay_esn->oseq + 1;
+
+			if (seq_diff >= x->replay_maxdiff ||
+			    oseq_diff >= x->replay_maxdiff)
+				break;
 		}
 
+		if (x->xflags & XFRM_TIME_DEFER)
+			event = XFRM_REPLAY_TIMEOUT;
+		else
+			return;
+
 		break;
 
 	case XFRM_REPLAY_TIMEOUT:
-- 
1.7.9.5
