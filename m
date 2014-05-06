From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Subject: [PATCH] netdev: add support for interface name retrieval from DT aliases
Date: Tue,  6 May 2014 17:36:34 +0200
Message-ID: <1399390594-1409-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Olof Johansson <olof@lixom.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:52423 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757662AbaEFPgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:36:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently no proper way to bind a net interface to a specific
name. The interface name is chosen based on the interface type (eth,
wlan, ...) and the interfaces already registered (the core codes takes
the first unused interface id of the given type).

Add support for DT retrieval of the interface id based on DT aliases.
The alias name must match the interface type (e.g. ethX if you're defining
an ethernet dev alias).

Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>
---
 net/core/dev.c | 45 +++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 41 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d2c8a06..8f30cb8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,7 @@
 #include <linux/hashtable.h>
 #include <linux/vmalloc.h>
 #include <linux/if_macvlan.h>
+#include <linux/of.h>
 
 #include "net-sysfs.h"
 
@@ -960,13 +961,19 @@ EXPORT_SYMBOL(dev_valid_name);
  *	Returns the number of the unit assigned or a negative errno code.
  */
 
-static int __dev_alloc_name(struct net *net, const char *name, char *buf)
+static int __dev_alloc_name(struct net *net, struct net_device *dev,
+			    const char *name, char *buf)
 {
 	int i = 0;
+	int of_id = -EINVAL;
 	const char *p;
 	const int max_netdevices = 8*PAGE_SIZE;
 	unsigned long *inuse;
 	struct net_device *d;
+	struct device_node *np = NULL;
+
+	if (dev->dev.parent)
+		np = dev->dev.parent->of_node;
 
 	p = strnchr(name, IFNAMSIZ-1, '%');
 	if (p) {
@@ -978,11 +985,38 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
+		if (np) {
+			strlcpy(buf, name, (size_t)(p + 1 - name));
+			of_id = of_alias_get_id(np, buf);
+		}
+
 		/* Use one page as a bit array of possible slots */
 		inuse = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
 		if (!inuse)
 			return -ENOMEM;
 
+#ifdef CONFIG_OF
+		/* iterate over aliases to reserve interfaces names */
+		np = of_find_node_by_path("/aliases");
+		if (np) {
+			struct property *pp;
+			for_each_property_of_node(np, pp) {
+				if (!sscanf(pp->name, name, &i))
+					continue;
+				if (i < 0 || i >= max_netdevices)
+					continue;
+
+				/* avoid cases where sscanf is not exact
+				 * inverse of printf
+				 */
+				snprintf(buf, IFNAMSIZ, name, i);
+				if (!strncmp(buf, pp->name, IFNAMSIZ) &&
+				    i != of_id)
+					set_bit(i, inuse);
+			}
+		}
+#endif
+
 		for_each_netdev(net, d) {
 			if (!sscanf(d->name, name, &i))
 				continue;
@@ -995,7 +1029,10 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 				set_bit(i, inuse);
 		}
 
-		i = find_first_zero_bit(inuse, max_netdevices);
+		if (of_id >= 0 && !test_bit(of_id, inuse))
+			i = of_id;
+		else
+			i = find_first_zero_bit(inuse, max_netdevices);
 		free_page((unsigned long) inuse);
 	}
 
@@ -1033,7 +1070,7 @@ int dev_alloc_name(struct net_device *dev, const char *name)
 
 	BUG_ON(!dev_net(dev));
 	net = dev_net(dev);
-	ret = __dev_alloc_name(net, name, buf);
+	ret = __dev_alloc_name(net, dev, name, buf);
 	if (ret >= 0)
 		strlcpy(dev->name, buf, IFNAMSIZ);
 	return ret;
@@ -1047,7 +1084,7 @@ static int dev_alloc_name_ns(struct net *net,
 	char buf[IFNAMSIZ];
 	int ret;
 
-	ret = __dev_alloc_name(net, name, buf);
+	ret = __dev_alloc_name(net, dev, name, buf);
 	if (ret >= 0)
 		strlcpy(dev->name, buf, IFNAMSIZ);
 	return ret;
-- 
1.8.3.2
