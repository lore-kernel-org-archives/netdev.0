From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] Introduce notification events for routing changes
Date: Thu, 29 Nov 2012 00:34:35 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1211290018060.22729@blackhole.kfki.hu>
References: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu> <1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu> <20121128.175929.618012822860698468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121128.175929.618012822860698468.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2012, David Miller wrote:

> > The netfilter MASQUERADE target does not handle the case when the routing
> > changes and the source address of existing connections become invalid.
> > The problem can be solved if routing modifications create events to which
> > the MASQUERADE target can subscribe and then delete the affected
> > connections.
> > 
> > The patch adds the required event support for IPv4/IPv6.
> > 
> > Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> 
> What part of the information are you actually interested in?

Actually, just the pointer to struct net is used.

> Because just saying that a route is added or removed using fib_info X
> doesn't tell you a whole lot.

We have to scan the whole conntrack table to find out which entries are 
affected by the routing change, whatever it was. More precisely, for which 
entry did the output interface changed? The output interface is stored in 
the nat part of conntrack for MASQUERADE, so it can directly be compared 
to the result of the route lookup.
 
> fib_info only encapsulates the information that can be shared heaving
> with many ipv4 routes.  It doesn't include the TOS or other aspects
> stored in the fib_alias part.  I can only guess that you did not
> use fib_alias in order to avoid having to export that structure to
> the callers, as it is currently private to net/ipv4/
> 
> The notifier doesn't seem to distinguish between adds or removes
> either, making it less useful in another way.
> 
> I would suggest passing a super-structure that gives the event type:
> 
> 	struct route_changed_info {
> 		enum {
> 			add,
> 			remove,
> 		} event_type;
> 		void *data;
> 	};
> 
> or something like that.
> 
> Can you also show us exactly how this will be used?  Otherwise we
> have to guess.

Yes, sure. Here follows the patch against conntrack/MASQUERADE:

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index bd8eea7..65b1b51 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -46,6 +46,12 @@ struct nf_conn_nat {
     defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE) || \
     defined(CONFIG_IP6_NF_TARGET_MASQUERADE) || \
     defined(CONFIG_IP6_NF_TARGET_MASQUERADE_MODULE)
+    	union {
+#if IS_ENABLED(CONFIG_IP6_NF_TARGET_MASQUERADE)
+		__be32 flowlabel;
+#endif
+		u8 tos;
+	} u;
 	int masq_index;
 #endif
 };
diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 1644cdd..3b47b32 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -87,6 +87,10 @@ enum ip_conntrack_status {
 	/* Conntrack got a helper explicitly attached via CT target. */
 	IPS_HELPER_BIT = 13,
 	IPS_HELPER = (1 << IPS_HELPER_BIT),
+
+	/* Conntrack must be deleted when routing changed (MASQUERADE). */
+	IPS_ROUTING_DEPENDENT_BIT = 14,
+	IPS_ROUTING_DEPENDENT = (1 << IPS_ROUTING_DEPENDENT_BIT),
 };
 
 /* Connection tracking event types */
diff --git a/include/uapi/linux/netfilter/nf_nat.h b/include/uapi/linux/netfilter/nf_nat.h
index bf0cc37..a0dfac7 100644
--- a/include/uapi/linux/netfilter/nf_nat.h
+++ b/include/uapi/linux/netfilter/nf_nat.h
@@ -8,6 +8,7 @@
 #define NF_NAT_RANGE_PROTO_SPECIFIED	2
 #define NF_NAT_RANGE_PROTO_RANDOM	4
 #define NF_NAT_RANGE_PERSISTENT		8
+#define NF_NAT_ROUTING_DEPENDENT	16
 
 struct nf_nat_ipv4_range {
 	unsigned int			flags;
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 5d5d4d1..1056d99 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -19,6 +19,7 @@
 #include <net/ip.h>
 #include <net/checksum.h>
 #include <net/route.h>
+#include <net/ip_fib.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter/x_tables.h>
 #include <net/netfilter/nf_nat.h>
@@ -88,6 +89,11 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	newrange.min_proto   = mr->range[0].min;
 	newrange.max_proto   = mr->range[0].max;
 
+	if (mr->range[0].flags & NF_NAT_ROUTING_DEPENDENT) {
+		nat->u.tos = RT_TOS(ip_hdr(skb)->tos);
+		set_bit(IPS_ROUTING_DEPENDENT, &ct->status);
+	}
+
 	/* Hand modified range to generic setup. */
 	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
 }
