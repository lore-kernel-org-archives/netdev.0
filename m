From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [GIT PULL] bridge update for 2.6.22
Date: Mon, 9 Apr 2007 13:55:52 -0700
Message-ID: <20070409135552.5eee2bc8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60433 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752609AbXDIVGt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 17:06:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is an update to bridging code for net-2.6.22

The following changes since commit 532122caf3f7573760c5ec523bc3be14606b=
b8f2:
  Ilpo J=C3=A4rvinen (1):
        [TCP]: Simplify LOST marker code

are found in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/shemminger/bridge-2.6.22.=
git

Akinobu Mita (1):
      bridge: check kmem_cache_create() error

Stephen Hemminger (7):
      bridge: eliminate call by reference
      bridge: don't route packets while learning
      bridge: simpler hash with salt
      bridge: add sysfs hook to flush forwarding table
      bridge: add support for user mode STP
      bridge: change when netlink events go to STP
      bridge: allow changing hardware address to any valid address

 include/linux/if_bridge.h |    3 +-
 net/bridge/br.c           |    4 ++-
 net/bridge/br_device.c    |   19 +++++---------
 net/bridge/br_fdb.c       |   42 +++++++++++++++++++++++++++----
 net/bridge/br_if.c        |    6 ++++-
 net/bridge/br_input.c     |   35 +++++++++++++-------------
 net/bridge/br_ioctl.c     |    5 ++-
 net/bridge/br_netlink.c   |    2 +-
 net/bridge/br_notify.c    |   13 +++++++---
 net/bridge/br_private.h   |   21 ++++++++++++----
 net/bridge/br_stp.c       |   10 +++++--
 net/bridge/br_stp_bpdu.c  |   19 ++++++++++----
 net/bridge/br_stp_if.c    |   59 +++++++++++++++++++++++++++++++++++++=
+++++--
 net/bridge/br_sysfs_br.c  |   18 +++++++++++++-
 net/bridge/br_sysfs_if.c  |    8 ++++++
 net/core/dev.c            |   31 ++++++++++++++---------
 16 files changed, 220 insertions(+), 75 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index fd1b6eb..4ff211d 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -105,7 +105,8 @@ struct __fdb_entry
 #include <linux/netdevice.h>
=20
 extern void brioctl_set(int (*ioctl_hook)(unsigned int, void __user *)=
);
-extern int (*br_handle_frame_hook)(struct net_bridge_port *p, struct s=
k_buff **pskb);
+extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port =
*p,
+					       struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
=20
 #endif
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 601c37d..848b8fa 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -37,7 +37,9 @@ static int __init br_init(void)
 		return -EADDRINUSE;
 	}
=20
-	br_fdb_init();
+	err =3D br_fdb_init();
+	if (err)
+		goto err_out1;
=20
 	err =3D br_netfilter_init();
 	if (err)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index b22ada5..39b87da 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -83,27 +83,22 @@ static int br_change_mtu(struct net_device *dev, in=
t new_mtu)
 	return 0;
 }
=20
-/* Allow setting mac address of pseudo-bridge to be same as
- * any of the bound interfaces
- */
+/* Allow setting mac address to any valid ethernet address. */
 static int br_set_mac_address(struct net_device *dev, void *p)
 {
 	struct net_bridge *br =3D netdev_priv(dev);
 	struct sockaddr *addr =3D p;
 	struct net_bridge_port *port;
-	int err =3D -EADDRNOTAVAIL;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
=20
 	spin_lock_bh(&br->lock);
-	list_for_each_entry(port, &br->port_list, list) {
-		if (!compare_ether_addr(port->dev->dev_addr, addr->sa_data)) {
-			br_stp_change_bridge_id(br, addr->sa_data);
-			err =3D 0;
-			break;
-		}
-	}
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	br_stp_change_bridge_id(br, addr->sa_data);
 	spin_unlock_bh(&br->lock);
=20
-	return err;
+	return 0;
 }
=20
 static void br_getinfo(struct net_device *dev, struct ethtool_drvinfo =
*info)
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 8d566c1..91b0170 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -20,19 +20,28 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/jhash.h>
+#include <linux/random.h>
 #include <asm/atomic.h>
+#include <asm/unaligned.h>
 #include "br_private.h"
=20
 static struct kmem_cache *br_fdb_cache __read_mostly;
 static int fdb_insert(struct net_bridge *br, struct net_bridge_port *s=
ource,
 		      const unsigned char *addr);
