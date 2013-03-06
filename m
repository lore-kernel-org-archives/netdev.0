From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net: introduce NAPI_POLL_WEIGHT
Date: Tue, 05 Mar 2013 17:57:22 -0800
Message-ID: <1362535042.15793.144.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:61972 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab3CFB51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 20:57:27 -0500
Received: by mail-ie0-f172.google.com with SMTP id c10so8688063ieb.17
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 17:57:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some drivers use a too big NAPI poll weight.

This patch adds a NAPI_POLL_WEIGHT default value
and issues an error message if a driver attempts
to use a bigger weight.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 include/linux/netdevice.h |    5 +++++
 net/core/dev.c            |    3 +++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b3d00fa..896eb49 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1475,6 +1475,11 @@ static inline void *netdev_priv(const struct net_device *dev)
  */
 #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
 
+/* Default NAPI poll() weight
+ * Device drivers are strongly advised to not use bigger value
+ */
+#define NAPI_POLL_WEIGHT 64
+
 /**
  *	netif_napi_add - initialize a napi context
  *	@dev:  network device
diff --git a/net/core/dev.c b/net/core/dev.c
index a06a7a5..9610389 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4057,6 +4057,9 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 	napi->gro_list = NULL;
 	napi->skb = NULL;
 	napi->poll = poll;
+	if (weight > NAPI_POLL_WEIGHT)
+		pr_err_once("netif_napi_add() called with weight %d on device %s\n",
+			    weight, dev->name);
 	napi->weight = weight;
 	list_add(&napi->dev_list, &dev->napi_list);
 	napi->dev = dev;
