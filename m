From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Resend: [FIX][PATCH] ipv6 addrconf.c : wrong handling of non-ipv6
 hardware since 2.6.21
Date: Thu, 17 May 2007 19:09:06 +0200
Message-ID: <464C8C32.3050301@hartkopp.net>
References: <464C886F.50703@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:16836 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649AbXEQRJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 13:09:26 -0400
In-Reply-To: <464C886F.50703@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry. I had a problem with my mailer that disrupted the patch ...

--------------------------

Hello Hideaki, hello David,

since 2.6.21 the new case NETDEV_REGISTER has been added to the big 
'switch' in addrconf_notify().

But within this "case NETDEV_REGISTER"-code no check about valid ipv6 
networking hardware is done, as it is done in NETDEV_UP, NETDEV_CHANGE 
and others.

Please apply the following patch to handle only valid ipv6 networking 
hardware inside the addrconf-notifier. This omits the invocation of 
ipv6_add_dev(dev) for non ipv6 capable hardware (e.g. with MTUs < 
IPV6_MIN_MTU) which leads to an ugly "IPv6: add_dev failed for %s\n" 
kernel warning.

The patch applies since 2.6.21 and also to the latest 2.6.22-rc1-git5 
(with an offset of 78 lines).

Best regards,
Oliver

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---
--- linux-2.6.21/net/ipv6/addrconf.c.orig    2007-05-16 
01:43:30.000000000 +0200
+++ linux-2.6.21/net/ipv6/addrconf.c    2007-05-16 02:01:18.000000000 +0200
@@ -2076,15 +2076,6 @@ static void addrconf_dev_config(struct n

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
@@ -2172,13 +2163,35 @@ static void addrconf_ip6_tnl_config(stru
    ip6_tnl_add_linklocal(idev);
}

+static int ipv6_hwtype(struct net_device *dev)
+{
+    if ((dev->type == ARPHRD_ETHER) ||
+        (dev->type == ARPHRD_LOOPBACK) ||
+#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+        (dev->type == ARPHRD_SIT) ||
+#endif
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
    struct net_device *dev = (struct net_device *) data;
-    struct inet6_dev *idev = __in6_dev_get(dev);
+    struct inet6_dev *idev;
    int run_pending = 0;

+    if (!ipv6_hwtype(dev))
+        return NOTIFY_OK;
+
+    idev = __in6_dev_get(dev);
+
    switch(event) {
    case NETDEV_REGISTER:
        if (!idev) {


