From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [net-next-2.6 BUG] VLAN out of service ?
Date: Fri, 19 Dec 2008 20:46:18 +0100
Message-ID: <494BFA0A.8010202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54456 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbYLSTqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 14:46:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just tried some VLAN settings on my machine and got an immediate crash on latest net-next-2.6

ip link set eth2 up

ip link add link eth2 eth2.825 type vlan id 825
ip addr add 10.170.73.104/25 dev eth2.825
ip link set eth2.825 up

ip route add 10.170.72.0/24 via 10.170.73.126

ping 10.170.73.126
<<crash>>
Code: Bad EIP value.
EIP: [<00000000>] 0x0 SS:ESP 0068:f707bdb4
Kernel panic - not syncing: Fatal exception in interrupt

crash while jumping to ops->ndo_start_xmit(skb, dev);

CONFIG_COMPAT_NET_DEV_OPS is set in my .config, eth2 is a tg3

static const struct net_device_ops vlan_netdev_ops
has no ndo_start_xmit initializer.

Thanks

[PATCH] vlan: fix convertion to net_device_ops

commit 656299f706e52e0409733d704c2761f1b12d6954
(vlan: convert to net_device_ops) added a net_device_ops
with a NULL ndo_start_xmit field.

This gives a crash in dev_hard_start_xmit()

Fix it using two net_device_ops structures, one for hwaccel vlan,
one for non hwaccel vlan.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 71193a6..89a3bbd 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -593,6 +593,8 @@ static const struct header_ops vlan_header_ops = {
 	.parse	 = eth_header_parse,
 };
 
+static const struct net_device_ops vlan_netdev_ops, vlan_netdev_accel_ops;
+
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
@@ -619,11 +621,11 @@ static int vlan_dev_init(struct net_device *dev)
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
-		dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
+		dev->netdev_ops         = &vlan_netdev_accel_ops;
 	} else {
 		dev->header_ops      = &vlan_header_ops;
 		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
-		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
+		dev->netdev_ops         = &vlan_netdev_ops;
 	}
 
 	if (is_vlan_dev(real_dev))
@@ -704,6 +706,22 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_uninit		= vlan_dev_uninit,
 	.ndo_open		= vlan_dev_open,
 	.ndo_stop		= vlan_dev_stop,
+	.ndo_start_xmit =  vlan_dev_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= vlan_dev_set_mac_address,
+	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
+	.ndo_set_multicast_list	= vlan_dev_set_rx_mode,
+	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
+	.ndo_do_ioctl		= vlan_dev_ioctl,
+};
+
+static const struct net_device_ops vlan_netdev_accel_ops = {
+	.ndo_change_mtu		= vlan_dev_change_mtu,
+	.ndo_init		= vlan_dev_init,
+	.ndo_uninit		= vlan_dev_uninit,
+	.ndo_open		= vlan_dev_open,
+	.ndo_stop		= vlan_dev_stop,
+	.ndo_start_xmit =  vlan_dev_hwaccel_hard_start_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= vlan_dev_set_mac_address,
 	.ndo_set_rx_mode	= vlan_dev_set_rx_mode,
