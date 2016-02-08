From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip route: add mpls multipath support
Date: Sun,  7 Feb 2016 16:28:16 -0800
Message-ID: <1454891296-20147-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34490 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873AbcBHA2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 19:28:20 -0500
Received: by mail-pf0-f169.google.com with SMTP id o185so100353275pfb.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 16:28:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to add mpls multipath
routes.

example:
ip -f mpls route add 100 \
	nexthop as 200 via inet 10.1.1.2 dev swp1 \
	nexthop as 700 via inet 10.1.1.6 dev swp2

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/iproute.c | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index d5e3ebe..5e7ef16 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -646,7 +646,13 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					lwt_print_encap(fp,
 							tb[RTA_ENCAP_TYPE],
 							tb[RTA_ENCAP]);
-
+				if (tb[RTA_NEWDST]) {
+					fprintf(fp, " as to %s ",
+						format_host(r->rtm_family,
+						RTA_PAYLOAD(tb[RTA_NEWDST]),
+						RTA_DATA(tb[RTA_NEWDST]),
+						abuf, sizeof(abuf)));
+				}
 				if (tb[RTA_GATEWAY]) {
 					fprintf(fp, " via %s ",
 						format_host(r->rtm_family,
@@ -681,7 +687,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					fprintf(fp, "(ttl>%d)", nh->rtnh_hops);
 			} else {
 				fprintf(fp, " dev %s", ll_index_to_name(nh->rtnh_ifindex));
-				fprintf(fp, " weight %d", nh->rtnh_hops+1);
+				if (r->rtm_family != AF_MPLS)
+					fprintf(fp, " weight %d",
+						nh->rtnh_hops+1);
 			}
 			if (nh->rtnh_flags & RTNH_F_DEAD)
 				fprintf(fp, " dead");
@@ -743,7 +751,7 @@ static int parse_one_nh(struct nlmsghdr *n, struct rtmsg *r,
 				rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
 			} else {
 				rta_addattr_l(rta, 4096, RTA_VIA, &addr.family, addr.bytelen+2);
-				rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen+2;
+				rtnh->rtnh_len += RTA_SPACE(addr.bytelen+2);
 			}
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
@@ -771,6 +779,16 @@ static int parse_one_nh(struct nlmsghdr *n, struct rtmsg *r,
 
 			lwt_parse_encap(rta, 4096, &argc, &argv);
 			rtnh->rtnh_len += rta->rta_len - len;
+		} else if (strcmp(*argv, "as") == 0) {
+			inet_prefix addr;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "to") == 0)
+				NEXT_ARG();
+			get_addr(&addr, *argv, r->rtm_family);
+			rta_addattr_l(rta, 4096, RTA_NEWDST, &addr.data,
+				      addr.bytelen);
+			rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
 		} else
 			break;
 	}
@@ -881,9 +899,11 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (req.r.rtm_family == AF_UNSPEC)
 				req.r.rtm_family = addr.family;
 			if (addr.family == req.r.rtm_family)
-				addattr_l(&req.n, sizeof(req), RTA_GATEWAY, &addr.data, addr.bytelen);
+				addattr_l(&req.n, sizeof(req), RTA_GATEWAY,
+					  &addr.data, addr.bytelen);
 			else
-				addattr_l(&req.n, sizeof(req), RTA_VIA, &addr.family, addr.bytelen+2);
+				addattr_l(&req.n, sizeof(req), RTA_VIA,
+					  &addr.family, addr.bytelen+2);
 		} else if (strcmp(*argv, "from") == 0) {
 			inet_prefix addr;
 			NEXT_ARG();
-- 
1.9.1
