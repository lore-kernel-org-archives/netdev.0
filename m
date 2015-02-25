From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 8/8] ipmpls: Basic device for injecting packets into an mpls tunnel
Date: Wed, 25 Feb 2015 11:18:37 -0600
Message-ID: <87lhjlvriq.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51204 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbBYRWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:22:06 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Allow creating an mpls tunnel endpoint with

ip link add type ipmpls.

This tunnel has an mpls label for it's link layer address, and by
default sends all ingress packets over loopback to the local MPLS
forwarding logic which performs all of the work.

Ingress IPv4, IPv6 and MPLS packets are supported.

A new arp type ARPHRD_MPLS is defined for network devices that
whose link-layer addresses is an mpls label stack.

This is the most bare bones version of this tunnel device I can think
of.  Not even packet counters have been implemented. Offloads
and features in general are not supported, just to keep it simple and
obviously correct to start with.  In principle it should be able to
allow binding to a physical network device and pass all of the
offloads through ipmpls like the vlan, macvlan, or even ipvlan does.
Allowing a very fast light weight connection to the network.

The technical tricky bit to residing over something besides
the loopback device is how to get the next-hop mac address.
Neighbour table integration?  Something else?

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/uapi/linux/if_arp.h |   1 +
 net/mpls/Kconfig            |   5 +
 net/mpls/Makefile           |   1 +
 net/mpls/ipmpls.c           | 219 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 226 insertions(+)
 create mode 100644 net/mpls/ipmpls.c

diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index 4d024d75d64b..17d669fd1781 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -88,6 +88,7 @@
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
 #define ARPHRD_IEEE802154	  804
 #define ARPHRD_IEEE802154_MONITOR 805	/* IEEE 802.15.4 network monitor */
+#define ARPHRD_MPLS	806		/* IP and IPv6 over MPLS tunnels */
 
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index f4286ee7e2b0..4a6106dabfa8 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -27,4 +27,9 @@ config MPLS_ROUTING
 	help
 	 Add support for forwarding of mpls packets.
 
+config MPLS_IPTUNNEL
+	bool "MPLS: IP over MPLS tunnel support"
+	help
+	 A network device that allows sending ip packets into an mpls tunnel
+
 endif # MPLS
diff --git a/net/mpls/Makefile b/net/mpls/Makefile
index 60af15f1960e..4b578c80b9c5 100644
--- a/net/mpls/Makefile
+++ b/net/mpls/Makefile
@@ -3,3 +3,4 @@
 #
 obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
 obj-$(CONFIG_MPLS_ROUTING) += af_mpls.o
