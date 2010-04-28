From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix arp_validate on bonds inside a bridge
Date: Wed, 28 Apr 2010 12:05:11 -0700
Message-ID: <18759.1272481511@death.nxdomain.ibm.com>
References: <20100428125940.GB13400@midget.suse.cz>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45326 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab0D1TFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Apr 2010 15:05:22 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3SJ0BsT004794
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 15:00:11 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3SJ5EGc1962114
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 15:05:14 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3SJ5Ex2010024
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:05:14 -0300
In-reply-to: <20100428125940.GB13400@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>bonding with arp_validate does not currently work when the
>bonding master is part of a bridge. This is because
>bond_arp_rcv() is registered as a packet type handler for ARP,
>but before netif_receive_skb() processes the ptype_base hash
>table, handle_bridge() is called and changes the skb->dev to
>point to the bridge device.
>
>This patch makes bonding_should_drop() call the bonding ARP
>handler directly if a IFF_MASTER_NEEDARP flag is set on the
>bonding master.  bond_register_arp() now only needs to set the
>IFF_MASTER_NEEDARP flag.
>
>We ne longer need special ARP handling for inactive slaves, hence
>IFF_SLAVE_NEEDARP is not needed.
>
>skb_reset_network_header() and skb_reset_transport_header() need
>to be called before the call to bonding_should_drop() because
>bond_handle_arp() needs the offsets initialized.
>
>P.S.: bonding_should_drop() should probably be renamed to
>handle_bonding() -- we already have handle_bridge() and
>handle_macvlan(), and bonding_should_drop() has long been doing
>other stuff than deciding which packets to drop...

	I agree, and I have code that I've been working on locally that
wraps the "should_drop" into a hook, similar to the bridge and macvlan
hooks that already exist.  I used different names, though.  I've got
bond_handle_frame (and bond_handle_frame_hook) bond_main.c and
handle_bonding in net/core/dev.c, where the implementation for
handle_bonding parallels that of bridge and macvlan:

#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
int (*bonding_handle_frame_hook)(struct sk_buff *skb) __read_mostly;
EXPORT_SYMBOL_GPL(bonding_handle_frame_hook);

static inline int handle_bonding(struct sk_buff *skb)
{
	struct net_device *dev = skb->dev;
	struct net_device *master = dev->master;

	if (master->priv_flags & IFF_MASTER_ML)
		return bonding_handle_frame_hook(skb);

	return skb_bond_should_drop(skb);
}
#else
#define handle_bonding(skb)	(skb)
#endif

	I think the structure you're using (skb_bond_should_drop calls
