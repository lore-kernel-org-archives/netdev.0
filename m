From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: vxlan: use custom ndo_change_mtu handler
Date: Tue, 17 Dec 2013 14:20:09 +0100
Message-ID: <1387286409-1783-1-git-send-email-dborkman@redhat.com>
Cc: shahed.shaikh@qlogic.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914Ab3LQNUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 08:20:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding a new vxlan device to an "underlying carrier" (here:
dst->remote_ifindex), the MTU size assigned to the vxlan device
is the MTU at setup time of the carrier - needed headroom, when
adding a vxlan device w/o explicit carrier, then it defaults
to 1500.

In case of an explicit carrier that supports jumbo frames, we
currently cannot change vxlan MTU via ip(8) to > 1500 in
post-setup time, as vxlan driver uses eth_change_mtu() as default
method for manually setting MTU.

Hence, use a custom implementation that only falls back to
eth_change_mtu() in case we didn't use a dev parameter on device
setup time, and otherwise allow a max MTU setting of the carrier
incl. adjustment for headroom.

Reported-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/vxlan.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 58f6a0c..b80c22b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2014,6 +2014,32 @@ static void vxlan_set_multicast_list(struct net_device *dev)
 {
 }
 
+static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *dst = &vxlan->default_dst;
+	bool is_ipv6 = dst->remote_ip.sa.sa_family == AF_INET6;
+	int hroom = is_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM;
+	struct net_device *lowerdev;
+
+	lowerdev = dev_get_by_index(net, dst->remote_ifindex);
+	if (lowerdev == NULL)
+		return eth_change_mtu(dev, new_mtu);
+
+	if (new_mtu == lowerdev->mtu)
+		new_mtu = lowerdev->mtu - hroom;
+	if (new_mtu < 68 || new_mtu > lowerdev->mtu - hroom) {
+		dev_put(lowerdev);
+		return -EINVAL;
+	}
+
+	dev->mtu = new_mtu;
+
+	dev_put(lowerdev);
+	return 0;
+}
+
 static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_init		= vxlan_init,
 	.ndo_uninit		= vxlan_uninit,
@@ -2022,7 +2048,7 @@ static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_start_xmit		= vxlan_xmit,
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
 	.ndo_set_rx_mode	= vxlan_set_multicast_list,
-	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_change_mtu		= vxlan_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_fdb_add		= vxlan_fdb_add,
-- 
1.8.3.1
