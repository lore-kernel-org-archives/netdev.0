From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: Always leave subnet anycast group on link down
Date: Thu, 21 Jul 2016 14:44:16 +0100
Message-ID: <c805a77e-f21d-754c-79fe-12be45262888@brocade.com>
References: <a457dbfa-4320-a9b0-2bba-1ac488a61e50@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32975 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbcGUNon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 09:44:43 -0400
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by m0000700.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u6LDWLV5015582
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 06:44:42 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 2493fbcuek-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 06:44:42 -0700
In-Reply-To: <a457dbfa-4320-a9b0-2bba-1ac488a61e50@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Default kernel behavior is to delete IPv6 addresses on link
down, which entails deletion of the address-derived
subnet-router anycast address. The latter does not happen
with sysctl setting to keep global IPv6 addrs on link down,
so every link down/up causes an increment of the anycast
refcount, cf aca_users in __ipv6_dev_ac_inc(). This bogus
refcount stops the anycast being removed on subsequent
calls to delete the address. The solution is to leave the
group for this subnet anycast on link down also for the
callflow when global IPv6 addresses are kept.

Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/addrconf.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47f837a..3c69e56 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3562,6 +3562,8 @@ restart:
 		if (state != INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
 			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
+		} else if (idev->cnf.forwarding) {
+			addrconf_leave_anycast(ifa);
 		}
 
 		write_lock_bh(&idev->lock);
-- 
1.7.10.4
