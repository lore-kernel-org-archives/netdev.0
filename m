From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 05/10] net/hsr: Move slave init to hsr_slave.c.
Date: Fri, 4 Jul 2014 23:37:27 +0200
Message-ID: <53B71E97.6030106@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:51022 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643AbaGDVpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also try to prevent some possible slave dereference race conditions. Th=
is is
finalized in the next patch, which abandons the slave array in favour o=
f
a list_head list and list RCU.

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c   | 192 ++++++++++++++---------------------------=
--------
 net/hsr/hsr_framereg.c |   6 +-
 net/hsr/hsr_main.c     |  24 ++++---
 net/hsr/hsr_netlink.c  |  53 ++++++++++----
 net/hsr/hsr_slave.c    |  91 +++++++++++++++++++++++
 net/hsr/hsr_slave.h    |   3 +
 6 files changed, 205 insertions(+), 164 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 8936b3c..1f8869c 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -15,7 +15,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
-#include <linux/if_arp.h>
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
 #include "hsr_device.h"
@@ -108,23 +107,27 @@ void hsr_check_carrier_and_operstate(struct hsr_p=
riv *hsr)
 	hsr_check_announce(hsr->dev, old_operstate);
 }
=20
-
 int hsr_get_max_mtu(struct hsr_priv *hsr)
 {
-	int mtu_max;
-
-	if (hsr->slave[0] && hsr->slave[1])
-		mtu_max =3D min(hsr->slave[0]->mtu, hsr->slave[1]->mtu);
-	else if (hsr->slave[0])
-		mtu_max =3D hsr->slave[0]->mtu;
-	else if (hsr->slave[1])
-		mtu_max =3D hsr->slave[1]->mtu;
-	else
-		mtu_max =3D HSR_HLEN;
-
+	unsigned int mtu_max;
+	struct net_device *slave;
+
+	mtu_max =3D ETH_DATA_LEN;
+	rcu_read_lock();
+	slave =3D hsr->slave[0];
+	if (slave)
+		mtu_max =3D min(slave->mtu, mtu_max);
+	slave =3D hsr->slave[1];
+	if (slave)
+		mtu_max =3D min(slave->mtu, mtu_max);
+	rcu_read_unlock();
+
+	if (mtu_max < HSR_HLEN)
+		return 0;
 	return mtu_max - HSR_HLEN;
 }
=20
+
 static int hsr_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct hsr_priv *hsr;
@@ -145,18 +148,20 @@ static int hsr_dev_change_mtu(struct net_device *=
dev, int new_mtu)
 static int hsr_dev_open(struct net_device *dev)
 {
 	struct hsr_priv *hsr;
+	struct net_device *slave;
 	int i;
 	char *slave_name;
=20
 	hsr =3D netdev_priv(dev);
=20
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		if (hsr->slave[i])
-			slave_name =3D hsr->slave[i]->name;
+		slave =3D hsr->slave[i];
+		if (slave)
+			slave_name =3D slave->name;
 		else
 			slave_name =3D "null";
=20
-		if (!is_slave_up(hsr->slave[i]))
+		if (!is_slave_up(slave))
 			netdev_warn(dev, "Slave %c (%s) is not up; please bring it up to ge=
t a working HSR network\n",
 				    'A' + i, slave_name);
 	}
@@ -223,6 +228,8 @@ static int slave_xmit(struct sk_buff *skb, struct h=
sr_priv *hsr,
 	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
=20
 	skb->dev =3D hsr->slave[dev_idx];
+	if (unlikely(!skb->dev))
+		return NET_XMIT_DROP;
=20
 	hsr_addr_subst_dest(hsr, &hsr_ethhdr->ethhdr, dev_idx);
=20
@@ -252,14 +259,8 @@ static int hsr_dev_xmit(struct sk_buff *skb, struc=
t net_device *dev)
 	}
=20
 	skb2 =3D pskb_copy(skb, GFP_ATOMIC);
