From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/3] XFRM: RFC4303 compliant auditing
Date: Thu, 20 Dec 2007 16:42:25 -0500
Message-ID: <20071220214225.12122.48656.stgit@flek.lan>
References: <20071220214200.12122.89628.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:49541
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751856AbXLTVqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 16:46:00 -0500
In-Reply-To: <20071220214200.12122.89628.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a number of new IPsec audit events to meet the auditing
requirements of RFC4303.  This includes audit hooks for the following events:

 * Could not find a valid SA [sections 2.1, 3.4.2]
   . xfrm_audit_state_notfound()
   . xfrm_audit_state_notfound_simple()

 * Sequence number overflow [section 3.3.3]
   . xfrm_audit_state_replay_overflow()

 * Replayed packet [section 3.4.3]
   . xfrm_audit_state_replay()

 * Integrity check failure [sections 3.4.4.1, 3.4.4.2]
   . xfrm_audit_state_icvfail()

While RFC4304 deals only with ESP most of the changes in this patch apply to
IPsec in general, i.e. both AH and ESP.  The one case, integrity check
failure, where ESP specific code had to be modified the same was done to the
AH code for the sake of consistency.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/xfrm.h     |   33 ++++++++--
 net/ipv4/ah4.c         |    4 +
 net/ipv4/esp4.c        |    1 
 net/ipv6/ah6.c         |    2 -
 net/ipv6/esp6.c        |    1 
 net/ipv6/xfrm6_input.c |    4 +
 net/xfrm/xfrm_input.c  |    6 +-
 net/xfrm/xfrm_output.c |    2 +
 net/xfrm/xfrm_policy.c |   14 ++--
 net/xfrm/xfrm_state.c  |  153 +++++++++++++++++++++++++++++++++++++++++++-----
 10 files changed, 184 insertions(+), 36 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac6cf09..941d5cd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -548,26 +548,33 @@ struct xfrm_audit
 };
 
 #ifdef CONFIG_AUDITSYSCALL
-static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 secid)
+static inline struct audit_buffer *xfrm_audit_start(const char *op)
 {
 	struct audit_buffer *audit_buf = NULL;
-	char *secctx;
-	u32 secctx_len;
 
+	if (audit_enabled == 0)
+		return NULL;
 	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
-			      AUDIT_MAC_IPSEC_EVENT);
+				    AUDIT_MAC_IPSEC_EVENT);
 	if (audit_buf == NULL)
 		return NULL;
+	audit_log_format(audit_buf, "op=%s", op);
+	return audit_buf;
+}
 
-	audit_log_format(audit_buf, "auid=%u", auid);
+static inline void xfrm_audit_helper_usrinfo(u32 auid, u32 secid,
+					     struct audit_buffer *audit_buf)
+{
+	char *secctx;
+	u32 secctx_len;
 
+	audit_log_format(audit_buf, " auid=%u", auid);
 	if (secid != 0 &&
 	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0) {
 		audit_log_format(audit_buf, " subj=%s", secctx);
 		security_release_secctx(secctx, secctx_len);
 	} else
 		audit_log_task_context(audit_buf);
-	return audit_buf;
 }
 
 extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
@@ -578,11 +585,22 @@ extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
 				 u32 auid, u32 secid);
 extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 				    u32 auid, u32 secid);
+extern void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
+					     struct sk_buff *skb);
+extern void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family);
+extern void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
+				      __be32 net_spi, __be32 net_seq);
+extern void xfrm_audit_state_icvfail(struct xfrm_state *x,
+				     struct sk_buff *skb, u8 proto);
 #else
 #define xfrm_audit_policy_add(x, r, a, s)	do { ; } while (0)
 #define xfrm_audit_policy_delete(x, r, a, s)	do { ; } while (0)
 #define xfrm_audit_state_add(x, r, a, s)	do { ; } while (0)
 #define xfrm_audit_state_delete(x, r, a, s)	do { ; } while (0)
+#define xfrm_audit_state_replay_overflow(x, s)	do { ; } while (0)
+#define xfrm_audit_state_notfound_simple(s, f)	do { ; } while (0)
+#define xfrm_audit_state_notfound(s, f, sp, sq)	do { ; } while (0)
+#define xfrm_audit_state_icvfail(x, s, p)	do { ; } while (0)
 #endif /* CONFIG_AUDITSYSCALL */
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
@@ -1193,7 +1211,8 @@ extern int xfrm_state_delete(struct xfrm_state *x);
 extern int xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
-extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
+extern int xfrm_replay_check(struct xfrm_state *x,
+			     struct sk_buff *skb, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index d76803a..ec8de0a 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -179,8 +179,10 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		err = ah_mac_digest(ahp, skb, ah->auth_data);
 		if (err)
 			goto unlock;
-		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len))
+		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_AH);
 			err = -EBADMSG;
