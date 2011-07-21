From: kaber@trash.net
Subject: [PATCH 1/8] netfilter: add SELinux context support to AUDIT target
Date: Thu, 21 Jul 2011 12:17:49 +0200
Message-ID: <1311243476-18236-2-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34522 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab1GUKSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 06:18:02 -0400
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mr Dash Four <mr.dash.four@googlemail.com>

In this revision the conversion of secid to SELinux context and adding it
to the audit log is moved from xt_AUDIT.c to audit.c with the aid of a
separate helper function - audit_log_secctx - which does both the conversion
and logging of SELinux context, thus also preventing internal secid number
being leaked to userspace. If conversion is not successful an error is raised.

With the introduction of this helper function the work done in xt_AUDIT.c is
much more simplified. It also opens the possibility of this helper function
being used by other modules (including auditd itself), if desired. With this
addition, typical (raw auditd) output after applying the patch would be:

type=NETFILTER_PKT msg=audit(1305852240.082:31012): action=0 hook=1 len=52 inif=? outif=eth0 saddr=10.1.1.7 daddr=10.1.2.1 ipid=16312 proto=6 sport=56150 dport=22 obj=system_u:object_r:ssh_client_packet_t:s0
type=NETFILTER_PKT msg=audit(1306772064.079:56): action=0 hook=3 len=48 inif=eth0 outif=? smac=00:05:5d:7c:27:0b dmac=00:02:b3:0a:7f:81 macproto=0x0800 saddr=10.1.2.1 daddr=10.1.1.7 ipid=462 proto=6 sport=22 dport=3561 obj=system_u:object_r:ssh_server_packet_t:s0

Acked-by: Eric Paris <eparis@redhat.com>
Signed-off-by: Mr Dash Four <mr.dash.four@googlemail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/audit.h    |    7 +++++++
 kernel/audit.c           |   29 +++++++++++++++++++++++++++++
 net/netfilter/xt_AUDIT.c |    5 +++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 9d339eb..0c80061 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -613,6 +613,12 @@ extern void		    audit_log_d_path(struct audit_buffer *ab,
 extern void		    audit_log_key(struct audit_buffer *ab,
 					  char *key);
 extern void		    audit_log_lost(const char *message);
+#ifdef CONFIG_SECURITY
+extern void 		    audit_log_secctx(struct audit_buffer *ab, u32 secid);
+#else
+#define audit_log_secctx(b,s) do { ; } while (0)
+#endif
+
 extern int		    audit_update_lsm_rules(void);
 
 				/* Private API (for audit.c only) */
@@ -635,6 +641,7 @@ extern int audit_enabled;
 #define audit_log_untrustedstring(a,s) do { ; } while (0)
 #define audit_log_d_path(b, p, d) do { ; } while (0)
 #define audit_log_key(b, k) do { ; } while (0)
+#define audit_log_secctx(b,s) do { ; } while (0)
 #define audit_enabled 0
 #endif
 #endif
diff --git a/kernel/audit.c b/kernel/audit.c
index 9395003..52501b5 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -55,6 +55,9 @@
 #include <net/sock.h>
 #include <net/netlink.h>
 #include <linux/skbuff.h>
+#ifdef CONFIG_SECURITY
+#include <linux/security.h>
+#endif
 #include <linux/netlink.h>
 #include <linux/freezer.h>
 #include <linux/tty.h>
@@ -1502,6 +1505,32 @@ void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
 	}
 }
 
+#ifdef CONFIG_SECURITY
+/**
+ * audit_log_secctx - Converts and logs SELinux context
+ * @ab: audit_buffer
+ * @secid: security number
+ *
+ * This is a helper function that calls security_secid_to_secctx to convert
+ * secid to secctx and then adds the (converted) SELinux context to the audit
+ * log by calling audit_log_format, thus also preventing leak of internal secid
+ * to userspace. If secid cannot be converted audit_panic is called.
+ */
+void audit_log_secctx(struct audit_buffer *ab, u32 secid)
+{
+	u32 len;
+	char *secctx;
+
+	if (security_secid_to_secctx(secid, &secctx, &len)) {
+		audit_panic("Cannot convert secid to context");
+	} else {
+		audit_log_format(ab, " obj=%s", secctx);
+		security_release_secctx(secctx, len);
+	}
+}
+EXPORT_SYMBOL(audit_log_secctx);
+#endif
+
 EXPORT_SYMBOL(audit_log_start);
 EXPORT_SYMBOL(audit_log_end);
 EXPORT_SYMBOL(audit_log_format);
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index 363a99e..4bca15a 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -163,6 +163,11 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		break;
 	}
 
+#ifdef CONFIG_NETWORK_SECMARK
+	if (skb->secmark)
+		audit_log_secctx(ab, skb->secmark);
+#endif
+
 	audit_log_end(ab);
 
 errout:
-- 
1.7.2.3

