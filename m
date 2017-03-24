From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next v2 2/3] ip netconf: Show all address families by default in dumps
Date: Thu, 23 Mar 2017 19:51:21 -0700
Message-ID: <1490323882-11609-3-git-send-email-dsa@cumulusnetworks.com>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:32850 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933818AbdCXCvb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 22:51:31 -0400
Received: by mail-pg0-f52.google.com with SMTP id w20so1442424pgc.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 19:51:30 -0700 (PDT)
In-Reply-To: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, 'ip netconf' only shows ipv4 and ipv6 netconf settings. If IPv6
is not enabled, the dump ends with
    RTNETLINK answers: Operation not supported

when IPv6 request is attempted. Further, if the mpls_router module is also
loaded a separate request is needed to get MPLS settings.

To make this better going forward, use the new PF_UNSPEC dump all option
if the kernel supports it. If the kernel does not, it sets NLMSG_ERROR and
returns EOPNOTSUPP which is trapped and we fall back to the existing output
to maintain compatibility with existing kernels.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipnetconf.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index af539f5e945c..dc0851025223 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -19,6 +19,7 @@
 #include <sys/time.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
+#include <errno.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -197,16 +198,26 @@ static int do_show(int argc, char **argv)
 		}
 		rtnl_listen(&rth, print_netconf, stdout);
 	} else {
+		rth.flags = RTNL_HANDLE_F_SUPPRESS_NLERR;
 dump:
 		if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNETCONF) < 0) {
 			perror("Cannot send dump request");
 			exit(1);
 		}
 		if (rtnl_dump_filter(&rth, print_netconf2, stdout) < 0) {
+			/* kernel does not support netconf dump on AF_UNSPEC;
+			 * fall back to requesting by family
+			 */
+			if (errno == EOPNOTSUPP &&
+			    filter.family == AF_UNSPEC) {
+				filter.family = AF_INET;
+				goto dump;
+			}
+			perror("RTNETLINK answers");
 			fprintf(stderr, "Dump terminated\n");
 			exit(1);
 		}
-		if (preferred_family == AF_UNSPEC) {
+		if (preferred_family == AF_UNSPEC && filter.family == AF_INET) {
 			preferred_family = AF_INET6;
 			filter.family = AF_INET6;
 			goto dump;
-- 
2.1.4
