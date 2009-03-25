From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: allow bond in mode balance-alb to work properly
	in bridge -try2
Date: Wed, 25 Mar 2009 14:04:43 +0100
Message-ID: <20090325130443.GG3437@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35944 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753934AbZCYNHN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 09:07:13 -0400
Content-Disposition: inline
In-Reply-To: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend)

Hi all.

The problem is described in following bugzilla:
https://bugzilla.redhat.com/show_bug.cgi?id=487763

Basically here's what's going on. In every mode, bonding interface uses the same
mac address for all enslaved devices. Except for mode balance-alb. When you put
this kind of bond device into a bridge it will only add one of mac adresses into
a hash list of mac addresses, say X. This mac address is marked as local. But
this bonding interface also has mac address Y. Now then packet arrives with
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
index 27fb7f5..2838be0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1762,6 +1762,26 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	return 0;
 }
 
+void bond_alb_change_dest(struct sk_buff *skb)
+{
+	struct net_device *bond_dev = skb->dev;
+	struct bonding *bond = netdev_priv(bond_dev);
+	unsigned char *dest = eth_hdr(skb)->h_dest;
+	struct slave *slave;
+	int i;
+
+	if (!memcmp(dest, bond_dev->dev_addr, ETH_ALEN))
+		return;
+	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		if (!memcmp(slave->dev->dev_addr, dest, ETH_ALEN)) {
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
index 50968f8..77f36fb 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -127,6 +127,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
+void bond_alb_change_dest(struct sk_buff *skb);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3d76686..b62fdc4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4294,6 +4294,19 @@ unwind:
 	return res;
 }
 
+/*
+ * Called via bond_change_dest_hook.
+ * note: already called with rcu_read_lock (preempt_disabled)
+ */
+void bond_change_dest(struct sk_buff *skb)
+{
+	struct net_device *bond_dev = skb->dev;
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	if (bond->params.mode == BOND_MODE_ALB)
+		bond_alb_change_dest(skb);
+}
+
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -5243,6 +5256,8 @@ static int __init bonding_init(void)
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
 
+	bond_change_dest_hook = bond_change_dest;
+
 	goto out;
 err:
 	list_for_each_entry(bond, &bond_dev_list, bond_list) {
@@ -5266,6 +5281,8 @@ static void __exit bonding_exit(void)
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_unregister_ipv6_notifier();
 
+	bond_change_dest_hook = NULL;
+
 	bond_destroy_sysfs();
 
 	rtnl_lock();
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca849d2..df92b70 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -375,5 +375,7 @@ static inline void bond_unregister_ipv6_notifier(void)
 }
 #endif
 
+extern void (*bond_change_dest_hook)(struct sk_buff *skb);
+
 #endif /* _LINUX_BONDING_H */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index e3fe5c7..abe68d9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2061,6 +2061,13 @@ static inline int deliver_skb(struct sk_buff *skb,
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
+void (*bond_change_dest_hook)(struct sk_buff *skb) __read_mostly;
+EXPORT_SYMBOL(bond_change_dest_hook);
+#else
+#define bond_change_dest_hook(skb) do {} while (0)
+#endif
+
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
 /* These hooks defined here for ATM */
 struct net_bridge;
@@ -2251,10 +2258,12 @@ int netif_receive_skb(struct sk_buff *skb)
 	null_or_orig = NULL;
 	orig_dev = skb->dev;
 	if (orig_dev->master) {
-		if (skb_bond_should_drop(skb))
+		if (skb_bond_should_drop(skb)) {
 			null_or_orig = orig_dev; /* deliver only exact match */
-		else
+		} else {
 			skb->dev = orig_dev->master;
+			bond_change_dest_hook(skb);
+		}
 	}
 
 	__get_cpu_var(netdev_rx_stat).total++;
