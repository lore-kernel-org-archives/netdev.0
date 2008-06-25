From: Ben Greear <greearb@candelatech.com>
Subject: RFC:  Patch to add support for multiple multicast routing tables.
Date: Tue, 24 Jun 2008 17:50:51 -0700
Message-ID: <4861966B.5090208@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070703070400080300040301"
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:37515 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbYFYAuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 20:50:54 -0400
Received: from [71.113.76.161] (pool-71-113-76-161.sttlwa.dsl-w.verizon.net [71.113.76.161])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m5P0opMe032080
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 17:50:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070703070400080300040301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In order to run multiple Xorp instances and treat different groups of
interfaces as being in their own virtual router, I had to update the
ipv4/ipmr.c logic to support multiple routing tables.

I will be attempting to push the cooresponding xorp changes to it's
maintainers if this is accepted into the kernel.  It should be fully
backwards compatible with existing xorp and other multicast
routing tools.  It does change the procfs output slightly, adding
a TableId column.

The original patch was written by me, and then Patrick McHardy
fixed up my cruft and made it much smaller and with better locking.
I then fixed a few bugs I found while testing with my modified xorp.

The attached patch is against 2.6.25.4 + hacks.  It has a few rejects 
against 2.6.26.rc7,
but I will fix those sooner rather than later if the patch is otherwise 
deemed
worthy.

Please let me know if this stands a chance of inclusion.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



--------------070703070400080300040301
Content-Type: text/x-patch;
 name="patch2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch2.patch"

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 35a8277..d6abe2a 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -30,11 +30,16 @@
 #define SIOCGETSGCNT	(SIOCPROTOPRIVATE+1)
 #define SIOCGETRPF	(SIOCPROTOPRIVATE+2)
 
+#define SIOCGETVIFCNT_NG	(SIOCPROTOPRIVATE+3)
+#define SIOCGETSGCNT_NG		(SIOCPROTOPRIVATE+4)
+
 #define MAXVIFS		32	
 typedef unsigned long vifbitmap_t;	/* User mode code depends on this lot */
 typedef unsigned short vifi_t;
 #define ALL_VIFS	((vifi_t)(-1))
 
+#define DFLT_MROUTE_TBL RT_TABLE_MAIN
+
 /*
  *	Same idea as select
  */
@@ -60,6 +65,11 @@ struct vifctl {
 	struct in_addr vifc_rmt_addr;	/* IPIP tunnel addr */
 };
 
+struct vifctl_ng {
+	struct vifctl vif;
+	unsigned table_id;
+};
+
 #define VIFF_TUNNEL	0x1	/* IPIP tunnel */
 #define VIFF_SRCRT	0x2	/* NI */
 #define VIFF_REGISTER	0x4	/* register vif	*/
@@ -80,6 +90,18 @@ struct mfcctl
 	int	     mfcc_expire;
 };
 
+struct mfcctl_ng
+{
+	struct mfcctl mfc;
+	unsigned int table_id;
+};
+
+struct mrt_sockopt_simple
+{
+	unsigned int optval;
+	unsigned int table_id;
+};
+
 /* 
  *	Group count retrieval for mrouted
  */
@@ -93,6 +115,12 @@ struct sioc_sg_req
 	unsigned long wrong_if;
 };
 
+struct sioc_sg_req_ng
+{
+	struct sioc_sg_req req;
+	unsigned int table_id;
+};
+
 /*
  *	To get vif packet counts
  */
@@ -106,6 +134,12 @@ struct sioc_vif_req
 	unsigned long obytes;	/* Out bytes */
 };
 
+struct sioc_vif_req_ng
+{
+	struct sioc_vif_req vif;
+	unsigned int table_id;
+};
+
 /*
  *	This is the format the mroute daemon expects to see IGMP control
  *	data. Magically happens to be like an IP packet as per the original
@@ -156,6 +190,8 @@ struct vif_device
 	unsigned short	flags;			/* Control flags 		*/
 	__be32		local,remote;		/* Addresses(remote for tunnels)*/
 	int		link;			/* Physical interface index	*/
+	int		vif_index;		/* Index in vif_table		*/
+	unsigned int	table_id;               /* table-id that this vif belongs to */
 };
 
 #define VIFF_STATIC 0x8000
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 30064d7..c4761f1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -43,6 +43,10 @@
 
 #include <net/net_namespace.h>
 
+#ifdef CONFIG_IP_MROUTE
+struct ipmr_table;
+#endif
+
 struct vlan_group;
 struct ethtool_ops;
 struct netpoll_info;
@@ -728,6 +732,11 @@ struct net_device
 				     */
 	long dflt_skb_mark; /* Specify skb->mark for pkts received on this interface. */
 
+#ifdef CONFIG_IP_MROUTE
+	/* IPv4 Multicast Routing Table for tis device. */
+	struct ipmr_table* mrt_entry;
+#endif
+
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
 	/* macvlan */
diff --git a/net/core/dev.c b/net/core/dev.c
index 617a49a..02b7f41 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -120,6 +120,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/mroute.h>
 
 #include "net-sysfs.h"
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a94f52c..410b785 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -69,8 +69,23 @@
 #define CONFIG_IP_PIMSM	1
 #endif
 
-static struct sock *mroute_socket;
+struct ipmr_table {
+	struct list_head	list;
+	struct sock		*mroute_socket;
+	struct vif_device	vif_table[MAXVIFS];	     /* Devices */
+	int			maxvif;
+	int			mroute_do_assert;	     /* Set in PIM assert */
+	int			mroute_do_pim;
+	struct mfc_cache	*mfc_cache_array[MFC_LINES]; /* Forwarding cache */
+	struct mfc_cache	*mfc_unres_queue;	     /* Queue of unresolved entries */
+	atomic_t		cache_resolve_queue_len;     /* Size of unresolved */
+	/* Special spinlock for queue of unresolved entries */
+	spinlock_t		mfc_unres_lock;
+	int			reg_vif_num;
+	unsigned int		id;			     /* Table ID */
+};
 
+static int mroute_pim_cnt;
 
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
@@ -82,21 +97,7 @@ static DEFINE_RWLOCK(mrt_lock);
  *	Multicast router control variables
  */
 
