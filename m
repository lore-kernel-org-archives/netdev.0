From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH v4 2/5] can: add rtnetlink support
Date: Wed, 27 Apr 2011 10:57:05 +0200
Message-ID: <20110427085705.GC757@kurt.e-circ.dyndns.org>
References: <20110427085330.GA757@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110427085330.GA757-ozGf4kBk5synFtIcQ8t7k3L8HoS0Hn3T@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds rtnetlink support for AF_CAN. This support is really
a multiplexer towards the different CAN protocols.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
---
 include/linux/can/core.h |   26 +++++-
 net/can/af_can.c         |  240 +++++++++++++++++++++++++++++++++++++++++++---
 net/can/bcm.c            |    2 +-
 net/can/raw.c            |    2 +-
 4 files changed, 253 insertions(+), 17 deletions(-)

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index d803a5e..7ffd839 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -18,6 +18,7 @@
 #include <linux/can.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <net/rtnetlink.h>
 
 #define CAN_VERSION "20090105"
 
@@ -40,6 +41,27 @@ struct can_proto {
 	int protocol;
 	const struct proto_ops *ops;
 	struct proto *prot;
+	const struct rtnl_af_ops *rtnl_link_ops;
+	/*
+	 * hooks for rtnl hooks
+	 * for the *dump* functions, cb->args[0] is reserved
+	 * for use by af_can.c, so keep your fingers off.
+	 */
+	rtnl_doit_func rtnl_new_addr;
+	rtnl_doit_func rtnl_del_addr;
+	rtnl_dumpit_func rtnl_dump_addr;
+};
+
+/*
+ * this is quite a dirty hack:
+ * reuse the second byte of a rtnetlink msg
+ * to indicate the precise protocol.
+ * The major problem is that is may conflict
+ * with the prefixlen in struct ifaddrmsg.
+ */
+struct rtgencanmsg {
+	unsigned char rtgen_family;
+	unsigned char can_protocol;
 };
 
 /*
@@ -53,8 +75,8 @@ struct can_proto {
 
 /* function prototypes for the CAN networklayer core (af_can.c) */
 
-extern int  can_proto_register(struct can_proto *cp);
-extern void can_proto_unregister(struct can_proto *cp);
+extern int  can_proto_register(const struct can_proto *cp);
+extern void can_proto_unregister(const struct can_proto *cp);
 
 extern int  can_rx_register(struct net_device *dev, canid_t can_id,
 			    canid_t mask,
diff --git a/net/can/af_can.c b/net/can/af_can.c
index a8dcaa4..c7e9cdf 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -3,6 +3,7 @@
  *            (used by different CAN protocol modules)
  *
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * Copyright (C) 2011 Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -69,7 +70,8 @@ static __initdata const char banner[] = KERN_INFO
 MODULE_DESCRIPTION("Controller Area Network PF_CAN core");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>, "
-	      "Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>");
+	      "Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>, "
+	      "Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>");
 
 MODULE_ALIAS_NETPROTO(PF_CAN);
 
@@ -84,7 +86,7 @@ static DEFINE_SPINLOCK(can_rcvlists_lock);
 static struct kmem_cache *rcv_cache __read_mostly;
 
 /* table of registered CAN protocols */
-static struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
+static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
 static DEFINE_MUTEX(proto_tab_lock);
 
 struct timer_list can_stattimer;   /* timer for statistics update */
@@ -115,9 +117,9 @@ static void can_sock_destruct(struct sock *sk)
 	skb_queue_purge(&sk->sk_receive_queue);
 }
 
-static struct can_proto *can_try_module_get(int protocol)
+static const struct can_proto *can_try_module_get(int protocol)
 {
-	struct can_proto *cp;
+	const struct can_proto *cp;
 
 	rcu_read_lock();
 	cp = rcu_dereference(proto_tab[protocol]);
@@ -128,18 +130,20 @@ static struct can_proto *can_try_module_get(int protocol)
 	return cp;
 }
 
+static inline void can_put_proto(const struct can_proto *cp)
+{
+	module_put(cp->prot->owner);
+}
+
 static int can_create(struct net *net, struct socket *sock, int protocol,
 		      int kern)
 {
 	struct sock *sk;
-	struct can_proto *cp;
+	const struct can_proto *cp;
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
 
-	if (protocol < 0 || protocol >= CAN_NPROTO)
-		return -EINVAL;
-
 	if (!net_eq(net, &init_net))
 		return -EAFNOSUPPORT;
 
@@ -166,8 +170,8 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 
 	/* check for available protocol and correct usage */
 
-	if (!cp)
-		return -EPROTONOSUPPORT;
+	if (IS_ERR(cp))
+		return PTR_ERR(cp);
 
 	if (cp->type != sock->type) {
 		err = -EPROTOTYPE;
@@ -195,7 +199,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
 	}
 
  errout:
-	module_put(cp->prot->owner);
+	can_put_proto(cp);
 	return err;
 }
 
