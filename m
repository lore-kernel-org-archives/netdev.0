From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/13] dsa: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:57 -0700
Message-ID: <8c3464767ed2cecfdd02753824459a41b48d89b2.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41961 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751855Ab2EIE7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 00:59:35 -0400
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/dsa/slave.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 56cf9b8..e32083d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -66,7 +66,7 @@ static int dsa_slave_open(struct net_device *dev)
 	if (!(master->flags & IFF_UP))
 		return -ENETDOWN;
 
-	if (compare_ether_addr(dev->dev_addr, master->dev_addr)) {
+	if (!ether_addr_equal(dev->dev_addr, master->dev_addr)) {
 		err = dev_uc_add(master, dev->dev_addr);
 		if (err < 0)
 			goto out;
@@ -89,7 +89,7 @@ clear_allmulti:
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(master, -1);
 del_unicast:
-	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
+	if (!ether_addr_equal(dev->dev_addr, master->dev_addr))
 		dev_uc_del(master, dev->dev_addr);
 out:
 	return err;
@@ -107,7 +107,7 @@ static int dsa_slave_close(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(master, -1);
 
-	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
+	if (!ether_addr_equal(dev->dev_addr, master->dev_addr))
 		dev_uc_del(master, dev->dev_addr);
 
 	return 0;
@@ -146,13 +146,13 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 	if (!(dev->flags & IFF_UP))
 		goto out;
 
-	if (compare_ether_addr(addr->sa_data, master->dev_addr)) {
+	if (!ether_addr_equal(addr->sa_data, master->dev_addr)) {
 		err = dev_uc_add(master, addr->sa_data);
 		if (err < 0)
 			return err;
 	}
 
-	if (compare_ether_addr(dev->dev_addr, master->dev_addr))
+	if (!ether_addr_equal(dev->dev_addr, master->dev_addr))
 		dev_uc_del(master, dev->dev_addr);
 
 out:
-- 
1.7.8.111.gad25c.dirty
