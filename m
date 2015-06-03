From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net iproute2 v4] mpls: always set type RTN_UNICAST and scope RT_SCOPE_UNIVERSE for route add/deletes
Date: Tue,  2 Jun 2015 17:42:47 -0700
Message-ID: <1433292167-13364-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: stephen@networkplumber.org, ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:33359 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbbFCAm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 20:42:58 -0400
Received: by qgfa63 with SMTP id a63so66144680qgf.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 17:42:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch fixes incorrect -EINVAL errors due to invalid
scope and type during mpls route deletes.

$ip -f mpls route add 100 as 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route show
100 as to 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1
RTNETLINK answers: Invalid argument

$ip -f mpls route del 100
RTNETLINK answers: Invalid argument

After patch:

$ip -f mpls route show
100 as to 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route show

Always set type to RTN_UNICAST for mpls route add/deletes.
Also to keep things consistent with kernel set scope to
RT_SCOPE_UNIVERSE for both mpls and ipv6 routes. Both mpls and ipv6 route
deletes ignore scope.

Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
--
v4 move fix to iproute2
---
 ip/iproute.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c6..d0b9910 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -803,6 +803,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	int scope_ok = 0;
 	int table_ok = 0;
 	int raw = 0;
+	int type_ok = 0;
 
 	memset(&req, 0, sizeof(req));
 
@@ -1095,6 +1096,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			    rtnl_rtntype_a2n(&type, *argv) == 0) {
 				NEXT_ARG();
 				req.r.rtm_type = type;
+				type_ok = 1;
 			}
 
 			if (matches(*argv, "help") == 0)
@@ -1136,6 +1138,9 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (nhs_ok)
 		parse_nexthops(&req.n, &req.r, argc, argv);
 
+	if (req.r.rtm_family == AF_UNSPEC)
+		req.r.rtm_family = AF_INET;
+
 	if (!table_ok) {
 		if (req.r.rtm_type == RTN_LOCAL ||
 		    req.r.rtm_type == RTN_BROADCAST ||
@@ -1144,8 +1149,11 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			req.r.rtm_table = RT_TABLE_LOCAL;
 	}
 	if (!scope_ok) {
-		if (req.r.rtm_type == RTN_LOCAL ||
-		    req.r.rtm_type == RTN_NAT)
+		if (req.r.rtm_family == AF_INET6 ||
+		    req.r.rtm_family == AF_MPLS)
+			req.r.rtm_scope = RT_SCOPE_UNIVERSE;
+		else if (req.r.rtm_type == RTN_LOCAL ||
+			 req.r.rtm_type == RTN_NAT)
 			req.r.rtm_scope = RT_SCOPE_HOST;
 		else if (req.r.rtm_type == RTN_BROADCAST ||
 			 req.r.rtm_type == RTN_MULTICAST ||
@@ -1160,8 +1168,8 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		}
 	}
 
-	if (req.r.rtm_family == AF_UNSPEC)
-		req.r.rtm_family = AF_INET;
+	if (!type_ok && req.r.rtm_family == AF_MPLS)
+		req.r.rtm_type = RTN_UNICAST;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
 		return -2;
-- 
1.7.10.4