@@ -132,6 +138,74 @@ static int masq_inet_event(struct notifier_block *this,
 	return masq_device_event(this, event, dev);
 }
 
+struct nf_net_fl4 {
+	struct net *net;
+	struct flowi4 fl4;
+	struct fib_result res;
+};
+
+static int
+route_cmp(struct nf_conn *ct, void *ptr)
+{
+	const struct nf_conn_nat *nat = nfct_nat(ct);
+	struct nf_net_fl4 *nf = ptr;
+	int ret, found = 0;
+
+	if (!nat)
+		return 0;
+	if (nf_ct_l3num(ct) != NFPROTO_IPV4)
+		return 0;
+	if (!test_bit(IPS_ROUTING_DEPENDENT, &ct->status))
+		return 0;
+
+	/* We don't have an skb and have to re-check the routing */
+	nf->fl4.daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip;
+	nf->fl4.saddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
+	nf->fl4.flowi4_tos = nat->u.tos;
+#if defined(CONFIG_NF_CONNTRACK_MARK)
+	nf->fl4.flowi4_mark = ct->mark;
+#endif
+	rcu_read_lock();
+	if (!fib_lookup(nf->net, &nf->fl4, &nf->res)) {
+		rcu_read_unlock();
+		/* Routing changed and no route. Purge the entry */
+		return 1;
+	}
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	for (ret = 0; ret < nf->res.fi->fib_nhs; ret++) {
+		struct fib_nh *nh = &nf->res.fi->fib_nh[ret];
+
+		if (nat->masq_index != (int)(long)nh->nh_dev->ifindex) {
+			found = 1;
+			break;
+		}
+	}
+#else
+	found = nat->masq_index != (int)(long)FIB_RES_DEV(nf->res)->ifindex;
+#endif
+	rcu_read_unlock();
+	return found;
+}
+
+static int masq_route_event(struct notifier_block *this,
+			    unsigned long event,
+			    void *ptr)
+{
+	struct net *net = ((struct fib_info *)ptr)->fib_net;
+	struct nf_net_fl4 nf = {
+		.net = net,
+		.fl4 = {
+			.flowi4_scope = RT_SCOPE_UNIVERSE,
+		},
+	};
+
+	if (event == NETDEV_ROUTE_CHANGED)
+		/* Routing changed, delete marked entries */
+		nf_ct_iterate_cleanup(net, route_cmp, (void *)&nf);
+
+	return NOTIFY_DONE;
+}
+
 static struct notifier_block masq_dev_notifier = {
 	.notifier_call	= masq_device_event,
 };
@@ -140,6 +214,10 @@ static struct notifier_block masq_inet_notifier = {
 	.notifier_call	= masq_inet_event,
 };
 
+static struct notifier_block masq_route_notifier = {
+	.notifier_call	= masq_route_event,
+};
+
 static struct xt_target masquerade_tg_reg __read_mostly = {
 	.name		= "MASQUERADE",
 	.family		= NFPROTO_IPV4,
@@ -162,6 +240,8 @@ static int __init masquerade_tg_init(void)
 		register_netdevice_notifier(&masq_dev_notifier);
 		/* Register IP address change reports */
 		register_inetaddr_notifier(&masq_inet_notifier);
+		/* Register route change reports */
+		register_iproute_notifier(&masq_route_notifier);
 	}
 
 	return ret;
@@ -172,6 +252,7 @@ static void __exit masquerade_tg_exit(void)
 	xt_unregister_target(&masquerade_tg_reg);
 	unregister_netdevice_notifier(&masq_dev_notifier);
 	unregister_inetaddr_notifier(&masq_inet_notifier);
