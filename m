From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 10/11] xfrm: Add support for IPsec extended sequence
 numbers
Date: Mon, 22 Nov 2010 11:33:32 +0100
Message-ID: <20101122103332.GM1868@secunet.com>
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

This patch adds support for IPsec extended sequence numbers (esn)
as defined in RFC 4303. The bits to manage the anti-replay window
are based on a patch from Alex Badea.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |    1 +
 net/xfrm/xfrm_input.c  |    4 +
 net/xfrm/xfrm_replay.c |  190 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 194 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4b1559a..a6ef001 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1412,6 +1412,7 @@ extern int xfrm_state_delete(struct xfrm_state *x);
 extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
+extern u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
 extern int xfrm_init_replay(struct xfrm_state *x);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 55d5f5c..872065c 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -107,6 +107,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	struct net *net = dev_net(skb->dev);
 	int err;
 	__be32 seq;
+	__be32 seq_hi;
 	struct xfrm_state *x;
 	xfrm_address_t *daddr;
 	struct xfrm_mode *inner_mode;
@@ -184,7 +185,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
+		seq_hi = htonl(xfrm_replay_seqhi(x, seq));
+
 		XFRM_SKB_CB(skb)->seq.input.low = seq;
+		XFRM_SKB_CB(skb)->seq.input.hi = seq_hi;
 
 		nexthdr = x->type->input(x, skb);
 
diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index be2c9eb..52433b5 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -20,6 +20,31 @@
 
 #include <net/xfrm.h>
 
+u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq)
+{
+	u32 seq, seq_hi, bottom;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+
+	if (!(x->props.flags & XFRM_STATE_ESN))
+		return 0;
+
+	seq = ntohl(net_seq);
+	seq_hi = replay_esn->seq_hi;
+	bottom = replay_esn->seq - replay_esn->replay_window + 1;
+
+	if (likely(replay_esn->seq >= replay_esn->replay_window - 1)) {
+		/* A. same subspace */
+		if (unlikely(seq < bottom))
+			seq_hi++;
+	} else {
+		/* B. window spans two subspaces */
+		if (unlikely(seq >= bottom))
+			seq_hi--;
+	}
+
+	return seq_hi;
+}
+
 static void xfrm_replay_notify(struct xfrm_state *x, int event)
 {
 	struct km_event c;
@@ -313,6 +338,160 @@ static void xfrm_replay_notify_bmp(struct xfrm_state *x, int event)
 		x->xflags &= ~XFRM_TIME_DEFER;
 }
 
+static int xfrm_replay_overflow_esn(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	struct net *net = xs_net(x);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		XFRM_SKB_CB(skb)->seq.output.low = ++replay_esn->oseq;
+		XFRM_SKB_CB(skb)->seq.output.hi = replay_esn->oseq_hi;
+
+		if (unlikely(replay_esn->oseq == 0)) {
+			XFRM_SKB_CB(skb)->seq.output.hi = ++replay_esn->oseq_hi;
+
+			if (replay_esn->oseq_hi == 0) {
+				replay_esn->oseq--;
+				replay_esn->oseq_hi--;
+				xfrm_audit_state_replay_overflow(x, skb);
+				err = -EOVERFLOW;
+
+				return err;
+			}
+		}
+		if (xfrm_aevent_is_on(net))
+			x->repl->notify(x, XFRM_REPLAY_UPDATE);
+	}
+
+	return err;
+}
+
+static int xfrm_replay_check_esn(struct xfrm_state *x,
+				 struct sk_buff *skb, __be32 net_seq)
+{
+	unsigned int bitnr, nr;
+	u32 diff;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	u32 seq = ntohl(net_seq);
+	u32 pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+	u32 wsize = replay_esn->replay_window;
+	u32 top = replay_esn->seq;
+	u32 bottom = top - wsize + 1;
+
+	if (unlikely(seq == 0 && replay_esn->seq_hi == 0 &&
+		     (replay_esn->seq < replay_esn->replay_window - 1)))
+		goto err;
+
+	diff = top - seq;
+
+	if (likely(top >= wsize - 1)) {
+		/* A. same subspace */
+		if (likely(seq > top) || seq < bottom)
+			return 0;
+	} else {
+		/* B. window spans two subspaces */
+		if (likely(seq > top && seq < bottom))
+			return 0;
+		if (seq >= bottom)
+			diff = ~seq + top + 1;
+	}
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
+static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
+{
+	unsigned int bitnr, nr, i;
+	int wrap;
+	u32 diff, pos, seq, seq_hi;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+
+	if (!replay_esn->replay_window)
+		return;
+
+	seq = ntohl(net_seq);
+	pos = (replay_esn->seq - 1) % replay_esn->replay_window;
+	seq_hi = xfrm_replay_seqhi(x, net_seq);
+	wrap = seq_hi - replay_esn->seq_hi;
+
+	if ((!wrap && seq > replay_esn->seq) || wrap > 0) {
+		if (likely(!wrap))
+			diff = seq - replay_esn->seq;
+		else
+			diff = ~replay_esn->seq + seq + 1;
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
+
+		if (unlikely(wrap > 0))
+			replay_esn->seq_hi++;
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
 static struct xfrm_replay xfrm_replay_legacy = {
 	.advance	= xfrm_replay_advance,
 	.check		= xfrm_replay_check,
@@ -327,9 +506,18 @@ static struct xfrm_replay xfrm_replay_bmp = {
 	.overflow	= xfrm_replay_overflow_bmp,
 };
 
+static struct xfrm_replay xfrm_replay_esn = {
+	.advance	= xfrm_replay_advance_esn,
+	.check		= xfrm_replay_check_esn,
+	.notify		= xfrm_replay_notify_bmp,
+	.overflow	= xfrm_replay_overflow_esn,
+};
+
 int xfrm_init_replay(struct xfrm_state *x)
 {
-	if (x->replay_esn)
+	if ((x->props.flags & XFRM_STATE_ESN) && x->replay_esn)
+		x->repl = &xfrm_replay_esn;
+	else if (x->replay_esn)
 		x->repl = &xfrm_replay_bmp;
 	else
 		x->repl = &xfrm_replay_legacy;
-- 
1.7.0.4
