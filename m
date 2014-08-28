From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 07/13] net: dsa: allow switches to work without tagging
Date: Wed, 27 Aug 2014 17:04:52 -0700
Message-ID: <1409184298-1793-8-git-send-email-f.fainelli@gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:44612 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965629AbaH1AGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 20:06:10 -0400
Received: by mail-pa0-f53.google.com with SMTP id fa1so113589pad.12
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 17:06:09 -0700 (PDT)
In-Reply-To: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case switch port tagging is disabled (voluntarily, or the switch just
does not support it), allow us to continue using the defined set of
dsa_device_ops in net/dsa/slave.c.

We introduce dsa_protocol_is_tagged() to check whether we need to
override skb->protocol and go through the DSA-specifif packet_type
function, or if we just go on and receive the SKB through the normal
path.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
No changes in v5

Changes in v4:
- reworked logic to use dsa_device_ops introduced in patch 1
- added a helper to check for the switch protocol tag

Changes in v3:
- update logic with the helpers introduced in the firs patch set
- renamed dummy to notag

 include/linux/netdevice.h |  6 +++---
 include/net/dsa.h         |  5 +++++
 net/dsa/slave.c           | 19 ++++++++++++++++++-
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1875dc71422a..429801370d0c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1784,10 +1784,10 @@ void dev_net_set(struct net_device *dev, struct net *net)
 static inline bool netdev_uses_dsa(struct net_device *dev)
 {
 #ifdef CONFIG_NET_DSA
-	return dev->dsa_ptr != NULL;
-#else
-	return false;
+	if (dev->dsa_ptr != NULL)
+		return dsa_uses_tagged_protocol(dev->dsa_ptr);
 #endif
+	return false;
 }
 
 /**
diff --git a/include/net/dsa.h b/include/net/dsa.h
index dc357454ae3b..1035f6452d79 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -198,4 +198,9 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
 	return (void *)(ds + 1);
 }
 
+static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
+{
+	return dst->tag_protocol != 0;
+}
+
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 03d2894a0f8a..241c2a1684cb 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -181,6 +181,17 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	return dst->ops->xmit(skb, dev);
 }
 
+static netdev_tx_t dsa_slave_notag_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	skb->dev = p->parent->dst->master_netdev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+}
+
 
 /* ethtool operations *******************************************************/
 static int
@@ -314,6 +325,11 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 };
 
+static const struct dsa_device_ops notag_netdev_ops = {
+	.xmit	= dsa_slave_notag_xmit,
+	.rcv	= NULL,
+};
+
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -415,7 +431,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		break;
 #endif
 	default:
-		BUG();
+		ds->dst->ops = &notag_netdev_ops;
+		break;
 	}
 
 	SET_NETDEV_DEV(slave_dev, parent);
-- 
1.9.1
