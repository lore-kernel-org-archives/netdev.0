From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 4/6] ipaddress: fix ipaddr_flush for Linux >= 3.1
Date: Sun,  8 Nov 2015 21:22:19 +0100
Message-ID: <1447014141-3565-5-git-send-email-phil@nwl.cc>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39891 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751349AbbKHUWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 15:22:24 -0500
In-Reply-To: <1447014141-3565-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux version 3.1 introduced a consistency check for netlink dumps in
commit 670dc28 ("netlink: advertise incomplete dumps"). This bites
iproute2 when flushing more addresses than can fit into a single
RTM_GETADDR response. To silence the spurious error message "Dump was
interrupted and may be inconsistent.", advise rtnl_dump_filter_l() to
not care about NLM_F_DUMP_INTR.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b5b444b..23e0308 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1398,7 +1398,8 @@ static int ipaddr_flush(void)
 			exit(1);
 		}
 		filter.flushed = 0;
-		if (rtnl_dump_filter(&rth, print_addrinfo, stdout) < 0) {
+		if (rtnl_dump_filter_nc(&rth, print_addrinfo,
+					stdout, NLM_F_DUMP_INTR) < 0) {
 			fprintf(stderr, "Flush terminated\n");
 			exit(1);
 		}
-- 
2.1.2
