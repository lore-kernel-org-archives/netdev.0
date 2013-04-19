From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 5/6] bridge: Automatically set promisc on uplink ports.
Date: Fri, 19 Apr 2013 16:52:49 -0400
Message-ID: <1366404770-28523-6-git-send-email-vyasevic@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932474Ab3DSUw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:59 -0400
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we now support adding HW mac addresses to uplink ports, we can make
uplinks non-promisc in certain situations.  To aid in this determination
we introduce a concept of dynamic port.  "Dynamic port" is a port in its
default default state without any statically configured FDB entries that
are meant to be added to the uplink.  Now the promisc selection can be
done as follows:
 Case A: 0 uplinks and 0 dynamic ports
   - In this case, there are no uplinks specified, and the user has
     manually specified the neighbors for all ports.  Every port in
     this case can be non-promisc since we know how to reach all the
     neighbors.  A sample use case is a routed bridge.
 Case B: 1 dynamic port (uplink)
   - Uplink is always considered a dynamic port.  If it is the only
     one, and all other ports have static FDBs, then the uplink can
     be non-promisc.  A sample use case is a VM hypervisior with a
     single uplink and a bunch of VMs each of which provides the
     addresses it will use.
 Case C: any other combination
   - If we have have more then 1 dynamic port, whether it be another
     uplink or simply a non statically programmed port, then all ports
     needs to be promisc so we can reach any neighbors that may be
     behind the dynamic port.


Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |   35 ++++++++++++++++++++++++-
 net/bridge/br_fdb.c     |   64 ++++++++++++++++++++++++++++++++++++++--------
 net/bridge/br_if.c      |   48 +++++++++++++++++++++--------------
 net/bridge/br_private.h |    8 +++++-
 net/core/dev.c          |    1 +
 5 files changed, 123 insertions(+), 33 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5c3c904..470fb1b 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -108,12 +108,43 @@ static void br_dev_set_rx_mode(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *port;
-
+	u32 dp = br->dynamic_ports;
+	u32 up = br->uplink_ports;
+
+	/* Prereq: Uplink ports are always dynamic.
+	 *
+	 * Case A: 0 dynamic ports
+	 *  - all non-promisc with synced addrs.
+	 * Case B: 1 dynamic port (uplink)
+	 *  - uplink is non-promisc, other ports are promisc
+	 * Case C: any other combination
+	 *  - all promisc, no need to sync.
+	 */
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &br->port_list, list) {
-		if (port->flags & BR_UPLINK) {
+		unsigned long promisc = BR_PROMISC;
+
+		if (up == 0 && dp == 0) {
+			/* Case A */
+			dev_uc_sync_multiple(port->dev, dev);
+			dev_uc_sync_multiple(port->dev, dev);
+			promisc = 0;
+		} else if (dp == 1 && (port->flags & BR_UPLINK)) {
+			/* Case B */
 			dev_uc_sync_multiple(port->dev, dev);
 			dev_mc_sync_multiple(port->dev, dev);
+			promisc = 0;
+		}
+
+		/* Set proper promisc mode if it needs to change */
+		if ((port->flags & BR_PROMISC) != promisc) {
+			if (promisc) {
+				port->flags |= BR_PROMISC;
+				dev_set_promiscuity(dev, 1);
+			} else {
+				port->flags &= ~BR_PROMISC;
+				dev_set_promiscuity(dev, -1);
+			}
 		}
 	}
 	rcu_read_unlock();
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5585e00..5a18c2e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -89,6 +89,36 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
 
+static void fdb_static_count_inc(struct net_bridge_port *p)
+{
+	p->static_cnt++;
+
+	/* Uplink always counts as dynamic port */
+	if (p->flags & BR_UPLINK)
+		return;
+
+	/* If this is the first static fdb entry, decrement the number of
+	 * number of dynamic ports.
+	 */
+	if (p->static_cnt == 1)
+		p->br->dynamic_ports--;
+}
+
+static void fdb_static_count_dec(struct net_bridge_port *p)
+{
+	p->static_cnt--;
+
+	/* Uplink always counts as dynamic port */
+	if (p->flags & BR_UPLINK)
+		return;
+
+	/* If this was the last static fdb entry for this port, add the
+	 * port back to dynamic count.
+	 */
+	if (!p->static_cnt)
+		p->br->dynamic_ports++;
+}
+
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br = p->br;
@@ -218,7 +248,7 @@ void br_fdb_flush(struct net_bridge *br)
  * if do_all is set also flush static entries
  */
 void br_fdb_delete_by_port(struct net_bridge *br,
-			   const struct net_bridge_port *p,
+			   struct net_bridge_port *p,
 			   int do_all)
 {
 	int i;
@@ -235,6 +265,10 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 
 			if (f->is_static && !do_all)
 				continue;
+
+			if (f->is_uplink)
+				fdb_static_count_dec(p);
+
 			/*
 			 * if multiple ports all have the same device address
 			 * then when one port is deleted, assign
@@ -386,7 +420,8 @@ static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
 					       const unsigned char *addr,
-					       __u16 vid)
+					       __u16 vid,
+					       bool uplink)
 {
 	struct net_bridge_fdb_entry *fdb;
 
@@ -397,6 +432,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 		fdb->vlan_id = vid;
 		fdb->is_local = 0;
 		fdb->is_static = 0;
+		fdb->is_uplink = uplink;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
@@ -425,7 +461,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		fdb_delete(br, fdb);
 	}
 
-	fdb = fdb_create(head, source, addr, vid);
+	fdb = fdb_create(head, source, addr, vid, false);
 	if (!fdb)
 		return -ENOMEM;
 
@@ -477,7 +513,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	} else {
 		spin_lock(&br->hash_lock);
 		if (likely(!fdb_find(head, addr, vid))) {
-			fdb = fdb_create(head, source, addr, vid);
+			fdb = fdb_create(head, source, addr, vid, false);
 			if (fdb)
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
@@ -610,7 +646,7 @@ out:
 
 /* Update (create or replace) forwarding database entry */
 static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
-			 __u16 state, __u16 flags, __u16 vid)
+			 __u16 state, __u16 flags, __u16 vid, bool uplink)
 {
 	struct net_bridge *br = source->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
@@ -621,7 +657,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		fdb = fdb_create(head, source, addr, vid);
+		fdb = fdb_create(head, source, addr, vid, uplink);
 		if (!fdb)
 			return -ENOMEM;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
@@ -658,7 +694,8 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
 	} else {
 		spin_lock_bh(&p->br->hash_lock);
 		err = fdb_add_entry(p, addr, ndm->ndm_state,
-				    nlh_flags, vid);
+				    nlh_flags, vid,
+				    ndm->ndm_flags & BR_UPLINK);
 		spin_unlock_bh(&p->br->hash_lock);
 	}
 
