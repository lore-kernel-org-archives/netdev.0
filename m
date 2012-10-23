From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/2] ip: fix "ip -6 route add ... nexthop"
Date: Tue, 23 Oct 2012 14:42:55 +0200
Message-ID: <1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20121023.023910.80461258323920266.davem@davemloft.net>
Cc: netdev@vger.kernel.org, joe@perches.com, bernat@luffy.cx,
	eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:32948 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab2JWMe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 08:34:57 -0400
In-Reply-To: <20121023.023910.80461258323920266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <bernat@luffy.cx>

IPv6 multipath routes were not accepted by "ip route" because an IPv4
address was expected for each gateway. Use `get_addr()` instead of
`get_addr32()`.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iproute.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 3e5f8d0..c60156f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -625,16 +625,20 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
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
+			get_addr(&addr, *argv, r->rtm_family);
+			if (r->rtm_family == AF_UNSPEC)
+				r->rtm_family = addr.family;
+			rta_addattr_l(rta, 4096, RTA_GATEWAY, &addr.data, addr.bytelen);
+			rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			if ((rtnh->rtnh_ifindex = ll_name_to_index(*argv)) == 0) {
@@ -686,7 +690,7 @@ int parse_nexthops(struct nlmsghdr *n, struct rtmsg *r, int argc, char **argv)
 		memset(rtnh, 0, sizeof(*rtnh));
 		rtnh->rtnh_len = sizeof(*rtnh);
 		rta->rta_len += rtnh->rtnh_len;
-		parse_one_nh(rta, rtnh, &argc, &argv);
+		parse_one_nh(r, rta, rtnh, &argc, &argv);
 		rtnh = RTNH_NEXT(rtnh);
 	}
 
-- 
1.7.12