=20
-void __init br_fdb_init(void)
+static u32 fdb_salt __read_mostly;
+
+int __init br_fdb_init(void)
 {
 	br_fdb_cache =3D kmem_cache_create("bridge_fdb_cache",
 					 sizeof(struct net_bridge_fdb_entry),
 					 0,
 					 SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (!br_fdb_cache)
+		return -ENOMEM;
+
+	get_random_bytes(&fdb_salt, sizeof(fdb_salt));
+	return 0;
 }
=20
 void __exit br_fdb_fini(void)
@@ -44,24 +53,26 @@ void __exit br_fdb_fini(void)
 /* if topology_changing then use forward_delay (default 15 sec)
  * otherwise keep longer (default 5 minutes)
  */
-static __inline__ unsigned long hold_time(const struct net_bridge *br)
+static inline unsigned long hold_time(const struct net_bridge *br)
 {
 	return br->topology_change ? br->forward_delay : br->ageing_time;
 }
=20
-static __inline__ int has_expired(const struct net_bridge *br,
+static inline int has_expired(const struct net_bridge *br,
 				  const struct net_bridge_fdb_entry *fdb)
 {
 	return !fdb->is_static
 		&& time_before_eq(fdb->ageing_timer + hold_time(br), jiffies);
 }
=20
-static __inline__ int br_mac_hash(const unsigned char *mac)
+static inline int br_mac_hash(const unsigned char *mac)
 {
-	return jhash(mac, ETH_ALEN, 0) & (BR_HASH_SIZE - 1);
+	/* use 1 byte of OUI cnd 3 bytes of NIC */
+	u32 key =3D get_unaligned((u32 *)(mac + 2));
+	return jhash_1word(key, fdb_salt) & (BR_HASH_SIZE - 1);
 }
=20
-static __inline__ void fdb_delete(struct net_bridge_fdb_entry *f)
+static inline void fdb_delete(struct net_bridge_fdb_entry *f)
 {
 	hlist_del_rcu(&f->hlist);
 	br_fdb_put(f);
@@ -128,7 +139,26 @@ void br_fdb_cleanup(unsigned long _data)
 	mod_timer(&br->gc_timer, jiffies + HZ/10);
 }
=20
+/* Completely flush all dynamic entries in forwarding database.*/
+void br_fdb_flush(struct net_bridge *br)
+{
+	int i;
=20
+	spin_lock_bh(&br->hash_lock);
+	for (i =3D 0; i < BR_HASH_SIZE; i++) {
+		struct net_bridge_fdb_entry *f;
+		struct hlist_node *h, *n;
+		hlist_for_each_entry_safe(f, h, n, &br->hash[i], hlist) {
+			if (!f->is_static)
+				fdb_delete(f);
+		}
+	}
+	spin_unlock_bh(&br->hash_lock);
+}
+
+/* Flush all entries refering to a specific port.
+ * if do_all is set also flush static entries
+ */
 void br_fdb_delete_by_port(struct net_bridge *br,
 			   const struct net_bridge_port *p,
 			   int do_all)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f3a2e29..690573b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -152,6 +152,8 @@ static void del_nbp(struct net_bridge_port *p)
 	br_stp_disable_port(p);
 	spin_unlock_bh(&br->lock);
=20
+	br_ifinfo_notify(RTM_DELLINK, p);
+
 	br_fdb_delete_by_port(br, p, 1);
=20
 	list_del_rcu(&p->list);
@@ -203,7 +205,7 @@ static struct net_device *new_bridge_dev(const char=
 *name)
 	memcpy(br->group_addr, br_group_address, ETH_ALEN);
=20
 	br->feature_mask =3D dev->features;
-	br->stp_enabled =3D 0;
+	br->stp_enabled =3D BR_NO_STP;
 	br->designated_root =3D br->bridge_id;
 	br->root_path_cost =3D 0;
 	br->root_port =3D 0;
@@ -434,6 +436,8 @@ int br_add_if(struct net_bridge *br, struct net_dev=
ice *dev)
 		br_stp_enable_port(p);
 	spin_unlock_bh(&br->lock);
=20
+	br_ifinfo_notify(RTM_NEWLINK, p);
+
 	dev_set_mtu(br->dev, br_min_mtu(br));
=20
 	kobject_uevent(&p->kobj, KOBJ_ADD);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index a260679..8a55276 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -121,41 +121,42 @@ static inline int is_link_local(const unsigned ch=
ar *dest)
=20
 /*
  * Called via br_handle_frame_hook.
- * Return 0 if *pskb should be processed furthur
- *	  1 if *pskb is handled
+ * Return NULL if skb is handled
  * note: already called with rcu_read_lock (preempt_disabled)
  */
-int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb)
+struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_b=
uff *skb)
 {
-	struct sk_buff *skb =3D *pskb;
 	const unsigned char *dest =3D eth_hdr(skb)->h_dest;
=20
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
-		goto err;
+		goto drop;
=20
 	if (unlikely(is_link_local(dest))) {
 		skb->pkt_type =3D PACKET_HOST;
-		return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			       NULL, br_handle_local_finish) !=3D 0;
+
+		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+				NULL, br_handle_local_finish) =3D=3D 0) ? skb : NULL;
 	}