@@ -731,14 +768,16 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 				goto out;
 		}
 	}
-
 uplink:
 	/* Check to see if  the user requested this address be added to
 	 * uplink
 	 */
-	if (ndm->ndm_flags & NTF_UPLINK)
+	if (ndm->ndm_flags & NTF_UPLINK) {
+		fdb_static_count_inc(p);
 		err = ndo_dflt_fdb_add(ndm, tb, p->br->dev, addr, nlh_flags);
-
+		if (err)
+			fdb_static_count_dec(p);
+	}
 out:
 	return err;
 }
@@ -832,8 +871,11 @@ uplink:
 	/* Check to see if  the user requested this address be removed
 	 * from uplink
 	 */
-	if (ndm->ndm_flags & NTF_UPLINK)
+	if (ndm->ndm_flags & NTF_UPLINK) {
 		err = ndo_dflt_fdb_del(ndm, tb, p->br->dev, addr);
+		if (!err)
+			fdb_static_count_dec(p);
+	}
 out:
 	return err;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7c74cd5..c62da60 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -132,7 +132,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	sysfs_remove_link(br->ifobj, p->dev->name);
 
-	dev_set_promiscuity(dev, -1);
+	if (p->flags & BR_PROMISC)
+		dev_set_promiscuity(dev, -1);
 
 	spin_lock_bh(&br->lock);
 	br_stp_disable_port(p);
@@ -142,13 +143,19 @@ static void del_nbp(struct net_bridge_port *p)
 
 	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 1);
