From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] net: ipmr, ip6mr: fix vif/tunnel failure race condition
Date: Tue, 24 Nov 2015 17:09:30 +0100
Message-ID: <1448381370-32173-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38433 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbKXQJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 11:09:35 -0500
Received: by wmec201 with SMTP id c201so33517038wme.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 08:09:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Since (at least) commit b17a7c179dd3 ("[NET]: Do sysfs registration as
part of register_netdevice."), netdev_run_todo() deals only with
unregistration, so we don't need to do the rtnl_unlock/lock cycle to
finish registration when failing pimreg or dvmrp device creation. In
fact that opens a race condition where someone can delete the device
while rtnl is unlocked because it's fully registered. The problem gets
worse when netlink support is introduced as there are more points of entry
that can cause it and it also makes reusing that code correctly impossible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
I was able to crash the kernel by artificially triggering this race just to
confim it. I know it's very unlikely to hit the race in the real world, but
the biggest advantage of the change is that the code can be re-used later
when adding netlink support.

 net/ipv4/ipmr.c  | 8 --------
 net/ipv6/ip6mr.c | 4 ----
 2 files changed, 12 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 292123bc30fa..c3a38353f5dc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -441,10 +441,6 @@ struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 	return dev;
 
 failure:
-	/* allow the register to be completed before unregistering. */
-	rtnl_unlock();
-	rtnl_lock();
-
 	unregister_netdevice(dev);
 	return NULL;
 }
@@ -540,10 +536,6 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 	return dev;
 
 failure:
-	/* allow the register to be completed before unregistering. */
-	rtnl_unlock();
-	rtnl_lock();
-
 	unregister_netdevice(dev);
 	return NULL;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7a4a1b81dbb6..a10e77103c88 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -765,10 +765,6 @@ static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
 	return dev;
 
 failure:
-	/* allow the register to be completed before unregistering. */
-	rtnl_unlock();
-	rtnl_lock();
-
 	unregister_netdevice(dev);
 	return NULL;
 }
-- 
2.4.3
