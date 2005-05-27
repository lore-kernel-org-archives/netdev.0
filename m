From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2] [NETLINK] Correctly set NLM_F_MULTI without checking the pid
Date: Fri, 27 May 2005 19:01:35 +0200
Message-ID: <20050527170135.GE15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain> <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain> <20050527151913.GA15391@postel.suug.ch> <1117209466.6383.106.camel@localhost.localdomain> <20050527165935.GC15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050527165935.GC15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch rectifies some rtnetlink message builders that derive the
flags from the pid. It is now explicit like the other cases
which get it right. Also fixes half a dozen dumpers which did not
set NLM_F_MULTI at all.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: Thomas Graf <tgraf@suug.ch>


---
commit b20a9fb4f28c4397096cf3c745c42cf045c36a7a
tree 5144b4dc6ffa4fb1821eb758838f63c5e210bc34
parent 1eb85f52f4e0d23996f6aa49009ce02fc0579658
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 18:58:48 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 18:58:48 +0200

 net/core/neighbour.c     |   14 ++++++-------
 net/core/rtnetlink.c     |   13 +++++++-----
 net/decnet/dn_dev.c      |    9 ++++----
 net/decnet/dn_route.c    |   11 +++++-----
 net/decnet/dn_rules.c    |    7 +++---
 net/decnet/dn_table.c    |    8 +++----
 net/ipv4/devinet.c       |    9 +++-----
 net/ipv4/fib_hash.c      |    3 +-
 net/ipv4/fib_lookup.h    |    3 +-
 net/ipv4/fib_rules.c     |    7 +++---
 net/ipv4/fib_semantics.c |    6 ++---
 net/ipv4/route.c         |   11 ++++------
 net/ipv6/addrconf.c      |   49 ++++++++++++++++++++++-------------------------
 net/ipv6/route.c         |   11 +++++-----
 14 files changed, 83 insertions(+), 78 deletions(-)

Index: net/core/neighbour.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/core/neighbour.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/core/neighbour.c  (mode:100644)
@@ -1857,18 +1857,17 @@
 }
 
 static int neigh_fill_info(struct sk_buff *skb, struct neighbour *n,
-			   u32 pid, u32 seq, int event)
+			   u32 pid, u32 seq, int event, unsigned int flags)
 {
 	unsigned long now = jiffies;
 	unsigned char *b = skb->tail;
 	struct nda_cacheinfo ci;
 	int locked = 0;
 	u32 probes;
-	struct nlmsghdr *nlh = NLMSG_PUT(skb, pid, seq, event,
-					 sizeof(struct ndmsg));
+	struct nlmsghdr *nlh = NLMSG_NEW(skb, pid, seq, event,
+					 sizeof(struct ndmsg), flags);
 	struct ndmsg *ndm = NLMSG_DATA(nlh);
 
-	nlh->nlmsg_flags = pid ? NLM_F_MULTI : 0;
 	ndm->ndm_family	 = n->ops->family;
 	ndm->ndm_flags	 = n->flags;
 	ndm->ndm_type	 = n->type;
@@ -1918,7 +1917,8 @@
 				continue;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
 					    cb->nlh->nlmsg_seq,
-					    RTM_NEWNEIGH) <= 0) {
+					    RTM_NEWNEIGH,
+					    NLM_F_MULTI) <= 0) {
 				read_unlock_bh(&tbl->lock);
 				rc = -1;
 				goto out;
@@ -2327,7 +2327,7 @@
 	if (!skb)
 		return;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH) < 0) {
+	if (neigh_fill_info(skb, n, 0, 0, RTM_GETNEIGH, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
@@ -2346,7 +2346,7 @@
 	if (!skb)
 		return;
 
-	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH) < 0) {
+	if (neigh_fill_info(skb, n, 0, 0, RTM_NEWNEIGH, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
Index: net/core/rtnetlink.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/core/rtnetlink.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/core/rtnetlink.c  (mode:100644)
@@ -178,14 +178,14 @@
 
 
 static int rtnetlink_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
-				 int type, u32 pid, u32 seq, u32 change)
+				 int type, u32 pid, u32 seq, u32 change, 
+				 unsigned int flags)
 {
 	struct ifinfomsg *r;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*r));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW(skb, pid, seq, type, sizeof(*r), flags);
 	r = NLMSG_DATA(nlh);
 	r->ifi_family = AF_UNSPEC;
 	r->ifi_type = dev->type;
@@ -275,7 +275,10 @@
 	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
-		if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq, 0) <= 0)
+		if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK,
+					  NETLINK_CB(cb->skb).pid,
+					  cb->nlh->nlmsg_seq, 0,
+					  NLM_F_MULTI) <= 0)
 			break;
 	}
 	read_unlock(&dev_base_lock);
