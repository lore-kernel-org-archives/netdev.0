From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Allow setting mac address while device is up
Date: Thu, 08 Nov 2007 18:20:19 +0100
Message-ID: <47334553.6000206@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000004000701060205040806"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65233 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760716AbXKHRUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 12:20:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000004000701060205040806
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch allows to change a VLAN device's MAC address while
the device is up. Doesn't seem worth to hold back until
2.6.25-rc since it can't break anything without actually
getting used (and it does work :))


--------------000004000701060205040806
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[VLAN]: Allow setting mac address while device is up

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5efb3597bba3b223fcf3690a88394064dded87ba
tree a15ae1c12bcdc1277c5a5096f420437c1ded7414
parent f6d0e3b654d36bd87016b0626464990f3fc57ca7
author Patrick McHardy <kaber@trash.net> Thu, 08 Nov 2007 18:12:20 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 08 Nov 2007 18:12:20 +0100

 net/8021q/vlan.c     |    1 +
 net/8021q/vlan.h     |    1 +
 net/8021q/vlan_dev.c |   26 ++++++++++++++++++++++++++
 3 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d80afec..dd4086b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -376,6 +376,7 @@ void vlan_setup(struct net_device *new_dev)
 	new_dev->init = vlan_dev_init;
 	new_dev->open = vlan_dev_open;
 	new_dev->stop = vlan_dev_stop;
+	new_dev->set_mac_address = vlan_set_mac_address;
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 	new_dev->change_rx_flags = vlan_change_rx_flags;
 	new_dev->destructor = free_netdev;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index cf4a80d..2cd1393 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -60,6 +60,7 @@ int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev
 int vlan_dev_change_mtu(struct net_device *dev, int new_mtu);
 int vlan_dev_open(struct net_device* dev);
 int vlan_dev_stop(struct net_device* dev);
+int vlan_set_mac_address(struct net_device *dev, void *p);
 int vlan_dev_ioctl(struct net_device* dev, struct ifreq *ifr, int cmd);
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, short vlan_prio);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1a1740a..7a36878 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -665,6 +665,32 @@ int vlan_dev_stop(struct net_device *dev)
 	return 0;
 }
 
+int vlan_set_mac_address(struct net_device *dev, void *p)
+{
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct sockaddr *addr = p;
+	int err;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (!(dev->flags & IFF_UP))
+		goto out;
+
+	if (compare_ether_addr(addr->sa_data, real_dev->dev_addr)) {
+		err = dev_unicast_add(real_dev, addr->sa_data, ETH_ALEN);
+		if (err < 0)
+			return err;
+	}
+
+	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
+
+out:
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	return 0;
+}
+
 int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;

--------------000004000701060205040806--
