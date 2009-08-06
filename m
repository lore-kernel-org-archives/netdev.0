From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH, RFC] bonding: prevent outgoing packets on inactive
	slaves
Date: Fri, 7 Aug 2009 00:56:44 +0200
Message-ID: <20090806225644.GF8024@midget.suse.cz>
References: <20090805162429.GD16093@midget.suse.cz> <24645.1249491676@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37227 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360AbZHFW4s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 18:56:48 -0400
Content-Disposition: inline
In-Reply-To: <24645.1249491676@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2009 at 10:01:16AM -0700, Jay Vosburgh wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> >This patch makes sure the TX queues on inactive slaves are
> >deactivated.
> 
> 	I'd love to include this patch; many times I've tracked down
> "bonding" problems to some errant dingus confusing the switch, but I
> think this patch will break some things, and therefore has to be a NAK.
> 
> 	Specifically, I suspect this will break users of some protocols
> that intentionally (and legitimately) bind directly to the slave
> underneath bonding, LLDP for one.  I'm fairly sure there are such users,
> because the inactive slave rx path was changed last year to permit
> explicit binds to the inactive slaves to receive packets that normally
> would be dropped:
> 
> commit 0d7a3681232f545c6a59f77e60f7667673ef0e93
> Author: Joe Eykholt <jre@nuovasystems.com>
> Date:   Wed Jul 2 18:22:01 2008 -0700
> 
>     net/core: Allow certain receives on inactive slave.
>     
>     Allow a packet_type that specifies the exact device to receive
>     even on an inactive bonding slave devices.  This is important for some
>     L2 protocols such as LLDP and FCoE.  This can eventually be used
>     for the bonding special cases as well.

OK. I checked FCoE and it really seems to bind to a specific
interface. I checked openlldp and it does bind to individual
interfaces specifically, so checking the ptype really seems like
it should work. How about the following patch, then?

I think it even is cleaner than the original, because
bond_set_slave_active_flags() really only sets flags instead of
calling non-trivial functions while holding locks. If some
protocol does not work with the ptype heuristics, it can easilly
be "whitelisted" in skb_bond_should_drop_tx():


Signed-off-by: Jiri Bohac <jbohac@suse.cz>


--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1955,7 +1955,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
 				   IFF_SLAVE_INACTIVE | IFF_BONDING |
-				   IFF_SLAVE_NEEDARP);
+				   IFF_SLAVE_NEEDARP | IFF_SLAVE_FILTER_TX);
 
 	kfree(slave);
 
@@ -2081,7 +2081,7 @@ static int bond_release_all(struct net_device *bond_dev)
 		}
 
 		slave_dev->priv_flags &= ~(IFF_MASTER_8023AD | IFF_MASTER_ALB |
-					   IFF_SLAVE_INACTIVE);
+					   IFF_SLAVE_INACTIVE | IFF_SLAVE_FILTER_TX);
 
 		kfree(slave);
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6290a50..7d0e0bb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -291,12 +291,15 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
 	if (slave_do_arp_validate(bond, slave))
 		slave->dev->priv_flags |= IFF_SLAVE_NEEDARP;
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+		slave->dev->priv_flags |= IFF_SLAVE_FILTER_TX;
 }
 
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
 	slave->state = BOND_STATE_ACTIVE;
-	slave->dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP);
+	slave->dev->priv_flags &= ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDARP |
+				    IFF_SLAVE_FILTER_TX);
 }
 
 static inline void bond_set_master_3ad_flags(struct bonding *bond)
diff --git a/include/linux/if.h b/include/linux/if.h
index b9a6229..40d5c56 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -70,6 +70,7 @@
 #define IFF_XMIT_DST_RELEASE 0x400	/* dev_hard_start_xmit() is allowed to
 					 * release skb->dst
 					 */
+#define IFF_SLAVE_FILTER_TX 0x800	/* filter tx on bonding slaves	*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/net/core/dev.c b/net/core/dev.c
index 70c27e0..7018ba7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1786,6 +1786,25 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 	return netdev_get_tx_queue(dev, queue_index);
 }
 
+/* In active-backup mode, on bonding slaves other than the currently active slave,
+ * suppress outgoing packets, except for special L2 protocols.
+ */
+static inline int skb_bond_should_drop_tx(struct sk_buff *skb)
+{
+	struct packet_type *ptype;
+	__be16 type;
+
+	/* allow protocols specifically bound to this interface */
+	type = skb->protocol;
+	list_for_each_entry_rcu(ptype,
+			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
+		if (ptype->type == type && ptype->dev == skb->dev)
+			return 0;
+	}
+
+	return 1;
+}
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -1818,6 +1837,12 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
+	if ((dev->priv_flags & IFF_SLAVE_FILTER_TX) &&
+	    skb_bond_should_drop_tx(skb)) {
+		rc = NET_XMIT_DROP;
+		goto out_kfree_skb;
+	}
+
 	/* GSO will handle the following emulations directly. */
 	if (netif_needs_gso(dev, skb))
 		goto gso;

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

