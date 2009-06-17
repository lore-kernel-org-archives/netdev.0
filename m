From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 21:33:38 +0200
Message-ID: <1245267218.31588.41.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59500 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502AbZFQTeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 15:34:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes generic netlink network namespace aware.
No actual generic netlink families are made namespace
aware, they need to be checked one by one and then
set the family->netnsok member to true.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
I created this patch against wireless-testing and added the one hunk
that was necessary against net-next (ieee80215 stack) to the end of the
patch manually. As a result, there's one hunk in here that cannot apply
against net-next currently because it's not in there yet. I can also
send a patch w/o that hunk, if preferred.

 drivers/acpi/event.c           |    2 
 fs/dlm/netlink.c               |    2 
 fs/quota/dquot.c               |    2 
 include/net/genetlink.h        |   20 +++--
 include/net/net_namespace.h    |    2 
 kernel/taskstats.c             |    4 -
 net/core/drop_monitor.c        |    2 
 net/irda/irnetlink.c           |    2 
 net/netfilter/ipvs/ip_vs_ctl.c |    2 
 net/netlink/genetlink.c        |  143 ++++++++++++++++++++++++++++++-----------
 net/tipc/netlink.c             |    2 
 net/wimax/op-msg.c             |    2 
 net/wimax/stack.c              |    2 
 net/wireless/nl80211.c         |   34 ++++-----
 net/ieee802154/netlink.c       |    3 +--
 15 files changed, 151 insertions(+), 73 deletions(-)

--- wireless-testing.orig/include/net/genetlink.h	2009-06-17 20:36:46.000000000 +0200
+++ wireless-testing/include/net/genetlink.h	2009-06-17 21:04:04.000000000 +0200
@@ -3,6 +3,7 @@
 
 #include <linux/genetlink.h>
 #include <net/netlink.h>
+#include <net/net_namespace.h>
 
 /**
  * struct genl_multicast_group - generic netlink multicast group
@@ -27,6 +28,8 @@ struct genl_multicast_group
  * @name: name of family
  * @version: protocol version
  * @maxattr: maximum number of attributes supported
+ * @netnsok: set to true if the family can handle network
+ *	namespaces and should be presented in all of them
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
@@ -39,6 +42,7 @@ struct genl_family
 	char			name[GENL_NAMSIZ];
 	unsigned int		version;
 	unsigned int		maxattr;
+	bool			netnsok;
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
@@ -62,6 +66,7 @@ struct genl_info
 	struct genlmsghdr *	genlhdr;
 	void *			userhdr;
 	struct nlattr **	attrs;
+	struct net *		net;
 };
 
 /**
@@ -96,8 +101,6 @@ extern int genl_register_mc_group(struct
 extern void genl_unregister_mc_group(struct genl_family *family,
 				     struct genl_multicast_group *grp);
 
-extern struct sock *genl_sock;
-
 /**
  * genlmsg_put - Add generic netlink header to netlink message
  * @skb: socket buffer holding the message
@@ -174,10 +177,11 @@ static inline void genlmsg_cancel(struct
  * @group: multicast group id
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast(struct sk_buff *skb, u32 pid,
-				    unsigned int group, gfp_t flags)
+static inline int genlmsg_multicast(struct net *net, struct sk_buff *skb,
+				    u32 pid, unsigned int group,
+				    gfp_t flags)
 {
-	return nlmsg_multicast(genl_sock, skb, pid, group, flags);
+	return nlmsg_multicast(net->genl_sock, skb, pid, group, flags);
 }
 
 /**
@@ -185,9 +189,9 @@ static inline int genlmsg_multicast(stru
  * @skb: netlink message as socket buffer
  * @pid: netlink pid of the destination socket
  */
