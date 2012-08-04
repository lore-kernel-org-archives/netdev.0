From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: Introduce IN_DEV_NET_ROUTE_LOCALNET
Date: Sat, 04 Aug 2012 09:27:25 +0200
Message-ID: <1344065245.9299.1477.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59260 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab2HDH1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 03:27:30 -0400
Received: by wgbdr13 with SMTP id dr13so1283044wgb.1
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 00:27:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

performance profiles show a high cost in the IN_DEV_ROUTE_LOCALNET()
call done in ip_route_input_slow(), because of multiple dereferences,
even if cache lines are clean and available in cpu caches.

Since we already have the 'net' pointer, introduce
IN_DEV_NET_ROUTE_LOCALNET() macro avoiding two dereferences
(dev_net(in_dev->dev))

Also change the tests to use IN_DEV_NET_ROUTE_LOCALNET() only if saddr
or/and daddr are loopback addresse.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/inetdevice.h |   11 +++++++++--
 net/ipv4/route.c           |   11 +++++++----
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 67f9dda..d032780 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -104,9 +104,14 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ANDCONF(in_dev, attr) \
 	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) && \
 	 IN_DEV_CONF_GET((in_dev), attr))
-#define IN_DEV_ORCONF(in_dev, attr) \
-	(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr) || \
+
+#define IN_DEV_NET_ORCONF(in_dev, net, attr) \
+	(IPV4_DEVCONF_ALL(net, attr) || \
 	 IN_DEV_CONF_GET((in_dev), attr))
+
+#define IN_DEV_ORCONF(in_dev, attr) \
+	IN_DEV_NET_ORCONF(in_dev, dev_net(in_dev->dev), attr)
+
 #define IN_DEV_MAXCONF(in_dev, attr) \
 	(max(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr), \
 	     IN_DEV_CONF_GET((in_dev), attr)))
@@ -133,6 +138,8 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 					IN_DEV_ORCONF((in_dev), \
 						      PROMOTE_SECONDARIES)
 #define IN_DEV_ROUTE_LOCALNET(in_dev)	IN_DEV_ORCONF(in_dev, ROUTE_LOCALNET)
+#define IN_DEV_NET_ROUTE_LOCALNET(in_dev, net)	\
+	IN_DEV_NET_ORCONF(in_dev, net, ROUTE_LOCALNET)
 
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..21ad369 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1587,11 +1587,14 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_zeronet(daddr))
 		goto martian_destination;
 
-	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev))) {
-		if (ipv4_is_loopback(daddr))
+	/* Following code try to avoid calling IN_DEV_NET_ROUTE_LOCALNET(),
+	 * and call it once if daddr or/and saddr are loopback addresses
+	 */
+	if (ipv4_is_loopback(daddr)) {
+		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
 			goto martian_destination;
-
-		if (ipv4_is_loopback(saddr))
+	} else if (ipv4_is_loopback(saddr)) {
+		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
 			goto martian_source;
 	}
 
