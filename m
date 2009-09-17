From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH, RFC] bonding: prevent outgoing packets on inactive
 slaves
Date: Thu, 17 Sep 2009 13:14:18 +0200
Message-ID: <20090917111418.GA21734@midget.suse.cz>
References: <20090805162429.GD16093@midget.suse.cz>
 <24645.1249491676@death.nxdomain.ibm.com>
 <20090806225644.GF8024@midget.suse.cz>
 <20090819155509.GA11829@midget.suse.cz>
 <2495.1250729618@death.nxdomain.ibm.com>
 <20090825133701.GC23138@midget.suse.cz>
 <10377.1251221782@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44813 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786AbZIQLOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 07:14:18 -0400
Content-Disposition: inline
In-Reply-To: <10377.1251221782@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

after a small off-list (my fault, sorry) discussion with Jay, I am re-sending the
patch with a minor modification. See below.

On Tue, Aug 25, 2009 at 10:36:22AM -0700, Jay Vosburgh wrote (off-list):
> Jiri Bohac <jbohac@suse.cz> wrote:
> >+	if (unlikely(dev->priv_flags & IFF_SLAVE_FILTER_TX) &&
> >+	    skb_bond_should_drop_tx(skb)) {
> >+		rc = NET_XMIT_DROP;
> >+		goto out_kfree_skb;
> >+	}
> >+
> 
> 	The priv_flags test is hidden inside the skb_bond_should_drop
> that already exists, I see no reason to do this differently.  The
> function is an inline, so in terms of the generated code, it should be
> about the same.

OK, fixed in the new version below.


> 	Also, your patch won't prevent a VLAN configured directly above
> the slave from transmitting.  I mention this because I've occasionally seen
> configurations of the form:
> 
> 	bond0 -> eth0.555 -> eth0
> 
> 	I.e., where the bonding slave is the VLAN interface, not the
> actual interface.  The other bonding slave was on a different VLAN, if
> memory serves.  I don't know if this is really an issue or not for your
> purpose.

Right, the patch won't prevent transmission from the real device
on which a VLAN is configured. After some thinking, however, I am now
convinced this is the right thing to do:

1) the problem can be prevented when setting up the bond.  VLAN
interfaces can have their MAC address changed, independently from
the real device the VLAN is configured on (and from any other VLAN
interfaces). The problem occurs when a VLAN interface, with a MAC
address identical to the real device (or other VLAN interfaces)
is added as the first slave to the bond, making the bond inherit
this address and force it to subsequently enslaved devices. If a
slave, other than the first VLAN, is then made the active slave,
switches could be confused. The VLAN's MAC address can, however,
easily be changed prior to enslaving the VLAN interface and the
problem will then never occur.

2) filtering outgoing frames from the VLAN's real device could
break legitimate traffic. If the network topology ensures that
non-tagged (or tagged with a different VLAN id) frames going out
from the VLAN interface never get on the same L2 network as the
frames from the other bonding slaves, the setup can work well
and filtering the frames will break that.


Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index aa1be1f..56b8a8e 100644
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
index 6a94475..2d92c93 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1786,6 +1786,28 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
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
+	if (likely(!(skb->dev->priv_flags & IFF_SLAVE_FILTER_TX)))
+		return 0;
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
@@ -1818,6 +1840,11 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
+	if (skb_bond_should_drop_tx(skb)) {
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

