From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: ipv6 addrconf hardware type restrictions
Date: Thu, 26 Apr 2007 21:24:17 +0200
Message-ID: <4630FC61.1080706@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Urs Thuermann <urs@isnogud.escape.de>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-fb.rzone.de ([81.169.146.163]:58113 "EHLO
	mo-p00-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992AbXDZT4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 15:56:04 -0400
Received: from mo-p00-ob.rzone.de (fruni-mo-p00-ob.mail [192.168.63.71])
	by charnel-fb-04.store (RZmta 5.8) with ESMTP id 40179dj3QIsm7l
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 21:25:56 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

since the invocation of ipv6_add_dev() at NETDEV_REGISTER time in 
addrconf_notify() i get an 'add_dev failed' when registering a netdevice 
with a MTU of 16.

As the code doesn't check for ipv6 capable hardware types it simply runs 
into an error for some non-ipv6 capable networking hw ...

This patch below may just be a hint - maybe you find any 'nicer' 
implementation for this.

Best regards,
Oliver

Signed-Off-By: Oliver Hartkopp <socketcan@hartkopp.net>

--- addrconf.c-orig    2007-04-26 20:40:38.000000000 +0200
+++ addrconf.c    2007-04-26 20:54:58.000000000 +0200
@@ -2076,15 +2076,6 @@
 
     ASSERT_RTNL();
 
-    if ((dev->type != ARPHRD_ETHER) &&
-        (dev->type != ARPHRD_FDDI) &&
-        (dev->type != ARPHRD_IEEE802_TR) &&
-        (dev->type != ARPHRD_ARCNET) &&
-        (dev->type != ARPHRD_INFINIBAND)) {
-        /* Alas, we support only Ethernet autoconfiguration. */
-        return;
-    }
-
     idev = addrconf_add_dev(dev);
     if (idev == NULL)
         return;
@@ -2172,6 +2163,21 @@
     ip6_tnl_add_linklocal(idev);
 }
 
+static int ipv6_hwtype(struct net_device *dev)
+{
+    if ((dev->type == ARPHRD_ETHER) ||
+        (dev->type == ARPHRD_LOOPBACK) ||
+        (dev->type == ARPHRD_SIT) ||
+        (dev->type == ARPHRD_TUNNEL6) ||
+        (dev->type == ARPHRD_FDDI) ||
+        (dev->type == ARPHRD_IEEE802_TR) ||
+        (dev->type == ARPHRD_ARCNET) ||
+        (dev->type == ARPHRD_INFINIBAND))
+        return 1;
+
+    return 0;
+}
+
 static int addrconf_notify(struct notifier_block *this, unsigned long 
event,
                void * data)
 {
@@ -2179,6 +2185,9 @@
     struct inet6_dev *idev = __in6_dev_get(dev);
     int run_pending = 0;
 
+    if (!ipv6_hwtype(dev))
+        return NOTIFY_OK;
+
     switch(event) {
     case NETDEV_REGISTER:
         if (!idev) {


