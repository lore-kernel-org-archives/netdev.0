From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [FIX][PATCH] ipv6 addrconf.c REMOVED #if patch
Date: 21 May 2007 20:20:51 +0200
Message-ID: <ygf8xbivy0s.fsf@janus.isnogud.escape.de>
References: <464C886F.50703@hartkopp.net>
	<20070518.024940.120305926.yoshfuji@linux-ipv6.org>
	<464CC4B8.6040401@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:49203 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756400AbXEUSaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 14:30:21 -0400
In-Reply-To: <464CC4B8.6040401@hartkopp.net>; from Oliver Hartkopp on Thu, 17 May 2007 23:10:16 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp <socketcan@hartkopp.net> writes:

> Yep - you were right. It looks better like this as ARPHRD_SIT is
> defined in if_arp.h in any CONFIG_* case ...

Oliver asked me to resend the patch with a sane mailer that doesn't
mangle white-space and line breaks.  So here it is.

This patch makes the netdevice notifier for IPv6 ignore all events on
non-IPv6 capable devices.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

urs



--- /usr/src/linux-2.6.21/net/ipv6/addrconf.c.orig	2007-05-21 19:47:36.000000000 +0200
+++ /usr/src/linux-2.6.21/net/ipv6/addrconf.c	2007-05-21 19:54:30.000000000 +0200
@@ -2076,15 +2076,6 @@
 
 	ASSERT_RTNL();
 
-	if ((dev->type != ARPHRD_ETHER) &&
-	    (dev->type != ARPHRD_FDDI) &&
-	    (dev->type != ARPHRD_IEEE802_TR) &&
-	    (dev->type != ARPHRD_ARCNET) &&
-	    (dev->type != ARPHRD_INFINIBAND)) {
-		/* Alas, we support only Ethernet autoconfiguration. */
-		return;
-	}
-
 	idev = addrconf_add_dev(dev);
 	if (idev == NULL)
 		return;
@@ -2172,13 +2163,33 @@
 	ip6_tnl_add_linklocal(idev);
 }
 
+static int ipv6_hwtype(struct net_device *dev)
+{
+	if ((dev->type == ARPHRD_ETHER) ||
+	    (dev->type == ARPHRD_LOOPBACK) ||
+	    (dev->type == ARPHRD_SIT) ||
+	    (dev->type == ARPHRD_TUNNEL6) ||
+	    (dev->type == ARPHRD_FDDI) ||
+	    (dev->type == ARPHRD_IEEE802_TR) ||
+	    (dev->type == ARPHRD_ARCNET) ||
+	    (dev->type == ARPHRD_INFINIBAND))
+		return 1;
+
+	return 0;
+}
+
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void * data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct inet6_dev *idev = __in6_dev_get(dev);
+	struct inet6_dev *idev;
 	int run_pending = 0;
 
+	if (!ipv6_hwtype(dev))
+		return NOTIFY_OK;
+
+	idev = __in6_dev_get(dev);
+
 	switch(event) {
 	case NETDEV_REGISTER:
 		if (!idev) {
