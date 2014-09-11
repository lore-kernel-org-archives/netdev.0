From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 8/8] ipv6: refactor ipv6_dev_mc_inc()
Date: Thu, 11 Sep 2014 15:35:16 -0700
Message-ID: <1410474916-21873-9-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:57648 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852AbaIKWfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:48 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so11260282pdj.9
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:47 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor out allocation and initialization and make
the refcount code more readable.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/mcast.c | 82 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 49 insertions(+), 33 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d64e263..592eba6 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -641,14 +641,6 @@ bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	return rv;
 }
 
-static void ma_put(struct ifmcaddr6 *mc)
-{
-	if (atomic_dec_and_test(&mc->mca_refcnt)) {
-		in6_dev_put(mc->idev);
-		kfree(mc);
-	}
-}
-
 static void igmp6_group_added(struct ifmcaddr6 *mc)
 {
 	struct net_device *dev = mc->idev->dev;
@@ -814,6 +806,48 @@ static void mld_clear_delrec(struct inet6_dev *idev)
 	read_unlock_bh(&idev->lock);
 }
 
+static void mca_get(struct ifmcaddr6 *mc)
+{
+	atomic_inc(&mc->mca_refcnt);
+}
+
+static void ma_put(struct ifmcaddr6 *mc)
+{
+	if (atomic_dec_and_test(&mc->mca_refcnt)) {
+		in6_dev_put(mc->idev);
+		kfree(mc);
+	}
+}
+
+static struct ifmcaddr6 *mca_alloc(struct inet6_dev *idev,
+				   const struct in6_addr *addr)
+{
+	struct ifmcaddr6 *mc;
+
+	mc = kzalloc(sizeof(*mc), GFP_ATOMIC);
+	if (mc == NULL)
+		return NULL;
+
+	setup_timer(&mc->mca_timer, igmp6_timer_handler, (unsigned long)mc);
+
+	mc->mca_addr = *addr;
+	mc->idev = idev; /* reference taken by caller */
+	mc->mca_users = 1;
+	/* mca_stamp should be updated upon changes */
+	mc->mca_cstamp = mc->mca_tstamp = jiffies;
+	atomic_set(&mc->mca_refcnt, 1);
+	spin_lock_init(&mc->mca_lock);
+
+	/* initial mode is (EX, empty) */
+	mc->mca_sfmode = MCAST_EXCLUDE;
+	mc->mca_sfcount[MCAST_EXCLUDE] = 1;
+
+	if (ipv6_addr_is_ll_all_nodes(&mc->mca_addr) ||
+	    IPV6_ADDR_MC_SCOPE(&mc->mca_addr) < IPV6_ADDR_SCOPE_LINKLOCAL)
+		mc->mca_flags |= MAF_NOREPORT;
+
+	return mc;
+}
 
 /*
  *	device multicast group inc (add if not found)
@@ -849,38 +883,20 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 		}
 	}
 
-	/*
-	 *	not found: create a new one.
-	 */
-
-	mc = kzalloc(sizeof(struct ifmcaddr6), GFP_ATOMIC);
-
-	if (mc == NULL) {
+	mc = mca_alloc(idev, addr);
+	if (!mc) {
 		write_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
 		return -ENOMEM;
 	}
 
-	setup_timer(&mc->mca_timer, igmp6_timer_handler, (unsigned long)mc);
-
-	mc->mca_addr = *addr;
-	mc->idev = idev; /* (reference taken) */
-	mc->mca_users = 1;
-	/* mca_stamp should be updated upon changes */
-	mc->mca_cstamp = mc->mca_tstamp = jiffies;
-	atomic_set(&mc->mca_refcnt, 2);
-	spin_lock_init(&mc->mca_lock);
-
-	/* initial mode is (EX, empty) */
-	mc->mca_sfmode = MCAST_EXCLUDE;
-	mc->mca_sfcount[MCAST_EXCLUDE] = 1;
-
-	if (ipv6_addr_is_ll_all_nodes(&mc->mca_addr) ||
-	    IPV6_ADDR_MC_SCOPE(&mc->mca_addr) < IPV6_ADDR_SCOPE_LINKLOCAL)
-		mc->mca_flags |= MAF_NOREPORT;
-
 	mc->next = idev->mc_list;
 	idev->mc_list = mc;
+
+	/* Hold this for the code below before we unlock,
+	 * it is already exposed via idev->mc_list.
+	 */
+	mca_get(mc);
 	write_unlock_bh(&idev->lock);
 
 	mld_del_delrec(idev, &mc->mca_addr);
-- 
1.8.3.1
