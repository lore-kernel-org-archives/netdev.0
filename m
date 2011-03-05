From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 3/8] net: get rid of multiple bond-related netdevice->priv_flags
Date: Sat,  5 Mar 2011 11:29:24 +0100
Message-ID: <1299320969-7951-4-git-send-email-jpirko@redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553Ab1CEK3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 05:29:42 -0500
In-Reply-To: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when bond-related code is moved from net/core/dev.c into bonding
code, multiple priv_flags are not needed anymore. So toss them out.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c  |   33 ++++++++++++++-------------------
 drivers/net/bonding/bond_sysfs.c |    8 --------
 drivers/net/bonding/bonding.h    |   24 +-----------------------
 include/linux/if.h               |   22 +++++++++-------------
 4 files changed, 24 insertions(+), 63 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1c19368..7923184 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1471,20 +1471,20 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
  * ARP on active-backup slaves with arp_validate enabled.
  */
 static bool bond_should_deliver_exact_match(struct sk_buff *skb,
-					    struct net_device *slave_dev,
-					    struct net_device *bond_dev)
+					    struct slave *slave,
+					    struct bonding *bond)
 {
-	if (slave_dev->priv_flags & IFF_SLAVE_INACTIVE) {
-		if (slave_dev->priv_flags & IFF_SLAVE_NEEDARP &&
+	if (slave->dev->priv_flags & IFF_SLAVE_INACTIVE) {
+		if (slave_do_arp_validate(bond, slave) &&
 		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
 			return false;
 
-		if (bond_dev->priv_flags & IFF_MASTER_ALB &&
+		if (bond->params.mode == BOND_MODE_ALB &&
 		    skb->pkt_type != PACKET_BROADCAST &&
 		    skb->pkt_type != PACKET_MULTICAST)
 				return false;
 
-		if (bond_dev->priv_flags & IFF_MASTER_8023AD &&
+		if (bond->params.mode == BOND_MODE_8023AD &&
 		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
 			return false;
 
@@ -1497,6 +1497,7 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 {
 	struct slave *slave;
 	struct net_device *bond_dev;
+	struct bonding *bond;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
@@ -1507,17 +1508,19 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 	if (unlikely(!bond_dev))
 		return skb;
 
-	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
+	bond = netdev_priv(bond_dev);
+
+	if (bond->params.arp_interval)
 		slave->dev->last_rx = jiffies;
 
-	if (bond_should_deliver_exact_match(skb, slave->dev, bond_dev)) {
+	if (bond_should_deliver_exact_match(skb, slave, bond)) {
 		skb->deliver_no_wcard = 1;
 		return skb;
 	}
 
 	skb->dev = bond_dev;
 
-	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
+	if (bond->params.mode == BOND_MODE_ALB &&
 	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
 	    skb->pkt_type == PACKET_HOST) {
 		u16 *dest = (u16 *) eth_hdr(skb)->h_dest;
@@ -2128,9 +2131,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	dev_set_mtu(slave_dev, slave->original_mtu);
 
-	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
-				   IFF_SLAVE_INACTIVE | IFF_BONDING |
-				   IFF_SLAVE_NEEDARP);
+	slave_dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_BONDING);
 
 	kfree(slave);
 
@@ -2241,8 +2242,7 @@ static int bond_release_all(struct net_device *bond_dev)
 			dev_set_mac_address(slave_dev, &addr);
 		}
 
-		slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
-					   IFF_SLAVE_INACTIVE);
+		slave_dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
 
 		kfree(slave);
 
@@ -4718,11 +4718,9 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 	case BOND_MODE_BROADCAST:
 		break;
 	case BOND_MODE_8023AD:
-		bond_set_master_3ad_flags(bond);
 		bond_set_xmit_hash_policy(bond);
 		break;
 	case BOND_MODE_ALB:
-		bond_set_master_alb_flags(bond);
 		/* FALLTHRU */
 	case BOND_MODE_TLB:
 		break;
@@ -4813,9 +4811,6 @@ static void bond_setup(struct net_device *bond_dev)
 	bond_dev->priv_flags |= IFF_BONDING;
 	bond_dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 
-	if (bond->params.arp_interval)
-		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
-
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
 	 * empty bond. The block will be removed once non-challenged
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 72bb0f6..05e0ae5 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -322,11 +322,6 @@ static ssize_t bonding_store_mode(struct device *d,
 		ret = -EINVAL;
 		goto out;
 	}
-	if (bond->params.mode == BOND_MODE_8023AD)
-		bond_unset_master_3ad_flags(bond);
-
-	if (bond->params.mode == BOND_MODE_ALB)
-		bond_unset_master_alb_flags(bond);
 
 	bond->params.mode = new_value;
 	bond_set_mode_ops(bond, bond->params.mode);
@@ -527,8 +522,6 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	pr_info("%s: Setting ARP monitoring interval to %d.\n",
 		bond->dev->name, new_value);
 	bond->params.arp_interval = new_value;
-	if (bond->params.arp_interval)
-		bond->dev->priv_flags |= IFF_MASTER_ARPMON;
 	if (bond->params.miimon) {
 		pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
 			bond->dev->name, bond->dev->name);
@@ -1004,7 +997,6 @@ static ssize_t bonding_store_miimon(struct device *d,
 			pr_info("%s: MII monitoring cannot be used with ARP monitoring. Disabling ARP monitoring...\n",
 				bond->dev->name);
 			bond->params.arp_interval = 0;
-			bond->dev->priv_flags &= ~IFF_MASTER_ARPMON;
 			if (bond->params.arp_validate) {
 				bond_unregister_arp(bond);
 				bond->params.arp_validate =
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 1aac5cd..ddee62f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -354,34 +354,12 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 		slave->state = BOND_STATE_BACKUP;
 	if (!bond->params.all_slaves_active)
 		slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
-	if (slave_do_arp_validate(bond, slave))
-		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
 }
 
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
 	slave->state = BOND_STATE_ACTIVE;
-	slave->dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP);
-}
-
-static inline void bond_set_master_3ad_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags |= IFF_MASTER_8023AD;
-}
-
-static inline void bond_unset_master_3ad_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags &= ~IFF_MASTER_8023AD;
-}
-
-static inline void bond_set_master_alb_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags |= IFF_MASTER_ALB;
-}
-
-static inline void bond_unset_master_alb_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags &= ~IFF_MASTER_ALB;
+	slave->dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
 }
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
diff --git a/include/linux/if.h b/include/linux/if.h
index 3bc63e6..2fdd47a 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -60,21 +60,17 @@
 #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
 #define IFF_EBRIDGE	0x2		/* Ethernet bridging device.	*/
 #define IFF_SLAVE_INACTIVE	0x4	/* bonding slave not the curr. active */
-#define IFF_MASTER_8023AD	0x8	/* bonding master, 802.3ad. 	*/
-#define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
-#define IFF_BONDING	0x20		/* bonding master or slave	*/
-#define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
-#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
-#define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
-#define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
-#define IFF_XMIT_DST_RELEASE 0x400	/* dev_hard_start_xmit() is allowed to
+#define IFF_BONDING	0x8		/* bonding master or slave	*/
+#define IFF_ISATAP	0x10		/* ISATAP interface (RFC4214)	*/
+#define IFF_WAN_HDLC	0x20		/* WAN HDLC device		*/
+#define IFF_XMIT_DST_RELEASE 0x40	/* dev_hard_start_xmit() is allowed to
 					 * release skb->dst
 					 */
-#define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
-#define IFF_DISABLE_NETPOLL	0x1000	/* disable netpoll at run-time */
-#define IFF_MACVLAN_PORT	0x2000	/* device used as macvlan port */
-#define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
-#define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
+#define IFF_DONT_BRIDGE 0x80		/* disallow bridging this ether dev */
+#define IFF_DISABLE_NETPOLL	0x100	/* disable netpoll at run-time */
+#define IFF_MACVLAN_PORT	0x200	/* device used as macvlan port */
+#define IFF_BRIDGE_PORT	0x400		/* device used as bridge port */
+#define IFF_OVS_DATAPATH	0x800	/* device used as Open vSwitch
 					 * datapath port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
-- 
1.7.4

