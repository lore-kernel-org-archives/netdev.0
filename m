From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Fri, 22 Apr 2016 17:14:35 +0100
Message-ID: <571A4DEB.3090204@brocade.com>
References: <571A4D11.8070307@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:49084 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752827AbcDVQOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 12:14:46 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3MG5swo017927
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 09:14:45 -0700
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 22fm1p8m62-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 09:14:45 -0700
In-Reply-To: <571A4D11.8070307@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f1705ec197e7 ("net: ipv6: Make address flushing on ifdown 
optional") added the option to retain user configured addresses on an
admin down. A comment to one of the later revisions suggested using
the IFA_F_PERMANENT flag rather than adding a user_managed boolean to
the ifaddr struct. A side effect of this change is that link local and
loopback addresses were also retained which was not part of the
objective of the original changes. The commit 70af921db6f8 ("net: ipv6: 
Do not keep linklocal and loopback addresses") ensures that these are
no longer kept. Similarly, the present fix ensures that these addresses
are not incorrectly fixed up. 

Testing also with the recent patch in place to delete host routes on
ifdown still shows that fixup of the LL & loopback addrs is incorrectly
being attempted (and without that patch was causing a crash in fib6).
Another approach to this is through code inspection by checking where
the user_managed flag in the original dahern patch (which we have been
using for nearly a year) has been replaced by checking IFA_F_PERMANENT.

Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/addrconf.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 23cec53..cba4e10 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3200,6 +3200,12 @@ static void l3mdev_check_host_rt(struct inet6_dev *idev,
 }
 #endif
 
+static bool addr_is_local(const struct in6_addr *addr)
+{
+	return ipv6_addr_type(addr) &
+		(IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
+}
+
 static int fixup_permanent_addr(struct inet6_dev *idev,
 				struct inet6_ifaddr *ifp)
 {
@@ -3238,6 +3244,7 @@ static void addrconf_permanent_addr(struct net_device *dev)
 
 	list_for_each_entry_safe(ifp, tmp, &idev->addr_list, if_list) {
 		if ((ifp->flags & IFA_F_PERMANENT) &&
+		    !addr_is_local(&ifp->addr) &&
 		    fixup_permanent_addr(idev, ifp) < 0) {
 			write_unlock_bh(&idev->lock);
 			ipv6_del_addr(ifp);
@@ -3448,12 +3455,6 @@ static void addrconf_type_change(struct net_device *dev, unsigned long event)
 		ipv6_mc_unmap(idev);
 }
 
-static bool addr_is_local(const struct in6_addr *addr)
-{
-	return ipv6_addr_type(addr) &
-		(IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
-}
-
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
-- 
1.7.10.4
