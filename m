From: Liping Zhang <zlpnobody@gmail.com>
Subject: [PATCH iproute2] ipmonitor: fix ip monitor can't work when NET_NS is not enabled
Date: Tue, 20 Sep 2016 02:09:02 -0700
Message-ID: <1474362542-5506-1-git-send-email-zlpnobody@gmail.com>
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33700 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752089AbcITJJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:09:21 -0400
Received: by mail-pa0-f66.google.com with SMTP id oz2so668433pac.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:09:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

In ip monitor, netns_map_init will check getnsid is supported or not.
But when /proc/self/ns/net does not exist, we just print out error
messages and exit. So user cannot use ip monitor anymore when
CONFIG_NET_NS is disabled:
  # ip monitor
  open("/proc/self/ns/net"): No such file or directory

If open "/proc/self/ns/net" failed, set have_rtnl_getnsid to false.

Fixes: d652ccbf8195 ("netns: allow to dump and monitor nsid")
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
---
 ip/ipnetns.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index af87065..ccc652c 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -72,8 +72,8 @@ static int ipnetns_have_nsid(void)
 	if (have_rtnl_getnsid < 0) {
 		fd = open("/proc/self/ns/net", O_RDONLY);
 		if (fd < 0) {
-			perror("open(\"/proc/self/ns/net\")");
-			exit(1);
+			have_rtnl_getnsid = 0;
+			return 0;
 		}
 
 		addattr32(&req.n, 1024, NETNSA_FD, fd);
-- 
1.9.1
