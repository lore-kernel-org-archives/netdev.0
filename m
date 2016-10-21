From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net] net: remove MTU limits on a few ether_setup callers
Date: Thu, 20 Oct 2016 23:25:27 -0400
Message-ID: <20161021032527.12954-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>,
        R Parameswaran <parameswaran.r7@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45050 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752903AbcJUDZg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 23:25:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These few drivers call ether_setup(), but have no ndo_change_mtu, and thus
were overlooked for changes to MTU range checking behavior. They
previously had no range checks, so for feature-parity, set their min_mtu
to 0 and max_mtu to ETH_MAX_MTU (65535), instead of the 68 and 1500
inherited from the ether_setup() changes. Fine-tuning can come after we get
back to full feature-parity here.

CC: netdev@vger.kernel.org
Reported-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
CC: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
CC: R Parameswaran <parameswaran.r7@gmail.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/atm/br2684.c            | 4 +++-
 net/bluetooth/bnep/netdev.c | 2 ++
 net/dsa/slave.c             | 2 ++
 net/irda/irlan/irlan_eth.c  | 3 ++-
 net/l2tp/l2tp_eth.c         | 2 ++
 5 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index c7d82f4..fca84e1 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -649,7 +649,9 @@ static void br2684_setup_routed(struct net_device *netdev)
 	netdev->hard_header_len = sizeof(llc_oui_ipv4); /* worst case */
 	netdev->netdev_ops = &br2684_netdev_ops_routed;
 	netdev->addr_len = 0;
-	netdev->mtu = 1500;
+	netdev->mtu = ETH_DATA_LEN;
+	netdev->min_mtu = 0;
+	netdev->max_mtu = ETH_MAX_MTU;
 	netdev->type = ARPHRD_PPP;
 	netdev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 	netdev->tx_queue_len = 100;
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 0f25ddc..2b875ed 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -221,6 +221,8 @@ void bnep_net_setup(struct net_device *dev)
 	dev->addr_len = ETH_ALEN;
 
 	ether_setup(dev);
+	dev->min_mtu = 0;
+	dev->max_mtu = ETH_MAX_MTU;
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->netdev_ops = &bnep_netdev_ops;
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 68714a5..d0c7bce 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1247,6 +1247,8 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->priv_flags |= IFF_NO_QUEUE;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
 	slave_dev->switchdev_ops = &dsa_slave_switchdev_ops;
+	slave_dev->min_mtu = 0;
+	slave_dev->max_mtu = ETH_MAX_MTU;
 	SET_NETDEV_DEVTYPE(slave_dev, &dsa_type);
 
 	netdev_for_each_tx_queue(slave_dev, dsa_slave_set_lockdep_class_one,
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 8192eae..74d09f9 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -66,7 +66,8 @@ static void irlan_eth_setup(struct net_device *dev)
 
 	dev->netdev_ops		= &irlan_eth_netdev_ops;
 	dev->destructor		= free_netdev;
-
+	dev->min_mtu		= 0;
+	dev->max_mtu		= ETH_MAX_MTU;
 
 	/*
 	 * Lets do all queueing in IrTTP instead of this device driver.
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 965f7e3..e2c6ae0 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -259,6 +259,8 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 		session->mtu = dev->mtu - session->hdr_len;
 	dev->mtu = session->mtu;
 	dev->needed_headroom += session->hdr_len;
+	dev->min_mtu = 0;
+	dev->max_mtu = ETH_MAX_MTU;
 
 	priv = netdev_priv(dev);
 	priv->dev = dev;
-- 
2.10.0
