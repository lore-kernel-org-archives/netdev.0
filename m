From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH] ipv4: release dev refcnt early when destroying inetdev
Date: Fri, 10 Sep 2010 15:35:44 +0200
Message-ID: <4C8A3430.2070105@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040000060609050909080901"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39912 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab0IJNft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 09:35:49 -0400
Received: by eyb6 with SMTP id 6so1655277eyb.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 06:35:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040000060609050909080901
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

We got a scalability problem when we try to remove a lot of virtual interfaces. 
After analysis, we found that a refcnt on a device was released too late.
Here is a proposal patch. If we are not missing something, the refcnt can be 
release before call_rcu(). In IPv6, this is already the case.

Comments are welcome.


Regards,
Nicolas

--------------040000060609050909080901
Content-Type: text/x-diff;
 name="0001-ipv4-release-dev-refcnt-early-when-destroying-inetd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-ipv4-release-dev-refcnt-early-when-destroying-inetd.pat";
 filename*1="ch"

>From 6fe291ff56b1f94599dfaa57dfb0ed4c168b603f Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 10 Sep 2010 14:52:15 +0200
Subject: [PATCH] ipv4: release dev refcnt early when destroying inetdev

When a virtual device is removed, refcnt on dev is released
after rcu barrier, hence we fall always in the msleep(250)
of netdev_wait_allrefs(). This causes a long delay when
a lot of interfaces are removed.
Refcnt can be released before this rcu barrier, this allows
to accelerate the removing of virtual interfaces.

Test of removing 50 ipip tunnel interfaces:
 Before the patch:
  real    0m12.804s
  user    0m0.020s
  sys     0m0.000s

 After the patch:
  real    0m0.988s
  user    0m0.004s
  sys     0m0.016s

Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index da14c49..dd59e79 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -131,7 +131,9 @@ static inline void inet_free_ifa(struct in_ifaddr *ifa)
 
 void in_dev_finish_destroy(struct in_device *idev)
 {
+#ifdef NET_REFCNT_DEBUG
 	struct net_device *dev = idev->dev;
+#endif
 
 	WARN_ON(idev->ifa_list);
 	WARN_ON(idev->mc_list);
@@ -139,7 +141,6 @@ void in_dev_finish_destroy(struct in_device *idev)
 	printk(KERN_DEBUG "in_dev_finish_destroy: %p=%s\n",
 	       idev, dev ? dev->name : "NIL");
 #endif
-	dev_put(dev);
 	if (!idev->dead)
 		pr_err("Freeing alive in_device %p\n", idev);
 	else
@@ -215,6 +216,7 @@ static void inetdev_destroy(struct in_device *in_dev)
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
 	arp_ifdown(dev);
 
+	dev_put(dev);
 	call_rcu(&in_dev->rcu_head, in_dev_rcu_put);
 }
 
-- 
1.5.4.5


--------------040000060609050909080901--