-
-	res1 =3D NET_XMIT_DROP;
-	if (likely(hsr->slave[HSR_DEV_SLAVE_A]))
-		res1 =3D slave_xmit(skb, hsr, HSR_DEV_SLAVE_A);
-
-	res2 =3D NET_XMIT_DROP;
-	if (likely(skb2 && hsr->slave[HSR_DEV_SLAVE_B]))
-		res2 =3D slave_xmit(skb2, hsr, HSR_DEV_SLAVE_B);
+	res1 =3D slave_xmit(skb, hsr, HSR_DEV_SLAVE_A);
+	res2 =3D slave_xmit(skb2, hsr, HSR_DEV_SLAVE_B);
=20
 	if (likely(res1 =3D=3D NET_XMIT_SUCCESS || res1 =3D=3D NET_XMIT_CN ||
 		   res2 =3D=3D NET_XMIT_SUCCESS || res2 =3D=3D NET_XMIT_CN)) {
@@ -406,28 +407,10 @@ static void hsr_announce(unsigned long data)
 static void restore_slaves(struct net_device *hsr_dev)
 {
 	struct hsr_priv *hsr;
-	int i;
-	int res;
=20
 	hsr =3D netdev_priv(hsr_dev);
-
-	rtnl_lock();
-
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		if (!hsr->slave[i])
-			continue;
-		res =3D dev_set_promiscuity(hsr->slave[i], -1);
-		if (res)
-			netdev_info(hsr_dev,
-				    "Cannot restore slave promiscuity (%s, %d)\n",
-				    hsr->slave[i]->name, res);
-
-		if (hsr->slave[i]->rx_handler =3D=3D hsr_handle_frame)
-			netdev_rx_handler_unregister(hsr->slave[i]);
-	}
-
-
-	rtnl_unlock();
+	hsr_del_slave(hsr, 1);
+	hsr_del_slave(hsr, 0);
 }
=20
 static void reclaim_hsr_dev(struct rcu_head *rh)
@@ -483,38 +466,6 @@ bool is_hsr_master(struct net_device *dev)
 	return (dev->netdev_ops->ndo_start_xmit =3D=3D hsr_dev_xmit);
 }
