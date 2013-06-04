From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Tue,  4 Jun 2013 12:01:14 +0400
Message-ID: <1370332874-584-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrey Vagin <avagin@openvz.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:48560 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab3FDIBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 04:01:31 -0400
Received: by mail-lb0-f175.google.com with SMTP id v10so338125lbd.34
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 01:01:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise a program executed by "ip netns exec" has two extra
descriptors.

$ ip netns exec test /bin/bash
$ lsof -p $$
...
bash    817 root    0u   CHR  136,0       0t0          3 /dev/pts/0
bash    817 root    1u   CHR  136,0       0t0          3 /dev/pts/0
bash    817 root    2u   CHR  136,0       0t0          3 /dev/pts/0
bash    817 root    3u  sock    0,6       0t0      13386 protocol: NETLINK
bash    817 root    4r   REG    0,3         0 4026532155 net
bash    817 root  255u   CHR  136,0       0t0          3 /dev/pts/0

Cc: Stephen Hemminger <stephen@networkplumber.org>
Reported-by: Dilip Daya <dilip.daya@hp.com>
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 ip/ipnetns.c     | 2 +-
 lib/libnetlink.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index c9bc20a..fa2b681 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -150,7 +150,7 @@ static int netns_exec(int argc, char **argv)
 	name = argv[0];
 	cmd = argv[1];
 	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
-	netns = open(net_path, O_RDONLY);
+	netns = open(net_path, O_RDONLY | O_CLOEXEC);
 	if (netns < 0) {
 		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
 			name, strerror(errno));
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b17e1aa..9e2a795 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -43,7 +43,7 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions,
 
 	memset(rth, 0, sizeof(*rth));
 
-	rth->fd = socket(AF_NETLINK, SOCK_RAW, protocol);
+	rth->fd = socket(AF_NETLINK, SOCK_RAW | SOCK_CLOEXEC, protocol);
 	if (rth->fd < 0) {
 		perror("Cannot open netlink socket");
 		return -1;
-- 
1.8.2
