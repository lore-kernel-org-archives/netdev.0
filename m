From: Anton Aksola <aakso@iki.fi>
Subject: [PATCH v2] iproute2: build nsid-name cache only for commands that
 need it
Date: Fri, 16 Sep 2016 07:22:29 +0000
Message-ID: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-78.nebula.fi ([83.145.220.78]:41768 "EHLO smtp.nebula.fi"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753955AbcIPHW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 03:22:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The calling of netns_map_init() before command parsing introduced
a performance issue with large number of namespaces.

As commands such as add, del and exec do not need to iterate through
/var/run/netns it would be good not no build the cache before executing
these commands.

Example:
unpatched:
time seq 1 1000 | xargs -n 1 ip netns add

real    0m16.832s
user    0m1.350s
sys    0m15.029s

patched:
time seq 1 1000 | xargs -n 1 ip netns add

real    0m3.859s
user    0m0.132s
sys    0m3.205s

Signed-off-by: Anton Aksola <aakso@iki.fi>
---
 ip/ipnetns.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index af87065..564d034 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -775,17 +775,21 @@ static int netns_monitor(int argc, char **argv)
 
 int do_netns(int argc, char **argv)
 {
-	netns_map_init();
-
-	if (argc < 1)
+	if (argc < 1) {
+		netns_map_init();
 		return netns_list(0, NULL);
+	}
 
 	if ((matches(*argv, "list") == 0) || (matches(*argv, "show") == 0) ||
-	    (matches(*argv, "lst") == 0))
+	    (matches(*argv, "lst") == 0)) {
+		netns_map_init();
 		return netns_list(argc-1, argv+1);
+	}
 
-	if ((matches(*argv, "list-id") == 0))
+	if ((matches(*argv, "list-id") == 0)) {
+		netns_map_init();
 		return netns_list_id(argc-1, argv+1);
+	}
 
 	if (matches(*argv, "help") == 0)
 		return usage();
-- 
1.8.3.1