-static struct vif_device vif_table[MAXVIFS];		/* Devices 		*/
-static int maxvif;
-
-#define VIF_EXISTS(idx) (vif_table[idx].dev != NULL)
-
-static int mroute_do_assert;				/* Set in PIM assert	*/
-static int mroute_do_pim;
-
-static struct mfc_cache *mfc_cache_array[MFC_LINES];	/* Forwarding cache	*/
-
-static struct mfc_cache *mfc_unres_queue;		/* Queue of unresolved entries */
-static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
-
-/* Special spinlock for queue of unresolved entries */
-static DEFINE_SPINLOCK(mfc_unres_lock);
+#define VIF_EXISTS(table, idx) (table->vif_table[idx].dev != NULL)
 
 /* We return to original Alan's scheme. Hash table of resolved
    entries is changed only in process context and protected
@@ -108,9 +109,9 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 
 static struct kmem_cache *mrt_cachep __read_mostly;
 
-static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local);
-static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
-static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
+static int ip_mr_forward(struct ipmr_table *table, struct sk_buff *skb, struct mfc_cache *cache, int local);
+static int ipmr_cache_report(struct ipmr_table *table, struct sk_buff *pkt, vifi_t vifi, int assert);
+static int ipmr_fill_mroute(struct ipmr_table *table, struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
 
 #ifdef CONFIG_IP_PIMSM_V2
 static struct net_protocol pim_protocol;
@@ -118,6 +119,48 @@ static struct net_protocol pim_protocol;
 
 static struct timer_list ipmr_expire_timer;
 
+#define IPMR_HSIZE	256
+static struct list_head ipmr_table_hash[IPMR_HSIZE];
+static DEFINE_SPINLOCK(ipmr_hash_lock);
+
+static struct ipmr_table *ipmr_table_create(unsigned int id)
+{
+	struct ipmr_table *table;
+	unsigned int i;
+
+	table = kzalloc(sizeof(*table), GFP_KERNEL);
+	if (!table)
+		return table;
+	spin_lock_init(&table->mfc_unres_lock);
+	table->id = id;
+	table->reg_vif_num = -1;
+	for (i = 0; i < ARRAY_SIZE(table->vif_table); i++) {
+		table->vif_table[i].vif_index = i;
+		table->vif_table[i].table_id = id;
+	}
+
+	spin_lock(&ipmr_hash_lock);
+	list_add_tail_rcu(&table->list, &ipmr_table_hash[id & (IPMR_HSIZE -1)]);
+	spin_unlock(&ipmr_hash_lock);
+	return table;
+}
+
+static struct ipmr_table *ipmr_table_lookup(unsigned int id)
+{
+	struct ipmr_table *table;
+
+	/* Tables never get freed, so rcu_read_lock() or refcounting is
+	 * unnecessary here. The _rcu variant is just to protect against
+	 * concurrent additions.
+	 */
+	list_for_each_entry_rcu(table, &ipmr_table_hash[id & (IPMR_HSIZE - 1)],
+                                list) {
+		if (table->id == id)
+			return table;
+	}
+	return NULL;
+}
+
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */
 
 static
@@ -176,15 +219,20 @@ failure:
 
 #ifdef CONFIG_IP_PIMSM
 
-static int reg_vif_num = -1;
-
 static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct ipmr_table *table;
+
+	table = dev->mrt_entry;
+	if (!table)
+		goto out;
+
 	read_lock(&mrt_lock);
 	((struct net_device_stats*)netdev_priv(dev))->tx_bytes += skb->len;
 	((struct net_device_stats*)netdev_priv(dev))->tx_packets++;
-	ipmr_cache_report(skb, reg_vif_num, IGMPMSG_WHOLEPKT);
+	ipmr_cache_report(table, skb, table->reg_vif_num, IGMPMSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
+out:
 	kfree_skb(skb);
 	return 0;
 }
@@ -204,12 +252,14 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 }
 
