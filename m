From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] genetlink: make netns aware
Date: Thu, 18 Jun 2009 13:16:46 +0200
Message-ID: <1245323806.13790.1.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43792 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbZFRLRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 07:17:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes generic netlink network namespace aware. No
generic netlink families except for the controller family
are made namespace aware, they need to be checked one by
one and then set the family->netnsok member to true.

The function genlmsg_multicast() is changed to multicast
the message in all namespaces, this is correct for all
generic netlink families that do not care about the net
namespace at all -- which will probably be a significant
amount but they still need to be fixed up.

A new function genlmsg_multicast_netns() is introduced to
allow sending a multicast message in a given namespace,
for example when it applies to an object that lives in
that namespace.

The current state is that generic netlink is available
only in init_net, where after this patch families can
easily decide whether or not they should be available in
all net namespaces or not. Many families that use genl
for something unrelated to networking should probably be
available in all network namespaces, hence the multicast
behaviour mentioned above.

Note that this doesn't touch on the checkpoint/restart
problem where network namespaces could be used, genl
families and multicast groups are numbered globally and
I see no easy way of changing that, especially since it
must be possible to multicast to all network namespaces
for those families that do not care about netns.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 fs/dlm/netlink.c               |    2 
 include/net/genetlink.h        |   32 ++++--
 include/net/net_namespace.h    |    2 
 kernel/taskstats.c             |   10 +-
 net/irda/irnetlink.c           |    2 
 net/netfilter/ipvs/ip_vs_ctl.c |    2 
 net/netlink/genetlink.c        |  195 ++++++++++++++++++++++++++++++++---------
 net/tipc/netlink.c             |    2 
 net/wireless/nl80211.c         |   14 +-
 9 files changed, 196 insertions(+), 65 deletions(-)

--- wireless-testing.orig/include/net/genetlink.h	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/include/net/genetlink.h	2009-06-18 03:48:13.000000000 +0200
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
@@ -168,16 +171,27 @@ static inline void genlmsg_cancel(struct
 }
 
 /**
- * genlmsg_multicast - multicast a netlink message
+ * genlmsg_multicast - multicast a netlink message to all network namespaces
+ * @skb: netlink message as socket buffer
+ * @pid: own netlink pid to avoid sending to yourself
+ * @group: multicast group id
+ * @flags: allocation flags
+ */
+int genlmsg_multicast(struct sk_buff *skb, u32 pid,
+		      unsigned int group, gfp_t flags);
+
+/**
+ * genlmsg_multicast_netns - multicast a netlink message to a specific netns
+ * @net: the net namespace
  * @skb: netlink message as socket buffer
  * @pid: own netlink pid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast(struct sk_buff *skb, u32 pid,
-				    unsigned int group, gfp_t flags)
+static inline int genlmsg_multicast_netns(struct net *net, struct sk_buff *skb,
+					  u32 pid, unsigned int group, gfp_t flags)
 {
-	return nlmsg_multicast(genl_sock, skb, pid, group, flags);
+	return nlmsg_multicast(net->genl_sock, skb, pid, group, flags);
 }
 
 /**
@@ -185,9 +199,9 @@ static inline int genlmsg_multicast(stru
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
@@ -197,7 +211,7 @@ static inline int genlmsg_unicast(struct
  */
 static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info)
 {
-	return genlmsg_unicast(skb, info->snd_pid);
+	return genlmsg_unicast(info->net, skb, info->snd_pid);
 }
 
 /**
--- wireless-testing.orig/net/netlink/genetlink.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/net/netlink/genetlink.c	2009-06-18 04:18:22.000000000 +0200
@@ -15,11 +15,10 @@
 #include <linux/skbuff.h>
 #include <linux/mutex.h>
 #include <linux/bitmap.h>
+#include <linux/rtnetlink.h>
 #include <net/sock.h>
 #include <net/genetlink.h>
 
-struct sock *genl_sock = NULL;
-
 static DEFINE_MUTEX(genl_mutex); /* serialization of message processing */
 
 static inline void genl_lock(void)
@@ -175,10 +174,30 @@ int genl_register_mc_group(struct genl_f
 		mc_groups_longs++;
 	}
 
