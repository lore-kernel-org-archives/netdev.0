From: akpm@linux-foundation.org
Subject: [patch 2/3] arch/um/drivers: remove duplicate structure field initialization
Date: Tue, 20 Jul 2010 15:25:17 -0700
Message-ID: <201007202225.o6KMPHA3021446@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37016 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932818Ab0GTWZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 18:25:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

There are two initializations of ndo_set_mac_address, one to a local
function that is not used otherwise and one to a function that is defined
elsewhere.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier I, s, fld;
position p0,p;
expression E;
@@

struct I s =@p0 { ... .fld@p = E, ...};

@s@
identifier I, s, r.fld;
position r.p0,p;
expression E;
@@

struct I s =@p0 { ... .fld@p = E, ...};

@script:python@
p0 << r.p0;
fld << r.fld;
ps << s.p;
pr << r.p;
@@

if int(ps[0].line)<int(pr[0].line) or int(ps[0].column)<int(pr[0].column):
  cocci.print_main(fld,p0)
// </smpl>

akpm:

- Use the standard eth_mac_addr() in uml_net_set_mac()

- Remove unneeded and racy local set_ether_mac()

- Remove duplicated (and incorrect)
  uml_netdev_ops.ndo_set_mac_address initializer.

Fixes 8bb95b39a16ed55226810596f92216c53329d2fe ("uml: convert network
device to netdevice ops").

[akpm@linux-foundation.org: rework as above]
Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/um/drivers/net_kern.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff -puN arch/um/drivers/net_kern.c~arch-um-drivers-remove-duplicate-structure-field-initialization arch/um/drivers/net_kern.c
--- a/arch/um/drivers/net_kern.c~arch-um-drivers-remove-duplicate-structure-field-initialization
+++ a/arch/um/drivers/net_kern.c
@@ -25,11 +25,6 @@
 #include "net_kern.h"
 #include "net_user.h"
 
-static inline void set_ether_mac(struct net_device *dev, unsigned char *addr)
-{
-	memcpy(dev->dev_addr, addr, ETH_ALEN);
-}
-
 #define DRIVER_NAME "uml-netdev"
 
 static DEFINE_SPINLOCK(opened_lock);
@@ -266,7 +261,7 @@ static int uml_net_set_mac(struct net_de
 	struct sockaddr *hwaddr = addr;
 
 	spin_lock_irq(&lp->lock);
-	set_ether_mac(dev, hwaddr->sa_data);
+	eth_mac_addr(dev, hwaddr->sa_data);
 	spin_unlock_irq(&lp->lock);
 
 	return 0;
@@ -380,7 +375,6 @@ static const struct net_device_ops uml_n
 	.ndo_tx_timeout 	= uml_net_tx_timeout,
 	.ndo_set_mac_address	= uml_net_set_mac,
 	.ndo_change_mtu 	= uml_net_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -478,7 +472,7 @@ static void eth_configure(int n, void *i
 	    ((*transport->user->init)(&lp->user, dev) != 0))
 		goto out_unregister;
 
-	set_ether_mac(dev, device->mac);
+	eth_mac_addr(dev, device->mac);
 	dev->mtu = transport->user->mtu;
 	dev->netdev_ops = &uml_netdev_ops;
 	dev->ethtool_ops = &uml_net_ethtool_ops;
_