-static struct net_device *ipmr_reg_vif(void)
+static struct net_device *ipmr_reg_vif(struct ipmr_table *table)
 {
 	struct net_device *dev;
 	struct in_device *in_dev;
+	char name[IFNAMSIZ];
 
-	dev = alloc_netdev(sizeof(struct net_device_stats), "pimreg",
+	snprintf(name, sizeof(name), "pimreg%u", table->id);
+	dev = alloc_netdev(sizeof(struct net_device_stats), name,
 			   reg_vif_setup);
 
 	if (dev == NULL)
@@ -250,38 +300,41 @@ failure:
  *	Delete a VIF entry
  */
 
-static int vif_delete(int vifi)
+static int vif_delete(struct ipmr_table *table, int vifi)
 {
 	struct vif_device *v;
 	struct net_device *dev;
 	struct in_device *in_dev;
 
-	if (vifi < 0 || vifi >= maxvif)
+	if (vifi < 0 || vifi >= table->maxvif)
 		return -EADDRNOTAVAIL;
 
-	v = &vif_table[vifi];
+	v = &table->vif_table[vifi];
 
 	write_lock_bh(&mrt_lock);
 	dev = v->dev;
 	v->dev = NULL;
 
-	if (!dev) {
+	if (dev) {
+		dev->mrt_entry = NULL;
+	}
+	else {
 		write_unlock_bh(&mrt_lock);
 		return -EADDRNOTAVAIL;
 	}
 
 #ifdef CONFIG_IP_PIMSM
-	if (vifi == reg_vif_num)
-		reg_vif_num = -1;
+	if (vifi == table->reg_vif_num)
+		table->reg_vif_num = -1;
 #endif
 
-	if (vifi+1 == maxvif) {
+	if (vifi + 1 == table->maxvif) {
 		int tmp;
 		for (tmp=vifi-1; tmp>=0; tmp--) {
-			if (VIF_EXISTS(tmp))
+			if (VIF_EXISTS(table, tmp))
 				break;
 		}
-		maxvif = tmp+1;
+		table->maxvif = tmp + 1;
 	}
 
 	write_unlock_bh(&mrt_lock);
@@ -304,12 +357,12 @@ static int vif_delete(int vifi)
    and reporting error to netlink readers.
  */
 
-static void ipmr_destroy_unres(struct mfc_cache *c)
+static void ipmr_destroy_unres(struct ipmr_table *table, struct mfc_cache *c)
 {
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
 
-	atomic_dec(&cache_resolve_queue_len);
+	atomic_dec(&table->cache_resolve_queue_len);
 
 	while ((skb=skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
@@ -336,44 +389,54 @@ static void ipmr_expire_process(unsigned long dummy)
 {
 	unsigned long now;
 	unsigned long expires;
+	unsigned long interval;
 	struct mfc_cache *c, **cp;
+	struct ipmr_table *table;
+	unsigned int i;
+	int rearm = 0;
 
-	if (!spin_trylock(&mfc_unres_lock)) {
-		mod_timer(&ipmr_expire_timer, jiffies+HZ/10);
-		return;
-	}
+	expires = 10 * HZ;
 
-	if (atomic_read(&cache_resolve_queue_len) == 0)
-		goto out;
+	for (i = 0; i < IPMR_HSIZE; i++) {
+		list_for_each_entry_rcu(table, &ipmr_table_hash[i], list) {
+			if (!spin_trylock(&table->mfc_unres_lock))
+				goto next;
 
-	now = jiffies;
-	expires = 10*HZ;
-	cp = &mfc_unres_queue;
+			if (atomic_read(&table->cache_resolve_queue_len) == 0)
+				continue;
 
-	while ((c=*cp) != NULL) {
-		if (time_after(c->mfc_un.unres.expires, now)) {
-			unsigned long interval = c->mfc_un.unres.expires - now;
-			if (interval < expires)
-				expires = interval;
-			cp = &c->next;
-			continue;
-		}
+			now = jiffies;
+			cp = &table->mfc_unres_queue;
+
+			while ((c = *cp) != NULL) {
+				if (time_after(c->mfc_un.unres.expires, now)) {
+					interval = c->mfc_un.unres.expires - now;
+					if (interval < expires)
+						expires = interval;
+					cp = &c->next;
+					continue;
+				}
 
-		*cp = c->next;
+				*cp = c->next;
+
+				ipmr_destroy_unres(table, c);
+			}
 
-		ipmr_destroy_unres(c);
+			spin_unlock(&table->mfc_unres_lock);
+next:
+			if (atomic_read(&table->cache_resolve_queue_len))
+				rearm = 1;
+		}
 	}
 
-	if (atomic_read(&cache_resolve_queue_len))
+	if (rearm)
 		mod_timer(&ipmr_expire_timer, jiffies + expires);
-
-out:
-	spin_unlock(&mfc_unres_lock);
 }
 
 /* Fill oifs list. It is called under write locked mrt_lock. */
 
-static void ipmr_update_thresholds(struct mfc_cache *cache, unsigned char *ttls)
+static void ipmr_update_thresholds(struct ipmr_table *table,
+				   struct mfc_cache *cache, unsigned char *ttls)
 {
 	int vifi;
 
@@ -381,8 +444,8 @@ static void ipmr_update_thresholds(struct mfc_cache *cache, unsigned char *ttls)
 	cache->mfc_un.res.maxvif = 0;
 	memset(cache->mfc_un.res.ttls, 255, MAXVIFS);
 
-	for (vifi=0; vifi<maxvif; vifi++) {
-		if (VIF_EXISTS(vifi) && ttls[vifi] && ttls[vifi] < 255) {
+	for (vifi = 0; vifi < table->maxvif; vifi++) {
+		if (VIF_EXISTS(table, vifi) && ttls[vifi] && ttls[vifi] < 255) {
 			cache->mfc_un.res.ttls[vifi] = ttls[vifi];
 			if (cache->mfc_un.res.minvif > vifi)
 				cache->mfc_un.res.minvif = vifi;
@@ -392,15 +455,15 @@ static void ipmr_update_thresholds(struct mfc_cache *cache, unsigned char *ttls)
 	}
 }
 
-static int vif_add(struct vifctl *vifc, int mrtsock)
+static int vif_add(struct ipmr_table *table, struct vifctl *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
-	struct vif_device *v = &vif_table[vifi];
+	struct vif_device *v = &table->vif_table[vifi];
 	struct net_device *dev;
 	struct in_device *in_dev;
 
 	/* Is vif busy ? */
-	if (VIF_EXISTS(vifi))
+	if (VIF_EXISTS(table, vifi))
 		return -EADDRINUSE;
 
 	switch (vifc->vifc_flags) {
@@ -410,9 +473,9 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		 * Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
-		if (reg_vif_num >= 0)
+		if (table->reg_vif_num >= 0)
 			return -EADDRINUSE;
-		dev = ipmr_reg_vif();
+		dev = ipmr_reg_vif(table);
 		if (!dev)
 			return -ENOBUFS;
 		break;
@@ -426,6 +489,12 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
 		if (!dev)
 			return -EADDRNOTAVAIL;
+		if (dev->mrt_entry && (dev->mrt_entry != table)) {
+			printk("ERROR:  Device: %s is already in multicast routing table: %d\n",
+			       dev->name, dev->mrt_entry->id);
+			return -EADDRNOTAVAIL;
+		}
+
 		dev_put(dev);
 		break;
 	default:
@@ -460,22 +529,24 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
 	write_lock_bh(&mrt_lock);
 	dev_hold(dev);
 	v->dev=dev;
+	dev->mrt_entry = table;
 #ifdef CONFIG_IP_PIMSM
 	if (v->flags&VIFF_REGISTER)
-		reg_vif_num = vifi;
+		table->reg_vif_num = vifi;
 #endif
-	if (vifi+1 > maxvif)
-		maxvif = vifi+1;
+	if (vifi+1 > table->maxvif)
+		table->maxvif = vifi+1;
 	write_unlock_bh(&mrt_lock);
 	return 0;
 }
 
-static struct mfc_cache *ipmr_cache_find(__be32 origin, __be32 mcastgrp)
+static struct mfc_cache *ipmr_cache_find(struct ipmr_table *table,
+					 __be32 origin, __be32 mcastgrp)
 {
 	int line=MFC_HASH(mcastgrp,origin);
 	struct mfc_cache *c;
 
-	for (c=mfc_cache_array[line]; c; c = c->next) {
+	for (c = table->mfc_cache_array[line]; c; c = c->next) {
 		if (c->mfc_origin==origin && c->mfc_mcastgrp==mcastgrp)
 			break;
 	}
@@ -508,7 +579,8 @@ static struct mfc_cache *ipmr_cache_alloc_unres(void)
  *	A cache entry has gone into a resolved state from queued
  */
 
-static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
+static void ipmr_cache_resolve(struct ipmr_table *table, struct mfc_cache *uc,
+			       struct mfc_cache *c)
 {
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
@@ -521,7 +593,7 @@ static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
-			if (ipmr_fill_mroute(skb, c, NLMSG_DATA(nlh)) > 0) {
+			if (ipmr_fill_mroute(table, skb, c, NLMSG_DATA(nlh)) > 0) {
 				nlh->nlmsg_len = (skb_tail_pointer(skb) -
 						  (u8 *)nlh);
 			} else {
@@ -535,7 +607,7 @@ static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
 
 			rtnl_unicast(skb, &init_net, NETLINK_CB(skb).pid);
 		} else
-			ip_mr_forward(skb, c, 0);
+			ip_mr_forward(table, skb, c, 0);
 	}
 }
 
@@ -546,7 +618,8 @@ static void ipmr_cache_resolve(struct mfc_cache *uc, struct mfc_cache *c)
  *	Called under mrt_lock.
  */
 
-static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
+static int ipmr_cache_report(struct ipmr_table *table, struct sk_buff *pkt,
+			     vifi_t vifi, int assert)
 {
 	struct sk_buff *skb;
 	const int ihl = ip_hdrlen(pkt);
@@ -578,7 +651,7 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 		memcpy(msg, skb_network_header(pkt), sizeof(struct iphdr));
 		msg->im_msgtype = IGMPMSG_WHOLEPKT;
 		msg->im_mbz = 0;
-		msg->im_vif = reg_vif_num;
+		msg->im_vif = table->reg_vif_num;
 		ip_hdr(skb)->ihl = sizeof(struct iphdr) >> 2;
 		ip_hdr(skb)->tot_len = htons(ntohs(ip_hdr(pkt)->tot_len) +
 					     sizeof(struct iphdr));
@@ -610,7 +683,7 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 	skb->transport_header = skb->network_header;
 	}
 
-	if (mroute_socket == NULL) {
+	if (table->mroute_socket == NULL) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -618,7 +691,7 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
 	/*
 	 *	Deliver to mrouted
 	 */
-	if ((ret=sock_queue_rcv_skb(mroute_socket,skb))<0) {
+	if ((ret = sock_queue_rcv_skb(table->mroute_socket, skb)) < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
 		kfree_skb(skb);
@@ -632,14 +705,14 @@ static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert)
  */
 
 static int
-ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
+ipmr_cache_unresolved(struct ipmr_table *table, vifi_t vifi, struct sk_buff *skb)
 {
 	int err;
 	struct mfc_cache *c;
 	const struct iphdr *iph = ip_hdr(skb);
 
-	spin_lock_bh(&mfc_unres_lock);
-	for (c=mfc_unres_queue; c; c=c->next) {
+	spin_lock_bh(&table->mfc_unres_lock);
+	for (c = table->mfc_unres_queue; c; c = c->next) {
 		if (c->mfc_mcastgrp == iph->daddr &&
 		    c->mfc_origin == iph->saddr)
 			break;
@@ -650,9 +723,9 @@ ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
 		 *	Create a new entry if allowable
 		 */
 
-		if (atomic_read(&cache_resolve_queue_len)>=10 ||
+		if (atomic_read(&table->cache_resolve_queue_len) >= 10 ||
 		    (c=ipmr_cache_alloc_unres())==NULL) {
-			spin_unlock_bh(&mfc_unres_lock);
+			spin_unlock_bh(&table->mfc_unres_lock);
 
 			kfree_skb(skb);
 			return -ENOBUFS;
@@ -668,20 +741,21 @@ ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
 		/*
 		 *	Reflect first query at mrouted.
 		 */
-		if ((err = ipmr_cache_report(skb, vifi, IGMPMSG_NOCACHE))<0) {
+		if ((err = ipmr_cache_report(table, skb, vifi,
+					     IGMPMSG_NOCACHE)) < 0) {
 			/* If the report failed throw the cache entry
 			   out - Brad Parker
 			 */
-			spin_unlock_bh(&mfc_unres_lock);
+			spin_unlock_bh(&table->mfc_unres_lock);
 
 			kmem_cache_free(mrt_cachep, c);
 			kfree_skb(skb);
 			return err;
 		}
 
-		atomic_inc(&cache_resolve_queue_len);
-		c->next = mfc_unres_queue;
-		mfc_unres_queue = c;
+		atomic_inc(&table->cache_resolve_queue_len);
+		c->next = table->mfc_unres_queue;
+		table->mfc_unres_queue = c;
 
 		mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
@@ -697,7 +771,7 @@ ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
 		err = 0;
 	}
 
-	spin_unlock_bh(&mfc_unres_lock);
+	spin_unlock_bh(&table->mfc_unres_lock);
 	return err;
 }
 
@@ -705,14 +779,15 @@ ipmr_cache_unresolved(vifi_t vifi, struct sk_buff *skb)
  *	MFC cache manipulation by user space mroute daemon
  */
 
-static int ipmr_mfc_delete(struct mfcctl *mfc)
+static int ipmr_mfc_delete(struct ipmr_table *table, struct mfcctl *mfc)
 {
 	int line;
 	struct mfc_cache *c, **cp;
 
 	line=MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp=&mfc_cache_array[line]; (c=*cp) != NULL; cp = &c->next) {
+	for (cp = &table->mfc_cache_array[line]; (c = *cp) != NULL;
+	     cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
 			write_lock_bh(&mrt_lock);
@@ -726,14 +801,15 @@ static int ipmr_mfc_delete(struct mfcctl *mfc)
 	return -ENOENT;
 }
 
-static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
+static int ipmr_mfc_add(struct ipmr_table *table, struct mfcctl *mfc, int mrtsock)
 {
 	int line;
 	struct mfc_cache *uc, *c, **cp;
 
 	line=MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp=&mfc_cache_array[line]; (c=*cp) != NULL; cp = &c->next) {
+	for (cp = &table->mfc_cache_array[line]; (c = *cp) != NULL;
+	     cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr)
 			break;
@@ -742,7 +818,7 @@ static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
 	if (c != NULL) {
 		write_lock_bh(&mrt_lock);
 		c->mfc_parent = mfc->mfcc_parent;
-		ipmr_update_thresholds(c, mfc->mfcc_ttls);
+		ipmr_update_thresholds(table, c, mfc->mfcc_ttls);
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
@@ -759,34 +835,34 @@ static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
 	c->mfc_origin=mfc->mfcc_origin.s_addr;
 	c->mfc_mcastgrp=mfc->mfcc_mcastgrp.s_addr;
 	c->mfc_parent=mfc->mfcc_parent;
-	ipmr_update_thresholds(c, mfc->mfcc_ttls);
+	ipmr_update_thresholds(table, c, mfc->mfcc_ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	c->next = mfc_cache_array[line];
-	mfc_cache_array[line] = c;
+	c->next = table->mfc_cache_array[line];
+	table->mfc_cache_array[line] = c;
 	write_unlock_bh(&mrt_lock);
 
 	/*
 	 *	Check to see if we resolved a queued list. If so we
 	 *	need to send on the frames and tidy up.
 	 */
-	spin_lock_bh(&mfc_unres_lock);
-	for (cp = &mfc_unres_queue; (uc=*cp) != NULL;
+	spin_lock_bh(&table->mfc_unres_lock);
+	for (cp = &table->mfc_unres_queue; (uc = *cp) != NULL;
 	     cp = &uc->next) {
 		if (uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
 			*cp = uc->next;
-			if (atomic_dec_and_test(&cache_resolve_queue_len))
+			if (atomic_dec_and_test(&table->cache_resolve_queue_len))
 				del_timer(&ipmr_expire_timer);
 			break;
 		}
 	}
-	spin_unlock_bh(&mfc_unres_lock);
+	spin_unlock_bh(&table->mfc_unres_lock);
 
 	if (uc) {
-		ipmr_cache_resolve(uc, c);
+		ipmr_cache_resolve(table, uc, c);
 		kmem_cache_free(mrt_cachep, uc);
 	}
 	return 0;
@@ -796,16 +872,16 @@ static int ipmr_mfc_add(struct mfcctl *mfc, int mrtsock)
  *	Close the multicast socket, and clear the vif tables etc
  */
 
-static void mroute_clean_tables(struct sock *sk)
+static void mroute_clean_tables(struct ipmr_table *table, struct sock *sk)
 {
 	int i;
 
 	/*
 	 *	Shut down all active vif entries
 	 */
-	for (i=0; i<maxvif; i++) {
-		if (!(vif_table[i].flags&VIFF_STATIC))
-			vif_delete(i);
+	for (i = 0; i < table->maxvif; i++) {
+		if (!(table->vif_table[i].flags&VIFF_STATIC))
+			vif_delete(table, i);
 	}
 
 	/*
@@ -814,7 +890,7 @@ static void mroute_clean_tables(struct sock *sk)
 	for (i=0;i<MFC_LINES;i++) {
 		struct mfc_cache *c, **cp;
 
-		cp = &mfc_cache_array[i];
+		cp = &table->mfc_cache_array[i];
 		while ((c = *cp) != NULL) {
 			if (c->mfc_flags&MFC_STATIC) {
 				cp = &c->next;
@@ -828,34 +904,41 @@ static void mroute_clean_tables(struct sock *sk)
 		}
 	}
 
-	if (atomic_read(&cache_resolve_queue_len) != 0) {
+	if (atomic_read(&table->cache_resolve_queue_len) != 0) {
 		struct mfc_cache *c;
 
-		spin_lock_bh(&mfc_unres_lock);
-		while (mfc_unres_queue != NULL) {
-			c = mfc_unres_queue;
-			mfc_unres_queue = c->next;
-			spin_unlock_bh(&mfc_unres_lock);
+		spin_lock_bh(&table->mfc_unres_lock);
+		while (table->mfc_unres_queue != NULL) {
+			c = table->mfc_unres_queue;
+			table->mfc_unres_queue = c->next;
+			spin_unlock_bh(&table->mfc_unres_lock);
 
-			ipmr_destroy_unres(c);
+			ipmr_destroy_unres(table, c);
 
-			spin_lock_bh(&mfc_unres_lock);
+			spin_lock_bh(&table->mfc_unres_lock);
 		}
-		spin_unlock_bh(&mfc_unres_lock);
+		spin_unlock_bh(&table->mfc_unres_lock);
 	}
 }
 
 static void mrtsock_destruct(struct sock *sk)
 {
+	struct ipmr_table *table;
+	unsigned int i;
+
 	rtnl_lock();
-	if (sk == mroute_socket) {
-		IPV4_DEVCONF_ALL(sk->sk_net, MC_FORWARDING)--;
+	for (i = 0; i < IPMR_HSIZE; i++) {
+		list_for_each_entry_rcu(table, &ipmr_table_hash[i], list) {
+			if (sk == table->mroute_socket) {
+				IPV4_DEVCONF_ALL(sk->sk_net, MC_FORWARDING)--;
 
-		write_lock_bh(&mrt_lock);
-		mroute_socket=NULL;
-		write_unlock_bh(&mrt_lock);
+				write_lock_bh(&mrt_lock);
+				table->mroute_socket = NULL;
+				write_unlock_bh(&mrt_lock);
 
-		mroute_clean_tables(sk);
+				mroute_clean_tables(table, sk);
+			}
+		}
 	}
 	rtnl_unlock();
 }
@@ -872,9 +955,57 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 	int ret;
 	struct vifctl vif;
 	struct mfcctl mfc;
+	struct ipmr_table *table;
+	unsigned int table_id = DFLT_MROUTE_TBL;
+
+	switch (optname) {
+	case MRT_INIT:
+	case MRT_DONE:
+	case MRT_ASSERT:
+#ifdef CONFIG_IP_PIMSM
+	case MRT_PIM:
+#endif
+		if (optlen == sizeof(struct mrt_sockopt_simple)) {
+			struct mrt_sockopt_simple tmp;
+			if (copy_from_user(&tmp, optval, sizeof(tmp)))
+				return -EFAULT;
+			table_id = tmp.table_id;
+			optlen = sizeof(int);
+		}
+		break;
+	case MRT_ADD_VIF:
+	case MRT_DEL_VIF:
+		if (optlen == sizeof(struct vifctl_ng)) {
+			struct vifctl_ng tmp;
+			if (copy_from_user(&tmp, optval, sizeof(tmp)))
+				return -EFAULT;
+			table_id = tmp.table_id;
+			optlen = sizeof(vif);
+		}
+		break;
+	case MRT_ADD_MFC:
+	case MRT_DEL_MFC:
+		if (optlen == sizeof(struct mfcctl_ng)) {
+			struct mfcctl_ng tmp;
+			if (copy_from_user(&tmp, optval, sizeof(tmp)))
+				return -EFAULT;
+			table_id = tmp.table_id;
+			optlen = sizeof(mfc);
+		}
+	}
+
+	table = ipmr_table_lookup(table_id);
+	if (!table) {
+		if (optname == MRT_INIT) {
+			table = ipmr_table_create(table_id);
+		}
+	}
+	
+	if (!table)
+		return -ENOENT;
 
 	if (optname != MRT_INIT) {
-		if (sk != mroute_socket && !capable(CAP_NET_ADMIN))
+		if (sk != table->mroute_socket && !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
@@ -887,7 +1018,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 			return -ENOPROTOOPT;
 
 		rtnl_lock();
-		if (mroute_socket) {
+		if (table->mroute_socket) {
 			rtnl_unlock();
 			return -EADDRINUSE;
 		}
@@ -895,7 +1026,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
 			write_lock_bh(&mrt_lock);
-			mroute_socket=sk;
+			table->mroute_socket = sk;
 			write_unlock_bh(&mrt_lock);
 
 			IPV4_DEVCONF_ALL(sk->sk_net, MC_FORWARDING)++;
@@ -903,7 +1034,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk!=mroute_socket)
+		if (sk != table->mroute_socket)
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
@@ -916,9 +1047,9 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 			return -ENFILE;
 		rtnl_lock();
 		if (optname==MRT_ADD_VIF) {
-			ret = vif_add(&vif, sk==mroute_socket);
+			ret = vif_add(table, &vif, sk == table->mroute_socket);
 		} else {
-			ret = vif_delete(vif.vifc_vifi);
+			ret = vif_delete(table, vif.vifc_vifi);
 		}
 		rtnl_unlock();
 		return ret;
@@ -935,9 +1066,10 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 			return -EFAULT;
 		rtnl_lock();
 		if (optname==MRT_DEL_MFC)
-			ret = ipmr_mfc_delete(&mfc);
+			ret = ipmr_mfc_delete(table, &mfc);
 		else
-			ret = ipmr_mfc_add(&mfc, sk==mroute_socket);
+			ret = ipmr_mfc_add(table, &mfc,
+					   sk == table->mroute_socket);
 		rtnl_unlock();
 		return ret;
 		/*
@@ -948,7 +1080,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 		int v;
 		if (get_user(v,(int __user *)optval))
 			return -EFAULT;
-		mroute_do_assert=(v)?1:0;
+		table->mroute_do_assert = v ? 1 : 0;
 		return 0;
 	}
 #ifdef CONFIG_IP_PIMSM
@@ -962,19 +1094,25 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 
 		rtnl_lock();
 		ret = 0;
-		if (v != mroute_do_pim) {
-			mroute_do_pim = v;
-			mroute_do_assert = v;
+		if (v != table->mroute_do_pim) {
+			if (v != table->mroute_do_pim) {
+				if (v)
+					mroute_pim_cnt++;
+				else
+					mroute_pim_cnt--;
 #ifdef CONFIG_IP_PIMSM_V2
-			if (mroute_do_pim)
-				ret = inet_add_protocol(&pim_protocol,
-							IPPROTO_PIM);
-			else
-				ret = inet_del_protocol(&pim_protocol,
-							IPPROTO_PIM);
-			if (ret < 0)
-				ret = -EAGAIN;
+				if (mroute_pim_cnt == 1)
+					ret = inet_add_protocol(&pim_protocol,
+								IPPROTO_PIM);
+				else if (mroute_pim_cnt == 0)
+					ret = inet_del_protocol(&pim_protocol,
+								IPPROTO_PIM);
+				if (ret < 0)
+					ret = -EAGAIN;
 #endif
+			}
+			table->mroute_do_pim = v;
+			table->mroute_do_assert = v;
 		}
 		rtnl_unlock();
 		return ret;
@@ -995,6 +1133,8 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 
 int ip_mroute_getsockopt(struct sock *sk,int optname,char __user *optval,int __user *optlen)
 {
+	struct ipmr_table *table;
+	unsigned int table_id = DFLT_MROUTE_TBL;
 	int olr;
 	int val;
 
@@ -1008,20 +1148,31 @@ int ip_mroute_getsockopt(struct sock *sk,int optname,char __user *optval,int __u
 	if (get_user(olr, optlen))
 		return -EFAULT;
 
-	olr = min_t(unsigned int, olr, sizeof(int));
+	olr = min_t(unsigned int, olr, sizeof(struct mrt_sockopt_simple));
 	if (olr < 0)
 		return -EINVAL;
 
+	if (olr == sizeof(struct mrt_sockopt_simple)) {
+		struct mrt_sockopt_simple tmp;
+		if (copy_from_user(&tmp, optval, sizeof(tmp)))
+			return -EFAULT;
+		table_id = tmp.table_id;
+	}
+
+	table = ipmr_table_lookup(table_id);
+	if (!table)
+		return -ENOENT;
+
 	if (put_user(olr,optlen))
 		return -EFAULT;
 	if (optname==MRT_VERSION)
 		val=0x0305;
 #ifdef CONFIG_IP_PIMSM
 	else if (optname==MRT_PIM)
-		val=mroute_do_pim;
+		val = table->mroute_do_pim;
 #endif
 	else
-		val=mroute_do_assert;
+		val = table->mroute_do_assert;
 	if (copy_to_user(optval,&val,olr))
 		return -EFAULT;
 	return 0;
@@ -1034,19 +1185,42 @@ int ip_mroute_getsockopt(struct sock *sk,int optname,char __user *optval,int __u
 int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 {
 	struct sioc_sg_req sr;
+	struct sioc_sg_req_ng sr_ng;
 	struct sioc_vif_req vr;
+	struct sioc_vif_req_ng vr_ng;
 	struct vif_device *vif;
 	struct mfc_cache *c;
+	struct ipmr_table *table;
+	unsigned int table_id = DFLT_MROUTE_TBL;
+
+	switch (cmd) {
+	case SIOCGETVIFCNT_NG:
+		if (copy_from_user(&vr_ng, arg, sizeof(vr_ng)))
+			return -EFAULT;
+		table_id = vr_ng.table_id;
+		cmd = SIOCGETVIFCNT;
+		break;
+	case SIOCGETSGCNT_NG:
+		if (copy_from_user(&sr_ng, arg, sizeof(sr_ng)))
+			return -EFAULT;
+		table_id = sr_ng.table_id;
+		cmd = SIOCGETSGCNT;
+		break;
+	}
+
+	table = ipmr_table_lookup(table_id);
+	if (!table)
+		return -ENOENT;
 
 	switch (cmd) {
 	case SIOCGETVIFCNT:
 		if (copy_from_user(&vr,arg,sizeof(vr)))
 			return -EFAULT;
-		if (vr.vifi>=maxvif)
+		if (vr.vifi >= table->maxvif)
 			return -EINVAL;
 		read_lock(&mrt_lock);
-		vif=&vif_table[vr.vifi];
-		if (VIF_EXISTS(vr.vifi))	{
+		vif = &table->vif_table[vr.vifi];
+		if (VIF_EXISTS(table, vr.vifi))	{
 			vr.icount=vif->pkt_in;
 			vr.ocount=vif->pkt_out;
 			vr.ibytes=vif->bytes_in;
@@ -1064,7 +1238,7 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 			return -EFAULT;
 
 		read_lock(&mrt_lock);
-		c = ipmr_cache_find(sr.src.s_addr, sr.grp.s_addr);
+		c = ipmr_cache_find(table, sr.src.s_addr, sr.grp.s_addr);
 		if (c) {
 			sr.pktcnt = c->mfc_un.res.pkt;
 			sr.bytecnt = c->mfc_un.res.bytes;
@@ -1087,6 +1261,7 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 {
 	struct net_device *dev = ptr;
 	struct vif_device *v;
+	struct ipmr_table *table;
 	int ct;
 
 	if (dev->nd_net != &init_net)
@@ -1094,10 +1269,15 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	v=&vif_table[0];
-	for (ct=0;ct<maxvif;ct++,v++) {
+
+	table = dev->mrt_entry;
+	if (!table)
+		return NOTIFY_DONE;
+
+	v = &table->vif_table[0];
+	for (ct = 0; ct < table->maxvif; ct++, v++) {
 		if (v->dev==dev)
-			vif_delete(ct);
+			vif_delete(table, ct);
 	}
 	return NOTIFY_DONE;
 }
@@ -1155,10 +1335,11 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
  *	Processing handlers for ipmr_forward
  */
 
-static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
+static void ipmr_queue_xmit(struct ipmr_table *table, struct sk_buff *skb,
+			    struct mfc_cache *c, int vifi)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct vif_device *vif = &vif_table[vifi];
+	struct vif_device *vif = &table->vif_table[vifi];
 	struct net_device *dev;
 	struct rtable *rt;
 	int    encap = 0;
@@ -1172,7 +1353,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 		vif->bytes_out+=skb->len;
 		((struct net_device_stats*)netdev_priv(vif->dev))->tx_bytes += skb->len;
 		((struct net_device_stats*)netdev_priv(vif->dev))->tx_packets++;
-		ipmr_cache_report(skb, vifi, IGMPMSG_WHOLEPKT);
+		ipmr_cache_report(table, skb, vifi, IGMPMSG_WHOLEPKT);
 		kfree_skb(skb);
 		return;
 	}
@@ -1256,11 +1437,12 @@ out_free:
 	return;
 }
 
-static int ipmr_find_vif(struct net_device *dev)
+static int ipmr_find_vif(struct ipmr_table *table, struct net_device *dev)
 {
 	int ct;
-	for (ct=maxvif-1; ct>=0; ct--) {
-		if (vif_table[ct].dev == dev)
+
+	for (ct = table->maxvif - 1; ct >= 0; ct--) {
+		if (table->vif_table[ct].dev == dev)
 			break;
 	}
 	return ct;
@@ -1268,7 +1450,8 @@ static int ipmr_find_vif(struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local)
+static int ip_mr_forward(struct ipmr_table *table, struct sk_buff *skb,
+			 struct mfc_cache *cache, int local)
 {
 	int psend = -1;
 	int vif, ct;
@@ -1280,7 +1463,7 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 	/*
 	 * Wrong interface: drop packet and (maybe) send PIM assert.
 	 */
-	if (vif_table[vif].dev != skb->dev) {
+	if (table->vif_table[vif].dev != skb->dev) {
 		int true_vifi;
 
 		if (((struct rtable*)skb->dst)->fl.iif == 0) {
@@ -1299,25 +1482,26 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 		}
 
 		cache->mfc_un.res.wrong_if++;
-		true_vifi = ipmr_find_vif(skb->dev);
+		true_vifi = ipmr_find_vif(table, skb->dev);
 
-		if (true_vifi >= 0 && mroute_do_assert &&
+		if (true_vifi >= 0 && table->mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
 		       so that we cannot check that packet arrived on an oif.
 		       It is bad, but otherwise we would need to move pretty
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
-		    (mroute_do_pim || cache->mfc_un.res.ttls[true_vifi] < 255) &&
+		    (table->mroute_do_pim ||
+		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
 		    time_after(jiffies,
 			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;
-			ipmr_cache_report(skb, true_vifi, IGMPMSG_WRONGVIF);
+			ipmr_cache_report(table, skb, true_vifi, IGMPMSG_WRONGVIF);
 		}
 		goto dont_forward;
 	}
 
-	vif_table[vif].pkt_in++;
-	vif_table[vif].bytes_in+=skb->len;
+	table->vif_table[vif].pkt_in++;
+	table->vif_table[vif].bytes_in += skb->len;
 
 	/*
 	 *	Forward the frame
@@ -1327,7 +1511,8 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2)
-					ipmr_queue_xmit(skb2, cache, psend);
+					ipmr_queue_xmit(table, skb2, cache,
+							psend);
 			}
 			psend=ct;
 		}
@@ -1336,9 +1521,9 @@ static int ip_mr_forward(struct sk_buff *skb, struct mfc_cache *cache, int local
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2)
-				ipmr_queue_xmit(skb2, cache, psend);
+				ipmr_queue_xmit(table, skb2, cache, psend);
 		} else {
-			ipmr_queue_xmit(skb, cache, psend);
+			ipmr_queue_xmit(table, skb, cache, psend);
 			return 0;
 		}
 	}
@@ -1358,6 +1543,10 @@ int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
 	int local = ((struct rtable*)skb->dst)->rt_flags&RTCF_LOCAL;
+	struct ipmr_table *table = skb->dev->mrt_entry;
+	
+	if (!table)
+		goto drop;
 
 	/* Packet is looped back after forward, it should not be
 	   forwarded second time, but still can be delivered locally.
@@ -1377,9 +1566,9 @@ int ip_mr_input(struct sk_buff *skb)
 			       that we can forward NO IGMP messages.
 			     */
 			    read_lock(&mrt_lock);
-			    if (mroute_socket) {
+			    if (table->mroute_socket) {
 				    nf_reset(skb);
-				    raw_rcv(mroute_socket, skb);
+				    raw_rcv(table->mroute_socket, skb);
 				    read_unlock(&mrt_lock);
 				    return 0;
 			    }
@@ -1388,7 +1577,7 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
+	cache = ipmr_cache_find(table, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
 
 	/*
 	 *	No usable cache entry
@@ -1406,9 +1595,9 @@ int ip_mr_input(struct sk_buff *skb)
 			skb = skb2;
 		}
 
-		vif = ipmr_find_vif(skb->dev);
+		vif = ipmr_find_vif(table, skb->dev);
 		if (vif >= 0) {
-			int err = ipmr_cache_unresolved(vif, skb);
+			int err = ipmr_cache_unresolved(table, vif, skb);
 			read_unlock(&mrt_lock);
 
 			return err;
@@ -1418,7 +1607,7 @@ int ip_mr_input(struct sk_buff *skb)
 		return -ENODEV;
 	}
 
-	ip_mr_forward(skb, cache, local);
+	ip_mr_forward(table, skb, cache, local);
 
 	read_unlock(&mrt_lock);
 
@@ -1430,6 +1619,7 @@ int ip_mr_input(struct sk_buff *skb)
 dont_forward:
 	if (local)
 		return ip_local_deliver(skb);
+drop:
 	kfree_skb(skb);
 	return 0;
 }
@@ -1444,13 +1634,18 @@ int pim_rcv_v1(struct sk_buff * skb)
 	struct igmphdr *pim;
 	struct iphdr   *encap;
 	struct net_device  *reg_dev = NULL;
+	struct ipmr_table *table;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
 		goto drop;
 
 	pim = igmp_hdr(skb);
 
-	if (!mroute_do_pim ||
+	table = skb->dev->mrt_entry;
+	if (!table)
+		goto drop;
+
+	if (!table->mroute_do_pim ||
 	    skb->len < sizeof(*pim) + sizeof(*encap) ||
 	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;
@@ -1469,8 +1664,8 @@ int pim_rcv_v1(struct sk_buff * skb)
 		goto drop;
 
 	read_lock(&mrt_lock);
-	if (reg_vif_num >= 0)
-		reg_dev = vif_table[reg_vif_num].dev;
+	if (table->reg_vif_num >= 0)
+		reg_dev = table->vif_table[table->reg_vif_num].dev;
 	if (reg_dev)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
@@ -1505,6 +1700,7 @@ static int pim_rcv(struct sk_buff * skb)
 	struct pimreghdr *pim;
 	struct iphdr   *encap;
 	struct net_device  *reg_dev = NULL;
+	struct ipmr_table *table;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
 		goto drop;
@@ -1524,9 +1720,13 @@ static int pim_rcv(struct sk_buff * skb)
 	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len)
 		goto drop;
 
+	table = skb->dev->mrt_entry;
+	if (!table)
+		goto drop;
+
 	read_lock(&mrt_lock);
-	if (reg_vif_num >= 0)
-		reg_dev = vif_table[reg_vif_num].dev;
+	if (table->reg_vif_num >= 0)
+		reg_dev = table->vif_table[table->reg_vif_num].dev;
 	if (reg_dev)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
@@ -1556,11 +1756,12 @@ static int pim_rcv(struct sk_buff * skb)
 #endif
 
 static int
-ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm)
+ipmr_fill_mroute(struct ipmr_table *table, struct sk_buff *skb,
+		 struct mfc_cache *c, struct rtmsg *rtm)
 {
 	int ct;
 	struct rtnexthop *nhp;
-	struct net_device *dev = vif_table[c->mfc_parent].dev;
+	struct net_device *dev = table->vif_table[c->mfc_parent].dev;
 	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
@@ -1576,7 +1777,7 @@ ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm)
 			nhp = (struct rtnexthop*)skb_put(skb, RTA_ALIGN(sizeof(*nhp)));
 			nhp->rtnh_flags = 0;
 			nhp->rtnh_hops = c->mfc_un.res.ttls[ct];
-			nhp->rtnh_ifindex = vif_table[ct].dev->ifindex;
+			nhp->rtnh_ifindex = table->vif_table[ct].dev->ifindex;
 			nhp->rtnh_len = sizeof(*nhp);
 		}
 	}
@@ -1595,9 +1796,20 @@ int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 	int err;
 	struct mfc_cache *cache;
 	struct rtable *rt = (struct rtable*)skb->dst;
+	struct ipmr_table *table;
+	struct net_device *dev;
+
+	dev = dev_get_by_index(&init_net, rt->fl.iif);
+	if (!dev)
+		return -ENODEV;
+
+	table = dev->mrt_entry;
+	dev_put(dev);
+	if (!table)
+		return -ENOENT;
 
 	read_lock(&mrt_lock);
-	cache = ipmr_cache_find(rt->rt_src, rt->rt_dst);
+	cache = ipmr_cache_find(table, rt->rt_src, rt->rt_dst);
 
 	if (cache==NULL) {
 		struct sk_buff *skb2;
@@ -1611,7 +1823,7 @@ int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 		}
 
 		dev = skb->dev;
-		if (dev == NULL || (vif = ipmr_find_vif(dev)) < 0) {
+		if (dev == NULL || (vif = ipmr_find_vif(table, dev)) < 0) {
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
@@ -1628,14 +1840,14 @@ int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
 		iph->saddr = rt->rt_src;
 		iph->daddr = rt->rt_dst;
 		iph->version = 0;
-		err = ipmr_cache_unresolved(vif, skb2);
+		err = ipmr_cache_unresolved(table, vif, skb2);
 		read_unlock(&mrt_lock);
 		return err;
 	}
 
 	if (!nowait && (rtm->rtm_flags&RTM_F_NOTIFY))
 		cache->mfc_flags |= MFC_NOTIFY;
-	err = ipmr_fill_mroute(skb, cache, rtm);
+	err = ipmr_fill_mroute(table, skb, cache, rtm);
 	read_unlock(&mrt_lock);
 	return err;
 }
@@ -1645,17 +1857,26 @@ int ipmr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait)
  *	The /proc interfaces to multicast routing /proc/ip_mr_cache /proc/ip_mr_vif
  */
 struct ipmr_vif_iter {
-	int ct;
+	unsigned int		bucket;
+	struct ipmr_table	*table;
+	int			ct;
 };
 
 static struct vif_device *ipmr_vif_seq_idx(struct ipmr_vif_iter *iter,
 					   loff_t pos)
 {
-	for (iter->ct = 0; iter->ct < maxvif; ++iter->ct) {
-		if (!VIF_EXISTS(iter->ct))
-			continue;
-		if (pos-- == 0)
-			return &vif_table[iter->ct];
+	for (iter->bucket = 0; iter->bucket < IPMR_HSIZE; iter->bucket++) {
+		list_for_each_entry_rcu(iter->table,
+					&ipmr_table_hash[iter->bucket],
+					list) {
+			for (iter->ct = 0; iter->ct < iter->table->maxvif;
+			     ++iter->ct) {
+				if (!VIF_EXISTS(iter->table, iter->ct))
+					continue;
+				if (pos-- == 0)
+					return &iter->table->vif_table[iter->ct];
+			}
+		}
 	}
 	return NULL;
 }
@@ -1676,11 +1897,27 @@ static void *ipmr_vif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (v == SEQ_START_TOKEN)
 		return ipmr_vif_seq_idx(iter, 0);
 
-	while (++iter->ct < maxvif) {
-		if (!VIF_EXISTS(iter->ct))
+next_vif:
+	while (++iter->ct < iter->table->maxvif) {
+		if (!VIF_EXISTS(iter->table, iter->ct))
 			continue;
-		return &vif_table[iter->ct];
+		return &iter->table->vif_table[iter->ct];
+	}
+
+next_table:
+	if (iter->table->list.next != &ipmr_table_hash[iter->bucket]) {
+		iter->table = list_entry(iter->table->list.next,
+					 struct ipmr_table, list);
+		iter->ct = -1;
+		goto next_vif;
 	}
+
+	while (++iter->bucket < IPMR_HSIZE) {
+		iter->table = list_entry(&ipmr_table_hash[iter->bucket],
+					 struct ipmr_table, list);
+		goto next_table;
+	}
+
 	return NULL;
 }
 
@@ -1694,17 +1931,17 @@ static int ipmr_vif_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
-			 "Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote\n");
+			 "Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote TableId\n");
 	} else {
 		const struct vif_device *vif = v;
 		const char *name =  vif->dev ? vif->dev->name : "none";
 
 		seq_printf(seq,
-			   "%2Zd %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X\n",
-			   vif - vif_table,
+			   "%2d %-10s %8ld %7ld  %8ld %7ld %05X %08X %08X %d\n",
+			   vif->vif_index,
 			   name, vif->bytes_in, vif->pkt_in,
 			   vif->bytes_out, vif->pkt_out,
-			   vif->flags, vif->local, vif->remote);
+			   vif->flags, vif->local, vif->remote, vif->table_id);
 	}
 	return 0;
 }
@@ -1731,8 +1968,10 @@ static const struct file_operations ipmr_vif_fops = {
 };
 
 struct ipmr_mfc_iter {
-	struct mfc_cache **cache;
-	int ct;
+	unsigned int		bucket;
+	struct ipmr_table	*table;
+	struct mfc_cache	**cache;
+	int			ct;
 };
 
 
@@ -1740,22 +1979,29 @@ static struct mfc_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
 {
 	struct mfc_cache *mfc;
 
-	it->cache = mfc_cache_array;
-	read_lock(&mrt_lock);
-	for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
-		for (mfc = mfc_cache_array[it->ct]; mfc; mfc = mfc->next)
-			if (pos-- == 0)
-				return mfc;
-	read_unlock(&mrt_lock);
-
-	it->cache = &mfc_unres_queue;
-	spin_lock_bh(&mfc_unres_lock);
-	for (mfc = mfc_unres_queue; mfc; mfc = mfc->next)
-		if (pos-- == 0)
-			return mfc;
-	spin_unlock_bh(&mfc_unres_lock);
+	for (it->bucket = 0; it->bucket < IPMR_HSIZE; it->bucket++) {
+		list_for_each_entry_rcu(it->table,
+					&ipmr_table_hash[it->bucket],
+					list) {
+			it->cache = it->table->mfc_cache_array;
+			read_lock(&mrt_lock);
+			for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
+				for (mfc = it->table->mfc_cache_array[it->ct];
+				     mfc; mfc = mfc->next)
+					if (pos-- == 0)
+						return mfc;
+			read_unlock(&mrt_lock);
 
-	it->cache = NULL;
+			it->cache = &it->table->mfc_unres_queue;
+			spin_lock_bh(&it->table->mfc_unres_lock);
+			for (mfc = it->table->mfc_unres_queue; mfc;
+			     mfc = mfc->next)
+				if (pos-- == 0)
+					return mfc;
+			spin_unlock_bh(&it->table->mfc_unres_lock);
+			it->cache = NULL;
+		}
+	}
 	return NULL;
 }
 
@@ -1782,31 +2028,47 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (mfc->next)
 		return mfc->next;
 
-	if (it->cache == &mfc_unres_queue)
+ next_mfc:
+	if (it->cache == &it->table->mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != mfc_cache_array);
+	BUG_ON(it->cache != it->table->mfc_cache_array);
 
 	while (++it->ct < MFC_LINES) {
-		mfc = mfc_cache_array[it->ct];
+		mfc = it->table->mfc_cache_array[it->ct];
 		if (mfc)
 			return mfc;
 	}
 
 	/* exhausted cache_array, show unresolved */
 	read_unlock(&mrt_lock);
-	it->cache = &mfc_unres_queue;
+	it->cache = &it->table->mfc_unres_queue;
 	it->ct = 0;
 
-	spin_lock_bh(&mfc_unres_lock);
-	mfc = mfc_unres_queue;
+	spin_lock_bh(&it->table->mfc_unres_lock);
+	mfc = it->table->mfc_unres_queue;
 	if (mfc)
 		return mfc;
 
  end_of_list:
-	spin_unlock_bh(&mfc_unres_lock);
+	spin_unlock_bh(&it->table->mfc_unres_lock);
 	it->cache = NULL;
 
+ next_table:
+	if (it->table->list.next != &ipmr_table_hash[it->bucket]) {
+		it->table = list_entry(it->table->list.next,
+				       struct ipmr_table, list);
+		it->ct = -1;
+		it->cache = it->table->mfc_cache_array;
+		goto next_mfc;
+	}
+
+	while (++it->bucket < IPMR_HSIZE) {
+		it->table = list_entry(&ipmr_table_hash[it->bucket],
+				       struct ipmr_table, list);
+		goto next_table;
+	}
+
 	return NULL;
 }
 
@@ -1814,9 +2076,9 @@ static void ipmr_mfc_seq_stop(struct seq_file *seq, void *v)
 {
 	struct ipmr_mfc_iter *it = seq->private;
 
-	if (it->cache == &mfc_unres_queue)
-		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == mfc_cache_array)
+	if (it->cache == &it->table->mfc_unres_queue)
+		spin_unlock_bh(&it->table->mfc_unres_lock);
+	else if (it->cache == it->table->mfc_cache_array)
 		read_unlock(&mrt_lock);
 }
 
@@ -1826,23 +2088,24 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq,
-		 "Group    Origin   Iif     Pkts    Bytes    Wrong Oifs\n");
+		 "Group    Origin   Iif     Pkts    Bytes    Wrong Oifs TableId\n");
 	} else {
 		const struct mfc_cache *mfc = v;
 		const struct ipmr_mfc_iter *it = seq->private;
 
-		seq_printf(seq, "%08lX %08lX %-3d %8ld %8ld %8ld",
+		seq_printf(seq, "%08lX %08lX %-3d %8ld %8ld %8ld %u",
 			   (unsigned long) mfc->mfc_mcastgrp,
 			   (unsigned long) mfc->mfc_origin,
 			   mfc->mfc_parent,
 			   mfc->mfc_un.res.pkt,
 			   mfc->mfc_un.res.bytes,
-			   mfc->mfc_un.res.wrong_if);
+			   mfc->mfc_un.res.wrong_if,
+			   it->table->id);
 
-		if (it->cache != &mfc_unres_queue) {
+		if (it->cache != &it->table->mfc_unres_queue) {
 			for (n = mfc->mfc_un.res.minvif;
 			     n < mfc->mfc_un.res.maxvif; n++ ) {
-				if (VIF_EXISTS(n)
+				if (VIF_EXISTS(it->table, n)
 				   && mfc->mfc_un.res.ttls[n] < 255)
 				seq_printf(seq,
 					   " %2d:%-3d",
@@ -1889,6 +2152,12 @@ static struct net_protocol pim_protocol = {
 
 void __init ip_mr_init(void)
 {
+	unsigned int i;
+
+	for (i = 0; i < IPMR_HSIZE; i++)
+		INIT_LIST_HEAD(&ipmr_table_hash[i]);
+	ipmr_table_create(DFLT_MROUTE_TBL);
+
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,

--------------070703070400080300040301--