+obj-$(CONFIG_MPLS_IPTUNNEL) += ipmpls.o
diff --git a/net/mpls/ipmpls.c b/net/mpls/ipmpls.c
new file mode 100644
index 000000000000..96938748654f
--- /dev/null
+++ b/net/mpls/ipmpls.c
@@ -0,0 +1,219 @@
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/if_arp.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/module.h>
+#include <linux/mpls.h>
+#include "internal.h"
+
+static LIST_HEAD(ipmpls_dev_list);
+
+struct ipmpls_dev_priv {
+	unsigned label;
+	struct net_device *out_dev;
+	struct list_head list;
+	struct net_device *dev;
+};
+
+static netdev_tx_t ipmpls_dev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ipmpls_dev_priv *priv = netdev_priv(dev);
+	struct net_device *out_dev = priv->out_dev;
+	struct mpls_shim_hdr *hdr;
+	bool bottom_of_stack = true;
+	unsigned ttl;
+	int ret;
+
+	/* Obtain the ttl */
+	if (skb->protocol == htons(ETH_P_IP)) {
+		ttl = ip_hdr(skb)->ttl;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		ttl = ipv6_hdr(skb)->hop_limit;
+	} else if (skb->protocol == htons(ETH_P_MPLS_UC)) {
+		ttl = mpls_entry_decode(mpls_hdr(skb)).ttl;
+		bottom_of_stack = false;
+	} else
+		goto drop;
+
+	skb_orphan(skb);
+
+	skb->inner_protocol = skb->protocol;
+	skb->inner_network_header = skb->network_header;
+
+	skb_push(skb, sizeof(*hdr));
+	skb_reset_network_header(skb);
+	hdr = mpls_hdr(skb);
+	*hdr = mpls_entry_encode(priv->label, ttl, 0, bottom_of_stack);
+
+	skb->dev = out_dev;
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	ret = dev_hard_header(skb, out_dev, ETH_P_MPLS_UC,
+			      out_dev->dev_addr, NULL, skb->len);
+	if (ret >= 0)
+		ret = dev_queue_xmit(skb);
+	if (ret)
+		goto drop;
+
+	return 0;
+
+drop:
+	/* TODO keep packet counters */
+	kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int ipmpls_dev_init(struct net_device *dev)
+{
+	struct ipmpls_dev_priv *priv = netdev_priv(dev);
+
+	list_add_tail(&priv->list, &ipmpls_dev_list);
+
+	return 0;
+}
+
+
+static void ipmpls_dev_uninit(struct net_device *dev)
+{
+	struct ipmpls_dev_priv *priv = netdev_priv(dev);
+	list_del_init(&priv->list);
+}
+
+static void ipmpls_dev_free(struct net_device *dev)
+{
+	free_netdev(dev);
+}
+
+static const struct net_device_ops ipmpls_netdev_ops = {
+	.ndo_init		= ipmpls_dev_init,
+	.ndo_start_xmit		= ipmpls_dev_xmit,
+	.ndo_uninit		= ipmpls_dev_uninit,
+};
+
+#define IPMPLS_FEATURES (NETIF_F_SG | 			\
+			 NETIF_F_FRAGLIST |		\
+			 NETIF_F_HIGHDMA |		\
+			 NETIF_F_VLAN_CHALLENGED)
+
+static void ipmpls_dev_setup(struct net_device *dev)
+{
+	dev->netdev_ops		= &ipmpls_netdev_ops;
+
+	dev->type		= ARPHRD_MPLS;
+	dev->flags = IFF_NOARP;
+	dev->flags &= ~IFF_MULTICAST;
+	dev->iflink		= 0;
+	dev->addr_len		= 4;
+	dev->features		|= NETIF_F_LLTX;
+	dev->features		|= IPMPLS_FEATURES;
+	dev->hw_features	|= IPMPLS_FEATURES;
+	dev->vlan_features	= 0;
+
+	dev->destructor = ipmpls_dev_free;
+}
+
+static int ipmpls_dev_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	unsigned label;
+	if (!tb[IFLA_ADDRESS])
+		return -EADDRNOTAVAIL;
+	if (nla_len(tb[IFLA_ADDRESS]) != 4)
+		return -EINVAL;
+
+	label = be32_to_cpu(nla_get_be32(tb[IFLA_ADDRESS]));
+	if (label >= (1 << 20))
+		return -EADDRNOTAVAIL;
+
+	return 0;
+}
+
+static int ipmpls_dev_newlink(struct net *src_net, struct net_device *dev,
+			struct nlattr *tb[], struct nlattr *data[])
+{
+	struct ipmpls_dev_priv *priv = netdev_priv(dev);
+	u32 labels;
+
+	if (nla_get_labels(tb[IFLA_ADDRESS], 1, &labels, &priv->label))
+		return -EINVAL;
+
+	priv->out_dev = src_net->loopback_dev;
+	priv->dev = dev;
+
+	dev->hard_header_len =
+		priv->out_dev->hard_header_len + sizeof(struct mpls_shim_hdr);
+
+	return register_netdevice(dev);
+}
+
+static void ipmpls_dev_dellink(struct net_device *dev, struct list_head *head)
+{
+	unregister_netdevice_queue(dev, head);
+}
+
+static struct rtnl_link_ops ipmpls_ops = {
+	.kind		= "ipmpls",
+	.priv_size	= sizeof(struct ipmpls_dev_priv),
+	.setup		= ipmpls_dev_setup,
+	.validate	= ipmpls_dev_validate,
+	.newlink	= ipmpls_dev_newlink,
+	.dellink	= ipmpls_dev_dellink,
+};
+
+static int ipmpls_dev_notify(struct notifier_block *this, unsigned long event,
+			     void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	if (event == NETDEV_UNREGISTER) {
+		struct ipmpls_dev_priv *priv, *priv2;
+		LIST_HEAD(list_kill);
+
+		/* Ignore netns device moves */
+		if (dev->reg_state != NETREG_UNREGISTERING)
+			goto done;
+
+		list_for_each_entry_safe(priv, priv2, &ipmpls_dev_list, list) {
+			if (priv->out_dev != dev)
+				continue;
+
+			ipmpls_dev_dellink(priv->dev, &list_kill);
+		}
+		unregister_netdevice_many(&list_kill);
+	}
+done:
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ipmpls_dev_notifier = {
+	.notifier_call = ipmpls_dev_notify,
+};
+
+static int __init ipmpls_init(void)
+{
+	int err;
+
+	err = register_netdevice_notifier(&ipmpls_dev_notifier);
+	if (err)
+		goto out;
+
+	err = rtnl_link_register(&ipmpls_ops);
+	if (err)
+		goto out_unregister_notifier;
+out:
+	return err;
+out_unregister_notifier:
+	unregister_netdevice_notifier(&ipmpls_dev_notifier);
+	goto out;
+}
+module_init(ipmpls_init);
+
+static void __exit ipmpls_exit(void)
+{
+	rtnl_link_unregister(&ipmpls_ops);
+	unregister_netdevice_notifier(&ipmpls_dev_notifier);
+}
+module_exit(ipmpls_exit);
+
+MODULE_ALIAS_RTNL_LINK("ipmpls");
-- 
2.2.1
