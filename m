From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] XFRM: SPD auditing fix to include the netmask/prefix-length
Date: Mon, 26 Nov 2007 14:55:12 -0500
Message-ID: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Joy Latten <latten@us.ibm.com>
To: netdev@vger.kernel.org, linux-audit@redhat.com
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

Currently the netmask/prefix-length of an IPsec SPD entry is not included in
any of the SPD related audit messages.  This can cause a problem when the
audit log is examined as the netmask/prefix-length is vital in determining
what network traffic is affected by a particular SPD entry.  This patch fixes
this problem by adding two additional fields, "src_prefixlen" and
"dst_prefixlen", to the SPD audit messages to indicate the source and
destination netmasks.  These new fields are only included in the audit message
when the netmask/prefix-length is less than the address length, i.e. the SPD
entry applies to a network address and not a host address.

Example audit message:

 type=UNKNOWN[1415] msg=audit(1196105849.752:25): auid=0 \
   subj=root:system_r:unconfined_t:s0-s0:c0.c1023 op=SPD-add res=1 \
   src=192.168.0.0 src_prefixlen=24 dst=192.168.1.0 dst_prefixlen=24

In addition, this patch also fixes a few other things in the
xfrm_audit_common_policyinfo() function.  The IPv4 string formatting was
converted to use the standard NIPQUAD_FMT constant, the memcpy() was removed
from the IPv6 code path and replaced with a typecast (the memcpy() was acting
as a slow, implicit typecast anyway), and two local variables were created to
make referencing the XFRM security context and selector information cleaner.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/xfrm/xfrm_policy.c |   44 ++++++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b702bd8..bd70d79 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2123,29 +2123,37 @@ void __init xfrm_init(void)
 static inline void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 						struct audit_buffer *audit_buf)
 {
-	if (xp->security)
+	struct xfrm_sec_ctx *ctx = xp->security;
+	struct xfrm_selector *sel = &xp->selector;
+
+	if (ctx)
 		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
-				 xp->security->ctx_alg, xp->security->ctx_doi,
-				 xp->security->ctx_str);
+				 ctx->ctx_alg, ctx->ctx_doi, ctx->ctx_str);
 
-	switch(xp->selector.family) {
+	switch(sel->family) {
 	case AF_INET:
-		audit_log_format(audit_buf, " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
-				 NIPQUAD(xp->selector.saddr.a4),
-				 NIPQUAD(xp->selector.daddr.a4));
+		audit_log_format(audit_buf, " src=" NIPQUAD_FMT,
+				 NIPQUAD(sel->saddr.a4));
+		if (sel->prefixlen_s != 32)
+			audit_log_format(audit_buf, " src_prefixlen=%d",
+					 sel->prefixlen_s);
+		audit_log_format(audit_buf, " dst=" NIPQUAD_FMT,
+				 NIPQUAD(sel->daddr.a4));
+		if (sel->prefixlen_d != 32)
+			audit_log_format(audit_buf, " dst_prefixlen=%d",
+					 sel->prefixlen_d);
 		break;
 	case AF_INET6:
-		{
-			struct in6_addr saddr6, daddr6;
-
-			memcpy(&saddr6, xp->selector.saddr.a6,
-				sizeof(struct in6_addr));
-			memcpy(&daddr6, xp->selector.daddr.a6,
-				sizeof(struct in6_addr));
-			audit_log_format(audit_buf,
-				" src=" NIP6_FMT " dst=" NIP6_FMT,
-				NIP6(saddr6), NIP6(daddr6));
-		}
+		audit_log_format(audit_buf, " src=" NIP6_FMT,
+				 NIP6(*(struct in6_addr *)sel->saddr.a6));
+		if (sel->prefixlen_s != 128)
+			audit_log_format(audit_buf, " src_prefixlen=%d",
+					 sel->prefixlen_s);
+		audit_log_format(audit_buf, " dst=" NIP6_FMT,
+				 NIP6(*(struct in6_addr *)sel->daddr.a6));
+		if (sel->prefixlen_d != 128)
+			audit_log_format(audit_buf, " dst_prefixlen=%d",
+					 sel->prefixlen_d);
 		break;
 	}
 }
