From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH 5/6] ip xfrm state: fixup hard/soft timeouts/limits while save
Date: Fri,  2 Sep 2016 12:02:25 +0300
Message-ID: <1472806946-16575-6-git-send-email-ptikhomirov@virtuozzo.com>
References: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        crml <criu@openvz.org>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47030 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752415AbcIBJGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 05:06:06 -0400
In-Reply-To: <1472806946-16575-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce "fixlimits" option of "ip xfrm state save",
if have these option we will change the limits saved to
dump file according to the real passed time/bytes/packets
since the state add-time.

For instance, we have a process in container which set
xfrm state 10sec ago with a timeout of 30sec and now we
do C/R for the whole container. As the process in question
knows nothing about C/R, after restore it might expect that
xfrm state dissappears in 30-10=20sec, so we need to set
timeout to 20. If difference is <=0 set 1 at least to do
not lose the limit completely.

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 ip/xfrm_state.c    | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-xfrm.8 | 10 ++++++-
 2 files changed, 95 insertions(+), 3 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 56d9f22..6c55b3e 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -32,6 +32,7 @@
 #include "xfrm.h"
 #include "ip_common.h"
 #include <errno.h>
+#include <time.h>
 
 /* #define NLMSG_DELETEALL_BUF_SIZE (4096-512) */
 #define NLMSG_DELETEALL_BUF_SIZE 8192
@@ -66,7 +67,8 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID [ mark MARK [ mask MASK ] ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm state { save | restore }\n");
+	fprintf(stderr, "Usage: ip xfrm state save [ fixlimits ]\n");
+	fprintf(stderr, "Usage: ip xfrm state restore\n");
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM-PROTO ]\n");
 	fprintf(stderr, "Usage: ip xfrm state count\n");
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM-PROTO ] [ spi SPI ]\n");
@@ -1077,10 +1079,89 @@ static int xfrm_state_keep(const struct sockaddr_nl *who,
 
 static __u32 state_dump_magic = 0x71706987;
 
+static inline void fixup_lft_limit(__u64 *lft_limit, __u64 lft_cur)
+{
+	if (lft_cur < *lft_limit)
+		/*
+		 * Limit is not yet hit, decrease it by
+		 * current lifetime
+		 */
+		*lft_limit -= lft_cur;
+	else
+		/*
+		 * Limit is already hit or almost hit, set it
+		 * to 1 to hit it imediately after restore
+		 */
+		*lft_limit = 1;
+}
+
+static int fixup_lifetime(struct xfrm_lifetime_cur *curlft, struct xfrm_lifetime_cfg *lft)
+{
+	unsigned long now;
+	__u64 time_since_add, time_since_use;
+
+	now = time(NULL);
+	if (now < 0) {
+		fprintf(stderr, "Failed to get current time\n");
+		return -1;
+	}
+	time_since_add = now - curlft->add_time;
+	time_since_use = now - (curlft->use_time ? : curlft->add_time);
+
+	/* Fixup expire timeouts */
+	if (lft->hard_add_expires_seconds)
+		fixup_lft_limit(&lft->hard_add_expires_seconds, time_since_add);
+	if (lft->hard_use_expires_seconds)
+		fixup_lft_limit(&lft->hard_use_expires_seconds, time_since_use);
+	if (lft->soft_add_expires_seconds)
+		fixup_lft_limit(&lft->soft_add_expires_seconds, time_since_add);
+	if (lft->soft_use_expires_seconds)
+		fixup_lft_limit(&lft->soft_use_expires_seconds, time_since_use);
+
+	/* Fixup expire limits */
+	if (lft->hard_byte_limit != XFRM_INF)
+		fixup_lft_limit(&lft->hard_byte_limit, curlft->bytes);
+	if (lft->hard_packet_limit != XFRM_INF)
+		fixup_lft_limit(&lft->hard_packet_limit, curlft->packets);
+	if (lft->soft_byte_limit != XFRM_INF)
+		fixup_lft_limit(&lft->soft_byte_limit, curlft->bytes);
+	if (lft->soft_packet_limit != XFRM_INF)
+		fixup_lft_limit(&lft->soft_packet_limit, curlft->packets);
+
+	return 0;
+}
+
+static int save_state(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		void *arg)
+{
+	struct xfrm_usersa_info *xsinfo;
+	int len = n->nlmsg_len;
+
+	if (n->nlmsg_type != XFRM_MSG_NEWSA) {
+		fprintf(stderr, "BUG: wrong nlmsg_type: %08x\n",
+			n->nlmsg_type);
+		return -1;
+	}
+
+	xsinfo = NLMSG_DATA(n);
+	len -= NLMSG_SPACE(sizeof(*xsinfo));
+
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (fixup_lifetime(&xsinfo->curlft, &xsinfo->lft))
+		return -1;
+
+	return save_nlmsg(who, n, arg);
+}
+
 static int xfrm_state_list_deleteall_or_save(int argc, char **argv, int deleteall, int save)
 {
 	char *idp = NULL;
 	struct rtnl_handle rth;
+	int fixlimits = 0;
 
 	if (argc > 0)
 		filter.use = 1;
@@ -1105,6 +1186,9 @@ static int xfrm_state_list_deleteall_or_save(int argc, char **argv, int deleteal
 
 			filter.state_flags_mask = XFRM_FILTER_MASK_FULL;
 
+		} else if (strcmp(*argv, "fixlimits") == 0) {
+			fixlimits = 1;
+
 		} else {
 			if (idp)
 				invarg("unknown", *argv);
@@ -1179,7 +1263,7 @@ static int xfrm_state_list_deleteall_or_save(int argc, char **argv, int deleteal
 		if (save) {
 			if (dump_write_magic(state_dump_magic))
 				return -1;
-			rtnl_filter = save_nlmsg;
+			rtnl_filter = fixlimits ? save_state : save_nlmsg;
 		}
 
 		struct xfrm_address_filter addrfilter = {
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index f5b8290..2fd088d 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -104,7 +104,7 @@ ip-xfrm \- transform configuration
 .BR "ip xfrm state count"
 
 .ti -8
-.BR "ip xfrm state save"
+.BR "ip xfrm state save" " [ " fixlimits " ]"
 
 .ti -8
 .BR "ip xfrm state restore"
@@ -550,6 +550,14 @@ encapsulates packets with protocol
 .RI "using source port " SPORT ", destination port "  DPORT
 .RI ", and original address " OADDR "."
 
+.P
+If the
+.BI fixlimits
+option is set on save, change entry
+.I LIMITs
+saved to dump file according to the real time/bytes/packets passed
+since entry add-time.
+
 .sp
 .PP
 .TS
-- 
2.5.5
