From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] IPROUTE2: Fix bug  in display of ipv6 cloned/cached routes
Date: Wed, 11 Jul 2007 11:37:43 -0700
Message-ID: <1184179063.16607.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:59030 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765736AbXGKSht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 14:37:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6BHY0BA007379
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 13:34:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BIbjcj529940
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 14:37:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BIbjQ5030613
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 14:37:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug in the 'ip' command to display 
IPv6 cloned routes.
  ip -6 route ls cache
returns empty even when there are cloned routes because of
of a missing else in print_route() routine.

Thanks
Sridhar

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>	

diff --git a/ip/iproute.c b/ip/iproute.c
index 6fe4a70..08feceb 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -176,18 +176,19 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (filter.cloned) {
 			if (!(r->rtm_flags&RTM_F_CLONED))
 				return 0;
-		}
-		if (filter.tb) {
-			if (r->rtm_flags&RTM_F_CLONED)
-				return 0;
-			if (filter.tb == RT_TABLE_LOCAL) {
-				if (r->rtm_type != RTN_LOCAL)
+		} else {
+			if (filter.tb) {
+				if (r->rtm_flags&RTM_F_CLONED)
 					return 0;
-			} else if (filter.tb == RT_TABLE_MAIN) {
-				if (r->rtm_type == RTN_LOCAL)
+				if (filter.tb == RT_TABLE_LOCAL) {
+					if (r->rtm_type != RTN_LOCAL)
+						return 0;
+				} else if (filter.tb == RT_TABLE_MAIN) {
+					if (r->rtm_type == RTN_LOCAL)
+						return 0;
+				} else {
 					return 0;
-			} else {
-				return 0;
+				}
 			}
 		}
 	} else {


