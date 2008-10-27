From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 03/09]IPtablestng/KernelSpace - create pkt_tables.c
Date: Mon, 27 Oct 2008 08:19:00 +0330 (IRST)
Message-ID: <20081027044900.930ECC6408B@host1.ystp.ac.ir>
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

create pkt-tables.c file: core of this new framework

this patch creates a new file named pkt_tables.c. the content of this file is the common framework for  tables/chains/rules management i.e. all of the ideas behind this new framwork are located in this file.
in this file you can find 'pktt_table_trigger' that is the replacement of 'ip*t_do_table' functions.

diff --git a/net/netfilter/pkt_tables.c b/net/netfilter/pkt_tables.c
new file mode 100644
index 0000000..89810c2
--- /dev/null
+++ b/net/netfilter/pkt_tables.c
@@ -0,0 +1,2203 @@
+/* Packet Tables Code
+ *
+ * Copyright (C) 2005-2008 Hamid Jafarian(hm.t.) <hamid.jafarian@gmail.com>
+ */
+#include <linux/kernel.h>
+#include <linux/net.h>
+#include <linux/seq_file.h>
+#include <linux/vmalloc.h>
+#include <linux/kmod.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/string.h>
+#include <linux/mutex.h>
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <asm/uaccess.h>
+#include <net/net_namespace.h>
+#include <linux/seq_file.h>
+#include <linux/fs.h>
+#include <net/ip.h>
+
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter/pkt_tables.h>
+#include <linux/netfilter_arp.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Hamid Jafarian hm.t.");
+MODULE_DESCRIPTION("Packet Tables Code - IP*tables-tng");
+
+extern struct xt_af *xt;
+
+extern const char *xt_prefix[NPROTO];
+
+/**
+ * reserved chain names for IP hooks
+ */
+static char *hook_names[NPROTO][NF_MAX_HOOKS]={
+        [AF_INET]	={	"PREROUTING",   /* NF_IP_PRE_ROUTING */
+        			"INPUT",        /* NF_IP_LOCAL_IN */
+        			"FORWARD",      /* NF_IP_FORWARD */
+        			"OUTPUT",       /* NF_IP_LOCAL_OUT */
+        			"POSTROUTING"   /* NF_IP_POST_ROUTING */
+			},
+	[AF_INET6]	={	"PREROUTING",	/* NF_IP6_PRE_ROUTING */
+        			"INPUT",        /* NF_IP6_LOCAL_IN */
+        			"FORWARD",      /* NF_IP6_FORWARD */
+        			"OUTPUT",       /* NF_IP6_LOCAL_OUT */
+        			"POSTROUTING"   /* NF_IP6_POST_ROUTING */
+			}
+};
+
+/**
+ * pktt_match_trigger - triggers the matches in the entry
+ * @m: pointer to match structure
+ * @skb: pointer to the socket buffer
+ * @in: input device
+ * @out: output interface
+ * @offset: offset of the network packet
+ * @protoff: offset of the transport layer protocol 
+ * @hotdrop: if be true means drop immediately
+ */
+static inline
+int pktt_match_trigger(struct xt_entry_match *m,
+			const struct sk_buff *skb,
+			const struct net_device *in,
+			const struct net_device *out,
+			int offset,
+			unsigned int protoff,
+			bool *hotdrop)
+{
+	
+	/* Stop iteration if it doesn't match */
+	if (!m->u.kernel.match->match(skb, in, out, m->u.kernel.match,
+					m->data, offset, protoff, hotdrop))
+		return 1;
+	else
+		return 0;
+}
+
+static inline unsigned int 
+pktt_entry_trigger(struct pktt_entry *e,
+			struct sk_buff *pskb,
+			unsigned int hook,
+			const struct net_device *in,
+			const struct net_device *out,
+			u_int16_t offset,
+			u_int16_t pkt_len,
+			u_int16_t protoff)
+{
+	struct xt_entry_target *t;
+	unsigned int verdict;
+	bool hotdrop =false;
+	int ret;
+	
+	pktt_info("entry with rank -%i- triggered", e->rank);
+	
+	switch(e->family){
+	case AF_INET:
+		ret = IP4_CHECK_FRAGMENT((e->pkt_header.ip4), offset);
+		if(ret != 0) return ret;
+		break;
+	case AF_INET6:
+	case NF_ARP:
+		break;	
+	}
+	
+	if(PKTT_ENTRY_MATCH_ITERATE(e, pktt_match_trigger, pskb, 
+					  in ,out, offset, protoff, &hotdrop) !=0){
+		/* it means : don't match packet */
+		verdict = NF_MAX_VERDICT +2;
+		goto GOVER;
+	}
+	
+	ADD_COUNTER(e->counters[smp_processor_id()], pkt_len, 1);
+
+	t= pktt_entry_get_target(e);
+	verdict= t->u.kernel.target->target( pskb, in, out, hook,
+					t->u.kernel.target, t->data);
+GOVER:
+	if( hotdrop ) return NF_DROP;
+	return verdict;
+}
+
+static inline unsigned int 
+pktt_chain_trigger(int who_am_i, 
+			struct pktt_chain *chain,
+			struct sk_buff *pskb,
+			unsigned int hook,
+			const struct net_device *in,
+			const struct net_device *out,
+			u_int16_t offset,
+			u_int16_t pkt_len,
+			u_int16_t protoff)
+{
+	unsigned int ret;
+	void *e=NULL;
+
+	pktt_info("chain -%s- triggered", chain->name);
+
+	/*
+		get the rules that match the packet from
+		the classifier.
+	*/
+	e = chain->classifier->first_match(chain->context,
+						pskb, in, out);
+	while( e != NULL ){
+		ret= pktt_entry_trigger(e, pskb, hook, in, out, 
+					offset, pkt_len, protoff);
+		switch( ret ){
+		case PKTT_RETURN:
+			/* IPT_RETURN in the root chains means using from
+			   Chain Policy .. |*/
+			if( who_am_i == 1 /* means: i am root*/)
+							return chain->policy;
+
+			/* else: We Are in a Called Chain .. return IPT_RETURN
+			   to Continue traversing rules in the Caller*/
+			return PKTT_RETURN;
+			break;
+
+		case PKTT_CONTINUE:
+		case NF_MAX_VERDICT +2:   /* e don't match packet completely. 
+						to now only the classifier
+						matched the packet.	
+						but one of the matches may	
+						deny him.
+					   */
+			//pktt_info("don't match rank=%li continue", e->rank);
+			/* 
+				go to the next match 
+			*/
+			e = chain->classifier->next_match(chain->context,
+						e, pskb, in, out);
+			break;
+
+		default:
+			return ret;
+		}
+	}
+	/* if we reach at the end, we should use chain policy */
+	return chain->policy;
+}
+
+/** 
+ * pktt_table_trigger - core function to search the rules
+ *
+ * Returns one of the generic firewall policies, like NF_ACCEPT. 
+ */
+unsigned int
+pktt_table_trigger(struct sk_buff *pskb,
+	     unsigned int hook,
+	     const struct net_device *in,
+	     const struct net_device *out,
+	     struct pktt_regtable *regtable)
+{
+	/* Initializing verdict to NF_DROP keeps gcc happy. */
+	unsigned int verdict = NF_DROP;
+	struct pkt_table *table = regtable->table;
+	u_int16_t offset, pkt_len, protoff;
+
+	//IP_NF_ASSERT( (table->valid_hooks) & (1 << hook) );
+
+	pktt_info("coming a packet from table=%s hook=%d chain=%s",
+			table->name, hook, table->hook_entry[hook]->name);
+	
+	switch(table->family){
+	case AF_INET:
+		offset = IP4_OFFSET(pskb);
+		pkt_len = IP4_TOTLEN(pskb);
+		protoff = IP4_PROTOFF(pskb);
+		break;
+	case AF_INET6:
+	case NF_ARP:
+		printk( KERN_ERR "pkt-table: bad table family\n");
+		return NF_DROP;
+		break;	
+	default:
+		printk( KERN_ERR "pkt-table: bad table family\n");
+		return NF_DROP;
+	}
+
+	read_lock_bh( &(table -> lock) );
+
+	verdict = pktt_chain_trigger( 1/* i am root */, table->hook_entry[hook],
+			pskb, hook, in, out, offset, pkt_len,protoff);
+
+	read_unlock_bh( &(table -> lock) );
+
+#ifdef DEBUG_ALLOW_ALL
+	return NF_ACCEPT;
+#else
+	/* in this level IPT_RETURN means NF_DROP */
+	if( verdict == PKTT_RETURN ) return NF_DROP;
+	return verdict;
+#endif
+}
+EXPORT_SYMBOL(pktt_table_trigger);
+
+/**
+ * pktt_chain_target_function - this is the 'target' function of the chains 'target' .
+ *
+ * ability to use from chains as target ..
+ * SEE: pktt_chain_init
+ */			
+static unsigned int 
+pktt_chain_target_function(struct sk_buff *pskb,
+			const struct net_device *in,
+			const struct net_device *out,
+			unsigned int hooknum,
+			const struct xt_target *target,
+			const void *targinfo){
+	unsigned long *_chain = ( unsigned long *)targinfo;
+	struct pktt_chain *chain = ( void *) (*_chain);
+	unsigned int ret;
+	u_int16_t offset, pkt_len, protoff;
+
+	pktt_info("chain -%s- called as a target", chain->name);
+
+	switch(chain->table->family){
+	case AF_INET:
+		offset = IP4_OFFSET(pskb);
+		pkt_len = IP4_TOTLEN(pskb);
+		protoff = IP4_PROTOFF(pskb);
+		break;
+	case AF_INET6:
+	case NF_ARP:
+		printk( KERN_ERR "pkt-table: bad table family\n");
+		return NF_DROP;
+		break;	
+	default:
+		printk( KERN_ERR "pkt-table: bad table family\n");
+		return NF_DROP;
+	}
+
+	ret = pktt_chain_trigger( 0 /* means: i am not root */, chain,
+		pskb, hooknum, in, out, offset, pkt_len, protoff);
+
+	/*
+	 * Say TO The Caller that : you should CONTINUE 
+	 */
+	if( ret == PKTT_RETURN ) return PKTT_CONTINUE;
+	return ret;
+}
+
+/**
+ * pktt_chain_destroy_function - this is the 'destroy' function of the chains 'target' .
+ *
+ * ability to use from chains as target ..
+ * SEE: pktt_chain_init
+ */
+void
+pktt_chain_destroy_function(const struct xt_target *target,
+			void *targinfo){
+	unsigned long *_chain = ( unsigned long *)targinfo;
+	struct pktt_chain *chain = ( void *) (*_chain);
+	
+	atomic_dec ( &(chain->refcnt) );
+	pktt_info("chain: '%s' is destroyed", chain->name);
+}
+
+/**
+ * pktt_chain_init - initialize the memory that is allocated for pktt_chain
+ * @chain: memory in cache ( allocated for pktt_chain )
+ */
+static void pktt_chain_init(struct pktt_chain *chain){
+	chain->list.next = chain->list.prev = NULL;
+	chain->table = NULL;
+
+	chain->my_hooks = 0;
+
+	chain->name[0] = '\0';
+
+	atomic_set(&(chain->refcnt), 0);
+	chain->target.target = pktt_chain_target_function;
+	chain->target.destroy = pktt_chain_destroy_function;
+	chain->target.me = (void *)NULL;
+	chain->target.checkentry = (void *)NULL;
+
+	INIT_LIST_HEAD( &(chain->entries) );
+	chain->num_entries = 0;
+	chain->size = 0;
+
+	chain->classifier = NULL;
+	chain->context = NULL;
+
+	chain->policy = cACCEPT;
+}
+
+
+/**
+ * pktt_table_init - initialize the memory that is allocated for pkt_table
+ * @table: memory in cache ( allocated for ipt_table )
+ */
+static void pktt_table_init(struct pkt_table *table){
+	int i;
+	table->list.next = table->list.prev = NULL;
+
+	table->name[0] = '\0';
+
+	table->valid_hooks = 0;
+	INIT_LIST_HEAD( &(table->chains) );
+	table->num_chains = 0;
+
+	for( i=0; i<NF_INET_NUMHOOKS; ++i) table->hook_entry[i]=NULL;
+
+	table->family = NPROTO +1;
+
+	rwlock_init( &(table->lock) );
+
+	table->owner = NULL;
+}
+
+/**
+ * pktt_match_cleanup - call match destroy function and put it's module
+ * @m: the match that must be cleaned
+ * @i: helper counter
+ */
+static inline int
+pktt_match_cleanup(struct xt_entry_match *m, unsigned int *i)
+{
+	if (i && (*i)-- == 0)
+		return 1;
+	pktt_info("cleanup match -%s-", m->u.kernel.match->name);
+
+	if (m->u.kernel.match->destroy)
+		m->u.kernel.match->destroy(m->u.kernel.match, m->data);
+
+	module_put(m->u.kernel.match->me);
+	return 0;
+}
+
+/**
+ * pktt_entry_cleanup - calls destroy functions for matches and target
+ * @e: the entry that must be cleaned
+ */
+static inline int
+pktt_entry_cleanup(struct pktt_entry*e)
+{
+	struct xt_entry_target *target;
+	pktt_info("clean up an entry");
+
+	/* Cleanup all matches */
+	PKTT_ENTRY_MATCH_ITERATE(e , pktt_match_cleanup, NULL);
+
+	target = pktt_entry_get_target(e);
+	if (target->u.kernel.target->destroy)
+		target->u.kernel.target->destroy(target->u.kernel.target,
+						 target->data);
+	module_put(target->u.kernel.target->me);
+	return 0;
+}
+
+/**
+ * pktt_chain_free - frees the memory that is allocated for the "chain" ...
+ *  
+ *   	- destroy the algoritm memory
+ *	- delete entries from the chain->entries list
+ *		- free entries
+ *	- free chain memory 
+ *
+ * we don't need to lock_bh, because we will call this function when we free
+ * the table. in this time there is nobody to trace the rules.
+ */
+static void 
+pktt_chain_free(struct pktt_chain *chain){
+	struct pktt_entry *entry;
+
+	pktt_info("free the chain (%s)", chain->name);
+	/*
+		destroy classifier specific memory
+	*/
+	chain->classifier->destroy( chain->context );
+	module_put( chain->classifier->owner );
+
+	while( 1 ){
+		if( list_empty( &(chain->entries)) ) break;
+
+		entry = (void*)	chain->entries.next;
+		list_del(&entry->list);
+		pktt_entry_cleanup( entry );
+
+		pktt_info("entry with rank=%i from the chain(%s)", entry->rank, chain->name);
+		kfree( entry );
+	}
+	//module_put(chain->table->owner);
+	kfree( chain );
+	pktt_info("chain is freed");
+}
+
+/** 
+ * pktt_table_free - frees memory that is allocated for the "table" ...
+ *
+ * 	- delete chains from the table->chains list
+ * 		- frees the chains
+ *	- delete from cache
+ * in this function we don't check the "refcnt" for chains
+ * because we want free all of them ( really )
+ */
+static void 
+pktt_table_free(struct pkt_table *table){
+	struct list_head *tmp;
+	struct pktt_chain *chain;
+	pktt_info("free the table (%s)", table -> name);
+
+	while( 1 ){
+		if( list_empty( &(table->chains) ) ) break;
+		list_del( tmp = table->chains.next );
+
+		chain = (struct pktt_chain *) tmp;
+		pktt_chain_free( chain );
+	}
+	kfree( table );
+	pktt_info("table is freed");
+}
+
+/**
+ * pktt_unregister_chain - deleting a chain from the table @table
+ * @table: chain containor
+ * @chain_name: chain information
+ *
+ * for deleting we first check the 'chain->refcnt', it must be zero
+ * and if not we can't unregister him.
+ */
+static int 
+pktt_unregister_chain(struct pkt_table *table, const char *chain_name){
+	struct pktt_chain *chain=NULL, *_chain;
+	pktt_info("unregister a chain (%s) from the table (%s)." 
+				"table_num_chains=%u", 
+				chain_name, table->name, table->num_chains);
+
+	/* finding the chain */
+	list_for_each_entry(_chain, &table->chains, list)
+		if(!strcmp(_chain->name, chain_name)){ chain=_chain; break; }
+
+	if(chain == NULL) {
+		pktt_error("three is no chain with this name");
+		return -EINVAL;
+	}
+
+	if(atomic_read(&chain->refcnt)){
+		pktt_error("the chain is busy");
+		return -EBUSY;
+	}
+
+	list_del(&chain->list);
+	--table->num_chains;
+
+	pktt_chain_free(chain);
+
+	pktt_info("chain is unregistered, table_num_chains=%u", 
+						table->num_chains);
+	return 0;
+}
+
+static struct pktt_classifier *
+	pktt_find_classifier(int af, const char *name);
+
+/**
+ * pktt_register_chain - register a chian in the table @table
+ * @table: chain containor
+ * @regchian: the information of the chain that must be registered.
+ */
+static struct pktt_chain* 
+pktt_register_chain(struct pkt_table *table, struct pktt_regchain *regchain){
+	struct pktt_chain *chain = NULL;
+	struct pktt_classifier *c;
+	int ret;
+	pktt_info( "registering a chain (%s) in the table (%s). "
+							"table_num_chains=%u" ,
+				regchain->name, table->name, table->num_chains);
+	list_for_each_entry(chain, &table->chains, list)
+		if(!strcmp(chain->name, regchain->name)) return ERR_PTR(-EEXIST);
+
+	if(!try_module_get(table->owner)){
+		pktt_error("can't get the table module");
+		return ERR_PTR(-ENOENT);
+	}
+
+	if(!(chain = kmalloc(sizeof(struct pktt_chain), GFP_KERNEL))){
+		pktt_error("there is no memory");
+		ret = -ENOMEM;
+		goto error_put;
+	}
+
+	pktt_chain_init( chain );
+
+	chain->policy = regchain->policy;
+	chain->table = table;
+	strlcpy(chain->name, regchain->name, PKTT_CHAIN_MAXNAMELEN);
+	strlcpy((char *)(chain->target.name), chain->name, PKTT_FUNCTION_MAXNAMELEN-1);
+
+	list_add(&chain->list, &table->chains);
+
+	/*
+	 * linear classifier as default classifier
+ 	 */
+	//chain->classifier = pktt_find_classifier(table->family, PKTT_LC_NAME)
+	chain->classifier = NULL;
+	list_for_each_entry(c, &xt[table->family].classifier, list)
+			if(!strcmp(c->name, PKTT_LC_NAME))
+				if(try_module_get(c->owner)){
+					chain->classifier = c;
+					break;
+				} 
+	if( chain->classifier &&
+		(chain->context=chain->classifier->init(chain))){
+		++table->num_chains;
+		pktt_info("chain is added (%s) table_num_chains=%u", 
+				chain->name, table->num_chains );
+		return chain;
+	}
+	ret = -EINVAL; 
+
+	pktt_error("can't initialize the classifier");
+	list_del(&chain->list);
+	kfree(chain);
+
+error_put:
+	//module_put(table->owner);
+	return ERR_PTR(ret);
+}
+
+int 
+pktt_register_table(struct net *net, struct pktt_regtable *regtable)
+{
+	int i, ret;
+	struct pkt_table *table;
+	pktt_info("registering a table (%s)", regtable->name);
+
+	if(regtable->family>=NPROTO) 
+		return -EFAULT;
+
+	if( (ret = mutex_lock_interruptible(&xt[regtable->family].mutex)) != 0 )
+		return ret;
+
+	list_for_each_entry(table, &net->xt.tables[regtable->family], list)
+		if(!strcmp(table->name, regtable->name)){
+			mutex_unlock(&xt[regtable->family].mutex);
+                	return -EEXIST;
+		}
+
+	table = kmalloc(sizeof(struct pkt_table),  GFP_KERNEL);
+	if(!table){
+		mutex_unlock(&xt[regtable->family].mutex); 
+		return -ENOMEM;
+	}
+
+	pktt_table_init( table );
+
+	strlcpy(table->name, regtable->name, PKTT_TABLE_MAXNAMELEN);
+	table->valid_hooks = regtable->valid_hooks;
+	table->owner = regtable->owner;
+	table->family = regtable->family;
+
+	list_add(&table->list, &net->xt.tables[regtable->family]);
+
+	for( i=0; i<NF_INET_NUMHOOKS; ++i){
+		struct pktt_regchain regchain;
+		struct pktt_chain* chain;
+
+		if( !( table->valid_hooks & ( 1 << i ) ) )
+			continue;
+		strlcpy(regchain.name, hook_names[table->family][i], PKTT_CHAIN_MAXNAMELEN);
+		regchain.policy = regtable->hooks_policy[i];
+
+		chain = pktt_register_chain(table, &regchain);
+		if(IS_ERR(chain)){ 
+			list_del(&table->list);
+			pktt_table_free(table);
+			pktt_error("can't register the chain '%s'",
+								regchain.name);
+			mutex_unlock(&xt[table->family].mutex);
+			return PTR_ERR( chain );
+		}
+		/* 
+		 * this chains are basic and could not deleted.
+		 * for this we set their "refcnt"s to 1 ( 0++ )
+		 */
+		atomic_inc( &(chain->refcnt) );
+		table->hook_entry[i] = chain;
+		chain->my_hooks = 1 << i;
+
+		pktt_info("chain is registered (%s)", chain->name );
+	}
+
+	regtable->table = table;
+	mutex_unlock(&xt[table->family].mutex);
+
+	pktt_info("table is registered (%s)", table->name);
+
+	return 0;
+}
+EXPORT_SYMBOL(pktt_register_table);
+
+void pktt_unregister_table(struct pktt_regtable *regtable)
+{
+	if(regtable->family >= NPROTO){
+		printk("pkt-table: bad family in the table unregisteration\n");
+		return;
+	}
+	mutex_lock(&xt[regtable->family].mutex);
+	list_del(&regtable->table->list);
+	mutex_unlock(&xt[regtable->family].mutex);
+
+	pktt_table_free( regtable->table );
+}
+EXPORT_SYMBOL(pktt_unregister_table);
+
+static inline struct pkt_table*
+pktt_table_find_lock(struct net *net, int af, char *table_name){
+	struct pkt_table *t=NULL;
+
+	if(mutex_lock_interruptible(&xt[af].mutex)!=0)
+		return ERR_PTR(-EINTR);
+
+	list_for_each_entry(t, &net->xt.tables[af], list)
+		if(strcmp(t->name, table_name)==0) return t;
+
+	mutex_unlock(&xt[af].mutex);
+	return NULL;
+}
+
+static inline int
+pktt_table_lock(struct pkt_table *t){
+	return mutex_lock_interruptible(&xt[t->family].mutex);
+}
+
+void
+pktt_table_unlock(struct pkt_table *t){
+	mutex_unlock(&xt[t->family].mutex);
+}
+
+static inline int 
+pktt_target_check(struct pktt_entry *e,
+			struct xt_entry_target *t,
+			const char *table_name,
+			unsigned int hookmask)
+{
+	struct xt_target *target;
+	int ret=0;
+
+	target = t->u.kernel.target;
+	switch(e->family){
+		case AF_INET:
+			ret = xt_check_target(target, e->family, 
+						t->u.target_size - sizeof(*t),
+			      			table_name, hookmask, 
+						e->pkt_header.ip4.proto,
+			      			e->pkt_header.ip4.invflags & 
+								XT_INV_PROTO);
+			break;
+		case AF_INET6:
+		case NF_ARP:
+			break;
+	}
+	if (!ret && t->u.kernel.target->checkentry
+   	&& !t->u.kernel.target->checkentry(table_name, e, 
+				target,	t->data, hookmask)) {
+		pktt_error("check failed for `%s'.",
+				t->u.kernel.target->name);
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+
+static inline int 
+pktt_match_check(struct xt_entry_match *m, 
+			struct pktt_entry *e,
+			const char *table_name,
+			unsigned int hookmask,
+			unsigned int *i)
+{
+	struct xt_match *match;
+	int ret=0;
+
+	match = m->u.kernel.match;
+	
+	switch(e->family){
+		case AF_INET:
+			ret = xt_check_match(match, e->family, 
+						m->u.match_size - sizeof(*m),
+						table_name, hookmask, 
+						e->pkt_header.ip4.proto,
+						e->pkt_header.ip4.invflags & 
+								XT_INV_PROTO);
+			if (!ret && m->u.kernel.match->checkentry
+			&& !m->u.kernel.match->checkentry(table_name, 
+				&e->pkt_header.ip4, match, m->data, hookmask)) {
+				pktt_error("check failed for `%s'.",
+						m->u.kernel.match->name);
+				ret = -EINVAL;
+			}
+			break;
+		case AF_INET6:
+		case NF_ARP:
+			break;
+	}
+	if (!ret)
+		(*i)++;
+	return ret;
+}
+
+/**
+ * pktt_match_transform_to_kernel - transform match from heuman readable form to kernel specific form
+ */
+static inline int
+pktt_match_transform_to_kernel(struct xt_entry_match *m, 
+				struct pktt_entry *e,
+				const char *table_name,
+				unsigned int hookmask,
+				unsigned int *i)
+{
+	struct xt_match *match;
+	int ret;
+	pktt_info("tranform match -%s-", m->u.user.name);
+
+	match = try_then_request_module(xt_find_match(e->family, m->u.user.name,
+							m->u.user.revision ),
+					"%st_%s", xt_prefix[e->family], m->u.user.name);
+	if (IS_ERR(match) || !match) {
+		pktt_error("can't find the match `%s'", m->u.user.name);
+		return match ? PTR_ERR(match) : -ENOENT;
+	}
+	m->u.kernel.match = match;
+
+	ret = pktt_match_check(m, e, table_name, hookmask, i);
+	if( ret ) goto err;
+	return 0;
+err:
+	module_put(m->u.kernel.match->me);
+	return ret;
+}
+
+/**
+ * pktt_entry_transform_to_kernel - transforms an entry from heuman readable form to kernel specific form
+ * @chain: the chain that the entry belong to
+ * @e: the entry memory in the heuman readable form
+ */
+static inline int
+pktt_entry_transform_to_kernel(struct pktt_chain *chain, struct pktt_entry *e)
+{
+	int ret;
+	unsigned int j;
+	struct xt_target *target;
+	struct xt_entry_target *t;
+	unsigned short family = chain->table->family;
+
+	pktt_info("transform an entry");
+
+	j = 0;
+	ret = PKTT_ENTRY_MATCH_ITERATE(e, pktt_match_transform_to_kernel, e, 
+					chain->table->name, 
+					chain->my_hooks, &j);
+	if (ret != 0){
+		pktt_error("can't translate matches");
+		goto cleanup_matches;
+	}
+
+	t = pktt_entry_get_target(e);
+	
+	target = try_then_request_module( xt_find_target(family, 
+					t->u.user.name, t->u.user.revision),
+					"%st_%s", xt_prefix[family], t->u.user.name);
+	if (IS_ERR(target)){ 
+		ret = PTR_ERR(target);
+		goto cleanup_matches;
+	}
+
+	if (!target) {
+		struct pktt_chain *tchain;
+
+		/* chain as a target */
+		list_for_each_entry(tchain, &chain->table->chains, list)
+			if(!strcmp(tchain->name, t->u.user.name)){
+				t->u.kernel.target = &(tchain->target);
+				((struct pktt_chain_target *)t)->chain = (unsigned long) tchain;
+				atomic_inc(&tchain->refcnt); //increment reference
+
+				pktt_info("chain as a target '%s'",tchain->name);
+				return 0;
+			}
+		pktt_error("also in the chain list");
+		ret = -ENOENT;
+		goto cleanup_matches;
+	}
+	t->u.kernel.target = target;
+	ret = pktt_target_check(e, t, chain->table->name, chain->my_hooks);
+	if( ret ){
+		module_put(target->me);
+		goto cleanup_matches;
+	}
+
+	pktt_info("entry is transformed");
+	return 0;
+
+cleanup_matches:
+	PKTT_ENTRY_MATCH_ITERATE(e, pktt_match_cleanup, &j);
+	return ret;
+}
+
+/**
+* pktt_entry_insert: add an entry to the chain
+* @chain: the containor
+* @ent: the entry that must be inserted to the chain. 
+* @index: the position that the entry @ent must be inserted before him
+*
+* index = 0: prepend the entry
+* index >= chain-> num_entries : append the entry
+*
+* for insertion we must first traverse the list to find the insertion 
+* position.. in this traversing also we update the ranks of entries.
+* if traversing forward ::: decrement them
+* if traversing reverse ::: increment them.
+* selection of the direction of traversing is depend on the insertion position
+* NOTE: every list has two half --------------------------------------
+*	                        |   num_entries / 2 | num_entries /2 |
+*				--------------------------------------
+*	to reaching to a position in a link list we can traverse the list
+*	in each direction. but if the position locates in the first half
+*	the forward direction is faster and for the second half the reverse
+*	direction too.
+* traversing the list in the forward direction means our entrie locates
+* at the front of this entries .. thus we should decrement their rank
+* and like this for the reverse direction .. must increment because our
+* entry locates at the back of this entries.
+*/
+static int 
+pktt_entry_insert(struct pktt_chain *chain, 
+			struct pktt_entry *ent, int index){
+	int ret;
+	struct list_head *_ent;
+	__u64 rank = -1, i = 0;
+	
+	ent->rank =0;
+	pktt_info("adding an entry to the -%s- size=%llu", chain->name, chain->size);
+
+	if( index<=chain->num_entries/2 ){
+		i=0;
+		list_for_each(_ent, &chain->entries){
+			if( i++ >= index ) break;
+			--(((struct pktt_entry *)_ent)->rank);
+			pktt_info("go over from this rank=%i +1",((struct pktt_entry *)_ent)->rank); 
+		}
+		/* check i: if be zero : the list is empty (rank = 0)
+		* if not we should to prepend him to the _ent .. 
+		* 	his rank is _ent->rank -1 .. 
+		*/
+		rank = (i)? ((struct ipt_entry *)_ent)->rank-1: 0;
+		pktt_info("first-half. rank=%lld", rank);
+	}else{
+		i=0;
+		list_for_each_prev( _ent, &chain->entries){
+			if( i >= (chain->num_entries - index) ) break;
+			rank = ++(((struct pktt_entry *)_ent)->rank);
+			++i;
+			pktt_info("go over from this rank=%i -1",((struct pktt_entry *)_ent) -> rank);
+		}
+		/* check i: if be zero: must append the entry. now 
+ 		* we are at the last entry in the list. we should use from
+		* the last rank + 1 for his rank.
+		*/
+		rank=(i)? rank-1:((struct pktt_entry *)_ent)->rank +1;
+		_ent = _ent->next;
+		pktt_info("second-half. rank=%lld", rank);
+	}
+	ent->rank = rank;
+
+	write_lock_bh(&chain->table->lock);
+	list_add_tail(&ent->list, _ent);	
+	/*
+		adding entry to classifier
+	*/
+	ret = chain->classifier->attach_rule(chain->context, ent);
+	if(ret!=0){
+		list_del(&ent->list);
+		write_unlock_bh(&chain->table->lock);
+
+		pktt_error("can't add entry to the classifier");
+		//pktt_entry_cleanup(ent);
+		return ret;
+	}
+	write_unlock_bh(&chain->table->lock);
+
+	++(chain->num_entries);
+	chain->size += ent->size;
+
+	pktt_info("entry is added. rank=%i entry-size=%u "
+				"chain_num_entries=%u chain_size=%llu", 
+			ent->rank, ent->size, chain->num_entries, chain->size);
+	return 0;
+}
+
+/**
+ * pktt_chain_flush - flush the entries of the chain
+ * @chain: the chain that must be flushed
+ *
+ * we should to use table "lock", because it may be called at the table
+ * life time.
+ */
+static void 
+pktt_chain_flush(struct pktt_chain *chain){
+	struct pktt_entry *ent;
+	pktt_info("flush the chain (%s)", chain->name);
+
+	write_lock_bh(&chain->table->lock);
+	/*
+		flush classifier 
+	*/
+	chain->classifier->flush(chain->context);
+	write_unlock_bh(&chain->table->lock);
+
+	while( 1 ){
+		if( list_empty(&chain->entries) ) break;
+
+		ent = (void*) chain->entries.next;
+		list_del(&ent->list);
+		pktt_entry_cleanup(ent);
+
+		pktt_info("entry with rank=%i from the chain(%s)", ent->rank, chain->name);
+		kfree(ent);
+	}
+	chain->size = 0;
+	chain->num_entries = 0;
+
+	pktt_info("chain is flushed");
+} 
+
+/**
+ * pktt_entry_delete - delete an entry from the chain @chain
+ * @chain: containor 
+ * @ent: the entry that must be deleted 
+ *
+ * first delete from the classification algoritm then
+ * from the chain
+ */
+static int 
+pktt_entry_delete(struct pktt_chain *chain, struct pktt_entry *ent){
+	int ret;
+
+	pktt_info("deleting an entry from-%s- chain_size=%llu chain_num_entries=%u"
+						"entry_size=%u entry_rank=%i.", 
+		chain->name , chain->size, chain->num_entries, ent->size, ent->rank);
+
+	write_lock_bh(&chain->table->lock);
+	/*
+		deleting entry from classifier
+	*/
+	ret = chain->classifier->detach_rule(chain->context, ent);
+	if(!ret) list_del(&ent->list);
+	write_unlock_bh(&chain->table->lock);
+	
+	if( ret != 0 ){
+		pktt_error("can't delete entry from the classifier");
+		return ret;
+	}
+	--chain->num_entries;
+	chain->size -= ent->size;
+
+	pktt_info("entry is deleted. chain_size=%llu chain_num_entries=%d", 
+					chain->size, chain->num_entries);	
+
+	pktt_entry_cleanup( ent );
+	kfree( ent );
+	return 0;
+}
+
+/**
+ * pktt_entry_replace - replace an entry in the chain with the new entry.
+ * @chain: the entries containor
+ * @this: must be replaced
+ * @with: new entry.. must be transformed before insertion
+ */
+static int 
+pktt_entry_replace(struct pktt_chain *chain, 
+		   struct pktt_entry *this, 
+		   struct pktt_entry *with){
+	int ret;
+	struct list_head *tmp;
+
+	pktt_info("replacing an entry in the chain -%s- rank=%i", chain->name,
+								    this->rank);
+
+	with->rank = this->rank;
+	tmp = this->list.next;
+
+	ret = pktt_entry_delete(chain, this);
+	if( ret != 0 ){
+		pktt_error("can't delete old entry");
+		goto error;
+	}
+
+	write_lock_bh(&chain->table->lock);
+	list_add_tail(&with->list, tmp);
+	/*
+		adding new entry to classifier
+	*/
+	ret = chain->classifier->attach_rule(chain->context, with);
+	if(ret) list_del(&with->list);
+	write_unlock_bh(&chain->table->lock);
+
+	if( ret != 0 ){
+		pktt_error("can't add new entry to the classifier");
+		//FIXME add old rule
+		goto error;
+	}
+
+	++chain->num_entries;
+	chain->size += with->size;
+
+	pktt_info("entry replaced, new_entry_size=%u new_chain_size=%llu", 
+					with->size, chain->size);
+	return ret;
+
+error:
+	//pktt_entry_cleanup(with);
+	return ret;
+}
+
+int
+pktt_register_classifier(struct pktt_classifier *classifier){
+	int ret;
+	unsigned short af= classifier->family;
+	struct pktt_classifier *c;
+
+	if( (ret = mutex_lock_interruptible(&xt[af].mutex)) != 0 )
+		return ret;
+
+	list_for_each_entry(c, &xt[af].classifier, list)
+		if(!strcmp(c->name, classifier->name)){
+			pktt_error("\"%s\" classifier exists", classifier->name);
+			mutex_unlock(&xt[af].mutex);
+			return -EEXIST;
+		}
+
+	list_add(&classifier->list, &xt[af].classifier);
+	mutex_unlock(&xt[af].mutex);
+
+	pktt_info("\"%s\" classifier is registered", classifier->name);
+	return ret;
+}
+EXPORT_SYMBOL(pktt_register_classifier);
+
+void 
+pktt_unregister_classifier(struct pktt_classifier *classifier){
+	int af = classifier->family;
+
+	mutex_lock(&xt[af].mutex);
+	list_del(&classifier->list);
+	mutex_unlock(&xt[af].mutex);
+}
+EXPORT_SYMBOL(pktt_unregister_classifier);
+
+static struct pktt_classifier *
+pktt_find_classifier(int af, const char *name){
+	struct pktt_classifier *c;
+
+	if(mutex_lock_interruptible(&xt[af].mutex) != 0)
+		return ERR_PTR(-EINTR);
+
+	list_for_each_entry(c, &xt[af].classifier, list){
+		if(strcmp(c->name, name) == 0){
+			pktt_info("classifier fined ..");
+			if(try_module_get(c->owner)){
+				mutex_unlock(&xt[af].mutex);
+				return c;
+			}
+		}
+	}
+	mutex_unlock(&xt[af].mutex);
+	return NULL;
+}
+//EXPORT_SYMBOL(pktt_find_classifier);
+//FIXME be macro
+static inline int
+PKTT_CLASSIFIER_ADD_ENTRY(struct pktt_entry *e, 
+			     struct pktt_classifier *classifier,
+			     void *context){
+	pktt_info("adding entry with rank: %i", e->rank);
+	return classifier->attach_rule(context, e);
+}
+
+/**
+ * pktt_classifier_change - change the chain classifier 
+ */
+static int 
+pktt_classifier_change(struct pktt_chain *chain, struct pktt_classifier *newc){
+	struct pktt_classifier *oldc;
+	//struct pktt_classifier *newc;
+	void *context;
+	int ret =0;
+
+	//newc = try_then_request_module(pktt_find_classifier(chain->table->family, new_classifier),
+	//				"%sc_%s", xt_prefix[chain->table->family], new_classifier);
+	//if(IS_ERR(newc) || !newc){
+	//	pktt_error("can't find new classifier(%s)", new_classifier);
+	//	return newc? PTR_ERR(newc): -ENOENT;
+	//}
+
+	context = newc->init(chain);
+	if(!context){
+		pktt_error("can't initialize the new classifier(%s)", newc->name);
+		return -EINVAL;
+	}
+
+	write_lock_bh(&chain->table->lock);
+	/*
+		flushing old classifier ..
+
+		WHY? classfiers can use from "next_match" and "helper_list"
+		pointers in the "pktt_entry" structure.
+		by this we can avoid from classifiers side affects on each other.
+	*/
+	chain->classifier->flush(chain->context);
+
+	/*
+		adding entries to the new classifier
+	*/
+	ret = PKTT_ENTRY_ITERATE(&(chain->entries), PKTT_CLASSIFIER_ADD_ENTRY, newc, context);
+	if( ret != 0 ){
+		pktt_error("I can't add all of the entries to the new classifier");
+		pktt_error("using from old classfieir");
+
+		/*
+			destroy new classifier
+		*/
+		newc->destroy(context);
+
+		/*
+			using old classifier
+		*/
+		ret = PKTT_ENTRY_ITERATE(&(chain->entries), PKTT_CLASSIFIER_ADD_ENTRY, 
+						chain->classifier, chain->context);
+		if( ret != 0 ){
+			chain->classifier->flush(chain->context);
+			printk(KERN_ERR"iptables: UNSTABLE state !!!!\n");
+			printk(KERN_ERR"iptables: Using Classifier In The FLUSH mode\n");
+			printk(KERN_ERR"iptables: Only Chain Policies can effect on the packets\n");
+		}
+
+		write_unlock_bh(&chain->table->lock);
+
+		module_put(newc->owner);
+		return ret;
+	}
+
+	/** 
+		All of the entries are ADDed successfully
+
+		destroy old classifier
+	*/
+	oldc = chain->classifier;
+	chain->classifier->destroy(chain->context);
+	
+	/*
+		using new classifier
+	*/
+	chain->classifier = newc;
+	chain->context = context;
+
+	write_unlock_bh(&chain->table->lock);
+
+	module_put(oldc->owner);
+
+	return ret;
+}
+
+static inline int 
+pktt_match_transform_to_user(struct xt_entry_match *m, 
+				void __user *userptr, unsigned int *offset){
+	int ret;
+	ret = copy_to_user(userptr + *offset
+				+ offsetof(struct xt_entry_match, u.user.name),
+				m->u.kernel.match->name,
+				strlen(m->u.kernel.match->name)+1);
+	if( ret != 0){
+		pktt_error("can't copy match name (%s)", 
+					m->u.kernel.match->name);
+		return -EFAULT;
+	}
+	pktt_info("match name (%s) is copied", m->u.kernel.match->name);
+	(*offset) += m->u.match_size;
+	return 0;
+}
+
+static inline void 
+pktt_entry_get_counters(const struct pktt_entry *e,struct pktt_counters *c){
+	int i;
+	for( i=0; i<NR_CPUS; ++i){
+		c->bcnt += e->counters[i].bcnt;
+		c->pcnt += e->counters[i].pcnt;
+	}
+}
+
+static int
+pktt_entry_transform_to_user(const struct pktt_entry *e, void __user *userptr)
+{
+	struct xt_entry_target *t;
+	struct pktt_counters cnt = {0 ,0};
+	unsigned int offset;
+	int ret;
+	pktt_info("copy entry to user rank=%i", e->rank);
+
+	/* copy user specific part of the entry */
+	offset = sizeof(struct pktt_user_entry);
+	ret = copy_to_user(userptr, e->pktt_user_entry, offset);
+
+	if(ret == 0) /* copy matches (if any) and target */
+		ret = copy_to_user( userptr + offset, e->elems,
+						e->size - offset );
+	if ( ret != 0 ){
+		pktt_error("can't copy entry to user");
+		return -EFAULT;
+	}
+	pktt_entry_get_counters(e, &cnt); /* copy counters */
+	ret=copy_to_user( userptr + offsetof( struct pktt_user_entry, counters),
+					&cnt, sizeof(struct pktt_counters));
+	if( ret != 0 ){ 
+		pktt_error("can't copy counters");
+		return -EFAULT;
+	}
+
+	ret = PKTT_ENTRY_MATCH_ITERATE( e , pktt_match_transform_to_user , userptr, &offset );
+	if( ret != 0 ) return -EFAULT;
+
+	t = pktt_entry_get_target(e);
+	if (copy_to_user(userptr + e->target_offset + sizeof(struct pktt_user_entry)
+			 	+ offsetof(struct xt_entry_target, u.user.name),
+			 	t->u.kernel.target->name,
+			 	strlen(t->u.kernel.target->name)+1) != 0) {
+		pktt_error("can't copy target name (%s)",
+					t->u.kernel.target->name);
+		return -EFAULT;
+	}
+	pktt_info("target name (%s) is copied",t->u.kernel.target->name);
+	
+	return 0;
+}
+
+/*
+ * NOTE: in the pktt_compare_* functions that coming below, 
+ * e1 is in the kernel spcific form and
+ * e2 is in the user specific form.
+ */
+static inline int 
+pktt_compare_entries_ips(struct pktt_entry *e1, struct pktt_entry *e2){
+	switch(e1->family){
+		case AF_INET:
+			return !memcmp( &e1->pkt_header.ip4, &e2->pkt_header.ip4, sizeof(struct ipt_ip));
+		case AF_INET6:
+		case NF_ARP:
+			break;
+	}
+	return 0;
+}
+
+static inline int
+pktt_compare_entries_matches(struct pktt_entry *e1, struct pktt_entry *e2){
+	unsigned int i=0;
+	struct xt_entry_match *m1, *m2;
+	
+	for(i=0; i < e1->target_offset; i+=m1->u.match_size){
+		m1 = (void *)e1->elems + i;
+		m2 = (void *)e2->elems + i;
+
+		if(m1->u.match_size != m2->u.match_size) return 0;
+		if(strcmp(m1->u.kernel.match->name, m2->u.user.name)) return 0;
+		if(memcmp(m1->data, m2->data, m1->u.match_size - sizeof(*m1))) return 0;
+	}
+
+	return 1;
+}
+/**
+ * pktt_compare_entries - we use from this function to find a rule that matches e2....
+ */
+static inline int 
+pktt_compare_entries(struct pktt_chain *chain, 
+		     struct pktt_entry *e1, struct pktt_entry *e2){
+	int ret =1;
+	struct xt_entry_target *t1, *t2;
+	struct pktt_chain *_chain;
+
+	ret = ret && (e1->target_offset == e2->target_offset);
+	ret = ret && (e1->size == e2->size);
+	if( !ret ) return 0;
+	pktt_info("entry compare size and offset passed");
+
+	ret = ret && pktt_compare_entries_ips(e1, e2);
+	if( !ret ) return 0;
+	ret = ret && pktt_compare_entries_matches(e1, e2);
+	if( !ret ) return 0;
+	pktt_info("entry compare ips & matches passed");
+
+	t1= pktt_entry_get_target(e1);
+	t2= pktt_entry_get_target(e2);
+
+	/* compare target names */
+	ret = ret && !strcmp(t1->u.kernel.target->name, t2->u.user.name);
+	pktt_info("entry compare target names: kern:%s user:%s ret:%d",
+			     t1->u.kernel.target->name, t2->u.user.name, ret);
+	if( !ret ) return 0;
+
+	/* compare target infoes */
+	/* first test to see the target is a chain, if not we can
+	 * compare the target infoes */
+	list_for_each_entry(_chain, &chain->table->chains, list)
+		if(!strcmp(_chain->name, t1->u.kernel.target->name)) return ret;
+
+	ret = ret && !memcmp(t1->data, t2->data, 
+		t1->u.target_size - sizeof(struct xt_entry_target));
+	pktt_info("entry compare target data: ret:%d",ret);
+	return ret;
+}
+
+static inline int 
+pktt_entry_zero_counters(const struct pktt_entry *entry){
+	memset( &(entry->counters), 0,NR_CPUS * sizeof(struct pktt_counters));
+	return 0;
+}
+
+static int 
+pktt_manage_set_commands(struct net *net, void __user *user, unsigned int len){
+	int ret = 0;
+	struct pktt_command command;
+	struct pkt_table *table;
+	struct pktt_chain *chain;
+	pktt_info("executing a user set command");
+
+	if( len < sizeof(struct pktt_command)) return -EFAULT;
+
+	ret= copy_from_user(&command, user, sizeof(struct pktt_command));
+	if( ret != 0 ){ 
+		pktt_error("can't copy the command");
+		return -EFAULT;
+	}
+	pktt_info("command: %d ,table: %s ,chain: %s", command.command, 
+				command.table_name, command.chain_name);
+
+	if(command.family>=NPROTO){
+		pktt_error("pkt-table: bad family from user space");
+		return -EFAULT;
+	}	
+
+	table= try_then_request_module(pktt_table_find_lock(net, command.family, 
+							command.table_name),
+					"iptable_%s", command.table_name);
+	if( IS_ERR(table) || !table ){
+		pktt_error("can't find the table");
+		return -ENOENT;
+	}
+
+#define FIND_CHAIN 							\
+	list_for_each_entry(chain, &table->chains, list)		\
+		if(!strcmp(chain->name, command.chain_name)) break;	\
+	if (&chain->list == &table->chains){				\
+		pktt_error("can't find the chain");			\
+		ret=-EINVAL; chain=NULL;				\
+		break;							\
+	}				
+	
+/** modifier for the size of memory that must be allocated for the entry
+ */
+#define ENTRY_SIZE_MODIFIER ( sizeof(struct pktt_entry) - 		\
+					sizeof(struct pktt_user_entry) )
+
+#define COPY_ENTRY_FROM_USER(e, user, len,  ret) \
+	do{ /* copy entry info */					\
+	 /* make counters zero */					\
+	pktt_entry_zero_counters((struct pktt_entry *)(e)); 		\
+	ret = copy_from_user( ((struct pktt_entry *)(e))->pktt_user_entry,\
+				 user + sizeof(struct pktt_command), 	\
+				 sizeof(struct pktt_user_entry));    	\
+	if( ret == 0 ){	/* copy entry payload */			\
+	ret = copy_from_user( ((struct pktt_entry *)e)->elems , 	\
+	/* position to copy from */ user + sizeof(struct pktt_command) +\
+				 	sizeof(struct pktt_user_entry),	\
+	/* length to copy */	 len  - sizeof(struct pktt_command) -	\
+					sizeof(struct pktt_user_entry));\
+/*#if 0*/								\
+	pktt_info("counters: bcnt:%lli pcnt:%lli",			\
+			e->counters[0].bcnt, e->counters[0].pcnt);	\
+/*#endif*/								\
+	} 								\
+	}while(0)
+
+	switch( command.command ){
+	case PKTT_ENTRY_ADD:{
+		struct pktt_entry *e;
+		pktt_info("ENTRY_ADD rule-number=%d", 
+						command.ext.ent.rule_number);
+
+		FIND_CHAIN;
+		e= kmalloc( len - sizeof(struct pktt_command) 
+						+ ENTRY_SIZE_MODIFIER ,GFP_KERNEL);
+		if( !e ){ 
+			ret=-ENOMEM;
+			break;
+		}
+
+		COPY_ENTRY_FROM_USER(e, user, len, ret);
+		if( ret !=0 ){ 
+			ret=-EFAULT;
+			kfree(e);
+			break;
+		}
+		/* test size of entry: it must fill all of the 
+		 * remained memory 
+		 */
+		if( e->size != (len - sizeof(struct pktt_command) )){
+			pktt_error("size mismatched e: %d, len: %d",
+				e->size, len-sizeof(struct pktt_command));
+			ret=-EINVAL;
+			kfree(e);
+			break;
+		}
+		if( e->family != chain->table->family ){
+			pktt_error("family mismatched e:%d t:%d", e->family, chain->table->family);
+			ret=-EINVAL;
+			kfree(e);
+			break;
+		}
+
+		/* go away from dead lock */
+		pktt_table_unlock(table);
+
+		/* transform the entry to the kernel specific form */
+		ret = pktt_entry_transform_to_kernel(chain, e);
+		if( ret != 0 ){
+			pktt_error("can't transform the entry");
+			kfree(e);
+			ret = -EBADF;
+			break;
+		}
+
+		if(pktt_table_lock(table) !=0){
+			pktt_entry_cleanup(e);
+			kfree(e);
+			ret = -EINTR;
+			break;
+		}
+		ret = pktt_entry_insert(chain, e, 
+						command.ext.ent.rule_number -1);
+
+		if( ret != 0 ){ 
+			pktt_entry_cleanup(e);
+			kfree(e);
+		}
+		break;}
+
+	case PKTT_ENTRY_DEL_WITH_RULE:{
+		struct pktt_entry *e, *ee, *matched_entry;
+		pktt_info("ENTRY_DEL_WITH_RULE");
+
+		FIND_CHAIN;
+		e= kmalloc( len - sizeof(struct pktt_command ) 
+						+ ENTRY_SIZE_MODIFIER , GFP_KERNEL);
+		if(!e){
+			ret= -ENOMEM;
+			break;
+		}
+		
+		COPY_ENTRY_FROM_USER(e, user, len, ret);
+		if( ret != 0 ){
+			ret=-EFAULT;
+			kfree(e);
+			break;
+		}
+		/* test size of entry: it must fill all of the remained 
+		 * memory */
+		if( e->size != (len - sizeof(struct pktt_command) )){
+			pktt_error("size mismatched e:%d , len:%d",
+				e->size, len-sizeof(struct pktt_command));
+			ret=-EINVAL;
+			kfree(e);
+			break;
+		}
+		matched_entry = NULL;
+		list_for_each_entry( ee, &(chain->entries), list)
+			if(pktt_compare_entries(chain, ee, e)){
+				matched_entry = ee;
+				break;
+			}
+				
+		kfree(e);
+		if(!matched_entry){
+			ret=-EINVAL;
+			break;
+		}
+		ret = pktt_entry_delete(chain, matched_entry);
+		break;}
+
+	case PKTT_ENTRY_DEL_WITH_NUM:{
+		struct pktt_entry *ee;
+		unsigned int i;
+		pktt_info("ENTRY_DEL_WITH_NUM rule-number= %d", 
+						command.ext.ent.rule_number);
+		FIND_CHAIN;
+		if(command.ext.ent.rule_number > chain->num_entries){
+			pktt_error("ENTRY_DEL_WITH_NUM bad index");
+			ret=-EINVAL;
+			break;
+		}
+		i=0;
+		list_for_each_entry(ee, &(chain->entries), list)
+				if(i++ == command.ext.ent.rule_number-1) break;
+		ret = pktt_entry_delete(chain, ee);
+		break;}
+
+	case PKTT_ENTRY_REPLACE:{
+		struct pktt_entry *e, *ee;
+		unsigned int i;
+		pktt_info("IPT_ENTRY_REPLACE rule-number= %d", 
+						command.ext.ent.rule_number);
+		FIND_CHAIN;
+		if(command.ext.ent.rule_number > chain->num_entries){
+			pktt_error("ENTRY_REPLACE bad index");
+			ret=-EINVAL;
+			break;
+		}
+		i=0;
+		list_for_each_entry(ee, &(chain->entries), list)
+				if(i++ == command.ext.ent.rule_number-1) break;
+
+		e= kmalloc(len - sizeof(struct pktt_command) 
+						+ ENTRY_SIZE_MODIFIER , GFP_KERNEL);
+		if(!e){
+			ret=-ENOMEM;
+			break;
+		}
+		
+		COPY_ENTRY_FROM_USER(e, user, len, ret);
+		if( ret != 0 ){
+			ret=-EFAULT;
+			kfree(e);
+			break;
+		}
+		/* test entry size */
+		if(e->size != (len - sizeof(struct pktt_command))){
+			pktt_error("IPT_ENTRY_REPLACE size mismatched e:%d , \
+			     len:%d", e->size, len-sizeof(struct pktt_command));
+			ret=-EINVAL;
+			kfree(e);
+			break;
+		}
+
+		/* go away from dead lock */
+		pktt_table_unlock(table);
+
+		/* transform the entry to the kernel specific form */
+		ret = pktt_entry_transform_to_kernel(chain, e);
+		if( ret != 0 ){
+			pktt_error("can't transform the entry");
+			kfree(e);
+			break;
+		}
+
+		if(pktt_table_lock(table) !=0){
+			pktt_error("can't get mutex lock");
+			pktt_entry_cleanup(e);
+			kfree(e);
+			ret = -EINTR;
+			break;
+		}
+
+		ret= pktt_entry_replace( chain, ee, e);
+		if(ret != 0){ 
+			pktt_entry_cleanup(e);
+			kfree(e);
+		}
+		break;}
+	
+	case PKTT_ENTRY_SET_COUNTER:{
+		struct pktt_entry *ee;
+		unsigned int i;
+		pktt_info("ENTRY_SET_COUNTER rule-number=%d", 
+						command.ext.ent.rule_number);
+		FIND_CHAIN;
+		if(command.ext.ent.rule_number > chain->num_entries){
+			pktt_error("ENTRY_REPLACE bad index");
+			ret=-EINVAL;
+			break;
+		}
+		i=0;
+		list_for_each_entry(ee, &(chain->entries), list)
+				if(i++ == command.ext.ent.rule_number-1) break;
+
+		write_lock_bh(&table->lock);
+
+		pktt_entry_zero_counters(ee);
+
+		ee->counters[0].bcnt = command.ext.ent.counter.bcnt;
+		ee->counters[0].pcnt = command.ext.ent.counter.pcnt;
+
+		write_unlock_bh(&table->lock);
+		ret = 0;
+		break;}
+
+	case PKTT_CHAIN_FLUSH:{
+		pktt_info("CHAIN_FLUSH");
+
+		FIND_CHAIN;
+		pktt_chain_flush(chain);
+		ret = 0 ;
+		break;}
+
+	case PKTT_CHAIN_ZERO:{
+		struct pktt_entry *ee;
+		pktt_info("CHAIN_ZERO");
+
+		FIND_CHAIN;
+		/* Why lock?? we can directly make zero.. but note
+		 * matchig activities work with us.. we should stop them
+		 * to make counters zero really. */
+		write_lock_bh(&table->lock);
+
+		list_for_each_entry(ee, &(chain->entries), list)
+					pktt_entry_zero_counters(ee);
+
+		write_unlock_bh(&table->lock);		
+		ret = 0;
+		break;}
+
+	case PKTT_CHAIN_NEW:{
+		struct pktt_regchain regchain;
+		struct pktt_chain *chain;
+		pktt_info("CHAIN_NEW");
+
+		strlcpy(regchain.name, command.chain_name, PKTT_CHAIN_MAXNAMELEN);
+		regchain.policy= cACCEPT;
+
+		chain= pktt_register_chain(table, &regchain);
+
+		if( IS_ERR( chain ) ) ret = PTR_ERR(chain);
+		else ret = 0;
+
+		break;}
+
+	case PKTT_CHAIN_DELETE:{
+		pktt_info("CHAIN_DELETE");
+
+		ret= pktt_unregister_chain(table, command.chain_name);
+		break;}
+
+	case PKTT_CHAIN_RENAME:{
+		pktt_info("CHAIN_RENAME new_name= %s",
+					      command.ext.new_chain_name);
+		FIND_CHAIN;
+
+		strlcpy(chain->name, command.ext.new_chain_name, PKTT_CHAIN_MAXNAMELEN);
+		strlcpy((char *)chain->target.name, command.ext.new_chain_name, PKTT_CHAIN_MAXNAMELEN );
+
+		ret =0;
+
+		break;}
+
+	case PKTT_CHAIN_SET_POLICY:{
+		pktt_info("CHAIN_SET_POLICY policy= %d", command.ext.policy);
+
+		FIND_CHAIN;
+		/* it may be required to lock_bh there ..  
+		 * but i write directly ..
+		 * it may some searches don't see this,
+		 * but after some times, all of the matching activities will
+		 * work with the new policy 
+		 */
+		chain->policy = command.ext.policy;
+		ret = 0;
+		break;}
+
+	case PKTT_CHAIN_CHG_CLASSIFIER:{
+		struct pktt_classifier *newc;
+		pktt_info("CHAIN_CHG_CLASSIFIER new-classifier= %s",
+						command.ext.new_classifier);
+		FIND_CHAIN;
+		
+		/* go away from dead lock */
+		pktt_table_unlock(table);
+
+		newc = try_then_request_module(
+			pktt_find_classifier(table->family, command.ext.new_classifier),
+		"%sc_%s", xt_prefix[table->family], command.ext.new_classifier);
+		if(IS_ERR(newc) || !newc){
+			pktt_error("can't find the classifier %s",
+						command.ext.new_classifier);
+			ret = -ENOENT; break;
+		}
+
+		if(pktt_table_lock(table) !=0){
+			pktt_error("can't get mutex lock");
+			ret = -EINTR;
+			break;
+		}
+
+		ret = pktt_classifier_change(chain, newc);
+		break;}
+
+	default:
+		pktt_error("UNknown command -%d-",command.command);
+		ret = -EINVAL;
+		break;
+	}
+
+	pktt_table_unlock(table);
+	return ret;
+}
+
+static int
+pktt_set_ctl(struct sock *sk,	int cmd, void __user *user, unsigned int len)
+{
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	switch(cmd) {
+	case IPT_SO_SET_REPLACE:
+	case IPT_SO_SET_ADD_COUNTERS:
+		return pktt_manage_set_commands(sk->sk_net, user, len);
+		break;
+
+	default:
+		printk("do_ipt_set_ctl:  unknown request %i\n", cmd);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static inline int 
+pktt_entry_transform_to_user_helper(const struct pktt_entry *e, 
+					void __user *user,
+					unsigned long *offset){
+	int ret = pktt_entry_transform_to_user(e, user+(*offset));
+
+	if(ret != 0) return ret;
+
+	*offset += e->size;
+	return 0;
+}
+
+static int 
+pktt_manage_get_commands(struct net *net, void __user *user, int *len){
+	int ret;
+	struct pktt_command command;
+	struct pkt_table *table;
+
+	pktt_info("executing a user get info command");
+
+	ret = copy_from_user(&command, user, sizeof(struct pktt_command));
+	if( ret != 0 ){
+		pktt_error("can't copy the command");
+		return -EFAULT;
+	}
+	pktt_info("command:%d ,table:%s", command.command, command.table_name );
+	
+	if(command.family>=NPROTO){
+		printk("pkt-table: bad family from user space\n");
+		return -EFAULT;
+	}	
+
+	table = try_then_request_module(pktt_table_find_lock(net, command.family, 
+							command.table_name),
+					"iptable_%s", command.table_name);
+	if( IS_ERR(table) || !table ){
+		pktt_error("can't find the table");
+		return -ENOENT;
+	}
+
+	*len = ret = 0;
+	switch( command.command ){
+	case PKTT_TABLE_GET_INFO:{
+		struct pkt_table_info pti;
+		pktt_info("TABLE_GET_INFO");
+
+		strcpy(pti.name, table->name);
+		pti.num_chains = table->num_chains;
+		pti.valid_hooks= table->valid_hooks;
+		pktt_info("table: %s  num_entries: %d", pti.name, pti.num_chains);
+		
+		ret = copy_to_user( user, &pti, sizeof(struct pkt_table_info));
+		if(ret != 0){
+			pktt_error("can't copy table info");
+			ret= -EFAULT;
+			break;
+		}
+		*len = sizeof(struct pkt_table_info );
+		ret = 0;
+		break;}
+
+	case PKTT_TABLE_CHAINS_GET_INFO:{
+		struct pkt_table_info pti;
+		struct pktt_chain_info pci;
+		struct pktt_chain *chain;
+		unsigned int i;
+		pktt_info("IPT_TABLE_CHAINS_GET_INFO");
+
+		strcpy(pti.name, table->name);
+		pti.num_chains = table->num_chains;
+		pti.valid_hooks= table->valid_hooks;
+
+		ret= copy_to_user(user, &pti, sizeof(struct pkt_table_info));
+		if( ret != 0 ){
+			pktt_error("can't copy table info -%s-", pti.name);
+			ret=-EFAULT;
+			break;
+		}
+		pktt_info("table: %s, num_chains: %d", pti.name,pti.num_chains);
+		
+		chain = (void *)(table->chains.prev);
+		for( i=0; i< table->num_chains; ++i){
+			strcpy(pci.name, chain->name);
+			pci.num_entries = chain->num_entries;
+			pci.refcnt = atomic_read( &chain->refcnt );
+			pci.size = chain->size;
+			pci.policy = chain->policy;
+			strcpy(pci.classifier_name, chain->classifier->name);
+
+			ret= copy_to_user( user + sizeof(struct pkt_table_info)
+						+i*sizeof(struct pktt_chain_info)
+						, &pci,
+						sizeof(struct pktt_chain_info));
+			if( ret != 0 ){
+				pktt_error("can't copy chain info -%s-",
+								pci.name);
+				ret=-EFAULT;
+				break;
+			}
+			chain = (void *)(chain->list.prev);
+			pktt_info("chain copied -%s-", pci.name);
+		}
+		
+		if(ret==0){
+			*len = sizeof(struct pkt_table_info) + 
+			   table->num_chains * sizeof(struct pktt_chain_info );
+			ret = 0;
+		}
+		break;}
+
+	case PKTT_CHAIN_GET_INFO:{
+		struct pktt_chain_info pci;
+		struct pktt_chain *chain;
+		pktt_info("IPT_CHAIN_GET_INFO chain_name=%s", command.chain_name);
+		
+		FIND_CHAIN;
+		strcpy(pci.name, chain->name);
+		pci.num_entries= chain->num_entries;
+		pci.refcnt= atomic_read(&chain->refcnt);
+		pci.size= chain->size;
+		pci.policy= chain->policy;
+		strcpy(pci.classifier_name, chain->classifier->name);
+
+		ret = copy_to_user(user, &pci, sizeof(struct pktt_chain_info));
+		if( ret != 0 ){
+			pktt_error("can't copy chain info (%s) to user",
+								pci.name);
+			ret=-EFAULT;
+			break;
+		}
+		*len = sizeof(struct pktt_chain_info);
+		ret = 0;
+		break;}
+
+	case PKTT_CHAIN_GET_ENTRIES:{
+		struct pktt_chain_info pci;
+		struct pktt_chain *chain;
+		unsigned long offset;
+		pktt_info("get entries for chain -%s- in table -%s-", 
+				command.chain_name, command.table_name);
+		FIND_CHAIN
+		strcpy(pci.name, chain->name);
+		pci.num_entries= chain->num_entries;
+		pci.refcnt= atomic_read(&chain->refcnt);
+		pci.size= chain->size;
+		pci.policy= chain->policy;
+		strcpy(pci.classifier_name, chain->classifier->name);
+
+		ret= copy_to_user(user, &pci, sizeof(struct pktt_chain_info));
+		if(ret != 0){
+			pktt_error("can't copy chain info");
+			ret=-EFAULT;
+			break;
+		}
+
+		offset = sizeof(struct pktt_chain_info);
+		
+		ret = PKTT_ENTRY_ITERATE( &(chain->entries),
+					  pktt_entry_transform_to_user_helper,
+					  user, &offset);
+		if(ret != 0){ 
+			pktt_error("can't copy all of the entries");
+			ret=-EFAULT;
+		} else *len = offset;
+		break;}
+
+	case PKTT_ENTRY_GET_COUNTERS:{
+		struct pktt_chain *chain;
+		struct pktt_counters c={0, 0};
+		struct pktt_entry *ee;
+		unsigned int i;
+		pktt_info("GET_ENTRY_COUNTERS chain=%s, rule-number=%d",
+			command.chain_name, command.ext.ent.rule_number);
+
+		FIND_CHAIN
+		if(command.ext.ent.rule_number > chain->num_entries){
+			pktt_error("ENTRY_DEL_WITH_NUM bad index");
+			ret=-EINVAL;
+			break;
+		}
+		i=0; ret =0; 
+		list_for_each_entry(ee, &(chain->entries), list)
+			if( i++ == command.ext.ent.rule_number-1 ) break;
+
+		pktt_entry_get_counters(ee, &c);
+		ret = copy_to_user(user, &c, sizeof(struct pktt_counters));
+		if(ret != 0){
+			ret = -EFAULT;
+			pktt_error("can't copy counters to user");
+		}else *len = sizeof(struct pktt_counters);
+
+		break;}
+
+	default:
+		pktt_error("UNknown command -%d-", command.command);
+		ret=-EINVAL;
+		break;
+	}
+
+	pktt_table_unlock(table);
+	return ret;
+}
+
+static int
+pktt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
+{
+	int ret=0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	switch (cmd) {
+	case IPT_SO_GET_INFO: 
+	case IPT_SO_GET_ENTRIES: 
+		return pktt_manage_get_commands( sk->sk_net, user, len);
+		break;
+	default:
+		pktt_error("pktt_get_ctl: unknown request %i", cmd);
+		ret = -EINVAL;
+	}
+
+	return ret;
+}
+
+/* standard target */
+static unsigned int 
+pktt_standard_target_target(struct sk_buff *pskb,
+			const struct net_device *in,
+			const struct net_device *out,
+			unsigned int hooknum,
+			const struct xt_target *target,
+			const void *targinfo){
+	int v= *((int *)targinfo);
+
+	pktt_info("standard target verdict=%i",v);
+
+	if( v == PKTT_RETURN ) return PKTT_RETURN;
+	else if( v == PKTT_CONTINUE ) return PKTT_CONTINUE;
+	else return ((unsigned)(-v) - 1);
+}
+
+static bool
+pktt_standard_target_checkentry(const char *tablename,
+                              const void *entry,
+                              const struct xt_target *target,
+                              void *targinfo,
+                              unsigned int hook_mask){
+	struct xt_entry_target *xt = pktt_entry_get_target(entry);
+	struct xt_standard_target *t = (void*) xt;
+
+	pktt_info("chack an standard target");
+
+	/* Check standard info. */
+	if (xt->u.target_size
+	    != XT_ALIGN(sizeof(struct xt_standard_target))) {
+		pktt_error("standard_check: target size %u != %u",
+			 xt->u.target_size,
+			 XT_ALIGN(sizeof(struct xt_standard_target)));
+		return 0;
+	}
+
+	if (t->verdict < -NF_MAX_VERDICT - 1) {
+		pktt_error("ipt_standard_check: bad negative verdict (%i)",
+			 t->verdict);
+		return 0;
+	}
+	return 1;
+}
+
+//Standard Targets
+static struct xt_target pktt_standard_targets[NPROTO]={{{0,0}}};
+
+//Socket Options
+static struct nf_sockopt_ops pktt_sockopts= {
+	.pf		= PF_INET,
+        .set_optmin     = IPT_BASE_CTL,
+        .set_optmax     = IPT_SO_SET_MAX+1,
+        .set            = pktt_set_ctl,
+        .get_optmin     = IPT_BASE_CTL,
+        .get_optmax     = IPT_SO_GET_MAX+1,
+        .get            = pktt_get_ctl,
+};
+
+#ifdef CONFIG_PROC_FS
+static void *pktt_classifier_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct proc_dir_entry *pde = (struct proc_dir_entry *)seq->private;
+	u_int16_t af = (unsigned long)pde->data;
+
+	mutex_lock(&xt[af].mutex);
+	return seq_list_start(&xt[af].classifier, *pos);
+}
+
+static void *pktt_classifier_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct proc_dir_entry *pde = (struct proc_dir_entry *)seq->private;
+	u_int16_t af = (unsigned long)pde->data;
+
+	return seq_list_next(v, &xt[af].classifier, pos);
+}
+
+static void pktt_classifier_seq_stop(struct seq_file *seq, void *v)
+{
+	struct proc_dir_entry *pde = seq->private;
+	u_int16_t af = (unsigned long)pde->data;
+
+	mutex_unlock(&xt[af].mutex);
+}
+
+static int pktt_classifier_seq_show(struct seq_file *seq, void *v)
+{
+	struct pktt_classifier *classifier = list_entry(v, struct pktt_classifier, list);
+
+	if (strlen(classifier->name))
+		return seq_printf(seq, "%s\n", classifier->name);
+	else
+		return 0;
+}
+
+static const struct seq_operations pktt_classifier_seq_ops = {
+	.start	= pktt_classifier_seq_start,
+	.next	= pktt_classifier_seq_next,
+	.stop	= pktt_classifier_seq_stop,
+	.show	= pktt_classifier_seq_show,
+};
+
+static int pktt_classifier_open(struct inode *inode, struct file *file)
+{
+	int ret;
+
+	ret = seq_open(file, &pktt_classifier_seq_ops);
+	if (!ret) {
+		struct seq_file *seq = file->private_data;
+
+		seq->private = PDE(inode);
+	}
+	return ret;
+}
+
+static const struct file_operations pktt_classifier_ops = {
+	.owner	 = THIS_MODULE,
+	.open	 = pktt_classifier_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = seq_release,
+};
+
+#define FORMAT_CLASSIFIERS "_tables_classifiers"
+#endif /* CONFIG_PROC_FS */
+
+int
+pktt_proto_init(struct net *net, unsigned short family){
+#ifdef CONFIG_PROC_FS
+        char buf[XT_FUNCTION_MAXNAMELEN];
+        struct proc_dir_entry *proc;
+#endif
+	int ret;
+	
+	if(family>=NPROTO) return -EINVAL;
+
+	memset(&pktt_standard_targets[family], 0, sizeof(struct xt_target));
+
+	pktt_standard_targets[family].family 	= family;
+	pktt_standard_targets[family].target 	= pktt_standard_target_target;
+	pktt_standard_targets[family].checkentry= pktt_standard_target_checkentry;
+	pktt_standard_targets[family].targetsize= sizeof(int);
+	pktt_standard_targets[family].me = THIS_MODULE;
+	strlcpy((char *)pktt_standard_targets[family].name, XT_STANDARD_TARGET, 
+					sizeof(pktt_standard_targets[family].name));
+	ret = xt_register_target(&pktt_standard_targets[family]);
+	if(ret) goto err1;
+
+#ifdef CONFIG_PROC_FS
+	strlcpy(buf, xt_prefix[family], sizeof(buf));
+        strlcat(buf, FORMAT_CLASSIFIERS, sizeof(buf));
+        proc = proc_net_fops_create(net, buf, 0440, &pktt_classifier_ops);
+        if (!proc)
+                goto err2;
+        proc->data = (void *)(unsigned long)family;
+#endif 
+
+	ret = xt_proto_init(net, family);
+	if(ret) goto err3;
+
+	return 0;
+err3:
+#ifdef CONFIG_PROC_FS
+        strlcpy(buf, xt_prefix[family], sizeof(buf));
+        strlcat(buf, FORMAT_CLASSIFIERS, sizeof(buf));
+        proc_net_remove(net, buf);
+#endif 
+
+err2:
+	xt_unregister_target(&pktt_standard_targets[family]);
+err1:
+	pktt_error("can't start- net namespace");
+	return ret;
+}
+EXPORT_SYMBOL(pktt_proto_init);
+
+void
+pktt_proto_exit(struct net *net, unsigned short family){
+#ifdef CONFIG_PROC_FS
+        char buf[XT_FUNCTION_MAXNAMELEN];
+
+        strlcpy(buf, xt_prefix[family], sizeof(buf));
+        strlcat(buf, FORMAT_CLASSIFIERS, sizeof(buf));
+        proc_net_remove(net, buf);
+#endif
+	xt_unregister_target(&pktt_standard_targets[family]);
+	xt_proto_fini(net, family);
+}
+EXPORT_SYMBOL(pktt_proto_exit);
+
+
+static int __init
+pkt_tables_init(void){
+	int ret;
+	
+	ret = nf_register_sockopt(&pktt_sockopts);
+	if(ret) return ret;
+
+	printk("pkt_tables: (C) 2005-2008 Hamid Jafarian (hm.t.)\n");
+	return 0;
+}
+
+static void __exit
+pkt_tables_exit(void){
+	nf_unregister_sockopt(&pktt_sockopts);
+}
+
+module_init(pkt_tables_init);
+module_exit(pkt_tables_exit);

