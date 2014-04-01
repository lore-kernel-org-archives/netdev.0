From: zhuyj <zyjzyj2000@gmail.com>
Subject: ipv6:remove ipv6 global address after the interface is down
Date: Tue, 01 Apr 2014 17:30:31 +0800
Message-ID: <533A8737.8050108@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070107000106050307040707"
Cc: zhuyj <zyjzyj2000@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070107000106050307040707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi, Paul

With kernel 2.6.34.x, the following problem will appear.

  TargetA ------------------------- TargetB
3000::1/64 3000::2/64

  TargetA
    - bring the interface down by doing an "ifconfig eth1 down"
    - bring the interface back up by doing an "ifconfig eth1 up"

TargetB
    - ping6 3000::1
       ping6 succeeds the first time
    - after bringing the interface on TargetA down and then back up, 
ping6 to the interface fails.

With the latest mainline kernel(3.4+), this problem is resolved. When 
eth1 is down, ipv6 address and route item are removed.
But with kernel 2.6.34.x, when eth1 is down, ipv6 address remains while 
route item is removed.

So when eth1 is up and assign the previous ipv6 address, with 2.6.34.x, 
some errors will appear. But with latest mainline kernel, it can work well.

So I made a patch to fix this problem in kernel 2.6.34.x. Please merge 
this to kernel2.6.34.x.

Thanks a lot.
Zhu Yanjun

--------------070107000106050307040707
Content-Type: text/x-patch;
 name="0001-ipv6-remove-ipv6-global-address-after-the-interface.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ipv6-remove-ipv6-global-address-after-the-interface.pat";
 filename*1="ch"

>From 4eb7dd9180bcbd7b8196f9e5e6f5db638de799e7 Mon Sep 17 00:00:00 2001
From: yanjun.zhu <yanjun.zhu@windriver.com>
Date: Tue, 1 Apr 2014 17:09:11 +0800
Subject: [PATCH 1/1] ipv6:remove ipv6 global address after the interface is down

2.6.34.x kernels require a similar logic change as commit 73a8bd74
[ipv6:Revert 'administrative down' address handling changes]
introduces for newer kernels.

In 2.6.34.x kernels, when an interface with ipv6 global address is
restarted, the ipv6 route item disappear, but ipv6 global address
still remains. Compared with kernel versions 3.4+, the ipv6 global
address and route item should both disappear. To be consistent with
kernel versions 3.4+, we remove ipv6 address from the interface that
is shutdown.

Signed-off-by: yanjun.zhu <yanjun.zhu@windriver.com>
---
 net/ipv6/addrconf.c |   39 ++++-----------------------------------
 1 files changed, 4 insertions(+), 35 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2b82070..6fd29fb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2624,7 +2624,7 @@ static void addrconf_bonding_change(struct net_device *dev, unsigned long event)
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa, *keep_list, **bifa;
+	struct inet6_ifaddr *ifa, **bifa;
 	struct net *net = dev_net(dev);
 	int i;
 
@@ -2657,9 +2657,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 		write_lock_bh(&addrconf_hash_lock);
 		while ((ifa = *bifa) != NULL) {
-			if (ifa->idev == idev &&
-			    (how || !(ifa->flags&IFA_F_PERMANENT) ||
-			     ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
+			if (ifa->idev == idev){
 				*bifa = ifa->lst_next;
 				ifa->lst_next = NULL;
 				__in6_ifa_put(ifa);
@@ -2698,40 +2696,12 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	keep_list = NULL;
-	bifa = &keep_list;
 	while ((ifa = idev->addr_list) != NULL) {
 		idev->addr_list = ifa->if_next;
 		ifa->if_next = NULL;
 
 		addrconf_del_timer(ifa);
-
-		/* If just doing link down, and address is permanent
-		   and not link-local, then retain it. */
-		if (how == 0 &&
-		    (ifa->flags&IFA_F_PERMANENT) &&
-		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
-
-			/* Move to holding list */
-			*bifa = ifa;
-			bifa = &ifa->if_next;
-
-			/* If not doing DAD on this address, just keep it. */
-			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
-			    idev->cnf.accept_dad <= 0 ||
-			    (ifa->flags & IFA_F_NODAD))
-				continue;
-
-			/* If it was tentative already, no need to notify */
-			if (ifa->flags & IFA_F_TENTATIVE)
-				continue;
-
-			/* Flag it for later restoration when link comes up */
-			ifa->flags |= IFA_F_TENTATIVE;
-			in6_ifa_hold(ifa);
-		} else {
-			ifa->dead = 1;
-		}
+		ifa->dead = 1;
 		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
@@ -2743,8 +2713,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_lock_bh(&idev->lock);
 	}
 
-	idev->addr_list = keep_list;
-
+	idev->addr_list = NULL;
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
-- 
1.7.3.5


--------------070107000106050307040707--
