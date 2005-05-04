From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: (diet-)FIB alternative fib_hlist.c
Date: Wed, 4 May 2005 18:10:20 +0200
Message-ID: <17016.62444.34282.625407@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Jens.Laas@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

fib_hlist is the smallest and simpliest routing algo we could think of
it's just a sorted (h)list.

routing (FIB lookup) performance. dst hash is not used.

    fib_hlist   fib_hash  test        routing table size 
    -----------------------------------------------------
    444 kpps    433 kpps  Single flow. local=19/main=5 entries
    433 kpps    431 kpps  rDoS.        local=19/main=5
    0.2 kpps    198 kpps  rDoS         local=19/main=123946

As seen fib_hlist is catastrophe for large routing tables as expected but 
performs surprisingly well for ordinary routing tables so it should be 
fine for most hosts and servers. The patch has config option to select FIB.

Probably we soon want to specify differnt lookup schemes for different 
tables say for local table fib_hash or fib_hlist. While for large main table
fib_hash2/fib_trie would be better option.

Cheers.
					--ro


--- net/ipv4/Makefile.orig	2005-04-15 13:42:12.000000000 +0200
+++ net/ipv4/Makefile	2005-05-04 16:24:27.000000000 +0200
@@ -7,8 +7,10 @@
 	     ip_output.o ip_sockglue.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o tcp_minisocks.o \
 	     datagram.o raw.o udp.o arp.o icmp.o devinet.o af_inet.o igmp.o \
-	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o fib_hash.o
+	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o
 
+obj-$(CONFIG_IP_FIB_HASH) += fib_hash.o
+obj-$(CONFIG_IP_FIB_HLIST) += fib_hlist.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
--- net/ipv4/Kconfig.orig	2005-04-15 13:41:52.000000000 +0200
+++ net/ipv4/Kconfig	2005-05-04 16:23:58.000000000 +0200
@@ -1,6 +1,27 @@
 #
 # IP configuration
 #
+choice 
+	prompt "Choose IP: FIB lookup""
+	depends on INET
+	default IP_FIB_HASH
+
+config IP_FIB_HASH
+	bool "FIB_HASH"
+	---help---
+	Current FIB is very proven and good enough for most users.
+
+config IP_FIB_HLIST
+	bool "FIB_HLIST"
+	depends on INET && EXPERIMENTAL	
+	---help---
+
+	Use new very simple and minimalistic lookup algorithm. It should
+	only be used for small routing tables. Performance is equal to
+	FIB_HASH with small tables but with less memory use.
+
+endchoice
+
 config IP_MULTICAST
 	bool "IP: multicasting"
 	depends on INET
