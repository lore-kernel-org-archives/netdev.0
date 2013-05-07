From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 43/48] Audit: xfrm: translate audit_log_start to audit_log_start_ns
Date: Tue, 7 May 2013 10:21:04 +0800
Message-ID: <1367893269-9308-44-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we can log audit message in the user namespace which current
task belongs to.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/xfrm.h     |  7 ++++---
 net/xfrm/xfrm_policy.c |  4 ++--
 net/xfrm/xfrm_state.c  | 14 +++++++-------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ae16531..1a99744 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -683,11 +683,12 @@ struct xfrm_audit {
 static inline struct audit_buffer *xfrm_audit_start(const char *op)
 {
 	struct audit_buffer *audit_buf = NULL;
+	struct user_namespace *ns = current_user_ns();
 
-	if (audit_enabled == 0)
+	if (audit_enabled_ns(ns) == 0)
 		return NULL;
-	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
-				    AUDIT_MAC_IPSEC_EVENT);
+	audit_buf = audit_log_start_ns(ns, current->audit_context,
+				       GFP_ATOMIC, AUDIT_MAC_IPSEC_EVENT);
 	if (audit_buf == NULL)
 		return NULL;
 	audit_log_format(audit_buf, "op=%s", op);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 23cea0f..f3cc1b9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3008,7 +3008,7 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
@@ -3023,7 +3023,7 @@ void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_delete);
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..50115d9 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2119,7 +2119,7 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
@@ -2134,7 +2134,7 @@ void xfrm_audit_state_delete(struct xfrm_state *x, int result,
 	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
 
@@ -2152,7 +2152,7 @@ void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 	 * of audit message */
 	spi = ntohl(x->id.spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay_overflow);
 
@@ -2169,7 +2169,7 @@ void xfrm_audit_state_replay(struct xfrm_state *x,
 	spi = ntohl(x->id.spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 			 spi, spi, ntohl(net_seq));
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_replay);
 
@@ -2181,7 +2181,7 @@ void xfrm_audit_state_notfound_simple(struct sk_buff *skb, u16 family)
 	if (audit_buf == NULL)
 		return;
 	xfrm_audit_helper_pktinfo(skb, family, audit_buf);
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound_simple);
 
@@ -2198,7 +2198,7 @@ void xfrm_audit_state_notfound(struct sk_buff *skb, u16 family,
 	spi = ntohl(net_spi);
 	audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 			 spi, spi, ntohl(net_seq));
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_notfound);
 
@@ -2218,7 +2218,7 @@ void xfrm_audit_state_icvfail(struct xfrm_state *x,
 		audit_log_format(audit_buf, " spi=%u(0x%x) seqno=%u",
 				 spi, spi, ntohl(net_seq));
 	}
-	audit_log_end(audit_buf);
+	audit_log_end_ns(current_user_ns(), audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_icvfail);
 #endif /* CONFIG_AUDITSYSCALL */
-- 
1.8.1.4
