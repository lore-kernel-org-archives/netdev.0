From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC net-next iproute2 1/2] libnetlink: Add test for error code returned from netlink reply
Date: Wed, 26 Oct 2016 22:30:07 +0300
Message-ID: <1477510208-20292-2-git-send-email-gorcunov@gmail.com>
References: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>,
        Cyrill Gorcunov <gorcunov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35182 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753334AbcJZTa0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 15:30:26 -0400
Received: by mail-lf0-f67.google.com with SMTP id x79so729570lff.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:30:25 -0700 (PDT)
In-Reply-To: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case if some diag module is not present in the system,
say the kernel is not modern enough, we simply skip the
error code reported. Instead we should check for data
length in NLMSG_DONE and process unsupported case.

Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
---
 lib/libnetlink.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 2279935..a397c07 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -312,6 +312,27 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 					dump_intr = 1;
 
 				if (h->nlmsg_type == NLMSG_DONE) {
+					int len;
+
+					/*
+					 * The kernel reports if there is
+					 * no inet-diag module present in
+					 * the system via negative length
+					 * as error code.
+					 */
+					if (h->nlmsg_len < NLMSG_LENGTH(sizeof(int))) {
+						fprintf(stderr, "Truncated length reply\n");
+						return -1;
+					}
+					len = *(int *)NLMSG_DATA(h);
+					if (len < 0) {
+						errno = -len;
+						if (errno == ENOENT ||
+						    errno == EOPNOTSUPP)
+							return -1;
+						perror("RTNETLINK answers");
+						return len;
+					}
 					found_done = 1;
 					break; /* process next filter */
 				}
-- 
2.7.4
