From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH net-next iproute2 1/2 v2] libnetlink: Add test for error code returned from netlink reply
Date: Wed,  2 Nov 2016 16:14:55 +0300
Message-ID: <1478092496-7540-2-git-send-email-gorcunov@gmail.com>
References: <1478092496-7540-1-git-send-email-gorcunov@gmail.com>
Cc: stephen@networkplumber.org, avagin@openvz.org,
        Cyrill Gorcunov <gorcunov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36294 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753543AbcKBNPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 09:15:05 -0400
Received: by mail-lf0-f65.google.com with SMTP id o20so959605lfg.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 06:15:04 -0700 (PDT)
In-Reply-To: <1478092496-7540-1-git-send-email-gorcunov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case if some diag module is not present in the system,
say the kernel is not modern enough, we simply skip the
error code reported. Instead we should check for data
length in NLMSG_DONE and process unsupported case.

Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
---
 lib/libnetlink.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 2279935..232daee 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -312,6 +312,22 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 					dump_intr = 1;
 
 				if (h->nlmsg_type == NLMSG_DONE) {
+					if (rth->proto == NETLINK_SOCK_DIAG) {
+						if (h->nlmsg_len < NLMSG_LENGTH(sizeof(int))) {
+							fprintf(stderr, "DONE truncated\n");
+							return -1;
+						} else {
+							int len = *(int *)NLMSG_DATA(h);
+							if (len < 0) {
+								errno = -len;
+								if (errno == ENOENT ||
+								    errno == EOPNOTSUPP)
+									return -1;
+								perror("RTNETLINK answers");
+								return len;
+							}
+						}
+					}
 					found_done = 1;
 					break; /* process next filter */
 				}
-- 
2.7.4
