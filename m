From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 06/10] net/hsr: Use list_head (and rcu) instead of
 array for slave devices.
Date: Fri, 4 Jul 2014 23:38:05 +0200
Message-ID: <53B71EBD.3070002@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:51408 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557AbaGDVpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c   | 242 +++++++++++++++++++++++++++--------------=
--------
 net/hsr/hsr_framereg.c | 142 +++++++++++++----------------
 net/hsr/hsr_framereg.h |  12 +--
 net/hsr/hsr_main.c     | 128 ++++++++------------------
 net/hsr/hsr_main.h     |  31 ++++---
 net/hsr/hsr_netlink.c  |  57 ++++++------
 net/hsr/hsr_netlink.h  |   3 +-
 net/hsr/hsr_slave.c    | 199 ++++++++++++++++++++++++----------------
 net/hsr/hsr_slave.h    |  29 +++++-
 9 files changed, 438 insertions(+), 405 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 1f8869c..1fc4ea2 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -45,29 +45,38 @@ static void __hsr_set_operstate(struct net_device *=
dev, int transition)
 	}
 }
=20
-static void hsr_set_operstate(struct net_device *hsr_dev, bool has_car=
rier)
+static void hsr_set_operstate(struct hsr_port *master, bool has_carrie=
r)
 {
-	if (!is_admin_up(hsr_dev)) {
-		__hsr_set_operstate(hsr_dev, IF_OPER_DOWN);
+	if (!is_admin_up(master->dev)) {
+		__hsr_set_operstate(master->dev, IF_OPER_DOWN);
 		return;
 	}
=20
 	if (has_carrier)
-		__hsr_set_operstate(hsr_dev, IF_OPER_UP);
+		__hsr_set_operstate(master->dev, IF_OPER_UP);
 	else
-		__hsr_set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
+		__hsr_set_operstate(master->dev, IF_OPER_LOWERLAYERDOWN);
 }
=20
-static bool hsr_check_carrier(struct hsr_priv *hsr)
+static bool hsr_check_carrier(struct hsr_port *master)
 {
+	struct hsr_port *port;
 	bool has_carrier;
=20
-	has_carrier =3D (is_slave_up(hsr->slave[0]) || is_slave_up(hsr->slave=
[1]));
+	has_carrier =3D false;
+
+	rcu_read_lock();
+	hsr_for_each_port(master->hsr, port)
+		if ((port->type !=3D HSR_PT_MASTER) && is_slave_up(port->dev)) {
+			has_carrier =3D true;
+			break;
+		}
+	rcu_read_unlock();
=20
 	if (has_carrier)
-		netif_carrier_on(hsr->dev);
+		netif_carrier_on(master->dev);
 	else
-		netif_carrier_off(hsr->dev);
+		netif_carrier_off(master->dev);
=20
 	return has_carrier;
 }
@@ -95,31 +104,30 @@ static void hsr_check_announce(struct net_device *=
hsr_dev,
=20
 void hsr_check_carrier_and_operstate(struct hsr_priv *hsr)
 {
+	struct hsr_port *master;
 	unsigned char old_operstate;
 	bool has_carrier;
=20
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
 	/* netif_stacked_transfer_operstate() cannot be used here since
 	 * it doesn't set IF_OPER_LOWERLAYERDOWN (?)
 	 */
-	old_operstate =3D hsr->dev->operstate;
-	has_carrier =3D hsr_check_carrier(hsr);
-	hsr_set_operstate(hsr->dev, has_carrier);
-	hsr_check_announce(hsr->dev, old_operstate);
+	old_operstate =3D master->dev->operstate;
+	has_carrier =3D hsr_check_carrier(master);
+	hsr_set_operstate(master, has_carrier);
+	hsr_check_announce(master->dev, old_operstate);
 }
=20
 int hsr_get_max_mtu(struct hsr_priv *hsr)
 {
 	unsigned int mtu_max;
-	struct net_device *slave;
+	struct hsr_port *port;
=20
 	mtu_max =3D ETH_DATA_LEN;
 	rcu_read_lock();
-	slave =3D hsr->slave[0];
-	if (slave)
-		mtu_max =3D min(slave->mtu, mtu_max);
-	slave =3D hsr->slave[1];
-	if (slave)
-		mtu_max =3D min(slave->mtu, mtu_max);
+	hsr_for_each_port(hsr, port)
+		if (port->type !=3D HSR_PT_MASTER)
+			mtu_max =3D min(port->dev->mtu, mtu_max);
 	rcu_read_unlock();
=20
 	if (mtu_max < HSR_HLEN)
@@ -131,11 +139,13 @@ int hsr_get_max_mtu(struct hsr_priv *hsr)
 static int hsr_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct hsr_priv *hsr;
+	struct hsr_port *master;
=20
 	hsr =3D netdev_priv(dev);
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
=20
 	if (new_mtu > hsr_get_max_mtu(hsr)) {
-		netdev_info(hsr->dev, "A HSR master's MTU cannot be greater than the=
 smallest MTU of its slaves minus the HSR Tag length (%d octets).\n",
+		netdev_info(master->dev, "A HSR master's MTU cannot be greater than =
the smallest MTU of its slaves minus the HSR Tag length (%d octets).\n"=
,
 			    HSR_HLEN);
 		return -EINVAL;
 	}
@@ -148,35 +158,42 @@ static int hsr_dev_change_mtu(struct net_device *=
dev, int new_mtu)
 static int hsr_dev_open(struct net_device *dev)
 {
 	struct hsr_priv *hsr;
-	struct net_device *slave;
-	int i;
-	char *slave_name;
+	struct hsr_port *port;
+	char designation;
=20
 	hsr =3D netdev_priv(dev);
+	designation =3D '\0';
=20
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		slave =3D hsr->slave[i];
-		if (slave)
-			slave_name =3D slave->name;
-		else
-			slave_name =3D "null";
-
-		if (!is_slave_up(slave))
-			netdev_warn(dev, "Slave %c (%s) is not up; please bring it up to ge=
t a working HSR network\n",
-				    'A' + i, slave_name);
+	rcu_read_lock();
+	hsr_for_each_port(hsr, port) {
+		if (port->type =3D=3D HSR_PT_MASTER)
+			continue;
+		switch (port->type) {
+		case HSR_PT_SLAVE_A:
+			designation =3D 'A';
+			break;
+		case HSR_PT_SLAVE_B:
+			designation =3D 'B';
+			break;
+		default:
+			designation =3D '?';
+		}
+		if (!is_slave_up(port->dev))
+			netdev_warn(dev, "Slave %c (%s) is not up; please bring it up to ge=
t a fully working HSR network\n",
+				    designation, port->dev->name);
 	}
+	rcu_read_unlock();
+
+	if (designation =3D=3D '\0')
+		netdev_warn(dev, "No slave devices configured\n");
=20
 	return 0;
 }
=20
+
 static int hsr_dev_close(struct net_device *dev)
 {
-	/* Nothing to do here. We could try to restore the state of the slave=
s
-	 * to what they were before being changed by the hsr master dev's sta=
te,
-	 * but they might have been changed manually in the mean time too, so
-	 * taking them up or down here might be confusing and is probably not=
 a
-	 * good idea.
-	 */
+	/* Nothing to do here. */
 	return 0;
 }
=20
@@ -220,18 +237,24 @@ static void hsr_fill_tag(struct hsr_ethhdr *hsr_e=
thhdr, struct hsr_priv *hsr)
 	hsr_ethhdr->ethhdr.h_proto =3D htons(ETH_P_PRP);
 }
=20
-static int slave_xmit(struct sk_buff *skb, struct hsr_priv *hsr,
-		      enum hsr_dev_idx dev_idx)
+static int slave_xmit(struct hsr_priv *hsr, struct sk_buff *skb,
+		      enum hsr_port_type type)
 {
+	struct hsr_port *port;
 	struct hsr_ethhdr *hsr_ethhdr;
=20
 	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
=20
-	skb->dev =3D hsr->slave[dev_idx];
-	if (unlikely(!skb->dev))
+	rcu_read_lock();
+	port =3D hsr_port_get_hsr(hsr, type);
+	if (!port) {
+		rcu_read_unlock();
 		return NET_XMIT_DROP;
+	}
+	skb->dev =3D port->dev;
=20
-	hsr_addr_subst_dest(hsr, &hsr_ethhdr->ethhdr, dev_idx);
+	hsr_addr_subst_dest(port->hsr, &hsr_ethhdr->ethhdr, port);
+	rcu_read_unlock();
=20
 	/* Address substitution (IEC62439-3 pp 26, 50): replace mac
 	 * address of outgoing frame with that of the outgoing slave's.
@@ -241,10 +264,10 @@ static int slave_xmit(struct sk_buff *skb, struct=
 hsr_priv *hsr,
 	return dev_queue_xmit(skb);
 }
=20
-
 static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct hsr_priv *hsr;
+	struct hsr_port *master;
 	struct hsr_ethhdr *hsr_ethhdr;
 	struct sk_buff *skb2;
 	int res1, res2;
@@ -259,16 +282,23 @@ static int hsr_dev_xmit(struct sk_buff *skb, stru=
ct net_device *dev)
 	}
=20
 	skb2 =3D pskb_copy(skb, GFP_ATOMIC);
-	res1 =3D slave_xmit(skb, hsr, HSR_DEV_SLAVE_A);
-	res2 =3D slave_xmit(skb2, hsr, HSR_DEV_SLAVE_B);
=20
+	res1 =3D slave_xmit(hsr, skb, HSR_PT_SLAVE_A);
+	if (skb2)
+		res2 =3D slave_xmit(hsr, skb2, HSR_PT_SLAVE_B);
+	else
+		res2 =3D NET_XMIT_DROP;
+
+	rcu_read_lock();
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
 	if (likely(res1 =3D=3D NET_XMIT_SUCCESS || res1 =3D=3D NET_XMIT_CN ||
 		   res2 =3D=3D NET_XMIT_SUCCESS || res2 =3D=3D NET_XMIT_CN)) {
-		hsr->dev->stats.tx_packets++;
-		hsr->dev->stats.tx_bytes +=3D skb->len;
+		master->dev->stats.tx_packets++;
+		master->dev->stats.tx_bytes +=3D skb->len;
 	} else {
-		hsr->dev->stats.tx_dropped++;
+		master->dev->stats.tx_dropped++;
 	}
+	rcu_read_unlock();
=20
 	return NETDEV_TX_OK;
 }
@@ -322,31 +352,35 @@ static int hsr_pad(int size)
 static void send_hsr_supervision_frame(struct net_device *hsr_dev, u8 =
type)
 {
 	struct hsr_priv *hsr;
+	struct hsr_port *master;
 	struct sk_buff *skb;
 	int hlen, tlen;
 	struct hsr_sup_tag *hsr_stag;
 	struct hsr_sup_payload *hsr_sp;
 	unsigned long irqflags;
+	int res;
+
+	hsr =3D netdev_priv(hsr_dev);
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
=20
-	hlen =3D LL_RESERVED_SPACE(hsr_dev);
-	tlen =3D hsr_dev->needed_tailroom;
+	hlen =3D LL_RESERVED_SPACE(master->dev);
+	tlen =3D master->dev->needed_tailroom;
 	skb =3D alloc_skb(hsr_pad(sizeof(struct hsr_sup_payload)) + hlen + tl=
en,
 			GFP_ATOMIC);
=20
 	if (skb =3D=3D NULL)
 		return;
=20
-	hsr =3D netdev_priv(hsr_dev);
-
 	skb_reserve(skb, hlen);
=20
-	skb->dev =3D hsr_dev;
+	skb->dev =3D master->dev;
 	skb->protocol =3D htons(ETH_P_PRP);
 	skb->priority =3D TC_PRIO_CONTROL;
=20
-	if (dev_hard_header(skb, skb->dev, ETH_P_PRP,
-			    hsr->sup_multicast_addr,
-			    skb->dev->dev_addr, skb->len) < 0)
+	res =3D dev_hard_header(skb, skb->dev, ETH_P_PRP,
+			      hsr->sup_multicast_addr,
+			      skb->dev->dev_addr, skb->len);
+	if (res <=3D 0)
 		goto out;
=20
 	skb_pull(skb, sizeof(struct ethhdr));
@@ -367,12 +401,13 @@ static void send_hsr_supervision_frame(struct net=
_device *hsr_dev, u8 type)
=20
 	/* Payload: MacAddressA */
 	hsr_sp =3D (typeof(hsr_sp)) skb_put(skb, sizeof(*hsr_sp));
-	ether_addr_copy(hsr_sp->MacAddressA, hsr_dev->dev_addr);
+	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
=20
 	dev_queue_xmit(skb);
 	return;
=20
 out:
+	WARN_ON_ONCE("HSR: Could not send supervision frame\n");
 	kfree_skb(skb);
 }
=20
@@ -382,14 +417,16 @@ out:
 static void hsr_announce(unsigned long data)
 {
 	struct hsr_priv *hsr;
+	struct hsr_port *master;
=20
 	hsr =3D (struct hsr_priv *) data;
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
=20
 	if (hsr->announce_count < 3) {
-		send_hsr_supervision_frame(hsr->dev, HSR_TLV_ANNOUNCE);
+		send_hsr_supervision_frame(master->dev, HSR_TLV_ANNOUNCE);
 		hsr->announce_count++;
 	} else {
-		send_hsr_supervision_frame(hsr->dev, HSR_TLV_LIFE_CHECK);
+		send_hsr_supervision_frame(master->dev, HSR_TLV_LIFE_CHECK);
 	}
=20
 	if (hsr->announce_count < 3)
@@ -399,43 +436,28 @@ static void hsr_announce(unsigned long data)
 		hsr->announce_timer.expires =3D jiffies +
 				msecs_to_jiffies(HSR_LIFE_CHECK_INTERVAL);
=20
-	if (is_admin_up(hsr->dev))
+	if (is_admin_up(master->dev))
 		add_timer(&hsr->announce_timer);
 }
=20
=20
-static void restore_slaves(struct net_device *hsr_dev)
-{
-	struct hsr_priv *hsr;
-
-	hsr =3D netdev_priv(hsr_dev);
-	hsr_del_slave(hsr, 1);
-	hsr_del_slave(hsr, 0);
-}
-
-static void reclaim_hsr_dev(struct rcu_head *rh)
-{
-	struct hsr_priv *hsr;
-
-	hsr =3D container_of(rh, struct hsr_priv, rcu_head);
-	free_netdev(hsr->dev);
-}
-
-
 /* According to comments in the declaration of struct net_device, this=
 function
  * is "Called from unregister, can be used to call free_netdev". Ok th=
en...
  */
 static void hsr_dev_destroy(struct net_device *hsr_dev)
 {
 	struct hsr_priv *hsr;
+	struct hsr_port *port;
=20
 	hsr =3D netdev_priv(hsr_dev);
+	hsr_for_each_port(hsr, port)
+		hsr_del_port(port);
=20
 	del_timer_sync(&hsr->prune_timer);
 	del_timer_sync(&hsr->announce_timer);
-	unregister_hsr_master(hsr);    /* calls list_del_rcu on hsr */
-	restore_slaves(hsr_dev);
-	call_rcu(&hsr->rcu_head, reclaim_hsr_dev);   /* reclaim hsr */
+
+	synchronize_rcu();
+	free_netdev(hsr_dev);
 }
=20
 static const struct net_device_ops hsr_device_ops =3D {
@@ -461,12 +483,11 @@ void hsr_dev_setup(struct net_device *dev)
=20
 /* Return true if dev is a HSR master; return false otherwise.
  */
-bool is_hsr_master(struct net_device *dev)
+inline bool is_hsr_master(struct net_device *dev)
 {
 	return (dev->netdev_ops->ndo_start_xmit =3D=3D hsr_dev_xmit);
 }
=20
-
 /* Default multicast address for HSR Supervision frames */
 static const unsigned char def_multicast_addr[ETH_ALEN] __aligned(2) =3D=
 {
 	0x01, 0x15, 0x4e, 0x00, 0x01, 0x00
@@ -476,12 +497,11 @@ int hsr_dev_finalize(struct net_device *hsr_dev, =
struct net_device *slave[2],
 		     unsigned char multicast_spec)
 {
 	struct hsr_priv *hsr;
+	struct hsr_port *port;
 	int res;
=20
 	hsr =3D netdev_priv(hsr_dev);
-	hsr->dev =3D hsr_dev;
-	hsr->slave[0] =3D NULL;
-	hsr->slave[1] =3D NULL;
+	INIT_LIST_HEAD(&hsr->ports);
 	INIT_LIST_HEAD(&hsr->node_db);
 	INIT_LIST_HEAD(&hsr->self_node_db);
=20
@@ -516,36 +536,42 @@ int hsr_dev_finalize(struct net_device *hsr_dev, =
struct net_device *slave[2],
 	ether_addr_copy(hsr->sup_multicast_addr, def_multicast_addr);
 	hsr->sup_multicast_addr[ETH_ALEN - 1] =3D multicast_spec;
=20
-/* FIXME: should I modify the value of these?
- *
- * - hsr_dev->flags - i.e.
- *			IFF_MASTER/SLAVE?
- * - hsr_dev->priv_flags - i.e.
- *			IFF_EBRIDGE?
- *			IFF_TX_SKB_SHARING?
- *			IFF_HSR_MASTER/SLAVE?
- */
+	/* FIXME: should I modify the value of these?
+	 *
+	 * - hsr_dev->flags - i.e.
+	 *			IFF_MASTER/SLAVE?
+	 * - hsr_dev->priv_flags - i.e.
+	 *			IFF_EBRIDGE?
+	 *			IFF_TX_SKB_SHARING?
+	 *			IFF_HSR_MASTER/SLAVE?
+	 */
=20
 	/* Make sure the 1st call to netif_carrier_on() gets through */
 	netif_carrier_off(hsr_dev);
=20
-	res =3D register_netdevice(hsr_dev);
+	res =3D hsr_add_port(hsr, hsr_dev, HSR_PT_MASTER);
 	if (res)
 		return res;
=20
-	res =3D hsr_add_slave(hsr, slave[0], 0);
+	res =3D register_netdevice(hsr_dev);
 	if (res)
-		return res;
-	res =3D hsr_add_slave(hsr, slave[1], 1);
-	if (res) {
-		hsr_del_slave(hsr, 0);
-		return res;
-	}
+		goto fail;
+
+	res =3D hsr_add_port(hsr, slave[0], HSR_PT_SLAVE_A);
+	if (res)
+		goto fail;
+	res =3D hsr_add_port(hsr, slave[1], HSR_PT_SLAVE_B);
+	if (res)
+		goto fail;
=20
 	hsr->prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD)=
;
 	add_timer(&hsr->prune_timer);
=20
-	register_hsr_master(hsr);
-
 	return 0;
+
+fail:
+	hsr_for_each_port(hsr, port)
+		hsr_del_port(port);
+
+	return res;
 }
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 3666f94..c9b78c5 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -27,12 +27,11 @@ struct hsr_node {
 	struct list_head	mac_list;
 	unsigned char		MacAddressA[ETH_ALEN];
 	unsigned char		MacAddressB[ETH_ALEN];
-	enum hsr_dev_idx	AddrB_if;/* The local slave through which AddrB
-					  * frames are received from this node
-					  */
-	unsigned long		time_in[HSR_MAX_SLAVE];
-	bool			time_in_stale[HSR_MAX_SLAVE];
-	u16			seq_out[HSR_MAX_DEV];
+	/* Local slave through which AddrB frames are received from this node=
 */
+	enum hsr_port_type	AddrB_port;
+	unsigned long		time_in[HSR_PT_PORTS];
+	bool			time_in_stale[HSR_PT_PORTS];
+	u16			seq_out[HSR_PT_PORTS];
 	struct rcu_head		rcu_head;
 };
=20
@@ -154,11 +153,10 @@ int hsr_create_self_node(struct list_head *self_n=
ode_db,
  * We also need to detect if the sender's SlaveA and SlaveB cables hav=
e been
  * swapped.
  */
-struct hsr_node *hsr_merge_node(struct hsr_priv *hsr,
-				struct hsr_node *node,
-				struct sk_buff *skb,
-				enum hsr_dev_idx dev_idx)
+struct hsr_node *hsr_merge_node(struct hsr_node *node, struct sk_buff =
*skb,
+				struct hsr_port *port)
 {
+	struct hsr_priv *hsr;
 	struct hsr_sup_payload *hsr_sp;
 	struct hsr_ethhdr_sp *hsr_ethsup;
 	int i;
@@ -166,6 +164,7 @@ struct hsr_node *hsr_merge_node(struct hsr_priv *hs=
r,
=20
 	hsr_ethsup =3D (struct hsr_ethhdr_sp *) skb_mac_header(skb);
 	hsr_sp =3D (struct hsr_sup_payload *) skb->data;
+	hsr =3D port->hsr;
=20
 	if (node && !ether_addr_equal(node->MacAddressA, hsr_sp->MacAddressA)=
) {
 		/* Node has changed its AddrA, frame was received from SlaveB */
@@ -174,7 +173,7 @@ struct hsr_node *hsr_merge_node(struct hsr_priv *hs=
r,
 		node =3D NULL;
 	}
=20
-	if (node && (dev_idx =3D=3D node->AddrB_if) &&
+	if (node && (port->type =3D=3D node->AddrB_port) &&
 	    !ether_addr_equal(node->MacAddressB, hsr_ethsup->ethhdr.h_source)=
) {
 		/* Cables have been swapped */
 		list_del_rcu(&node->mac_list);
@@ -182,8 +181,8 @@ struct hsr_node *hsr_merge_node(struct hsr_priv *hs=
r,
 		node =3D NULL;
 	}
=20
-	if (node && (dev_idx !=3D node->AddrB_if) &&
-	    (node->AddrB_if !=3D HSR_DEV_NONE) &&
+	if (node && (port->type !=3D node->AddrB_port) &&
+	    (node->AddrB_port !=3D HSR_PT_NONE) &&
 	    !ether_addr_equal(node->MacAddressA, hsr_ethsup->ethhdr.h_source)=
) {
 		/* Cables have been swapped */
 		list_del_rcu(&node->mac_list);
@@ -200,7 +199,7 @@ struct hsr_node *hsr_merge_node(struct hsr_priv *hs=
r,
 		 * address. Node is PICS_SUBS capable; merge its AddrB.
 		 */
 		ether_addr_copy(node->MacAddressB, hsr_ethsup->ethhdr.h_source);
-		node->AddrB_if =3D dev_idx;
+		node->AddrB_port =3D port->type;
 		return node;
 	}
=20
@@ -211,17 +210,15 @@ struct hsr_node *hsr_merge_node(struct hsr_priv *=
hsr,
 	ether_addr_copy(node->MacAddressA, hsr_sp->MacAddressA);
 	ether_addr_copy(node->MacAddressB, hsr_ethsup->ethhdr.h_source);
 	if (!ether_addr_equal(hsr_sp->MacAddressA, hsr_ethsup->ethhdr.h_sourc=
e))
-		node->AddrB_if =3D dev_idx;
-	else
-		node->AddrB_if =3D HSR_DEV_NONE;
+		node->AddrB_port =3D port->type;
=20
 	/* We are only interested in time diffs here, so use current jiffies
 	 * as initialization. (0 could trigger an spurious ring error warning=
).
 	 */
 	now =3D jiffies;
-	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
+	for (i =3D 0; i < HSR_PT_PORTS; i++)
 		node->time_in[i] =3D now;
-	for (i =3D 0; i < HSR_MAX_DEV; i++)
+	for (i =3D 0; i < HSR_PT_PORTS; i++)
 		node->seq_out[i] =3D ntohs(hsr_ethsup->hsr_sup.sequence_nr) - 1;
=20
 	list_add_tail_rcu(&node->mac_list, &hsr->node_db);
@@ -265,13 +262,13 @@ void hsr_addr_subst_source(struct hsr_priv *hsr, =
struct sk_buff *skb)
  * which "side" the different interfaces are.
  */
 void hsr_addr_subst_dest(struct hsr_priv *hsr, struct ethhdr *ethhdr,
-			 enum hsr_dev_idx dev_idx)
+			 struct hsr_port *port)
 {
 	struct hsr_node *node;
=20
 	rcu_read_lock();
 	node =3D find_node_by_AddrA(&hsr->node_db, ethhdr->h_dest);
-	if (node && (node->AddrB_if =3D=3D dev_idx))
+	if (node && (node->AddrB_port =3D=3D port->type))
 		ether_addr_copy(ethhdr->h_dest, node->MacAddressB);
 	rcu_read_unlock();
 }
@@ -295,14 +292,10 @@ static bool seq_nr_after(u16 a, u16 b)
 #define seq_nr_before_or_eq(a, b)	(!seq_nr_after((a), (b)))
=20
=20
-void hsr_register_frame_in(struct hsr_node *node, enum hsr_dev_idx dev=
_idx)
+void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *por=
t)
 {
-	if ((dev_idx < 0) || (dev_idx >=3D HSR_MAX_SLAVE)) {
-		WARN_ONCE(1, "%s: Invalid dev_idx (%d)\n", __func__, dev_idx);
-		return;
-	}
-	node->time_in[dev_idx] =3D jiffies;
-	node->time_in_stale[dev_idx] =3D false;
+	node->time_in[port->type] =3D jiffies;
+	node->time_in_stale[port->type] =3D false;
 }
=20
=20
@@ -314,16 +307,12 @@ void hsr_register_frame_in(struct hsr_node *node,=
 enum hsr_dev_idx dev_idx)
  *	 0 otherwise, or
  *	 negative error code on error
  */
-int hsr_register_frame_out(struct hsr_node *node, enum hsr_dev_idx dev=
_idx,
+int hsr_register_frame_out(struct hsr_node *node, struct hsr_port *por=
t,
 			   struct sk_buff *skb)
 {
 	struct hsr_ethhdr *hsr_ethhdr;
 	u16 sequence_nr;
=20
-	if ((dev_idx < 0) || (dev_idx >=3D HSR_MAX_DEV)) {
-		WARN_ONCE(1, "%s: Invalid dev_idx (%d)\n", __func__, dev_idx);
-		return -EINVAL;
-	}
 	if (!skb_mac_header_was_set(skb)) {
 		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
 		return -EINVAL;
@@ -331,35 +320,32 @@ int hsr_register_frame_out(struct hsr_node *node,=
 enum hsr_dev_idx dev_idx,
 	hsr_ethhdr =3D (struct hsr_ethhdr *) skb_mac_header(skb);
=20
 	sequence_nr =3D ntohs(hsr_ethhdr->hsr_tag.sequence_nr);
-	if (seq_nr_before_or_eq(sequence_nr, node->seq_out[dev_idx]))
+	if (seq_nr_before_or_eq(sequence_nr, node->seq_out[port->type]))
 		return 1;
=20
-	node->seq_out[dev_idx] =3D sequence_nr;
+	node->seq_out[port->type] =3D sequence_nr;
 	return 0;
 }
=20
=20
-
-static bool is_late(struct hsr_node *node, enum hsr_dev_idx dev_idx)
+static struct hsr_port *get_late_port(struct hsr_priv *hsr,
+				      struct hsr_node *node)
 {
-	enum hsr_dev_idx other;
-
-	if (node->time_in_stale[dev_idx])
-		return true;
-
-	if (dev_idx =3D=3D HSR_DEV_SLAVE_A)
-		other =3D HSR_DEV_SLAVE_B;
-	else
-		other =3D HSR_DEV_SLAVE_A;
-
-	if (node->time_in_stale[other])
-		return false;
+	if (node->time_in_stale[HSR_PT_SLAVE_A])
+		return hsr_port_get_hsr(hsr, HSR_PT_SLAVE_A);
+	if (node->time_in_stale[HSR_PT_SLAVE_B])
+		return hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
+
+	if (time_after(node->time_in[HSR_PT_SLAVE_B],
+		       node->time_in[HSR_PT_SLAVE_A] +
+					msecs_to_jiffies(MAX_SLAVE_DIFF)))
+		return hsr_port_get_hsr(hsr, HSR_PT_SLAVE_A);
+	if (time_after(node->time_in[HSR_PT_SLAVE_A],
+		       node->time_in[HSR_PT_SLAVE_B] +
+					msecs_to_jiffies(MAX_SLAVE_DIFF)))
+		return hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
=20
-	if (time_after(node->time_in[other], node->time_in[dev_idx] +
-		       msecs_to_jiffies(MAX_SLAVE_DIFF)))
-		return true;
-
-	return false;
+	return NULL;
 }
=20
=20
@@ -370,6 +356,7 @@ void hsr_prune_nodes(unsigned long data)
 {
 	struct hsr_priv *hsr;
 	struct hsr_node *node;
+	struct hsr_port *port;
 	unsigned long timestamp;
 	unsigned long time_a, time_b;
=20
@@ -378,35 +365,33 @@ void hsr_prune_nodes(unsigned long data)
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &hsr->node_db, mac_list) {
 		/* Shorthand */
-		time_a =3D node->time_in[HSR_DEV_SLAVE_A];
-		time_b =3D node->time_in[HSR_DEV_SLAVE_B];
+		time_a =3D node->time_in[HSR_PT_SLAVE_A];
+		time_b =3D node->time_in[HSR_PT_SLAVE_B];
=20
 		/* Check for timestamps old enough to risk wrap-around */
 		if (time_after(jiffies, time_a + MAX_JIFFY_OFFSET/2))
-			node->time_in_stale[HSR_DEV_SLAVE_A] =3D true;
+			node->time_in_stale[HSR_PT_SLAVE_A] =3D true;
 		if (time_after(jiffies, time_b + MAX_JIFFY_OFFSET/2))
-			node->time_in_stale[HSR_DEV_SLAVE_B] =3D true;
+			node->time_in_stale[HSR_PT_SLAVE_B] =3D true;
=20
 		/* Get age of newest frame from node.
 		 * At least one time_in is OK here; nodes get pruned long
 		 * before both time_ins can get stale
 		 */
 		timestamp =3D time_a;
-		if (node->time_in_stale[HSR_DEV_SLAVE_A] ||
-		    (!node->time_in_stale[HSR_DEV_SLAVE_B] &&
+		if (node->time_in_stale[HSR_PT_SLAVE_A] ||
+		    (!node->time_in_stale[HSR_PT_SLAVE_B] &&
 		    time_after(time_b, time_a)))
 			timestamp =3D time_b;
=20
 		/* Warn of ring error only as long as we get frames at all */
 		if (time_is_after_jiffies(timestamp +
 					msecs_to_jiffies(1.5*MAX_SLAVE_DIFF))) {
-
-			if (is_late(node, HSR_DEV_SLAVE_A))
-				hsr_nl_ringerror(hsr, node->MacAddressA,
-						 HSR_DEV_SLAVE_A);
-			else if (is_late(node, HSR_DEV_SLAVE_B))
-				hsr_nl_ringerror(hsr, node->MacAddressA,
-						 HSR_DEV_SLAVE_B);
+			rcu_read_lock();
+			port =3D get_late_port(hsr, node);
+			if (port !=3D NULL)
+				hsr_nl_ringerror(hsr, node->MacAddressA, port);
+			rcu_read_unlock();
 		}
=20
 		/* Prune old entries */
@@ -455,7 +440,7 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 		      u16 *if2_seq)
 {
 	struct hsr_node *node;
-	struct net_device *slave;
+	struct hsr_port *port;
 	unsigned long tdiff;
=20
=20
@@ -468,8 +453,8 @@ int hsr_get_node_data(struct hsr_priv *hsr,
=20
 	ether_addr_copy(addr_b, node->MacAddressB);
=20
-	tdiff =3D jiffies - node->time_in[HSR_DEV_SLAVE_A];
-	if (node->time_in_stale[HSR_DEV_SLAVE_A])
+	tdiff =3D jiffies - node->time_in[HSR_PT_SLAVE_A];
+	if (node->time_in_stale[HSR_PT_SLAVE_A])
 		*if1_age =3D INT_MAX;
 #if HZ <=3D MSEC_PER_SEC
 	else if (tdiff > msecs_to_jiffies(INT_MAX))
@@ -478,8 +463,8 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 	else
 		*if1_age =3D jiffies_to_msecs(tdiff);
=20
-	tdiff =3D jiffies - node->time_in[HSR_DEV_SLAVE_B];
-	if (node->time_in_stale[HSR_DEV_SLAVE_B])
+	tdiff =3D jiffies - node->time_in[HSR_PT_SLAVE_B];
+	if (node->time_in_stale[HSR_PT_SLAVE_B])
 		*if2_age =3D INT_MAX;
 #if HZ <=3D MSEC_PER_SEC
 	else if (tdiff > msecs_to_jiffies(INT_MAX))
@@ -489,14 +474,15 @@ int hsr_get_node_data(struct hsr_priv *hsr,
 		*if2_age =3D jiffies_to_msecs(tdiff);
=20
 	/* Present sequence numbers as if they were incoming on interface */
-	*if1_seq =3D node->seq_out[HSR_DEV_SLAVE_B];
-	*if2_seq =3D node->seq_out[HSR_DEV_SLAVE_A];
+	*if1_seq =3D node->seq_out[HSR_PT_SLAVE_B];
+	*if2_seq =3D node->seq_out[HSR_PT_SLAVE_A];
=20
-	slave =3D hsr->slave[node->AddrB_if];
-	if ((node->AddrB_if !=3D HSR_DEV_NONE) && slave)
-		*addr_b_ifindex =3D slave->ifindex;
-	else
+	if (node->AddrB_port !=3D HSR_PT_NONE) {
+		port =3D hsr_port_get_hsr(hsr, node->AddrB_port);
+		*addr_b_ifindex =3D port->dev->ifindex;
+	} else {
 		*addr_b_ifindex =3D -1;
+	}
=20
 	rcu_read_unlock();
=20
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
index ccb09cf..c87f36f 100644
--- a/net/hsr/hsr_framereg.h
+++ b/net/hsr/hsr_framereg.h
@@ -18,18 +18,16 @@ struct hsr_node;
=20
 struct hsr_node *hsr_find_node(struct list_head *node_db, struct sk_bu=
ff *skb);
=20
-struct hsr_node *hsr_merge_node(struct hsr_priv *hsr,
-				struct hsr_node *node,
-				struct sk_buff *skb,
-				enum hsr_dev_idx dev_idx);
+struct hsr_node *hsr_merge_node(struct hsr_node *node, struct sk_buff =
*skb,
+				struct hsr_port *port);
=20
 void hsr_addr_subst_source(struct hsr_priv *hsr, struct sk_buff *skb);
 void hsr_addr_subst_dest(struct hsr_priv *hsr, struct ethhdr *ethhdr,
-			 enum hsr_dev_idx dev_idx);
+			 struct hsr_port *port);
=20
-void hsr_register_frame_in(struct hsr_node *node, enum hsr_dev_idx dev=
_idx);
+void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *por=
t);
=20
-int hsr_register_frame_out(struct hsr_node *node, enum hsr_dev_idx dev=
_idx,
+int hsr_register_frame_out(struct hsr_node *node, struct hsr_port *por=
t,
 			   struct sk_buff *skb);
=20
 void hsr_prune_nodes(unsigned long data);
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index b5abe26..a06cab5 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -39,76 +39,25 @@ void unregister_hsr_master(struct hsr_priv *hsr)
 		}
 }
=20
-bool is_hsr_slave(struct net_device *dev)
-{
-	struct hsr_priv *hsr_it;
-
-	list_for_each_entry_rcu(hsr_it, &hsr_list, hsr_list) {
-		if (dev =3D=3D hsr_it->slave[0])
-			return true;
-		if (dev =3D=3D hsr_it->slave[1])
-			return true;
-	}
-
-	return false;
-}
-
-/* If dev is a HSR slave device, return the virtual master device. Ret=
urn NULL
- * otherwise.
- */
-struct hsr_priv *get_hsr_master(struct net_device *dev)
-{
-	struct hsr_priv *hsr;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(hsr, &hsr_list, hsr_list)
-		if ((dev =3D=3D hsr->slave[0]) ||
-		    (dev =3D=3D hsr->slave[1])) {
-			rcu_read_unlock();
-			return hsr;
-		}
-
-	rcu_read_unlock();
-	return NULL;
-}
-
-/* If dev is a HSR slave device, return the other slave device. Return=
 NULL
- * otherwise.
- */
-struct net_device *get_other_slave(struct hsr_priv *hsr,
-				   struct net_device *dev)
-{
-	if (dev =3D=3D hsr->slave[0])
-		return hsr->slave[1];
-	if (dev =3D=3D hsr->slave[1])
-		return hsr->slave[0];
-
-	return NULL;
-}
-
=20
 static int hsr_netdev_notify(struct notifier_block *nb, unsigned long =
event,
 			     void *ptr)
 {
-	struct net_device *slave, *other_slave;
+	struct net_device *dev;
+	struct hsr_port *port, *master;
 	struct hsr_priv *hsr;
 	int mtu_max;
 	int res;
-	struct net_device *dev;
=20
 	dev =3D netdev_notifier_info_to_dev(ptr);
-
-	hsr =3D get_hsr_master(dev);
-	if (hsr) {
-		/* dev is a slave device */
-		slave =3D dev;
-		other_slave =3D get_other_slave(hsr, slave);
-	} else {
+	port =3D hsr_port_get_rtnl(dev);
+	if (port =3D=3D NULL) {
 		if (!is_hsr_master(dev))
-			return NOTIFY_DONE;
+			return NOTIFY_DONE;	/* Not an HSR device */
 		hsr =3D netdev_priv(dev);
-		slave =3D hsr->slave[0];
-		other_slave =3D hsr->slave[1];
+		port =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+	} else {
+		hsr =3D port->hsr;
 	}
=20
 	switch (event) {
@@ -118,48 +67,41 @@ static int hsr_netdev_notify(struct notifier_block=
 *nb, unsigned long event,
 		hsr_check_carrier_and_operstate(hsr);
 		break;
 	case NETDEV_CHANGEADDR:
-
-		/* This should not happen since there's no ndo_set_mac_address()
-		 * for HSR devices - i.e. not supported.
-		 */
-		if (dev =3D=3D hsr->dev)
+		if (port->type =3D=3D HSR_PT_MASTER) {
+			/* This should not happen since there's no
+			 * ndo_set_mac_address() for HSR devices - i.e. not
+			 * supported.
+			 */
 			break;
+		}
=20
-		if (dev =3D=3D hsr->slave[0]) {
-			ether_addr_copy(hsr->dev->dev_addr, dev->dev_addr);
-			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr->dev);
+		master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+
+		if (port->type =3D=3D HSR_PT_SLAVE_A) {
+			ether_addr_copy(master->dev->dev_addr, dev->dev_addr);
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, master->dev);
 		}
=20
 		/* Make sure we recognize frames from ourselves in hsr_rcv() */
-		other_slave =3D hsr->slave[1];
+		port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
 		res =3D hsr_create_self_node(&hsr->self_node_db,
-					   hsr->dev->dev_addr,
-					   other_slave ?
-						other_slave->dev_addr :
-						hsr->dev->dev_addr);
+					   master->dev->dev_addr,
+					   port ?
+						port->dev->dev_addr :
+						master->dev->dev_addr);
 		if (res)
-			netdev_warn(hsr->dev,
+			netdev_warn(master->dev,
 				    "Could not update HSR node address.\n");
 		break;
 	case NETDEV_CHANGEMTU:
-		if (dev =3D=3D hsr->dev)
+		if (port->type =3D=3D HSR_PT_MASTER)
 			break; /* Handled in ndo_change_mtu() */
-		mtu_max =3D hsr_get_max_mtu(hsr);
-		if (hsr->dev->mtu > mtu_max)
-			dev_set_mtu(hsr->dev, mtu_max);
+		mtu_max =3D hsr_get_max_mtu(port->hsr);
+		master =3D hsr_port_get_hsr(port->hsr, HSR_PT_MASTER);
+		master->dev->mtu =3D mtu_max;
 		break;
 	case NETDEV_UNREGISTER:
-		if (dev =3D=3D hsr->slave[0]) {
-			hsr->slave[0] =3D NULL;
-			hsr_del_slave(hsr, 0);
-		}
-		if (dev =3D=3D hsr->slave[1]) {
-			hsr->slave[1] =3D NULL;
-			hsr_del_slave(hsr, 1);
-		}
-
-		/* There should really be a way to set a new slave device... */
-
+		hsr_del_port(port);
 		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* HSR works only on Ethernet devices. Refuse slave to change
@@ -172,6 +114,16 @@ static int hsr_netdev_notify(struct notifier_block=
 *nb, unsigned long event,
 }
=20
=20
+struct hsr_port *hsr_port_get_hsr(struct hsr_priv *hsr, enum hsr_port_=
type pt)
+{
+	struct hsr_port *port;
+
+	hsr_for_each_port(hsr, port)
+		if (port->type =3D=3D pt)
+			return port;
+	return NULL;
+}
+
 static struct notifier_block hsr_nb =3D {
 	.notifier_call =3D hsr_netdev_notify,	/* Slave event notifications */
 };
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
index 43689a6..e31c306 100644
--- a/net/hsr/hsr_main.h
+++ b/net/hsr/hsr_main.h
@@ -136,20 +136,26 @@ struct hsr_ethhdr_sp {
 } __packed;
=20
=20
-enum hsr_dev_idx {
-	HSR_DEV_NONE =3D -1,
-	HSR_DEV_SLAVE_A =3D 0,
-	HSR_DEV_SLAVE_B,
-	HSR_DEV_MASTER,
+enum hsr_port_type {
+	HSR_PT_NONE =3D 0,	/* Must be 0, used by framereg */
+	HSR_PT_SLAVE_A,
+	HSR_PT_SLAVE_B,
+	HSR_PT_INTERLINK,
+	HSR_PT_MASTER,
+	HSR_PT_PORTS,	/* This must be the last item in the enum */
+};
+
+struct hsr_port {
+	struct list_head	port_list;
+	struct net_device	*dev;
+	struct hsr_priv		*hsr;
+	enum hsr_port_type	type;
 };
-#define HSR_MAX_SLAVE	(HSR_DEV_SLAVE_B + 1)
-#define HSR_MAX_DEV	(HSR_DEV_MASTER + 1)
=20
 struct hsr_priv {
 	struct list_head	hsr_list;	/* List of hsr devices */
 	struct rcu_head		rcu_head;
-	struct net_device	*dev;
-	struct net_device	*slave[HSR_MAX_SLAVE];
+	struct list_head	ports;
 	struct list_head	node_db;	/* Other HSR nodes */
 	struct list_head	self_node_db;	/* MACs of slaves */
 	struct timer_list	announce_timer;	/* Supervision frame dispatch */
@@ -160,11 +166,6 @@ struct hsr_priv {
 	unsigned char		sup_multicast_addr[ETH_ALEN];
 };
=20
-void register_hsr_master(struct hsr_priv *hsr);
-void unregister_hsr_master(struct hsr_priv *hsr);
-bool is_hsr_slave(struct net_device *dev);
-struct hsr_priv *get_hsr_master(struct net_device *dev);
-struct net_device *get_other_slave(struct hsr_priv *hsr,
-				   struct net_device *dev);
+struct hsr_port *hsr_port_get_hsr(struct hsr_priv *hsr, enum hsr_port_=
type pt);
=20
 #endif /*  __HSR_PRIVATE_H */
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index a2ce359..6708245 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -64,7 +64,7 @@ static int hsr_newlink(struct net *src_net, struct ne=
t_device *dev,
 static int hsr_fill_info(struct sk_buff *skb, const struct net_device =
*dev)
 {
 	struct hsr_priv *hsr;
-	struct net_device *slave;
+	struct hsr_port *port;
 	int res;
=20
 	hsr =3D netdev_priv(dev);
@@ -72,17 +72,17 @@ static int hsr_fill_info(struct sk_buff *skb, const=
 struct net_device *dev)
 	res =3D 0;
=20
 	rcu_read_lock();
-	slave =3D hsr->slave[0];
-	if (slave)
-		res =3D nla_put_u32(skb, IFLA_HSR_SLAVE1, slave->ifindex);
+	port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_A);
+	if (port)
+		res =3D nla_put_u32(skb, IFLA_HSR_SLAVE1, port->dev->ifindex);
 	rcu_read_unlock();
 	if (res)
 		goto nla_put_failure;
=20
 	rcu_read_lock();
-	slave =3D hsr->slave[1];
-	if (slave)
-		res =3D nla_put_u32(skb, IFLA_HSR_SLAVE2, slave->ifindex);
+	port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
+	if (port)
+		res =3D nla_put_u32(skb, IFLA_HSR_SLAVE2, port->dev->ifindex);
 	rcu_read_unlock();
 	if (res)
 		goto nla_put_failure;
@@ -141,13 +141,12 @@ static const struct genl_multicast_group hsr_mcgr=
ps[] =3D {
  * (i.e. a link has failed somewhere).
  */
 void hsr_nl_ringerror(struct hsr_priv *hsr, unsigned char addr[ETH_ALE=
N],
-		      enum hsr_dev_idx dev_idx)
+		      struct hsr_port *port)
 {
 	struct sk_buff *skb;
-	struct net_device *slave;
 	void *msg_head;
+	struct hsr_port *master;
 	int res;
-	int ifindex;
=20
 	skb =3D genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
 	if (!skb)
@@ -161,15 +160,7 @@ void hsr_nl_ringerror(struct hsr_priv *hsr, unsign=
ed char addr[ETH_ALEN],
 	if (res < 0)
 		goto nla_put_failure;
=20
-	rcu_read_lock();
-	slave =3D hsr->slave[dev_idx];
-	if (slave)
-		ifindex =3D slave->ifindex;
-	else
-		ifindex =3D -1;
-	rcu_read_unlock();
-
-	res =3D nla_put_u32(skb, HSR_A_IFINDEX, ifindex);
+	res =3D nla_put_u32(skb, HSR_A_IFINDEX, port->dev->ifindex);
 	if (res < 0)
 		goto nla_put_failure;
=20
@@ -182,7 +173,10 @@ nla_put_failure:
 	kfree_skb(skb);
=20
 fail:
-	netdev_warn(hsr->dev, "Could not send HSR ring error message\n");
+	rcu_read_lock();
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+	netdev_warn(master->dev, "Could not send HSR ring error message\n");
+	rcu_read_unlock();
 }
=20
 /* This is called when we haven't heard from the node with MAC address=
 addr for
@@ -192,6 +186,7 @@ void hsr_nl_nodedown(struct hsr_priv *hsr, unsigned=
 char addr[ETH_ALEN])
 {
 	struct sk_buff *skb;
 	void *msg_head;
+	struct hsr_port *master;
 	int res;
=20
 	skb =3D genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
@@ -216,7 +211,10 @@ nla_put_failure:
 	kfree_skb(skb);
=20
 fail:
-	netdev_warn(hsr->dev, "Could not send HSR node down\n");
+	rcu_read_lock();
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+	netdev_warn(master->dev, "Could not send HSR node down\n");
+	rcu_read_unlock();
 }
=20
=20
@@ -232,12 +230,13 @@ static int hsr_get_node_status(struct sk_buff *sk=
b_in, struct genl_info *info)
 {
 	/* For receiving */
 	struct nlattr *na;
-	struct net_device *hsr_dev, *slave;
+	struct net_device *hsr_dev;
=20
 	/* For sending */
 	struct sk_buff *skb_out;
 	void *msg_head;
 	struct hsr_priv *hsr;
+	struct hsr_port *port;
 	unsigned char hsr_node_addr_b[ETH_ALEN];
 	int hsr_node_if1_age;
 	u16 hsr_node_if1_seq;
@@ -319,9 +318,10 @@ static int hsr_get_node_status(struct sk_buff *skb=
_in, struct genl_info *info)
 	if (res < 0)
 		goto nla_put_failure;
 	rcu_read_lock();
-	slave =3D hsr->slave[0];
-	if (slave)
-		res =3D nla_put_u32(skb_out, HSR_A_IF1_IFINDEX, slave->ifindex);
+	port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_A);
+	if (port)
+		res =3D nla_put_u32(skb_out, HSR_A_IF1_IFINDEX,
+				  port->dev->ifindex);
 	rcu_read_unlock();
 	if (res < 0)
 		goto nla_put_failure;
@@ -333,9 +333,10 @@ static int hsr_get_node_status(struct sk_buff *skb=
_in, struct genl_info *info)
 	if (res < 0)
 		goto nla_put_failure;
 	rcu_read_lock();
-	slave =3D hsr->slave[1];
-	if (slave)
-		res =3D nla_put_u32(skb_out, HSR_A_IF2_IFINDEX, slave->ifindex);
+	port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
+	if (port)
+		res =3D nla_put_u32(skb_out, HSR_A_IF2_IFINDEX,
+				  port->dev->ifindex);
 	rcu_read_unlock();
 	if (res < 0)
 		goto nla_put_failure;
diff --git a/net/hsr/hsr_netlink.h b/net/hsr/hsr_netlink.h
index 3047f9c..3f6b95b 100644
--- a/net/hsr/hsr_netlink.h
+++ b/net/hsr/hsr_netlink.h
@@ -17,12 +17,13 @@
 #include <uapi/linux/hsr_netlink.h>
=20
 struct hsr_priv;
+struct hsr_port;
=20
 int __init hsr_netlink_init(void);
 void __exit hsr_netlink_exit(void);
=20
 void hsr_nl_ringerror(struct hsr_priv *hsr, unsigned char addr[ETH_ALE=
N],
-		      int dev_idx);
+		      struct hsr_port *port);
 void hsr_nl_nodedown(struct hsr_priv *hsr, unsigned char addr[ETH_ALEN=
]);
 void hsr_nl_framedrop(int dropcount, int dev_idx);
 void hsr_nl_linkdown(int dev_idx);
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index d676090..fffd692 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -17,7 +17,7 @@
 #include "hsr_framereg.h"
=20
=20
-static int check_slave_ok(struct net_device *dev)
+static int hsr_check_dev_ok(struct net_device *dev)
 {
 	/* Don't allow HSR on non-ethernet like devices */
 	if ((dev->flags & IFF_LOOPBACK) || (dev->type !=3D ARPHRD_ETHER) ||
@@ -32,7 +32,7 @@ static int check_slave_ok(struct net_device *dev)
 		return -EINVAL;
 	}
=20
-	if (is_hsr_slave(dev)) {
+	if (hsr_port_exists(dev)) {
 		netdev_info(dev, "This device is already a HSR slave.\n");
 		return -EINVAL;
 	}
@@ -116,38 +116,29 @@ static bool is_supervision_frame(struct hsr_priv =
*hsr, struct sk_buff *skb)
 rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb)
 {
 	struct sk_buff *skb =3D *pskb;
-	struct net_device *dev =3D skb->dev;
+	struct hsr_port *port, *other_port, *master;
 	struct hsr_priv *hsr;
-	struct net_device *other_slave;
 	struct hsr_node *node;
 	bool deliver_to_self;
 	struct sk_buff *skb_deliver;
-	enum hsr_dev_idx dev_in_idx, dev_other_idx;
 	bool dup_out;
 	int ret;
=20
 	if (eth_hdr(skb)->h_proto !=3D htons(ETH_P_PRP))
 		return RX_HANDLER_PASS;
=20
-	hsr =3D get_hsr_master(dev);
-	if (!hsr) {
-		WARN_ON_ONCE(1);
-		return RX_HANDLER_PASS;
-	}
+	rcu_read_lock(); /* ports & node */
=20
-	if (dev =3D=3D hsr->slave[0]) {
-		dev_in_idx =3D HSR_DEV_SLAVE_A;
-		dev_other_idx =3D HSR_DEV_SLAVE_B;
-	} else {
-		dev_in_idx =3D HSR_DEV_SLAVE_B;
-		dev_other_idx =3D HSR_DEV_SLAVE_A;
-	}
+	port =3D hsr_port_get_rcu(skb->dev);
+	hsr =3D port->hsr;
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
=20
 	node =3D hsr_find_node(&hsr->self_node_db, skb);
 	if (node) {
 		/* Always kill frames sent by ourselves */
 		kfree_skb(skb);
-		return RX_HANDLER_CONSUMED;
+		ret =3D RX_HANDLER_CONSUMED;
+		goto finish;
 	}
=20
 	/* Is this frame a candidate for local reception? */
@@ -156,23 +147,22 @@ rx_handler_result_t hsr_handle_frame(struct sk_bu=
ff **pskb)
 	    (skb->pkt_type =3D=3D PACKET_MULTICAST) ||
 	    (skb->pkt_type =3D=3D PACKET_BROADCAST))
 		deliver_to_self =3D true;
-	else if (ether_addr_equal(eth_hdr(skb)->h_dest, hsr->dev->dev_addr)) =
{
+	else if (ether_addr_equal(eth_hdr(skb)->h_dest,
+				  master->dev->dev_addr)) {
 		skb->pkt_type =3D PACKET_HOST;
 		deliver_to_self =3D true;
 	}
=20
-
-	rcu_read_lock(); /* node_db */
 	node =3D hsr_find_node(&hsr->node_db, skb);
=20
 	if (is_supervision_frame(hsr, skb)) {
 		skb_pull(skb, sizeof(struct hsr_sup_tag));
-		node =3D hsr_merge_node(hsr, node, skb, dev_in_idx);
+		node =3D hsr_merge_node(node, skb, port);
 		if (!node) {
-			rcu_read_unlock(); /* node_db */
 			kfree_skb(skb);
-			hsr->dev->stats.rx_dropped++;
-			return RX_HANDLER_CONSUMED;
+			master->dev->stats.rx_dropped++;
+			ret =3D RX_HANDLER_CONSUMED;
+			goto finish;
 		}
 		skb_push(skb, sizeof(struct hsr_sup_tag));
 		deliver_to_self =3D false;
@@ -182,46 +172,51 @@ rx_handler_result_t hsr_handle_frame(struct sk_bu=
ff **pskb)
 		/* Source node unknown; this might be a HSR frame from
 		 * another net (different multicast address). Ignore it.
 		 */
-		rcu_read_unlock(); /* node_db */
 		kfree_skb(skb);
-		return RX_HANDLER_CONSUMED;
+		ret =3D RX_HANDLER_CONSUMED;
+		goto finish;
 	}
=20
+	if (port->type =3D=3D HSR_PT_SLAVE_A)
+		other_port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_B);
+	else
+		other_port =3D hsr_port_get_hsr(hsr, HSR_PT_SLAVE_A);
+
 	/* Register ALL incoming frames as outgoing through the other interfa=
ce.
 	 * This allows us to register frames as incoming only if they are val=
id
 	 * for the receiving interface, without using a specific counter for
 	 * incoming frames.
 	 */
-	dup_out =3D hsr_register_frame_out(node, dev_other_idx, skb);
+	if (other_port)
+		dup_out =3D hsr_register_frame_out(node, other_port, skb);
+	else
+		dup_out =3D 0;
 	if (!dup_out)
-		hsr_register_frame_in(node, dev_in_idx);
+		hsr_register_frame_in(node, port);
=20
 	/* Forward this frame? */
-	if (!dup_out && (skb->pkt_type !=3D PACKET_HOST))
-		other_slave =3D get_other_slave(hsr, dev);
-	else
-		other_slave =3D NULL;
+	if (dup_out || (skb->pkt_type =3D=3D PACKET_HOST))
+		other_port =3D NULL;
=20
-	if (hsr_register_frame_out(node, HSR_DEV_MASTER, skb))
+	if (hsr_register_frame_out(node, master, skb))
 		deliver_to_self =3D false;
=20
-	rcu_read_unlock(); /* node_db */
-
-	if (!deliver_to_self && !other_slave) {
+	if (!deliver_to_self && !other_port) {
 		kfree_skb(skb);
 		/* Circulated frame; silently remove it. */
-		return RX_HANDLER_CONSUMED;
+		ret =3D RX_HANDLER_CONSUMED;
+		goto finish;
 	}
=20
 	skb_deliver =3D skb;
-	if (deliver_to_self && other_slave) {
+	if (deliver_to_self && other_port) {
 		/* skb_clone() is not enough since we will strip the hsr tag
 		 * and do address substitution below
 		 */
 		skb_deliver =3D pskb_copy(skb, GFP_ATOMIC);
 		if (!skb_deliver) {
 			deliver_to_self =3D false;
-			hsr->dev->stats.rx_dropped++;
+			master->dev->stats.rx_dropped++;
 		}
 	}
=20
@@ -230,7 +225,7 @@ rx_handler_result_t hsr_handle_frame(struct sk_buff=
 **pskb)
=20
 		skb_deliver =3D hsr_pull_tag(skb_deliver);
 		if (!skb_deliver) {
-			hsr->dev->stats.rx_dropped++;
+			master->dev->stats.rx_dropped++;
 			goto forward;
 		}
 #if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
@@ -253,82 +248,130 @@ rx_handler_result_t hsr_handle_frame(struct sk_b=
uff **pskb)
 		skb_deliver->data -=3D HSR_HLEN;
 		skb_deliver->tail -=3D HSR_HLEN;
 #endif
-		skb_deliver->dev =3D hsr->dev;
+		skb_deliver->dev =3D master->dev;
 		hsr_addr_subst_source(hsr, skb_deliver);
 		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
 		ret =3D netif_rx(skb_deliver);
 		if (ret =3D=3D NET_RX_DROP) {
-			hsr->dev->stats.rx_dropped++;
+			master->dev->stats.rx_dropped++;
 		} else {
-			hsr->dev->stats.rx_packets++;
-			hsr->dev->stats.rx_bytes +=3D skb->len;
+			master->dev->stats.rx_packets++;
+			master->dev->stats.rx_bytes +=3D skb->len;
 			if (multicast_frame)
-				hsr->dev->stats.multicast++;
+				master->dev->stats.multicast++;
 		}
 	}
=20
 forward:
-	if (other_slave) {
+	if (other_port) {
 		skb_push(skb, ETH_HLEN);
-		skb->dev =3D other_slave;
+		skb->dev =3D other_port->dev;
 		dev_queue_xmit(skb);
 	}
=20
-	return RX_HANDLER_CONSUMED;
+	ret =3D RX_HANDLER_CONSUMED;
+
+finish:
+	rcu_read_unlock();
+	return ret;
 }
=20
-int hsr_add_slave(struct hsr_priv *hsr, struct net_device *dev, int id=
x)
+/* Setup device to be added to the HSR bridge. */
+static int hsr_portdev_setup(struct net_device *dev, struct hsr_port *=
port)
 {
 	int res;
=20
 	dev_hold(dev);
-
-	res =3D check_slave_ok(dev);
-	if (res)
-		goto fail;
-
 	res =3D dev_set_promiscuity(dev, 1);
 	if (res)
-		goto fail;
-
-	res =3D netdev_rx_handler_register(dev, hsr_handle_frame, hsr);
+		goto fail_promiscuity;
+	res =3D netdev_rx_handler_register(dev, hsr_handle_frame, port);
 	if (res)
 		goto fail_rx_handler;
+	dev_disable_lro(dev);
=20
-
-	hsr->slave[idx] =3D dev;
-
-	/* Set required header length */
-	if (dev->hard_header_len + HSR_HLEN > hsr->dev->hard_header_len)
-		hsr->dev->hard_header_len =3D dev->hard_header_len + HSR_HLEN;
-
-	dev_set_mtu(hsr->dev, hsr_get_max_mtu(hsr));
+	/* FIXME:
+	 * What does net device "adjacency" mean? Should we do
+	 * res =3D netdev_master_upper_dev_link(port->dev, port->hsr->dev); ?
+	 */
=20
 	return 0;
=20
 fail_rx_handler:
 	dev_set_promiscuity(dev, -1);
-
-fail:
+fail_promiscuity:
 	dev_put(dev);
+
 	return res;
 }
=20
-void hsr_del_slave(struct hsr_priv *hsr, int idx)
+int hsr_add_port(struct hsr_priv *hsr, struct net_device *dev,
+		 enum hsr_port_type type)
 {
-	struct net_device *slave;
+	struct hsr_port *port, *master;
+	int res;
=20
-	slave =3D hsr->slave[idx];
-	hsr->slave[idx] =3D NULL;
+	if (type !=3D HSR_PT_MASTER) {
+		res =3D hsr_check_dev_ok(dev);
+		if (res)
+			return res;
+	}
+
+	port =3D hsr_port_get_hsr(hsr, type);
+	if (port !=3D NULL)
+		return -EBUSY;	/* This port already exists */
+
+	port =3D kzalloc(sizeof(*port), GFP_KERNEL);
+	if (port =3D=3D NULL)
+		return -ENOMEM;
+
+	if (type !=3D HSR_PT_MASTER) {
+		res =3D hsr_portdev_setup(dev, port);
+		if (res)
+			goto fail_dev_setup;
+	}
+
+	port->hsr =3D hsr;
+	port->dev =3D dev;
+	port->type =3D type;
+
+	list_add_tail_rcu(&port->port_list, &hsr->ports);
+	synchronize_rcu();
+
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+
+	/* Set required header length */
+	if (dev->hard_header_len + HSR_HLEN > master->dev->hard_header_len)
+		master->dev->hard_header_len =3D dev->hard_header_len + HSR_HLEN;
=20
-	netdev_update_features(hsr->dev);
-	dev_set_mtu(hsr->dev, hsr_get_max_mtu(hsr));
+	dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
=20
-	if (slave) {
-		netdev_rx_handler_unregister(slave);
-		dev_set_promiscuity(slave, -1);
+	return 0;
+
+fail_dev_setup:
+	kfree(port);
+	return res;
+}
+
+void hsr_del_port(struct hsr_port *port)
+{
+	struct hsr_priv *hsr;
+	struct hsr_port *master;
+
+	hsr =3D port->hsr;
+	master =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+	list_del_rcu(&port->port_list);
+
+	if (port !=3D master) {
+		dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
+		netdev_rx_handler_unregister(port->dev);
+		dev_set_promiscuity(port->dev, -1);
 	}
=20
+	/* FIXME?
+	 * netdev_upper_dev_unlink(port->dev, port->hsr->dev);
+	 */
+
 	synchronize_rcu();
-	dev_put(slave);
+	dev_put(port->dev);
 }
diff --git a/net/hsr/hsr_slave.h b/net/hsr/hsr_slave.h
index 03c15fd..3055022 100644
--- a/net/hsr/hsr_slave.h
+++ b/net/hsr/hsr_slave.h
@@ -14,10 +14,35 @@
=20
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
 #include "hsr_main.h"
=20
-int hsr_add_slave(struct hsr_priv *hsr, struct net_device *dev, int id=
x);
-void hsr_del_slave(struct hsr_priv *hsr, int idx);
+int hsr_add_port(struct hsr_priv *hsr, struct net_device *dev,
+		 enum hsr_port_type pt);
+void hsr_del_port(struct hsr_port *port);
 rx_handler_result_t hsr_handle_frame(struct sk_buff **pskb);
=20
+
+#define hsr_for_each_port(hsr, port) \
+	list_for_each_entry_rcu((port), &(hsr)->ports, port_list)
+
+
+static inline bool hsr_port_exists(const struct net_device *dev)
+{
+	return dev->rx_handler =3D=3D hsr_handle_frame;
+}
+
+static inline struct hsr_port *hsr_port_get_rtnl(const struct net_devi=
ce *dev)
+{
+	ASSERT_RTNL();
+	return hsr_port_exists(dev) ?
+				rtnl_dereference(dev->rx_handler_data) : NULL;
+}
+
+static inline struct hsr_port *hsr_port_get_rcu(const struct net_devic=
e *dev)
+{
+	return hsr_port_exists(dev) ?
+				rcu_dereference(dev->rx_handler_data) : NULL;
+}
+
 #endif /* __HSR_SLAVE_H */
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
