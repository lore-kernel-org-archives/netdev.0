From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN 02/02]: Allow setting mac address while device is up
Date: Thu, 15 Nov 2007 16:54:32 +0100 (MET)
Message-ID: <20071115155430.12874.24763.sendpatchset@localhost.localdomain>
References: <20071115155427.12874.34461.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48717 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757971AbXKOPyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 10:54:33 -0500
In-Reply-To: <20071115155427.12874.34461.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[MACVLAN]: Allow setting mac address while device is up

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3c50588260810d735231220f9a8ebaa6a6e8fb1e
tree 48ee2625502caf2454263a05b5a9869648de3aed
parent e2d06a34b52a999e8c539d1cdef51ff523e2f2c2
author Patrick McHardy <kaber@trash.net> Thu, 15 Nov 2007 16:38:06 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 15 Nov 2007 16:38:06 +0100

 drivers/net/macvlan.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 461149c..3acf8cd 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -213,6 +213,29 @@ static int macvlan_stop(struct net_device *dev)
 	return 0;
 }
 
+static int macvlan_set_mac_address(struct net_device *dev, void *p)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+	struct sockaddr *addr = p;
+	int err;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (!(dev->flags & IFF_UP))
+		goto out;
+
+	err = dev_unicast_add(lowerdev, addr->sa_data, ETH_ALEN);
+	if (err < 0)
+		return err;
+	dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
+
+out:
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	return 0;
+}
+
 static void macvlan_change_rx_flags(struct net_device *dev, int change)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -300,6 +323,7 @@ static void macvlan_setup(struct net_device *dev)
 	dev->stop		= macvlan_stop;
 	dev->change_mtu		= macvlan_change_mtu;
 	dev->change_rx_flags	= macvlan_change_rx_flags;
+	dev->set_mac_address	= macvlan_set_mac_address;
 	dev->set_multicast_list	= macvlan_set_multicast_list;
 	dev->hard_start_xmit	= macvlan_hard_start_xmit;
 	dev->destructor		= free_netdev;
