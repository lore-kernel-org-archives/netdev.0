From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next2.6] ipv4: ip_ptr cleanups
Date: Wed, 15 Sep 2010 16:04:31 +0200
Message-ID: <1284559471.2495.147.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60788 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab0IOOEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 10:04:36 -0400
Received: by wyf22 with SMTP id 22so234919wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 07:04:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev->ip_ptr is protected by rtnl and rcu.

Yet some places dont use appropriate primitives and/or locking rules.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/plip.c           |    8 ++++++--
 drivers/net/via-velocity.h   |   11 +++++++----
 drivers/net/wan/hdlc_cisco.c |    4 +++-
 include/linux/inetdevice.h   |   13 ++++---------
 include/linux/netdevice.h    |    2 +-
 net/core/dev.c               |    2 +-
 net/ipv4/devinet.c           |    4 ++--
 net/ipv4/ipmr.c              |    2 +-
 net/mac80211/main.c          |    2 +-
 9 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 7e82a82..ca4df7f 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -995,8 +995,10 @@ plip_tx_packet(struct sk_buff *skb, struct net_device *dev)
 static void
 plip_rewrite_address(const struct net_device *dev, struct ethhdr *eth)
 {
-	const struct in_device *in_dev = dev->ip_ptr;
+	const struct in_device *in_dev;
 
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		/* Any address will do - we take the first */
 		const struct in_ifaddr *ifa = in_dev->ifa_list;
@@ -1006,6 +1008,7 @@ plip_rewrite_address(const struct net_device *dev, struct ethhdr *eth)
 			memcpy(eth->h_dest+2, &ifa->ifa_address, 4);
 		}
 	}
+	rcu_read_unlock();
 }
 
 static int
@@ -1088,7 +1091,8 @@ plip_open(struct net_device *dev)
 	   when the device address isn't identical to the address of a
 	   received frame, the kernel incorrectly drops it).             */
 
-	if ((in_dev=dev->ip_ptr) != NULL) {
+	in_dev=__in_dev_get_rtnl(dev);
+	if (in_dev) {
 		/* Any address will do - we take the first. We already
 		   have the first two bytes filled with 0xfc, from
 		   plip_init_dev(). */
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index f7b33ae..b5e120b 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1504,22 +1504,25 @@ struct velocity_info {
  *	addresses on this chain then we use the first - multi-IP WOL is not
  *	supported.
  *
- *	CHECK ME: locking
  */
 
 static inline int velocity_get_ip(struct velocity_info *vptr)
 {
-	struct in_device *in_dev = (struct in_device *) vptr->dev->ip_ptr;
+	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
+	int res = -ENOENT;
 
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(vptr->dev);
 	if (in_dev != NULL) {
 		ifa = (struct in_ifaddr *) in_dev->ifa_list;
 		if (ifa != NULL) {
 			memcpy(vptr->ip_addr, &ifa->ifa_address, 4);
-			return 0;
+			res = 0;
 		}
 	}
-	return -ENOENT;
+	rcu_read_unlock();
+	return res;
 }
 
 /**
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index b38ffa1..b1e5e5b 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -191,7 +191,8 @@ static int cisco_rx(struct sk_buff *skb)
 
 		switch (ntohl (cisco_data->type)) {
 		case CISCO_ADDR_REQ: /* Stolen from syncppp.c :-) */
-			in_dev = dev->ip_ptr;
+			rcu_read_lock();
+			in_dev = __in_dev_get_rcu(dev);
 			addr = 0;
 			mask = ~cpu_to_be32(0); /* is the mask correct? */
 
@@ -211,6 +212,7 @@ static int cisco_rx(struct sk_buff *skb)
 				cisco_keepalive_send(dev, CISCO_ADDR_REPLY,
 						     addr, mask);
 			}
+			rcu_read_unlock();
 			dev_kfree_skb_any(skb);
 			return NET_RX_SUCCESS;
 
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 2be1a1a..85cd162 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -198,14 +198,10 @@ static __inline__ int bad_mask(__be32 mask, __be32 addr)
 
 static inline struct in_device *__in_dev_get_rcu(const struct net_device *dev)
 {
-	struct in_device *in_dev = dev->ip_ptr;
-	if (in_dev)
-		in_dev = rcu_dereference(in_dev);
-	return in_dev;
+	return rcu_dereference(dev->ip_ptr);
 }
 
-static __inline__ struct in_device *
-in_dev_get(const struct net_device *dev)
+static inline struct in_device *in_dev_get(const struct net_device *dev)
 {
 	struct in_device *in_dev;
 
@@ -217,10 +213,9 @@ in_dev_get(const struct net_device *dev)
 	return in_dev;
 }
 
-static __inline__ struct in_device *
-__in_dev_get_rtnl(const struct net_device *dev)
+static inline struct in_device *__in_dev_get_rtnl(const struct net_device *dev)
 {
-	return (struct in_device*)dev->ip_ptr;
+	return rcu_dereference_check(dev->ip_ptr, lockdep_rtnl_is_held());
 }
 
 extern void in_dev_finish_destroy(struct in_device *idev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index af05186..8992fff 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -942,7 +942,7 @@ struct net_device {
 	void			*dsa_ptr;	/* dsa specific data */
 #endif
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
-	void			*ip_ptr;	/* IPv4 specific data	*/
+	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
 	void                    *dn_ptr;        /* DECnet specific data */
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
diff --git a/net/core/dev.c b/net/core/dev.c
index fc2dc93..5bdce97 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5286,7 +5286,7 @@ void netdev_run_todo(void)
 
 		/* paranoia */
 		BUG_ON(atomic_read(&dev->refcnt));
-		WARN_ON(dev->ip_ptr);
+		WARN_ON(rcu_dereference_raw(dev->ip_ptr));
 		WARN_ON(dev->ip6_ptr);
 		WARN_ON(dev->dn_ptr);
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index da14c49..c2ff48f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -209,7 +209,7 @@ static void inetdev_destroy(struct in_device *in_dev)
 		inet_free_ifa(ifa);
 	}
 
-	dev->ip_ptr = NULL;
+	rcu_assign_pointer(dev->ip_ptr, NULL);
 
 	devinet_sysctl_unregister(in_dev);
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
@@ -1059,7 +1059,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	switch (event) {
 	case NETDEV_REGISTER:
 		printk(KERN_DEBUG "inetdev_event: bug\n");
-		dev->ip_ptr = NULL;
+		rcu_assign_pointer(dev->ip_ptr, NULL);
 		break;
 	case NETDEV_UP:
 		if (!inetdev_valid_mtu(dev->mtu))
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 179fcab..10b24c0 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -724,7 +724,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 	case 0:
 		if (vifc->vifc_flags == VIFF_USE_IFINDEX) {
 			dev = dev_get_by_index(net, vifc->vifc_lcl_ifindex);
-			if (dev && dev->ip_ptr == NULL) {
+			if (dev && __in_dev_get_rtnl(dev) == NULL) {
 				dev_put(dev);
 				return -EADDRNOTAVAIL;
 			}
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 4935b84..b8cf282 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -362,7 +362,7 @@ static int ieee80211_ifa_changed(struct notifier_block *nb,
 	if (sdata->vif.type != NL80211_IFTYPE_STATION)
 		return NOTIFY_DONE;
 
-	idev = sdata->dev->ip_ptr;
+	idev = __in_dev_get_rtnl(sdata->dev);
 	if (!idev)
 		return NOTIFY_DONE;
 


