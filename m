From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 03/10] net/hsr: Move to per-hsr device prune timer.
Date: Fri, 4 Jul 2014 23:35:47 +0200
Message-ID: <53B71E33.8030402@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:57200 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbaGDVpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c   | 10 +++++++++-
 net/hsr/hsr_framereg.c |  5 ++++-
 net/hsr/hsr_framereg.h |  2 +-
 net/hsr/hsr_main.c     | 24 ------------------------
 net/hsr/hsr_main.h     |  1 +
 5 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 4e5d92a..f224067 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -429,7 +429,8 @@ static void hsr_dev_destroy(struct net_device *hsr_=
dev)
=20
 	hsr =3D netdev_priv(hsr_dev);
=20
-	del_timer(&hsr->announce_timer);
+	del_timer_sync(&hsr->prune_timer);
+	del_timer_sync(&hsr->announce_timer);
 	unregister_hsr_master(hsr);    /* calls list_del_rcu on hsr */
 	restore_slaves(hsr_dev);
 	call_rcu(&hsr->rcu_head, reclaim_hsr_dev);   /* reclaim hsr */
@@ -523,6 +524,10 @@ int hsr_dev_finalize(struct net_device *hsr_dev, s=
truct net_device *slave[2],
 	hsr->announce_timer.function =3D hsr_announce;
 	hsr->announce_timer.data =3D (unsigned long) hsr;
=20
+	init_timer(&hsr->prune_timer);
+	hsr->prune_timer.function =3D hsr_prune_nodes;
+	hsr->prune_timer.data =3D (unsigned long) hsr;
+
 	ether_addr_copy(hsr->sup_multicast_addr, def_multicast_addr);
 	hsr->sup_multicast_addr[ETH_ALEN - 1] =3D multicast_spec;
=20
@@ -596,6 +601,9 @@ int hsr_dev_finalize(struct net_device *hsr_dev, st=
ruct net_device *slave[2],
 	if (res)
 		goto fail;
=20
+	hsr->prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD)=
;
+	add_timer(&hsr->prune_timer);
+
 	register_hsr_master(hsr);
=20
 	return 0;
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index b419edb..79e3f7f 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -366,12 +366,15 @@ static bool is_late(struct hsr_node *node, enum h=
sr_dev_idx dev_idx)
 /* Remove stale sequence_nr records. Called by timer every
  * HSR_LIFE_CHECK_INTERVAL (two seconds or so).
  */
-void hsr_prune_nodes(struct hsr_priv *hsr)
+void hsr_prune_nodes(unsigned long data)
 {
+	struct hsr_priv *hsr;
 	struct hsr_node *node;
 	unsigned long timestamp;
 	unsigned long time_a, time_b;
=20
+	hsr =3D (struct hsr_priv *) data;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &hsr->node_db, mac_list) {
 		/* Shorthand */
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
index 3675139..ccb09cf 100644
--- a/net/hsr/hsr_framereg.h
+++ b/net/hsr/hsr_framereg.h
@@ -32,7 +32,7 @@ void hsr_register_frame_in(struct hsr_node *node, enu=
m hsr_dev_idx dev_idx);
 int hsr_register_frame_out(struct hsr_node *node, enum hsr_dev_idx dev=
_idx,
 			   struct sk_buff *skb);
=20
-void hsr_prune_nodes(struct hsr_priv *hsr);
+void hsr_prune_nodes(unsigned long data);
=20
 int hsr_create_self_node(struct list_head *self_node_db,
 			 unsigned char addr_a[ETH_ALEN],
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index bcda901..5f9cd7f 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -175,22 +175,6 @@ static int hsr_netdev_notify(struct notifier_block=
 *nb, unsigned long event,
 }
=20
=20
-static struct timer_list prune_timer;
-
-static void prune_nodes_all(unsigned long data)
-{
-	struct hsr_priv *hsr;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(hsr, &hsr_list, hsr_list)
-		hsr_prune_nodes(hsr);
-	rcu_read_unlock();
-
-	prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD);
-	add_timer(&prune_timer);
-}
-
-
 static struct notifier_block hsr_nb =3D {
 	.notifier_call =3D hsr_netdev_notify,	/* Slave event notifications */
 };
@@ -202,14 +186,7 @@ static int __init hsr_init(void)
=20
 	BUILD_BUG_ON(sizeof(struct hsr_tag) !=3D HSR_HLEN);
=20
-	init_timer(&prune_timer);
-	prune_timer.function =3D prune_nodes_all;
-	prune_timer.data =3D 0;
-	prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD);
-	add_timer(&prune_timer);
-
 	register_netdevice_notifier(&hsr_nb);
-
 	res =3D hsr_netlink_init();
=20
 	return res;
@@ -218,7 +195,6 @@ static int __init hsr_init(void)
 static void __exit hsr_exit(void)
 {
 	unregister_netdevice_notifier(&hsr_nb);
-	del_timer_sync(&prune_timer);
 	hsr_netlink_exit();
 }
=20
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
index d919321..43689a6 100644
--- a/net/hsr/hsr_main.h
+++ b/net/hsr/hsr_main.h
@@ -153,6 +153,7 @@ struct hsr_priv {
 	struct list_head	node_db;	/* Other HSR nodes */
 	struct list_head	self_node_db;	/* MACs of slaves */
 	struct timer_list	announce_timer;	/* Supervision frame dispatch */
+	struct timer_list	prune_timer;
 	int announce_count;
 	u16 sequence_nr;
 	spinlock_t seqnr_lock;			/* locking for sequence_nr */
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