@@ -449,7 +452,7 @@
 	if (!skb)
 		return;
 
-	if (rtnetlink_fill_ifinfo(skb, dev, type, 0, 0, change) < 0) {
+	if (rtnetlink_fill_ifinfo(skb, dev, type, 0, 0, change, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
Index: net/decnet/dn_dev.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/decnet/dn_dev.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/decnet/dn_dev.c  (mode:100644)
@@ -716,13 +716,13 @@
 }
 
 static int dn_dev_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
-				u32 pid, u32 seq, int event)
+				u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
 	ifm = NLMSG_DATA(nlh);
 
 	ifm->ifa_family = AF_DECnet;
@@ -755,7 +755,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_DECnet_IFADDR, ENOBUFS);
 		return;
 	}
-	if (dn_dev_fill_ifaddr(skb, ifa, 0, 0, event) < 0) {
+	if (dn_dev_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_DECnet_IFADDR, EINVAL);
 		return;
@@ -790,7 +790,8 @@
 			if (dn_dev_fill_ifaddr(skb, ifa,
 					       NETLINK_CB(cb->skb).pid,
 					       cb->nlh->nlmsg_seq,
-					       RTM_NEWADDR) <= 0)
+					       RTM_NEWADDR,
+					       NLM_F_MULTI) <= 0)
 				goto done;
 		}
 	}
Index: net/decnet/dn_route.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/decnet/dn_route.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/decnet/dn_route.c  (mode:100644)
@@ -1465,7 +1465,8 @@
 	return dn_route_input_slow(skb);
 }
 
-static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event, int nowait)
+static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+			   int event, int nowait, unsigned int flags)
 {
 	struct dn_route *rt = (struct dn_route *)skb->dst;
 	struct rtmsg *r;
@@ -1473,9 +1474,8 @@
 	unsigned char *b = skb->tail;
 	struct rta_cacheinfo ci;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
 	r = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = (nowait && pid) ? NLM_F_MULTI : 0;
 	r->rtm_family = AF_DECnet;
 	r->rtm_dst_len = 16;
 	r->rtm_src_len = 0;
@@ -1596,7 +1596,7 @@
 
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 
-	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq, RTM_NEWROUTE, 0);
+	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq, RTM_NEWROUTE, 0, 0);
 
 	if (err == 0)
 		goto out_free;
@@ -1644,7 +1644,8 @@
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);
 			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
-					cb->nlh->nlmsg_seq, RTM_NEWROUTE, 1) <= 0) {
+					cb->nlh->nlmsg_seq, RTM_NEWROUTE, 
+					1, NLM_F_MULTI) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));
 				rcu_read_unlock_bh();
 				goto done;
Index: net/decnet/dn_rules.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/decnet/dn_rules.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/decnet/dn_rules.c  (mode:100644)
@@ -342,14 +342,15 @@
 	.notifier_call =	dn_fib_rules_event,
 };
 
-static int dn_fib_fill_rule(struct sk_buff *skb, struct dn_fib_rule *r, struct netlink_callback *cb)
+static int dn_fib_fill_rule(struct sk_buff *skb, struct dn_fib_rule *r,
+			    struct netlink_callback *cb, unsigned int flags)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb->tail;
 
 
-	nlh = NLMSG_PUT(skb, NETLINK_CREDS(cb->skb)->pid, cb->nlh->nlmsg_seq, RTM_NEWRULE, sizeof(*rtm));
+	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWRULE, sizeof(*rtm), flags);
 	rtm = NLMSG_DATA(nlh);
 	rtm->rtm_family = AF_DECnet;
 	rtm->rtm_dst_len = r->r_dst_len;
@@ -394,7 +395,7 @@
 	for(r = dn_fib_rules, idx = 0; r; r = r->r_next, idx++) {
 		if (idx < s_idx)
 			continue;
-		if (dn_fib_fill_rule(skb, r, cb) < 0)
+		if (dn_fib_fill_rule(skb, r, cb, NLM_F_MULTI) < 0)
 			break;
 	}
 	read_unlock(&dn_fib_rules_lock);
