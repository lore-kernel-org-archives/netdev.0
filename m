From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 4/6] bonding: wrap slave state work
Date: Sat, 12 Mar 2011 14:14:37 +0100
Message-ID: <1299935679-18135-5-git-send-email-jpirko@redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab1CLNPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:15:06 -0500
In-Reply-To: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

transfers slave->state into slave->backup (that it's going to transfer
into bitfield. Introduce wrapper inlines to do the work with it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_3ad.c   |    2 +-
 drivers/net/bonding/bond_main.c  |   36 ++++++++++++++++++------------=
------
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/bonding/bonding.h    |   31 ++++++++++++++++++++++++++----=
-
 4 files changed, 46 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_=
3ad.c
index 1024ae1..047af0b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -246,7 +246,7 @@ static inline void __enable_port(struct port *port)
  */
 static inline int __port_is_enabled(struct port *port)
 {
-	return port->slave->state =3D=3D BOND_STATE_ACTIVE;
+	return bond_is_active_slave(port->slave);
 }
=20
 /**
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 3c6ac2f..c5f3a01 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1863,7 +1863,7 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		new_slave->state =3D BOND_STATE_ACTIVE;
+		bond_set_active_slave(new_slave);
 		bond_set_slave_inactive_flags(new_slave);
 		bond_select_active_slave(bond);
 		break;
@@ -1871,7 +1871,7 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 		pr_debug("This slave is always active in trunk mode\n");
=20
 		/* always active in trunk mode */
-		new_slave->state =3D BOND_STATE_ACTIVE;
+		bond_set_active_slave(new_slave);
=20
 		/* In trunking mode there is little meaning to curr_active_slave
 		 * anyway (it holds no special properties of the bond device),
@@ -1909,7 +1909,7 @@ int bond_enslave(struct net_device *bond_dev, str=
uct net_device *slave_dev)
=20
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
 		bond_dev->name, slave_dev->name,
-		new_slave->state =3D=3D BOND_STATE_ACTIVE ? "n active" : " backup",
+		bond_is_active_slave(new_slave) ? "n active" : " backup",
 		new_slave->link !=3D BOND_LINK_DOWN ? "n up" : " down");
=20
 	/* enslave is successful */
@@ -2007,7 +2007,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
=20
 	pr_info("%s: releasing %s interface %s\n",
 		bond_dev->name,
-		(slave->state =3D=3D BOND_STATE_ACTIVE) ? "active" : "backup",
+		bond_is_active_slave(slave) ? "active" : "backup",
 		slave_dev->name);
=20
 	oldcurrent =3D bond->curr_active_slave;
@@ -2348,7 +2348,7 @@ static int bond_slave_info_query(struct net_devic=
e *bond_dev, struct ifslave *in
 			res =3D 0;
 			strcpy(info->slave_name, slave->dev->name);
 			info->link =3D slave->link;
-			info->state =3D slave->state;
+			info->state =3D bond_slave_state(slave);
 			info->link_failure_count =3D slave->link_failure_count;
 			break;
 		}
@@ -2387,7 +2387,7 @@ static int bond_miimon_inspect(struct bonding *bo=
nd)
 					bond->dev->name,
 					(bond->params.mode =3D=3D
 					 BOND_MODE_ACTIVEBACKUP) ?
-					((slave->state =3D=3D BOND_STATE_ACTIVE) ?
+					(bond_is_active_slave(slave) ?
 					 "active " : "backup ") : "",
 					slave->dev->name,
 					bond->params.downdelay * bond->params.miimon);
@@ -2478,13 +2478,13 @@ static void bond_miimon_commit(struct bonding *=
bond)
=20
 			if (bond->params.mode =3D=3D BOND_MODE_8023AD) {
 				/* prevent it from being the active one */
-				slave->state =3D BOND_STATE_BACKUP;
+				bond_set_backup_slave(slave);
 			} else if (bond->params.mode !=3D BOND_MODE_ACTIVEBACKUP) {
 				/* make it immediately active */
-				slave->state =3D BOND_STATE_ACTIVE;
+				bond_set_active_slave(slave);
 			} else if (slave !=3D bond->primary_slave) {
 				/* prevent it from being the active one */
-				slave->state =3D BOND_STATE_BACKUP;
+				bond_set_backup_slave(slave);
 			}
=20
 			bond_update_speed_duplex(slave);
@@ -2862,7 +2862,7 @@ static int bond_arp_rcv(struct sk_buff *skb, stru=
ct net_device *dev, struct pack
 	memcpy(&tip, arp_ptr, 4);
=20
 	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
-		 bond->dev->name, slave->dev->name, slave->state,
+		 bond->dev->name, slave->dev->name, bond_slave_state(slave),
 		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
 		 &sip, &tip);
=20
@@ -2874,7 +2874,7 @@ static int bond_arp_rcv(struct sk_buff *skb, stru=
ct net_device *dev, struct pack
 	 * the active, through one switch, the router, then the other
 	 * switch before reaching the backup.
 	 */
-	if (slave->state =3D=3D BOND_STATE_ACTIVE)
+	if (bond_is_active_slave(slave))
 		bond_validate_arp(bond, slave, sip, tip);
 	else
 		bond_validate_arp(bond, slave, tip, sip);
@@ -2936,7 +2936,7 @@ void bond_loadbalance_arp_mon(struct work_struct =
*work)
 				slave->dev->last_rx + delta_in_ticks)) {
=20
 				slave->link  =3D BOND_LINK_UP;
-				slave->state =3D BOND_STATE_ACTIVE;
+				bond_set_active_slave(slave);
=20
 				/* primary_slave has no meaning in round-robin
 				 * mode. the window of a slave being up and
@@ -2969,7 +2969,7 @@ void bond_loadbalance_arp_mon(struct work_struct =
*work)
 				slave->dev->last_rx + 2 * delta_in_ticks)) {
=20
 				slave->link  =3D BOND_LINK_DOWN;
-				slave->state =3D BOND_STATE_BACKUP;
+				bond_set_backup_slave(slave);
=20
 				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
@@ -3063,7 +3063,7 @@ static int bond_ab_arp_inspect(struct bonding *bo=
nd, int delta_in_ticks)
 		 * gives each slave a chance to tx/rx traffic
 		 * before being taken out
 		 */
-		if (slave->state =3D=3D BOND_STATE_BACKUP &&
+		if (!bond_is_active_slave(slave) &&
 		    !bond->current_arp_slave &&
 		    !time_in_range(jiffies,
 			slave_last_rx(bond, slave) - delta_in_ticks,
@@ -3080,7 +3080,7 @@ static int bond_ab_arp_inspect(struct bonding *bo=
nd, int delta_in_ticks)
 		 *    the bond has an IP address)
 		 */
 		trans_start =3D dev_trans_start(slave->dev);
-		if ((slave->state =3D=3D BOND_STATE_ACTIVE) &&
+		if (bond_is_active_slave(slave) &&
 		    (!time_in_range(jiffies,
 			trans_start - delta_in_ticks,
 			trans_start + 2 * delta_in_ticks) ||
@@ -4144,7 +4144,7 @@ static int bond_xmit_roundrobin(struct sk_buff *s=
kb, struct net_device *bond_dev
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link =3D=3D BOND_LINK_UP) &&
-		    (slave->state =3D=3D BOND_STATE_ACTIVE)) {
+		    bond_is_active_slave(slave)) {
 			res =3D bond_dev_queue_xmit(bond, skb, slave->dev);
 			break;
 		}
@@ -4221,7 +4221,7 @@ static int bond_xmit_xor(struct sk_buff *skb, str=
uct net_device *bond_dev)
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link =3D=3D BOND_LINK_UP) &&
-		    (slave->state =3D=3D BOND_STATE_ACTIVE)) {
+		    bond_is_active_slave(slave)) {
 			res =3D bond_dev_queue_xmit(bond, skb, slave->dev);
 			break;
 		}
@@ -4262,7 +4262,7 @@ static int bond_xmit_broadcast(struct sk_buff *sk=
b, struct net_device *bond_dev)
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link =3D=3D BOND_LINK_UP) &&
-		    (slave->state =3D=3D BOND_STATE_ACTIVE)) {
+		    bond_is_active_slave(slave)) {
 			if (tx_dev) {
 				struct sk_buff *skb2 =3D skb_clone(skb, GFP_ATOMIC);
 				if (!skb2) {
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index 05e0ae5..344d23f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1579,7 +1579,7 @@ static ssize_t bonding_store_slaves_active(struct=
 device *d,
 	}
=20
 	bond_for_each_slave(bond, slave, i) {
-		if (slave->state =3D=3D BOND_STATE_BACKUP) {
+		if (!bond_is_active_slave(slave)) {
 			if (new_value)
 				slave->dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
 			else
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 049619f..63e9cf7 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -55,7 +55,7 @@
 		    (((slave)->dev->flags & IFF_UP)  && \
 		     netif_running((slave)->dev)     && \
 		     ((slave)->link =3D=3D BOND_LINK_UP) && \
-		     ((slave)->state =3D=3D BOND_STATE_ACTIVE))
+		     bond_is_active_slave(slave))
=20
=20
 #define USES_PRIMARY(mode)				\
@@ -192,7 +192,8 @@ struct slave {
 	unsigned long last_arp_rx;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     new_link;
-	s8     state;   /* one of BOND_STATE_XXXX */
+	u8     backup;	/* indicates backup slave. Value corresponds with
+			   BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
 	u32    original_mtu;
 	u32    link_failure_count;
 	u8     perm_hwaddr[ETH_ALEN];
@@ -304,6 +305,26 @@ static inline bool bond_is_lb(const struct bonding=
 *bond)
 		bond->params.mode =3D=3D BOND_MODE_ALB);
 }
=20
+static inline void bond_set_active_slave(struct slave *slave)
+{
+	slave->backup =3D 0;
+}
+
+static inline void bond_set_backup_slave(struct slave *slave)
+{
+	slave->backup =3D 1;
+}
+
+static inline int bond_slave_state(struct slave *slave)
+{
+	return slave->backup;
+}
+
+static inline bool bond_is_active_slave(struct slave *slave)
+{
+	return !bond_slave_state(slave);
+}
+
 #define BOND_PRI_RESELECT_ALWAYS	0
 #define BOND_PRI_RESELECT_BETTER	1
 #define BOND_PRI_RESELECT_FAILURE	2
@@ -321,7 +342,7 @@ static inline bool bond_is_lb(const struct bonding =
*bond)
 static inline int slave_do_arp_validate(struct bonding *bond,
 					struct slave *slave)
 {
-	return bond->params.arp_validate & (1 << slave->state);
+	return bond->params.arp_validate & (1 << bond_slave_state(slave));
 }
=20
 static inline unsigned long slave_last_rx(struct bonding *bond,
@@ -353,14 +374,14 @@ static inline void bond_set_slave_inactive_flags(=
struct slave *slave)
 {
 	struct bonding *bond =3D netdev_priv(slave->dev->master);
 	if (!bond_is_lb(bond))
-		slave->state =3D BOND_STATE_BACKUP;
+		bond_set_backup_slave(slave);
 	if (!bond->params.all_slaves_active)
 		slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
 }
=20
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
-	slave->state =3D BOND_STATE_ACTIVE;
+	bond_set_active_slave(slave);
 	slave->dev->priv_flags &=3D ~IFF_SLAVE_INACTIVE;
 }
=20
--=20
1.7.4

