From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 1/5] ipaddress: simplify ipaddr_flush()
Date: Tue, 24 Nov 2015 15:31:00 +0100
Message-ID: <1448375464-12145-2-git-send-email-phil@nwl.cc>
References: <20151123163115.5f8be482@xeon-e3>
 <1448375464-12145-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46532 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbbKXObm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 09:31:42 -0500
In-Reply-To: <1448375464-12145-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it's no longer relevant whether an IP address is primary or
secondary when flushing, ipaddr_flush() can be simplified a bit.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 38 +-------------------------------------
 1 file changed, 1 insertion(+), 37 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 05358c9..26e91c9 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1148,28 +1148,6 @@ brief_exit:
 	return 0;
 }
 
-static int print_addrinfo_primary(const struct sockaddr_nl *who,
-				  struct nlmsghdr *n, void *arg)
-{
-	struct ifaddrmsg *ifa = NLMSG_DATA(n);
-
-	if (ifa->ifa_flags & IFA_F_SECONDARY)
-		return 0;
-
-	return print_addrinfo(who, n, arg);
-}
-
-static int print_addrinfo_secondary(const struct sockaddr_nl *who,
-				    struct nlmsghdr *n, void *arg)
-{
-	struct ifaddrmsg *ifa = NLMSG_DATA(n);
-
-	if (!(ifa->ifa_flags & IFA_F_SECONDARY))
-		return 0;
-
-	return print_addrinfo(who, n, arg);
-}
-
 struct nlmsg_list
 {
 	struct nlmsg_list *next;
@@ -1420,26 +1398,12 @@ static int ipaddr_flush(void)
 	filter.flushe = sizeof(flushb);
 
 	while ((max_flush_loops == 0) || (round < max_flush_loops)) {
-		const struct rtnl_dump_filter_arg a[3] = {
-			{
-				.filter = print_addrinfo_secondary,
-				.arg1 = stdout,
-			},
-			{
-				.filter = print_addrinfo_primary,
-				.arg1 = stdout,
-			},
-			{
-				.filter = NULL,
-				.arg1 = NULL,
-			},
-		};
 		if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 			perror("Cannot send dump request");
 			exit(1);
 		}
 		filter.flushed = 0;
-		if (rtnl_dump_filter_l(&rth, a) < 0) {
+		if (rtnl_dump_filter(&rth, print_addrinfo, stdout) < 0) {
 			fprintf(stderr, "Flush terminated\n");
 			exit(1);
 		}
-- 
2.5.0