-static inline int genlmsg_unicast(struct sk_buff *skb, u32 pid)
+static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 pid)
 {
-	return nlmsg_unicast(genl_sock, skb, pid);
+	return nlmsg_unicast(net->genl_sock, skb, pid);
 }
 
 /**
@@ -197,7 +201,7 @@ static inline int genlmsg_unicast(struct
  */
 static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info)
 {
-	return genlmsg_unicast(skb, info->snd_pid);
+	return genlmsg_unicast(info->net, skb, info->snd_pid);
 }
 
 /**
--- wireless-testing.orig/include/net/net_namespace.h	2009-06-17 20:36:59.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-06-17 21:05:52.000000000 +0200
@@ -26,6 +26,7 @@ struct net_device;
 struct sock;
 struct ctl_table_header;
 struct net_generic;
+struct sock;
 
 struct net {
 	atomic_t		count;		/* To decided when the network
@@ -63,6 +64,7 @@ struct net {
 	struct netns_packet	packet;
 	struct netns_unix	unx;
 	struct netns_ipv4	ipv4;
+	struct sock		*genl_sock;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct netns_ipv6	ipv6;
 #endif
--- wireless-testing.orig/net/netlink/genetlink.c	2009-06-17 20:36:51.000000000 +0200
+++ wireless-testing/net/netlink/genetlink.c	2009-06-17 21:21:55.000000000 +0200
@@ -18,8 +18,6 @@
 #include <net/sock.h>
 #include <net/genetlink.h>
 
-struct sock *genl_sock = NULL;
-
 static DEFINE_MUTEX(genl_mutex); /* serialization of message processing */
 
 static inline void genl_lock(void)
@@ -175,10 +173,28 @@ int genl_register_mc_group(struct genl_f
 		mc_groups_longs++;
 	}
 
-	err = netlink_change_ngroups(genl_sock,
-				     mc_groups_longs * BITS_PER_LONG);
-	if (err)
-		goto out;
+	if (family->netnsok) {
+		struct net *net;
+
+		for_each_net(net) {
+			err = netlink_change_ngroups(net->genl_sock,
+					mc_groups_longs * BITS_PER_LONG);
+			if (err) {
+				/*
+				 * No need to roll back can only fail
+				 * if memory allocation fails and then
+				 * the number of groups is larger for
+				 * some sockets which is ok.
+				 */
+				goto out;
+			}
+		}
+	} else {
+		err = netlink_change_ngroups(init_net.genl_sock,
+					     mc_groups_longs * BITS_PER_LONG);
+		if (err)
+			goto out;
+	}
 
 	grp->id = id;
 	set_bit(id, mc_groups);
