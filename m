From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 1/7] dev: Add netif_get_l3_dev() helper
Date: Wed,  9 Mar 2016 13:49:55 -0800
Message-ID: <1457560195-12938-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33552 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbcCIVt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:49:59 -0500
Received: by mail-pf0-f196.google.com with SMTP id 129so1837939pfw.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:49:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

This patch adds a l3_dev to net_device struct and a helper
function to retrieve it. During L3 ingress packet processing,
this device will be used and should serve the current purpose
of skb->dev. Since l3_dev is initialized to self; l3_dev should
be pointing to skb->dev so the normal packet processing is
neither altered nor should incur any additional cost (as it
resides in the RX cache line).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 include/linux/netdevice.h | 6 ++++++
 net/core/dev.c            | 1 +
 2 files changed, 7 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e52077ffe5ed..1cf7e8d61043 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1738,6 +1738,7 @@ struct net_device {
 	unsigned long		gro_flush_timeout;
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
+	struct net_device	*l3_dev;
 
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *ingress_cl_list;
@@ -4085,6 +4086,11 @@ static inline void netif_keep_dst(struct net_device *dev)
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM);
 }
 
+static inline struct net_device *netif_get_l3_dev(struct net_device *dev)
+{
+	return dev->l3_dev;
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/net/core/dev.c b/net/core/dev.c
index edb7179bc051..c4023a68cdc1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7463,6 +7463,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
 
+	dev->l3_dev = dev;
 	nf_hook_ingress_init(dev);
 
 	return dev;
-- 
2.7.0.rc3.207.g0ac5344
