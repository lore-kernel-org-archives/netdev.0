From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 02/09]IPtablestng/KernelSpace - create pkt_tables.h
Date: Mon, 27 Oct 2008 08:13:03 +0330 (IRST)
Message-ID: <20081027044303.52643C64089@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.185.161.20] ([85.185.161.20]:43311 "EHLO host1.ystp.ac.ir"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbYJ0FEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 01:04:47 -0400
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

create pkt_tables.h file:Contains all of the new structures and semantics.

this patch creates a new file named pkt_tables.h. New definitions for tables/cahins/entries, structures used for management activities, and also structurs that are needed for kernelspace/userspace communication are located in this file. 
some important structures are:
	pkt_table:		new definition for tables: as Containor of builtin/userdefined chains.
	pktt_regtable:	for table registeration and subsequent accesses to the table by table's modules(e.g. unregister table)
	pktt_chain:		new definition for chains: as Containor of entries. He also has an element of type 'xt_target': by this, all of the chains can be used as target.
	pktt_entry: 	new definition for entries
	pktt_command:	cammnad structre for communicating between kernel/user spaces
	pktt_classifier: key feature to define/implement and use from diferent classification algorithms.
	

diff --git a/include/linux/netfilter/pkt_tables.h b/include/linux/netfilter/pkt_tables.h
new file mode 100644
index 0000000..c5729f3
--- /dev/null
+++ b/include/linux/netfilter/pkt_tables.h
@@ -0,0 +1,542 @@
+/* Packet Tables Code
+ *
+ * Copyright (C) 2005-2008 Hamid Jafarian(hm.t.) <hamid.jafarian@gmail.com>
+ */
+
+#ifndef _PKT_TABLES_H
+#define _PKT_TABLES_H
+#ifdef __KERNEL__
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <asm/atomic.h>
+#include <net/net_namespace.h>
+
+
+#define pktt_info( str, args...)
+#if 0
+#define pktt_error( str, args...)
+
+	#define pktt_info( str, args...) \
+        	printk( KERN_INFO "%s: " str "\n", __FUNCTION__, ## args)
+#endif
+#define pktt_error( str, args...) \
+       	printk( KERN_ERR  "%s: " str "\n", __FUNCTION__, ## args)
+
+#endif
+#include <linux/types.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+#define PKTT_FUNCTION_MAXNAMELEN 30 
+#define PKTT_TABLE_MAXNAMELEN 32
+#define PKTT_CHAIN_MAXNAMELEN PKTT_TABLE_MAXNAMELEN
+
+/*  verdict for users   */
+#define PKTT_CONTINUE NF_MAX_VERDICT+3
+#define PKTT_RETURN   NF_MAX_VERDICT+4
+/** 
+ * enum policy - define chain policies 
+ */
+enum pktt_chain_policy {cDROP=NF_DROP ,cACCEPT=NF_ACCEPT ,cRETURN=PKTT_RETURN ,
+			cQUEUE=NF_QUEUE};
+
+struct pktt_counters
+{
+	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
+};
+
+/**
+ * name of the linear classifier
+ */
+#define PKTT_LC_NAME "linear"
+
+#ifdef __KERNEL__
+struct pktt_entry
+{
+	struct list_head list;
+
+	/**
+	 * helper pointer for classifiers
+	 */ 
+	void *helper_data;
+
+	/**
+	 * for easy indexing in the link list 
+	 */
+	u_int32_t rank;
+
+	/** 
+ 	 * this is a helper pointer, by this we can transfrom 
+	 * the user data from "pktt_user_entry" to "pktt_entry".
+ 	 */
+	unsigned char pktt_user_entry[0];
+
+	/**
+	 * the protocol family
+	 */
+	u_int16_t family;
+
+	union{
+		struct ipt_ip ip4;
+	} pkt_header;
+
+	/** 
+	 * Mark with fields that we care about. 
+	 */
+	unsigned int nfcache;
+
+	/** 
+	 * Size of matches 
+	 */
+	u_int16_t target_offset;
+
+	/**
+ 	 * size of padded memory:  pktt_user_entry + matches + target 
+ 	 */
+	u_int32_t size;
+
+	/* 
+	 * Packet and byte counters. per CPU 
+	 */
+	struct pktt_counters counters[NR_CPUS];
+
+	/** 
+	 * The matches (if any), then target. 
+	 */
+	unsigned char elems[0];
+};
+#endif /* __KERNEL__ */
+
+/**
+ * this is a small image from "pktt_entry" that the users 
+ * use this to transform entry information to the kernel.
+ */
+#ifdef __KERNEL__
+struct pktt_user_entry /* used in the kernel space */
+#else 
+struct pktt_entry /* used in the user space */
+#endif
+{
+	/**
+	 * the protocol family
+	 */
+	u_int16_t family;
+
+	union{
+		struct ipt_ip ip4;
+	} pkt_header;
+
+	unsigned int nfcache;
+
+	u_int16_t target_offset;
+
+	u_int32_t size;
+
+	struct pktt_counters counters;
+
+	unsigned char elems[0];
+};
+
+/* Helper functions */
+static __inline__ struct xt_entry_target *
+pktt_entry_get_target(const struct pktt_entry *e)
+{
+	return (void *)e->elems + e->target_offset;
+}
+
+#ifdef __KERNEL__
+struct pktt_chain;
+
+/**
+ * struct pktt_classifier - use this to define a classifier.
+ *
+ * - Note, at the same time, different chains can use from one classifier
+ * to manage their search activities.
+ *
+ * - In one chain all of this functions will be called sequentially.. thus
+ * for one chain (one use): you don't need to use any lock to manage
+ * critical sections.
+ *
+ * - But if in your algoritm, different uses( means: using in different chains )
+ * have side affects on each other, you should manage them by your
+ * appropriate locks.
+ *
+ *      BEST IDEA: try to use from implementations with no side affects on
+ *      each other for different and multiple uses.
+ *
+ * - this functions ( except 'init' ) is called from spin locked protected
+ * areas. thus sleeping on them ( rescheduling the system ) is equal to die..
+ *
+ * - kmalloc and kfree are the best choices for memory allocations..
+ */
+struct pktt_classifier
+{
+        struct list_head list;
+
+        const char name[PKTT_FUNCTION_MAXNAMELEN-1];
+
+        /* initialize the classifier .. this is the first one that be called.
+         * it must return a pointer to a context, other functions will use
+         * this context to communicate with the classifier.
+         * NOTE:
+         *      different chains can use from one classifier at the same time.
+         */
+        void *(*init)(struct pktt_chain *chain);
+
+        /* flushing the classifier
+         *              ( detaching all of the rules from the classifier )
+         */
+        void (*flush)(void *c_context);
+        
+	/* attaching an entry to the classifier 
+	 */
+	int (*attach_rule)(void *c_context, struct pktt_entry *e);
+
+        /* detaching an entry from the classifier
+         */
+        int (*detach_rule)(void *c_context, struct pktt_entry *e);
+
+        /* destroying the classifier .. this is the last one that be called.
+         */
+        void (*destroy)(void *c_context);//, struct pktt_entry *e);
+
+        /* called when the chain recieves a packet. 
+         * he will return an entry with the lowest cost(rank) between
+         * the entries that match the packet.
+         *
+         * RETURN: NULL means "there is no matched entry for this packet".
+         */
+        struct pktt_entry *(*first_match)(void *c_context,
+        			   	const struct sk_buff *skb ,
+                                   	const struct net_device * in_dev ,
+                                   	const struct net_device * out_dev);
+
+        /* the next entry that match the packet.
+         * RETURN NULL means there is no more entry for this packet.
+         */
+        struct pktt_entry *(*next_match )(void *c_context ,
+                                   	const struct pktt_entry *prev_entry,
+	                                const struct sk_buff *skb,
+                                   	const struct net_device * in_dev,
+                                   	const struct net_device * out_dev);
+        /* OWNER */
+        struct module *owner;
+
+	unsigned short family;
+};
+
+/**
+ * pktt_chain_target - allow us to use chains as target
+ */
+struct pktt_chain_target
+{
+        struct xt_entry_target target;
+        unsigned long chain;
+};
+
+/**
+ * struct pktt_chain - defines the chains in the tabels
+ * @name: a unique human readable name for this chain
+ * @table: name of the table that the chain belongs to.
+ * @my_hooks: is a hook mask. determine the hooks that the packet flow may come
+                        from them.
+ * @refcnt: refrence counter .. HOWmany used in targets?
+ * @target: prepare this chance to use from the chain as a target
+ * @entries: list of rules in this chain.
+ * @num_entries: number of rules(entries) in this chain
+ * @size: size of the chain in Byte (size of rules)
+ * @classifier: chain classifier
+ * @context: classifier context
+ * @policy:  chain policy
+ */
+struct pktt_chain{
+        struct list_head list;
+
+        char name[PKTT_CHAIN_MAXNAMELEN];
+
+        struct pkt_table *table;
+        unsigned int my_hooks;
+
+        atomic_t refcnt;
+        struct xt_target target;
+
+        struct list_head entries;
+        __u32 num_entries;
+        __u64 size;
+
+        struct pktt_classifier *classifier;
+        void *context;
+
+        enum pktt_chain_policy policy;
+};
+
+/**
+ * struct pkt_table - defines the tables in the classifier
+ * @name: a unique human readable name for this table
+ * @valid_hooks: What hooks you will enter on
+ * @chains: list of table chains
+ * @hook_entry: entry points for IP hooks
+ * @num_chains: number of table chains
+ * @lock: protect entries management ( user - kernel )
+ * @family: defines the protocol family that he belongs to.
+ * @owner: table owner
+ */
+struct pkt_table{
+        struct list_head list;
+
+        char name[PKTT_TABLE_MAXNAMELEN];
+
+        unsigned int valid_hooks;
+
+        struct list_head chains;
+        struct pktt_chain *hook_entry[NF_INET_NUMHOOKS];
+        __u32 num_chains;
+
+        rwlock_t lock;
+
+	unsigned short family;
+
+        struct module *owner;
+};
+
+/* struct pktt_regtable - infos for registering a table
+ * @name: a unique human readable name for the table
+ * @valid_hooks: What hooks you will enter on
+ * @hooks_policy: policy of each hook ( just valid hooks )
+ * @family: defines the protocol family that he belongs to.
+ * @owner: i am owner
+ * @table: the pointer to the table that is registered. this is filled by
+                the pktt_register_table function.
+ */
+struct pktt_regtable{
+        char name[PKTT_TABLE_MAXNAMELEN];
+
+        unsigned int valid_hooks;
+        enum pktt_chain_policy hooks_policy[NF_INET_NUMHOOKS];
+
+	unsigned short family;
+
+        struct module *owner;
+        struct pkt_table *table;
+};
+#endif /* __KERNEL__ */
+
+/**
+ * struct pktt_regchain - infos for registering a chain
+ * @name: a unique human readable name for the chain
+ * @policy: chain policy
+ */
+struct pktt_regchain{
+        char name[PKTT_CHAIN_MAXNAMELEN];
+        enum pktt_chain_policy policy;
+};
+
+/**
+ * commands for communicating with the user level to manage the classifier.
+ * they are the "iptables" cammands ; like -A -D ...
+ *
+ * all of them needs a table and a chain name: except the IPT_TABLE_GET_INFO
+ * that just needs table name.
+ * some also needs rule number. other needs entry or chain information.
+ */
+// used with set socket option
+#define PKTT_ENTRY_ADD           0x0000U /* adding an entry to a chain */
+        /* format: #/table-name/chain-name/rule-number/entry--informations--... */
+        /* NOTE:
+         * rule-number >= 1 : insert at this position
+         * rule-number >= chain->num_entries : append
+         */
+#define PKTT_ENTRY_DEL_WITH_RULE 0x0001U /* deleting an entry: use rule match */
+        /* format: #/table-name/chain-name/ entry--informations--... */
+#define PKTT_ENTRY_DEL_WITH_NUM  0x0002U /* deleting an entry: use rule number */
+        /* format: #/table-name/chain-name/rule-number */
+#define PKTT_ENTRY_REPLACE       0x0004U
+        /* format: #/table-name/chain-name/rule-number/ entry-informations-...*/
+#define PKTT_ENTRY_SET_COUNTER   0x0008U
+        /* format: #/table-name/chain-name/rule-number/counters */
+#define PKTT_CHAIN_FLUSH         0x0010U
+        /* format: #/table-name/chain-name */
+#define PKTT_CHAIN_ZERO          0x0020U
+        /* format: #/table-name/chain-name */
+#define PKTT_CHAIN_NEW           0x0040U
+        /* format: #/table-name/chain-name */
+#define PKTT_CHAIN_DELETE        0x0080U
+        /* format: #/table-name/chain-name */
+#define PKTT_CHAIN_RENAME        0x0100U
+        /* format: #/table-name/chain-name/new-chain-name */
+#define PKTT_CHAIN_SET_POLICY    0x0200U
+        /* format: #/table-name/chain-name/Policy */
+        /* NOTE:
+         * Policy is a number ( enum policy )
+         */
+#define PKTT_CHAIN_CHG_CLASSIFIER        0x0400U /*change the chain classifier*/
+        /* format: #/table-name/chain-name/new-classifier */
+
+// used with get socket option
+#define PKTT_TABLE_GET_INFO      0x0800U /* just get table info */
+        /* format: #/table-name */
+#define PKTT_TABLE_CHAINS_GET_INFO       0x1000U /*also the information of table chains*/
+        /* format: #/table-name */
+#define PKTT_CHAIN_GET_INFO      0x2000U /* get a table chain info */
+        /* format: #/table-name/chain-name */
+#define PKTT_CHAIN_GET_ENTRIES   0x4000U /* get the entries of a chain */
+        /* format: #/table-name/chain-name */
+#define PKTT_ENTRY_GET_COUNTERS  0x8000U
+        /* format: #/table-name/chain-name/rule-number */
+
+/**
+ * struct pktt_command - use from this structure to send (from user level) and recieve (in the kernel level) the commands.
+ * @command: is command number
+ * @family: network family
+ * @table_name: the table that the command must be execed on it
+ * @chain_name: the chain that the command must be execed on it
+ * @index: index of insertion ( for PKTT_ENTRY_ADD )
+ * @rule_number:  rule number for deleting or replacing
+                        (for PKTT_ENTRY_DEL_WITH_NUM and PKTT_ENTRY_REPLACE)
+ * @new_chain_name: new name for renaming the chain @chain_name
+                        ( PKTT_CHAIN_RENAME )
+ * @policy: for setting the chain policy ( PKTT_CHAIN_SET_POLICY )
+ * @data: a pointer to the payload.
+                the payload is an entry information for the commands that need
+                entry informations. the payload is an instance of the
+                "pktt_entry" structure.
+ */
+#define pktt_command_t    u_int16_t
+struct pktt_command{
+        pktt_command_t command;
+
+	__u16 family;
+
+        char table_name[PKTT_TABLE_MAXNAMELEN];
+        char chain_name[PKTT_CHAIN_MAXNAMELEN];
+
+        union{
+                struct{
+                        __u32 rule_number;
+                        struct pktt_counters counter;
+                } ent;
+
+                char new_chain_name[PKTT_CHAIN_MAXNAMELEN];
+                char new_classifier[PKTT_FUNCTION_MAXNAMELEN-1];
+
+                __u8 policy;
+        } ext;
+
+        unsigned char data[0];
+};
+
+/**
+ * the two structures that is mentioned below are for communicating
+ * with the user level:
+ *
+ * the answer of the PKTT_TABLE_GET_INFO command is an instance of the
+ *      pkt_table_info structure.. by this the user can see how many chains
+ *      the table has and can allocate sufficient memory to call the
+ *      PKTT_GET_TABLE_CHAINS_INFO command.
+ *
+ * answer of the PKTT_TABLE_CHAIN_GET_INFO command is an instance of the
+ *      pkt_table_info structure with "num_chains" instance of the
+ *      pktt_chain_info structure as its payload. by this command the user
+ *      can learn about the chains and allocate sufficient memory to call
+ *      the PKTT_CHAIN_GET_ENTRIES command.
+ *
+ * if user know the name of a chain, he can use from the PKTT_CHAIN_GET_INFO.
+ *      its answer is an instance of the pktt_chain_info structure. he can use
+ *      from this to allocate sufficient memory to call the
+ *      PKTT_CHAIN_GET_ENTRIES command.
+ *
+ * for getting a chain entries the user must call the PKTT_CHAIN_GET_ENTRIES
+ *      command. its answer is an instance of the pktt_chain_info structure
+ *      with its entries as his payload.
+ *
+ */
+struct pkt_table_info{
+        char name[PKTT_TABLE_MAXNAMELEN];
+        u_int32_t num_chains;
+        unsigned int valid_hooks;
+
+        unsigned char chains_info[0];
+};
+
+struct pktt_chain_info{
+        char name[PKTT_CHAIN_MAXNAMELEN];
+
+        u_int64_t size;
+        u_int32_t num_entries;
+        u_int16_t refcnt;
+
+        char classifier_name[PKTT_FUNCTION_MAXNAMELEN-1];
+
+        u_int8_t policy;
+
+        unsigned char entries[0];
+};
+
+/** 
+ * PKTT_ENTRY_MATCH_ITERATE - iterate on the matches of an entry
+ * @e: pointer to the begining of the entry
+ * @fn: function that must be called for each match
+ *
+ * NOTE: @fn should returns 0 to iteration be continued
+ */
+#define PKTT_ENTRY_MATCH_ITERATE(e, fn, args...)	\
+({							\
+	unsigned int __i;				\
+	int __ret = 0;					\
+	struct xt_entry_match *__match;			\
+							\
+	for (__i = 0;					\
+	     __i < ((e)->target_offset);		\
+	     __i += __match->u.match_size) {		\
+		__match = (void *)(e)->elems + __i;	\
+							\
+		__ret = fn(__match , ## args);		\
+		if (__ret != 0)				\
+			break;				\
+	}						\
+	__ret;						\
+})
+
+/** 
+ * PKTT_ENTRY_ITERATE - iterate on the entries of a chain
+ * @entries: address of the head of chain entries
+ * @fn: function that must be called for each entry
+ *
+ * NOTE: @fn should returns 0 to iteration be continued
+ */
+#define PKTT_ENTRY_ITERATE(entries, fn, args...)	\
+({							\
+	int __ret = 0;					\
+	struct pktt_entry *__i=(void *)(entries)->next;	\
+							\
+	while ((void *)__i!=(void *)(entries)){ 	\
+		__ret = fn(__i , ## args);		\
+		if (__ret != 0)				\
+			break;				\
+							\
+		__i = (void *)__i->list.next;		\
+	}						\
+	__ret;						\
+})
+
+#ifdef __KERNEL__
+
+//extern struct pktt_classifier *pktt_find_classifier(int af, const char *name);
+
+extern int pktt_register_table(struct net *net, struct pktt_regtable *regtable);
+extern void pktt_unregister_table(struct pktt_regtable *regtable);
+
+extern int pktt_register_classifier(struct pktt_classifier *classifier);
+extern void pktt_unregister_classifier(struct pktt_classifier *classifier);
+
+extern unsigned int pktt_table_trigger(struct sk_buff *pskb,
+	     				unsigned int hook,
+	     				const struct net_device *in,
+	     				const struct net_device *out,
+	     				struct pktt_regtable *regtable);
+
+extern int pktt_proto_init(struct net *net, unsigned short family);
+extern void pktt_proto_exit(struct net *net, unsigned short family);
+#endif /* __KERNEL__ */
+
+#endif /* _PKT_TABLES_H */

