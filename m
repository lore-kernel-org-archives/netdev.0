From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 5/6] bonding: get rid of IFF_SLAVE_INACTIVE netdev->priv_flag
Date: Sat, 12 Mar 2011 14:14:38 +0100
Message-ID: <1299935679-18135-6-git-send-email-jpirko@redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858Ab1CLNP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:15:29 -0500
In-Reply-To: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since bond-related code was moved from net/core/dev.c into bonding,
IFF_SLAVE_INACTIVE is no longer needed. Replace is with flag "inactive"
stored in slave structure

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_main.c  |    6 ++----
 drivers/net/bonding/bond_sysfs.c |    4 ++--
 drivers/net/bonding/bonding.h    |   14 ++++++++++----
 include/linux/if.h               |   19 +++++++++----------
 4 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index c5f3a01..c3150df 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1461,7 +1461,7 @@ static bool bond_should_deliver_exact_match(struc=
t sk_buff *skb,
 					    struct slave *slave,
 					    struct bonding *bond)
 {
-	if (slave->dev->priv_flags & IFF_SLAVE_INACTIVE) {
+	if (bond_is_slave_inactive(slave)) {
 		if (slave_do_arp_validate(bond, slave) &&
 		    skb->protocol =3D=3D __cpu_to_be16(ETH_P_ARP))
 			return false;
@@ -2122,7 +2122,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
=20
 	dev_set_mtu(slave_dev, slave->original_mtu);
=20
-	slave_dev->priv_flags &=3D ~(IFF_SLAVE_INACTIVE | IFF_BONDING);
+	slave_dev->priv_flags &=3D ~IFF_BONDING;
=20
 	kfree(slave);
=20
@@ -2233,8 +2233,6 @@ static int bond_release_all(struct net_device *bo=
nd_dev)
 			dev_set_mac_address(slave_dev, &addr);
 		}
=20
-		slave_dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
-
 		kfree(slave);
=20
 		/* re-acquire the lock before getting the next slave */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index 344d23f..5161183 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1581,9 +1581,9 @@ static ssize_t bonding_store_slaves_active(struct=
 device *d,
 	bond_for_each_slave(bond, slave, i) {
 		if (!bond_is_active_slave(slave)) {
 			if (new_value)
-				slave->dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
+				slave->inactive =3D 0;
 			else
-				slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
+				slave->inactive =3D 1;
 		}
 	}
 out:
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 63e9cf7..6b26962 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -192,8 +192,9 @@ struct slave {
 	unsigned long last_arp_rx;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     new_link;
-	u8     backup;	/* indicates backup slave. Value corresponds with
-			   BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
+	u8     backup:1,   /* indicates backup slave. Value corresponds with
+			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
+	       inactive:1; /* indicates inactive slave */
 	u32    original_mtu;
 	u32    link_failure_count;
 	u8     perm_hwaddr[ETH_ALEN];
@@ -376,13 +377,18 @@ static inline void bond_set_slave_inactive_flags(=
struct slave *slave)
 	if (!bond_is_lb(bond))
 		bond_set_backup_slave(slave);
 	if (!bond->params.all_slaves_active)
-		slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
+		slave->inactive =3D 1;
 }
=20
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
 	bond_set_active_slave(slave);
-	slave->dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
+	slave->inactive =3D 0;
+}
+
+static inline bool bond_is_slave_inactive(struct slave *slave)
+{
+	return slave->inactive;
 }
=20
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_en=
try *curr);
diff --git a/include/linux/if.h b/include/linux/if.h
index 2fdd47a..0da7991 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -59,18 +59,17 @@
 /* Private (from user) interface flags (netdevice->priv_flags). */
 #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.        =
  */
 #define IFF_EBRIDGE	0x2		/* Ethernet bridging device.	*/
-#define IFF_SLAVE_INACTIVE	0x4	/* bonding slave not the curr. active *=
/
-#define IFF_BONDING	0x8		/* bonding master or slave	*/
-#define IFF_ISATAP	0x10		/* ISATAP interface (RFC4214)	*/
-#define IFF_WAN_HDLC	0x20		/* WAN HDLC device		*/
-#define IFF_XMIT_DST_RELEASE 0x40	/* dev_hard_start_xmit() is allowed =
to
+#define IFF_BONDING	0x4		/* bonding master or slave	*/
+#define IFF_ISATAP	0x8		/* ISATAP interface (RFC4214)	*/
+#define IFF_WAN_HDLC	0x10		/* WAN HDLC device		*/
+#define IFF_XMIT_DST_RELEASE 0x20	/* dev_hard_start_xmit() is allowed =
to
 					 * release skb->dst
 					 */
-#define IFF_DONT_BRIDGE 0x80		/* disallow bridging this ether dev */
-#define IFF_DISABLE_NETPOLL	0x100	/* disable netpoll at run-time */
-#define IFF_MACVLAN_PORT	0x200	/* device used as macvlan port */
-#define IFF_BRIDGE_PORT	0x400		/* device used as bridge port */
-#define IFF_OVS_DATAPATH	0x800	/* device used as Open vSwitch
+#define IFF_DONT_BRIDGE 0x40		/* disallow bridging this ether dev */
+#define IFF_DISABLE_NETPOLL	0x80	/* disable netpoll at run-time */
+#define IFF_MACVLAN_PORT	0x100	/* device used as macvlan port */
+#define IFF_BRIDGE_PORT	0x200		/* device used as bridge port */
+#define IFF_OVS_DATAPATH	0x400	/* device used as Open vSwitch
 					 * datapath port */
=20
 #define IF_GET_IFACE	0x0001		/* for querying only */
--=20
1.7.4

