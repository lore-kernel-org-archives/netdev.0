From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 6/6] ip xfrm policy: fixup hard/soft timeouts/limits while save
Date: Fri,  2 Sep 2016 12:02:26 +0300
Message-ID: <1472806946-16575-7-git-send-email-ptikhomirov@virtuozzo.com>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37800 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752135AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
In-Reply-To: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

same as for states, though I beleive that plicies do not actually
support byte-soft | byte-hard | packet-soft | packet-hard, but
they still can be set.

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 ip/ip_common.h     |  5 +++++
 ip/xfrm_policy.c   | 35 +++++++++++++++++++++++++++++++++--
 ip/xfrm_state.c    |  2 +-
 man/man8/ip-xfrm.8 |  2 +-
 4 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 69e028d..7c10413 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -72,6 +72,11 @@ extern int dump_check_magic(__u32 dump_magic);
 extern int save_nlmsg(const struct sockaddr_nl *who,
 		struct nlmsghdr *n, void *arg);
 
+#ifdef _LINUX_XFRM_H
+extern int fixup_lifetime(struct xfrm_lifetime_cur *curlft,
+		struct xfrm_lifetime_cfg *lft);
+#endif
+
 extern struct rtnl_handle rth;
 
 #include <stdbool.h>
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2f1ce4b..987fae8 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -62,7 +62,8 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ SELECTOR ] [ dir DIR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ ptype PTYPE ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { save | restore }\n");
+	fprintf(stderr, "Usage: ip xfrm policy save [ fixlimits ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy restore\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy count\n");
 	fprintf(stderr, "Usage: ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]\n");
@@ -758,10 +759,37 @@ static int xfrm_policy_keep(const struct sockaddr_nl *who,
 
 static __u32 policy_dump_magic = 0x71706988;
 
+static int save_policy(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		void *arg)
+{
+	struct xfrm_userpolicy_info *xpinfo;
+	int len = n->nlmsg_len;
+
+	if (n->nlmsg_type != XFRM_MSG_NEWPOLICY) {
+		fprintf(stderr, "BUG: wrong nlmsg_type: %08x\n",
+			n->nlmsg_type);
+		return -1;
+	}
+
+	xpinfo = NLMSG_DATA(n);
+	len -= NLMSG_SPACE(sizeof(*xpinfo));
+
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (fixup_lifetime(&xpinfo->curlft, &xpinfo->lft))
+		return -1;
+
+	return save_nlmsg(who, n, arg);
+}
+
 static int xfrm_policy_list_or_deleteall_or_save(int argc, char **argv, int deleteall, int save)
 {
 	char *selp = NULL;
 	struct rtnl_handle rth;
+	int fixlimits = 0;
 
 	if (argc > 0)
 		filter.use = 1;
@@ -812,6 +840,9 @@ static int xfrm_policy_list_or_deleteall_or_save(int argc, char **argv, int dele
 
 			filter.policy_flags_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "fixlimits") == 0) {
+			fixlimits = 1;
+
 		} else {
 			if (selp)
 				invarg("unknown", *argv);
@@ -885,7 +916,7 @@ static int xfrm_policy_list_or_deleteall_or_save(int argc, char **argv, int dele
 		if (save) {
 			if (dump_write_magic(policy_dump_magic))
 				return -1;
-			rtnl_filter = save_nlmsg;
+			rtnl_filter = fixlimits ? save_policy : save_nlmsg;
 		}
 
 		struct {
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 6c55b3e..ea324ef 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -1095,7 +1095,7 @@ static inline void fixup_lft_limit(__u64 *lft_limit, __u64 lft_cur)
 		*lft_limit = 1;
 }
 
-static int fixup_lifetime(struct xfrm_lifetime_cur *curlft, struct xfrm_lifetime_cfg *lft)
+int fixup_lifetime(struct xfrm_lifetime_cur *curlft, struct xfrm_lifetime_cfg *lft)
 {
 	unsigned long now;
 	__u64 time_since_add, time_since_use;
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 2fd088d..d3b62bb 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -274,7 +274,7 @@ ip-xfrm \- transform configuration
 .B "ip xfrm policy count"
 
 .ti -8
-.BR "ip xfrm policy save"
+.BR "ip xfrm policy save" " [ " fixlimits " ]"
 
 .ti -8
 .BR "ip xfrm policy restore"
-- 
2.5.5