@@ -691,7 +695,7 @@ drop:
  *  -EBUSY  protocol already in use
  *  -ENOBUF if proto_register() fails
  */
-int can_proto_register(struct can_proto *cp)
+int can_proto_register(const struct can_proto *cp)
 {
 	int proto = cp->protocol;
 	int err = 0;
@@ -728,7 +732,7 @@ EXPORT_SYMBOL(can_proto_register);
  * can_proto_unregister - unregister CAN transport protocol
  * @cp: pointer to CAN protocol structure
  */
-void can_proto_unregister(struct can_proto *cp)
+void can_proto_unregister(const struct can_proto *cp)
 {
 	int proto = cp->protocol;
 
@@ -818,6 +822,206 @@ static struct notifier_block can_netdev_notifier __read_mostly = {
 	.notifier_call = can_notifier,
 };
 
+/*
+ * RTNETLINK
+ */
+static int can_rtnl_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	int ret, protocol;
+	const struct can_proto *cp;
+	rtnl_doit_func fn;
+
+	protocol = ((struct rtgencanmsg *)NLMSG_DATA(nlh))->can_protocol;
+	/* since rtnl_lock is held, dont try to load protocol */
+	cp = can_get_proto(protocol, 0);
+	if (IS_ERR(cp))
+		return PTR_ERR(cp);
+
+	switch (nlh->nlmsg_type) {
+	case RTM_NEWADDR:
+		fn = cp->rtnl_new_addr;
+		break;
+	case RTM_DELADDR:
+		fn = cp->rtnl_del_addr;
+		break;
+	default:
+		fn = 0;
+		break;
+	}
+	if (fn)
+		ret = fn(skb, nlh, arg);
+	else
+		ret = -EPROTONOSUPPORT;
+	can_put_proto(cp);
+	return ret;
+}
+
+static int can_rtnl_dumpit(struct sk_buff *skb, struct netlink_callback *cb,
+		int offset)
+{
+	int ret, j;
+	const struct can_proto *cp;
+	rtnl_dumpit_func fn;
+
+	ret = 0;
+	for (j = cb->args[0]; j < CAN_NPROTO; ++j) {
+		/* save state */
+		cb->args[0] = j;
+		cp = can_get_proto(j, 0);
+		if (IS_ERR(cp))
+			/* we are looping, any error is our own fault */
+			continue;
+		fn = *((rtnl_dumpit_func *)(&((const uint8_t *)cp)[offset]));
+		if (fn)
+			ret = fn(skb, cb);
+		can_put_proto(cp);
+		if (ret < 0)
+			/* suspend this skb */
+			return ret;
+	}
+	return ret;
+}
+
+static int can_rtnl_dump_addr(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	return can_rtnl_dumpit(skb, cb,
+			offsetof(struct can_proto, rtnl_dump_addr));
+}
+
+/*
+ * LINK AF properties
+ */
+static size_t can_get_link_af_size(const struct net_device *dev)
+{
+	int ret, j, total;
+	const struct can_proto *cp;
+
+	if (!net_eq(dev_net(dev), &init_net) || (dev->type != ARPHRD_CAN))
+		return 0;
+
+	total = 0;
+	for (j = 0; j < CAN_NPROTO; ++j) {
+		cp = can_try_mdoule_get(j);
+		if (IS_ERR(cp))
+			/* no worry */
+			continue;
+		ret = 0;
+		if (cp->rtnl_link_ops && cp->rtnl_link_ops->get_link_af_size)
+			ret = cp->rtnl_link_ops->get_link_af_size(dev) +
+				nla_total_size(sizeof(struct nlattr));
+		can_put_proto(cp);
+		if (ret < 0)
+			return ret;
+		total += ret;
+	}
+	return nla_total_size(total);
+}
+
+static int can_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
+{
+	int ret, j, n;
+	struct nlattr *nla;
+	const struct can_proto *cp;
+
+	if (!net_eq(dev_net(dev), &init_net) || (dev->type != ARPHRD_CAN))
+		return -ENODATA;
+
+	n = 0;
+	for (j = 0; j < CAN_NPROTO; ++j) {
+		cp = can_try_module_get(j);
+		if (IS_ERR(cp))
+			/* no worry */
+			continue;
+		if (cp->rtnl_link_ops && cp->rtnl_link_ops->fill_link_af) {
+			nla = nla_nest_start(skb, j);
+			if (!nla)
+				goto nla_put_failure;
+
+			ret = cp->rtnl_link_ops->fill_link_af(skb, dev);
+			/*
+			 * Caller may return ENODATA to indicate that there
+			 * was no data to be dumped. This is not an error, it
+			 * means we should trim the attribute header and
+			 * continue.
+			 */
+			if (ret == -ENODATA)
+				nla_nest_cancel(skb, nla);
+			else if (ret < 0)
+				goto nla_put_failure;
+			nla_nest_end(skb, nla);
+			++n;
+		}
+		can_put_proto(cp);
+	}
+	return n ? 0 : -ENODATA;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nla);
+	can_put_proto(cp);
+	return -EMSGSIZE;
+}
+
+static int can_validate_link_af(const struct net_device *dev,
+				 const struct nlattr *nla)
+{
+	int ret, rem;
+	const struct can_proto *cp;
+	struct nlattr *prot;
+
+	if (!net_eq(dev_net(dev), &init_net) || (dev->type != ARPHRD_CAN))
+		return -EPROTONOSUPPORT;
+
+	nla_for_each_nested(prot, nla, rem) {
+		cp = can_try_module_get(nla_type(prot));
+		if (IS_ERR(cp))
+			return PTR_ERR(cp);
+		if (!cp->rtnl_link_ops)
+			ret = -EPROTONOSUPPORT;
+		else if (!cp->rtnl_link_ops->validate_link_af)
+			ret = 0;
+		else
+			ret = cp->rtnl_link_ops->validate_link_af(dev, prot);
+		can_put_proto(cp);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
+static int can_set_link_af(struct net_device *dev, const struct nlattr *nla)
+{
+	int ret, rem;
+	const struct can_proto *cp;
+	struct nlattr *prot;
+
+	if (!net_eq(dev_net(dev), &init_net) || (dev->type != ARPHRD_CAN))
+		return -EPROTONOSUPPORT;
+
+	nla_for_each_nested(prot, nla, rem) {
+		cp = can_try_module_get(nla_type(prot));
+		if (IS_ERR(cp))
+			return PTR_ERR(cp);
+		if (!cp->rtnl_link_ops || !cp->rtnl_link_ops->set_link_af)
+			ret = -EPROTONOSUPPORT;
+		else
+			ret = cp->rtnl_link_ops->set_link_af(dev, prot);
+		can_put_proto(cp);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
+static struct rtnl_af_ops can_rtnl_af_ops = {
+	.family		  = AF_CAN,
+	.fill_link_af	  = can_fill_link_af,
+	.get_link_af_size = can_get_link_af_size,
+	.validate_link_af = can_validate_link_af,
+	.set_link_af	  = can_set_link_af,
+};
+
+/* exported init */
+
 static __init int can_init(void)
 {
 	printk(banner);
@@ -843,6 +1047,11 @@ static __init int can_init(void)
 	register_netdevice_notifier(&can_netdev_notifier);
 	dev_add_pack(&can_packet);
 
+	rtnl_af_register(&can_rtnl_af_ops);
+	rtnl_register(PF_CAN, RTM_NEWADDR, can_rtnl_doit, NULL);
+	rtnl_register(PF_CAN, RTM_DELADDR, can_rtnl_doit, NULL);
+	rtnl_register(PF_CAN, RTM_GETADDR, NULL, can_rtnl_dump_addr);
+
 	return 0;
 }
 
@@ -853,6 +1062,11 @@ static __exit void can_exit(void)
 	if (stats_timer)
 		del_timer(&can_stattimer);
 
+	rtnl_unregister(PF_CAN, RTM_NEWADDR);
+	rtnl_unregister(PF_CAN, RTM_DELADDR);
+	rtnl_unregister(PF_CAN, RTM_GETADDR);
+	rtnl_af_unregister(&can_rtnl_af_ops);
+
 	can_remove_proc();
 
 	/* protocol unregister */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 3dc4d4e..4f65f4f 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1601,7 +1601,7 @@ static struct proto bcm_proto __read_mostly = {
 	.init       = bcm_init,
 };
 
-static struct can_proto bcm_can_proto __read_mostly = {
+static const struct can_proto bcm_can_proto = {
 	.type       = SOCK_DGRAM,
 	.protocol   = CAN_BCM,
 	.ops        = &bcm_ops,
diff --git a/net/can/raw.c b/net/can/raw.c
index 6009d5e..60d4282 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -774,7 +774,7 @@ static struct proto raw_proto __read_mostly = {
 	.init       = raw_init,
 };
 
-static struct can_proto raw_can_proto __read_mostly = {
+static const struct can_proto raw_can_proto = {
 	.type       = SOCK_RAW,
 	.protocol   = CAN_RAW,
 	.ops        = &raw_ops,
-- 
1.7.2.5
