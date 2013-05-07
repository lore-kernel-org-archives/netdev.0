From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 33/48] Audit: Log filter related audit message to proper user namespace
Date: Tue, 7 May 2013 10:20:54 +0800
Message-ID: <1367893269-9308-34-git-send-email-gaofeng@cn.fujitsu.com>
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

Now, we can log filter related audit message to the user namespace
which the task belongs to.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 kernel/auditfilter.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index f2afe9b..8af148b 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -1120,15 +1120,16 @@ static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 				  int res)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns = current_user_ns();
 
-	if (!audit_enabled)
+	if (!ns->audit.enabled)
 		return;
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_CONFIG_CHANGE);
 	if (!ab)
 		return;
 	audit_log_format(ab, "auid=%u ses=%u",
-			 from_kuid(&init_user_ns, loginuid), sessionid);
+			 from_kuid(ns, loginuid), sessionid);
 	if (sid) {
 		char *ctx = NULL;
 		u32 len;
@@ -1143,7 +1144,7 @@ static void audit_log_rule_change(kuid_t loginuid, u32 sessionid, u32 sid,
 	audit_log_string(ab, action);
 	audit_log_key(ab, rule->filterkey);
 	audit_log_format(ab, " list=%d res=%d", rule->listnr, res);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
 
 /**
-- 
1.8.1.4
