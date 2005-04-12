From: itkes@imec.msu.ru
Subject: A bug in the Kernel?
Date: Tue, 12 Apr 2005 16:31:41 +0400 (MSD)
Message-ID: <3558.193.232.114.87.1113309101.squirrel@mx>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20050412163141_77866"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_20050412163141_77866
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

Hello.

I think, I have found a bug in the Linux Kernel. It is caused by working
with lists by indexes in such operstions as routing tables dump and
routing rules dump (functions fib_rules_dump in fib_rules.c and a few dump
functions in fib_hash.c). If some elements are removed form the list, the
index may identify not the element it identified earlier. As a result,
there may happen that an application that requested the routes or rules
dump, will not receive the entire table. There is how
to make an application to lose some rules.

1. Add 150 rules to kernel table.
2. Application A sends an RTM_GETRULE message with flag NLM_F_DUMP. The
kernel puts first 107 rules to the buffer.
3. Application B deletes first 20 rules.
4. Application A receives the first couple of data from kernel. The kernel
puts next couple of rules to the buffer, begining from 108-th rule, that
was 128-th earlier.
As a result, 20 rules had not been sent to the application, without being
deleted or modified during the dump operation.

Routes can be lost, too, if you add certain 5000 routes, request their
dump and remove 1000 from them during the dump.

In the patch (against kernel 2.6.11) attached, I have corrected these
bugs. In the modified kernel, both dumps of routes and routing rules seems
to work properly. But, I think, there can be other bugs similar to this in
other dump operations.

Alex Itkes (Moscow State University).

P.S. I am awfully sorry if you got this message more then once. There were
some problems with my mailbox so my previous message or your answer might
be lost.

------=_20050412163141_77866
Content-Type: text/plain; name="patch-2.6.11-nl01"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="patch-2.6.11-nl01"

diff -urN linux-2.6.11/include/linux/netlink.h linux-2.6.11-nl01/include/linux/netlink.h
--- linux-2.6.11/include/linux/netlink.h	2005-03-02 23:04:19.000000000 +0300
+++ linux-2.6.11-nl01/include/linux/netlink.h	2005-03-08 15:03:11.000000000 +0300
@@ -145,9 +145,11 @@
 	int		(*dump)(struct sk_buff * skb, struct netlink_callback *cb);
 	int		(*done)(struct netlink_callback *cb);
 	int		family;
-	long		args[4];
+	long		args[5];
 };
 
+#define NLCB_ZERO(cb_,k_)	memset((cb_)->args+(k_),0,sizeof((cb_)->args)-(k_)*sizeof((cb_)->args[0]))
+
 struct netlink_notify
 {
 	int pid;
diff -urN linux-2.6.11/net/core/rtnetlink.c linux-2.6.11-nl01/net/core/rtnetlink.c
--- linux-2.6.11/net/core/rtnetlink.c	2005-03-02 23:04:21.000000000 +0300
+++ linux-2.6.11-nl01/net/core/rtnetlink.c	2005-03-08 17:27:28.000000000 +0300
@@ -425,7 +425,7 @@
 		    rtnetlink_links[idx][type].dumpit == NULL)
 			continue;
 		if (idx > s_idx)
-			memset(&cb->args[0], 0, sizeof(cb->args));
+		    NLCB_ZERO(cb,0);
 		if (rtnetlink_links[idx][type].dumpit(skb, cb))
 			break;
 	}
