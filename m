From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] XFRM: RFC4303 compliant auditing
Date: Fri, 07 Dec 2007 14:57:52 -0500
Message-ID: <20071207195752.31819.44606.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:1548 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753232AbXLGT57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 14:57:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NOTE: This really is an RFC patch, it compiles and boots but that is pretty
      much all I can promise at this point.  I'm posting this patch to gather
      feedback from the audit crowd about the continued overloading of
      the AUDIT_MAC_IPSEC_EVENT message type - continue to use it or create
      a new audit message type?  Of course any other comments people may have
      are always welcome.

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
---

 include/net/xfrm.h     |   14 ++++
 net/ipv4/ah4.c         |    1 
 net/ipv4/esp4.c        |    1 
 net/ipv4/xfrm4_input.c |    6 +-
 net/ipv6/ah6.c         |    1 
 net/ipv6/esp6.c        |    1 
 net/ipv6/xfrm6_input.c |   10 ++-
 net/xfrm/xfrm_output.c |    2 +
 net/xfrm/xfrm_state.c  |  155 ++++++++++++++++++++++++++++++++++++++++++++++--
 9 files changed, 177 insertions(+), 14 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c02e230..85ce8c1 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -492,11 +492,22 @@ extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
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
@@ -1045,7 +1056,8 @@ extern int xfrm_state_delete(struct xfrm_state *x);
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
index 5fc346d..8eb19c9 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -180,6 +180,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		err = -EINVAL;
 		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
 			x->stats.integrity_failed++;
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_AH);
 			goto out;
 		}
 	}
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index c31bccb..00ec285 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -183,6 +183,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
 			x->stats.integrity_failed++;
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_ESP);
 			goto out;
 		}
 	}
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5e95c8a..6d7be5e 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -56,8 +56,10 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 
 		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
 				      nexthdr, AF_INET);
-		if (x == NULL)
+		if (x == NULL) {
+			xfrm_audit_state_notfound(skb, AF_INET, spi, seq);
 			goto drop;
+		}
 
 		spin_lock(&x->lock);
 		if (unlikely(x->km.state != XFRM_STATE_VALID))
@@ -66,7 +68,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		if ((x->encap ? x->encap->encap_type : 0) != encap_type)
 			goto drop_unlock;
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
+		if (x->props.replay_window && xfrm_replay_check(x, skb, seq))
 			goto drop_unlock;
 
 		if (xfrm_state_check_expire(x))
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 4eaf550..b7d2e19 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -383,6 +383,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
 			LIMIT_NETDEBUG(KERN_WARNING "ipsec ah authentication error\n");
 			x->stats.integrity_failed++;
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_AH);
 			goto free_out;
 		}
 	}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7db66f1..d56db2b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -178,6 +178,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
 			x->stats.integrity_failed++;
+			xfrm_audit_state_icvfail(x, skb, IPPROTO_ESP);
 			ret = -EINVAL;
 			goto out;
 		}
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5157837..28c1e1b 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -40,13 +40,15 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 
 		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
 				      nexthdr, AF_INET6);
-		if (x == NULL)
+		if (x == NULL) {
+			xfrm_audit_state_notfound(skb, AF_INET6, spi, seq);
 			goto drop;
+		}
 		spin_lock(&x->lock);
 		if (unlikely(x->km.state != XFRM_STATE_VALID))
 			goto drop_unlock;
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
+		if (x->props.replay_window && xfrm_replay_check(x, skb, seq))
 			goto drop_unlock;
 
 		if (xfrm_state_check_expire(x))
@@ -217,8 +219,10 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 		break;
 	}
 
-	if (!xfrm_vec_one)
+	if (!xfrm_vec_one) {
+		xfrm_audit_state_notfound_simple(skb, AF_INET6);
 		goto drop;
+	}
 
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index f4bfd6c..14ce897 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -59,6 +59,8 @@ int xfrm_output(struct sk_buff *skb)
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
+			if (unlikely(x->replay.oseq == 0))
+				xfrm_audit_state_replay_overflow(x, skb);
 			if (xfrm_aevent_is_on())
 				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b291a82..cfef149 100644
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
@@ -1610,13 +1617,14 @@ static void xfrm_replay_timer_handler(unsigned long data)
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
@@ -1625,14 +1633,18 @@ int xfrm_replay_check(struct xfrm_state *x, __be32 net_seq)
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
 
@@ -1995,8 +2007,8 @@ void __init xfrm_state_init(void)
 }
 
 #ifdef CONFIG_AUDITSYSCALL
-static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
-					       struct audit_buffer *audit_buf)
+static inline void xfrm_audit_helper_sainfo(struct xfrm_state *x,
+					    struct audit_buffer *audit_buf)
 {
 	struct xfrm_sec_ctx *ctx = x->security;
 	u32 spi = ntohl(x->id.spi);
@@ -2023,6 +2035,34 @@ static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
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
@@ -2034,7 +2074,7 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SAD-add res=%u", result);
-	xfrm_audit_common_stateinfo(x, audit_buf);
+	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
@@ -2050,8 +2090,107 @@ void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SAD-delete res=%u", result);
-	xfrm_audit_common_stateinfo(x, audit_buf);
+	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
+
+void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
+				      struct sk_buff *skb)
+{
+	struct audit_buffer *audit_buf;
+	u32 spi = ntohl(x->id.spi);
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+				    AUDIT_MAC_IPSEC_EVENT);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SA-replay-overflow");
+	xfrm_audit_helper_pktinfo(skb, x->props.family, audit_buf);
+	/* don't record the sequence number because it's inherent in this kind
+	 * of audit message */
+	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_replay_overflow);
+
+static void xfrm_audit_state_replay(struct xfrm_state *x,
+			     struct sk_buff *skb, __be32 net_seq)
+{
+	struct audit_buffer *audit_buf;
+	u32 spi = ntohl(x->id.spi);
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+				    AUDIT_MAC_IPSEC_EVENT);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SA-replayed-pkt");
+	xfrm_audit_helper_pktinfo(skb, x->props.family, audit_buf);
+	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
+			 spi, spi, ntohl(net_seq));
+	audit_log_end(audit_buf);
+}
+
+void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family)
+{
+	struct audit_buffer *audit_buf;
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+				    AUDIT_MAC_IPSEC_EVENT);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SA-notfound");
+	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound_simple);
+
+void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
+			       __be32 net_spi, __be32 net_seq)
+{
+	struct audit_buffer *audit_buf;
+	u32 spi = ntohl(net_spi);
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+				    AUDIT_MAC_IPSEC_EVENT);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SA-notfound");
+	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
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
+	u32 spi;
+
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+				    AUDIT_MAC_IPSEC_EVENT);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SA-icv-failure");
+	xfrm_audit_helper_pktinfo(skb, x->props.family, audit_buf);
+	if (xfrm_parse_spi(skb, proto, &net_spi, &net_seq) == 0) {
+		spi = ntohl(net_spi);
+		audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
+				 spi, spi, ntohl(net_seq));
+	}
+	audit_log_end(audit_buf);
+}
+EXPORT_SYMBOL_GPL(xfrm_audit_state_icvfail);
 #endif /* CONFIG_AUDITSYSCALL */