=20
-static int check_slave_ok(struct net_device *dev)
-{
-	/* Don't allow HSR on non-ethernet like devices */
-	if ((dev->flags & IFF_LOOPBACK) || (dev->type !=3D ARPHRD_ETHER) ||
-	    (dev->addr_len !=3D ETH_ALEN)) {
-		netdev_info(dev, "Cannot use loopback or non-ethernet device as HSR =
slave.\n");
-		return -EINVAL;
-	}
-
-	/* Don't allow enslaving hsr devices */
-	if (is_hsr_master(dev)) {
-		netdev_info(dev, "Cannot create trees of HSR devices.\n");
-		return -EINVAL;
-	}
-
-	if (is_hsr_slave(dev)) {
-		netdev_info(dev, "This device is already a HSR slave.\n");
-		return -EINVAL;
-	}
-
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
-		netdev_info(dev, "HSR on top of VLAN is not yet supported in this dr=
iver.\n");
-		return -EINVAL;
-	}
-
-	/* HSR over bonded devices has not been tested, but I'm not sure it
-	 * won't work...
-	 */
-
-	return 0;
-}
-
=20
 /* Default multicast address for HSR Supervision frames */
 static const unsigned char def_multicast_addr[ETH_ALEN] __aligned(2) =3D=
 {
@@ -525,15 +476,30 @@ int hsr_dev_finalize(struct net_device *hsr_dev, =
struct net_device *slave[2],
 		     unsigned char multicast_spec)
 {
 	struct hsr_priv *hsr;
-	int i;
 	int res;
=20
 	hsr =3D netdev_priv(hsr_dev);
 	hsr->dev =3D hsr_dev;
+	hsr->slave[0] =3D NULL;
+	hsr->slave[1] =3D NULL;
 	INIT_LIST_HEAD(&hsr->node_db);
 	INIT_LIST_HEAD(&hsr->self_node_db);
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
-		hsr->slave[i] =3D slave[i];
+
+	ether_addr_copy(hsr_dev->dev_addr, slave[0]->dev_addr);
+
+	/* Make sure we recognize frames from ourselves in hsr_rcv() */
+	res =3D hsr_create_self_node(&hsr->self_node_db, hsr_dev->dev_addr,
+				   slave[1]->dev_addr);
+	if (res < 0)
+		return res;
+
+	hsr_dev->features =3D slave[0]->features & slave[1]->features;
+	/* Prevent recursive tx locking */
+	hsr_dev->features |=3D NETIF_F_LLTX;
+	/* VLAN on top of HSR needs testing and probably some work on
+	 * hsr_header_create() etc.
+	 */
+	hsr_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
=20
 	spin_lock_init(&hsr->seqnr_lock);
 	/* Overflow soon to find bugs easier: */
@@ -560,65 +526,21 @@ int hsr_dev_finalize(struct net_device *hsr_dev, =
struct net_device *slave[2],
  *			IFF_HSR_MASTER/SLAVE?
  */
=20
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		res =3D check_slave_ok(slave[i]);
-		if (res)
-			return res;
-	}
-
-	hsr_dev->features =3D slave[0]->features & slave[1]->features;
-	/* Prevent recursive tx locking */
-	hsr_dev->features |=3D NETIF_F_LLTX;
-	/* VLAN on top of HSR needs testing and probably some work on
-	 * hsr_header_create() etc.
-	 */
-	hsr_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
-
-	/* Set hsr_dev's MAC address to that of mac_slave1 */
-	ether_addr_copy(hsr_dev->dev_addr, hsr->slave[0]->dev_addr);
-
-	/* Set required header length */
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		if (slave[i]->hard_header_len + HSR_HLEN >
-						hsr_dev->hard_header_len)
-			hsr_dev->hard_header_len =3D
-					slave[i]->hard_header_len + HSR_HLEN;
-	}
-
-	/* MTU */
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
-		if (slave[i]->mtu - HSR_HLEN < hsr_dev->mtu)
-			hsr_dev->mtu =3D slave[i]->mtu - HSR_HLEN;
-
 	/* Make sure the 1st call to netif_carrier_on() gets through */
 	netif_carrier_off(hsr_dev);
=20
-	/* Promiscuity */
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		res =3D dev_set_promiscuity(slave[i], 1);
-		if (res) {
-			netdev_info(hsr_dev, "Cannot set slave promiscuity (%s, %d)\n",
-				    slave[i]->name, res);
-			goto fail;
-		}
-	}
-
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		res =3D netdev_rx_handler_register(slave[i], hsr_handle_frame,
-						 hsr);
-		if (res)
-			goto fail;
-	}
-
-	/* Make sure we recognize frames from ourselves in hsr_rcv() */
-	res =3D hsr_create_self_node(&hsr->self_node_db, hsr_dev->dev_addr,
-				   hsr->slave[1]->dev_addr);
-	if (res < 0)
-		goto fail;
-
 	res =3D register_netdevice(hsr_dev);
 	if (res)
-		goto fail;
+		return res;
+
+	res =3D hsr_add_slave(hsr, slave[0], 0);
+	if (res)
+		return res;
+	res =3D hsr_add_slave(hsr, slave[1], 1);
+	if (res) {
+		hsr_del_slave(hsr, 0);
+		return res;
+	}
=20
 	hsr->prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD)=
;
 	add_timer(&hsr->prune_timer);