diff -urN linux-2.6.11/net/ipv4/fib_frontend.c linux-2.6.11-nl01/net/ipv4/fib_frontend.c
--- linux-2.6.11/net/ipv4/fib_frontend.c	2005-03-02 23:04:21.000000000 +0300
+++ linux-2.6.11-nl01/net/ipv4/fib_frontend.c	2005-03-08 17:33:40.000000000 +0300
@@ -347,7 +347,7 @@
 	for (t=s_t; t<=RT_TABLE_MAX; t++) {
 		if (t < s_t) continue;
 		if (t > s_t)
-			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
+		    NLCB_ZERO(cb,1);
 		if ((tb = fib_get_table(t))==NULL)
 			continue;
 		if (tb->tb_dump(tb, skb, cb) < 0) 
diff -urN linux-2.6.11/net/ipv4/fib_hash.c linux-2.6.11-nl01/net/ipv4/fib_hash.c
--- linux-2.6.11/net/ipv4/fib_hash.c	2005-03-02 23:04:21.000000000 +0300
+++ linux-2.6.11-nl01/net/ipv4/fib_hash.c	2005-03-08 17:37:28.000000000 +0300
@@ -52,6 +52,9 @@
 	struct hlist_node	fn_hash;
 	struct list_head	fn_alias;
 	u32			fn_key;
+	
+	u32			fn_nl_links;
+	u8			fn_nl_dead;
 };
 
 struct fn_zone {
@@ -256,7 +259,7 @@
 
 		head = &fz->fz_hash[fn_hash(k, fz)];
 		hlist_for_each_entry(f, node, head, fn_hash) {
-			if (f->fn_key != k)
+			if (f->fn_key != k || f->fn_nl_dead)
 				continue;
 
 			err = fib_semantic_match(&f->fn_alias,
@@ -296,8 +299,14 @@
 	hlist_for_each_entry(f, node, &fz->fz_hash[0], fn_hash) {
 		struct fib_alias *fa;
 
+		if(f->fn_nl_dead){
+		    continue;
+		};
 		list_for_each_entry(fa, &f->fn_alias, fa_list) {
 			struct fib_info *next_fi = fa->fa_info;
+			if (fa->fa_nl_dead){
+			    continue;
+			};
 
 			if (fa->fa_scope != res->scope ||
 			    fa->fa_type != RTN_UNICAST)
@@ -497,6 +506,8 @@
 		INIT_HLIST_NODE(&new_f->fn_hash);
 		INIT_LIST_HEAD(&new_f->fn_alias);
 		new_f->fn_key = key;
+		new_f->fn_nl_links=0;
+		new_f->fn_nl_dead=0;
 		f = new_f;
 	}
 
@@ -506,6 +517,8 @@
 	new_fa->fa_scope = r->rtm_scope;
 	new_fa->fa_state = 0;
 
+	new_fa->fa_nl_links=0;
+	new_fa->fa_nl_dead=0;
 	/*
 	 * Insert new entry to the list.
 	 */
@@ -591,8 +604,17 @@
 		int kill_fn;
 
 		fa = fa_to_delete;
+		if(fa->fa_nl_dead){
+		    tb->tb_flush(tb);
+		    return -ESRCH;
+		};
 		rtmsg_fib(RTM_DELROUTE, key, fa, z, tb->tb_id, n, req);
-
+		
+		if(fa->fa_nl_links){
+		    fa->fa_nl_dead=1;
+		    tb->tb_flush(tb);
+		    return 0;
+		};
 		kill_fn = 0;
 		write_lock_bh(&fib_hash_lock);
 		list_del(&fa->fa_list);
@@ -630,7 +652,7 @@
 		list_for_each_entry_safe(fa, fa_node, &f->fn_alias, fa_list) {
 			struct fib_info *fi = fa->fa_info;
 
-			if (fi && (fi->fib_flags&RTNH_F_DEAD)) {
+			if ((fi && (fi->fib_flags&RTNH_F_DEAD))||(fa->fa_nl_dead&&(fa->fa_nl_links==0))) {
 				write_lock_bh(&fib_hash_lock);
 				list_del(&fa->fa_list);
 				if (list_empty(&f->fn_alias)) {
@@ -675,17 +697,42 @@
 {
 	struct hlist_node *node;
 	struct fib_node *f;
-	int i, s_i;
-
-	s_i = cb->args[3];
-	i = 0;
+	int flag1=0;
+	int flag2=0;
+	
+	if(cb->args[3]==0){
+	    flag1=1;
+	};
 	hlist_for_each_entry(f, node, head, fn_hash) {
 		struct fib_alias *fa;
 
+		if(flag1==0){
+		    if((long)(f)==cb->args[3]){
+			--(f->fn_nl_links);
+			flag1=1;
+		    }else{
+			continue;
+		    };
+		};
+		if(cb->args[4]==0){
+		    flag2=1;
+		};
+		if(f->fn_nl_dead){
+		    continue;
+		};
 		list_for_each_entry(fa, &f->fn_alias, fa_list) {
-			if (i < s_i)
-				goto next;
 
+			if(flag2==0){
+		            if((long)(fa)==cb->args[4]){
+				--(fa->fa_nl_links);
+				flag2=1;
+			    }else{
+				continue;
+			    };
+			};
+			if(fa->fa_nl_dead){
+			    continue;
+			};
 			if (fib_dump_info(skb, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq,
 					  RTM_NEWROUTE,
@@ -696,14 +743,16 @@
 					  fz->fz_order,
 					  fa->fa_tos,
 					  fa->fa_info) < 0) {
-				cb->args[3] = i;
+				++(fa->fa_nl_links);
+				++(f->fn_nl_links);
+				cb->args[4]=(long)(fa);
+				cb->args[3]=(long)(f);
 				return -1;
 			}
-		next:
-			i++;
 		}
 	}
-	cb->args[3] = i;
+	cb->args[4]=0;
+	cb->args[3]=0;
 	return skb->len;
 }
 
@@ -718,8 +767,7 @@
 	for (h=0; h < fz->fz_divisor; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
-			memset(&cb->args[3], 0,
-			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
+			NLCB_ZERO(cb,3);
 		if (fz->fz_hash == NULL ||
 		    hlist_empty(&fz->fz_hash[h]))
 			continue;
@@ -734,25 +782,27 @@
 
 static int fn_hash_dump(struct fib_table *tb, struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int m, s_m;
 	struct fn_zone *fz;
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
 
-	s_m = cb->args[1];
 	read_lock(&fib_hash_lock);
-	for (fz = table->fn_zone_list, m=0; fz; fz = fz->fz_next, m++) {
-		if (m < s_m) continue;
-		if (m > s_m)
-			memset(&cb->args[2], 0,
-			       sizeof(cb->args) - 2*sizeof(cb->args[0]));
+	if(cb->args[1]){
+	    fz=(struct fn_zone*)(cb->args[1]);
+	}else{
+	    fz=table->fn_zone_list;
+	};
+	for (; fz; fz = fz->fz_next) {
+		if((long)(fz)!=cb->args[1]){
+		    NLCB_ZERO(cb,2);
+		};
 		if (fn_hash_dump_zone(skb, cb, tb, fz) < 0) {
-			cb->args[1] = m;
+			cb->args[1] = (long)(fz);
 			read_unlock(&fib_hash_lock);
 			return -1;
 		}
 	}
 	read_unlock(&fib_hash_lock);
-	cb->args[1] = m;
+	cb->args[1] = 0;
 	return skb->len;
 }
 
diff -urN linux-2.6.11/net/ipv4/fib_lookup.h linux-2.6.11-nl01/net/ipv4/fib_lookup.h
--- linux-2.6.11/net/ipv4/fib_lookup.h	2005-03-02 23:04:21.000000000 +0300
+++ linux-2.6.11-nl01/net/ipv4/fib_lookup.h	2005-03-08 12:51:36.000000000 +0300
@@ -12,6 +12,9 @@
 	u8			fa_type;
 	u8			fa_scope;
 	u8			fa_state;
+	
+	u32			fa_nl_links;
+	u8			fa_nl_dead;
 };
 
 #define FA_S_ACCESSED	0x01
diff -urN linux-2.6.11/net/ipv4/fib_rules.c linux-2.6.11-nl01/net/ipv4/fib_rules.c
--- linux-2.6.11/net/ipv4/fib_rules.c	2005-03-02 23:04:21.000000000 +0300
+++ linux-2.6.11-nl01/net/ipv4/fib_rules.c	2005-03-08 17:33:25.000000000 +0300
@@ -74,6 +74,9 @@
 #endif
 	char		r_ifname[IFNAMSIZ];
 	int		r_dead;
+	
+	u32		r_nl_links;
+	u8		r_nl_dead;
 };
 
 static struct fib_rule default_rule = {
@@ -101,6 +104,28 @@
 static struct fib_rule *fib_rules = &local_rule;
 static DEFINE_RWLOCK(fib_rules_lock);
 
+static void nl_rules_flush(void)
+{
+	struct fib_rule *r, **rp;
+
+	for(rp=&fib_rules;(r=*rp)!=NULL;rp=&r->r_next){
+	    next:;
+	    if(r->r_nl_dead&&(r->r_nl_links==0)){
+		write_lock_bh(&fib_rules_lock);
+		*rp = r->r_next;
+		r->r_dead = 1;
+		write_unlock_bh(&fib_rules_lock);
+		fib_rule_put(r);
+		r=*rp;
+		if(r==0){
+		    return;
+		}else{
+        	    goto next;
+		};
+	    };
+	};
+}
+
 int inet_rtm_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct rtattr **rta = arg;
@@ -121,10 +146,18 @@
 		    (!rta[RTA_PRIORITY-1] || memcmp(RTA_DATA(rta[RTA_PRIORITY-1]), &r->r_preference, 4) == 0) &&
 		    (!rta[RTA_IIF-1] || rtattr_strcmp(rta[RTA_IIF-1], r->r_ifname) == 0) &&
 		    (!rtm->rtm_table || (r && rtm->rtm_table == r->r_table))) {
+			if(r->r_nl_dead==1){
+			    nl_rules_flush();
+			    break;
+			};
 			err = -EPERM;
 			if (r == &local_rule)
 				break;
-
+			if(r->r_nl_links!=0){
+			    r->r_nl_dead=1;
+			    nl_rules_flush();
+			    return 0;
+			};
 			write_lock_bh(&fib_rules_lock);
 			*rp = r->r_next;
 			r->r_dead = 1;
@@ -198,6 +231,8 @@
 	new_r->r_srcmask = inet_make_mask(rtm->rtm_src_len);
 	new_r->r_dstmask = inet_make_mask(rtm->rtm_dst_len);
 	new_r->r_tos = rtm->rtm_tos;
+	new_r->r_nl_links=0;
+	new_r->r_nl_dead=0;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	if (rta[RTA_PROTOINFO-1])
 		memcpy(&new_r->r_fwmark, RTA_DATA(rta[RTA_PROTOINFO-1]), 4);
@@ -293,6 +328,9 @@
 	NIPQUAD(flp->fl4_dst), NIPQUAD(flp->fl4_src));
 	read_lock(&fib_rules_lock);
 	for (r = fib_rules; r; r=r->r_next) {
+		if(r->r_nl_dead){
+		    continue;
+		};
 		if (((saddr^r->r_src) & r->r_srcmask) ||
 		    ((daddr^r->r_dst) & r->r_dstmask) ||
 		    (r->r_tos && r->r_tos != flp->fl4_tos) ||
@@ -414,19 +452,30 @@
 
 int inet_dump_rules(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx;
-	int s_idx = cb->args[0];
 	struct fib_rule *r;
-
+	
+	if(cb->args[0]==(-1)){
+	    return 0;
+	};
 	read_lock(&fib_rules_lock);
-	for (r=fib_rules, idx=0; r; r = r->r_next, idx++) {
-		if (idx < s_idx)
-			continue;
-		if (inet_fill_rule(skb, r, cb) < 0)
-			break;
+	if(cb->args[0]){
+	    r=(struct fib_rule*)(cb->args[0]);
+	    --(r->r_nl_links);
+	}else{
+	    r=fib_rules;
+	};
+	for (; r; r = r->r_next) {
+		if(r->r_nl_dead){
+		    continue;
+		};
+		if (inet_fill_rule(skb, r, cb) < 0){
+			++(r->r_nl_links);
+			cb->args[0]=(long)(r);
+			return skb->len;
+		};
 	}
+	cb->args[0]=(-1);
 	read_unlock(&fib_rules_lock);
-	cb->args[0] = idx;
 
 	return skb->len;
 }
------=_20050412163141_77866--
