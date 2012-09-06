From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH] Fix "ip -6 route add ... nexthop"
Date: Thu,  6 Sep 2012 19:30:49 +0200
Message-ID: <1346952649-5716-2-git-send-email-bernat@luffy.cx>
References: <1346952649-5716-1-git-send-email-bernat@luffy.cx>
Cc: Vincent Bernat <bernat@luffy.cx>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:42669 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759424Ab2IFRsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:48:25 -0400
In-Reply-To: <1346952649-5716-1-git-send-email-bernat@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 multipath routes were not accepted by "ip route" because an IPv4
address was expected for each gateway. Use `get_addr()` instead of
`get_addr32()`.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 ip/iproute.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 522dd28..c78d4f7 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -624,16 +624,20 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 }
 
 
-int parse_one_nh(struct rtattr *rta, struct rtnexthop *rtnh, int *argcp, char ***argvp)
+int parse_one_nh(struct rtmsg *r, struct rtattr *rta, struct rtnexthop *rtnh, int *argcp, char ***argvp)
 {
 	int argc = *argcp;
 	char **argv = *argvp;
 
 	while (++argv, --argc > 0) {
 		if (strcmp(*argv, "via") == 0) {
+			inet_prefix addr;
 			NEXT_ARG();
-			rta_addattr32(rta, 4096, RTA_GATEWAY, get_addr32(*argv));
-			rtnh->rtnh_len += sizeof(struct rtattr) + 4;
+                        get_addr(&addr, *argv, r->rtm_family);
+			if (r->rtm_family == AF_UNSPEC)
+				r->rtm_family = addr.family;
+			rta_addattr_l(rta, 4096, RTA_GATEWAY, &addr.data, addr.bytelen);
+                        rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			if ((rtnh->rtnh_ifindex = ll_name_to_index(*argv)) == 0) {
@@ -685,7 +689,7 @@ int parse_nexthops(struct nlmsghdr *n, struct rtmsg *r, int argc, char **argv)
 		memset(rtnh, 0, sizeof(*rtnh));
 		rtnh->rtnh_len = sizeof(*rtnh);
 		rta->rta_len += rtnh->rtnh_len;
-		parse_one_nh(rta, rtnh, &argc, &argv);
+		parse_one_nh(r, rta, rtnh, &argc, &argv);
 		rtnh = RTNH_NEXT(rtnh);
 	}
 
-- 
1.7.10.4
