From: Sorin Dumitru <sdumitru@ixiacom.com>
Subject: [PATCH] ipv6: remove some deadcode
Date: Thu, 30 Aug 2012 15:01:45 +0300
Message-ID: <1346328105-19541-1-git-send-email-sdumitru@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:18298
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750935Ab2H3MCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 08:02:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ipv6_regen_rndid no longer returns anything other than 0
so there's no point in verifying what it returns

Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
---
 net/ipv6/addrconf.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6bc85f7..055627f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -127,8 +127,8 @@ static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
 #endif
 
 #ifdef CONFIG_IPV6_PRIVACY
-static int __ipv6_regen_rndid(struct inet6_dev *idev);
-static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
+static void __ipv6_regen_rndid(struct inet6_dev *idev);
+static void __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
 static void ipv6_regen_rndid(unsigned long data);
 #endif
 
@@ -852,16 +852,7 @@ retry:
 	}
 	in6_ifa_hold(ifp);
 	memcpy(addr.s6_addr, ifp->addr.s6_addr, 8);
-	if (__ipv6_try_regen_rndid(idev, tmpaddr) < 0) {
-		spin_unlock_bh(&ifp->lock);
-		write_unlock(&idev->lock);
-		pr_warn("%s: regeneration of randomized interface id failed\n",
-			__func__);
-		in6_ifa_put(ifp);
-		in6_dev_put(idev);
-		ret = -1;
-		goto out;
-	}
+	__ipv6_try_regen_rndid(idev, tmpaddr);
 	memcpy(&addr.s6_addr[8], idev->rndid, 8);
 	age = (now - ifp->tstamp) / HZ;
 	tmp_valid_lft = min_t(__u32,
@@ -1600,7 +1591,7 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 
 #ifdef CONFIG_IPV6_PRIVACY
 /* (re)generation of randomized interface identifier (RFC 3041 3.2, 3.5) */
-static int __ipv6_regen_rndid(struct inet6_dev *idev)
+static void __ipv6_regen_rndid(struct inet6_dev *idev)
 {
 regen:
 	get_random_bytes(idev->rndid, sizeof(idev->rndid));
@@ -1627,8 +1618,6 @@ regen:
 		if ((idev->rndid[2]|idev->rndid[3]|idev->rndid[4]|idev->rndid[5]|idev->rndid[6]|idev->rndid[7]) == 0x00)
 			goto regen;
 	}
-
-	return 0;
 }
 
 static void ipv6_regen_rndid(unsigned long data)
@@ -1642,8 +1631,7 @@ static void ipv6_regen_rndid(unsigned long data)
 	if (idev->dead)
 		goto out;
 
-	if (__ipv6_regen_rndid(idev) < 0)
-		goto out;
+	__ipv6_regen_rndid(idev);
 
 	expires = jiffies +
 		idev->cnf.temp_prefered_lft * HZ -
@@ -1664,13 +1652,10 @@ out:
 	in6_dev_put(idev);
 }
 
-static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr)
+static void  __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr)
 {
-	int ret = 0;
-
 	if (tmpaddr && memcmp(idev->rndid, &tmpaddr->s6_addr[8], 8) == 0)
-		ret = __ipv6_regen_rndid(idev);
-	return ret;
+		__ipv6_regen_rndid(idev);
 }
 #endif
 
-- 
1.7.12
