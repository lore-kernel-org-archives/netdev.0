From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] netlink: Change rtnl_dump_done to always show error
Date: Tue, 16 May 2017 14:22:46 -0700
Message-ID: <20170516212246.10134-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36401 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752589AbdEPVWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:22:51 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so20056562pfb.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:22:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code which became rtnl_dump_done only shows netlink errors
if the protocol is NETLINK_SOCK_DIAG, but netlink dumps always appends
the length which contains any error encountered during the dump. Update
rtnl_dump_done to always show the error if there is one.

As an *example* without this patch, dumping a route object that exceeds
the internal buffer size terminates with no message to the user -- the
dump just ends because the NLMSG_DONE attribute was received. With this
patch the user at least gets a message that the dump was aborted.

$ ip ro ls
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
10.10.0.0/16 dev veth1 proto kernel scope link src 10.10.0.1
172.16.1.0/24 dev br0.11 proto kernel scope link src 172.16.1.1
Error: Buffer too small for object
Dump terminated

The point of this patch is to notify the user of a failure versus
silently exiting on a partial dump. Because the NLMSG_DONE attribute
was received, the entire dump needs to be restarted to use a larger
buffer for EMSGSIZE errors. That could be done automatically but it
has other user impacts (e.g., duplicate output if the dump is
restarted) and should be the subject of a different patch.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 lib/libnetlink.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 5b75b2db4e0b..d4b831f67ea2 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -266,21 +266,27 @@ static int rtnl_dump_done(const struct rtnl_handle *rth,
 {
 	int len = *(int *)NLMSG_DATA(h);
 
-	if (rth->proto == NETLINK_SOCK_DIAG) {
-		if (h->nlmsg_len < NLMSG_LENGTH(sizeof(int))) {
-			fprintf(stderr, "DONE truncated\n");
-			return -1;
-		}
-
+	if (h->nlmsg_len < NLMSG_LENGTH(sizeof(int))) {
+		fprintf(stderr, "DONE truncated\n");
+		return -1;
+	}
 
-		if (len < 0) {
-			errno = -len;
-			if (errno == ENOENT || errno == EOPNOTSUPP)
-				return -1;
+	if (len < 0) {
+		errno = -len;
+		switch (errno) {
+		case ENOENT:
+		case EOPNOTSUPP:
+			return -1;
+		case EMSGSIZE:
+			fprintf(stderr,
+				"Error: Buffer too small for object.\n");
+			break;
+		default:
 			perror("RTNETLINK answers");
-			return len;
 		}
+		return len;
 	}
+
 	return 0;
 }
 
-- 
2.11.0 (Apple Git-81)
