From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/3] dsa: set ->iflink on slave interfaces to the ifindex of the parent
Date: Fri, 20 Mar 2009 20:49:49 +0100
Message-ID: <20090320194949.GU4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Thomas <gary@mlbassoc.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:35450 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109AbZCTTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 15:49:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

..so that we can parse the DSA topology from 'ip link' output:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
4: lan1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
5: lan2@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
6: lan3@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
7: lan4@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 net/dsa/slave.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a68fd79..99114e5 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -48,6 +48,16 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 
 
 /* slave device handling ****************************************************/
+static int dsa_slave_init(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct net_device *master = p->parent->master_netdev;
+
+	dev->iflink = master->ifindex;
+
+	return 0;
+}
+
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -288,6 +298,7 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 
 #ifdef CONFIG_NET_DSA_TAG_DSA
 static const struct net_device_ops dsa_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
 	.ndo_start_xmit		= dsa_xmit,
@@ -300,6 +311,7 @@ static const struct net_device_ops dsa_netdev_ops = {
 #endif
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 static const struct net_device_ops edsa_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
 	.ndo_start_xmit		= edsa_xmit,
@@ -312,6 +324,7 @@ static const struct net_device_ops edsa_netdev_ops = {
 #endif
 #ifdef CONFIG_NET_DSA_TAG_TRAILER
 static const struct net_device_ops trailer_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
 	.ndo_start_xmit		= trailer_xmit,
-- 
1.5.6.4