+		}
 	}
 unlock:
 	spin_unlock(&x->lock);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 28ea5c7..b334c76 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -191,6 +191,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 			BUG();
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_ESP);
 			err = -EBADMSG;
 			goto unlock;
 		}
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 1b51d1e..2d32772 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -381,7 +381,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		if (err)
 			goto unlock;
 		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
-			LIMIT_NETDEBUG(KERN_WARNING "ipsec ah authentication error\n");
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_AH);
 			err = -EBADMSG;
 		}
 	}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 5bd5292..e10f10b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -186,6 +186,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 			BUG();
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_ESP);
 			ret = -EBADMSG;
 			goto unlock;
 		}
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 74f3aac..08b850a 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -136,8 +136,10 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		break;
 	}
 
-	if (!xfrm_vec_one)
+	if (!xfrm_vec_one) {
+		xfrm_audit_state_notfound_simple(skb, AF_INET6);
 		goto drop;
+	}
 
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 8624cbd..87e1aac 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -139,8 +139,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 
 		x = xfrm_state_lookup(daddr, spi, nexthdr, family);
-		if (x == NULL)
+		if (x == NULL) {
+			xfrm_audit_state_notfound(skb, family, spi, seq);
 			goto drop;
+		}
 
 		skb->sp->xvec[skb->sp->len++] = x;
 
@@ -151,7 +153,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if ((x->encap ? x->encap->encap_type : 0) != encap_type)
 			goto drop_unlock;
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
+		if (x->props.replay_window && xfrm_replay_check(x, skb, seq))
 			goto drop_unlock;
 
 		if (xfrm_state_check_expire(x))
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 26fa0cb..eb3333b 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -57,6 +57,8 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
+			if (unlikely(x->replay.oseq == 0))
+				xfrm_audit_state_replay_overflow(x, skb);
 			if (xfrm_aevent_is_on())
 				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c8f0656..97cebfe 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2323,12 +2323,11 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 {
 	struct audit_buffer *audit_buf;
 
-	if (audit_enabled == 0)
-		return;
-	audit_buf = xfrm_audit_start(auid, secid);
+	audit_buf = xfrm_audit_start("SPD-add");
 	if (audit_buf == NULL)
 		return;
-	audit_log_format(audit_buf, " op=SPD-add res=%u", result);
+	xfrm_audit_helper_usrinfo(auid, secid, audit_buf);
+	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
 }
@@ -2339,12 +2338,11 @@ void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
 {
 	struct audit_buffer *audit_buf;
 
-	if (audit_enabled == 0)
-		return;
-	audit_buf = xfrm_audit_start(auid, secid);
+	audit_buf = xfrm_audit_start("SPD-delete");
 	if (audit_buf == NULL)
 		return;
-	audit_log_format(audit_buf, " op=SPD-delete res=%u", result);
+	xfrm_audit_helper_usrinfo(auid, secid, audit_buf);
+	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
 }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index dd38e6f..1f00aeb 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -61,6 +61,13 @@ static unsigned int xfrm_state_genid;
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
+#ifdef CONFIG_AUDITSYSCALL
+static void xfrm_audit_state_replay(struct xfrm_state *x,
+				    struct sk_buff *skb, __be32 net_seq);
+#else
+#define xfrm_audit_state_replay(x, s, sq)	do { ; } while (0)
+#endif /* CONFIG_AUDITSYSCALL */
+
 static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr,
 					 xfrm_address_t *saddr,
 					 u32 reqid,
@@ -1609,13 +1616,14 @@ static void xfrm_replay_timer_handler(unsigned long data)
 	spin_unlock(&x->lock);
 }
 
-int xfrm_replay_check(struct xfrm_state *x, __be32 net_seq)
+int xfrm_replay_check(struct xfrm_state *x,
+		      struct sk_buff *skb, __be32 net_seq)
 {
 	u32 diff;
 	u32 seq = ntohl(net_seq);
 
 	if (unlikely(seq == 0))
-		return -EINVAL;
+		goto err;
 
 	if (likely(seq > x->replay.seq))
 		return 0;
@@ -1624,14 +1632,18 @@ int xfrm_replay_check(struct xfrm_state *x, __be32 net_seq)
 	if (diff >= min_t(unsigned int, x->props.replay_window,
 			  sizeof(x->replay.bitmap) * 8)) {
 		x->stats.replay_window++;
-		return -EINVAL;
+		goto err;
 	}
 
 	if (x->replay.bitmap & (1U << diff)) {
 		x->stats.replay++;
-		return -EINVAL;
+		goto err;
 	}
 	return 0;
+
+err:
+	xfrm_audit_state_replay(x, skb, net_seq);
+	return -EINVAL;	
 }
 EXPORT_SYMBOL(xfrm_replay_check);
 
@@ -1994,8 +2006,8 @@ void __init xfrm_state_init(void)
 }
 
 #ifdef CONFIG_AUDITSYSCALL