Index: net/decnet/dn_table.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/decnet/dn_table.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/decnet/dn_table.c  (mode:100644)
@@ -270,13 +270,13 @@
 
 static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
                         u8 tb_id, u8 type, u8 scope, void *dst, int dst_len,
-                        struct dn_fib_info *fi)
+                        struct dn_fib_info *fi, unsigned int flags)
 {
         struct rtmsg *rtm;
         struct nlmsghdr *nlh;
         unsigned char *b = skb->tail;
 
-        nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*rtm));
+        nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*rtm), flags);
         rtm = NLMSG_DATA(nlh);
         rtm->rtm_family = AF_DECnet;
         rtm->rtm_dst_len = dst_len;
@@ -345,7 +345,7 @@
 
         if (dn_fib_dump_info(skb, pid, nlh->nlmsg_seq, event, tb_id, 
                                 f->fn_type, f->fn_scope, &f->fn_key, z, 
-                                DN_FIB_INFO(f)) < 0) {
+                                DN_FIB_INFO(f), 0) < 0) {
                 kfree_skb(skb);
                 return;
         }
@@ -377,7 +377,7 @@
 				tb->n, 
 				(f->fn_state & DN_S_ZOMBIE) ? 0 : f->fn_type,
 				f->fn_scope, &f->fn_key, dz->dz_order, 
-				f->fn_info) < 0) {
+				f->fn_info, NLM_F_MULTI) < 0) {
 			cb->args[3] = i;
 			return -1;
 		}
Index: net/ipv4/devinet.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv4/devinet.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv4/devinet.c  (mode:100644)
@@ -1015,14 +1015,13 @@
 };
 
 static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
-			    u32 pid, u32 seq, int event)
+			    u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET;
 	ifm->ifa_prefixlen = ifa->ifa_prefixlen;
@@ -1075,7 +1074,7 @@
 				continue;
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
-					     RTM_NEWADDR) <= 0) {
+					     RTM_NEWADDR, NLM_F_MULTI) <= 0) {
 				rcu_read_unlock();
 				goto done;
 			}
@@ -1098,7 +1097,7 @@
 
 	if (!skb)
 		netlink_set_err(rtnl, 0, RTMGRP_IPV4_IFADDR, ENOBUFS);
-	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event) < 0) {
+	else if (inet_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV4_IFADDR, EINVAL);
 	} else {
Index: net/ipv4/fib_hash.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv4/fib_hash.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv4/fib_hash.c  (mode:100644)
@@ -703,7 +703,8 @@
 					  &f->fn_key,
 					  fz->fz_order,
 					  fa->fa_tos,
-					  fa->fa_info) < 0) {
+					  fa->fa_info,
+					  NLM_F_MULTI) < 0) {
 				cb->args[3] = i;
 				return -1;
 			}
Index: net/ipv4/fib_lookup.h
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv4/fib_lookup.h  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv4/fib_lookup.h  (mode:100644)
@@ -30,7 +30,8 @@
 			struct kern_rta *rta, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			 u8 tb_id, u8 type, u8 scope, void *dst,
-			 int dst_len, u8 tos, struct fib_info *fi);
+			 int dst_len, u8 tos, struct fib_info *fi,
+			 unsigned int);
 extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
 		      int z, int tb_id,
 		      struct nlmsghdr *n, struct netlink_skb_parms *req);
Index: net/ipv4/fib_rules.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv4/fib_rules.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv4/fib_rules.c  (mode:100644)
@@ -367,13 +367,14 @@
 
 static __inline__ int inet_fill_rule(struct sk_buff *skb,
 				     struct fib_rule *r,
-				     struct netlink_callback *cb)
+				     struct netlink_callback *cb,
+				     unsigned int flags)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, NETLINK_CREDS(cb->skb)->pid, cb->nlh->nlmsg_seq, RTM_NEWRULE, sizeof(*rtm));
+	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWRULE, sizeof(*rtm), flags);
 	rtm = NLMSG_DATA(nlh);
 	rtm->rtm_family = AF_INET;
 	rtm->rtm_dst_len = r->r_dst_len;
@@ -422,7 +423,7 @@
 	for (r=fib_rules, idx=0; r; r = r->r_next, idx++) {
 		if (idx < s_idx)
 			continue;
-		if (inet_fill_rule(skb, r, cb) < 0)
+		if (inet_fill_rule(skb, r, cb, NLM_F_MULTI) < 0)
 			break;
 	}
 	read_unlock(&fib_rules_lock);
