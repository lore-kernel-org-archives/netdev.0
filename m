From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Tue, 28 Sep 2010 17:24:57 +0200
Message-ID: <4CA208C9.1020800@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020908010704060102060904"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52326 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab0I1PZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 11:25:05 -0400
Received: by wyb28 with SMTP id 28so5069437wyb.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 08:25:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020908010704060102060904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I face a problem when I try to remove an interface, 
netdev_wait_allrefs() complains about refcount.

Here is a trivial scenario to reproduce the problem:
# ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev eth0
# ./a.out tunl1
# ip tunnel del tunl1

Note: a.out binary create an IPv4 raw socket, attach it to tunl1 
(SO_BINDTODEVICE), set it as multicast (IP_MULTICAST_LOOP), set the 
multicast interface to tunl1 (IP_MULTICAST_IF), build the IP header 
(IP_HDRINCL) and then send a single packet (192.168.6.1 -> 224.0.0.18).

Note2: when a.out is executed, tunl1 has no ip address and is down.

Then, I got a serie of "kernel:[1206699.728010] unregister_netdevice: 
waiting for tunl1 to become free. Usage count = 3" and after some time, 
interface is removed.

The problem is that route cache entries are only invalidate on 
UNREGISTER event, and not removed (introduced by commit 
e2ce146848c81af2f6d42e67990191c284bf0c33). We must wait that 
rt_check_expire() remove the remaining route cache entries.

To fix the problem, I propose to remove a part of the previous commit.

Regards,
Nicolas

--------------020908010704060102060904
Content-Type: text/x-diff;
 name="0001-ipv4-remove-all-rt-cache-entries-on-UNREGISTER-even.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-ipv4-remove-all-rt-cache-entries-on-UNREGISTER-even.pat";
 filename*1="ch"

>From 3344e2e0431fe803c4dac8757a8746908357d780 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 28 Sep 2010 16:38:19 +0200
Subject: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event

Commit e2ce146848c81af2f6d42e67990191c284bf0c33 (ipv4: factorize cache clearing
for batched unregister operations) add a new parameter to fib_disable_ip() to
only invalidate route cache entries on unregister event.
This is wrong, we should ensure that all cache entries are removed on
unregister event, else netdev_wait_allrefs() may complain. A cache entry
can be created between event DOWN and UNREGISTER.

So, I revert a part of the patch.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/fib_frontend.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7d02a9f..377e815 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -917,11 +917,11 @@ static void nl_fib_lookup_exit(struct net *net)
 	net->ipv4.fibnl = NULL;
 }
 
-static void fib_disable_ip(struct net_device *dev, int force, int delay)
+static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down_dev(dev, force))
 		fib_flush(dev_net(dev));
-	rt_cache_flush(dev_net(dev), delay);
+	rt_cache_flush(dev_net(dev), 0);
 	arp_ifdown(dev);
 }
 
@@ -944,7 +944,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 			/* Last address was deleted from this interface.
 			   Disable IP.
 			 */
-			fib_disable_ip(dev, 1, 0);
+			fib_disable_ip(dev, 1);
 		} else {
 			rt_cache_flush(dev_net(dev), -1);
 		}
@@ -959,7 +959,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
 	if (event == NETDEV_UNREGISTER) {
-		fib_disable_ip(dev, 2, -1);
+		fib_disable_ip(dev, 2);
 		return NOTIFY_DONE;
 	}
 
@@ -977,7 +977,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		rt_cache_flush(dev_net(dev), -1);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, 0, 0);
+		fib_disable_ip(dev, 0);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:
-- 
1.5.6.5


--------------020908010704060102060904--
