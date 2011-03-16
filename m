From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 3/6 v2] net: get rid of multiple bond-related
 netdevice->priv_flags
Date: Wed, 16 Mar 2011 19:45:23 +0100
Message-ID: <20110316184522.GA15224@psychotron.redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
 <1299935679-18135-4-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29756 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab1CPSpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 14:45:54 -0400
Content-Disposition: inline
In-Reply-To: <1299935679-18135-4-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when bond-related code is moved from net/core/dev.c into bonding
code, multiple priv_flags are not needed anymore. So let them rot.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_main.c  |   33 ++++++++++++++----------------=
---
 drivers/net/bonding/bond_sysfs.c |    8 --------
 drivers/net/bonding/bonding.h    |   24 +-----------------------
 3 files changed, 15 insertions(+), 50 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 29f69da..3c6ac2f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1458,20 +1458,20 @@ static void bond_setup_by_slave(struct net_devi=
ce *bond_dev,
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
 		    skb->protocol =3D=3D __cpu_to_be16(ETH_P_ARP))
 			return false;
=20
-		if (bond_dev->priv_flags & IFF_MASTER_ALB &&
+		if (bond->params.mode =3D=3D BOND_MODE_ALB &&
 		    skb->pkt_type !=3D PACKET_BROADCAST &&
 		    skb->pkt_type !=3D PACKET_MULTICAST)
 				return false;
=20
-		if (bond_dev->priv_flags & IFF_MASTER_8023AD &&
+		if (bond->params.mode =3D=3D BOND_MODE_8023AD &&
 		    skb->protocol =3D=3D __cpu_to_be16(ETH_P_SLOW))
 			return false;
=20
@@ -1484,6 +1484,7 @@ static struct sk_buff *bond_handle_frame(struct s=
k_buff *skb)
 {
 	struct slave *slave;
 	struct net_device *bond_dev;
+	struct bonding *bond;
=20
 	skb =3D skb_share_check(skb, GFP_ATOMIC);
 	if (unlikely(!skb))
@@ -1494,17 +1495,19 @@ static struct sk_buff *bond_handle_frame(struct=
 sk_buff *skb)
 	if (unlikely(!bond_dev))
 		return skb;
=20
-	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
+	bond =3D netdev_priv(bond_dev);
+
+	if (bond->params.arp_interval)
 		slave->dev->last_rx =3D jiffies;
=20
-	if (bond_should_deliver_exact_match(skb, slave->dev, bond_dev)) {
+	if (bond_should_deliver_exact_match(skb, slave, bond)) {
 		skb->deliver_no_wcard =3D 1;
 		return skb;
 	}
=20
 	skb->dev =3D bond_dev;
=20
-	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
+	if (bond->params.mode =3D=3D BOND_MODE_ALB &&
 	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
 	    skb->pkt_type =3D=3D PACKET_HOST) {
=20
@@ -2119,9 +2122,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
=20
 	dev_set_mtu(slave_dev, slave->original_mtu);
=20
-	slave_dev->priv_flags &=3D ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
-				   IFF_SLAVE_INACTIVE | IFF_BONDING |
-				   IFF_SLAVE_NEEDARP);
+	slave_dev->priv_flags &=3D ~(IFF_SLAVE_INACTIVE | IFF_BONDING);
=20
 	kfree(slave);
=20
@@ -2232,8 +2233,7 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 			dev_set_mac_address(slave_dev, &addr);
 		}
=20
-		slave_dev->priv_flags &=3D ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
-					   IFF_SLAVE_INACTIVE);
+		slave_dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
=20
 		kfree(slave);
=20
@@ -4416,11 +4416,9 @@ void bond_set_mode_ops(struct bonding *bond, int=
 mode)
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
@@ -4511,9 +4509,6 @@ static void bond_setup(struct net_device *bond_de=
v)
 	bond_dev->priv_flags |=3D IFF_BONDING;
 	bond_dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
=20
-	if (bond->params.arp_interval)
-		bond_dev->priv_flags |=3D IFF_MASTER_ARPMON;
-
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
 	 * empty bond. The block will be removed once non-challenged
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index 72bb0f6..05e0ae5 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -322,11 +322,6 @@ static ssize_t bonding_store_mode(struct device *d=
,
 		ret =3D -EINVAL;
 		goto out;
 	}
-	if (bond->params.mode =3D=3D BOND_MODE_8023AD)
-		bond_unset_master_3ad_flags(bond);
-
-	if (bond->params.mode =3D=3D BOND_MODE_ALB)
-		bond_unset_master_alb_flags(bond);
=20
 	bond->params.mode =3D new_value;
 	bond_set_mode_ops(bond, bond->params.mode);
@@ -527,8 +522,6 @@ static ssize_t bonding_store_arp_interval(struct de=
vice *d,
 	pr_info("%s: Setting ARP monitoring interval to %d.\n",
 		bond->dev->name, new_value);
 	bond->params.arp_interval =3D new_value;
-	if (bond->params.arp_interval)
-		bond->dev->priv_flags |=3D IFF_MASTER_ARPMON;
 	if (bond->params.miimon) {
 		pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s D=
isabling MII monitoring.\n",
 			bond->dev->name, bond->dev->name);
@@ -1004,7 +997,6 @@ static ssize_t bonding_store_miimon(struct device =
*d,
 			pr_info("%s: MII monitoring cannot be used with ARP monitoring. Dis=
abling ARP monitoring...\n",
 				bond->dev->name);
 			bond->params.arp_interval =3D 0;
-			bond->dev->priv_flags &=3D ~IFF_MASTER_ARPMON;
 			if (bond->params.arp_validate) {
 				bond_unregister_arp(bond);
 				bond->params.arp_validate =3D
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index ff9af31..049619f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -356,34 +356,12 @@ static inline void bond_set_slave_inactive_flags(=
struct slave *slave)
 		slave->state =3D BOND_STATE_BACKUP;
 	if (!bond->params.all_slaves_active)
 		slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
-	if (slave_do_arp_validate(bond, slave))
-		slave->dev->priv_flags |=3D IFF_SLAVE_NEEDARP;
 }
=20
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
 	slave->state =3D BOND_STATE_ACTIVE;
-	slave->dev->priv_flags &=3D ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP)=
;
-}
-
-static inline void bond_set_master_3ad_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags |=3D IFF_MASTER_8023AD;
-}
-
-static inline void bond_unset_master_3ad_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags &=3D ~IFF_MASTER_8023AD;
-}
-
-static inline void bond_set_master_alb_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags |=3D IFF_MASTER_ALB;
-}
-
-static inline void bond_unset_master_alb_flags(struct bonding *bond)
-{
-	bond->dev->priv_flags &=3D ~IFF_MASTER_ALB;
+	slave->dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
 }
=20
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_en=
try *curr);
--=20
1.7.4

