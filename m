From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv3 next 3/3] ipvlan: Introduce l3s mode
Date: Thu, 15 Sep 2016 17:14:06 -0700
Message-ID: <1473984847-32243-1-git-send-email-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34696 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755521AbcIPAO2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 20:14:28 -0400
Received: by mail-pa0-f66.google.com with SMTP id vz6so2727898pab.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 17:14:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

In a typical IPvlan L3 setup where master is in default-ns and
each slave is into different (slave) ns. In this setup egress
packet processing for traffic originating from slave-ns will
hit all NF_HOOKs in slave-ns as well as default-ns. However same
is not true for ingress processing. All these NF_HOOKs are
hit only in the slave-ns skipping them in the default-ns.
IPvlan in L3 mode is restrictive and if admins want to deploy
iptables rules in default-ns, this asymmetric data path makes it
impossible to do so.

This patch makes use of the l3_rcv() (added as part of l3mdev
enhancements) to perform input route lookup on RX packets without
changing the skb->dev and then uses nf_hook at NF_INET_LOCAL_IN
to change the skb->dev just before handing over skb to L4.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: David Ahern <dsa@cumulusnetworks.com>
---
 Documentation/networking/ipvlan.txt |  7 ++-
 drivers/net/Kconfig                 |  1 +
 drivers/net/ipvlan/ipvlan.h         |  7 +++
 drivers/net/ipvlan/ipvlan_core.c    | 94 +++++++++++++++++++++++++++++++++++++
 drivers/net/ipvlan/ipvlan_main.c    | 92 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/if_link.h        |  1 +
 6 files changed, 194 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
index 14422f8fcdc4..24196cef7c91 100644
--- a/Documentation/networking/ipvlan.txt
+++ b/Documentation/networking/ipvlan.txt
@@ -22,7 +22,7 @@ The driver can be built into the kernel (CONFIG_IPVLAN=y) or as a module
 	There are no module parameters for this driver and it can be configured
 using IProute2/ip utility.
 
-	ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | L3 }
+	ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | l3 | l3s }
 
 	e.g. ip link add link ipvl0 eth0 type ipvlan mode l2
 
@@ -48,6 +48,11 @@ master device for the L2 processing and routing from that instance will be
 used before packets are queued on the outbound device. In this mode the slaves
 will not receive nor can send multicast / broadcast traffic.
 
+4.3 L3S mode:
+	This is very similar to the L3 mode except that iptables (conn-tracking)
+works in this mode and hence it is L3-symmetric (L3s). This will have slightly less
+performance but that shouldn't matter since you are choosing this mode over plain-L3
+mode to make conn-tracking work.
 
 5. What to choose (macvlan vs. ipvlan)?
 	These two devices are very similar in many regards and the specific use
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0c5415b05ea9..8768a625350d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -149,6 +149,7 @@ config IPVLAN
     tristate "IP-VLAN support"
     depends on INET
     depends on IPV6
+    depends on NET_L3_MASTER_DEV
     ---help---
       This allows one to create virtual devices off of a main interface
       and packets will be delivered based on the dest L3 (IPv6/IPv4 addr)
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 695a5dc9ace3..371f4548c42d 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -23,11 +23,13 @@
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/inetdevice.h>
+#include <linux/netfilter.h>
 #include <net/ip.h>
 #include <net/ip6_route.h>
 #include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/addrconf.h>
+#include <net/l3mdev.h>
 
 #define IPVLAN_DRV	"ipvlan"
 #define IPV_DRV_VER	"0.1"
@@ -96,6 +98,7 @@ struct ipvl_port {
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
+	bool			hooks_attached;
 	struct rcu_head		rcu;
 };
 
@@ -124,4 +127,8 @@ struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
 				   const void *iaddr, bool is_v6);
 bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6);
 void ipvlan_ht_addr_del(struct ipvl_addr *addr);
+struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
+			      u16 proto);
+unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
+			     const struct nf_hook_state *state);
 #endif /* __IPVLAN_H */
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index b5f9511d819e..b4e990743e1d 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -560,6 +560,7 @@ int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	case IPVLAN_MODE_L2:
 		return ipvlan_xmit_mode_l2(skb, dev);
 	case IPVLAN_MODE_L3:
+	case IPVLAN_MODE_L3S:
 		return ipvlan_xmit_mode_l3(skb, dev);
 	}
 
