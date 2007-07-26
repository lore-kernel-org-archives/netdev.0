From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/6] [IPV4/IPV6]: Fail registration if inet device construction fails
Date: Thu, 26 Jul 2007 17:09:38 +0800
Message-ID: <E1IDzLm-0000AP-00@gondolin.me.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1322 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756880AbXGZJJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:09:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4/IPV6]: Fail registration if inet device construction fails

Now that netdev notifications can fail, we can use this to signal
errors during registration for IPv4/IPv6.  In particular, if we
fail to allocate memory for the inet device, we can fail the netdev
registration.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/devinet.c  |    5 ++---
 net/ipv6/addrconf.c |    8 +++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index abf6352..5b77bda 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1056,10 +1056,9 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	if (!in_dev) {
 		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
+			if (!in_dev)
+				return notifier_from_errno(-ENOMEM);
 			if (dev == &loopback_dev) {
-				if (!in_dev)
-					panic("devinet: "
-					      "Failed to create loopback\n");
 				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
 				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
 			}
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0601292..91ef3be 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2256,14 +2256,14 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = (struct net_device *) data;
 	struct inet6_dev *idev = __in6_dev_get(dev);
 	int run_pending = 0;
+	int err;
 
 	switch(event) {
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
 			if (!idev)
-				printk(KERN_WARNING "IPv6: add_dev failed for %s\n",
-					dev->name);
+				return notifier_from_errno(-ENOMEM);
 		}
 		break;
 	case NETDEV_UP:
@@ -2373,7 +2373,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 					      NULL);
 			addrconf_sysctl_register(idev, &idev->cnf);
 #endif
-			snmp6_register_dev(idev);
+			err = snmp6_register_dev(idev);
+			if (err)
+				return notifier_from_errno(err);
 		}
 		break;
 	}
