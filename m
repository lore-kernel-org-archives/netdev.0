From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ipx: move peII functions
Date: Wed, 18 Jul 2012 12:09:48 -0700
Message-ID: <20120718120948.67611bdd@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51533 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755327Ab2GRTJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 15:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet II wrapper is only used by IPX protocol, may have once
been used by Appletalk but not currently. Therefore it makes sense to 
move it to the IPX dust bin and drop the exports.

Build tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ethernet/Makefile |    2 --
 net/ethernet/pe2.c    |   37 -------------------------------------
 net/ipx/Makefile      |    2 +-
 net/ipx/pe2.c         |   35 +++++++++++++++++++++++++++++++++++
 4 files changed, 36 insertions(+), 40 deletions(-)

--- a/net/ethernet/Makefile	2012-07-16 12:08:12.163683266 -0700
+++ b/net/ethernet/Makefile	2012-07-17 09:25:49.009927882 -0700
@@ -3,5 +3,3 @@
 #
 
 obj-y					+= eth.o
-obj-$(subst m,y,$(CONFIG_IPX))		+= pe2.o
-obj-$(subst m,y,$(CONFIG_ATALK))	+= pe2.o
--- a/net/ethernet/pe2.c	2012-07-16 12:08:12.163683266 -0700
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,37 +0,0 @@
-#include <linux/in.h>
-#include <linux/mm.h>
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
-
-#include <net/datalink.h>
-
-static int pEII_request(struct datalink_proto *dl,
-			struct sk_buff *skb, unsigned char *dest_node)
-{
-	struct net_device *dev = skb->dev;
-
-	skb->protocol = htons(ETH_P_IPX);
-	dev_hard_header(skb, dev, ETH_P_IPX, dest_node, NULL, skb->len);
-	return dev_queue_xmit(skb);
-}
-
-struct datalink_proto *make_EII_client(void)
-{
-	struct datalink_proto *proto = kmalloc(sizeof(*proto), GFP_ATOMIC);
-
-	if (proto) {
-		proto->header_length = 0;
-		proto->request = pEII_request;
-	}
-
-	return proto;
-}
-EXPORT_SYMBOL(make_EII_client);
-
-void destroy_EII_client(struct datalink_proto *dl)
-{
-	kfree(dl);
-}
-EXPORT_SYMBOL(destroy_EII_client);
--- a/net/ipx/Makefile	2012-07-16 12:08:12.219683209 -0700
+++ b/net/ipx/Makefile	2012-07-17 09:27:36.218231168 -0700
@@ -4,5 +4,5 @@
 
 obj-$(CONFIG_IPX) += ipx.o
 
-ipx-y			:= af_ipx.o ipx_route.o ipx_proc.o
+ipx-y			:= af_ipx.o ipx_route.o ipx_proc.o pe2.o
 ipx-$(CONFIG_SYSCTL)	+= sysctl_net_ipx.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/ipx/pe2.c	2012-07-17 09:28:21.478359247 -0700
@@ -0,0 +1,35 @@
+#include <linux/in.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+
+#include <net/datalink.h>
+
+static int pEII_request(struct datalink_proto *dl,
+			struct sk_buff *skb, unsigned char *dest_node)
+{
+	struct net_device *dev = skb->dev;
+
+	skb->protocol = htons(ETH_P_IPX);
+	dev_hard_header(skb, dev, ETH_P_IPX, dest_node, NULL, skb->len);
+	return dev_queue_xmit(skb);
+}
+
+struct datalink_proto *make_EII_client(void)
+{
+	struct datalink_proto *proto = kmalloc(sizeof(*proto), GFP_ATOMIC);
+
+	if (proto) {
+		proto->header_length = 0;
+		proto->request = pEII_request;
+	}
+
+	return proto;
+}
+
+void destroy_EII_client(struct datalink_proto *dl)
+{
+	kfree(dl);
+}