-	err = netlink_change_ngroups(genl_sock,
-				     mc_groups_longs * BITS_PER_LONG);
-	if (err)
-		goto out;
+	if (family->netnsok) {
+		struct net *net;
+
+		rtnl_lock();
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
+		rtnl_unlock();
+	} else {
+		err = netlink_change_ngroups(init_net.genl_sock,
+					     mc_groups_longs * BITS_PER_LONG);
+		if (err)
+			goto out;
+	}
 
 	grp->id = id;
 	set_bit(id, mc_groups);
@@ -195,8 +214,14 @@ EXPORT_SYMBOL(genl_register_mc_group);
 static void __genl_unregister_mc_group(struct genl_family *family,
 				       struct genl_multicast_group *grp)
 {
+	struct net *net;
 	BUG_ON(grp->family != family);
-	netlink_clear_multicast_users(genl_sock, grp->id);
+
+	rtnl_lock();
+	for_each_net(net)
+		netlink_clear_multicast_users(net->genl_sock, grp->id);
+	rtnl_unlock();
+
 	clear_bit(grp->id, mc_groups);
 	list_del(&grp->list);
 	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
@@ -421,6 +446,7 @@ static int genl_rcv_msg(struct sk_buff *
 {
 	struct genl_ops *ops;
 	struct genl_family *family;
+	struct net *net = sock_net(skb->sk);
 	struct genl_info info;
 	struct genlmsghdr *hdr = nlmsg_data(nlh);
 	int hdrlen, err;
@@ -429,6 +455,10 @@ static int genl_rcv_msg(struct sk_buff *
 	if (family == NULL)
 		return -ENOENT;
 
+	/* this family doesn't exist in this netns */
+	if (!family->netnsok && !net_eq(net, &init_net))
+		return -ENOENT;
+
 	hdrlen = GENL_HDRLEN + family->hdrsize;
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		return -EINVAL;
@@ -446,7 +476,7 @@ static int genl_rcv_msg(struct sk_buff *
 			return -EOPNOTSUPP;
 
 		genl_unlock();
-		err = netlink_dump_start(genl_sock, skb, nlh,
+		err = netlink_dump_start(net->genl_sock, skb, nlh,
 					 ops->dumpit, ops->done);
 		genl_lock();
 		return err;
@@ -468,6 +498,7 @@ static int genl_rcv_msg(struct sk_buff *
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
+	info.net = net;
 
 	return ops->doit(skb, &info);
 }
@@ -488,6 +519,7 @@ static struct genl_family genl_ctrl = {
 	.name = "nlctrl",
 	.version = 0x2,
 	.maxattr = CTRL_ATTR_MAX,
+	.netnsok = true,
 };
 
 static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
@@ -604,6 +636,7 @@ static int ctrl_dumpfamily(struct sk_buf
 
 	int i, n = 0;
 	struct genl_family *rt;
+	struct net *net = sock_net(skb->sk);
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
@@ -612,6 +645,8 @@ static int ctrl_dumpfamily(struct sk_buf
 			continue;
 		n = 0;
 		list_for_each_entry(rt, genl_family_chain(i), family_list) {
+			if (!rt->netnsok && !net_eq(net, &init_net))
+				continue;
 			if (++n < fams_to_skip)
 				continue;
 			if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).pid,
@@ -683,6 +718,7 @@ static int ctrl_getfamily(struct sk_buff
 	if (info->attrs[CTRL_ATTR_FAMILY_ID]) {
 		u16 id = nla_get_u16(info->attrs[CTRL_ATTR_FAMILY_ID]);
 		res = genl_family_find_byid(id);
+		err = -ENOENT;
 	}
 
 	if (info->attrs[CTRL_ATTR_FAMILY_NAME]) {
@@ -690,51 +726,60 @@ static int ctrl_getfamily(struct sk_buff
 
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
+	if (!res->netnsok && !net_eq(info->net, &init_net)) {
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
 	struct sk_buff *msg;
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
 	}
 
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	if (!family->netnsok)
+		genlmsg_multicast_netns(&init_net, msg, 0,
+					GENL_ID_CTRL, GFP_KERNEL);
+	else
+		genlmsg_multicast(msg, 0, GENL_ID_CTRL, GFP_KERNEL);
+
 	return 0;
 }
 
@@ -749,6 +794,33 @@ static struct genl_multicast_group notif
 	.name		= "notify",
 };
 
+static int __net_init genl_pernet_init(struct net *net)
+{
+	/* we'll bump the group number right afterwards */
+	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC, 0,
+					       genl_rcv, &genl_mutex,
+					       THIS_MODULE);
+
+	if (!net->genl_sock && net_eq(net, &init_net))
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
@@ -758,36 +830,79 @@ static int __init genl_init(void)
 
 	err = genl_register_family(&genl_ctrl);
 	if (err < 0)
-		goto errout;
+		goto problem;
 
 	err = genl_register_ops(&genl_ctrl, &genl_ctrl_ops);
 	if (err < 0)
-		goto errout_register;
+		goto problem;
 
 	netlink_set_nonroot(NETLINK_GENERIC, NL_NONROOT_RECV);
 
-	/* we'll bump the group number right afterwards */
-	genl_sock = netlink_kernel_create(&init_net, NETLINK_GENERIC, 0,
-					  genl_rcv, &genl_mutex, THIS_MODULE);
-	if (genl_sock == NULL)
-		panic("GENL: Cannot initialize generic netlink\n");
+	err = register_pernet_subsys(&genl_pernet_ops);
+	if (err)
+		goto problem;
 
 	err = genl_register_mc_group(&genl_ctrl, &notify_grp);
 	if (err < 0)
-		goto errout_register;
+		goto problem;
 
 	return 0;
 
-errout_register:
-	genl_unregister_family(&genl_ctrl);
-errout:
+problem:
 	panic("GENL: Cannot register controller: %d\n", err);
 }
 
 subsys_initcall(genl_init);
 
-EXPORT_SYMBOL(genl_sock);
 EXPORT_SYMBOL(genl_register_ops);
 EXPORT_SYMBOL(genl_unregister_ops);
 EXPORT_SYMBOL(genl_register_family);
 EXPORT_SYMBOL(genl_unregister_family);
+
+static int genlmsg_mcast(struct sk_buff *skb, u32 pid, unsigned long group,
+			 gfp_t flags)
+{
+	struct sk_buff *tmp;
+	struct net *net, *prev = NULL;
+	int err;
+
+	for_each_net_rcu(net) {
+		if (prev) {
+			tmp = skb_clone(skb, flags);
+			if (!tmp) {
+				err = -ENOMEM;
+				goto error;
+			}
+			err = nlmsg_multicast(prev->genl_sock, tmp,
+					      pid, group, flags);
+			if (err)
+				goto error;
+		}
+
+		prev = net;
+	}
+
+	return nlmsg_multicast(prev->genl_sock, skb, pid, group, flags);
+ error:
+	kfree_skb(skb);
+	return err;
+}
+
+int genlmsg_multicast(struct sk_buff *skb, u32 pid,
+		      unsigned int group, gfp_t flags)
+{
+	int ret;
+
+	if (flags & GFP_ATOMIC) {
+		rcu_read_lock();
+		ret = genlmsg_mcast(skb, pid, group, flags);
+		rcu_read_unlock();
+	} else {
+		rtnl_lock();
+		ret = genlmsg_mcast(skb, pid, group, flags);
+		rtnl_unlock();
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(genlmsg_multicast);
--- wireless-testing.orig/fs/dlm/netlink.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/fs/dlm/netlink.c	2009-06-18 03:48:13.000000000 +0200
@@ -63,7 +63,7 @@ static int send_data(struct sk_buff *skb
 		return rv;
 	}
 
-	return genlmsg_unicast(skb, listener_nlpid);
+	return genlmsg_unicast(&init_net, skb, listener_nlpid);
 }
 
 static int user_cmd(struct sk_buff *skb, struct genl_info *info)
--- wireless-testing.orig/kernel/taskstats.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/kernel/taskstats.c	2009-06-18 03:48:13.000000000 +0200
@@ -108,7 +108,7 @@ static int prepare_reply(struct genl_inf
 /*
  * Send taskstats data in @skb to listener with nl_pid @pid
  */
-static int send_reply(struct sk_buff *skb, pid_t pid)
+static int send_reply(struct sk_buff *skb, struct genl_info *info)
 {
 	struct genlmsghdr *genlhdr = nlmsg_data(nlmsg_hdr(skb));
 	void *reply = genlmsg_data(genlhdr);
@@ -120,7 +120,7 @@ static int send_reply(struct sk_buff *sk
 		return rc;
 	}
 
-	return genlmsg_unicast(skb, pid);
+	return genlmsg_reply(skb, info);
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
@@ -418,7 +418,7 @@ static int cgroupstats_user_cmd(struct s
 		goto err;
 	}
 
-	rc = send_reply(rep_skb, info->snd_pid);
+	rc = send_reply(rep_skb, info);
 
 err:
 	fput_light(file, fput_needed);
@@ -487,7 +487,7 @@ free_return_rc:
 	} else
 		goto err;
 
-	return send_reply(rep_skb, info->snd_pid);
+	return send_reply(rep_skb, info);
 err:
 	nlmsg_free(rep_skb);
 	return rc;
--- wireless-testing.orig/net/irda/irnetlink.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/net/irda/irnetlink.c	2009-06-18 03:48:13.000000000 +0200
@@ -115,7 +115,7 @@ static int irda_nl_get_mode(struct sk_bu
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(msg, info->snd_pid);
+	return genlmsg_reply(msg, info);
 
  err_out:
 	nlmsg_free(msg);
--- wireless-testing.orig/net/netfilter/ipvs/ip_vs_ctl.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/net/netfilter/ipvs/ip_vs_ctl.c	2009-06-18 03:48:13.000000000 +0200
@@ -3231,7 +3231,7 @@ static int ip_vs_genl_get_cmd(struct sk_
 	}
 
 	genlmsg_end(msg, reply);
-	ret = genlmsg_unicast(msg, info->snd_pid);
+	ret = genlmsg_reply(msg, info);
 	goto out;
 
 nla_put_failure:
--- wireless-testing.orig/net/tipc/netlink.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/net/tipc/netlink.c	2009-06-18 03:48:13.000000000 +0200
@@ -62,7 +62,7 @@ static int handle_cmd(struct sk_buff *sk
 		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);
+		genlmsg_unicast(&init_net, rep_buf, NETLINK_CB(skb).pid);
 	}
 
 	return 0;
--- wireless-testing.orig/net/wireless/nl80211.c	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2009-06-18 04:16:38.000000000 +0200
@@ -398,7 +398,7 @@ static int nl80211_get_wiphy(struct sk_b
 
 	cfg80211_put_dev(dev);
 
-	return genlmsg_unicast(msg, info->snd_pid);
+	return genlmsg_reply(msg, info);
 
  out_free:
 	nlmsg_free(msg);
@@ -723,7 +723,7 @@ static int nl80211_get_interface(struct 
 	dev_put(netdev);
 	cfg80211_put_dev(dev);
 
-	return genlmsg_unicast(msg, info->snd_pid);
+	return genlmsg_reply(msg, info);
 
  out_free:
 	nlmsg_free(msg);
@@ -1014,7 +1014,7 @@ static int nl80211_get_key(struct sk_buf
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_reply(msg, info);
 	goto out;
 
  nla_put_failure:
@@ -1602,7 +1602,7 @@ static int nl80211_get_station(struct sk
 				 dev, mac_addr, &sinfo) < 0)
 		goto out_free;
 
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_reply(msg, info);
 	goto out;
 
  out_free:
@@ -2009,7 +2009,7 @@ static int nl80211_get_mpath(struct sk_b
 				 dev, dst, next_hop, &pinfo) < 0)
 		goto out_free;
 
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_reply(msg, info);
 	goto out;
 
  out_free:
@@ -2358,7 +2358,7 @@ static int nl80211_get_mesh_params(struc
 			cur_params.dot11MeshHWMPnetDiameterTraversalTime);
 	nla_nest_end(msg, pinfoattr);
 	genlmsg_end(msg, hdr);
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_reply(msg, info);
 	goto out;
 
  nla_put_failure:
@@ -2546,7 +2546,7 @@ static int nl80211_get_reg(struct sk_buf
 	nla_nest_end(msg, nl_reg_rules);
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_reply(msg, info);
 	goto out;
 
 nla_put_failure:
--- wireless-testing.orig/include/net/net_namespace.h	2009-06-18 03:48:12.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-06-18 04:17:00.000000000 +0200
@@ -26,6 +26,7 @@ struct net_device;
 struct sock;
 struct ctl_table_header;
 struct net_generic;
+struct sock;
 
 struct net {
 	atomic_t		count;		/* To decided when the network
@@ -57,6 +58,7 @@ struct net {
 	spinlock_t		rules_mod_lock;
 
 	struct sock 		*rtnl;			/* rtnetlink socket */
+	struct sock		*genl_sock;
 
 	struct netns_core	core;
 	struct netns_mib	mib;


