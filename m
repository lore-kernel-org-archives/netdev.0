From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: FIB reorg (1)
Date: Wed, 24 Nov 2004 20:09:42 +0100
Message-ID: <16804.56438.318740.779153@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

A couple of patches to reorg. FIB and make fib_hash.c cleaner.
rtmsg_fib() can be made a bit more generic and put in fib_semantics.c
something like below. 


						--ro


--- net/ipv4/fib_hash.c.orig	Tue Nov 16 21:41:59 2004
+++ net/ipv4/fib_hash.c	Tue Nov 16 22:41:46 2004
@@ -376,10 +376,10 @@
 	read_unlock(&fib_hash_lock);
 }
 
-static void rtmsg_fib(int, struct fib_node *, struct fib_alias *,
-		      int, int,
-		      struct nlmsghdr *n,
-		      struct netlink_skb_parms *);
+void rtmsg_fib(int, u32 key, struct fib_alias *,
+	       int, int,
+	       struct nlmsghdr *n,
+	       struct netlink_skb_parms *);
 
 /* Insert node F to FZ. */
 static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
@@ -565,7 +565,7 @@
 		fz->fz_nent++;
 	rt_cache_flush(-1);
 
-	rtmsg_fib(RTM_NEWROUTE, f, new_fa, z, tb->tb_id, n, req);
+	rtmsg_fib(RTM_NEWROUTE, key, new_fa, z, tb->tb_id, n, req);
 	return 0;
 
 out_free_new_fa:
@@ -631,7 +631,7 @@
 		int kill_fn;
 
 		fa = fa_to_delete;
-		rtmsg_fib(RTM_DELROUTE, f, fa, z, tb->tb_id, n, req);
+		rtmsg_fib(RTM_DELROUTE, key, fa, z, tb->tb_id, n, req);
 
 		kill_fn = 0;
 		write_lock_bh(&fib_hash_lock);
@@ -794,33 +794,6 @@
 	read_unlock(&fib_hash_lock);
 	cb->args[1] = m;
 	return skb->len;
-}
-
-static void rtmsg_fib(int event, struct fib_node *f, struct fib_alias *fa,
-		      int z, int tb_id,
-		      struct nlmsghdr *n, struct netlink_skb_parms *req)
-{
-	struct sk_buff *skb;
-	u32 pid = req ? req->pid : 0;
-	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
-
-	skb = alloc_skb(size, GFP_KERNEL);
-	if (!skb)
-		return;
-
-	if (fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
-			  fa->fa_type, fa->fa_scope, &f->fn_key, z,
-			  fa->fa_tos,
-			  fa->fa_info) < 0) {
-		kfree_skb(skb);
-		return;
-	}
-	NETLINK_CB(skb).dst_groups = RTMGRP_IPV4_ROUTE;
-	if (n->nlmsg_flags&NLM_F_ECHO)
-		atomic_inc(&skb->users);
-	netlink_broadcast(rtnl, skb, pid, RTMGRP_IPV4_ROUTE, GFP_KERNEL);
-	if (n->nlmsg_flags&NLM_F_ECHO)
-		netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
 }
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
--- net/ipv4/fib_semantics.c.orig	Tue Nov 16 21:42:19 2004
+++ net/ipv4/fib_semantics.c	Tue Nov 16 22:34:42 2004
@@ -268,6 +268,34 @@
 	return -1;
 }
 
+void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
+		      int z, int tb_id,
+		      struct nlmsghdr *n, struct netlink_skb_parms *req)
+{
+	struct sk_buff *skb;
+	u32 pid = req ? req->pid : 0;
+	int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
+
+	skb = alloc_skb(size, GFP_KERNEL);
+	if (!skb)
+		return;
+
+	if (fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
+			  fa->fa_type, fa->fa_scope, &key, z,
+			  fa->fa_tos,
+			  fa->fa_info) < 0) {
+		kfree_skb(skb);
+		return;
+	}
+	NETLINK_CB(skb).dst_groups = RTMGRP_IPV4_ROUTE;
+	if (n->nlmsg_flags&NLM_F_ECHO)
+		atomic_inc(&skb->users);
+	netlink_broadcast(rtnl, skb, pid, RTMGRP_IPV4_ROUTE, GFP_KERNEL);
+	if (n->nlmsg_flags&NLM_F_ECHO)
+		netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
+}
+
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
