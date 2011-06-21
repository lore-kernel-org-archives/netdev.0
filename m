From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] rtnl: provide link dump consistency info
Date: Tue, 21 Jun 2011 09:11:20 -0400
Message-ID: <20110621131120.GA19486@canuck.infradead.org>
References: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Samuel Ortiz <samuel@sortiz.org>,
	"aloisio.almeida" <aloisio.almeida@openbossa.org>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:45076 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab1FUNL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 09:11:27 -0400
Content-Disposition: inline
In-Reply-To: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a change sequence counter to each net namespace
which is bumped whenever a netdevice is added or removed from
the list. If such a change occurred while a link dump took place,
the dump will have the NLM_F_DUMP_INTR flag set in the first
message which has been interrupted and in all subsequent messages
of the same dump.

Note that links may still be modified or renamed while a dump is
taking place but we can guarantee for userspace to receive a
complete list of links and not miss any.

Testing:
I have added 500 VLAN netdevices to make sure the dump is split
over multiple messages. Then while continuously dumping links in
one process I also continuously deleted and re-added a dummy
netdevice in another process. Multiple dumps per seconds have
had the NLM_F_DUMP_INTR flag set.

I guess we can wait for Johannes patch to hit net-next via the
wireless tree.  I just wanted to give this some testing right away.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2bf9ed9..ff5c680 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -62,6 +62,7 @@ struct net {
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
+	unsigned int		dev_base_seq;	/* protected by rtnl_mutex */
 
 	/* core fib_rules */
 	struct list_head	rules_ops;
diff --git a/net/core/dev.c b/net/core/dev.c
index 9c58c1e..97f30b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -199,6 +199,11 @@ static struct list_head ptype_all __read_mostly;	/* Taps */
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+static inline void dev_base_seq_inc(struct net *net)
+{
+	while (++net->dev_base_seq == 0);
+}
+
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
 	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
@@ -237,6 +242,9 @@ static int list_netdevice(struct net_device *dev)
 	hlist_add_head_rcu(&dev->index_hlist,
 			   dev_index_hash(net, dev->ifindex));
 	write_unlock_bh(&dev_base_lock);
+
+	dev_base_seq_inc(net);
+
 	return 0;
 }
 
@@ -253,6 +261,8 @@ static void unlist_netdevice(struct net_device *dev)
 	hlist_del_rcu(&dev->name_hlist);
 	hlist_del_rcu(&dev->index_hlist);
 	write_unlock_bh(&dev_base_lock);
+
+	dev_base_seq_inc(dev_net(dev));
 }
 
 /*
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index e41e511..91f03c7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -128,6 +128,7 @@ static __net_init int setup_net(struct net *net)
 	LIST_HEAD(net_exit_list);
 
 	atomic_set(&net->count, 1);
+	net->dev_base_seq = 1;
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index abd936d..8d694b6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1009,6 +1009,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	s_idx = cb->args[1];
 
 	rcu_read_lock();
+	cb->seq = net->dev_base_seq;
+
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
@@ -1020,6 +1022,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 					     cb->nlh->nlmsg_seq, 0,
 					     NLM_F_MULTI) <= 0)
 				goto out;
+
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
