From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH v2] net: ipv6: Remove addresses for failures with strict DAD
Date: Thu, 18 Aug 2016 14:39:40 +0100
Message-ID: <1471527581-9125-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48816 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1945912AbcHRNkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 09:40:17 -0400
Received: from pps.filterd (m0048193.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7IDe8qn002786
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 06:40:16 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 24t2951pw3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 06:40:16 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If DAD fails with accept_dad set to 2, global addresses and host routes
are incorrectly left in place. Even though disable_ipv6 is set,
contrary to documentation, the addresses are not dynamically deleted
from the interface. It is only on a subsequent link down/up that these
are removed. The fix is not only to set the disable_ipv6 flag, but
also to call addrconf_ifdown(), which is the action to carry out when
disabling IPv6. This results in the addresses and routes being deleted
immediately. The DAD failure for the LL addr is determined as before
via netlink, or by the absence of the LL addr (which also previously
would have had to be checked for in case of an intervening link down
and up). As the call to addrconf_ifdown() requires an rtnl lock, the
logic to disable IPv6 when DAD fails is moved to addrconf_dad_work().

Previous behavior:

root@vm1:/# sysctl net.ipv6.conf.eth3.accept_dad=2
net.ipv6.conf.eth3.accept_dad = 2
root@vm1:/# ip -6 addr add 2000::10/64 dev eth3
root@vm1:/# ip link set up eth3
root@vm1:/# ip -6 addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2000::10/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe43:dd5a/64 scope link tentative dadfailed
       valid_lft forever preferred_lft forever
root@vm1:/# ip -6 route show dev eth3
2000::/64  proto kernel  metric 256
fe80::/64  proto kernel  metric 256
root@vm1:/# ip link set down eth3
root@vm1:/# ip link set up eth3
root@vm1:/# ip -6 addr show dev eth3
root@vm1:/# ip -6 route show dev eth3
root@vm1:/#

New behavior:

root@vm1:/# sysctl net.ipv6.conf.eth3.accept_dad=2
net.ipv6.conf.eth3.accept_dad = 2
root@vm1:/# ip -6 addr add 2000::10/64 dev eth3
root@vm1:/# ip link set up eth3
root@vm1:/# ip -6 addr show dev eth3
root@vm1:/# ip -6 route show dev eth3
root@vm1:/#

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/addrconf.c |   34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index df8425f..f418d2e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1872,7 +1872,6 @@ static int addrconf_dad_end(struct inet6_ifaddr *ifp)
 
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
-	struct in6_addr addr;
 	struct inet6_dev *idev = ifp->idev;
 	struct net *net = dev_net(ifp->idev->dev);
 
@@ -1934,18 +1933,6 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		in6_ifa_put(ifp2);
 lock_errdad:
 		spin_lock_bh(&ifp->lock);
-	} else if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
-		addr.s6_addr32[0] = htonl(0xfe800000);
-		addr.s6_addr32[1] = 0;
-
-		if (!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
-		    ipv6_addr_equal(&ifp->addr, &addr)) {
-			/* DAD failed for link-local based on MAC address */
-			idev->cnf.disable_ipv6 = 1;
-
-			pr_info("%s: IPv6 being disabled!\n",
-				ifp->idev->dev->name);
-		}
 	}
 
 errdad:
@@ -3821,6 +3808,7 @@ static void addrconf_dad_work(struct work_struct *w)
 						dad_work);
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr mcaddr;
+	bool disable_ipv6 = false;
 
 	enum {
 		DAD_PROCESS,
@@ -3837,6 +3825,24 @@ static void addrconf_dad_work(struct work_struct *w)
 	} else if (ifp->state == INET6_IFADDR_STATE_ERRDAD) {
 		action = DAD_ABORT;
 		ifp->state = INET6_IFADDR_STATE_POSTDAD;
+
+		if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6 &&
+		    !(ifp->flags & IFA_F_STABLE_PRIVACY)) {
+			struct in6_addr addr;
+
+			addr.s6_addr32[0] = htonl(0xfe800000);
+			addr.s6_addr32[1] = 0;
+
+			if (!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
+			    ipv6_addr_equal(&ifp->addr, &addr)) {
+				/* DAD failed for link-local based on MAC */
+				idev->cnf.disable_ipv6 = 1;
+
+				pr_info("%s: IPv6 being disabled!\n",
+					ifp->idev->dev->name);
+				disable_ipv6 = true;
+			}
+		}
 	}
 	spin_unlock_bh(&ifp->lock);
 
@@ -3845,6 +3851,8 @@ static void addrconf_dad_work(struct work_struct *w)
 		goto out;
 	} else if (action == DAD_ABORT) {
 		addrconf_dad_stop(ifp, 1);
+		if (disable_ipv6)
+			addrconf_ifdown(idev->dev, 0);
 		goto out;
 	}
 
-- 
1.7.10.4