=20
-	if (p->state =3D=3D BR_STATE_FORWARDING || p->state =3D=3D BR_STATE_L=
EARNING) {
+	switch (p->state) {
+	case BR_STATE_FORWARDING:
+
 		if (br_should_route_hook) {
-			if (br_should_route_hook(pskb))
-				return 0;
-			skb =3D *pskb;
+			if (br_should_route_hook(&skb))
+				return skb;
 			dest =3D eth_hdr(skb)->h_dest;
 		}
-
+		/* fall through */
+	case BR_STATE_LEARNING:
 		if (!compare_ether_addr(p->br->dev->dev_addr, dest))
 			skb->pkt_type =3D PACKET_HOST;
=20
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
-		return 1;
+		break;
+	default:
+drop:
+		kfree_skb(skb);
 	}
-
-err:
-	kfree_skb(skb);
-	return 1;
+	return NULL;
 }
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 147015f..eda0fbf 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -137,7 +137,8 @@ static int old_dev_ioctl(struct net_device *dev, st=
ruct ifreq *rq, int cmd)
 		b.topology_change =3D br->topology_change;
 		b.topology_change_detected =3D br->topology_change_detected;
 		b.root_port =3D br->root_port;
-		b.stp_enabled =3D br->stp_enabled;
+
+		b.stp_enabled =3D (br->stp_enabled !=3D BR_NO_STP);
 		b.ageing_time =3D jiffies_to_clock_t(br->ageing_time);
 		b.hello_timer_value =3D br_timer_value(&br->hello_timer);
 		b.tcn_timer_value =3D br_timer_value(&br->tcn_timer);
