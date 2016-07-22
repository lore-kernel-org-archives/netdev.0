From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH v2] net: ipv6: Always leave anycast and multicast groups on link down
Date: Fri, 22 Jul 2016 18:32:11 +0100
Message-ID: <1469208731-1085-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Manning <mmanning@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58020 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753864AbcGVRda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 13:33:30 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6MHXJCS001002
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:33:29 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 24axwuw6nw-19
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 10:33:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default kernel behavior is to delete IPv6 addresses on link
down, which entails deletion of the multicast and the
subnet-router anycast addresses. These deletions do not
happen with sysctl setting to keep global IPv6 addresses on
link down, so every link down/up causes an increment of the
anycast and multicast refcounts. These bogus refcounts may
stop these addrs from being removed on subsequent calls to
delete them. The solution is to leave the groups for the
multicast and subnet anycast on link down for the callflow
when global IPv6 addresses are kept.

Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/addrconf.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47f837a..047c75a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3562,6 +3562,10 @@ restart:
 		if (state != INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
 			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
+		} else {
+			if (idev->cnf.forwarding)
+				addrconf_leave_anycast(ifa);
+			addrconf_leave_solict(ifa->idev, &ifa->addr);
 		}
 
 		write_lock_bh(&idev->lock);
-- 
1.7.10.4
