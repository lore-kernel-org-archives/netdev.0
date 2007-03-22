From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 01/12] [RTNL]: Message handler registration interface
Date: Thu, 22 Mar 2007 13:59:56 +0100
Message-ID: <20070322130057.311937957@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53628 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbXCVNBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:01:30 -0400
Content-Disposition: inline; filename=rtnl_reg_api
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new interface to register rtnetlink message
handlers replacing the exported rtnl_links[] array which
required many message handlers to be exported unnecessarly.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/rtnetlink.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6.22/include/net/rtnetlink.h	2007-03-22 12:48:20.000000000 +0100
@@ -0,0 +1,18 @@
+#ifndef __NET_RTNETLINK_H
+#define __NET_RTNETLINK_H
+
+#include <linux/rtnetlink.h>
+#include <net/netlink.h>
+
+typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *, void *);
+typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
+
+extern int	__rtnl_register(int protocol, int msgtype,
+				rtnl_doit_func, rtnl_dumpit_func);
+extern void	rtnl_register(int protocol, int msgtype,
+			      rtnl_doit_func, rtnl_dumpit_func);
+extern int	rtnl_unregister(int protocol, int msgtype);
+extern void	rtnl_unregister_all(int protocol);
+extern int	rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb);
+
+#endif
Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-22 12:48:20.000000000 +0100
@@ -50,12 +50,18 @@
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <net/fib_rules.h>
-#include <net/netlink.h>
+#include <net/rtnetlink.h>
 #ifdef CONFIG_NET_WIRELESS_RTNETLINK
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
+struct rtnl_link
+{
+	rtnl_doit_func		doit;
+	rtnl_dumpit_func	dumpit;
+};
+
 static DEFINE_MUTEX(rtnl_mutex);
 static struct sock *rtnl;
 
@@ -95,7 +101,151 @@ int rtattr_parse(struct rtattr *tb[], in
 	return 0;
 }
 
-struct rtnetlink_link * rtnetlink_links[NPROTO];
+struct rtnl_link *rtnl_msg_handlers[NPROTO];
+
+static inline int rtm_msgindex(int msgtype)
+{
+	int msgindex = msgtype - RTM_BASE;
+
+	/*
+	 * msgindex < 0 implies someone tried to register a netlink
+	 * control code. msgindex >= RTM_NR_MSGTYPES may indicate that
+	 * the message type has not been added to linux/rtnetlink.h
+	 */
+	BUG_ON(msgindex < 0 || msgindex >= RTM_NR_MSGTYPES);
+
+	return msgindex;
+}
+
+static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex)
+{
+	struct rtnl_link *tab;
+
+	tab = rtnl_msg_handlers[protocol];
+	if (tab == NULL || tab->doit == NULL)
+		tab = rtnl_msg_handlers[PF_UNSPEC];
+
+	return tab ? tab->doit : NULL;
+}
+
+static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
+{
+	struct rtnl_link *tab;
+
+	tab = rtnl_msg_handlers[protocol];
+	if (tab == NULL || tab->dumpit == NULL)
+		tab = rtnl_msg_handlers[PF_UNSPEC];
+
+	return tab ? tab->dumpit : NULL;
+}
+
+/**
+ * __rtnl_register - Register a rtnetlink message type
+ * @protocol: Protocol family or PF_UNSPEC
+ * @msgtype: rtnetlink message type
+ * @doit: Function pointer called for each request message
+ * @dumpit: Function pointer called for each dump request (NLM_F_DUMP) message
+ *
+ * Registers the specified function pointers (at least one of them has
+ * to be non-NULL) to be called whenever a request message for the
+ * specified protocol family and message type is received.
+ *
+ * The special protocol family PF_UNSPEC may be used to define fallback
+ * function pointers for the case when no entry for the specific protocol
+ * family exists.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int __rtnl_register(int protocol, int msgtype,
+		    rtnl_doit_func doit, rtnl_dumpit_func dumpit)
+{
+	struct rtnl_link *tab;
+	int msgindex;
+
+	BUG_ON(protocol < 0 || protocol >= NPROTO);
+	msgindex = rtm_msgindex(msgtype);
+
+	tab = rtnl_msg_handlers[protocol];
+	if (tab == NULL) {
+		tab = kcalloc(RTM_NR_MSGTYPES, sizeof(*tab), GFP_KERNEL);
+		if (tab == NULL)
+			return -ENOBUFS;
+
+		rtnl_msg_handlers[protocol] = tab;
+	}
+
+	if (doit)
+		tab[msgindex].doit = doit;
+
+	if (dumpit)
+		tab[msgindex].dumpit = dumpit;
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(__rtnl_register);
+
+/**
+ * rtnl_register - Register a rtnetlink message type
+ *
+ * Identical to __rtnl_register() but panics on failure. This is useful
+ * as failure of this function is very unlikely, it can only happen due
+ * to lack of memory when allocating the chain to store all message
+ * handlers for a protocol. Meant for use in init functions where lack
+ * of memory implies no sense in continueing.
+ */
+void rtnl_register(int protocol, int msgtype,
+		   rtnl_doit_func doit, rtnl_dumpit_func dumpit)
+{
+	if (__rtnl_register(protocol, msgtype, doit, dumpit) < 0)
+		panic("Unable to register rtnetlink message handler, "
+		      "protocol = %d, message type = %d\n",
+		      protocol, msgtype);
+}
+
+EXPORT_SYMBOL_GPL(rtnl_register);
+
+/**
+ * rtnl_unregister - Unregister a rtnetlink message type
+ * @protocol: Protocol family or PF_UNSPEC
+ * @msgtype: rtnetlink message type
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int rtnl_unregister(int protocol, int msgtype)
+{
+	int msgindex;
+
+	BUG_ON(protocol < 0 || protocol >= NPROTO);
+	msgindex = rtm_msgindex(msgtype);
+
+	if (rtnl_msg_handlers[protocol] == NULL)
+		return -ENOENT;
+
+	rtnl_msg_handlers[protocol][msgindex].doit = NULL;
+	rtnl_msg_handlers[protocol][msgindex].dumpit = NULL;
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(rtnl_unregister);
+
+/**
+ * rtnl_unregister_all - Unregister all rtnetlink message type of a protocol
+ * @protocol : Protocol family or PF_UNSPEC
+ *
+ * Identical to calling rtnl_unregster() for all registered message types
+ * of a certain protocol family.
+ */
+void rtnl_unregister_all(int protocol)
+{
+	BUG_ON(protocol < 0 || protocol >= NPROTO);
+
+	kfree(rtnl_msg_handlers[protocol]);
+	rtnl_msg_handlers[protocol] = NULL;
+}
+
+EXPORT_SYMBOL_GPL(rtnl_unregister_all);
 
 static const int rtm_min[RTM_NR_FAMILIES] =
 {
@@ -647,7 +797,7 @@ errout:
 	return err;
 }
 
