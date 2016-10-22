From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH] batman-adv: Revert "use core MTU range checking in misc drivers"
Date: Sat, 22 Oct 2016 09:46:24 +0200
Message-ID: <20161022074624.30033-1-sven@narfation.org>
Cc: davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
        linux-kernel@vger.kernel.org, Sven Eckelmann <sven@narfation.org>,
        Jarod Wilson <jarod@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The maximum MTU is defined via the slave devices of an batman-adv
interface. Thus it is not possible to calculate the max_mtu during the
creation of the batman-adv device when no slave devices are attached. Doing
so would for example break non-fragmentation setups which then
(incorrectly) allow an MTU of 1500 even when underlying device cannot
transport 1500 bytes + batman-adv headers.

Checking the dynamically calculated max_mtu via the minimum of the slave
devices MTU during .ndo_change_mtu is also used by the bridge interface.

Cc: Jarod Wilson <jarod@redhat.com>
Fixes: b3e3893e1253 ("net: use core MTU range checking in misc drivers")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
Original patch + my comment: https://patchwork.ozlabs.org/patch/684722/

I just got informed about this patch when it was already applied in net-next.
So I can only ask for an revet of the batman-adv parts

 net/batman-adv/soft-interface.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 112679d..49e16b6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -158,6 +158,17 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
+static int batadv_interface_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* check ranges */
+	if ((new_mtu < 68) || (new_mtu > batadv_hardif_min_mtu(dev)))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
 /**
  * batadv_interface_set_rx_mode - set the rx mode of a device
  * @dev: registered network device to modify
@@ -909,6 +920,7 @@ static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_vlan_rx_add_vid = batadv_interface_add_vid,
 	.ndo_vlan_rx_kill_vid = batadv_interface_kill_vid,
 	.ndo_set_mac_address = batadv_interface_set_mac_addr,
+	.ndo_change_mtu = batadv_interface_change_mtu,
 	.ndo_set_rx_mode = batadv_interface_set_rx_mode,
 	.ndo_start_xmit = batadv_interface_tx,
 	.ndo_validate_addr = eth_validate_addr,
@@ -975,7 +987,6 @@ struct net_device *batadv_softif_create(struct net *net, const char *name)
 	dev_net_set(soft_iface, net);
 
 	soft_iface->rtnl_link_ops = &batadv_link_ops;
-	soft_iface->max_mtu = batadv_hardif_min_mtu(soft_iface);
 
 	ret = register_netdevice(soft_iface);
 	if (ret < 0) {
-- 
2.9.3
