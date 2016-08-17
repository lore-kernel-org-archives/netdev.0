From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: Remove addresses for failures with strict DAD
Date: Wed, 17 Aug 2016 11:28:40 +0100
Message-ID: <1471429720-6141-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34746 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbcHQK3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:29:44 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7HAThY4020727
	for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 03:29:43 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 24t2xukhgu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 03:29:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If DAD fails with accept_dad set to 2, global addresses and host routes
are incorrectly left in place. Even though disable_ipv6 is set,
contrary to documentation, the addresses are not dynamically deleted
from the interface. It is only on a subsequent link down/up that these
are removed. The fix is not only to set the disable_ipv6 flag, but to
actually disable IPv6 when DAD fails in this case. This results in the
addresses and routes being immediately deleted. The DAD failure
for the LL addr is determined as before via netlink, or by the absence
of the LL addr (which also previously would have had to be checked for
in case of an intervening link down/up).

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
 net/ipv6/addrconf.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index df8425f..6be5a95 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -135,6 +135,7 @@ static int ipv6_count_addresses(struct inet6_dev *idev);
 static int ipv6_generate_stable_address(struct in6_addr *addr,
 					u8 dad_count,
 					const struct inet6_dev *idev);
+static void dev_disable_change(struct inet6_dev *idev);
 
 /*
  *	Configured unicast address hash table
@@ -1945,6 +1946,12 @@ lock_errdad:
 
 			pr_info("%s: IPv6 being disabled!\n",
 				ifp->idev->dev->name);
+			spin_unlock_bh(&ifp->lock);
+			addrconf_dad_stop(ifp, 1);
+			rtnl_lock();
+			dev_disable_change(idev);
+			rtnl_unlock();
+			return;
 		}
 	}
 
-- 
1.7.10.4