--- /dev/null	2005-04-14 15:05:36.930846264 +0200
+++ net/ipv4/fib_hlist.c	2005-05-03 20:07:24.000000000 +0200
@@ -0,0 +1,719 @@
+/*
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation; either version
+ *   2 of the License, or (at your option) any later version.
+ *
+ *   Robert Olsson <robert.olsson@its.uu.se> Uppsala Universitet
+ *     & Swedish University of Agricultural Sciences.
+ *
+ *   Jens Laas <jens.laas@data.slu.se> Swedish University of 
+ *     Agricultural Sciences.
+ * 
+ *   Hans Liss <hans.liss@its.uu.se>  Uppsala Universitet
+ *
+ * Code from fib_hash has been reused which includes the following header:
+ *
+ * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+
+/*
+ * An alternative FIB for applications with small routing table
+ * The simplest and smallest routing algo eveer all routes is keept
+ * in a single (h)list sorted by prefix length.
+ *
+ */
+
+#include <linux/config.h>
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/errno.h>
+#include <linux/in.h>
+#include <linux/inet.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <linux/netlink.h>
+#include <linux/init.h>
+#include <linux/rcupdate.h>
+#include <linux/vmalloc.h>
+#include <linux/list.h>
+#include <net/ip.h>
+#include <net/protocol.h>
+#include <net/route.h>
+#include <net/tcp.h>
+#include <net/sock.h>
+#include <net/ip_fib.h>
+#include "fib_lookup.h"
+
+#define VERSION "0.04"
+
+typedef unsigned int t_key;
+
+struct fib_hlist_info {
+	struct hlist_node hlist;
+	u32 plen;
+	u32 pfx;
+	struct list_head falh;
+};
+
+struct fib_hlist_table {
+	struct hlist_head list;
+	rwlock_t lock;
+};
+
+extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa, int z, int tb_id,
+               struct nlmsghdr *n, struct netlink_skb_parms *req);
+
+extern struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
+extern int fib_detect_death(struct fib_info *fi, int order,
+                            struct fib_info **last_resort, int *last_idx, int *dflt);
+
+static int debug = 0;
+static kmem_cache_t *fn_alias_kmem;
+static kmem_cache_t *fn_hlist_kmem;
+
+static inline void fn_free_node(struct fib_hlist_info * f)
+{
+	kmem_cache_free(fn_hlist_kmem, f);
+}
+
+/* Candiate for fib_semantics */
+
+static void fn_free_alias(struct fib_alias *fa)
+{
+	fib_release_info(fa->fa_info);
+	kmem_cache_free(fn_alias_kmem, fa);
+}
+
+static struct fib_hlist_info *fib_find_node(struct hlist_head *head, u32 key, int plen)
+{
+	struct hlist_node *node;
+	struct fib_hlist_info *fhi;
+
+	hlist_for_each_entry(fhi, node, head, hlist) {
+		  
+		if ( fhi->plen == plen && fhi->pfx == key )
+			return fhi;
+	}
+	return NULL;
+}
+
+static void fib_insert_node(struct hlist_head *head, struct fib_hlist_info *new)
+{
+	struct fib_hlist_info *fhi=NULL, *last=NULL;
+	struct hlist_node *node, *tmp;
+	
+	if(hlist_empty(head))
+		hlist_add_head(&new->hlist, head);
+	else {
+		hlist_for_each_entry_safe(fhi, node, tmp, head, hlist) {
+			
+			if (new->plen > fhi->plen) 
+				break;
+			
+			last = fhi;
+		}
+		if(last) 
+			hlist_add_after(&last->hlist, &new->hlist);
+		else 
+			hlist_add_before(&new->hlist, &fhi->hlist);
+	}
+}
+
+static int
+fn_hlist_insert(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
+	       struct nlmsghdr *nlhdr, struct netlink_skb_parms *req)
+{
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+	int plen = r->rtm_dst_len;
+	int type = r->rtm_type;
+	u8 tos = r->rtm_tos;
+	u32 key, mask;
+	int err = 0;
+	struct fib_alias *fa=NULL, *new_fa;
+	struct list_head *fa_head=NULL;
+	struct fib_info *fi;
+	struct fib_hlist_info *fhi=NULL, *new_fhi;
+
+	if (plen > 32)
+		return -EINVAL;
+
+	key = 0;
+	if (rta->rta_dst) 
+		memcpy(&key, rta->rta_dst, 4);
+
+	key = ntohl(key);
+	mask =  ntohl( inet_make_mask(plen) );
+
+	if(key & ~mask)
+		return -EINVAL;
+
+	key = key & mask;
+
+	if(debug) 
+		printk("fn_hlist_insert id=%d %08x/%d\n", tb->tb_id, key, plen);
+
+	if ((fi = fib_create_info(r, rta, nlhdr, &err)) == NULL)
+		return err;
+
+	fhi = fib_find_node(&t->list, key, plen);
+
+	if (!fhi)
+		fa = NULL;
+	else {
+		fa_head = &fhi->falh;
+		fa = fib_find_alias(fa_head, tos, fi->fib_priority);
+	}
+
+	/* Now fa, if non-NULL, points to the first fib alias
+	 * with the same keys [prefix,tos,priority], if such key already
+	 * exists or to the node before which we will insert new one.
+	 *
+	 * If fa is NULL, we will need to allocate a new one and
+	 * insert to the head of f.
+	 *
+	 * If f is NULL, no fib node matched the destination key
+	 * and we need to allocate a new one of those as well.
+	 */
+
+	if (fa &&
+	    fa->fa_info->fib_priority == fi->fib_priority) {
+		struct fib_alias *fa_orig;
+
+		err = -EEXIST;
+		if (nlhdr->nlmsg_flags & NLM_F_EXCL)
+			goto out;
+
+		if (nlhdr->nlmsg_flags & NLM_F_REPLACE) {
+			struct fib_info *fi_drop;
+			u8 state;
+
+			write_lock_bh(&t->lock);
+			fi_drop = fa->fa_info;
+			fa->fa_info = fi;
+			fa->fa_type = type;
+			fa->fa_scope = r->rtm_scope;
+			state = fa->fa_state;
+			fa->fa_state &= ~FA_S_ACCESSED;
+			write_unlock_bh(&t->lock);
+
+			fib_release_info(fi_drop);
+			if (state & FA_S_ACCESSED)
+				rt_cache_flush(-1);
+			return 0;
+		}
+
+		/* Error if we find a perfect match which
+		 * uses the same scope, type, and nexthop
+		 * information.
+		 */
+		fa_orig = fa;
+		list_for_each_entry(fa, fa_orig->fa_list.prev, fa_list) {
+			if (fa->fa_tos != tos)
+				break;
+			if (fa->fa_info->fib_priority != fi->fib_priority)
+				break;
+			if (fa->fa_type == type &&
+			    fa->fa_scope == r->rtm_scope &&
+			    fa->fa_info == fi)
+				goto out;
+		}
+		if (!(nlhdr->nlmsg_flags & NLM_F_APPEND))
+			fa = fa_orig;
+	}
+
+	err = -ENOENT;
+	if (!(nlhdr->nlmsg_flags&NLM_F_CREATE))
+		goto out;
+
+	err = -ENOBUFS;
+	new_fa = kmem_cache_alloc(fn_alias_kmem, SLAB_KERNEL);
+	if (new_fa == NULL)
+		goto out;
+
+	new_fa->fa_info = fi;
+	new_fa->fa_tos = tos;
+	new_fa->fa_type = type;
+	new_fa->fa_scope = r->rtm_scope;
+	new_fa->fa_state = 0;
+
+	new_fhi = NULL;
+	if (!fhi) {
+		new_fhi = kmem_cache_alloc(fn_hlist_kmem, SLAB_KERNEL);
+		if(!new_fhi)
+		  goto out_free_new_fa;
+	
+		new_fhi->plen = plen;
+		new_fhi->pfx = key;
+
+		INIT_LIST_HEAD(&new_fhi->falh);
+		fa_head = &new_fhi->falh;
+	}
+
+	/*
+	 * Insert new entry to the list.
+	 */
+
+      	write_lock_bh(&t->lock);
+	if(new_fhi)
+		fib_insert_node(&t->list, new_fhi);
+
+	list_add_tail(&new_fa->fa_list,
+		 (fa ? &fa->fa_list : fa_head));
+	write_unlock_bh(&t->lock);
+
+	rt_cache_flush(-1);
+	rtmsg_fib(RTM_NEWROUTE, key, new_fa, plen, tb->tb_id, nlhdr, req);
+	return 0;
+
+out_free_new_fa:
+	kmem_cache_free(fn_alias_kmem, new_fa);
+out:
+	fib_release_info(fi);
+	return err;
+}
+
+static int
+fn_hlist_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+{
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+	t_key key;
+	u32 mask;
+	int ret;
+	struct fib_hlist_info *fhi = NULL;
+	struct hlist_node *node;
+
+	key = ntohl( flp->fl4_dst );
+
+	read_lock(&t->lock);
+	hlist_for_each_entry(fhi, node, &t->list, hlist) {
+
+		mask =  ntohl( inet_make_mask(fhi->plen) );
+
+		if (fhi->pfx == (key & mask)) {
+			ret = fib_semantic_match(&fhi->falh, flp, res, fhi->plen);
+
+			if(ret <= 0) 
+				goto found;
+		}
+	}
+	ret = 1;
+found:	
+	read_unlock(&t->lock);
+	return ret;
+}
+
+static int
+fn_hlist_delete(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
+	       struct nlmsghdr *nlhdr, struct netlink_skb_parms *req)
+{
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+	u32 key, mask;
+	int plen = r->rtm_dst_len;
+	u8 tos = r->rtm_tos;
+	int err = 0;
+	int kill_fn = 0;
+	struct fib_alias *fa, *fa_to_delete;
+	struct list_head *fa_head;
+	struct hlist_node *node;
+	struct fib_hlist_info *fhi = NULL;
+
+	if (plen > 32) 
+		return  -EINVAL;
+
+	key = 0;
+	if (rta->rta_dst) 
+		memcpy(&key, rta->rta_dst, 4);
+
+	key = ntohl(key);
+	mask =  ntohl( inet_make_mask(plen) );
+
+	if(key & ~mask)
+		return -EINVAL;
+
+	key = key & mask;
+
+	if(debug) 
+		printk("fn_hlist_delete id=%d %08x/%d\n", tb->tb_id, key, plen);
+
+	hlist_for_each_entry(fhi, node, &t->list, hlist) {
+		if (fhi->plen == plen && fhi->pfx == key ) {
+			fa = fib_find_alias(&fhi->falh, tos, 0);
+			if(fa) 
+				goto got_alias;
+		}
+	}
+	return  -ESRCH;
+
+got_alias:
+	fa_to_delete = NULL;
+	fa_head = fa->fa_list.prev;
+	list_for_each_entry(fa, fa_head, fa_list) {
+		struct fib_info *fi = fa->fa_info;
+
+		if (fa->fa_tos != tos)
+			break;
+
+		if ((!r->rtm_type ||
+		     fa->fa_type == r->rtm_type) &&
+		    (r->rtm_scope == RT_SCOPE_NOWHERE ||
+		     fa->fa_scope == r->rtm_scope) &&
+		    (!r->rtm_protocol ||
+		     fi->fib_protocol == r->rtm_protocol) &&
+		    fib_nh_match(r, nlhdr, rta, fi) == 0) {
+			fa_to_delete = fa;
+			break;
+		}
+	}
+
+	if (! fa_to_delete) 
+		return -ESRCH;
+
+	kill_fn = 0;
+	fa = fa_to_delete;
+	
+	rtmsg_fib(RTM_DELROUTE, key, fa, plen, tb->tb_id, nlhdr, req);
+	
+	write_lock_bh(&t->lock);
+	list_del(&fa->fa_list);
+	
+	/* Remove fib_hlist_info in case */
+	
+	if(list_empty(fa_head)) { 
+		hlist_del(&fhi->hlist);
+		kill_fn = 1;
+	}
+	write_unlock_bh(&t->lock);
+	
+	if (fa->fa_state & FA_S_ACCESSED)
+		rt_cache_flush(-1);
+	
+	fn_free_alias(fa);
+	
+	if (kill_fn) 
+		fn_free_node(fhi);
+
+	return err;
+}
+
+static int hlist_flush_list(struct fib_hlist_table *t, struct list_head *fah)
+{
+        struct list_head *head = fah;
+        struct fib_alias *fa, *fa_node;
+        int found = 0;
+
+        list_for_each_entry_safe(fa, fa_node, head, fa_list) {
+                struct fib_info *fi = fa->fa_info;
+                
+                if (fi && (fi->fib_flags&RTNH_F_DEAD)) {
+		  
+			write_lock_bh(&t->lock);
+                        list_del(&fa->fa_list);
+			write_unlock_bh(&t->lock);
+
+                        fn_free_alias(fa);
+                        found++;
+                }
+        }
+        return found;
+}
+
+static int fn_hlist_flush(struct fib_table *tb)
+{
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+	int found = 0;
+	struct hlist_head *bh;
+	struct hlist_node *node;
+	struct hlist_node *tmp;
+	struct fib_hlist_info *fhi;
+        int kill_f;
+
+	if(debug)
+		printk("fn_hlist_flush table=%d\n", tb->tb_id);
+
+	bh = &t->list;
+
+	hlist_for_each_entry_safe(fhi, node, tmp, bh, hlist) {
+		if(list_empty(&fhi->falh))
+			continue;
+		
+		found += hlist_flush_list(t, &fhi->falh);
+		
+		kill_f = 0;
+		write_lock_bh(&t->lock);
+		if(list_empty(&fhi->falh)) {
+			hlist_del(&fhi->hlist);
+			kill_f = 1;
+		}
+		write_unlock_bh(&t->lock);
+		
+		if(kill_f)
+			fn_free_node(fhi);
+	}
+
+	if(debug)
+		printk("fn_hlist_flush flushed=%d\n", found);
+
+	return found;
+}
+
+static int hlist_last_dflt=-1;
+
+static void
+fn_hlist_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+{
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+	int order, last_idx;
+	struct fib_info *fi = NULL;
+	struct fib_info *last_resort;
+	struct fib_alias *fa = NULL;
+	struct fib_hlist_info *fhi;
+
+	if(debug)
+		printk("fn_hlist_select_default\n");
+
+	fhi =  fib_find_node(&t->list, 0, 0);
+
+	if(!fhi) 
+		return;
+
+	if (list_empty(&fhi->falh))
+		return;
+
+	last_idx = -1;
+	last_resort = NULL;
+	order = -1;
+
+	list_for_each_entry(fa, &fhi->falh, fa_list) {
+		struct fib_info *next_fi = fa->fa_info;
+		
+		if (fa->fa_scope != res->scope ||
+		    fa->fa_type != RTN_UNICAST)
+			continue;
+		
+		if (next_fi->fib_priority > res->fi->fib_priority)
+			break;
+		if (!next_fi->fib_nh[0].nh_gw ||
+		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
+			continue;
+		fa->fa_state |= FA_S_ACCESSED;
+		
+		if (fi == NULL) {
+			if (next_fi != res->fi)
+				break;
+		} else if (!fib_detect_death(fi, order, &last_resort,
+					     &last_idx, &hlist_last_dflt)) {
+			if (res->fi)
+				fib_info_put(res->fi);
+			res->fi = fi;
+			atomic_inc(&fi->fib_clntref);
+			hlist_last_dflt = order;
+			goto out;
+		}
+		fi = next_fi;
+		order++;
+	}
+
+	if (order <= 0 || fi == NULL) {
+		hlist_last_dflt = -1;
+		goto out;
+	}
+
+	if (!fib_detect_death(fi, order, &last_resort, &last_idx, &hlist_last_dflt)) {
+		if (res->fi)
+			fib_info_put(res->fi);
+		res->fi = fi;
+		atomic_inc(&fi->fib_clntref);
+		hlist_last_dflt = order;
+		goto out;
+	}
+
+	if (last_idx >= 0) {
+		if (res->fi)
+			fib_info_put(res->fi);
+		res->fi = last_resort;
+		if (last_resort)
+			atomic_inc(&last_resort->fib_clntref);
+	}
+	hlist_last_dflt = last_idx;
+ out:;
+}
+
+static inline int fn_hlist_dump_fa(t_key key, int plen, struct list_head *fah, struct fib_table *tb,
+				   struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int i, s_i;
+	struct fib_alias *fa;
+	u32 xkey=htonl(key);
+	s_i=cb->args[3];
+	i = 0;
+
+	list_for_each_entry(fa, fah, fa_list) {
+
+		if (i < s_i)
+			goto next;
+
+		if (fa->fa_info->fib_nh == NULL)
+			goto next;
+
+		if (fa->fa_info == NULL)
+			goto next;
+
+		if (fib_dump_info(skb, NETLINK_CB(cb->skb).pid,
+				  cb->nlh->nlmsg_seq,
+				  RTM_NEWROUTE,
+				  tb->tb_id,
+				  fa->fa_type,
+				  fa->fa_scope,
+				  &xkey,
+				  plen,
+				  fa->fa_tos,
+				  fa->fa_info) < 0) {
+			cb->args[3] = i;
+			return -1;
+		}
+	next:
+		i++;
+	}
+	cb->args[3]=i;
+	return skb->len;
+}
+
+static inline int fn_hlist_dump_plen(int plen, struct fib_table *tb, 
+				     struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int s_i = cb->args[2];
+	int i = 0;
+	struct hlist_node *node;
+	struct fib_hlist_info *fhi;
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+	struct hlist_head *head;
+	
+	head = &t->list;
+
+	hlist_for_each_entry(fhi, node, head, hlist) {
+
+		if (i < s_i) 
+			goto next;
+
+		if (i > s_i)
+			memset(&cb->args[3], 0,
+			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
+
+		if (fhi->plen == plen) { 
+			
+			if (fn_hlist_dump_fa(fhi->pfx, fhi->plen, &fhi->falh, tb, skb, cb)<0) {
+				cb->args[2]=i;
+				return -1;
+			}
+		}
+	next:
+		i++;
+	}
+	cb->args[2]=i;
+	return skb->len;
+}
+
+static int fn_hlist_dump(struct fib_table *tb, struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int m, s_m;
+	s_m= cb->args[1];
+
+	for (m=s_m; m<=32; m++) {
+
+		if (m < s_m) continue;
+		if (m > s_m)
+			memset(&cb->args[2], 0,
+			       sizeof(cb->args) - 2*sizeof(cb->args[0]));
+
+		if (fn_hlist_dump_plen(32-m, tb, skb, cb)<0) {
+				cb->args[1] = m;
+				return -1;
+			}
+	}
+	cb->args[1] = m;
+	return skb->len;
+}
+
+void create(struct fib_table *tb)
+{
+	struct fib_hlist_table *t = (struct fib_hlist_table *) tb->tb_data;
+
+	INIT_HLIST_HEAD(&t->list);
+	
+        printk(KERN_INFO "IP: FIB_hlist vers %s routing table id=%d\n",
+	       VERSION, tb->tb_id);
+}
+
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+struct fib_table * fib_hash_init(int id)
+#else
+struct fib_table * __init fib_hash_init(int id)
+#endif
+{
+	struct fib_table *tb;
+	struct fib_hlist_table *t;
+
+	if (fn_alias_kmem == NULL)
+		fn_alias_kmem = kmem_cache_create("ip_fib_alias",
+						  sizeof(struct fib_alias),
+						  0, SLAB_HWCACHE_ALIGN,
+						  NULL, NULL);
+
+        if (fn_hlist_kmem == NULL)
+                fn_hlist_kmem = kmem_cache_create("ip_hlist_info",
+                                                 sizeof(struct fib_hlist_info),
+                                                 0, SLAB_HWCACHE_ALIGN,
+                                                 NULL, NULL);
+
+	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fib_hlist_table),
+		     GFP_KERNEL);
+
+	if (tb == NULL)
+		return NULL;
+
+	tb->tb_id = id;
+	tb->tb_lookup = fn_hlist_lookup;
+	tb->tb_insert = fn_hlist_insert;
+	tb->tb_delete = fn_hlist_delete;
+	tb->tb_flush = fn_hlist_flush;
+	tb->tb_select_default = fn_hlist_select_default;
+	tb->tb_dump = fn_hlist_dump;
+	memset(tb->tb_data, 0, sizeof(struct fib_hlist_table));
+
+	t = (struct fib_hlist_table *) tb->tb_data;
+
+	t->lock =  RW_LOCK_UNLOCKED;
+
+	create(tb);
+	return tb;
+}
+
+#ifdef CONFIG_PROC_FS
+
+int __init fib_proc_init(void)
+{
+	return 0;
+}
+
+void __init fib_proc_exit(void)
+{
+        proc_net_remove("route");
+}
+#endif /* CONFIG_PROC_FS */
+
