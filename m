From: Anton Aksola <aakso@iki.fi>
Subject: [PATCH] iproute2: build nsid-name cache only for commands that need
 it
Date: Thu, 15 Sep 2016 08:23:26 +0000
Message-ID: <20160915082326.GA1635@toys.tundra.dog-lvm.novalocal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-78.nebula.fi ([83.145.220.78]:44014 "EHLO smtp.nebula.fi"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758030AbcIOIaq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 04:30:46 -0400
Received: from toys.tundra.dog-lvm.novalocal (hel2-77-86-247-86.ext.nebulacloud.fi [77.86.247.86])
        (using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by smtp.nebula.fi (Postfix) with ESMTPS id 77832D00E86
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 11:23:20 +0300 (EEST)
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
 ip/ipnetns.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index af87065..4546fe7 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -775,8 +775,6 @@ static int netns_monitor(int argc, char **argv)
 
 int do_netns(int argc, char **argv)
 {
-	netns_map_init();
-
 	if (argc < 1)
 		return netns_list(0, NULL);
 
@@ -784,8 +782,10 @@ int do_netns(int argc, char **argv)
 	    (matches(*argv, "lst") == 0))
 		return netns_list(argc-1, argv+1);
 
-	if ((matches(*argv, "list-id") == 0))
+	if ((matches(*argv, "list-id") == 0)) {
+		netns_map_init();
 		return netns_list_id(argc-1, argv+1);
+	}
 
 	if (matches(*argv, "help") == 0)
 		return usage();
-- 
1.8.3.1
