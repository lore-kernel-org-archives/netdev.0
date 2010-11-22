From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 08/11] xfrm: Move IPsec replay detection functions to
 a separate file
Date: Mon, 22 Nov 2010 11:31:55 +0100
Message-ID: <20101122103155.GK1868@secunet.com>
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

To support multiple versions of replay detection, we move the replay
detection functions to a separate file and make them accessible
via function pointers contained in the struct xfrm_replay.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |   24 ++++++-
 net/xfrm/Makefile      |    2 +-
 net/xfrm/xfrm_input.c  |    5 +-
 net/xfrm/xfrm_output.c |   15 +----
 net/xfrm/xfrm_replay.c |  157 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_state.c  |  111 +---------------------------------
 net/xfrm/xfrm_user.c   |    4 +-
 7 files changed, 190 insertions(+), 128 deletions(-)
 create mode 100644 net/xfrm/xfrm_replay.c

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7f196e5..4b1559a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -190,6 +190,9 @@ struct xfrm_state {
 	struct xfrm_replay_state preplay;
 	struct xfrm_replay_state_esn *preplay_esn;
 
+	/* The functions for replay detection. */
+	struct xfrm_replay	*repl;
+
 	/* internal flag that only holds state for delayed aevent at the
 	 * moment
 	*/
@@ -259,6 +262,15 @@ struct km_event {
 	struct net *net;
 };
 
+struct xfrm_replay {
+	void	(*advance)(struct xfrm_state *x, __be32 net_seq);
+	int	(*check)(struct xfrm_state *x,
+			 struct sk_buff *skb,
+			 __be32 net_seq);
+	void	(*notify)(struct xfrm_state *x, int event);
+	int	(*overflow)(struct xfrm_state *x, struct sk_buff *skb);
+};
+
 struct net_device;
 struct xfrm_type;
 struct xfrm_dst;
@@ -682,6 +694,8 @@ extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 				    u32 auid, u32 ses, u32 secid);
 extern void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 					     struct sk_buff *skb);
+extern void xfrm_audit_state_replay(struct xfrm_state *x,
+				    struct sk_buff *skb, __be32 net_seq);
 extern void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family);
 extern void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
 				      __be32 net_spi, __be32 net_seq);
@@ -714,6 +728,11 @@ static inline void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 {
 }
 
+static inline void xfrm_audit_state_replay(struct xfrm_state *x,
+					   struct sk_buff *skb, __be32 net_seq)
+{
+}
+
 static inline void xfrm_audit_state_notfound_simple(struct sk_buff *skb,
 				      u16 family)
 {
@@ -1393,10 +1412,7 @@ extern int xfrm_state_delete(struct xfrm_state *x);
 extern int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
-extern int xfrm_replay_check(struct xfrm_state *x,
-			     struct sk_buff *skb, __be32 seq);
-extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
-extern void xfrm_replay_notify(struct xfrm_state *x, int event);
+extern int xfrm_init_replay(struct xfrm_state *x);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index c631047..aa429ee 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o xfrm_algo.o \
-		      xfrm_sysctl.o
+		      xfrm_sysctl.o xfrm_replay.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 obj-$(CONFIG_XFRM_IPCOMP) += xfrm_ipcomp.o
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b173b7f..55d5f5c 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -172,7 +172,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 		}
 
-		if (x->props.replay_window && xfrm_replay_check(x, skb, seq)) {
+		if (x->props.replay_window && x->repl->check(x, skb, seq)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATESEQERROR);
 			goto drop_unlock;
 		}
@@ -206,8 +206,7 @@ resume:
 		/* only the first xfrm gets the encap type */
 		encap_type = 0;
 
-		if (x->props.replay_window)
-			xfrm_replay_advance(x, seq);
+		x->repl->advance(x, seq);
 
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 4b63776..1aba03f 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -67,17 +67,10 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 			goto error;
 		}
 
-		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
-			XFRM_SKB_CB(skb)->seq.output.low = ++x->replay.oseq;
-			if (unlikely(x->replay.oseq == 0)) {
-				XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATESEQERROR);
-				x->replay.oseq--;
-				xfrm_audit_state_replay_overflow(x, skb);
-				err = -EOVERFLOW;
-				goto error;
-			}
-			if (xfrm_aevent_is_on(net))
-				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+		err = x->repl->overflow(x, skb);
+		if (err) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATESEQERROR);
+			goto error;
 		}
 
 		x->curlft.bytes += skb->len;
diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
new file mode 100644
index 0000000..598ca4c
--- /dev/null
+++ b/net/xfrm/xfrm_replay.c
@@ -0,0 +1,157 @@
+/*
+ * xfrm_replay.c - xfrm replay detection, derived from xfrm_state.c.
+ *
+ * Copyright (C) 2009 secunet Security Networks AG
+ * Copyright (C) 2009 Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#include <net/xfrm.h>
+
+static void xfrm_replay_notify(struct xfrm_state *x, int event)
+{
+	struct km_event c;
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
+		    (x->replay.seq - x->preplay.seq < x->replay_maxdiff) &&
+		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff)) {
+			if (x->xflags & XFRM_TIME_DEFER)
+				event = XFRM_REPLAY_TIMEOUT;
+			else
+				return;
+		}
+
+		break;
+
+	case XFRM_REPLAY_TIMEOUT:
+		if (memcmp(&x->replay, &x->preplay,
+			   sizeof(struct xfrm_replay_state)) == 0) {
+			x->xflags |= XFRM_TIME_DEFER;
+			return;
+		}
+
+		break;
+	}
+
+	memcpy(&x->preplay, &x->replay, sizeof(struct xfrm_replay_state));
+	c.event = XFRM_MSG_NEWAE;
+	c.data.aevent = event;
+	km_state_notify(x, &c);
+
+	if (x->replay_maxage &&
+	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
+		x->xflags &= ~XFRM_TIME_DEFER;
+}
+
+static int xfrm_replay_overflow(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct net *net = xs_net(x);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		XFRM_SKB_CB(skb)->seq.output.low = ++x->replay.oseq;
+		if (unlikely(x->replay.oseq == 0)) {
+			x->replay.oseq--;
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
+static int xfrm_replay_check(struct xfrm_state *x,
+		      struct sk_buff *skb, __be32 net_seq)
+{
+	u32 diff;
+	u32 seq = ntohl(net_seq);
+
+	if (unlikely(seq == 0))
+		goto err;
+
+	if (likely(seq > x->replay.seq))
+		return 0;
+
+	diff = x->replay.seq - seq;
+	if (diff >= min_t(unsigned int, x->props.replay_window,
+			  sizeof(x->replay.bitmap) * 8)) {
+		x->stats.replay_window++;
+		goto err;
+	}
+
+	if (x->replay.bitmap & (1U << diff)) {
+		x->stats.replay++;
+		goto err;
+	}
+	return 0;
+
+err:
+	xfrm_audit_state_replay(x, skb, net_seq);
+	return -EINVAL;
+}
+
+static void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
+{
+	u32 diff;
+	u32 seq = ntohl(net_seq);
+
+	if (!x->props.replay_window)
+		return;
+
+	if (seq > x->replay.seq) {
+		diff = seq - x->replay.seq;
+		if (diff < x->props.replay_window)
+			x->replay.bitmap = ((x->replay.bitmap) << diff) | 1;
+		else
+			x->replay.bitmap = 1;
+		x->replay.seq = seq;
+	} else {
+		diff = x->replay.seq - seq;
+		x->replay.bitmap |= (1U << diff);
+	}
+
+	if (xfrm_aevent_is_on(xs_net(x)))
+		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
+}
+
+static struct xfrm_replay xfrm_replay_legacy = {
+	.advance	= xfrm_replay_advance,
+	.check		= xfrm_replay_check,
+	.notify		= xfrm_replay_notify,
+	.overflow	= xfrm_replay_overflow,
+};
+
+int xfrm_init_replay(struct xfrm_state *x)
+{
+	x->repl = &xfrm_replay_legacy;
+
+	return 0;
+}
+EXPORT_SYMBOL(xfrm_init_replay);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index eb96ce5..a5035c0 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -42,13 +42,6 @@ static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
-#ifdef CONFIG_AUDITSYSCALL
-static void xfrm_audit_state_replay(struct xfrm_state *x,
-				    struct sk_buff *skb, __be32 net_seq);
-#else
-#define xfrm_audit_state_replay(x, s, sq)	do { ; } while (0)
-#endif /* CONFIG_AUDITSYSCALL */
-
 static inline unsigned int xfrm_dst_hash(struct net *net,
 					 xfrm_address_t *daddr,
 					 xfrm_address_t *saddr,
@@ -1609,54 +1602,6 @@ void xfrm_state_walk_done(struct xfrm_state_walk *walk)
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
 
-
-void xfrm_replay_notify(struct xfrm_state *x, int event)
-{
-	struct km_event c;
-	/* we send notify messages in case
-	 *  1. we updated on of the sequence numbers, and the seqno difference
-	 *     is at least x->replay_maxdiff, in this case we also update the
-	 *     timeout of our timer function
-	 *  2. if x->replay_maxage has elapsed since last update,
-	 *     and there were changes
-	 *
-	 *  The state structure must be locked!
-	 */
-
-	switch (event) {
-	case XFRM_REPLAY_UPDATE:
-		if (x->replay_maxdiff &&
-		    (x->replay.seq - x->preplay.seq < x->replay_maxdiff) &&
-		    (x->replay.oseq - x->preplay.oseq < x->replay_maxdiff)) {
-			if (x->xflags & XFRM_TIME_DEFER)
-				event = XFRM_REPLAY_TIMEOUT;
-			else
-				return;
-		}
-
-		break;
-
-	case XFRM_REPLAY_TIMEOUT:
-		if ((x->replay.seq == x->preplay.seq) &&
-		    (x->replay.bitmap == x->preplay.bitmap) &&
-		    (x->replay.oseq == x->preplay.oseq)) {
-			x->xflags |= XFRM_TIME_DEFER;
-			return;
-		}
-
-		break;
-	}
-
-	memcpy(&x->preplay, &x->replay, sizeof(struct xfrm_replay_state));
-	c.event = XFRM_MSG_NEWAE;
-	c.data.aevent = event;
-	km_state_notify(x, &c);
-
-	if (x->replay_maxage &&
-	    !mod_timer(&x->rtimer, jiffies + x->replay_maxage))
-		x->xflags &= ~XFRM_TIME_DEFER;
-}
-
 static void xfrm_replay_timer_handler(unsigned long data)
 {
 	struct xfrm_state *x = (struct xfrm_state*)data;
@@ -1665,7 +1610,7 @@ static void xfrm_replay_timer_handler(unsigned long data)
 
 	if (x->km.state == XFRM_STATE_VALID) {
 		if (xfrm_aevent_is_on(xs_net(x)))
-			xfrm_replay_notify(x, XFRM_REPLAY_TIMEOUT);
+			x->repl->notify(x, XFRM_REPLAY_TIMEOUT);
 		else
 			x->xflags |= XFRM_TIME_DEFER;
 	}
@@ -1673,57 +1618,6 @@ static void xfrm_replay_timer_handler(unsigned long data)
 	spin_unlock(&x->lock);
 }
 
-int xfrm_replay_check(struct xfrm_state *x,
-		      struct sk_buff *skb, __be32 net_seq)
-{
-	u32 diff;
-	u32 seq = ntohl(net_seq);
-
-	if (unlikely(seq == 0))
-		goto err;
-
-	if (likely(seq > x->replay.seq))
-		return 0;
-
-	diff = x->replay.seq - seq;
-	if (diff >= min_t(unsigned int, x->props.replay_window,
-			  sizeof(x->replay.bitmap) * 8)) {
-		x->stats.replay_window++;
-		goto err;
-	}
-
-	if (x->replay.bitmap & (1U << diff)) {
-		x->stats.replay++;
-		goto err;
-	}
-	return 0;
-
-err:
-	xfrm_audit_state_replay(x, skb, net_seq);
-	return -EINVAL;
-}
-
-void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
-{
-	u32 diff;
-	u32 seq = ntohl(net_seq);
-
-	if (seq > x->replay.seq) {
-		diff = seq - x->replay.seq;
-		if (diff < x->props.replay_window)
-			x->replay.bitmap = ((x->replay.bitmap) << diff) | 1;
-		else
-			x->replay.bitmap = 1;
-		x->replay.seq = seq;
-	} else {
-		diff = x->replay.seq - seq;
-		x->replay.bitmap |= (1U << diff);
-	}
-
-	if (xfrm_aevent_is_on(xs_net(x)))
-		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
-}
-
 static LIST_HEAD(xfrm_km_list);
 static DEFINE_RWLOCK(xfrm_km_lock);
 
@@ -2236,7 +2130,7 @@ void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay_overflow);
 
-static void xfrm_audit_state_replay(struct xfrm_state *x,
+void xfrm_audit_state_replay(struct xfrm_state *x,
 			     struct sk_buff *skb, __be32 net_seq)
 {
 	struct audit_buffer *audit_buf;
@@ -2251,6 +2145,7 @@ static void xfrm_audit_state_replay(struct xfrm_state *x,
 			 spi, spi, ntohl(net_seq));
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL_GPL(xfrm_audit_state_replay);
 
 void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family)
 {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8bae6b2..77452dc 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -464,8 +464,10 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	x->preplay.seq = x->replay.seq+x->replay_maxdiff;
 	x->preplay.oseq = x->replay.oseq +x->replay_maxdiff;
 
-	/* override default values from above */
+	if ((err = xfrm_init_replay(x)))
+		goto error;
 
+	/* override default values from above */
 	xfrm_update_ae_params(x, attrs);
 
 	return x;
-- 
1.7.0.4