-static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
+int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->family;
@@ -658,12 +808,12 @@ static int rtnl_dump_all(struct sk_buff 
 		int type = cb->nlh->nlmsg_type-RTM_BASE;
 		if (idx < s_idx || idx == PF_PACKET)
 			continue;
-		if (rtnetlink_links[idx] == NULL ||
-		    rtnetlink_links[idx][type].dumpit == NULL)
+		if (rtnl_msg_handlers[idx] == NULL ||
+		    rtnl_msg_handlers[idx][type].dumpit == NULL)
 			continue;
 		if (idx > s_idx)
 			memset(&cb->args[0], 0, sizeof(cb->args));
-		if (rtnetlink_links[idx][type].dumpit(skb, cb))
+		if (rtnl_msg_handlers[idx][type].dumpit(skb, cb))
 			break;
 	}
 	cb->family = idx;
@@ -671,6 +821,8 @@ static int rtnl_dump_all(struct sk_buff 
 	return skb->len;
 }
 
+EXPORT_SYMBOL_GPL(rtnl_dump_all);
+
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 {
 	struct sk_buff *skb;
@@ -702,8 +854,7 @@ static int rtattr_max;
 static __inline__ int
 rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)
 {
-	struct rtnetlink_link *link;
-	struct rtnetlink_link *link_tab;
+	rtnl_doit_func doit;
 	int sz_idx, kind;
 	int min_len;
 	int family;
@@ -736,11 +887,6 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 		return -1;
 	}
 
-	link_tab = rtnetlink_links[family];
-	if (link_tab == NULL)
-		link_tab = rtnetlink_links[PF_UNSPEC];
-	link = &link_tab[type];
-
 	sz_idx = type>>2;
 	kind = type&3;
 
@@ -750,14 +896,14 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 	}
 
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
-		if (link->dumpit == NULL)
-			link = &(rtnetlink_links[PF_UNSPEC][type]);
+		rtnl_dumpit_func dumpit;
 
-		if (link->dumpit == NULL)
+		dumpit = rtnl_get_dumpit(family, type);
+		if (dumpit == NULL)
 			goto err_inval;
 
 		if ((*errp = netlink_dump_start(rtnl, skb, nlh,
-						link->dumpit, NULL)) != 0) {
+						dumpit, NULL)) != 0) {
 			return -1;
 		}
 
@@ -786,11 +932,10 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 		}
 	}
 
-	if (link->doit == NULL)
-		link = &(rtnetlink_links[PF_UNSPEC][type]);
-	if (link->doit == NULL)
+	doit = rtnl_get_doit(family, type);
+	if (doit == NULL)
 		goto err_inval;
-	err = link->doit(skb, nlh, (void *)&rta_buf[0]);
+	err = doit(skb, nlh, (void *)&rta_buf[0]);
 
 	*errp = err;
 	return err;
@@ -885,7 +1030,6 @@ void __init rtnetlink_init(void)
 EXPORT_SYMBOL(__rta_fill);
 EXPORT_SYMBOL(rtattr_strlcpy);
 EXPORT_SYMBOL(rtattr_parse);
-EXPORT_SYMBOL(rtnetlink_links);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);
Index: net-2.6.22/include/linux/rtnetlink.h
===================================================================
--- net-2.6.22.orig/include/linux/rtnetlink.h	2007-03-22 12:48:05.000000000 +0100
+++ net-2.6.22/include/linux/rtnetlink.h	2007-03-22 12:48:20.000000000 +0100
@@ -574,13 +574,6 @@ extern int rtattr_parse(struct rtattr *t
 #define rtattr_parse_nested(tb, max, rta) \
 	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
 
-struct rtnetlink_link
-{
-	int (*doit)(struct sk_buff *, struct nlmsghdr*, void *attr);
-	int (*dumpit)(struct sk_buff *, struct netlink_callback *cb);
-};
-
-extern struct rtnetlink_link * rtnetlink_links[NPROTO];
 extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
 extern int rtnl_notify(struct sk_buff *skb, u32 pid, u32 group,

--

