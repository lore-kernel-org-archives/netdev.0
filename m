From: "David S. Miller" <davem@davemloft.net>
Subject: Re: FIB reorg (1)
Date: Tue, 30 Nov 2004 22:01:43 -0800
Message-ID: <20041130220143.3786e400.davem@davemloft.net>
References: <16804.56438.318740.779153@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16804.56438.318740.779153@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004 20:09:42 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> rtmsg_fib() can be made a bit more generic and put in fib_semantics.c
> something like below. 

Looks nice.  I've made a minor modification as I applied it to
my 2.6.11 pending tree.

We have a private header for routines shared between
fib_hash and fib_semantics, namely net/ipv4/fib_lookup.h
so that's where I placed the rtmsg_fib() extern declaration.

This is the final patch I applied.

Thanks Robert.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/30 21:37:16-08:00 davem@nuts.davemloft.net 
#   [IPV4]: FIB cleanup, rtmsg_fib()
#   
#   Based largely upon a patch by Robert Olsson.
#   
#   Abstract out rtmsg_fib() so that it does not depend
#   upon fib_hash internal datastructures, move it to
#   fib_semantics.c
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/fib_semantics.c
#   2004/11/30 21:36:06-08:00 davem@nuts.davemloft.net +27 -0
#   [IPV4]: FIB cleanup, rtmsg_fib()
# 
# net/ipv4/fib_lookup.h
#   2004/11/30 21:36:06-08:00 davem@nuts.davemloft.net +3 -0
#   [IPV4]: FIB cleanup, rtmsg_fib()
# 
# net/ipv4/fib_hash.c
#   2004/11/30 21:36:06-08:00 davem@nuts.davemloft.net +2 -34
#   [IPV4]: FIB cleanup, rtmsg_fib()
# 
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	2004-11-30 21:37:44 -08:00
+++ b/net/ipv4/fib_hash.c	2004-11-30 21:37:44 -08:00
@@ -376,11 +376,6 @@
 	read_unlock(&fib_hash_lock);
 }
 
-static void rtmsg_fib(int, struct fib_node *, struct fib_alias *,
-		      int, int,
-		      struct nlmsghdr *n,
-		      struct netlink_skb_parms *);
-
 /* Insert node F to FZ. */
 static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
 {
@@ -565,7 +560,7 @@
 		fz->fz_nent++;
 	rt_cache_flush(-1);
 
-	rtmsg_fib(RTM_NEWROUTE, f, new_fa, z, tb->tb_id, n, req);
+	rtmsg_fib(RTM_NEWROUTE, key, new_fa, z, tb->tb_id, n, req);
 	return 0;
 
 out_free_new_fa:
@@ -631,7 +626,7 @@
 		int kill_fn;
 
 		fa = fa_to_delete;
-		rtmsg_fib(RTM_DELROUTE, f, fa, z, tb->tb_id, n, req);
+		rtmsg_fib(RTM_DELROUTE, key, fa, z, tb->tb_id, n, req);
 
 		kill_fn = 0;
 		write_lock_bh(&fib_hash_lock);
@@ -794,33 +789,6 @@
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
diff -Nru a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
--- a/net/ipv4/fib_lookup.h	2004-11-30 21:37:44 -08:00
+++ b/net/ipv4/fib_lookup.h	2004-11-30 21:37:44 -08:00
@@ -30,5 +30,8 @@
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			 u8 tb_id, u8 type, u8 scope, void *dst,
 			 int dst_len, u8 tos, struct fib_info *fi);
+extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
+		      int z, int tb_id,
+		      struct nlmsghdr *n, struct netlink_skb_parms *req);
 
 #endif /* _FIB_LOOKUP_H */
diff -Nru a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
--- a/net/ipv4/fib_semantics.c	2004-11-30 21:37:44 -08:00
+++ b/net/ipv4/fib_semantics.c	2004-11-30 21:37:44 -08:00
@@ -270,6 +270,33 @@
 	return -1;
 }
 
+void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
+	       int z, int tb_id,
+	       struct nlmsghdr *n, struct netlink_skb_parms *req)
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
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
