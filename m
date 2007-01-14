From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] MCAST: Fix joining all-node multicast group on
 device initialization.
Date: Mon, 15 Jan 2007 03:56:01 +0900 (JST)
Message-ID: <20070115.035601.10978849.yoshfuji@linux-ipv6.org>
References: <200701131344.l0DDidDq007345@fire-2.osdl.org>
	<20070113134506.6021cf79.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gernoth@informatik.uni-erlangen.de,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:45792 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbXANSzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jan 2007 13:55:08 -0500
To: davem@davemloft.net
In-Reply-To: <20070113134506.6021cf79.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] MCAST: Fix joining all-node multicast group on device initialization.

Join all-node multicast group after assignment of dev->ip6_ptr
because it must be assigned when ipv6_dev_mc_inc() is called.
This fixes Bug#7817, reported by <gernoth@informatik.uni-erlangen.de>.

Closes: 7817
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 171e5b5..2a7e461 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -341,6 +341,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
+	struct in6_addr maddr;
 
 	ASSERT_RTNL();
 
@@ -425,6 +426,11 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 #endif
 	/* protected by rtnl_lock */
 	rcu_assign_pointer(dev->ip6_ptr, ndev);
+
+	/* Join all-node multicast group */
+	ipv6_addr_all_nodes(&maddr);
+	ipv6_dev_mc_inc(dev, &maddr);
+
 	return ndev;
 }
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a1c231a..882cde4 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2258,8 +2258,6 @@ void ipv6_mc_up(struct inet6_dev *idev)
 
 void ipv6_mc_init_dev(struct inet6_dev *idev)
 {
-	struct in6_addr maddr;
-
 	write_lock_bh(&idev->lock);
 	rwlock_init(&idev->mc_lock);
 	idev->mc_gq_running = 0;
@@ -2275,10 +2273,6 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 	idev->mc_maxdelay = IGMP6_UNSOLICITED_IVAL;
 	idev->mc_v1_seen = 0;
 	write_unlock_bh(&idev->lock);
-
-	/* Add all-nodes address. */
-	ipv6_addr_all_nodes(&maddr);
-	ipv6_dev_mc_inc(idev->dev, &maddr);
 }
 
 /*

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
