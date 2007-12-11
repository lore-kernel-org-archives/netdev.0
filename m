From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH v2] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 11:30:19 -0500
Message-ID: <20071211163019.15059.73746.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, selinux@tycho.nsa.gov
To: netdev@vger.kernel.org
Return-path: <linux-audit-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

This patch fixes a number of small but potentially troublesome things in the
XFRM/IPsec code:

 * Use the 'audit_enabled' variable already in include/linux/audit.h
   Removed the need for extern declarations local to each XFRM audit fuction

 * Convert 'sid' to 'secid'
   The 'sid' name is specific to SELinux, 'secid' is the common naming
   convention used by the kernel when refering to tokenized LSM labels

 * Convert address display to use standard NIP* macros
   Similar to what was recently done with the SPD audit code, this also also
   includes the removal of some unnecessary memcpy() calls

 * Move common code to xfrm_audit_common_stateinfo()
   Code consolidation from the "less is more" book on software development

 * Convert the SPI in audit records to host byte order
   The current SPI values in the audit record are being displayed in network
   byte order, probably not what was intended

 * Proper spacing around commas in function arguments
   Minor style tweak since I was already touching the code

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/linux/xfrm.h    |    2 +
 include/net/xfrm.h      |   18 ++++++------
 net/xfrm/xfrm_policy.c  |   15 +++++-----
 net/xfrm/xfrm_state.c   |   69 +++++++++++++++++++++--------------------------
 security/selinux/xfrm.c |   20 +++++++-------
 5 files changed, 58 insertions(+), 66 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b58adc5..f75a337 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -31,7 +31,7 @@ struct xfrm_sec_ctx {
 	__u8	ctx_doi;
 	__u8	ctx_alg;
 	__u16	ctx_len;
-	__u32	ctx_sid;
+	__u32	ctx_secid;
 	char	ctx_str[0];
 };
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0c380d9..3134ba6 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -547,7 +547,7 @@ struct xfrm_audit
 };
 
 #ifdef CONFIG_AUDITSYSCALL
-static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
+static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 secid)
 {
 	struct audit_buffer *audit_buf = NULL;
 	char *secctx;
@@ -560,8 +560,8 @@ static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
 
 	audit_log_format(audit_buf, "auid=%u", auid);
 
-	if (sid != 0 &&
-	    security_secid_to_secctx(sid, &secctx, &secctx_len) == 0) {
+	if (secid != 0 &&
+	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0) {
 		audit_log_format(audit_buf, " subj=%s", secctx);
 		security_release_secctx(secctx, secctx_len);
 	} else
@@ -570,13 +570,13 @@ static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
 }
 
 extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 sid);
+				  u32 auid, u32 secid);
 extern void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  u32 auid, u32 sid);
+				  u32 auid, u32 secid);
 extern void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 u32 auid, u32 sid);
+				 u32 auid, u32 secid);
 extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    u32 auid, u32 sid);
+				    u32 auid, u32 secid);
 #else
 #define xfrm_audit_policy_add(x, r, a, s)	do { ; } while (0)
 #define xfrm_audit_policy_delete(x, r, a, s)	do { ; } while (0)
@@ -706,13 +706,13 @@ extern int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 /*	If neither has a context --> match
- * 	Otherwise, both must have a context and the sids, doi, alg must match
+ * 	Otherwise, both must have a context and the secids, doi, alg must match
  */
 static inline int xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ctx *s2)
 {
 	return ((!s1 && !s2) ||
 		(s1 && s2 &&
-		 (s1->ctx_sid == s2->ctx_sid) &&
+		 (s1->ctx_secid == s2->ctx_secid) &&
 		 (s1->ctx_doi == s2->ctx_doi) &&
 		 (s1->ctx_alg == s2->ctx_alg)));
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d9bde91..8a89e2c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -24,6 +24,7 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <linux/audit.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
@@ -2298,15 +2299,14 @@ static inline void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 	}
 }
 
-void
-xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
+void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
+			   u32 auid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
-	extern int audit_enabled;
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(secid, auid);
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SPD-add res=%u", result);
@@ -2315,15 +2315,14 @@ xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
-void
-xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
+void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
+			      u32 auid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
-	extern int audit_enabled;
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(secid, auid);
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SPD-delete res=%u", result);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 5b860b6..e2a3dd1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -19,6 +19,7 @@
 #include <linux/ipsec.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <linux/audit.h>
 #include <asm/uaccess.h>
 
 #include "xfrm_hash.h"
@@ -1994,67 +1995,59 @@ void __init xfrm_state_init(void)
 static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
 					       struct audit_buffer *audit_buf)
 {
-	if (x->security)
-		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
-				 x->security->ctx_alg, x->security->ctx_doi,
-				 x->security->ctx_str);
+	struct xfrm_sec_ctx *ctx = x->security;
+	u32 spi = ntohl(x->id.spi);
 