@@ -251,7 +252,7 @@ static int old_dev_ioctl(struct net_device *dev, st=
ruct ifreq *rq, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
=20
-		br->stp_enabled =3D args[1]?1:0;
+		br_stp_set_enabled(br, args[1]);
 		return 0;
=20
 	case BRCTL_SET_BRIDGE_PRIORITY:
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a14ac51..5e84ade 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -165,7 +165,7 @@ static int br_rtm_setlink(struct sk_buff *skb,  str=
uct nlmsghdr *nlh, void *arg)
 		return -EINVAL;
=20
 	/* if kernel STP is running, don't allow changes */
-	if (p->br->stp_enabled)
+	if (p->br->stp_enabled =3D=3D BR_KERNEL_STP)
 		return -EBUSY;
=20
 	if (!netif_running(dev) ||
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 37357ed..c8451d3 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -50,7 +50,6 @@ static int br_device_event(struct notifier_block *unu=
sed, unsigned long event, v
 	case NETDEV_CHANGEADDR:
 		spin_lock_bh(&br->lock);
 		br_fdb_changeaddr(p, dev->dev_addr);
-		br_ifinfo_notify(RTM_NEWLINK, p);
 		br_stp_recalculate_bridge_id(br);
 		spin_unlock_bh(&br->lock);
 		break;
@@ -74,10 +73,11 @@ static int br_device_event(struct notifier_block *u=
nused, unsigned long event, v
 		break;
=20
 	case NETDEV_UP:
-		spin_lock_bh(&br->lock);
-		if (netif_carrier_ok(dev) && (br->dev->flags & IFF_UP))
+		if (netif_carrier_ok(dev) && (br->dev->flags & IFF_UP)) {
+			spin_lock_bh(&br->lock);
 			br_stp_enable_port(p);
-		spin_unlock_bh(&br->lock);
+			spin_unlock_bh(&br->lock);
+		}
 		break;
=20
 	case NETDEV_UNREGISTER:
@@ -85,5 +85,10 @@ static int br_device_event(struct notifier_block *un=
used, unsigned long event, v
 		break;
 	}
=20
+	/* Events that may cause spanning tree to refresh */
+	if (event =3D=3D NETDEV_CHANGEADDR || event =3D=3D NETDEV_UP ||
+	    event =3D=3D NETDEV_CHANGE || event =3D=3D NETDEV_DOWN)
+		br_ifinfo_notify(RTM_NEWLINK, p);
+
 	return NOTIFY_DONE;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2b73de6..21bf3a9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -26,7 +26,10 @@
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
=20
-#define BR_VERSION	"2.2"
+#define BR_VERSION	"2.3"
+
+/* Path to usermode spanning tree program */
+#define BR_STP_PROG	"/sbin/bridge-stp"
=20
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
@@ -107,7 +110,13 @@ struct net_bridge
=20
 	u8				group_addr[ETH_ALEN];
 	u16				root_port;
-	unsigned char			stp_enabled;
+
+	enum {
+		BR_NO_STP, 		/* no spanning tree */
+		BR_KERNEL_STP,		/* old STP in kernel */
+		BR_USER_STP,		/* new RSTP in userspace */
+	} stp_enabled;
+
 	unsigned char			topology_change;
 	unsigned char			topology_change_detected;
=20
@@ -127,14 +136,14 @@ static inline int br_is_root_bridge(const struct =
net_bridge *br)
 	return !memcmp(&br->bridge_id, &br->designated_root, 8);
 }
=20
-
 /* br_device.c */
 extern void br_dev_setup(struct net_device *dev);
 extern int br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
=20
 /* br_fdb.c */
-extern void br_fdb_init(void);
+extern int br_fdb_init(void);
 extern void br_fdb_fini(void);
+extern void br_fdb_flush(struct net_bridge *br);
 extern void br_fdb_changeaddr(struct net_bridge_port *p,
 			      const unsigned char *newaddr);
 extern void br_fdb_cleanup(unsigned long arg);
@@ -182,7 +191,8 @@ extern void br_features_recompute(struct net_bridge=
 *br);
=20
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern int br_handle_frame(struct net_bridge_port *p, struct sk_buff *=
*pskb);
+extern struct sk_buff *br_handle_frame(struct net_bridge_port *p,
+				       struct sk_buff *skb);
=20
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd);
@@ -207,6 +217,7 @@ extern void br_become_designated_port(struct net_br=
idge_port *p);
 /* br_stp_if.c */
 extern void br_stp_enable_bridge(struct net_bridge *br);
 extern void br_stp_disable_bridge(struct net_bridge *br);
+extern void br_stp_set_enabled(struct net_bridge *br, unsigned long va=
l);
 extern void br_stp_enable_port(struct net_bridge_port *p);
 extern void br_stp_disable_port(struct net_bridge_port *p);
 extern void br_stp_recalculate_bridge_id(struct net_bridge *br);
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index f9ff4d5..ebb0861 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -370,11 +370,11 @@ static void br_make_blocking(struct net_bridge_po=
rt *p)
 static void br_make_forwarding(struct net_bridge_port *p)
 {
 	if (p->state =3D=3D BR_STATE_BLOCKING) {
-		if (p->br->stp_enabled) {
+		if (p->br->stp_enabled =3D=3D BR_KERNEL_STP)
 			p->state =3D BR_STATE_LISTENING;
-		} else {
+		else
 			p->state =3D BR_STATE_LEARNING;
-		}
+
 		br_log_state(p);
 		mod_timer(&p->forward_delay_timer, jiffies + p->br->forward_delay);	=
}
 }
@@ -384,6 +384,10 @@ void br_port_state_selection(struct net_bridge *br=
)
 {
 	struct net_bridge_port *p;
=20
+	/* Don't change port states if userspace is handling STP */
+	if (br->stp_enabled =3D=3D BR_USER_STP)
+		return;
+
 	list_for_each_entry(p, &br->port_list, list) {
 		if (p->state !=3D BR_STATE_DISABLED) {
 			if (p->port_no =3D=3D br->root_port) {
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index b9fb0dc..60112bc 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -33,9 +33,6 @@ static void br_send_bpdu(struct net_bridge_port *p,
 {
 	struct sk_buff *skb;
=20
-	if (!p->br->stp_enabled)
-		return;
-
 	skb =3D dev_alloc_skb(length+LLC_RESERVE);
 	if (!skb)
 		return;
@@ -75,6 +72,9 @@ void br_send_config_bpdu(struct net_bridge_port *p, s=
truct br_config_bpdu *bpdu)
 {
 	unsigned char buf[35];
=20
+	if (p->br->stp_enabled !=3D BR_KERNEL_STP)
+		return;
+
 	buf[0] =3D 0;
 	buf[1] =3D 0;
 	buf[2] =3D 0;
@@ -117,6 +117,9 @@ void br_send_tcn_bpdu(struct net_bridge_port *p)
 {
 	unsigned char buf[4];
=20
+	if (p->br->stp_enabled !=3D BR_KERNEL_STP)
+		return;
+
 	buf[0] =3D 0;
 	buf[1] =3D 0;
 	buf[2] =3D 0;
@@ -157,9 +160,13 @@ int br_stp_rcv(struct sk_buff *skb, struct net_dev=
ice *dev,
 	br =3D p->br;
 	spin_lock(&br->lock);
=20
-	if (p->state =3D=3D BR_STATE_DISABLED
-	    || !br->stp_enabled
-	    || !(br->dev->flags & IFF_UP))
+	if (br->stp_enabled !=3D BR_KERNEL_STP)
+		goto out;
+
+	if (!(br->dev->flags & IFF_UP))
+		goto out;
+
+	if (p->state =3D=3D BR_STATE_DISABLED)
 		goto out;
=20
 	if (compare_ether_addr(dest, br->group_addr) !=3D 0)
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 58d13f2..ff5380e 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -87,7 +87,6 @@ void br_stp_disable_bridge(struct net_bridge *br)
 void br_stp_enable_port(struct net_bridge_port *p)
 {
 	br_init_port(p);
-	br_ifinfo_notify(RTM_NEWLINK, p);
 	br_port_state_selection(p->br);
 }
=20
@@ -101,8 +100,6 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
 	       br->dev->name, p->port_no, p->dev->name, "disabled");
=20
-	br_ifinfo_notify(RTM_DELLINK, p);
-
 	wasroot =3D br_is_root_bridge(br);
 	br_become_designated_port(p);
 	p->state =3D BR_STATE_DISABLED;
@@ -123,6 +120,62 @@ void br_stp_disable_port(struct net_bridge_port *p=
)
 		br_become_root_bridge(br);
 }
=20
+static void br_stp_start(struct net_bridge *br)
+{
+	int r;
+	char *argv[] =3D { BR_STP_PROG, br->dev->name, "start", NULL };
+	char *envp[] =3D { NULL };
+
+	r =3D call_usermodehelper(BR_STP_PROG, argv, envp, 1);
+	if (r =3D=3D 0) {
+		br->stp_enabled =3D BR_USER_STP;
+		printk(KERN_INFO "%s: userspace STP started\n", br->dev->name);
+	} else {
+		br->stp_enabled =3D BR_KERNEL_STP;
+		printk(KERN_INFO "%s: starting userspace STP failed, "
+				"staring kernel STP\n", br->dev->name);
+
+		/* To start timers on any ports left in blocking */
+		spin_lock_bh(&br->lock);
+		br_port_state_selection(br);
+		spin_unlock_bh(&br->lock);
+	}
+}
+
+static void br_stp_stop(struct net_bridge *br)
+{
+	int r;
+	char *argv[] =3D { BR_STP_PROG, br->dev->name, "stop", NULL };
+	char *envp[] =3D { NULL };
+
+	if (br->stp_enabled =3D=3D BR_USER_STP) {
+		r =3D call_usermodehelper(BR_STP_PROG, argv, envp, 1);
+		printk(KERN_INFO "%s: userspace STP stopped, return code %d\n",
+			br->dev->name, r);
+
+
+		/* To start timers on any ports left in blocking */
+		spin_lock_bh(&br->lock);
+		br_port_state_selection(br);
+		spin_unlock_bh(&br->lock);
+	}
+
+	br->stp_enabled =3D BR_NO_STP;
+}
+
+void br_stp_set_enabled(struct net_bridge *br, unsigned long val)
+{
+	ASSERT_RTNL();
+
+	if (val) {
+		if (br->stp_enabled =3D=3D BR_NO_STP)
+			br_stp_start(br);
+	} else {
+		if (br->stp_enabled !=3D BR_NO_STP)
+			br_stp_stop(br);
+	}
+}
+
 /* called under bridge lock */
 void br_stp_change_bridge_id(struct net_bridge *br, const unsigned cha=
r *addr)
 {
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 01a22ad..7ec0b76 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -149,7 +149,9 @@ static ssize_t show_stp_state(struct device *d,
=20
 static void set_stp_state(struct net_bridge *br, unsigned long val)
 {
-	br->stp_enabled =3D val;
+	spin_unlock_bh(&br->lock);
+	br_stp_set_enabled(br, val);
+	spin_lock_bh(&br->lock);
 }
=20
 static ssize_t store_stp_state(struct device *d,
@@ -309,6 +311,19 @@ static ssize_t store_group_addr(struct device *d,
 static DEVICE_ATTR(group_addr, S_IRUGO | S_IWUSR,
 		   show_group_addr, store_group_addr);
=20
+static ssize_t store_flush(struct device *d,
+			   struct device_attribute *attr,
+			   const char *buf, size_t len)
+{
+	struct net_bridge *br =3D to_bridge(d);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	br_fdb_flush(br);
+	return len;
+}
+static DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
=20
 static struct attribute *bridge_attrs[] =3D {
 	&dev_attr_forward_delay.attr,
@@ -328,6 +343,7 @@ static struct attribute *bridge_attrs[] =3D {
 	&dev_attr_topology_change_timer.attr,
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
+	&dev_attr_flush.attr,
 	NULL
 };
=20
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 0bc2aef..2da2292 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -137,6 +137,13 @@ static ssize_t show_hold_timer(struct net_bridge_p=
ort *p,
 }
 static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
=20
+static ssize_t store_flush(struct net_bridge_port *p, unsigned long v)
+{
+	br_fdb_delete_by_port(p->br, p, 0); // Don't delete local entry
+	return 0;
+}
+static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
+
 static struct brport_attribute *brport_attrs[] =3D {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
@@ -152,6 +159,7 @@ static struct brport_attribute *brport_attrs[] =3D =
{
 	&brport_attr_message_age_timer,
 	&brport_attr_forward_delay_timer,
 	&brport_attr_hold_timer,
+	&brport_attr_flush,
 	NULL
 };
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index c484fcf..08dcfeb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1690,31 +1690,37 @@ static inline int deliver_skb(struct sk_buff *s=
kb,
 }
=20
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
-int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff =
**pskb);
+/* These hooks defined here for ATM */
 struct net_bridge;
 struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
 						unsigned char *addr);
-void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
+void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent) __read_mostl=
y;
=20
-static __inline__ int handle_bridge(struct sk_buff **pskb,
-				    struct packet_type **pt_prev, int *ret,
-				    struct net_device *orig_dev)
+/*
+ * If bridge module is loaded call bridging hook.
+ *  returns NULL if packet was consumed.
+ */
+struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
+					struct sk_buff *skb) __read_mostly;
+static inline struct sk_buff *handle_bridge(struct sk_buff *skb,
+					    struct packet_type **pt_prev, int *ret,
+					    struct net_device *orig_dev)
 {
 	struct net_bridge_port *port;
=20
-	if ((*pskb)->pkt_type =3D=3D PACKET_LOOPBACK ||
-	    (port =3D rcu_dereference((*pskb)->dev->br_port)) =3D=3D NULL)
-		return 0;
+	if (skb->pkt_type =3D=3D PACKET_LOOPBACK ||
+	    (port =3D rcu_dereference(skb->dev->br_port)) =3D=3D NULL)
+		return skb;
=20
 	if (*pt_prev) {
-		*ret =3D deliver_skb(*pskb, *pt_prev, orig_dev);
+		*ret =3D deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev =3D NULL;
 	}
=20
-	return br_handle_frame_hook(port, pskb);
+	return br_handle_frame_hook(port, skb);
 }
 #else
-#define handle_bridge(skb, pt_prev, ret, orig_dev)	(0)
+#define handle_bridge(skb, pt_prev, ret, orig_dev)	(skb)
 #endif
=20
 #ifdef CONFIG_NET_CLS_ACT
@@ -1821,7 +1827,8 @@ int netif_receive_skb(struct sk_buff *skb)
 ncls:
 #endif
=20
-	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
+	skb =3D handle_bridge(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
 		goto out;
=20
 	type =3D skb->protocol;
