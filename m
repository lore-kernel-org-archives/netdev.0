From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: allow bond in mode balance-alb to work properly
	in bridge -try4
Date: Thu, 26 Mar 2009 16:52:06 +0100
Message-ID: <20090326155205.GA28868@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759499AbZCZPzO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(resend, updated changelog, hook moved into skb_bond_should_drop,
skb_bond_should_drop ifdefed)

Hi all.

The problem is described in following bugzilla:
https://bugzilla.redhat.com/show_bug.cgi?id=487763

Basically here's what's going on. In every mode, bonding interface uses the same
mac address for all enslaved devices (except fail_over_mac). Only balance-alb
will simultaneously use multiple MAC addresses across different slaves. When you
put this kind of bond device into a bridge it will only add one of mac adresses
into a hash list of mac addresses, say X. This mac address is marked as local.
But this bonding interface also has mac address Y. Now then packet arrives with
destination address Y, this address is not marked as local and the packed looks
like it needs to be forwarded. This packet is then lost which is wrong.

Notice that interfaces can be added and removed from bond while it is in bridge.

This patch solves the situation in the bonding without touching bridge code,
as Patrick suggested. For every incoming frame to bonding it searches the
destination address in slaves list and if any of slave addresses matches, it
rewrites the address in frame by the adress of bonding master. This ensures that
all frames comming thru the bonding in alb mode have the same address.

Jirka


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 27fb7f5..b973ede 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1762,6 +1762,25 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	return 0;
 }
 
+void bond_alb_change_dest(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	unsigned char *dest = eth_hdr(skb)->h_dest;
+	struct slave *slave;
+	int i;
+
+	if (!compare_ether_addr_64bits(dest, bond_dev->dev_addr))
+		return;
+	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		if (!compare_ether_addr_64bits(slave->dev->dev_addr, dest)) {
+			memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
+			break;
+		}
+	}
+	read_unlock(&bond->lock);
+}
+
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 {
 	if (bond->alb_info.current_alb_vlan &&
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 50968f8..4924dd7 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -127,6 +127,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
+void bond_alb_change_dest(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3d76686..7c7cb81 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4294,6 +4294,18 @@ unwind:
 	return res;
 }
 
+/*
+ * Called via bond_change_dest_hook.
+ * note: already called with rcu_read_lock (preempt_disabled)
+ */
+void bond_change_dest(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	if (bond->params.mode == BOND_MODE_ALB)
+		bond_alb_change_dest(skb, bond_dev);
+}
+
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -5243,6 +5255,8 @@ static int __init bonding_init(void)
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
 
+	bond_change_dest_hook = bond_change_dest;
+
 	goto out;
 err:
 	list_for_each_entry(bond, &bond_dev_list, bond_list) {
@@ -5266,6 +5280,8 @@ static void __exit bonding_exit(void)
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_unregister_ipv6_notifier();
 
+	bond_change_dest_hook = NULL;
+
 	bond_destroy_sysfs();
 
 	rtnl_lock();
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca849d2..7159483 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -375,5 +375,8 @@ static inline void bond_unregister_ipv6_notifier(void)
 }
 #endif
 
+extern void (*bond_change_dest_hook)(struct sk_buff *skb,
+				     struct net_device *master);
+
 #endif /* _LINUX_BONDING_H */
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6593667..7af6857 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1860,6 +1860,10 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
+extern void (*bond_change_dest_hook)(struct sk_buff *skb,
+				     struct net_device *master);
+
 /* On bonding slaves other than the currently active slave, suppress
  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
@@ -1876,22 +1880,31 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
 			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
 			    skb->protocol == __constant_htons(ETH_P_ARP))
-				return 0;
+				goto dont_drop;
 
 			if (master->priv_flags & IFF_MASTER_ALB) {
 				if (skb->pkt_type != PACKET_BROADCAST &&
 				    skb->pkt_type != PACKET_MULTICAST)
-					return 0;
+					goto dont_drop;
 			}
 			if (master->priv_flags & IFF_MASTER_8023AD &&
 			    skb->protocol == __constant_htons(ETH_P_SLOW))
-				return 0;
+				goto dont_drop;
 
 			return 1;
 		}
+dont_drop:
+		bond_change_dest_hook(skb, master);
 	}
+
+	return 0;
+}
+#else
+static inline int skb_bond_should_drop(struct sk_buff *skb)
+{
 	return 0;
 }
+#endif
 
 extern struct pernet_operations __net_initdata loopback_net_ops;
 #endif /* __KERNEL__ */
diff --git a/net/core/dev.c b/net/core/dev.c
index e3fe5c7..d9b758b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2061,6 +2061,12 @@ static inline int deliver_skb(struct sk_buff *skb,
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
+void (*bond_change_dest_hook)(struct sk_buff *skb,
+			      struct net_device *master) __read_mostly;
+EXPORT_SYMBOL(bond_change_dest_hook);
+#endif
+
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
 /* These hooks defined here for ATM */
 struct net_bridge;