@@ -664,6 +665,8 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
 		return ipvlan_handle_mode_l2(pskb, port);
 	case IPVLAN_MODE_L3:
 		return ipvlan_handle_mode_l3(pskb, port);
+	case IPVLAN_MODE_L3S:
+		return RX_HANDLER_PASS;
 	}
 
 	/* Should not reach here */
@@ -672,3 +675,94 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
 	kfree_skb(skb);
 	return RX_HANDLER_CONSUMED;
 }
+
+static struct ipvl_addr *ipvlan_skb_to_addr(struct sk_buff *skb,
+					    struct net_device *dev)
+{
+	struct ipvl_addr *addr = NULL;
+	struct ipvl_port *port;
+	void *lyr3h;
+	int addr_type;
+
+	if (!dev || !netif_is_ipvlan_port(dev))
+		goto out;
+
+	port = ipvlan_port_get_rcu(dev);
+	if (!port || port->mode != IPVLAN_MODE_L3S)
+		goto out;
+
+	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
+	if (!lyr3h)
+		goto out;
+
+	addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
+out:
+	return addr;
+}
+
+struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
+			      u16 proto)
+{
+	struct ipvl_addr *addr;
+	struct net_device *sdev;
+
+	addr = ipvlan_skb_to_addr(skb, dev);
+	if (!addr)
+		goto out;
+
+	sdev = addr->master->dev;
+	switch (proto) {
+	case AF_INET:
+	{
+		int err;
+		struct iphdr *ip4h = ip_hdr(skb);
+
+		err = ip_route_input_noref(skb, ip4h->daddr, ip4h->saddr,
+					   ip4h->tos, sdev);
+		if (unlikely(err))
+			goto out;
+		break;
+	}
+	case AF_INET6:
+	{
+		struct dst_entry *dst;
+		struct ipv6hdr *ip6h = ipv6_hdr(skb);
+		int flags = RT6_LOOKUP_F_HAS_SADDR;
+		struct flowi6 fl6 = {
+			.flowi6_iif   = sdev->ifindex,
+			.daddr        = ip6h->daddr,
+			.saddr        = ip6h->saddr,
+			.flowlabel    = ip6_flowinfo(ip6h),
+			.flowi6_mark  = skb->mark,
+			.flowi6_proto = ip6h->nexthdr,
+		};
+
+		skb_dst_drop(skb);
+		dst = ip6_route_input_lookup(dev_net(sdev), sdev, &fl6, flags);
+		skb_dst_set(skb, dst);
+		break;
+	}
+	default:
+		break;
+	}
+
+out:
+	return skb;
+}
+
+unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
+			     const struct nf_hook_state *state)
+{
+	struct ipvl_addr *addr;
+	unsigned int len;
+
+	addr = ipvlan_skb_to_addr(skb, skb->dev);
+	if (!addr)
+		goto out;
+
+	skb->dev = addr->master->dev;
+	len = skb->len + ETH_HLEN;
+	ipvlan_count_rx(addr->master, len, true, false);
+out:
+	return NF_ACCEPT;
+}
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 18b4e8c7f68a..aca690f41559 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -9,24 +9,91 @@
 
 #include "ipvlan.h"
 
+static u32 ipvl_nf_hook_refcnt = 0;
+
+static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
+	{
+		.hook     = ipvlan_nf_input,
+		.pf       = NFPROTO_IPV4,
+		.hooknum  = NF_INET_LOCAL_IN,
+		.priority = INT_MAX,
+	},
+	{
+		.hook     = ipvlan_nf_input,
+		.pf       = NFPROTO_IPV6,
+		.hooknum  = NF_INET_LOCAL_IN,
+		.priority = INT_MAX,
+	},
+};
+
+static struct l3mdev_ops ipvl_l3mdev_ops __read_mostly = {
+	.l3mdev_l3_rcv = ipvlan_l3_rcv,
+};
+
 static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 {
 	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
 }
 
