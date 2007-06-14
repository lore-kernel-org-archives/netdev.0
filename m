From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Thu, 14 Jun 2007 18:16:07 +1000
Message-ID: <20070614081607.GA22931@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kanru Chen <koster@debian.org.tw>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs@isnogud.escape.de>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1156 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751084AbXFNIRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 04:17:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[IPV6] addrconf: Fix IPv6 on tuntap tunnels

The recent patch that added ipv6_hwtype is broken on tuntap tunnels.
Indeed, it's broken on any device that does not pass the ipv6_hwtype
test.

The reason is that the original test only applies to autoconfiguration,
not IPv6 support.  IPv6 support is allowed on any device.  In fact,
even with the ipv6_hwtype patch applied you can still add IPv6 addresses
to any interface that doesn't pass thw ipv6_hwtype test provided that
they have a sufficiently large MTU.  This is a serious problem because
come deregistration time these devices won't be cleaned up properly.

I've gone back and looked at the rationale for the patch.  It appears
that the real problem is that we were creating IPv6 devices even if the
MTU was too small.  So here's a patch which fixes that and reverts the
ipv6_hwtype stuff.

Thanks to Kanru Chen for reporting this issue.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5a5f8bd..f96ed76 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2154,6 +2154,15 @@ static void addrconf_dev_config(struct net_device *dev)
 
 	ASSERT_RTNL();
 
+	if ((dev->type != ARPHRD_ETHER) &&
+	    (dev->type != ARPHRD_FDDI) &&
+	    (dev->type != ARPHRD_IEEE802_TR) &&
+	    (dev->type != ARPHRD_ARCNET) &&
+	    (dev->type != ARPHRD_INFINIBAND)) {
+		/* Alas, we support only Ethernet autoconfiguration. */
+		return;
+	}
+
 	idev = addrconf_add_dev(dev);
 	if (idev == NULL)
 		return;
@@ -2241,36 +2250,16 @@ static void addrconf_ip6_tnl_config(struct net_device *dev)
 	ip6_tnl_add_linklocal(idev);
 }
 
-static int ipv6_hwtype(struct net_device *dev)
-{
-	if ((dev->type == ARPHRD_ETHER) ||
-	    (dev->type == ARPHRD_LOOPBACK) ||
-	    (dev->type == ARPHRD_SIT) ||
-	    (dev->type == ARPHRD_TUNNEL6) ||
-	    (dev->type == ARPHRD_FDDI) ||
-	    (dev->type == ARPHRD_IEEE802_TR) ||
-	    (dev->type == ARPHRD_ARCNET) ||
-	    (dev->type == ARPHRD_INFINIBAND))
-		return 1;
-
-	return 0;
-}
-
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void * data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct inet6_dev *idev;
+	struct inet6_dev *idev = __in6_dev_get(dev);
 	int run_pending = 0;
 
-	if (!ipv6_hwtype(dev))
-		return NOTIFY_OK;
-
-	idev = __in6_dev_get(dev);
-
 	switch(event) {
 	case NETDEV_REGISTER:
-		if (!idev) {
+		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
 			if (!idev)
 				printk(KERN_WARNING "IPv6: add_dev failed for %s\n",
