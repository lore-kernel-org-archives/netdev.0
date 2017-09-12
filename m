From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ipaddress: Fix segfault in 'addr showdump'
Date: Tue, 12 Sep 2017 16:58:12 +0200
Message-ID: <20170912145812.15380-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47966 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751404AbdILO6X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 10:58:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Obviously, 'addr showdump' feature wasn't adjusted to json output
support. As a consequence, calls to print_string() in print_addrinfo()
tried to dereference a NULL FILE pointer.

Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9797145023966..ee6c9f588e7ba 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1801,17 +1801,31 @@ static int show_handler(const struct sockaddr_nl *nl,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	printf("if%d:\n", ifa->ifa_index);
+	open_json_object(NULL);
+	print_int(PRINT_ANY, "index", "if%d:\n", ifa->ifa_index);
 	print_addrinfo(NULL, n, stdout);
+	close_json_object();
 	return 0;
 }
 
 static int ipaddr_showdump(void)
 {
+	int err;
+
 	if (ipadd_dump_check_magic())
 		exit(-1);
 
-	exit(rtnl_from_file(stdin, &show_handler, NULL));
+	new_json_obj(json, stdout);
+	open_json_object(NULL);
+	open_json_array(PRINT_JSON, "addr_info");
+
+	err = rtnl_from_file(stdin, &show_handler, NULL);
+
+	close_json_array(PRINT_JSON, NULL);
+	close_json_object();
+	delete_json_obj();
+
+	exit(err);
 }
 
 static int restore_handler(const struct sockaddr_nl *nl,
-- 
2.13.1