+	unregister_iproute_notifier(&masq_route_notifier);
 }
 
 module_init(masquerade_tg_init);
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
index 60e9053..20dfa1d 100644
--- a/net/ipv6/netfilter/ip6t_MASQUERADE.c
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -19,6 +19,8 @@
 #include <net/netfilter/nf_nat.h>
 #include <net/addrconf.h>
 #include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <uapi/linux/route.h>
 
 static unsigned int
 masquerade_tg6(struct sk_buff *skb, const struct xt_action_param *par)
@@ -45,6 +47,12 @@ masquerade_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	newrange.min_proto	= range->min_proto;
 	newrange.max_proto	= range->max_proto;
 
+	if (range->flags & NF_NAT_ROUTING_DEPENDENT) {
+		nfct_nat(ct)->u.flowlabel =
+			(* (__be32 *) ipv6_hdr(skb)) & IPV6_FLOWINFO_MASK;
+		set_bit(IPS_ROUTING_DEPENDENT, &ct->status);
+	}
+
 	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
 }
 
@@ -97,6 +105,65 @@ static struct notifier_block masq_inet_notifier = {
 	.notifier_call	= masq_inet_event,
 };
 
+struct nf_net_fl6 {
+	struct net *net;
+	struct flowi6 fl6;
+};
+
+static int
+route_cmp(struct nf_conn *ct, void *ptr)
+{
+	const struct nf_conn_nat *nat = nfct_nat(ct);
+	struct nf_net_fl6 *nf = ptr;
+	struct rt6_info *rt;
+	int ret;
+
+	if (!nat)
+		return 0;
+	if (nf_ct_l3num(ct) != NFPROTO_IPV6)
+		return 0;
+	if (!test_bit(IPS_ROUTING_DEPENDENT, &ct->status))
+		return 0;
+
+	/* We don't have an skb and have to re-check the routing */
+	nf->fl6.daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.in6;
+	nf->fl6.saddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.in6;
+	nf->fl6.flowlabel = nat->u.flowlabel;
+	nf->fl6.flowi6_proto =
+		ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.protonum;
+#if defined(CONFIG_NF_CONNTRACK_MARK)
+	nf->fl6.flowi6_mark = ct->mark;
+#endif
+	rt = (void *) ip6_route_lookup(nf->net, &nf->fl6,
+				       RT6_LOOKUP_F_HAS_SADDR);
+	ret = rt->dst.error ||
+	      (rt->rt6i_flags & RTF_REJECT) ||
+	      nat->masq_index != (int)(long)rt->rt6i_idev->dev->ifindex;
+
+	dst_release(&rt->dst);
+	return ret;
+}
+
+static int masq_route_event(struct notifier_block *this,
+			    unsigned long event,
+			    void *ptr)
+{
+	struct net *net = dev_net(((struct rt6_info *)ptr)->dst.dev);
+	struct nf_net_fl6 nf = {
+		.net = net,
+	};
+
+	if (event == NETDEV_ROUTE_CHANGED)
+		/* Routing changed, delete marked entries */
+		nf_ct_iterate_cleanup(net, route_cmp, (void *)&nf);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block masq_route_notifier = {
+	.notifier_call	= masq_route_event,
+};
+
 static struct xt_target masquerade_tg6_reg __read_mostly = {
 	.name		= "MASQUERADE",
 	.family		= NFPROTO_IPV6,
@@ -116,12 +183,14 @@ static int __init masquerade_tg6_init(void)
 	if (err == 0) {
 		register_netdevice_notifier(&masq_dev_notifier);
 		register_inet6addr_notifier(&masq_inet_notifier);
+		register_ip6route_notifier(&masq_route_notifier);
 	}
 
 	return err;
 }
 static void __exit masquerade_tg6_exit(void)
 {
+	unregister_ip6route_notifier(&masq_route_notifier);
 	unregister_inet6addr_notifier(&masq_inet_notifier);
 	unregister_netdevice_notifier(&masq_dev_notifier);
 	xt_unregister_target(&masquerade_tg6_reg);


Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
