From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/3] xfrm: Fix replay notification for esn.
Date: Wed, 27 Mar 2013 08:41:07 +0100
Message-ID: <1364370068-20025-3-git-send-email-steffen.klassert@secunet.com>
References: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53935 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753842Ab3C0Hl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 03:41:26 -0400
In-Reply-To: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We may miscalculate the sequence number difference from the
last time we send a notification if a sequence number wrap
occured in the meantime. We fix this by adding a separate
replay notify function for esn. Here we take the high bits
of the sequence number into account to calculate the
difference.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |   68 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 67 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 35754cc..a390673 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -334,6 +334,72 @@ static void xfrm_replay_notify_bmp(struct xfrm_state *x, int event)
 		x->xflags &= ~XFRM_TIME_DEFER;
 }
 
+static void xfrm_replay_notify_esn(struct xfrm_state *x, int event)
+{
+	u32 seq_diff, oseq_diff;
+	struct km_event c;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	struct xfrm_replay_state_esn *preplay_esn = x->preplay_esn;
+
+	/* we send notify messages in case
+	 *  1. we updated on of the sequence numbers, and the seqno difference
+	 *     is at least x->replay_maxdiff, in this case we also update the
+	 *     timeout of our timer function
+	 *  2. if x->replay_maxage has elapsed since last update,
+	 *     and there were changes
+	 *
+	 *  The state structure must be locked!
+	 */
+
+	switch (event) {
+	case XFRM_REPLAY_UPDATE:
+		if (!x->replay_maxdiff)
+			break;
+
+		if (replay_esn->seq_hi == preplay_esn->seq_hi)
+			seq_diff = replay_esn->seq - preplay_esn->seq;
+		else
+			seq_diff = UINT_MAX - preplay_esn->seq
+				   + replay_esn->seq;
+
+		if (replay_esn->oseq_hi == preplay_esn->oseq_hi)
+			oseq_diff = replay_esn->oseq - preplay_esn->oseq;
+		else
+			oseq_diff = UINT_MAX - preplay_esn->oseq
+				    + replay_esn->oseq;
+
+		if (seq_diff < x->replay_maxdiff &&
+		    oseq_diff < x->replay_maxdiff) {
+
+			if (x->xflags & XFRM_TIME_DEFER)
+				event = XFRM_REPLAY_TIMEOUT;
+			else
+				return;
+		}
+
+		break;
+
+	case XFRM_REPLAY_TIMEOUT:
+		if (memcmp(x->replay_esn, x->preplay_esn,
+			   xfrm_replay_state_esn_len(replay_esn)) == 0) {
+			x->xflags |= XFRM_TIME_DEFER;
+			return;
+		}
+
+		break;
+	}
+
+	memcpy(x->preplay_esn, x->replay_esn,
+	       xfrm_replay_state_esn_len(replay_esn));
+	c.event = XFRM_MSG_NEWAE;
+	c.data.aevent = event;
+	km_state_notify(x, &c);
+
+	if (x->replay_maxage &&
+	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+		x->xflags &= ~XFRM_TIME_DEFER;
+}
+
 static int xfrm_replay_overflow_esn(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = 0;
@@ -510,7 +576,7 @@ static struct xfrm_replay xfrm_replay_esn = {
 	.advance	= xfrm_replay_advance_esn,
 	.check		= xfrm_replay_check_esn,
 	.recheck	= xfrm_replay_recheck_esn,
-	.notify		= xfrm_replay_notify_bmp,
+	.notify		= xfrm_replay_notify_esn,
 	.overflow	= xfrm_replay_overflow_esn,
 };
 
-- 
1.7.9.5
