From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/1][NETNS][IPV6] protect addrconf from loopback registration
Date: Mon, 12 Nov 2007 16:19:54 +0100
Message-ID: <20071112152403.273795630@mai.toulouse-stg.fr.ibm.com>
References: <20071112151953.052335971@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, den@sw.ru, xemul@openvz.org,
	ebiederm@xmission.com, containers@lists.osdl.org,
	yoshfuji@linux-ipv6.org, Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:28318 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbXKLP3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 10:29:51 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lACFTPWc379844
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 15:29:25 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lACFTLl01228916
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 15:29:23 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lACFSwo5005423
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 15:29:01 GMT
Content-Disposition: inline; filename=protect-addrconf-from-loopback-reg-notifications.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The loopback is now dynamically allocated. The ipv6 code was written
considering the loopback is allocated before the ipv6 protocol 
initialization. This is still the case when we don't use multiple
network namespaces.

In the case of the network namespaces, ipv6 notification handler is
already setup and active (done by the initial network namespace), 
so when a network namespace is created, a new instance of the 
loopback device, via dynamic allocation, will trigger a REGISTER event
to addrconf_notify and this one will try to setup the network device
while the ipv6 protocol is not yet initialized for the network namespace.

Because the ipv6 is relying on the fact that the loopback device will
not trigger REGISTER/UNREGISTER events, I just protect the addrconf_notify
function when the loopback register event is triggered.

In the case of multiple network namespaces, the usual ipv6 protocol 
initialization will be done after the loopback initialization with 
the subsystem registration mechanism.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/addrconf.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -2272,7 +2272,8 @@ static int addrconf_notify(struct notifi
 
 	switch(event) {
 	case NETDEV_REGISTER:
-		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
+		if (!(dev->flags & IFF_LOOPBACK) &&
+		    !idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
 			if (!idev)
 				return notifier_from_errno(-ENOMEM);
@@ -2366,11 +2367,15 @@ static int addrconf_notify(struct notifi
 		/* MTU falled under IPV6_MIN_MTU. Stop IPv6 on this interface. */
 
 	case NETDEV_DOWN:
+		addrconf_ifdown(dev, 0);
+		break;
+
 	case NETDEV_UNREGISTER:
 		/*
 		 *	Remove all addresses from this interface.
 		 */
-		addrconf_ifdown(dev, event != NETDEV_DOWN);
+		if (!(dev->flags & IFF_LOOPBACK))
+			addrconf_ifdown(dev, 1);
 		break;
 
 	case NETDEV_CHANGENAME:

-- 