Index: net/ipv4/fib_semantics.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv4/fib_semantics.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv4/fib_semantics.c  (mode:100644)
@@ -286,7 +286,7 @@
 	if (fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
 			  fa->fa_type, fa->fa_scope, &key, z,
 			  fa->fa_tos,
-			  fa->fa_info) < 0) {
+			  fa->fa_info, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
@@ -932,13 +932,13 @@
 int
 fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 	      u8 tb_id, u8 type, u8 scope, void *dst, int dst_len, u8 tos,
-	      struct fib_info *fi)
+	      struct fib_info *fi, unsigned int flags)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr  *nlh;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*rtm));
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*rtm), flags);
 	rtm = NLMSG_DATA(nlh);
 	rtm->rtm_family = AF_INET;
 	rtm->rtm_dst_len = dst_len;
Index: net/ipv4/route.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv4/route.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv4/route.c  (mode:100644)
@@ -2581,7 +2581,7 @@
 }
 
 static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			int nowait)
+			int nowait, unsigned int flags)
 {
 	struct rtable *rt = (struct rtable*)skb->dst;
 	struct rtmsg *r;
@@ -2591,9 +2591,8 @@
 #ifdef CONFIG_IP_MROUTE
 	struct rtattr *eptr;
 #endif
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
 	r = NLMSG_DATA(nlh);
-	nlh->nlmsg_flags = (nowait && pid) ? NLM_F_MULTI : 0;
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
@@ -2744,7 +2743,7 @@
 	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
 
 	err = rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
-				RTM_NEWROUTE, 0);
+				RTM_NEWROUTE, 0, 0);
 	if (!err)
 		goto out_free;
 	if (err < 0) {
@@ -2781,8 +2780,8 @@
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);
 			if (rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
-					 cb->nlh->nlmsg_seq,
-					 RTM_NEWROUTE, 1) <= 0) {
+					 cb->nlh->nlmsg_seq, RTM_NEWROUTE, 
+					 1, NLM_F_MULTI) <= 0) {
 				dst_release(xchg(&skb->dst, NULL));
 				rcu_read_unlock_bh();
 				goto done;
Index: net/ipv6/addrconf.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv6/addrconf.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv6/addrconf.c  (mode:100644)
@@ -2621,15 +2621,14 @@
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
-			     u32 pid, u32 seq, int event)
+			     u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	struct ifa_cacheinfo ci;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;
 	ifm->ifa_prefixlen = ifa->prefix_len;
@@ -2671,15 +2670,14 @@
 }
 
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
-				u32 pid, u32 seq, int event)
+				u32 pid, u32 seq, int event, unsigned flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	struct ifa_cacheinfo ci;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;	
 	ifm->ifa_prefixlen = 128;
@@ -2708,15 +2706,14 @@
 }
 
 static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
-				u32 pid, u32 seq, int event)
+				u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 	struct ifa_cacheinfo ci;
 	unsigned char	 *b = skb->tail;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*ifm), flags);
 	ifm = NLMSG_DATA(nlh);
 	ifm->ifa_family = AF_INET6;	
 	ifm->ifa_prefixlen = 128;
@@ -2785,7 +2782,8 @@
 					continue;
 				if ((err = inet6_fill_ifaddr(skb, ifa, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0)
+				    cb->nlh->nlmsg_seq, RTM_NEWADDR,
+				    NLM_F_MULTI)) <= 0)
 					goto done;
 			}
 			/* temp addr */
@@ -2796,7 +2794,8 @@
 					continue;
 				if ((err = inet6_fill_ifaddr(skb, ifa, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
+				    cb->nlh->nlmsg_seq, RTM_NEWADDR,
+				    NLM_F_MULTI)) <= 0) 
 					goto done;
 			}
 #endif
@@ -2809,7 +2808,8 @@
 					continue;
 				if ((err = inet6_fill_ifmcaddr(skb, ifmca, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST)) <= 0)
+				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST,
+				    NLM_F_MULTI)) <= 0)
 					goto done;
 			}
 			break;
@@ -2821,7 +2821,8 @@
 					continue;
 				if ((err = inet6_fill_ifacaddr(skb, ifaca, 
 				    NETLINK_CB(cb->skb).pid, 
-				    cb->nlh->nlmsg_seq, RTM_GETANYCAST)) <= 0) 
+				    cb->nlh->nlmsg_seq, RTM_GETANYCAST,
+				    NLM_F_MULTI)) <= 0) 
 					goto done;
 			}
 			break;