the hook as needed) may be better overall, as it doesn't require special
logic in the VLAN cases.  The disadvantage is that it's a little uglier
to hide the hook declaration behind #ifdef CONFIG_BONDING (more on that
below).

	The code I'm working on now doesn't just hook for ARP (I'm
working on a load-balance by subnet mode that needs to assign skb->dev
by destination to permit the slaves to operate independently from the
master; but that's another topic).  I did leave as much as possible to
the priv_flags, since that is less expensive to process than poking
around in the bonding structures (no locks for the priv_flags).

	I haven't tested your patch yet, but it looks like it should
work as advertised.

	I have a couple of minor comments, below, but nothing
substantive about the core of the changes.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 0075514..cafd404 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1940,8 +1940,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 	}
>
> 	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
>-				   IFF_SLAVE_INACTIVE | IFF_BONDING |
>-				   IFF_SLAVE_NEEDARP);
>+				   IFF_SLAVE_INACTIVE | IFF_BONDING);
>
> 	kfree(slave);
>
>@@ -2612,11 +2611,12 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
> 	}
> }
>
>-static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
>+static void bond_handle_arp(struct sk_buff *skb)
> {
> 	struct arphdr *arp;
> 	struct slave *slave;
> 	struct bonding *bond;
>+	struct net_device *dev = skb->dev->master, *orig_dev = skb->dev;
> 	unsigned char *arp_ptr;
> 	__be32 sip, tip;
>
>@@ -2637,9 +2637,8 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
> 	bond = netdev_priv(dev);
> 	read_lock(&bond->lock);
>
>-	pr_debug("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
>-		 bond->dev->name, skb->dev ? skb->dev->name : "NULL",
>-		 orig_dev ? orig_dev->name : "NULL");
>+	pr_debug("bond_handle_arp: bond: %s, master: %s, slave: %s\n",
>+		bond->dev->name, dev->name, orig_dev->name);
>
> 	slave = bond_get_slave_by_dev(bond, orig_dev);
> 	if (!slave || !slave_do_arp_validate(bond, slave))
>@@ -2684,8 +2683,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
> out_unlock:
> 	read_unlock(&bond->lock);
> out:
>-	dev_kfree_skb(skb);
>-	return NET_RX_SUCCESS;
>+	return;
> }
>
> /*
>@@ -3567,23 +3565,12 @@ static void bond_unregister_lacpdu(struct bonding *bond)
>
> void bond_register_arp(struct bonding *bond)
> {
>-	struct packet_type *pt = &bond->arp_mon_pt;
>-
>-	if (pt->type)
>-		return;
>-
>-	pt->type = htons(ETH_P_ARP);
>-	pt->dev = bond->dev;
>-	pt->func = bond_arp_rcv;
>-	dev_add_pack(pt);
>+	bond->dev->priv_flags |= IFF_MASTER_NEEDARP;
> }
>
> void bond_unregister_arp(struct bonding *bond)
> {
>-	struct packet_type *pt = &bond->arp_mon_pt;
>-
>-	dev_remove_pack(pt);
>-	pt->type = 0;
>+	bond->dev->priv_flags &= ~IFF_MASTER_NEEDARP;
> }
>
> /*---------------------------- Hashing Policies -----------------------------*/
>@@ -5041,6 +5028,7 @@ static int __init bonding_init(void)
> 	register_netdevice_notifier(&bond_netdev_notifier);
> 	register_inetaddr_notifier(&bond_inetaddr_notifier);
> 	bond_register_ipv6_notifier();
>+	bond_handle_arp_hook = bond_handle_arp;
> out:
> 	return res;
> err:
>@@ -5061,6 +5049,7 @@ static void __exit bonding_exit(void)
>
> 	rtnl_link_unregister(&bond_link_ops);
> 	unregister_pernet_subsys(&bond_net_ops);
>+	bond_handle_arp_hook = NULL;
> }
>
> module_init(bonding_init);
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 257a7a4..57adfe5 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -212,7 +212,6 @@ struct bonding {
> 	struct   bond_params params;
> 	struct   list_head vlan_list;
> 	struct   vlan_group *vlgrp;
>-	struct   packet_type arp_mon_pt;
> 	struct   workqueue_struct *wq;
> 	struct   delayed_work mii_work;
> 	struct   delayed_work arp_work;
>@@ -292,14 +291,12 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
> 	if (!bond_is_lb(bond))
> 		slave->state = BOND_STATE_BACKUP;
> 	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
>-	if (slave_do_arp_validate(bond, slave))
>-		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
> }
>
> static inline void bond_set_slave_active_flags(struct slave *slave)
> {
> 	slave->state = BOND_STATE_ACTIVE;
>-	slave->dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP);
>+	slave->dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
> }
>
> static inline void bond_set_master_3ad_flags(struct bonding *bond)
>diff --git a/include/linux/if.h b/include/linux/if.h
>index 3a9f410..84ab2c8 100644
>--- a/include/linux/if.h
>+++ b/include/linux/if.h
>@@ -63,7 +63,7 @@
> #define IFF_MASTER_8023AD	0x8	/* bonding master, 802.3ad. 	*/
> #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
> #define IFF_BONDING	0x20		/* bonding master or slave	*/
>-#define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
>+#define IFF_MASTER_NEEDARP 0x40		/* need ARPs for validation	*/
> #define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
> #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
> #define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index fa8b476..9f82fc6 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -2055,6 +2055,8 @@ static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
> 	}
> }
>
>+extern void (*bond_handle_arp_hook)(struct sk_buff *skb);

	Should this be inside the the skb_bond_should_drop function to
limit its scope?  Just wondering if that's a little tidier.

> /* On bonding slaves other than the currently active slave, suppress
>  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
>  * ARP on active-backup slaves with arp_validate enabled.
>@@ -2076,11 +2078,13 @@ static inline int skb_bond_should_drop(struct sk_buff *skb,
> 			skb_bond_set_mac_by_master(skb, master);
> 		}
>
>-		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
>-			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
>-			    skb->protocol == __cpu_to_be16(ETH_P_ARP))
>-				return 0;
>+		/* pass ARP frames directly to bonding
>+		   before bridging or other hooks change them */
>+		if ((master->priv_flags & IFF_MASTER_NEEDARP) &&
>+		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
>+			bond_handle_arp_hook(skb);
>
>+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
> 			if (master->priv_flags & IFF_MASTER_ALB) {
> 				if (skb->pkt_type != PACKET_BROADCAST &&
> 				    skb->pkt_type != PACKET_MULTICAST)
>diff --git a/net/core/dev.c b/net/core/dev.c
>index f769098..98d85a8 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -2314,6 +2314,9 @@ static inline int deliver_skb(struct sk_buff *skb,
> 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> }
>
>+void (*bond_handle_arp_hook)(struct sk_buff *skb);
>+EXPORT_SYMBOL_GPL(bond_handle_arp_hook);

	Should this be hidden by

#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)

	with some parallel changes to skb_bond_should_drop so it
vanishes if bonding is not configured?  Granted, distros will all turn
it on anyway, but the embedded size might be a bit smaller.

> #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
>
> #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
>@@ -2507,6 +2510,10 @@ int netif_receive_skb(struct sk_buff *skb)
> 	if (!skb->skb_iif)
> 		skb->skb_iif = skb->dev->ifindex;
>
>+	skb_reset_network_header(skb);
>+	skb_reset_transport_header(skb);
>+	skb->mac_len = skb->network_header - skb->mac_header;
>+
> 	null_or_orig = NULL;
> 	orig_dev = skb->dev;
> 	master = ACCESS_ONCE(orig_dev->master);
>@@ -2519,10 +2526,6 @@ int netif_receive_skb(struct sk_buff *skb)
>
> 	__get_cpu_var(netdev_rx_stat).total++;
>
>-	skb_reset_network_header(skb);
>-	skb_reset_transport_header(skb);
>-	skb->mac_len = skb->network_header - skb->mac_header;
>-
> 	pt_prev = NULL;
>
> 	rcu_read_lock();

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
