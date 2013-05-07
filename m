From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 39/48] Audit: netlabel: translate audit_log_start to audit_log_start_ns
Date: Tue, 7 May 2013 10:21:00 +0800
Message-ID: <1367893269-9308-40-git-send-email-gaofeng@cn.fujitsu.com>
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
 net/ipv4/cipso_ipv4.c              | 4 ++--
 net/netlabel/netlabel_domainhash.c | 4 ++--
 net/netlabel/netlabel_unlabeled.c  | 8 ++++----
 net/netlabel/netlabel_user.c       | 8 +++++---
 4 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 667c1d4..b021445 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -532,7 +532,7 @@ doi_add_return:
 		audit_log_format(audit_buf,
 				 " cipso_doi=%u cipso_type=%s res=%u",
 				 doi, type_str, ret_val == 0 ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 
 	return ret_val;
@@ -622,7 +622,7 @@ doi_remove_return:
 		audit_log_format(audit_buf,
 				 " cipso_doi=%u res=%u",
 				 doi, ret_val == 0 ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 
 	return ret_val;
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index d8d4243..7fab4b8 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -241,7 +241,7 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
 			break;
 		}
 		audit_log_format(audit_buf, " res=%u", result == 0 ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 }
 
@@ -462,7 +462,7 @@ int netlbl_domhsh_remove_entry(struct netlbl_dom_map *entry,
 				 " nlbl_domain=%s res=%u",
 				 entry->domain ? entry->domain : "(default)",
 				 ret_val == 0 ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 
 	if (ret_val == 0) {
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 8a6c6ea..7708078 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -465,7 +465,7 @@ unlhsh_add_return:
 			security_release_secctx(secctx, secctx_len);
 		}
 		audit_log_format(audit_buf, " res=%u", ret_val == 0 ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 	return ret_val;
 }
@@ -521,7 +521,7 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 			security_release_secctx(secctx, secctx_len);
 		}
 		audit_log_format(audit_buf, " res=%u", entry != NULL ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 
 	if (entry == NULL)
@@ -582,7 +582,7 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 			security_release_secctx(secctx, secctx_len);
 		}
 		audit_log_format(audit_buf, " res=%u", entry != NULL ? 1 : 0);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 
 	if (entry == NULL)
@@ -766,7 +766,7 @@ static void netlbl_unlabel_acceptflg_set(u8 value,
 	if (audit_buf != NULL) {
 		audit_log_format(audit_buf,
 				 " unlbl_accept=%u old=%u", value, old_val);
-		audit_log_end(audit_buf);
+		audit_log_end_ns(current_user_ns(), audit_buf);
 	}
 }
 
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 9650c4a..d7550a2 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -100,16 +100,18 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 	struct audit_buffer *audit_buf;
 	char *secctx;
 	u32 secctx_len;
+	struct user_namespace *ns = current_user_ns();
 
-	if (audit_enabled == 0)
+	if (audit_enabled_ns(ns) == 0)
 		return NULL;
 
-	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
+	audit_buf = audit_log_start_ns(ns, current->audit_context,
+				       GFP_ATOMIC, type);
 	if (audit_buf == NULL)
 		return NULL;
 
 	audit_log_format(audit_buf, "netlabel: auid=%u ses=%u",
-			 from_kuid(&init_user_ns, audit_info->loginuid),
+			 from_kuid(ns, audit_info->loginuid),
 			 audit_info->sessionid);
 
 	if (audit_info->secid != 0 &&
-- 
1.8.1.4
