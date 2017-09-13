From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] ipaddress: Fix segfault in 'addr showdump'
Date: Wed, 13 Sep 2017 11:20:34 +0200
Message-ID: <20170913092034.7002-1-phil@nwl.cc>
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Julien Fortin <julien@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50188 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751507AbdIMJUq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 05:20:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Obviously, 'addr showdump' feature wasn't adjusted to json output
support. As a consequence, calls to print_string() in print_addrinfo()
tried to dereference a NULL FILE pointer.

Cc: Julien Fortin <julien@cumulusnetworks.com>
Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
Signed-off-by: Phil Sutter <phil@nwl.cc>
--
Changes since v1:
Align json output with that of 'ip -j addr show':
- Interface index label is 'ifindex', not 'index' and it doesn't belong
  to 'addr_info' array.
- Create one 'addr_info' array per dumped address, not one for all.
---
 ip/ipaddress.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9797145023966..4c47809570410 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1801,17 +1801,33 @@ static int show_handler(const struct sockaddr_nl *nl,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	printf("if%d:\n", ifa->ifa_index);
+	open_json_object(NULL);
+	print_int(PRINT_ANY, "ifindex", "if%d:\n", ifa->ifa_index);
+
+	open_json_array(PRINT_JSON, "addr_info");
+	open_json_object(NULL);
+
 	print_addrinfo(NULL, n, stdout);
+
+	close_json_object();
+	close_json_array(PRINT_JSON, NULL);
+
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
+	err = rtnl_from_file(stdin, &show_handler, NULL);
+	delete_json_obj();
+
+	exit(err);
 }
 
 static int restore_handler(const struct sockaddr_nl *nl,
-- 
2.13.1