@@ -195,8 +211,12 @@ EXPORT_SYMBOL(genl_register_mc_group);
 static void __genl_unregister_mc_group(struct genl_family *family,
 				       struct genl_multicast_group *grp)
 {
+	struct net *net;
 	BUG_ON(grp->family != family);
-	netlink_clear_multicast_users(genl_sock, grp->id);
+
+	for_each_net(net)
+		netlink_clear_multicast_users(net->genl_sock, grp->id);
+
 	clear_bit(grp->id, mc_groups);
 	list_del(&grp->list);
 	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
@@ -421,6 +441,7 @@ static int genl_rcv_msg(struct sk_buff *
 {
 	struct genl_ops *ops;
 	struct genl_family *family;
+	struct net *net = sock_net(skb->sk);
 	struct genl_info info;
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
 	int hdrlen, err;
@@ -429,6 +450,10 @@ static int genl_rcv_msg(struct sk_buff *
 	if (family == NULL)
 		return -ENOENT;
 
+	/* this family doesn't exist in this netns */
+	if (!family->netnsok && net != &init_net)
+		return -ENOENT;
+
 	hdrlen = GENL_HDRLEN + family->hdrsize;
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		return -EINVAL;
@@ -446,7 +471,7 @@ static int genl_rcv_msg(struct sk_buff *
 			return -EOPNOTSUPP;
 
 		genl_unlock();
-		err = netlink_dump_start(genl_sock, skb, nlh,
+		err = netlink_dump_start(net->genl_sock, skb, nlh,
 					 ops->dumpit, ops->done);
 		genl_lock();
 		return err;
@@ -468,6 +493,7 @@ static int genl_rcv_msg(struct sk_buff *
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
+	info.net = net;
 
 	return ops->doit(skb, &info);
 }
@@ -488,6 +514,7 @@ static struct genl_family genl_ctrl = {
 	.name = "nlctrl",
 	.version = 0x2,
 	.maxattr = CTRL_ATTR_MAX,
+	.netnsok = true,
 };
 
 static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
@@ -604,6 +631,7 @@ static int ctrl_dumpfamily(struct sk_buf
 
 	int i, n = 0;
 	struct genl_family *rt;
+	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
@@ -612,6 +640,8 @@ static int ctrl_dumpfamily(struct sk_buf
 			continue;
 		n = 0;
 		list_for_each_entry(rt, genl_family_chain(i), family_list) {
+			if (!rt->netnsok && net != &init_net)
+				continue;
 			if (++n < fams_to_skip)
 				continue;
 			if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).pid,
@@ -683,6 +713,7 @@ static int ctrl_getfamily(struct sk_buff
 	if (info->attrs[CTRL_ATTR_FAMILY_ID]) {
 		u16 id = nla_get_u16(info->attrs[CTRL_ATTR_FAMILY_ID]);
 		res = genl_family_find_byid(id);
+		err = -ENOENT;
 	}
 
 	if (info->attrs[CTRL_ATTR_FAMILY_NAME]) {
@@ -690,49 +721,67 @@ static int ctrl_getfamily(struct sk_buff
 
 		name = nla_data(info->attrs[CTRL_ATTR_FAMILY_NAME]);
 		res = genl_family_find_byname(name);
+		err = -ENOENT;
 	}
 
-	if (res == NULL) {
-		err = -ENOENT;
-		goto errout;
+	if (res == NULL)
+		return err;
+
+	if (!res->netnsok && info->net != &init_net) {
+		/* family doesn't exist here */
+		return -ENOENT;
 	}
 
 	msg = ctrl_build_family_msg(res, info->snd_pid, info->snd_seq,
 				    CTRL_CMD_NEWFAMILY);
-	if (IS_ERR(msg)) {
-		err = PTR_ERR(msg);
-		goto errout;
-	}
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
 
-	err = genlmsg_reply(msg, info);
-errout:
-	return err;
+	return genlmsg_reply(msg, info);
 }
 
 static int genl_ctrl_event(int event, void *data)
 {
-	struct sk_buff *msg;
+	struct net *net;
+	struct sk_buff *msg, *skb;
+	struct genl_family *family;
+	struct genl_multicast_group *grp;
 
-	if (genl_sock == NULL)
+	/* genl is still initialising */
+	if (!init_net.genl_sock)
 		return 0;
 
 	switch (event) {
 	case CTRL_CMD_NEWFAMILY:
 	case CTRL_CMD_DELFAMILY:
-		msg = ctrl_build_family_msg(data, 0, 0, event);
-		if (IS_ERR(msg))
-			return PTR_ERR(msg);
-
-		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
+		family = data;
+		msg = ctrl_build_family_msg(family, 0, 0, event);
 		break;
 	case CTRL_CMD_NEWMCAST_GRP:
 	case CTRL_CMD_DELMCAST_GRP:
+		grp = data;
+		family = grp->family;
 		msg = ctrl_build_mcgrp_msg(data, 0, 0, event);
-		if (IS_ERR(msg))
-			return PTR_ERR(msg);
-
-		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
 		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	if (!family->netnsok)
+		genlmsg_multicast(&init_net, msg, 0,
+				  GENL_ID_CTRL, GFP_KERNEL);
+	else {
+		for_each_net(net) {
+			skb = skb_clone(msg, GFP_KERNEL);
+			if (!skb)
+				continue;
+			genlmsg_multicast(net, skb, 0, GENL_ID_CTRL,
+					  GFP_KERNEL);
+		}
+		kfree_skb(msg);
 	}
 
 	return 0;
@@ -749,6 +798,33 @@ static struct genl_multicast_group notif
 	.name		= "notify",
 };
 
+static int __net_init genl_pernet_init(struct net *net)
+{
+	/* we'll bump the group number right afterwards */
+	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC, 0,
+					       genl_rcv, &genl_mutex,
+					       THIS_MODULE);
+
+	if (!net->genl_sock && net == &init_net)
+		panic("GENL: Cannot initialize generic netlink\n");
+
+	if (!net->genl_sock)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __net_exit genl_pernet_exit(struct net *net)
+{
+	netlink_kernel_release(net->genl_sock);
+	net->genl_sock = NULL;
+}
+
+static struct pernet_operations genl_pernet_ops = {
+	.init = genl_pernet_init,
+	.exit = genl_pernet_exit,
+};
+
 static int __init genl_init(void)
 {
 	int i, err;
@@ -766,11 +842,9 @@ static int __init genl_init(void)
 
 	netlink_set_nonroot(NETLINK_GENERIC, NL_NONROOT_RECV);
 
-	/* we'll bump the group number right afterwards */
-	genl_sock = netlink_kernel_create(&init_net, NETLINK_GENERIC, 0,
-					  genl_rcv, &genl_mutex, THIS_MODULE);
-	if (genl_sock == NULL)
-		panic("GENL: Cannot initialize generic netlink\n");
+	err = register_pernet_subsys(&genl_pernet_ops);
+	if (err)
+		goto errout_register;
 
 	err = genl_register_mc_group(&genl_ctrl, &notify_grp);
 	if (err < 0)
@@ -786,7 +860,6 @@ errout:
 
 subsys_initcall(genl_init);
 
-EXPORT_SYMBOL(genl_sock);
 EXPORT_SYMBOL(genl_register_ops);
 EXPORT_SYMBOL(genl_unregister_ops);
 EXPORT_SYMBOL(genl_register_family);
--- wireless-testing.orig/drivers/acpi/event.c	2009-04-09 10:00:06.000000000 +0200
+++ wireless-testing/drivers/acpi/event.c	2009-06-17 21:02:28.000000000 +0200
@@ -235,7 +235,7 @@ int acpi_bus_generate_netlink_event(cons
 		return result;
 	}
 
-	genlmsg_multicast(skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&init_net, skb, 0, acpi_event_mcgrp.id, GFP_ATOMIC);
 	return 0;
 }
 
--- wireless-testing.orig/fs/dlm/netlink.c	2009-01-13 15:05:18.000000000 +0100
+++ wireless-testing/fs/dlm/netlink.c	2009-06-17 21:02:28.000000000 +0200
@@ -63,7 +63,7 @@ static int send_data(struct sk_buff *skb
 		return rv;
 	}
 
-	return genlmsg_unicast(skb, listener_nlpid);
+	return genlmsg_unicast(&init_net, skb, listener_nlpid);
 }
 
 static int user_cmd(struct sk_buff *skb, struct genl_info *info)
--- wireless-testing.orig/fs/quota/dquot.c	2009-04-09 10:00:33.000000000 +0200
+++ wireless-testing/fs/quota/dquot.c	2009-06-17 21:02:28.000000000 +0200
@@ -1130,7 +1130,7 @@ static void send_warning(const struct dq
 		goto attr_err_out;
 	genlmsg_end(skb, msg_head);
 
-	genlmsg_multicast(skb, 0, quota_genl_family.id, GFP_NOFS);
+	genlmsg_multicast(&init_net, skb, 0, quota_genl_family.id, GFP_NOFS);
 	return;
 attr_err_out:
 	printk(KERN_ERR "VFS: Not enough space to compose quota message!\n");
--- wireless-testing.orig/kernel/taskstats.c	2009-01-13 15:05:23.000000000 +0100
+++ wireless-testing/kernel/taskstats.c	2009-06-17 21:02:28.000000000 +0200
@@ -120,7 +120,7 @@ static int send_reply(struct sk_buff *sk
 		return rc;
 	}
 
-	return genlmsg_unicast(skb, pid);
+	return genlmsg_unicast(&init_net, skb, pid);
 }
 
 /*
@@ -150,7 +150,7 @@ static void send_cpu_listeners(struct sk
 			if (!skb_next)
 				break;
 		}
-		rc = genlmsg_unicast(skb_cur, s->pid);
+		rc = genlmsg_unicast(&init_net, skb_cur, s->pid);
 		if (rc == -ECONNREFUSED) {
 			s->valid = 0;
 			delcount++;
--- wireless-testing.orig/net/core/drop_monitor.c	2009-04-09 10:00:38.000000000 +0200
+++ wireless-testing/net/core/drop_monitor.c	2009-06-17 21:02:28.000000000 +0200
@@ -94,7 +94,7 @@ static void send_dm_alert(struct work_st
 	/*
 	 * Ship it!
 	 */
-	genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
+	genlmsg_multicast(&init_net, skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
 
 }
 
--- wireless-testing.orig/net/irda/irnetlink.c	2008-12-19 00:28:09.000000000 +0100
+++ wireless-testing/net/irda/irnetlink.c	2009-06-17 21:02:28.000000000 +0200
@@ -115,7 +115,7 @@ static int irda_nl_get_mode(struct sk_bu
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(msg, info->snd_pid);
+	return genlmsg_unicast(&init_net, msg, info->snd_pid);
 
  err_out:
 	nlmsg_free(msg);
--- wireless-testing.orig/net/netfilter/ipvs/ip_vs_ctl.c	2009-01-13 15:05:25.000000000 +0100
+++ wireless-testing/net/netfilter/ipvs/ip_vs_ctl.c	2009-06-17 21:02:28.000000000 +0200
@@ -3231,7 +3231,7 @@ static int ip_vs_genl_get_cmd(struct sk_
 	}
 
 	genlmsg_end(msg, reply);
-	ret = genlmsg_unicast(msg, info->snd_pid);
+	ret = genlmsg_unicast(&init_net, msg, info->snd_pid);
 	goto out;
 
 nla_put_failure:
--- wireless-testing.orig/net/tipc/netlink.c	2008-12-19 00:28:09.000000000 +0100
+++ wireless-testing/net/tipc/netlink.c	2009-06-17 21:02:28.000000000 +0200
@@ -62,7 +62,7 @@ static int handle_cmd(struct sk_buff *sk
 		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);
+		genlmsg_unicast(&init_net, rep_buf, NETLINK_CB(skb).pid);
 	}
 
 	return 0;
--- wireless-testing.orig/net/wimax/op-msg.c	2009-05-18 12:02:06.000000000 +0200
+++ wireless-testing/net/wimax/op-msg.c	2009-06-17 21:02:28.000000000 +0200
@@ -266,7 +266,7 @@ int wimax_msg_send(struct wimax_dev *wim
 
 	d_printf(1, dev, "CTX: wimax msg, %zu bytes\n", size);
 	d_dump(2, dev, msg, size);
-	genlmsg_multicast(skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
 	d_printf(1, dev, "CTX: genl multicast done\n");
 	return 0;
 }
--- wireless-testing.orig/net/wimax/stack.c	2009-05-18 12:02:06.000000000 +0200
+++ wireless-testing/net/wimax/stack.c	2009-06-17 21:02:28.000000000 +0200
@@ -168,7 +168,7 @@ int wimax_gnl_re_state_change_send(
 		goto out;
 	}
 	genlmsg_end(report_skb, header);
-	genlmsg_multicast(report_skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, report_skb, 0, wimax_gnl_mcg.id, GFP_KERNEL);
 out:
 	d_fnend(3, dev, "(wimax_dev %p report_skb %p) = %d\n",
 		wimax_dev, report_skb, result);
--- wireless-testing.orig/net/wireless/nl80211.c	2009-06-17 20:25:59.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2009-06-17 21:10:32.000000000 +0200
@@ -398,7 +398,7 @@ static int nl80211_get_wiphy(struct sk_b
 
 	cfg80211_put_dev(dev);
 
-	return genlmsg_unicast(msg, info->snd_pid);
+	return genlmsg_unicast(&init_net, msg, info->snd_pid);
 
  out_free:
 	nlmsg_free(msg);
@@ -723,7 +723,7 @@ static int nl80211_get_interface(struct 
 	dev_put(netdev);
 	cfg80211_put_dev(dev);
 
-	return genlmsg_unicast(msg, info->snd_pid);
+	return genlmsg_unicast(&init_net, msg, info->snd_pid);
 
  out_free:
 	nlmsg_free(msg);
@@ -1014,7 +1014,7 @@ static int nl80211_get_key(struct sk_buf
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_unicast(&init_net, msg, info->snd_pid);
 	goto out;
 
  nla_put_failure:
@@ -1602,7 +1602,7 @@ static int nl80211_get_station(struct sk
 				 dev, mac_addr, &sinfo) < 0)
 		goto out_free;
 
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_unicast(&init_net, msg, info->snd_pid);
 	goto out;
 
  out_free:
@@ -2006,7 +2006,7 @@ static int nl80211_get_mpath(struct sk_b
 				 dev, dst, next_hop, &pinfo) < 0)
 		goto out_free;
 
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_unicast(&init_net, msg, info->snd_pid);
 	goto out;
 
  out_free:
@@ -2355,7 +2355,7 @@ static int nl80211_get_mesh_params(struc
 			cur_params.dot11MeshHWMPnetDiameterTraversalTime);
 	nla_nest_end(msg, pinfoattr);
 	genlmsg_end(msg, hdr);
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_unicast(&init_net, msg, info->snd_pid);
 	goto out;
 
  nla_put_failure:
@@ -2543,7 +2543,7 @@ static int nl80211_get_reg(struct sk_buf
 	nla_nest_end(msg, nl_reg_rules);
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_unicast(&init_net, msg, info->snd_pid);
 	goto out;
 
 nla_put_failure:
@@ -3594,7 +3594,7 @@ void nl80211_notify_dev_rename(struct cf
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_config_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_config_mcgrp.id, GFP_KERNEL);
 }
 
 static int nl80211_add_scan_req(struct sk_buff *msg,
@@ -3669,7 +3669,7 @@ void nl80211_send_scan_start(struct cfg8
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
 void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
@@ -3687,7 +3687,7 @@ void nl80211_send_scan_done(struct cfg80
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
 void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
@@ -3705,7 +3705,7 @@ void nl80211_send_scan_aborted(struct cf
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_scan_mcgrp.id, GFP_KERNEL);
 }
 
 /*
@@ -3754,7 +3754,7 @@ void nl80211_send_reg_change_event(struc
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_regulatory_mcgrp.id, GFP_KERNEL);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_regulatory_mcgrp.id, GFP_KERNEL);
 
 	return;
 
@@ -3790,7 +3790,7 @@ static void nl80211_send_mlme_event(stru
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
@@ -3854,7 +3854,7 @@ static void nl80211_send_mlme_timeout(st
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
@@ -3901,7 +3901,7 @@ void nl80211_send_ibss_bssid(struct cfg8
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, gfp);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_mlme_mcgrp.id, gfp);
 	return;
 
  nla_put_failure:
@@ -3941,7 +3941,7 @@ void nl80211_michael_mic_failure(struct 
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_mlme_mcgrp.id, GFP_ATOMIC);
 	return;
 
  nla_put_failure:
@@ -3994,7 +3994,7 @@ void nl80211_send_beacon_hint_event(stru
 		return;
 	}
 
-	genlmsg_multicast(msg, 0, nl80211_regulatory_mcgrp.id, GFP_ATOMIC);
+	genlmsg_multicast(&init_net, msg, 0, nl80211_regulatory_mcgrp.id, GFP_ATOMIC);
 
 	return;
 
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -76,8 +76,7 @@ static int ieee802154_nl_finish(struct sk_buff *msg)
 	if (!genlmsg_end(msg, hdr))
 		goto out;
 
-	return genlmsg_multicast(msg, 0, ieee802154_coord_mcgrp.id,
-			GFP_ATOMIC);
+	return genlmsg_multicast(&init_net, msg, 0, ieee802154_coord_mcgrp.id, GFP_ATOMIC);
 out:
 	nlmsg_free(msg);
 	return -ENOBUFS;