@@ -626,8 +548,4 @@ int hsr_dev_finalize(struct net_device *hsr_dev, st=
ruct net_device *slave[2],
 	register_hsr_master(hsr);
=20
 	return 0;
-
-fail:
-	restore_slaves(hsr_dev);
-	return res;
 }
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 79e3f7f..3666f94 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -455,6 +455,7 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 		      u16 *if2_seq)
 {
 	struct hsr_node *node;
+	struct net_device *slave;
 	unsigned long tdiff;
=20
=20
@@ -491,8 +492,9 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 	*if1_seq =3D node->seq_out[HSR_DEV_SLAVE_B];
 	*if2_seq =3D node->seq_out[HSR_DEV_SLAVE_A];
=20
-	if ((node->AddrB_if !=3D HSR_DEV_NONE) && hsr->slave[node->AddrB_if])
-		*addr_b_ifindex =3D hsr->slave[node->AddrB_if]->ifindex;
+	slave =3D hsr->slave[node->AddrB_if];
+	if ((node->AddrB_if !=3D HSR_DEV_NONE) && slave)
+		*addr_b_ifindex =3D slave->ifindex;
 	else
 		*addr_b_ifindex =3D -1;
=20
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 431b528..b5abe26 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -17,6 +17,7 @@
 #include "hsr_device.h"
 #include "hsr_netlink.h"
 #include "hsr_framereg.h"
+#include "hsr_slave.h"
=20
=20
 /* List of all registered virtual HSR devices */
@@ -124,22 +125,21 @@ static int hsr_netdev_notify(struct notifier_bloc=
k *nb, unsigned long event,
 		if (dev =3D=3D hsr->dev)
 			break;
=20
-		if (dev =3D=3D hsr->slave[0])
-			ether_addr_copy(hsr->dev->dev_addr,
-					hsr->slave[0]->dev_addr);
+		if (dev =3D=3D hsr->slave[0]) {
+			ether_addr_copy(hsr->dev->dev_addr, dev->dev_addr);
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr->dev);
+		}
=20
 		/* Make sure we recognize frames from ourselves in hsr_rcv() */
+		other_slave =3D hsr->slave[1];
 		res =3D hsr_create_self_node(&hsr->self_node_db,
 					   hsr->dev->dev_addr,
-					   hsr->slave[1] ?
-						hsr->slave[1]->dev_addr :
+					   other_slave ?
+						other_slave->dev_addr :
 						hsr->dev->dev_addr);
 		if (res)
 			netdev_warn(hsr->dev,
 				    "Could not update HSR node address.\n");
-
-		if (dev =3D=3D hsr->slave[0])
-			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr->dev);
 		break;
 	case NETDEV_CHANGEMTU:
 		if (dev =3D=3D hsr->dev)
