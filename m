From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: allow bond in mode balance-alb to work properly
	in bridge
Date: Fri, 13 Mar 2009 19:33:04 +0100
Message-ID: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57348 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbZCMSen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 14:34:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

This is only a draft of patch to consult. I'm aware that it should be divided
into multiple patches. I want to know opinion from you folks.

The problem is described in following bugzilla:
https://bugzilla.redhat.com/show_bug.cgi?id=487763

Basically here's what's going on. In every mode, bonding interface uses the same
mac address for all enslaved devices. Except for mode balance-alb. When you put
this kind of bond device into a bridge it will only add one of mac adresses into
a hash list of mac addresses, say X. This mac address is marked as local. But
this bonding interface also has mac address Y. Now then packet arrives with
destination address Y, this address is not marked as local and the packed looks
like it needs to be forwarded. This packet is then lost which is wrong.

Notice that interfaces can be added and removed from bond while it is in bridge.
Therefore I introduce another function pointer in struct net_device_ops -
ndo_check_mac_address. This function when it's implemented should check passed
mac address against the one set in device. I'm using this in bonding driver when
the bond is in mode balance-alb to walk thru all slaves and checking if any of
them equals passed address.

Then in bridge function br_handle_frame_finish() I'm using ndo_check_mac_address
to recognize the destination mac address as local.

Please look at this and tell me what you think about it.

Thanks

Jirka


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bonding/bond_alb.c  |   17 +++++++++++++++++
 drivers/net/bonding/bond_alb.h  |    1 +
 drivers/net/bonding/bond_main.c |   11 +++++++++++
 include/linux/netdevice.h       |    7 +++++++
 net/bridge/br_input.c           |    5 ++++-
 5 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 27fb7f5..b7bcee0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1762,6 +1762,23 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	return 0;
 }
 
+int bond_alb_check_mac_address(struct net_device *bond_dev, void *addr)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave = NULL;
+	int ret = !0;
+	int i;
+
+	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		ret = compare_ether_addr(slave->perm_hwaddr, addr);
+		if (!ret)
+			break;
+	}
+	read_unlock(&bond->lock);
+	return ret;
+}
+
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 {
 	if (bond->alb_info.current_alb_vlan &&
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 50968f8..5e39bda 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -127,6 +127,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
+int bond_alb_check_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e0578fe..fbff338 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4279,6 +4279,16 @@ unwind:
 	return res;
 }
 
+static int bond_check_mac_address(struct net_device *bond_dev, void *addr)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	if (bond->params.mode == BOND_MODE_ALB)
+		return bond_alb_check_mac_address(bond_dev, addr);
+
+	return compare_ether_addr(bond_dev->dev_addr, addr);
+}
+
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -4576,6 +4586,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_set_multicast_list	= bond_set_multicast_list,
 	.ndo_change_mtu		= bond_change_mtu,
 	.ndo_set_mac_address 	= bond_set_mac_address,
+	.ndo_check_mac_address 	= bond_check_mac_address,
 	.ndo_neigh_setup	= bond_neigh_setup,
 	.ndo_vlan_rx_register	= bond_vlan_rx_register,
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6593667..e75f691 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -491,6 +491,10 @@ struct netdev_queue {
  *	needs to be changed. If not this interface is not defined, the
  *	mac address can not be changed.
  *
+ * int (*ndo_check_mac_address)(struct net_device *dev, void *addr);
+ *	This function is called when the given Media Access Control address
+ *	needs to compared to the one set to the device.
+ *
  * int (*ndo_validate_addr)(struct net_device *dev);
  *	Test if Media Access Control address is valid for the device.
  *
@@ -554,6 +558,9 @@ struct net_device_ops {
 #define HAVE_SET_MAC_ADDR
 	int			(*ndo_set_mac_address)(struct net_device *dev,
 						       void *addr);
+#define HAVE_CHECK_MAC_ADDR
+	int			(*ndo_check_mac_address)(struct net_device *dev,
+						       void *addr);
 #define HAVE_VALIDATE_ADDR
 	int			(*ndo_validate_addr)(struct net_device *dev);
 #define HAVE_PRIVATE_IOCTL
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 30b8877..b071169 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -39,6 +39,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = rcu_dereference(skb->dev->br_port);
+	struct net_device *dev = p->dev;
 	struct net_bridge *br;
 	struct net_bridge_fdb_entry *dst;
 	struct sk_buff *skb2;
@@ -64,7 +65,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (is_multicast_ether_addr(dest)) {
 		br->dev->stats.multicast++;
 		skb2 = skb;
-	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
+	} else if (((dst = __br_fdb_get(br, dest)) && dst->is_local) ||
+		   (dev->netdev_ops->ndo_check_mac_address &&
+		    !dev->netdev_ops->ndo_check_mac_address(dev, (unsigned char *) dest))) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
 		skb = NULL;