-static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
+static int ipvlan_register_nf_hook(void)
+{
+	int err = 0;
+
+	if (!ipvl_nf_hook_refcnt) {
+		err = _nf_register_hooks(ipvl_nfops, ARRAY_SIZE(ipvl_nfops));
+		if (!err)
+			ipvl_nf_hook_refcnt = 1;
+	} else {
+		ipvl_nf_hook_refcnt++;
+	}
+
+	return err;
+}
+
+static void ipvlan_unregister_nf_hook(void)
+{
+	BUG_ON(!ipvl_nf_hook_refcnt);
+
+	ipvl_nf_hook_refcnt--;
+	if (!ipvl_nf_hook_refcnt)
+		_nf_unregister_hooks(ipvl_nfops, ARRAY_SIZE(ipvl_nfops));
+}
+
+static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
 {
 	struct ipvl_dev *ipvlan;
+	struct net_device *mdev = port->dev;
+	int err = 0;
 
+	ASSERT_RTNL();
 	if (port->mode != nval) {
+		if (nval == IPVLAN_MODE_L3S) {
+			if (!port->hooks_attached) {
+				err = ipvlan_register_nf_hook();
+				if (!err) {
+					mdev->l3mdev_ops = &ipvl_l3mdev_ops;
+					mdev->priv_flags |= IFF_L3MDEV_MASTER;
+					port->hooks_attached = true;
+				} else
+					return err;
+			}
+		} else {
+			if (port->hooks_attached) {
+				mdev->priv_flags &= ~IFF_L3MDEV_MASTER;
+				ipvlan_unregister_nf_hook();
+				mdev->l3mdev_ops = NULL;
+			}
+			port->hooks_attached = false;
+		}
 		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
-			if (nval == IPVLAN_MODE_L3)
+			if (nval == IPVLAN_MODE_L3 || nval == IPVLAN_MODE_L3S)
 				ipvlan->dev->flags |= IFF_NOARP;
 			else
 				ipvlan->dev->flags &= ~IFF_NOARP;
 		}
 		port->mode = nval;
 	}
+	return err;
 }
 
 static int ipvlan_port_create(struct net_device *dev)
@@ -74,6 +141,12 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	struct ipvl_port *port = ipvlan_port_get_rtnl(dev);
 
 	dev->priv_flags &= ~IFF_IPVLAN_MASTER;
+	if (port->hooks_attached) {
+		dev->priv_flags &= ~IFF_L3MDEV_MASTER;
+		ipvlan_unregister_nf_hook();
+		dev->l3mdev_ops = NULL;
+		port->hooks_attached = false;
+	}
 	netdev_rx_handler_unregister(dev);
 	cancel_work_sync(&port->wq);
 	__skb_queue_purge(&port->backlog);
@@ -132,7 +205,8 @@ static int ipvlan_open(struct net_device *dev)
 	struct net_device *phy_dev = ipvlan->phy_dev;
 	struct ipvl_addr *addr;
 
-	if (ipvlan->port->mode == IPVLAN_MODE_L3)
+	if (ipvlan->port->mode == IPVLAN_MODE_L3 ||
+	    ipvlan->port->mode == IPVLAN_MODE_L3S)
 		dev->flags |= IFF_NOARP;
 	else
 		dev->flags &= ~IFF_NOARP;
@@ -372,13 +446,14 @@ static int ipvlan_nl_changelink(struct net_device *dev,
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_port *port = ipvlan_port_get_rtnl(ipvlan->phy_dev);
+	int err = 0;
 
 	if (data && data[IFLA_IPVLAN_MODE]) {
 		u16 nmode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
 
-		ipvlan_set_port_mode(port, nmode);
+		err = ipvlan_set_port_mode(port, nmode);
 	}
-	return 0;
+	return err;
 }
 
 static size_t ipvlan_nl_getsize(const struct net_device *dev)
@@ -473,10 +548,13 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 		unregister_netdevice(dev);
 		return err;
 	}
+	err = ipvlan_set_port_mode(port, mode);
+	if (err) {
+		unregister_netdevice(dev);
+		return err;
+	}
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
-	ipvlan_set_port_mode(port, mode);
-
 	netif_stacked_transfer_operstate(phy_dev, dev);
 	return 0;
 }
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9bf3aecfe05b..a615583bab09 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -464,6 +464,7 @@ enum {
 enum ipvlan_mode {
 	IPVLAN_MODE_L2 = 0,
 	IPVLAN_MODE_L3,
+	IPVLAN_MODE_L3S,
 	IPVLAN_MODE_MAX
 };
 
-- 
2.8.0.rc3.226.g39d4020
