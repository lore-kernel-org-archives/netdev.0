From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] iproute: extend route get for mpls routes
Date: Fri,  7 Jul 2017 15:08:11 -0700
Message-ID: <1499465291-2199-1-git-send-email-roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36012 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdGGWIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 18:08:16 -0400
Received: by mail-pf0-f169.google.com with SMTP id q86so22959986pfl.3
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 15:08:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch extends route get to support mpls specific
route attributes like RTA_NEWDST.

Input:
RTA_DST - input label
RTA_NEWDST - labels in packet for multipath selection

By default the getroute handler returns matched
nexthop label, via and oif

With fibmatch keyword (RTM_F_FIB_MATCH flag), full matched
route is returned.

example:
$ip -f mpls route show
101
        nexthop as to 102/103 via inet 172.16.2.2 dev virt1-2
        nexthop as to 302/303 via inet 172.16.12.2 dev virt1-12
201
        nexthop as to 202/203 via inet6 2001:db8:2::2 dev virt1-2
        nexthop as to 402/403 via inet6 2001:db8:12::2 dev virt1-12

$ip -f mpls route get 103
RTNETLINK answers: Network is unreachable

$ip -f mpls route get 101
101 as to 102/103 via inet 172.16.2.2 dev virt1-2

$ip -f mpls route get as to 302/303 101
101 as to 302/303 via inet 172.16.12.2 dev virt1-12

$ip -f mpls route get fibmatch 103
RTNETLINK answers: Network is unreachable

$ip -f mpls route get fibmatch 101
101
        nexthop as to 102/103 via inet 172.16.2.2 dev virt1-2
        nexthop as to 302/303 via inet 172.16.12.2 dev virt1-12

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/iproute.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index 4e022d7..a735d28 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1731,6 +1731,16 @@ static int iproute_get(int argc, char **argv)
 			addattr32(&req.n, sizeof(req), RTA_UID, uid);
 		} else if (matches(*argv, "fibmatch") == 0) {
 			fib_match = 1;
+		} else if (strcmp(*argv, "as") == 0) {
+			inet_prefix addr;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "to") == 0)
+				NEXT_ARG();
+			get_addr(&addr, *argv, req.r.rtm_family);
+			if (req.r.rtm_family == AF_UNSPEC)
+				req.r.rtm_family = addr.family;
+			addattr_l(&req.n, sizeof(req), RTA_NEWDST, &addr.data, addr.bytelen);
 		} else {
 			inet_prefix addr;
 
-- 
1.9.1
