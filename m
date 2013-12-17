From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v2 net-next] net: vxlan: use custom ndo_change_mtu handler
Date: Tue, 17 Dec 2013 21:37:40 +0100
Message-ID: <1387312660-3467-1-git-send-email-dborkman@redhat.com>
Cc: shahed.shaikh@qlogic.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754Ab3LQUhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 15:37:45 -0500
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
 v1->v2:
  - applied Stephen's feedback

 drivers/net/vxlan.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 58f6a0c..72466e9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2014,6 +2014,30 @@ static void vxlan_set_multicast_list(struct net_device *dev)
 {
 }
 
+static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *dst = &vxlan->default_dst;
+	struct net_device *lowerdev;
+	int max_mtu;
+
+	lowerdev = __dev_get_by_index(dev_net(dev),
+				      vxlan->default_dst.remote_ifindex);
+	if (lowerdev == NULL)
+		return eth_change_mtu(dev, new_mtu);
+
+	if (dst->remote_ip.sa.sa_family == AF_INET6)
+		max_mtu = lowerdev->mtu - VXLAN6_HEADROOM;
+	else
+		max_mtu = lowerdev->mtu - VXLAN_HEADROOM;
+
+	if (new_mtu < 68 || new_mtu > max_mtu)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_init		= vxlan_init,
 	.ndo_uninit		= vxlan_uninit,
@@ -2022,7 +2046,7 @@ static const struct net_device_ops vxlan_netdev_ops = {
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
