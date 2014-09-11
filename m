From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 4/8] ipv6: refactor __ipv6_dev_ac_inc()
Date: Thu, 11 Sep 2014 15:35:12 -0700
Message-ID: <1410474916-21873-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:58449 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaIKWfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:43 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so8901134pab.22
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:42 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor out allocation and initialization and make
the refcount code more readable.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/anycast.c | 62 ++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 39 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 66c1932..952c1fd 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -203,6 +203,11 @@ void ipv6_sock_ac_close(struct sock *sk)
 	rtnl_unlock();
 }
 
+static void aca_get(struct ifacaddr6 *aca)
+{
+	atomic_inc(&aca->aca_refcnt);
+}
+
 static void aca_put(struct ifacaddr6 *ac)
 {
 	if (atomic_dec_and_test(&ac->aca_refcnt)) {
@@ -212,6 +217,29 @@ static void aca_put(struct ifacaddr6 *ac)
 	}
 }
 
+static struct ifacaddr6 *aca_alloc(struct rt6_info *rt,
+				   const struct in6_addr *addr)
+{
+	struct inet6_dev *idev = rt->rt6i_idev;
+	struct ifacaddr6 *aca;
+
+	aca = kzalloc(sizeof(*aca), GFP_ATOMIC);
+	if (aca == NULL)
+		return NULL;
+
+	aca->aca_addr = *addr;
+	in6_dev_hold(idev);
+	aca->aca_idev = idev;
+	aca->aca_rt = rt;
+	aca->aca_users = 1;
+	/* aca_tstamp should be updated upon changes */
+	aca->aca_cstamp = aca->aca_tstamp = jiffies;
+	atomic_set(&aca->aca_refcnt, 1);
+	spin_lock_init(&aca->aca_lock);
+
+	return aca;
+}
+
 /*
  *	device anycast group inc (add if not found)
  */
@@ -223,7 +251,6 @@ int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr)
 
 	ASSERT_RTNL();
 
-	in6_dev_hold(idev);
 	write_lock_bh(&idev->lock);
 	if (idev->dead) {
 		err = -ENODEV;
@@ -238,35 +265,25 @@ int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr)
 		}
 	}
 
-	/*
-	 *	not found: create a new one.
-	 */
-
-	aca = kzalloc(sizeof(struct ifacaddr6), GFP_ATOMIC);
-
-	if (aca == NULL) {
-		err = -ENOMEM;
-		goto out;
-	}
-
 	rt = addrconf_dst_alloc(idev, addr, true);
 	if (IS_ERR(rt)) {
-		kfree(aca);
 		err = PTR_ERR(rt);
 		goto out;
 	}
-
-	aca->aca_addr = *addr;
-	aca->aca_idev = idev;
-	aca->aca_rt = rt;
-	aca->aca_users = 1;
-	/* aca_tstamp should be updated upon changes */
-	aca->aca_cstamp = aca->aca_tstamp = jiffies;
-	atomic_set(&aca->aca_refcnt, 2);
-	spin_lock_init(&aca->aca_lock);
+	aca = aca_alloc(rt, addr);
+	if (aca == NULL) {
+		ip6_rt_put(rt);
+		err = -ENOMEM;
+		goto out;
+	}
 
 	aca->aca_next = idev->ac_list;
 	idev->ac_list = aca;
+
+	/* Hold this for addrconf_join_solict() below before we unlock,
+	 * it is already exposed via idev->ac_list.
+	 */
+	aca_get(aca);
 	write_unlock_bh(&idev->lock);
 
 	ip6_ins_rt(rt);
@@ -277,7 +294,6 @@ int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr)
 	return 0;
 out:
 	write_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
 	return err;
 }
 
-- 
1.8.3.1
