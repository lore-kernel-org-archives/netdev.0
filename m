From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 02/10] caif: Use RCU instead of spin-lock in caif_dev.c
Date: Fri, 13 May 2011 14:44:00 +0200
Message-ID: <1305290648-9613-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:32858 "EHLO
	slow1.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759210Ab1EMNBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:01:02 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow1.isp.as2116.net (Postfix) with ESMTP id EA8AD800F6
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:16 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU read_lock and refcount is used to protect in-flight packets.

Use RCU and counters to manage freeing lower part of the CAIF stack if
CAIF-link layer is removed. Old solution based on delaying removal of
device is removed.

When CAIF link layer goes down the use of CAIF link layer is disabled
(by calling caif_set_phy_state()), but removal and freeing of the
lower part of the CAIF stack is done when Link layer is unregistered.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfcnfg.h |   10 ++
 net/caif/caif_dev.c       |  277 ++++++++++++++++++++++++++-----------=
--------
 2 files changed, 169 insertions(+), 118 deletions(-)

diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index f33d363..e0a1eb5 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -145,4 +145,14 @@ struct dev_info *cfcnfg_get_phyid(struct cfcnfg *c=
nfg,
  * @ifi:	ifindex obtained from socket.c bindtodevice.
  */
 int cfcnfg_get_id_from_ifi(struct cfcnfg *cnfg, int ifi);
+
+/**
+ * cfcnfg_set_phy_state() - Set the state of the physical interface de=
vice.
+ * @cnfg:	Configuration object
+ * @phy_layer:	Physical Layer representation
+ * @up:	State of device
+ */
+int cfcnfg_set_phy_state(struct cfcnfg *cnfg, struct cflayer *phy_laye=
r,
+				bool up);
+
 #endif				/* CFCNFG_H_ */
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 75e00d5..6d1d86b 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -12,14 +12,11 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
=20
 #include <linux/version.h>
-#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
 #include <linux/net.h>
 #include <linux/netdevice.h>
-#include <linux/skbuff.h>
-#include <linux/sched.h>
-#include <linux/wait.h>
+#include <linux/mutex.h>
 #include <net/netns/generic.h>
 #include <net/net_namespace.h>
 #include <net/pkt_sched.h>
@@ -30,23 +27,19 @@
 #include <net/caif/cfcnfg.h>
=20
 MODULE_LICENSE("GPL");
-#define TIMEOUT (HZ*5)
=20
 /* Used for local tracking of the CAIF net devices */
 struct caif_device_entry {
 	struct cflayer layer;
 	struct list_head list;
-	atomic_t in_use;
-	atomic_t state;
-	u16 phyid;
 	struct net_device *netdev;
-	wait_queue_head_t event;
+	int __percpu *pcpu_refcnt;
 };
=20
 struct caif_device_entry_list {
 	struct list_head list;
 	/* Protects simulanous deletes in list */
-	spinlock_t lock;
+	struct mutex lock;
 };
=20
 struct caif_net {
@@ -65,19 +58,39 @@ static struct caif_device_entry_list *caif_device_l=
ist(struct net *net)
 	return &caifn->caifdevs;
 }
=20
+static void caifd_put(struct caif_device_entry *e)
+{
+	irqsafe_cpu_dec(*e->pcpu_refcnt);
+}
+
+static void caifd_hold(struct caif_device_entry *e)
+{
+	irqsafe_cpu_inc(*e->pcpu_refcnt);
+}
+
+static int caifd_refcnt_read(struct caif_device_entry *e)
+{
+	int i, refcnt =3D 0;
+	for_each_possible_cpu(i)
+		refcnt +=3D *per_cpu_ptr(e->pcpu_refcnt, i);
+	return refcnt;
+}
+
 /* Allocate new CAIF device. */
 static struct caif_device_entry *caif_device_alloc(struct net_device *=
dev)
 {
 	struct caif_device_entry_list *caifdevs;
 	struct caif_device_entry *caifd;
+
 	caifdevs =3D caif_device_list(dev_net(dev));
 	BUG_ON(!caifdevs);
+
 	caifd =3D kzalloc(sizeof(*caifd), GFP_ATOMIC);
 	if (!caifd)
 		return NULL;
+	caifd->pcpu_refcnt =3D alloc_percpu(int);
 	caifd->netdev =3D dev;
-	list_add(&caifd->list, &caifdevs->list);
-	init_waitqueue_head(&caifd->event);
+	dev_hold(dev);
 	return caifd;
 }
=20
@@ -87,35 +100,13 @@ static struct caif_device_entry *caif_get(struct n=
et_device *dev)
 	    caif_device_list(dev_net(dev));
 	struct caif_device_entry *caifd;
 	BUG_ON(!caifdevs);
-	list_for_each_entry(caifd, &caifdevs->list, list) {
+	list_for_each_entry_rcu(caifd, &caifdevs->list, list) {
 		if (caifd->netdev =3D=3D dev)
 			return caifd;
 	}
 	return NULL;
 }
=20
-static void caif_device_destroy(struct net_device *dev)
-{
-	struct caif_device_entry_list *caifdevs =3D
-	    caif_device_list(dev_net(dev));
-	struct caif_device_entry *caifd;
-	ASSERT_RTNL();
-	if (dev->type !=3D ARPHRD_CAIF)
-		return;
-
-	spin_lock_bh(&caifdevs->lock);
-	caifd =3D caif_get(dev);
-	if (caifd =3D=3D NULL) {
-		spin_unlock_bh(&caifdevs->lock);
-		return;
-	}
-
-	list_del(&caifd->list);
-	spin_unlock_bh(&caifdevs->lock);
-
-	kfree(caifd);
-}
-
 static int transmit(struct cflayer *layer, struct cfpkt *pkt)
 {
 	struct caif_device_entry *caifd =3D
@@ -130,23 +121,8 @@ static int transmit(struct cflayer *layer, struct =
cfpkt *pkt)
 	return 0;
 }
=20
-static int modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
-{
-	struct caif_device_entry *caifd;
-	caifd =3D container_of(layr, struct caif_device_entry, layer);
-	if (ctrl =3D=3D _CAIF_MODEMCMD_PHYIF_USEFULL) {
-		atomic_set(&caifd->in_use, 1);
-		wake_up_interruptible(&caifd->event);
-
-	} else if (ctrl =3D=3D _CAIF_MODEMCMD_PHYIF_USELESS) {
-		atomic_set(&caifd->in_use, 0);
-		wake_up_interruptible(&caifd->event);
-	}
-	return 0;
-}
-
 /*
- * Stuff received packets to associated sockets.
+ * Stuff received packets into the CAIF stack.
  * On error, returns non-zero and releases the skb.
  */
 static int receive(struct sk_buff *skb, struct net_device *dev,
@@ -154,14 +130,27 @@ static int receive(struct sk_buff *skb, struct ne=
t_device *dev,
 {
 	struct cfpkt *pkt;
 	struct caif_device_entry *caifd;
+
 	pkt =3D cfpkt_fromnative(CAIF_DIR_IN, skb);
+
+	rcu_read_lock();
 	caifd =3D caif_get(dev);
-	if (!caifd || !caifd->layer.up || !caifd->layer.up->receive)
-		return NET_RX_DROP;
=20
-	if (caifd->layer.up->receive(caifd->layer.up, pkt))
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->receive ||
+			!netif_oper_up(caifd->netdev)) {
+		rcu_read_unlock();
+		kfree_skb(skb);
 		return NET_RX_DROP;
+	}
+
+	/* Hold reference to netdevice while using CAIF stack */
+	caifd_hold(caifd);
+	rcu_read_unlock();
=20
+	caifd->layer.up->receive(caifd->layer.up, pkt);
+
+	/* Release reference to stack upwards */
+	caifd_put(caifd);
 	return 0;
 }
=20
@@ -172,15 +161,25 @@ static struct packet_type caif_packet_type __read=
_mostly =3D {
=20
 static void dev_flowctrl(struct net_device *dev, int on)
 {
-	struct caif_device_entry *caifd =3D caif_get(dev);
-	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+	struct caif_device_entry *caifd;
+
+	rcu_read_lock();
+
+	caifd =3D caif_get(dev);
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd) {
+		rcu_read_unlock();
 		return;
+	}
+
+	caifd_hold(caifd);
+	rcu_read_unlock();
=20
 	caifd->layer.up->ctrlcmd(caifd->layer.up,
 				 on ?
 				 _CAIF_CTRLCMD_PHYIF_FLOW_ON_IND :
 				 _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
 				 caifd->layer.id);
+	caifd_put(caifd);
 }
=20
 /* notify Caif of device events */
@@ -192,34 +191,22 @@ static int caif_device_notify(struct notifier_blo=
ck *me, unsigned long what,
 	struct caif_dev_common *caifdev;
 	enum cfcnfg_phy_preference pref;
 	enum cfcnfg_phy_type phy_type;
+	struct caif_device_entry_list *caifdevs =3D
+	    caif_device_list(dev_net(dev));
=20
 	if (dev->type !=3D ARPHRD_CAIF)
 		return 0;
=20
 	switch (what) {
 	case NETDEV_REGISTER:
-		netdev_info(dev, "register\n");
 		caifd =3D caif_device_alloc(dev);
-		if (caifd =3D=3D NULL)
-			break;
+		if (!caifd)
+			return 0;
+
 		caifdev =3D netdev_priv(dev);
 		caifdev->flowctrl =3D dev_flowctrl;
-		atomic_set(&caifd->state, what);
-		break;
=20
-	case NETDEV_UP:
-		netdev_info(dev, "up\n");
-		caifd =3D caif_get(dev);
-		if (caifd =3D=3D NULL)
-			break;
-		caifdev =3D netdev_priv(dev);
-		if (atomic_read(&caifd->state) =3D=3D NETDEV_UP) {
-			netdev_info(dev, "already up\n");
-			break;
-		}
-		atomic_set(&caifd->state, what);
 		caifd->layer.transmit =3D transmit;
-		caifd->layer.modemcmd =3D modemcmd;
=20
 		if (caifdev->use_frag)
 			phy_type =3D CFPHYTYPE_FRAG;
@@ -237,62 +224,95 @@ static int caif_device_notify(struct notifier_blo=
ck *me, unsigned long what,
 			pref =3D CFPHYPREF_HIGH_BW;
 			break;
 		}
-		dev_hold(dev);
+		strncpy(caifd->layer.name, dev->name,
+			sizeof(caifd->layer.name) - 1);
+		caifd->layer.name[sizeof(caifd->layer.name) - 1] =3D 0;
+
+		mutex_lock(&caifdevs->lock);
+		list_add_rcu(&caifd->list, &caifdevs->list);
+
 		cfcnfg_add_phy_layer(cfg,
 				     phy_type,
 				     dev,
 				     &caifd->layer,
-				     &caifd->phyid,
+				     0,
 				     pref,
 				     caifdev->use_fcs,
 				     caifdev->use_stx);
-		strncpy(caifd->layer.name, dev->name,
-			sizeof(caifd->layer.name) - 1);
-		caifd->layer.name[sizeof(caifd->layer.name) - 1] =3D 0;
+		mutex_unlock(&caifdevs->lock);
 		break;
=20
-	case NETDEV_GOING_DOWN:
+	case NETDEV_UP:
+		rcu_read_lock();
+
 		caifd =3D caif_get(dev);
-		if (caifd =3D=3D NULL)
+		if (caifd =3D=3D NULL) {
+			rcu_read_unlock();
 			break;
-		netdev_info(dev, "going down\n");
+		}
=20
-		if (atomic_read(&caifd->state) =3D=3D NETDEV_GOING_DOWN ||
-			atomic_read(&caifd->state) =3D=3D NETDEV_DOWN)
-			break;
+		cfcnfg_set_phy_state(cfg, &caifd->layer, true);
+		rcu_read_unlock();
=20
-		atomic_set(&caifd->state, what);
-		if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
-			return -EINVAL;
-		caifd->layer.up->ctrlcmd(caifd->layer.up,
-					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
-					 caifd->layer.id);
-		might_sleep();
-		wait_event_interruptible_timeout(caifd->event,
-					atomic_read(&caifd->in_use) =3D=3D 0,
-					TIMEOUT);
 		break;
=20
 	case NETDEV_DOWN:
+		rcu_read_lock();
+
 		caifd =3D caif_get(dev);
-		if (caifd =3D=3D NULL)
-			break;
-		netdev_info(dev, "down\n");
-		if (atomic_read(&caifd->in_use))
-			netdev_warn(dev,
-				    "Unregistering an active CAIF device\n");
-		cfcnfg_del_phy_layer(cfg, &caifd->layer);
-		dev_put(dev);
-		atomic_set(&caifd->state, what);
+		if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd) {
+			rcu_read_unlock();
+			return -EINVAL;
+		}
+
+		cfcnfg_set_phy_state(cfg, &caifd->layer, false);
+		caifd_hold(caifd);
+		rcu_read_unlock();
+
+		caifd->layer.up->ctrlcmd(caifd->layer.up,
+					 _CAIF_CTRLCMD_PHYIF_DOWN_IND,
+					 caifd->layer.id);
+		caifd_put(caifd);
 		break;
=20
 	case NETDEV_UNREGISTER:
+		mutex_lock(&caifdevs->lock);
+
 		caifd =3D caif_get(dev);
-		if (caifd =3D=3D NULL)
+		if (caifd =3D=3D NULL) {
+			mutex_unlock(&caifdevs->lock);
 			break;
-		netdev_info(dev, "unregister\n");
-		atomic_set(&caifd->state, what);
-		caif_device_destroy(dev);
+		}
+		list_del_rcu(&caifd->list);
+
+		/*
+		 * NETDEV_UNREGISTER is called repeatedly until all reference
+		 * counts for the net-device are released. If references to
+		 * caifd is taken, simply ignore NETDEV_UNREGISTER and wait for
+		 * the next call to NETDEV_UNREGISTER.
+		 *
+		 * If any packets are in flight down the CAIF Stack,
+		 * cfcnfg_del_phy_layer will return nonzero.
+		 * If no packets are in flight, the CAIF Stack associated
+		 * with the net-device un-registering is freed.
+		 */
+
+		if (caifd_refcnt_read(caifd) !=3D 0 ||
+			cfcnfg_del_phy_layer(cfg, &caifd->layer) !=3D 0) {
+
+			pr_info("Wait for device inuse\n");
+			/* Enrole device if CAIF Stack is still in use */
+			list_add_rcu(&caifd->list, &caifdevs->list);
+			mutex_unlock(&caifdevs->lock);
+			break;
+		}
+
+		synchronize_rcu();
+		dev_put(caifd->netdev);
+		free_percpu(caifd->pcpu_refcnt);
+		kfree(caifd);
+
+		mutex_unlock(&caifdevs->lock);
 		break;
 	}
 	return 0;
@@ -304,8 +324,8 @@ static struct notifier_block caif_device_notifier =3D=
 {
 };
=20
 int caif_connect_client(struct caif_connect_request *conn_req,
-			struct cflayer *client_layer, int *ifindex,
-			int *headroom, int *tailroom)
+		       struct cflayer *client_layer, int *ifindex,
+		       int *headroom, int *tailroom)
 {
 	struct cfctrl_link_param param;
 	int ret;
@@ -315,8 +335,8 @@ int caif_connect_client(struct caif_connect_request=
 *conn_req,
 		return ret;
 	/* Hook up the adaptation layer. */
 	return cfcnfg_add_adaptation_layer(cfg, &param,
-					client_layer, ifindex,
-					headroom, tailroom);
+				       client_layer, ifindex,
+				       headroom, tailroom);
 }
 EXPORT_SYMBOL(caif_connect_client);
=20
@@ -331,20 +351,40 @@ static int caif_init_net(struct net *net)
 {
 	struct caif_net *caifn =3D net_generic(net, caif_net_id);
 	INIT_LIST_HEAD(&caifn->caifdevs.list);
-	spin_lock_init(&caifn->caifdevs.lock);
+	mutex_init(&caifn->caifdevs.lock);
 	return 0;
 }
=20
 static void caif_exit_net(struct net *net)
 {
-	struct net_device *dev;
+	struct caif_device_entry *caifd, *tmp;
+	struct caif_device_entry_list *caifdevs =3D
+	    caif_device_list(net);
+
 	rtnl_lock();
-	for_each_netdev(net, dev) {
-		if (dev->type !=3D ARPHRD_CAIF)
-			continue;
-		dev_close(dev);
-		caif_device_destroy(dev);
+	mutex_lock(&caifdevs->lock);
+
+	list_for_each_entry_safe(caifd, tmp, &caifdevs->list, list) {
+		int i =3D 0;
+		list_del_rcu(&caifd->list);
+		cfcnfg_set_phy_state(cfg, &caifd->layer, false);
+
+		while (i < 10 &&
+			(caifd_refcnt_read(caifd) !=3D 0 ||
+			cfcnfg_del_phy_layer(cfg, &caifd->layer) !=3D 0)) {
+
+			pr_info("Wait for device inuse\n");
+			msleep(250);
+			i++;
+		}
+		synchronize_rcu();
+		dev_put(caifd->netdev);
+		free_percpu(caifd->pcpu_refcnt);
+		kfree(caifd);
 	}
+
+
+	mutex_unlock(&caifdevs->lock);
 	rtnl_unlock();
 }
=20
@@ -359,6 +399,7 @@ static struct pernet_operations caif_net_ops =3D {
 static int __init caif_device_init(void)
 {
 	int result;
+
 	cfg =3D cfcnfg_create();
 	if (!cfg) {
 		pr_warn("can't create cfcnfg\n");
--=20
1.7.1