-	if (p->flags & BR_UPLINK) {
-		dev_uc_unsync(dev, br->dev);
-		dev_mc_unsync(dev, br->dev);
-	}
+
+	/* Remove any bridge hw addresses from the port device */
+	dev_uc_unsync(dev, br->dev);
+	dev_mc_unsync(dev, br->dev);
+	dev_uc_del(p->dev, br->dev->dev_addr);
 
 	list_del_rcu(&p->list);
 
+	/* Now that the port has been removed, call dev_set_rx_mode()
+	 * so that the port removal may be recorded.
+	 */
+	dev_set_rx_mode(br->dev);
+
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
@@ -353,14 +360,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	call_netdevice_notifiers(NETDEV_JOIN, dev);
 
-	err = dev_set_promiscuity(dev, 1);
-	if (err)
-		goto put_back;
-
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
-		goto err1;
+		goto put_back;
 
 	err = br_sysfs_addif(p);
 	if (err)
@@ -382,6 +385,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	dev_disable_lro(dev);
 
 	list_add_rcu(&p->list, &br->port_list);
+	br->dynamic_ports++;
 
 	netdev_update_features(br->dev);
 
@@ -405,6 +409,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
+	dev_set_rx_mode(br->dev);
+
 	return 0;
 
 err5:
@@ -416,8 +422,6 @@ err3:
 err2:
 	kobject_put(&p->kobj);
 	p = NULL; /* kobject_put frees */
-err1:
-	dev_set_promiscuity(dev, -1);
 put_back:
 	dev_put(dev);
 	kfree(p);
@@ -460,16 +464,22 @@ void br_manage_uplinks(struct net_bridge_port *p, unsigned long mask)
 		return;
 
 	if (p->flags & BR_UPLINK) {
-		/* Newly marked uplink port.  Sync all of device addresses
-		 * to it.
+		/* Uplinks are always considered dynamic ports, so if
+		 * any static fdbs are configured, we need to add this
+		 * port back to dynamic count.
 		 */
-		dev_uc_sync(p->dev, br->dev);
-		dev_mc_sync(p->dev, br->dev);
+		br->uplink_ports++;
+		if (p->static_cnt)
+			br->dynamic_ports++;
 	} else {
-		/* Uplink was unmakred.  Remove device addresses */
-		dev_uc_unsync(p->dev, br->dev);
-		dev_mc_unsync(p->dev, br->dev);
+		/* Uplink flag was turned off.  This port can once again
+		 * be removed from the dynamic count.
+		 */
+		br->uplink_ports--;
+		if (p->static_cnt)
+			br->dynamic_ports--;
 	}
+	dev_set_rx_mode(br->dev);
 }
 
 void __net_exit br_net_exit(struct net *net)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c43374a..40ac501 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -90,6 +90,7 @@ struct net_bridge_fdb_entry
 	mac_addr			addr;
 	unsigned char			is_local;
 	unsigned char			is_static;
+	bool				is_uplink;
 	__u16				vlan_id;
 };
 
@@ -157,6 +158,9 @@ struct net_bridge_port
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
 #define BR_UPLINK		0x00000010
+#define BR_PROMISC		0x80000000
+
+	u32				static_cnt;
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
@@ -282,6 +286,8 @@ struct net_bridge
 	u8				vlan_enabled;
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
+	u32				dynamic_ports;
+	u32				uplink_ports;
 };
 
 struct br_input_skb_cb {
@@ -375,7 +381,7 @@ extern void br_fdb_changeaddr(struct net_bridge_port *p,
 extern void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
 extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
-				  const struct net_bridge_port *p, int do_all);
+				  struct net_bridge_port *p, int do_all);
 extern struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
 						 const unsigned char *addr,
 						 __u16 vid);
diff --git a/net/core/dev.c b/net/core/dev.c
index fad4c38..471081b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4587,6 +4587,7 @@ void dev_set_rx_mode(struct net_device *dev)
 	__dev_set_rx_mode(dev);
 	netif_addr_unlock_bh(dev);
 }
+EXPORT_SYMBOL(dev_set_rx_mode);
 
 /**
  *	dev_get_flags - get flags reported to userspace
-- 
1.7.7.6