@@ -149,10 +149,14 @@ static int hsr_netdev_notify(struct notifier_bloc=
k *nb, unsigned long event,
 			dev_set_mtu(hsr->dev, mtu_max);
 		break;
 	case NETDEV_UNREGISTER:
-		if (dev =3D=3D hsr->slave[0])
+		if (dev =3D=3D hsr->slave[0]) {
 			hsr->slave[0] =3D NULL;
-		if (dev =3D=3D hsr->slave[1])
+			hsr_del_slave(hsr, 0);
+		}
+		if (dev =3D=3D hsr->slave[1]) {
 			hsr->slave[1] =3D NULL;
+			hsr_del_slave(hsr, 1);
+		}
=20
 		/* There should really be a way to set a new slave device... */
=20
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index bea250e..a2ce359 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -64,16 +64,28 @@ static int hsr_newlink(struct net *src_net, struct =
net_device *dev,
 static int hsr_fill_info(struct sk_buff *skb, const struct net_device =
*dev)
 {
 	struct hsr_priv *hsr;
+	struct net_device *slave;
+	int res;
=20
 	hsr =3D netdev_priv(dev);
=20
-	if (hsr->slave[0])
-		if (nla_put_u32(skb, IFLA_HSR_SLAVE1, hsr->slave[0]->ifindex))
-			goto nla_put_failure;
+	res =3D 0;
=20
-	if (hsr->slave[1])
-		if (nla_put_u32(skb, IFLA_HSR_SLAVE2, hsr->slave[1]->ifindex))
-			goto nla_put_failure;
+	rcu_read_lock();
+	slave =3D hsr->slave[0];
+	if (slave)
+		res =3D nla_put_u32(skb, IFLA_HSR_SLAVE1, slave->ifindex);
+	rcu_read_unlock();
+	if (res)
+		goto nla_put_failure;
+
+	rcu_read_lock();
+	slave =3D hsr->slave[1];
+	if (slave)
+		res =3D nla_put_u32(skb, IFLA_HSR_SLAVE2, slave->ifindex);
+	rcu_read_unlock();
+	if (res)
+		goto nla_put_failure;
=20
 	if (nla_put(skb, IFLA_HSR_SUPERVISION_ADDR, ETH_ALEN,
 		    hsr->sup_multicast_addr) ||
@@ -132,6 +144,7 @@ void hsr_nl_ringerror(struct hsr_priv *hsr, unsigne=
d char addr[ETH_ALEN],
 		      enum hsr_dev_idx dev_idx)
 {
 	struct sk_buff *skb;
+	struct net_device *slave;
 	void *msg_head;
 	int res;
 	int ifindex;
@@ -148,10 +161,14 @@ void hsr_nl_ringerror(struct hsr_priv *hsr, unsig=
ned char addr[ETH_ALEN],
 	if (res < 0)
 		goto nla_put_failure;
=20
-	if (hsr->slave[dev_idx])
-		ifindex =3D hsr->slave[dev_idx]->ifindex;
+	rcu_read_lock();
+	slave =3D hsr->slave[dev_idx];
+	if (slave)
+		ifindex =3D slave->ifindex;
 	else
 		ifindex =3D -1;
+	rcu_read_unlock();
+
 	res =3D nla_put_u32(skb, HSR_A_IFINDEX, ifindex);
 	if (res < 0)
 		goto nla_put_failure;
@@ -215,7 +232,7 @@ static int hsr_get_node_status(struct sk_buff *skb_=
in, struct genl_info *info)
 {
 	/* For receiving */
 	struct nlattr *na;
-	struct net_device *hsr_dev;
+	struct net_device *hsr_dev, *slave;
=20
 	/* For sending */
 	struct sk_buff *skb_out;
@@ -301,9 +318,11 @@ static int hsr_get_node_status(struct sk_buff *skb=
_in, struct genl_info *info)
 	res =3D nla_put_u16(skb_out, HSR_A_IF1_SEQ, hsr_node_if1_seq);
 	if (res < 0)
 		goto nla_put_failure;
-	if (hsr->slave[0])
-		res =3D nla_put_u32(skb_out, HSR_A_IF1_IFINDEX,
-						hsr->slave[0]->ifindex);
+	rcu_read_lock();
+	slave =3D hsr->slave[0];
+	if (slave)
+		res =3D nla_put_u32(skb_out, HSR_A_IF1_IFINDEX, slave->ifindex);
+	rcu_read_unlock();
 	if (res < 0)
 		goto nla_put_failure;
=20
@@ -313,9 +332,13 @@ static int hsr_get_node_status(struct sk_buff *skb=
_in, struct genl_info *info)
 	res =3D nla_put_u16(skb_out, HSR_A_IF2_SEQ, hsr_node_if2_seq);
 	if (res < 0)
 		goto nla_put_failure;
-	if (hsr->slave[1])
-		res =3D nla_put_u32(skb_out, HSR_A_IF2_IFINDEX,
-						hsr->slave[1]->ifindex);
+	rcu_read_lock();
+	slave =3D hsr->slave[1];
+	if (slave)
+		res =3D nla_put_u32(skb_out, HSR_A_IF2_IFINDEX, slave->ifindex);
+	rcu_read_unlock();
+	if (res < 0)
+		goto nla_put_failure;
=20
 	genlmsg_end(skb_out, msg_head);
 	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid);
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index 7028146..d676090 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -11,10 +11,45 @@
=20
 #include "hsr_slave.h"
 #include <linux/etherdevice.h>
+#include <linux/if_arp.h>
 #include "hsr_main.h"
+#include "hsr_device.h"
 #include "hsr_framereg.h"
=20
=20
+static int check_slave_ok(struct net_device *dev)
+{
+	/* Don't allow HSR on non-ethernet like devices */
+	if ((dev->flags & IFF_LOOPBACK) || (dev->type !=3D ARPHRD_ETHER) ||
+	    (dev->addr_len !=3D ETH_ALEN)) {
+		netdev_info(dev, "Cannot use loopback or non-ethernet device as HSR =
slave.\n");
+		return -EINVAL;
+	}
+
+	/* Don't allow enslaving hsr devices */
+	if (is_hsr_master(dev)) {
+		netdev_info(dev, "Cannot create trees of HSR devices.\n");
+		return -EINVAL;
+	}
+
+	if (is_hsr_slave(dev)) {
+		netdev_info(dev, "This device is already a HSR slave.\n");
+		return -EINVAL;
+	}
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		netdev_info(dev, "HSR on top of VLAN is not yet supported in this dr=
iver.\n");
+		return -EINVAL;
+	}
+
+	/* HSR over bonded devices has not been tested, but I'm not sure it
+	 * won't work...
+	 */
+
+	return 0;
+}
+
+
 static struct sk_buff *hsr_pull_tag(struct sk_buff *skb)
 {
 	struct hsr_tag *hsr_tag;
@@ -241,3 +276,59 @@ forward:
=20
 	return RX_HANDLER_CONSUMED;
 }
+
+int hsr_add_slave(struct hsr_priv *hsr, struct net_device *dev, int id=
x)
+{
+	int res;
+
+	dev_hold(dev);
+
+	res =3D check_slave_ok(dev);
+	if (res)
+		goto fail;
+
+	res =3D dev_set_promiscuity(dev, 1);
+	if (res)
+		goto fail;
+
+	res =3D netdev_rx_handler_register(dev, hsr_handle_frame, hsr);
+	if (res)
+		goto fail_rx_handler;
+
+
+	hsr->slave[idx] =3D dev;
+
+	/* Set required header length */
+	if (dev->hard_header_len + HSR_HLEN > hsr->dev->hard_header_len)
+		hsr->dev->hard_header_len =3D dev->hard_header_len + HSR_HLEN;
+
+	dev_set_mtu(hsr->dev, hsr_get_max_mtu(hsr));
+
+	return 0;
+
+fail_rx_handler:
+	dev_set_promiscuity(dev, -1);
+
+fail:
+	dev_put(dev);
+	return res;
+}
+
+void hsr_del_slave(struct hsr_priv *hsr, int idx)
+{
+	struct net_device *slave;
+
+	slave =3D hsr->slave[idx];
+	hsr->slave[idx] =3D NULL;
+
+	netdev_update_features(hsr->dev);
+	dev_set_mtu(hsr->dev, hsr_get_max_mtu(hsr));
+
+	if (slave) {
+		netdev_rx_handler_unregister(slave);
+		dev_set_promiscuity(slave, -1);
+	}
+
+	synchronize_rcu();
+	dev_put(slave);
+}
diff --git a/net/hsr/hsr_slave.h b/net/hsr/hsr_slave.h
index ae90c8d..03c15fd 100644
--- a/net/hsr/hsr_slave.h
+++ b/net/hsr/hsr_slave.h
@@ -14,7 +14,10 @@
=20
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include "hsr_main.h"
=20
+int hsr_add_slave(struct hsr_priv *hsr, struct net_device *dev, int id=
x);
+void hsr_del_slave(struct hsr_priv *hsr, int idx);
 rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb);
=20
 #endif /* __HSR_SLAVE_H */
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
