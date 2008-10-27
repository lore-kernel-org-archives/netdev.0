From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 04/09]IPtablestng/KernelSpace - create tuple classifier
Date: Mon, 27 Oct 2008 08:20:50 +0330 (IRST)
Message-ID: <20081027045050.A14A7C6408C@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

create a simple classifier named 'tuple'

this classifier uses Source&Destination addresses for packet classification. he uses hash tables base on their addresses and their masks for rules storage/management. 
this classifier is an example for implementing new classifiers. this patch creates new files named 'ipc_tuple.c' and 'ipc_tuple.h'.
'ipc_' prefix defines a classifier for ipv4 and also 'ip6c_' for ipv6.

diff --git a/net/ipv4/netfilter/ipc_tuple.c b/net/ipv4/netfilter/ipc_tuple.c
new file mode 100644
index 0000000..27ea5df
--- /dev/null
+++ b/net/ipv4/netfilter/ipc_tuple.c
@@ -0,0 +1,300 @@
+/**
+ *	this is a simple and lieght implementation of tuple classification
+ *	algoritm. ( don't use INVERSE FLAGs )
+ */
+
+/**
+ *	Copyright (C) 2005-2008  hamid jafarian (hm.t.)
+ *
+ * 	This program is free software; you can redistribute it and/or modify
+ * 	it under the terms of the GNU General Public License version 2 as
+ * 	published by the Free Software Foundation.
+ */
+
+
+
+#include <linux/slab.h>
+#include <linux/in.h>
+
+#define ASSERT_READ_LOCK(x)
+#define ASSERT_WRITE_LOCK(x)
+//#include <linux/netfilter_ipv4/listhelp.h>
+#include <linux/netfilter_ipv4/ipc_tuple.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Hamid Jafarian hm.t.");
+MODULE_DESCRIPTION("Packet Tables Code - IP*tables-tng: Tuple Classifier");
+
+#define illegal_inverse_flags (				\
+		IPT_INV_VIA_IN | IPT_INV_VIA_OUT |	\
+		IPT_INV_SRCIP  | IPT_INV_DSTIP   |	\
+		IPT_INV_PROTO )
+
+#define ht_info(str, args...)
+#if 0
+#define ht_info(str, args...) 	\
+	printk(KERN_INFO"%s: "str"\n",__FUNCTION__, ## args )
+#endif
+
+/**
+ * Tuple Classifier Implemetation
+ */
+static struct kmem_cache *tuple_entry_cache = NULL;
+
+#define do_hash(s, d) \
+	((s + d) % tspace_htable_size)
+
+/**
+ * initialize the classifier
+ */
+void * tuple_init(struct pktt_chain *chain){
+	struct tuple_context *tc = 
+			kmalloc(sizeof(struct tuple_context), GFP_KERNEL);
+
+	if(tc == NULL) return NULL;
+
+	tc->chain = chain;
+	INIT_LIST_HEAD(&tc->tuple_spaces);
+	
+	return tc;
+}
+
+static inline int __cmp_find(const struct tuple_space *ts, 
+					struct in_addr *smsk,
+					struct in_addr *dmsk){
+	if( (ts->id.smsk.s_addr == smsk->s_addr) && 
+			(ts->id.dmsk.s_addr == dmsk->s_addr) ) return 1;
+	return 0;
+}
+
+int tuple_add_entry(void *t_context, struct pktt_entry *e){
+	struct tuple_space *ts;
+	struct tuple_entry *te;
+	struct tuple_context *tc = t_context;
+	int h = do_hash( e->pkt_header.ip4.src.s_addr, 
+					e->pkt_header.ip4.dst.s_addr );
+	ht_info("adding entry with rank %i", e->rank);
+
+	if( e->pkt_header.ip4.invflags & illegal_inverse_flags ){
+		printk(KERN_ERR "tuple_classifier: bad rule.\n");
+		return -EINVAL;
+	}
+
+	list_for_each_entry(ts, &tc->tuple_spaces, list)
+		if(__cmp_find(ts, &e->pkt_header.ip4.smsk, &e->pkt_header.ip4.dmsk)) break;
+
+	if(&ts->list == &tc->tuple_spaces){
+		/* there is no space with this mask */
+		int i;
+		ts = kmalloc( sizeof(struct tuple_space), GFP_ATOMIC );
+		if(ts == NULL){ 
+			printk(KERN_ERR "tuple_classifier: can't get memory for new tuple space\n");
+			return -ENOMEM;
+		}
+
+		ht_info("new space with mask smsk:%d.%d.%d.%d dmsk:%d.%d.%d.%d",
+			NIPQUAD(e->pkt_header.ip4.smsk), NIPQUAD(e->pkt_header.ip4.dmsk));	
+
+		ts->id.smsk = e->pkt_header.ip4.smsk;
+		ts->id.dmsk = e->pkt_header.ip4.dmsk;
+
+		list_add(&ts->list, &tc->tuple_spaces);
+
+		for(i=0; i < tspace_htable_size; ++i){
+			INIT_LIST_HEAD(&ts->htable[i].list);
+		}
+	}
+
+	te = kmem_cache_alloc(tuple_entry_cache, GFP_ATOMIC);
+	if(te == NULL){ 
+		printk(KERN_ERR "tuple_classifer: can't get memory for new entry\n");
+		return -ENOMEM;
+	}
+
+	memcpy(&te->ip, &e->pkt_header.ip4, sizeof(struct ipt_ip));
+	te->rank = e->rank;
+
+	te->entry = e;
+
+	list_add(&te->list, &ts->htable[h].list);
+	/* using helper_data for call_back */
+	e->helper_data = (void *)te;
+
+	memset(&te->next_match, 0, sizeof(struct tuple_entry*) * NR_CPUS);
+
+	return 0;
+}
+
+
+/**
+ * delete an entry from the tuple space
+ */
+int tuple_del_entry(void *t_context, struct pktt_entry *e){
+	struct tuple_entry *te = e->helper_data;
+
+	list_del(&te->list);
+	kmem_cache_free(tuple_entry_cache, te);
+
+	return 0;
+}
+
+static inline int __cmp_FLUSH_SPACE(const struct tuple_space *_ts){
+	int i=0;
+	struct tuple_space *ts = (void *)_ts;
+
+	for(i=0; i< tspace_htable_size; ++i){
+		struct tuple_entry *te;
+		while(1){
+			if( list_empty(&ts->htable[i].list) ) break;
+
+			te = (void *) ts->htable[i].list.next;
+
+			list_del(&te->list);
+
+			ht_info("free entry with rank: %i", te->rank);
+
+			kmem_cache_free( tuple_entry_cache, te );
+		}
+	}
+	return 0;
+}
+
+void tuple_flush_entries(void *t_context){
+	struct tuple_space *ts;
+	struct tuple_context *tc = t_context;
+
+	list_for_each_entry(ts, &tc->tuple_spaces, list)
+					__cmp_FLUSH_SPACE(ts);
+
+	while( 1 ){
+		if( list_empty(&tc->tuple_spaces) ) break;
+
+		ts = (void *)tc->tuple_spaces.next;
+
+		list_del(&ts->list);
+
+		kfree( ts );
+	}
+}
+
+void tuple_destroy(void *t_context){
+	struct tuple_context *tc = t_context;
+
+	tuple_flush_entries( tc );
+	kfree( tc );
+}
+
+#define if_match(_if, _is, _mask)							\
+({	int _i=0, __ret=0;								\
+	if(_if)										\
+	  for(; _i<(IFNAMSIZ/sizeof(unsigned long)); ++_i)				\
+		__ret |= (((unsigned long *)_if->name)[_i] ^ ((unsigned long *)_is)[_i])\
+					& ((unsigned long *)_mask)[_i];			\
+	__ret == 0;									\
+})
+
+#define proto_match(_proto, _is)				\
+({	;							\
+	(_proto)? ((_proto) == (_is)): 1;			\
+})
+
+struct pktt_entry *tuple_first_match(void *t_context,
+				const struct sk_buff *skb,
+				const struct net_device *in_dev,
+				const struct net_device *out_dev){
+	struct tuple_context *tc = t_context;
+	struct tuple_entry *te;
+	struct tuple_space *ts;
+	struct tuple_entry *first = NULL;
+
+	list_for_each_entry(ts, &tc->tuple_spaces, list){
+		__u32 s = IP4_SRCIP(skb) & ts->id.smsk.s_addr;
+		__u32 d = IP4_DSTIP(skb) & ts->id.dmsk.s_addr;
+
+		list_for_each_entry(te, &ts->htable[do_hash(s , d)].list, list){
+			if( ( s == te->ip.src.s_addr ) && ( d == te->ip.dst.s_addr ) &&
+				/* protocol match ? */
+			    proto_match(te->ip.proto, IP4_PROTO(skb)) &&
+				/* input interface match ? */
+			    if_match(in_dev, te->ip.iniface, 
+						 te->ip.iniface_mask) &&
+				/* output interface match ? */
+			    if_match(out_dev, te->ip.outiface,
+						te->ip.outiface_mask) ){
+				/** this is a match */
+				struct tuple_entry *__i , *__j;
+				int cpu_id = smp_processor_id();
+
+				ht_info("entry with rank %i matched", te->rank);
+
+				__i = first; __j = NULL;
+				while( __i ){
+					if(__i->rank < te->rank){ 
+						__j = __i;
+						__i = __i ->next_match[cpu_id];
+						continue;
+					}
+					break;
+				}
+				te->next_match[cpu_id] = __i;
+				if( __i == first ) first = te;
+				if(__j) __j->next_match[cpu_id] = te;
+			}
+		}
+	}
+	return first? first->entry:NULL;
+}
+
+struct pktt_entry *tuple_next_match(void *t_context, 
+				const struct pktt_entry *prev,
+				const struct sk_buff *skb,
+				const struct net_device *in_dev,
+				const struct net_device *out_dev){
+	struct tuple_entry *curr = prev->helper_data;
+	struct tuple_entry *next = curr->next_match[smp_processor_id()];
+	curr->next_match[smp_processor_id()] = NULL;
+
+	return next? next->entry:NULL;
+}
+
+
+static struct pktt_classifier tuple = {
+	.name 		= "tuple",
+	.init		= tuple_init,
+	.flush		= tuple_flush_entries,
+	.destroy	= tuple_destroy,
+	.attach_rule	= tuple_add_entry,
+	.detach_rule	= tuple_del_entry,
+	.first_match	= tuple_first_match,
+	.next_match	= tuple_next_match,
+	.owner		= THIS_MODULE,
+	.family		= AF_INET,
+};
+
+int __init tuple_up(void){
+	if(pktt_register_classifier(&tuple) != 0){ 
+		printk(KERN_ERR"iptc_tuple: can't register classifier\n");
+		return -EFAULT;
+	}
+	
+	tuple_entry_cache = kmem_cache_create("tuple-classifier", 
+					sizeof(struct tuple_entry), 0, 
+					SLAB_HWCACHE_ALIGN, NULL);
+	if( tuple_entry_cache == NULL ){
+		printk(KERN_ERR"iptc_tuple: can'r create tuple-classifier cache\n");
+		pktt_unregister_classifier(&tuple);
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+void __exit tuple_down(void){
+	pktt_unregister_classifier(&tuple);
+	kmem_cache_destroy(tuple_entry_cache);
+}
+
+
+module_init(tuple_up);
+module_exit(tuple_down);
+
diff --git a/include/linux/netfilter_ipv4/ipc_tuple.h b/include/linux/netfilter_ipv4/ipc_tuple.h
new file mode 100644
index 0000000..44a6447
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipc_tuple.h
@@ -0,0 +1,69 @@
+
+#ifndef _IPC_TUPLE_H_
+#define _IPC_TUPLE_H_ 
+
+#include <linux/in.h>
+#include <linux/list.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+
+#define tspace_htable_size 1093
+
+/**
+ * ID for each tuple .. all of the entries in one tuple_space
+ * have the same source and detination masks.
+ */
+struct tuple_ID{
+        struct in_addr smsk;
+        struct in_addr dmsk;
+};
+                                                                                                                             
+/**
+ * entries in the hash table ..
+ */
+struct tuple_entry{
+        struct list_head list;
+        
+	/** 
+	 * for easy access..
+	 * using system cache..
+	 */
+        struct ipt_ip ip;
+	u_int32_t rank;
+        
+	struct pktt_entry *entry;
+
+	/**
+	 * Next entries that match an special packet..
+	 */ 
+	struct tuple_entry *next_match[NR_CPUS];
+};
+
+/**
+ * heads in the hash table .
+ */
+struct tuple_head{
+        struct list_head list;
+};
+                                                                                                                             
+/**
+ * for each combination of source and destination mask, we will have one
+ * tuple space ..
+ * it contains an id and a hash_table that defines the entries in
+ * the tuple space.
+ */
+struct tuple_space{
+        struct list_head list;
+                                                                                                                             
+        struct tuple_ID id;
+        struct tuple_head htable[tspace_htable_size];
+};
+
+
+struct tuple_context{
+        /* OWNER */
+        struct pktt_chain *chain;
+        struct list_head tuple_spaces;
+};
+
+#endif