@@ -2871,7 +2872,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFADDR, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_ifaddr(skb, ifa, 0, 0, event) < 0) {
+	if (inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFADDR, EINVAL);
 		return;
@@ -2906,7 +2907,7 @@
 }
 
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev, 
-			     u32 pid, u32 seq, int event)
+			     u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct net_device	*dev = idev->dev;
 	__s32			*array = NULL;
@@ -2917,8 +2918,7 @@
 	__u32			mtu = dev->mtu;
 	struct ifla_cacheinfo	ci;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
-	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
 	r = NLMSG_DATA(nlh);
 	r->ifi_family = AF_INET6;
 	r->ifi_type = dev->type;
@@ -2985,7 +2985,7 @@
 		if ((idev = in6_dev_get(dev)) == NULL)
 			continue;
 		err = inet6_fill_ifinfo(skb, idev, NETLINK_CB(cb->skb).pid, 
-				cb->nlh->nlmsg_seq, RTM_NEWLINK);
+				cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
 		in6_dev_put(idev);
 		if (err <= 0)
 			break;
@@ -3007,7 +3007,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_ifinfo(skb, idev, 0, 0, event) < 0) {
+	if (inet6_fill_ifinfo(skb, idev, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_IFINFO, EINVAL);
 		return;
@@ -3017,18 +3017,15 @@
 }
 
 static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
-			struct prefix_info *pinfo, u32 pid, u32 seq, int event)
+			struct prefix_info *pinfo, u32 pid, u32 seq, 
+			int event, unsigned int flags)
 {
 	struct prefixmsg	*pmsg;
 	struct nlmsghdr 	*nlh;
 	unsigned char		*b = skb->tail;
 	struct prefix_cacheinfo	ci;
 
-	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*pmsg));
-	
-	if (pid) 
-		nlh->nlmsg_flags |= NLM_F_MULTI;
-	
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*pmsg), flags);
 	pmsg = NLMSG_DATA(nlh);
 	pmsg->prefix_family = AF_INET6;
 	pmsg->prefix_ifindex = idev->dev->ifindex;
@@ -3067,7 +3064,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, ENOBUFS);
 		return;
 	}
-	if (inet6_fill_prefix(skb, idev, pinfo, 0, 0, event) < 0) {
+	if (inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_PREFIX, EINVAL);
 		return;
Index: net/ipv6/route.c
===================================================================
--- debb58e5f900a6551f751b457226250cfccc3c75/net/ipv6/route.c  (mode:100644)
+++ 5144b4dc6ffa4fb1821eb758838f63c5e210bc34/net/ipv6/route.c  (mode:100644)
@@ -1570,7 +1570,8 @@
 			 struct in6_addr *src,
 			 int iif,
 			 int type, u32 pid, u32 seq,
-			 struct nlmsghdr *in_nlh, int prefix)
+			 struct nlmsghdr *in_nlh, int prefix,
+			 unsigned int flags)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr  *nlh;
@@ -1588,7 +1589,7 @@
 		pid = in_nlh->nlmsg_pid;
 	}
 
-	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*rtm));
+	nlh = NLMSG_NEW(skb, pid, seq, type, sizeof(*rtm), flags);
 	rtm = NLMSG_DATA(nlh);
 	rtm->rtm_family = AF_INET6;
 	rtm->rtm_dst_len = rt->rt6i_dst.plen;
@@ -1674,7 +1675,7 @@
 
 	return rt6_fill_node(arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,
-		     NULL, prefix);
+		     NULL, prefix, NLM_F_MULTI);
 }
 
 static int fib6_dump_node(struct fib6_walker_t *w)
@@ -1822,7 +1823,7 @@
 			    &fl.fl6_dst, &fl.fl6_src,
 			    iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
-			    nlh->nlmsg_seq, nlh, 0);
+			    nlh->nlmsg_seq, nlh, 0, 0);
 	if (err < 0) {
 		err = -EMSGSIZE;
 		goto out_free;
@@ -1848,7 +1849,7 @@
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, ENOBUFS);
 		return;
 	}
-	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh, 0) < 0) {
+	if (rt6_fill_node(skb, rt, NULL, NULL, 0, event, 0, 0, nlh, 0, 0) < 0) {
 		kfree_skb(skb);
 		netlink_set_err(rtnl, 0, RTMGRP_IPV6_ROUTE, EINVAL);
 		return;
