From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/19] netdev: convert pseudo drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:51 -0700
Message-ID: <20090901055129.617288897@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57460 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781AbZIAF6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:54 -0400
Content-Disposition: inline; filename=more-misc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are all drivers that don't touch real hardware.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/firewire/net.c          |    2 +-
 drivers/net/bonding/bond_main.c |    2 +-
 drivers/net/can/vcan.c          |    2 +-
 drivers/net/dummy.c             |   22 ++++++++++------------
 drivers/net/eql.c               |    4 ++--
 drivers/net/ifb.c               |    9 ++++-----
 drivers/net/macvlan.c           |    3 ++-
 drivers/net/ppp_generic.c       |    2 +-
 drivers/net/slip.c              |    2 +-
 drivers/net/tun.c               |    2 +-
 drivers/net/veth.c              |    2 +-
 drivers/net/virtio_net.c        |    2 +-
 net/phonet/pep-gprs.c           |    2 +-
 13 files changed, 27 insertions(+), 29 deletions(-)

--- a/drivers/net/ifb.c	2009-08-31 16:17:52.671091194 -0700
+++ b/drivers/net/ifb.c	2009-08-31 16:27:13.201091438 -0700
@@ -59,7 +59,7 @@ struct ifb_private {
 static int numifbs = 2;
 
 static void ri_tasklet(unsigned long dev);
-static int ifb_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev);
 static int ifb_open(struct net_device *dev);
 static int ifb_close(struct net_device *dev);
 
@@ -160,11 +160,10 @@ static void ifb_setup(struct net_device 
 	random_ether_addr(dev->dev_addr);
 }
 
-static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
-	int ret = NETDEV_TX_OK;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
 	stats->rx_packets++;
@@ -173,7 +172,7 @@ static int ifb_xmit(struct sk_buff *skb,
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->iif) {
 		dev_kfree_skb(skb);
 		stats->rx_dropped++;
-		return ret;
+		return NETDEV_TX_OK;
 	}
 
 	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
@@ -187,7 +186,7 @@ static int ifb_xmit(struct sk_buff *skb,
 		tasklet_schedule(&dp->ifb_tasklet);
 	}
 
-	return ret;
+	return NETDEV_TX_OK;
 }
 
 static int ifb_close(struct net_device *dev)
--- a/drivers/net/macvlan.c	2009-08-31 16:17:52.721091262 -0700
+++ b/drivers/net/macvlan.c	2009-08-31 16:27:47.322328136 -0700
@@ -184,7 +184,8 @@ static struct sk_buff *macvlan_handle_fr
 	return NULL;
 }
 
-static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
--- a/drivers/net/virtio_net.c	2009-08-31 16:17:52.701107507 -0700
+++ b/drivers/net/virtio_net.c	2009-08-31 16:28:02.602319381 -0700
@@ -519,7 +519,7 @@ static void xmit_tasklet(unsigned long d
 	netif_tx_unlock_bh(vi->dev);
 }
 
-static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
--- a/drivers/net/dummy.c	2009-08-31 16:17:52.711091877 -0700
+++ b/drivers/net/dummy.c	2009-08-31 16:28:20.634332248 -0700
@@ -39,8 +39,6 @@
 
 static int numdummies = 1;
 
-static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
-
 static int dummy_set_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *sa = p;
@@ -57,6 +55,16 @@ static void set_multicast_list(struct ne
 {
 }
 
+
+static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
 static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_start_xmit		= dummy_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -78,16 +86,6 @@ static void dummy_setup(struct net_devic
 	dev->flags &= ~IFF_MULTICAST;
 	random_ether_addr(dev->dev_addr);
 }
-
-static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
-	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
-}
-
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
--- a/drivers/net/tun.c	2009-08-31 16:17:52.691107284 -0700
+++ b/drivers/net/tun.c	2009-08-31 16:28:30.394333166 -0700
@@ -358,7 +358,7 @@ static int tun_net_close(struct net_devi
 }
 
 /* Net device start xmit */
-static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
--- a/drivers/net/veth.c	2009-08-31 16:17:52.691107284 -0700
+++ b/drivers/net/veth.c	2009-08-31 16:27:13.211106957 -0700
@@ -148,7 +148,7 @@ static struct ethtool_ops veth_ethtool_o
  * xmit
  */
 
-static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device *rcv = NULL;
 	struct veth_priv *priv, *rcv_priv;
--- a/drivers/firewire/net.c	2009-08-31 16:17:52.731143867 -0700
+++ b/drivers/firewire/net.c	2009-08-31 16:27:13.211106957 -0700
@@ -1188,7 +1188,7 @@ static int fwnet_stop(struct net_device 
 	return 0;
 }
 
-static int fwnet_tx(struct sk_buff *skb, struct net_device *net)
+static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 {
 	struct fwnet_header hdr_buf;
 	struct fwnet_device *dev = netdev_priv(net);
--- a/drivers/net/bonding/bond_main.c	2009-08-31 16:17:52.661107314 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-08-31 16:28:48.571114507 -0700
@@ -4450,7 +4450,7 @@ static void bond_set_xmit_hash_policy(st
 	}
 }
 
-static int bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct bonding *bond = netdev_priv(dev);
 
--- a/drivers/net/can/vcan.c	2009-08-31 16:17:52.681081639 -0700
+++ b/drivers/net/can/vcan.c	2009-08-31 16:27:13.211106957 -0700
@@ -83,7 +83,7 @@ static void vcan_rx(struct sk_buff *skb,
 	netif_rx(skb);
 }
 
-static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	int loop;
--- a/drivers/net/eql.c	2009-08-31 16:17:52.681081639 -0700
+++ b/drivers/net/eql.c	2009-08-31 16:29:03.411105414 -0700
@@ -127,7 +127,7 @@
 static int eql_open(struct net_device *dev);
 static int eql_close(struct net_device *dev);
 static int eql_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t eql_slave_xmit(struct sk_buff *skb, struct net_device *dev);
 
 #define eql_is_slave(dev)	((dev->flags & IFF_SLAVE) == IFF_SLAVE)
 #define eql_is_master(dev)	((dev->flags & IFF_MASTER) == IFF_MASTER)
@@ -325,7 +325,7 @@ static slave_t *__eql_schedule_slaves(sl
 	return best_slave;
 }
 
-static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	equalizer_t *eql = netdev_priv(dev);
 	slave_t *slave;
--- a/drivers/net/ppp_generic.c	2009-08-31 16:17:52.671091194 -0700
+++ b/drivers/net/ppp_generic.c	2009-08-31 16:27:13.211106957 -0700
@@ -951,7 +951,7 @@ out:
 /*
  * Network interface unit routines.
  */
-static int
+static netdev_tx_t
 ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ppp *ppp = netdev_priv(dev);
--- a/drivers/net/slip.c	2009-08-31 16:17:52.711091877 -0700
+++ b/drivers/net/slip.c	2009-08-31 16:27:13.211106957 -0700
@@ -474,7 +474,7 @@ out:
 
 
 /* Encapsulate an IP datagram and kick it into a TTY queue. */
-static int
+static netdev_tx_t
 sl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct slip *sl = netdev_priv(dev);
--- a/net/phonet/pep-gprs.c	2009-08-31 16:17:52.651081529 -0700
+++ b/net/phonet/pep-gprs.c	2009-08-31 16:27:13.211106957 -0700
@@ -183,7 +183,7 @@ static int gprs_close(struct net_device 
 	return 0;
 }
 
-static int gprs_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gprs_dev *gp = netdev_priv(dev);
 	struct sock *sk = gp->sk;

-- 