-	switch(x->props.family) {
-	case AF_INET:
-		audit_log_format(audit_buf, " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
-				 NIPQUAD(x->props.saddr.a4),
-				 NIPQUAD(x->id.daddr.a4));
-		break;
-	case AF_INET6:
-		{
-			struct in6_addr saddr6, daddr6;
-
-			memcpy(&saddr6, x->props.saddr.a6,
-				sizeof(struct in6_addr));
-			memcpy(&daddr6, x->id.daddr.a6,
-				sizeof(struct in6_addr));
-			audit_log_format(audit_buf,
-					 " src=" NIP6_FMT " dst=" NIP6_FMT,
-					 NIP6(saddr6), NIP6(daddr6));
-		}
-		break;
-	}
+        if (ctx)
+                audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
+                                 ctx->ctx_alg, ctx->ctx_doi, ctx->ctx_str);
+
+        switch(x->props.family) {
+        case AF_INET:
+                audit_log_format(audit_buf,
+				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
+                                 NIPQUAD(x->props.saddr.a4),
+                                 NIPQUAD(x->id.daddr.a4));
+                break;
+        case AF_INET6:
+		audit_log_format(audit_buf,
+				 " src=" NIP6_FMT " dst=" NIP6_FMT,
+				 NIP6(*(struct in6_addr *)x->props.saddr.a6),
+				 NIP6(*(struct in6_addr *)x->id.daddr.a6));
+                break;
+        }
+
+	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
 }
 
-void
-xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
+void xfrm_audit_state_add(struct xfrm_state *x, int result,
+			  u32 auid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
-	extern int audit_enabled;
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(secid, auid);
 	if (audit_buf == NULL)
 		return;
-	audit_log_format(audit_buf, " op=SAD-add res=%u",result);
+	audit_log_format(audit_buf, " op=SAD-add res=%u", result);
 	xfrm_audit_common_stateinfo(x, audit_buf);
-	audit_log_format(audit_buf, " spi=%lu(0x%lx)",
-			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
-void
-xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
+void xfrm_audit_state_delete(struct xfrm_state *x, int result,
+			     u32 auid, u32 secid)
 {
 	struct audit_buffer *audit_buf;
-	extern int audit_enabled;
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(secid, auid);
 	if (audit_buf == NULL)
 		return;
-	audit_log_format(audit_buf, " op=SAD-delete res=%u",result);
+	audit_log_format(audit_buf, " op=SAD-delete res=%u", result);
 	xfrm_audit_common_stateinfo(x, audit_buf);
-	audit_log_format(audit_buf, " spi=%lu(0x%lx)",
-			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index e076039..c925880 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -85,7 +85,7 @@ int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir)
 		if (!selinux_authorizable_ctx(ctx))
 			return -EINVAL;
 
-		sel_sid = ctx->ctx_sid;
+		sel_sid = ctx->ctx_secid;
 	}
 	else
 		/*
@@ -132,7 +132,7 @@ int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x, struct xfrm_policy *
 				/* Not a SELinux-labeled SA */
 				return 0;
 
-	state_sid = x->security->ctx_sid;
+	state_sid = x->security->ctx_secid;
 
 	if (fl->secid != state_sid)
 		return 0;
@@ -175,13 +175,13 @@ int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
 				struct xfrm_sec_ctx *ctx = x->security;
 
 				if (!sid_set) {
-					*sid = ctx->ctx_sid;
+					*sid = ctx->ctx_secid;
 					sid_set = 1;
 
 					if (!ckall)
 						break;
 				}
-				else if (*sid != ctx->ctx_sid)
+				else if (*sid != ctx->ctx_secid)
 					return -EINVAL;
 			}
 		}
@@ -232,7 +232,7 @@ static int selinux_xfrm_sec_ctx_alloc(struct xfrm_sec_ctx **ctxp,
 	ctx->ctx_str[str_len] = 0;
 	rc = security_context_to_sid(ctx->ctx_str,
 				     str_len,
-				     &ctx->ctx_sid);
+				     &ctx->ctx_secid);
 
 	if (rc)
 		goto out;
@@ -240,7 +240,7 @@ static int selinux_xfrm_sec_ctx_alloc(struct xfrm_sec_ctx **ctxp,
 	/*
 	 * Does the subject have permission to set security context?
 	 */
-	rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
+	rc = avc_has_perm(tsec->sid, ctx->ctx_secid,
 			  SECCLASS_ASSOCIATION,
 			  ASSOCIATION__SETCONTEXT, NULL);
 	if (rc)
@@ -264,7 +264,7 @@ not_from_user:
 
 	ctx->ctx_doi = XFRM_SC_DOI_LSM;
 	ctx->ctx_alg = XFRM_SC_ALG_SELINUX;
-	ctx->ctx_sid = sid;
+	ctx->ctx_secid = sid;
 	ctx->ctx_len = str_len;
 	memcpy(ctx->ctx_str,
 	       ctx_str,
@@ -341,7 +341,7 @@ int selinux_xfrm_policy_delete(struct xfrm_policy *xp)
 	int rc = 0;
 
 	if (ctx)
-		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
+		rc = avc_has_perm(tsec->sid, ctx->ctx_secid,
 				  SECCLASS_ASSOCIATION,
 				  ASSOCIATION__SETCONTEXT, NULL);
 
@@ -383,7 +383,7 @@ int selinux_xfrm_state_delete(struct xfrm_state *x)
 	int rc = 0;
 
 	if (ctx)
-		rc = avc_has_perm(tsec->sid, ctx->ctx_sid,
+		rc = avc_has_perm(tsec->sid, ctx->ctx_secid,
 				  SECCLASS_ASSOCIATION,
 				  ASSOCIATION__SETCONTEXT, NULL);
 
@@ -412,7 +412,7 @@ int selinux_xfrm_sock_rcv_skb(u32 isec_sid, struct sk_buff *skb,
 
 			if (x && selinux_authorizable_xfrm(x)) {
 				struct xfrm_sec_ctx *ctx = x->security;
-				sel_sid = ctx->ctx_sid;
+				sel_sid = ctx->ctx_secid;
 				break;
 			}
 		}
