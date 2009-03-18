From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] netdev: handle setting transmit queue length on active
 device.
Date: Wed, 18 Mar 2009 10:02:37 -0700
Message-ID: <20090318100237.06e974c9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57788 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066AbZCRRCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 13:02:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some virtual devices like VLAN's or bridges by default have not transmit queue.
In order to do queuing disciplines on these devices a queue must be added
by setting transmit queue length. The kernel allows doing this at any time, but
setting the queue length value is not enough. Setting the queue length does
not create the transmit queue (going from 0 to non-zero) or destroy it
(setting to zero); the queue is only created (or destroyed) when device
comes up (or goes down).

This patch handles this be doing the necessary activations.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   19 +++++++++++++++++--
 net/core/net-sysfs.c      |    5 ++---
 net/core/rtnetlink.c      |    2 +-
 4 files changed, 22 insertions(+), 6 deletions(-)

--- a/include/linux/netdevice.h	2009-03-17 11:06:40.358479573 -0700
+++ b/include/linux/netdevice.h	2009-03-17 11:13:55.243604979 -0700
@@ -1436,6 +1436,8 @@ extern int		dev_change_net_namespace(str
 extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
+extern int		dev_set_tx_queue_len(struct net_device *dev,
+					     unsigned long len);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev,
 					    struct netdev_queue *txq);
--- a/net/core/dev.c	2009-03-17 11:05:54.919541341 -0700
+++ b/net/core/dev.c	2009-03-17 11:16:25.717479320 -0700
@@ -983,6 +983,22 @@ int dev_set_alias(struct net_device *dev
 	return len;
 }
 
+/**
+ *
+ *	@dev: device
+ *	@len: limit of frames in transmit queue
+ *
+ *	Set ifalias for a device,
+ */
+int dev_set_tx_queue_len(struct net_device *dev, unsigned long len)
+{
+	if (dev->flags & IFF_UP)
+		dev_deactivate(dev);
+	dev->tx_queue_len = len;
+	if (dev->flags & IFF_UP)
+		dev_activate(dev);
+	return 0;
+}
 
 /**
  *	netdev_features_change - device changes features
@@ -3975,8 +3991,7 @@ static int dev_ifsioc(struct net *net, s
 		case SIOCSIFTXQLEN:
 			if (ifr->ifr_qlen < 0)
 				return -EINVAL;
-			dev->tx_queue_len = ifr->ifr_qlen;
-			return 0;
+			return dev_set_tx_queue_len(dev, ifr->ifr_qlen);
 
 		case SIOCSIFNAME:
 			ifr->ifr_newname[IFNAMSIZ-1] = '\0';
--- a/net/core/net-sysfs.c	2009-03-17 11:05:54.896453584 -0700
+++ b/net/core/net-sysfs.c	2009-03-17 11:10:10.877230558 -0700
@@ -198,10 +198,9 @@ static ssize_t store_flags(struct device
 
 NETDEVICE_SHOW(tx_queue_len, fmt_ulong);
 
-static int change_tx_queue_len(struct net_device *net, unsigned long new_len)
+static int change_tx_queue_len(struct net_device *netdev, unsigned long new_len)
 {
-	net->tx_queue_len = new_len;
-	return 0;
+	return dev_set_tx_queue_len(netdev, new_len);
 }
 
 static ssize_t store_tx_queue_len(struct device *dev,
--- a/net/core/rtnetlink.c	2009-03-17 11:10:47.540541648 -0700
+++ b/net/core/rtnetlink.c	2009-03-17 11:11:28.722542409 -0700
@@ -885,7 +885,7 @@ static int do_setlink(struct net_device 
 	}
 
 	if (tb[IFLA_TXQLEN])
-		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+		dev_set_tx_queue_len(dev, nla_get_u32(tb[IFLA_TXQLEN]));
 
 	if (tb[IFLA_OPERSTATE])
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