-static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
-					       struct audit_buffer *audit_buf)
+static inline void xfrm_audit_helper_sainfo(struct xfrm_state *x,
+					    struct audit_buffer *audit_buf)
 {
 	struct xfrm_sec_ctx *ctx = x->security;
 	u32 spi = ntohl(x->id.spi);
@@ -2022,18 +2034,45 @@ static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
 	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
 }
 
+static inline void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
+					     struct audit_buffer *audit_buf)
+{
+	struct iphdr *iph4;
+	struct ipv6hdr *iph6;
+
+	switch (family) {
+	case AF_INET:
+		iph4 = ip_hdr(skb);
+		audit_log_format(audit_buf,
+				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
+				 NIPQUAD(iph4->saddr),
+				 NIPQUAD(iph4->daddr));
+		break;
+	case AF_INET6:
+		iph6 = ipv6_hdr(skb);
+		audit_log_format(audit_buf,
+				 " src=" NIP6_FMT " dst=" NIP6_FMT
+				 " flowlbl=0x%x%x%x",
+				 NIP6(iph6->saddr),
+				 NIP6(iph6->daddr),
+				 iph6->flow_lbl[0] & 0x0f,
+				 iph6->flow_lbl[1],
+				 iph6->flow_lbl[2]);
+		break;
+	}
+}
+
 void xfrm_audit_state_add(struct xfrm_state *x, int result,
 			  u32 auid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
 
-	if (audit_enabled == 0)
-		return;
-	audit_buf = xfrm_audit_start(auid, secid);
+	audit_buf = xfrm_audit_start("SAD-add");
 	if (audit_buf == NULL)
 		return;
-	audit_log_format(audit_buf, " op=SAD-add res=%u", result);
-	xfrm_audit_common_stateinfo(x, audit_buf);
+	xfrm_audit_helper_usrinfo(auid, secid, audit_buf);
+	xfrm_audit_helper_sainfo(x, audit_buf);
+	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
@@ -2043,14 +2082,96 @@ void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 {
 	struct audit_buffer *audit_buf;
 
-	if (audit_enabled == 0)
-		return;
-	audit_buf = xfrm_audit_start(auid, secid);
+	audit_buf = xfrm_audit_start("SAD-delete");
 	if (audit_buf == NULL)
 		return;
-	audit_log_format(audit_buf, " op=SAD-delete res=%u", result);
-	xfrm_audit_common_stateinfo(x, audit_buf);
+	xfrm_audit_helper_usrinfo(auid, secid, audit_buf);
+	xfrm_audit_helper_sainfo(x, audit_buf);
+	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
+
+void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
+				      struct sk_buff *skb)
+{
+	struct audit_buffer *audit_buf;
+	u32 spi;
+
+	audit_buf = xfrm_audit_start("SA-replay-overflow");
+	if (audit_buf == NULL)
+		return;
+	xfrm_audit_helper_pktinfo(skb, x->props.family, audit_buf);
+	/* don't record the sequence number because it's inherent in this kind
+	 * of audit message */
+	spi = ntohl(x->id.spi);
+	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_replay_overflow);
+
+static void xfrm_audit_state_replay(struct xfrm_state *x,
+			     struct sk_buff *skb, __be32 net_seq)
+{
+	struct audit_buffer *audit_buf;
+	u32 spi;
+
+	audit_buf = xfrm_audit_start("SA-replayed-pkt");
+	if (audit_buf == NULL)
+		return;
+	xfrm_audit_helper_pktinfo(skb, x->props.family, audit_buf);
+	spi = ntohl(x->id.spi);
+	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
+			 spi, spi, ntohl(net_seq));
+	audit_log_end(audit_buf);
+}
+
+void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family)
+{
+	struct audit_buffer *audit_buf;
+
+	audit_buf = xfrm_audit_start("SA-notfound");
+	if (audit_buf == NULL)
+		return;
+	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound_simple);
+
+void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
+			       __be32 net_spi, __be32 net_seq)
+{
+	struct audit_buffer *audit_buf;
+	u32 spi;
+
+	audit_buf = xfrm_audit_start("SA-notfound");
+	if (audit_buf == NULL)
+		return;
+	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
+	spi = ntohl(net_spi);
+	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
+			 spi, spi, ntohl(net_seq));
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound);
+
+void xfrm_audit_state_icvfail(struct xfrm_state *x,
+			      struct sk_buff *skb, u8 proto)
+{
+	struct audit_buffer *audit_buf;
+	__be32 net_spi;
+	__be32 net_seq;
+
+	audit_buf = xfrm_audit_start("SA-icv-failure");
+	if (audit_buf == NULL)
+		return;
+	xfrm_audit_helper_pktinfo(skb, x->props.family, audit_buf);
+	if (xfrm_parse_spi(skb, proto, &net_spi, &net_seq) == 0) {
+		u32 spi = ntohl(net_spi);
+		audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
+				 spi, spi, ntohl(net_seq));
+	}
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_icvfail);
 #endif /* CONFIG_AUDITSYSCALL */

