From: jamal <hadi@cyberus.ca>
Subject: [XFRM] Fix aevent timer
Date: Thu, 13 Apr 2006 08:55:58 -0400
Message-ID: <1144932959.5262.5.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-eS+jfo6wA2B38UpR7JwO"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:44485 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964889AbWDMM4E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:56:04 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FU1Mi-0005Vw-Nb
	for netdev@vger.kernel.org; Thu, 13 Apr 2006 08:56:04 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eS+jfo6wA2B38UpR7JwO
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Finally got an opportunity to test this. I have incorporated all the
feedback and it passes all the scenarios i know.

Dave, please apply to Linus tree since this is a bug fix.

cheers,
jamal

--=-eS+jfo6wA2B38UpR7JwO
Content-Disposition: attachment; filename=aevent-fix-timer-5
Content-Type: text/plain; name=aevent-fix-timer-5; charset=UTF-8
Content-Transfer-Encoding: 7bit


Send aevent immediately if we have sent nothing since last timer and
this is the first packet.
Fixes a corner case when packet threshold is very high, the timer low
and a very low packet rate input which is bursty.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---

 include/net/xfrm.h    |    8 ++++++++
 net/xfrm/xfrm_state.c |   25 +++++++++++++++++++------
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0d5529c..b77d333 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -143,6 +143,11 @@ struct xfrm_state
 	/* Replay detection state at the time we sent the last notification */
 	struct xfrm_replay_state preplay;
 
+	/* internal flag that only holds state for delayed aevent at the 
+	 * moment
+	*/
+	u32			xflags;
+
 	/* Replay detection notification settings */
 	u32			replay_maxage;
 	u32			replay_maxdiff;
@@ -167,6 +172,9 @@ struct xfrm_state
 	 * interpreted by xfrm_type methods. */
 	void			*data;
 };
+
+/* xflags - make enum if more show up */
+#define XFRM_TIME_DEFER	1
 
 enum {
 	XFRM_STATE_VOID,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a8e14dc..3dc3e1f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -805,16 +805,22 @@ void xfrm_replay_notify(struct xfrm_stat
 	case XFRM_REPLAY_UPDATE:
 		if (x->replay_maxdiff &&
 		    (x->replay.seq - x->preplay.seq < x->replay_maxdiff) &&
-		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff))
-			return;
+		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff)) {
+			if (x->xflags & XFRM_TIME_DEFER)
+				event = XFRM_REPLAY_TIMEOUT;
+			else
+				return;
+		}
 
 		break;
 
 	case XFRM_REPLAY_TIMEOUT:
 		if ((x->replay.seq == x->preplay.seq) &&
 		    (x->replay.bitmap == x->preplay.bitmap) &&
-		    (x->replay.oseq == x->preplay.oseq))
+		    (x->replay.oseq == x->preplay.oseq)) {
+			x->xflags |= XFRM_TIME_DEFER;
 			return;
+		}
 
 		break;
 	}
@@ -825,8 +831,10 @@ void xfrm_replay_notify(struct xfrm_stat
 	km_state_notify(x, &c);
 
 	if (x->replay_maxage &&
-	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage)) {
 		xfrm_state_hold(x);
+		x->xflags &= ~XFRM_TIME_DEFER;
+	}
 }
 EXPORT_SYMBOL(xfrm_replay_notify);
 
@@ -836,10 +844,15 @@ static void xfrm_replay_timer_handler(un
 
 	spin_lock(&x->lock);
 
-	if (xfrm_aevent_is_on() && x->km.state == XFRM_STATE_VALID)
-		xfrm_replay_notify(x, XFRM_REPLAY_TIMEOUT);
+	if (x->km.state == XFRM_STATE_VALID) {
+		if (xfrm_aevent_is_on())
+			xfrm_replay_notify(x, XFRM_REPLAY_TIMEOUT);
+		else
+			x->xflags |= XFRM_TIME_DEFER;
+	}
 
 	spin_unlock(&x->lock);
+	xfrm_state_put(x);
 }
 
 int xfrm_replay_check(struct xfrm_state *x, u32 seq)

--=-eS+jfo6wA2B38UpR7JwO--

