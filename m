From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 09/11] xfrm: Support anti-replay window size bigger
 than 32 packets
Date: Mon, 22 Nov 2010 11:32:41 +0100
Message-ID: <20101122103241.GL1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As it is, the anti-replay bitmap in struct xfrm_replay_state can
only accomodate 32 packets. Even though it is possible to configure
anti-replay window sizes up to 255 packets from userspace. So we
reject any packet with a sequence number within the configured window
but outside the bitmap. With this patch, we represent the anti-replay
window as a bitmap of variable length that can be accessed via the
new struct xfrm_replay_state_esn. Thus, we have no limit on the
window size anymore. To use the new anti-replay window implementantion,
new userspace tools are required. We leave the old implementation
untouched to stay in sync with old userspace tools.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c |  185 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 184 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 598ca4c..be2c9eb 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -141,6 +141,178 @@ static void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
 
+static int xfrm_replay_overflow_bmp(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	struct net *net = xs_net(x);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		XFRM_SKB_CB(skb)->seq.output.low = ++replay_esn->oseq;
+		if (unlikely(replay_esn->oseq == 0)) {
+			replay_esn->oseq--;
+			xfrm_audit_state_replay_overflow(x, skb);
+			err = -EOVERFLOW;
+
+			return err;
+		}
+		if (xfrm_aevent_is_on(net))
+			x->repl->notify(x, XFRM_REPLAY_UPDATE);
+	}
+
+	return err;
+}
+
+static int xfrm_replay_check_bmp(struct xfrm_state *x,
+				 struct sk_buff *skb, __be32 net_seq)
+{
+	unsigned int bitnr, nr;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	u32 seq = ntohl(net_seq);
+	u32 diff =  replay_esn->seq - seq;
+	u32 pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
+	if (unlikely(seq == 0))
+		goto err;
+
+	if (likely(seq > replay_esn->seq))
+		return 0;
+
+	if (diff >= replay_esn->replay_window) {
+		x->stats.replay_window++;
+		goto err;
+	}
+
+	if (pos >= diff) {
+		bitnr = (pos - diff) % replay_esn->replay_window;
+		nr = bitnr >> 5;
+		bitnr = bitnr & 0x1F;
+		if (replay_esn->bmp[nr] & (1U << bitnr))
+			goto err_replay;
+	} else {
+		bitnr = replay_esn->replay_window - (diff - pos);
+		nr = bitnr >> 5;
+		bitnr = bitnr & 0x1F;
+		if (replay_esn->bmp[nr] & (1U << bitnr))
+			goto err_replay;
+	}
+	return 0;
+
+err_replay:
+	x->stats.replay++;
+err:
+	xfrm_audit_state_replay(x, skb, net_seq);
+	return -EINVAL;
+}
+
+static void xfrm_replay_advance_bmp(struct xfrm_state *x, __be32 net_seq)
+{
+	unsigned int bitnr, nr, i;
+	u32 diff;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	u32 seq = ntohl(net_seq);
+	u32 pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+
+	if (!replay_esn->replay_window)
+		return;
+
+	if (seq > replay_esn->seq) {
+		diff = seq - replay_esn->seq;
+
+		if (diff < replay_esn->replay_window) {
+			for (i = 1; i < diff; i++) {
+				bitnr = (pos + i) % replay_esn->replay_window;
+				nr = bitnr >> 5;
+				bitnr = bitnr & 0x1F;
+				replay_esn->bmp[nr] &=  ~(1U << bitnr);
+			}
+
+			bitnr = (pos + diff) % replay_esn->replay_window;
+			nr = bitnr >> 5;
+			bitnr = bitnr & 0x1F;
+			replay_esn->bmp[nr] |= (1U << bitnr);
+		} else {
+			nr = replay_esn->replay_window >> 5;
+			for (i = 0; i <= nr; i++)
+				replay_esn->bmp[i] = 0;
+
+			bitnr = (pos + diff) % replay_esn->replay_window;
+			nr = bitnr >> 5;
+			bitnr = bitnr & 0x1F;
+			replay_esn->bmp[nr] |= (1U << bitnr);
+		}
+
+		replay_esn->seq = seq;
+	} else {
+		diff = replay_esn->seq - seq;
+
+		if (pos >= diff) {
+			bitnr = (pos - diff) % replay_esn->replay_window;
+			nr = bitnr >> 5;
+			bitnr = bitnr & 0x1F;
+			replay_esn->bmp[nr] |= (1U << bitnr);
+		} else {
+			bitnr = replay_esn->replay_window - (diff - pos);
+			nr = bitnr >> 5;
+			bitnr = bitnr & 0x1F;
+			replay_esn->bmp[nr] |= (1U << bitnr);
+		}
+	}
+
+	if (xfrm_aevent_is_on(xs_net(x)))
+		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+}
+
+static void xfrm_replay_notify_bmp(struct xfrm_state *x, int event)
+{
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
+		if (x->replay_maxdiff &&
+		    (replay_esn->seq - preplay_esn->seq < x->replay_maxdiff) &&
+		    (replay_esn->oseq - preplay_esn->oseq < x->replay_maxdiff)) {
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
 static struct xfrm_replay xfrm_replay_legacy = {
 	.advance	= xfrm_replay_advance,
 	.check		= xfrm_replay_check,
@@ -148,9 +320,20 @@ static struct xfrm_replay xfrm_replay_legacy = {
 	.overflow	= xfrm_replay_overflow,
 };
 
+static struct xfrm_replay xfrm_replay_bmp = {
+	.advance	= xfrm_replay_advance_bmp,
+	.check		= xfrm_replay_check_bmp,
+	.notify		= xfrm_replay_notify_bmp,
+	.overflow	= xfrm_replay_overflow_bmp,
+};
+
 int xfrm_init_replay(struct xfrm_state *x)
 {
-	x->repl = &xfrm_replay_legacy;
+	if (x->replay_esn)
+		x->repl = &xfrm_replay_bmp;
+	else
+		x->repl = &xfrm_replay_legacy;
+
 
 	return 0;
 }
-- 
1.7.0.4
