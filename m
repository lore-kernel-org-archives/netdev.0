From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 02/05]IPtablestng/UserSpace - patch libiptc.*
Date: Mon, 27 Oct 2008 08:54:36 +0330 (IRST)
Message-ID: <20081027052436.504DBC64093@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.185.161.20] ([85.185.161.20]:46725 "EHLO host1.ystp.ac.ir"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbYJ0FqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 01:46:22 -0400
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

modify the way to communicate with kernel. 

all of the management activities are moved to kernel. by this approach and also because of new structures & command base manner for communicating with kernel, libiptc.c is reimplemented from scratch.
he uses 'pktt_command' to communicate with kernel.
in each 'add/delete/replace/save/restore' commands just one rule per transaction is transformed between kernel&user Spaces.

diff --git a/libiptc/libiptc.c b/libiptc/libiptc.c
index d0f51b4..28f6085 100644
--- a/libiptc/libiptc.c
+++ b/libiptc/libiptc.c
@@ -1,1313 +1,266 @@
-/* Library which manipulates firewall rules.  Version $Revision$ */
-
-/* Architecture of firewall rules is as follows:
- *
- * Chains go INPUT, FORWARD, OUTPUT then user chains.
- * Each user chain starts with an ERROR node.
- * Every chain ends with an unconditional jump: a RETURN for user chains,
- * and a POLICY for built-ins.
- */
-
-/* (C) 1999 Paul ``Rusty'' Russell - Placed under the GNU GPL (See
- * COPYING for details). 
- * (C) 2000-2004 by the Netfilter Core Team <coreteam@netfilter.org>
+/* Packet Tables Code - Firewal Manipulation Library
  *
- * 2003-Jun-20: Harald Welte <laforge@netfilter.org>:
- *	- Reimplementation of chain cache to use offsets instead of entries
- * 2003-Jun-23: Harald Welte <laforge@netfilter.org>:
- * 	- performance optimization, sponsored by Astaro AG (http://www.astaro.com/)
- * 	  don't rebuild the chain cache after every operation, instead fix it
- * 	  up after a ruleset change.  
- * 2004-Aug-18: Harald Welte <laforge@netfilter.org>:
- * 	- futher performance work: total reimplementation of libiptc.
- * 	- libiptc now has a real internal (linked-list) represntation of the
- * 	  ruleset and a parser/compiler from/to this internal representation
- * 	- again sponsored by Astaro AG (http://www.astaro.com/)
+ * Copyright (C) 2005-2008 Hamid Jafarian(hm.t.) <hamid.jafarian@gmail.com>
+ * Licence: GPLv2
  */
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <xtables.h>
-
-#include "linux_list.h"
-
-//#define IPTC_DEBUG2 1
 
-#ifdef IPTC_DEBUG2
-#include <fcntl.h>
-#define DEBUGP(x, args...)	fprintf(stderr, "%s: " x, __FUNCTION__, ## args)
-#define DEBUGP_C(x, args...)	fprintf(stderr, x, ## args)
-#else
-#define DEBUGP(x, args...)
-#define DEBUGP_C(x, args...)
+#ifndef IPT_LIB_DIR
+#define IPT_LIB_DIR "/usr/local/lib/iptables"
 #endif
 
-#ifdef DEBUG
-#define debug(x, args...)	fprintf(stderr, x, ## args)
-#else
-#define debug(x, args...)
+#ifndef __OPTIMIZE__
+STRUCT_ENTRY_TARGET *
+GET_TARGET(STRUCT_ENTRY *e)
+{
+	return (void *)e->elems + e->target_offset;
+}
 #endif
 
 static int sockfd = -1;
-static int sockfd_use = 0;
 static void *iptc_fn = NULL;
 
-static const char *hooknames[] = {
-	[HOOK_PRE_ROUTING]	= "PREROUTING",
-	[HOOK_LOCAL_IN]		= "INPUT",
-	[HOOK_FORWARD]		= "FORWARD",
-	[HOOK_LOCAL_OUT]	= "OUTPUT",
-	[HOOK_POST_ROUTING]	= "POSTROUTING",
+static const char *hooknames[]
+= { [HOOK_PRE_ROUTING]  "PREROUTING",
+    [HOOK_LOCAL_IN]     "INPUT",
+    [HOOK_FORWARD]      "FORWARD",
+    [HOOK_LOCAL_OUT]    "OUTPUT",
+    [HOOK_POST_ROUTING] "POSTROUTING",
 #ifdef HOOK_DROPPING
-	[HOOK_DROPPING]		= "DROPPING"
+    [HOOK_DROPPING]	"DROPPING"
 #endif
 };
 
-/* Convenience structures */
-struct ipt_error_target
-{
-	STRUCT_ENTRY_TARGET t;
-	char error[TABLE_MAXNAMELEN];
-};
-
-struct chain_head;
-struct rule_head;
-
-struct counter_map
-{
-	enum {
-		COUNTER_MAP_NOMAP,
-		COUNTER_MAP_NORMAL_MAP,
-		COUNTER_MAP_ZEROED,
-		COUNTER_MAP_SET
-	} maptype;
-	unsigned int mappos;
-};
-
-enum iptcc_rule_type {
-	IPTCC_R_STANDARD,		/* standard target (ACCEPT, ...) */
-	IPTCC_R_MODULE,			/* extension module (SNAT, ...) */
-	IPTCC_R_FALLTHROUGH,		/* fallthrough rule */
-	IPTCC_R_JUMP,			/* jump to other chain */
-};
-
-struct rule_head
-{
-	struct list_head list;
-	struct chain_head *chain;
-	struct counter_map counter_map;
-
-	unsigned int index;		/* index (needed for counter_map) */
-	unsigned int offset;		/* offset in rule blob */
-
-	enum iptcc_rule_type type;
-	struct chain_head *jump;	/* jump target, if IPTCC_R_JUMP */
-
-	unsigned int size;		/* size of entry data */
-	STRUCT_ENTRY entry[0];
-};
-
-struct chain_head
-{
-	struct list_head list;
-	char name[TABLE_MAXNAMELEN];
-	unsigned int hooknum;		/* hook number+1 if builtin */
-	unsigned int references;	/* how many jumps reference us */
-	int verdict;			/* verdict if builtin */
-
-	STRUCT_COUNTERS counters;	/* per-chain counters */
-	struct counter_map counter_map;
-
-	unsigned int num_rules;		/* number of rules in list */
-	struct list_head rules;		/* list of rules */
-
-	unsigned int index;		/* index (needed for jump resolval) */
-	unsigned int head_offset;	/* offset in rule blob */
-	unsigned int foot_index;	/* index (needed for counter_map) */
-	unsigned int foot_offset;	/* offset in rule blob */
-};
-
 STRUCT_TC_HANDLE
 {
-	int changed;			 /* Have changes been made? */
-
-	struct list_head chains;
-	
-	struct chain_head *chain_iterator_cur;
-	struct rule_head *rule_iterator_cur;
-
-	unsigned int num_chains;         /* number of user defined chains */
-
-	struct chain_head **chain_index;   /* array for fast chain list access*/
-	unsigned int        chain_index_sz;/* size of chain index array */
-
-	STRUCT_GETINFO info;
-	STRUCT_GET_ENTRIES *entries;
-};
-
-/* allocate a new chain head for the cache */
-static struct chain_head *iptcc_alloc_chain_head(const char *name, int hooknum)
-{
-	struct chain_head *c = malloc(sizeof(*c));
-	if (!c)
-		return NULL;
-	memset(c, 0, sizeof(*c));
-
-	strncpy(c->name, name, TABLE_MAXNAMELEN);
-	c->hooknum = hooknum;
-	INIT_LIST_HEAD(&c->rules);
-
-	return c;
-}
+	/* Any Changes in the number of the table's Chains */
+	int chains_no_changed;
+	/* Any changes in the number of the table's entries */
+	int entries_no_changed;
+	/* Any changes in the info of the table's entries */
+	int entries_info_changed;
 
-/* allocate and initialize a new rule for the cache */
-static struct rule_head *iptcc_alloc_rule(struct chain_head *c, unsigned int size)
-{
-	struct rule_head *r = malloc(sizeof(*r)+size);
-	if (!r)
-		return NULL;
-	memset(r, 0, sizeof(*r));
+	/* this is the table header */
+	STRUCT_TABLE_INFO table; 
 
-	r->chain = c;
-	r->size = size;
-
-	return r;
-}
-
-/* notify us that the ruleset has been modified by the user */
-static inline void
-set_changed(TC_HANDLE_T h)
-{
-	h->changed = 1;
-}
+	/* this contains the table and its chains headers: table_info|chain#1_info|... */
+	STRUCT_TABLE_INFO *table_chains_headers;
 
-#ifdef IPTC_DEBUG
-static void do_check(TC_HANDLE_T h, unsigned int line);
-#define CHECK(h) do { if (!getenv("IPTC_NO_CHECK")) do_check((h), __LINE__); } while(0)
-#else
-#define CHECK(h)
-#endif
+	/* chain iterator: point to the current chain */
+	STRUCT_CHAIN_INFO *chains_iterator;
 
+	/* a cache for entries of a chain */
+	/* its memory map: chain-info| entries .. */
+	STRUCT_CHAIN_INFO *entries_cache;
 
-/**********************************************************************
- * iptc blob utility functions (iptcb_*)
- **********************************************************************/
+	/* point to the end of the chain entries (stored in "entries_cache"*/
+	STRUCT_ENTRY *end_of_entries;
 
-static inline int
-iptcb_get_number(const STRUCT_ENTRY *i,
-	   const STRUCT_ENTRY *seek,
-	   unsigned int *pos)
-{
-	if (i == seek)
-		return 1;
-	(*pos)++;
-	return 0;
-}
+	/* Array of hook names */
+	const char **hooknames;
 
-static inline int
-iptcb_get_entry_n(STRUCT_ENTRY *i,
-	    unsigned int number,
-	    unsigned int *pos,
-	    STRUCT_ENTRY **pe)
-{
-	if (*pos == number) {
-		*pe = i;
-		return 1;
-	}
-	(*pos)++;
-	return 0;
-}
+	unsigned int cache_num_chains;
+	unsigned int cache_num_builtins;
 
-static inline STRUCT_ENTRY *
-iptcb_get_entry(TC_HANDLE_T h, unsigned int offset)
-{
-	return (STRUCT_ENTRY *)((char *)h->entries->entrytable + offset);
-}
+};
 
-static unsigned int
-iptcb_entry2index(const TC_HANDLE_T h, const STRUCT_ENTRY *seek)
+static void
+set_changed(TC_HANDLE_T h, int who/* 0:chains 1:entries_no 2:entries_info else all*/)
 {
-	unsigned int pos = 0;
-
-	if (ENTRY_ITERATE(h->entries->entrytable, h->entries->size,
-			  iptcb_get_number, seek, &pos) == 0) {
-		fprintf(stderr, "ERROR: offset %u not an entry!\n",
-			(unsigned int)((char *)seek - (char *)h->entries->entrytable));
-		abort();
+	switch(who){
+		case 0: h->chains_no_changed = 1; 
+		case 1: h->entries_no_changed = 1;
+		case 2: h->entries_info_changed = 1; break;
+		default:h->chains_no_changed = h->entries_no_changed = h->entries_info_changed = 1; break;
 	}
-	return pos;
+	return;
 }
 
-static inline STRUCT_ENTRY *
-iptcb_offset2entry(TC_HANDLE_T h, unsigned int offset)
+/* Allocate handle space */
+static TC_HANDLE_T
+alloc_handle()
 {
-	return (STRUCT_ENTRY *) ((void *)h->entries->entrytable+offset);
-}
+	size_t len;
+	TC_HANDLE_T h;
 
+	len = sizeof(STRUCT_TC_HANDLE);
 
-static inline unsigned long
-iptcb_entry2offset(const TC_HANDLE_T h, const STRUCT_ENTRY *e)
-{
-	return (void *)e - (void *)h->entries->entrytable;
-}
+	h=malloc(len);
+	if(!h) {errno = ENOMEM; return NULL;}
 
-static inline unsigned int
-iptcb_offset2index(const TC_HANDLE_T h, unsigned int offset)
-{
-	return iptcb_entry2index(h, iptcb_offset2entry(h, offset));
+	h->cache_num_chains = 0;
+	h->cache_num_builtins = 0;
+	
+	h->table_chains_headers = NULL;
+	h->entries_cache = NULL;
+	return h;
 }
 
-/* Returns 0 if not hook entry, else hooknumber + 1 */
-static inline unsigned int
-iptcb_ent_is_hook_entry(STRUCT_ENTRY *e, TC_HANDLE_T h)
+static int populate_cache(TC_HANDLE_T h)
 {
+	STRUCT_COMMAND *cmd;
 	unsigned int i;
+	socklen_t s;
 
-	for (i = 0; i < NUMHOOKS; i++) {
-		if ((h->info.valid_hooks & (1 << i))
-		    && iptcb_get_entry(h, h->info.hook_entry[i]) == e)
-			return i+1;
-	}
-	return 0;
-}
-
-
-/**********************************************************************
- * Chain index (cache utility) functions
- **********************************************************************
- * The chain index is an array with pointers into the chain list, with
- * CHAIN_INDEX_BUCKET_LEN spacing.  This facilitates the ability to
- * speedup chain list searching, by find a more optimal starting
- * points when searching the linked list.
- *
- * The starting point can be found fast by using a binary search of
- * the chain index. Thus, reducing the previous search complexity of
- * O(n) to O(log(n/k) + k) where k is CHAIN_INDEX_BUCKET_LEN.
- *
- * A nice property of the chain index, is that the "bucket" list
- * length is max CHAIN_INDEX_BUCKET_LEN (when just build, inserts will
- * change this). Oppose to hashing, where the "bucket" list length can
- * vary a lot.
- */
-#ifndef CHAIN_INDEX_BUCKET_LEN
-#define CHAIN_INDEX_BUCKET_LEN 40
-#endif
-
-/* Another nice property of the chain index is that inserting/creating
- * chains in chain list don't change the correctness of the chain
- * index, it only causes longer lists in the buckets.
- *
- * To mitigate the performance penalty of longer bucket lists and the
- * penalty of rebuilding, the chain index is rebuild only when
- * CHAIN_INDEX_INSERT_MAX chains has been added.
- */
-#ifndef CHAIN_INDEX_INSERT_MAX
-#define CHAIN_INDEX_INSERT_MAX 355
-#endif
-
-static inline unsigned int iptcc_is_builtin(struct chain_head *c);
-
-
-/* Use binary search in the chain index array, to find a chain_head
- * pointer closest to the place of the searched name element.
- *
- * Notes that, binary search (obviously) requires that the chain list
- * is sorted by name.
- */
-static struct list_head *
-iptcc_bsearch_chain_index(const char *name, unsigned int *idx, TC_HANDLE_T handle)
-{
-	unsigned int pos, end;
-	int res;
-
-	struct list_head *list_pos;
-	list_pos=&handle->chains;
-
-	/* Check for empty array, e.g. no user defined chains */
-	if (handle->chain_index_sz == 0) {
-		debug("WARNING: handle->chain_index_sz == 0\n");
-		return list_pos;
-	}
-
-	/* Init */
-	end = handle->chain_index_sz;
-	pos = end / 2;
-
-	debug("bsearch Find chain:%s (pos:%d end:%d)\n", name, pos, end);
-
-	/* Loop */
- loop:
-	if (!handle->chain_index[pos]) {
-		fprintf(stderr, "ERROR: NULL pointer chain_index[%d]\n", pos);
-		return &handle->chains; /* Be safe, return orig start pos */
-	}
-
-	res = strcmp(name, handle->chain_index[pos]->name);
-	list_pos = &handle->chain_index[pos]->list;
-	*idx = pos;
-
-	debug("bsearch Index[%d] name:%s res:%d ",
-	      pos, handle->chain_index[pos]->name, res);
-
-	if (res == 0) { /* Found element, by direct hit */
-		debug("[found] Direct hit pos:%d end:%d\n", pos, end);
-		return list_pos;
-	} else if (res < 0) { /* Too far, jump back */
-		end = pos;
-		pos = pos / 2;
-
-		/* Exit case: First element of array */
-		if (end == 0) {
-			debug("[found] Reached first array elem (end%d)\n",end);
-			return list_pos;
-		}
-		debug("jump back to pos:%d (end:%d)\n", pos, end);
-		goto loop;
-	} else if (res > 0 ){ /* Not far enough, jump forward */
-
-		/* Exit case: Last element of array */
-		if (pos == handle->chain_index_sz-1) {
-			debug("[found] Last array elem (end:%d)\n", end);
-			return list_pos;
-		}
-
-		/* Exit case: Next index less, thus elem in this list section */
-		res = strcmp(name, handle->chain_index[pos+1]->name);
-		if (res < 0) {
-			debug("[found] closest list (end:%d)\n", end);
-			return list_pos;
-		}
-
-		pos = (pos+end)/2;
-		debug("jump forward to pos:%d (end:%d)\n", pos, end);
-		goto loop;
-	}
-
-	return list_pos;
-}
-
-#ifdef DEBUG
-/* Trivial linear search of chain index. Function used for verifying
-   the output of bsearch function */
-static struct list_head *
-iptcc_linearly_search_chain_index(const char *name, TC_HANDLE_T handle)
-{
-	unsigned int i=0;
-	int res=0;
-
-	struct list_head *list_pos;
-	list_pos = &handle->chains;
+	if(!h->chains_no_changed && !h->entries_no_changed) return 1;
 
-	if (handle->chain_index_sz)
-		list_pos = &handle->chain_index[0]->list;
+	if(h->chains_no_changed){
+		s = (sizeof(STRUCT_COMMAND) > sizeof(STRUCT_TABLE_INFO))?
+			sizeof(STRUCT_COMMAND):sizeof(STRUCT_TABLE_INFO);
 
-	/* Linearly walk of chain index array */
+		cmd= malloc(s); 
+		if(!cmd){errno= ENOMEM; return 0;}
 
-	for (i=0; i < handle->chain_index_sz; i++) {
-		if (handle->chain_index[i]) {
-			res = strcmp(handle->chain_index[i]->name, name);
-			if (res > 0)
-				break; // One step too far
-			list_pos = &handle->chain_index[i]->list;
-			if (res == 0)
-				break; // Direct hit
+		cmd->command = PKTT_TABLE_GET_INFO;
+		strcpy(cmd->table_name, h->table.name); 
+		cmd->family = TC_AF;
+	
+		if (getsockopt(sockfd, TC_IPPROTO, SO_GET_INFO, cmd, &s)< 0){
+			errno = EFAULT; free(cmd);
+			return 0;
 		}
+		memcpy(&h->table, cmd, sizeof(STRUCT_TABLE_INFO));
+		free(cmd);
 	}
+	h->chains_no_changed = 0;
 
-	return list_pos;
-}
-#endif
-
-static int iptcc_chain_index_alloc(TC_HANDLE_T h)
-{
-	unsigned int list_length = CHAIN_INDEX_BUCKET_LEN;
-	unsigned int array_elems;
-	unsigned int array_mem;
-
-	/* Allocate memory for the chain index array */
-	array_elems = (h->num_chains / list_length) +
-                      (h->num_chains % list_length ? 1 : 0);
-	array_mem   = sizeof(h->chain_index) * array_elems;
-
-	debug("Alloc Chain index, elems:%d mem:%d bytes\n",
-	      array_elems, array_mem);
-
-	h->chain_index = malloc(array_mem);
-	if (!h->chain_index) {
-		h->chain_index_sz = 0;
-		return -ENOMEM;
-	}
-	memset(h->chain_index, 0, array_mem);
-	h->chain_index_sz = array_elems;
-
-	return 1;
-}
-
-static void iptcc_chain_index_free(TC_HANDLE_T h)
-{
-	h->chain_index_sz = 0;
-	free(h->chain_index);
-}
-
-
-#ifdef DEBUG
-static void iptcc_chain_index_dump(TC_HANDLE_T h)
-{
-	unsigned int i = 0;
-
-	/* Dump: contents of chain index array */
-	for (i=0; i < h->chain_index_sz; i++) {
-		if (h->chain_index[i]) {
-			fprintf(stderr, "Chain index[%d].name: %s\n",
-				i, h->chain_index[i]->name);
-		}
+	if(h->table_chains_headers){
+		free(h->table_chains_headers);
+		h->table_chains_headers = NULL;
 	}
-}
-#endif
+	s= (sizeof(STRUCT_COMMAND) > sizeof(STRUCT_TABLE_INFO))?
+			sizeof(STRUCT_COMMAND):sizeof(STRUCT_TABLE_INFO);
+	s+= h->table.num_chains * sizeof(STRUCT_CHAIN_INFO);
 
-/* Build the chain index */
-static int iptcc_chain_index_build(TC_HANDLE_T h)
-{
-	unsigned int list_length = CHAIN_INDEX_BUCKET_LEN;
-	unsigned int chains = 0;
-	unsigned int cindex = 0;
-	struct chain_head *c;
+	cmd = malloc(s); 
+	if(!cmd){errno= ENOMEM; return 0;}
 
-	/* Build up the chain index array here */
-	debug("Building chain index\n");
+	h->cache_num_chains = 0;
+	h->cache_num_builtins = 0;
 
-	debug("Number of user defined chains:%d bucket_sz:%d array_sz:%d\n",
-		h->num_chains, list_length, h->chain_index_sz);
+	cmd->command = PKTT_TABLE_CHAINS_GET_INFO;
+	strcpy(cmd->table_name, h->table.name);
+	cmd->family = TC_AF;
 
-	if (h->chain_index_sz == 0)
+	if(getsockopt(sockfd, TC_IPPROTO, SO_GET_INFO, cmd, &s ) <0 ){
+		free(cmd); errno = EFAULT;
 		return 0;
-
-	list_for_each_entry(c, &h->chains, list) {
-
-		/* Issue: The index array needs to start after the
-		 * builtin chains, as they are not sorted */
-		if (!iptcc_is_builtin(c)) {
-			cindex=chains / list_length;
-
-			/* Safe guard, break out on array limit, this
-			 * is useful if chains are added and array is
-			 * rebuild, without realloc of memory. */
-			if (cindex >= h->chain_index_sz)
-				break;
-
-			if ((chains % list_length)== 0) {
-				debug("\nIndex[%d] Chains:", cindex);
-				h->chain_index[cindex] = c;
-			}
-			chains++;
-		}
-		debug("%s, ", c->name);
 	}
-	debug("\n");
 
-	return 1;
-}
+	h->table_chains_headers= (void *)cmd;
+	h->cache_num_chains = h->table.num_chains;
 
-static int iptcc_chain_index_rebuild(TC_HANDLE_T h)
-{
-	debug("REBUILD chain index array\n");
-	iptcc_chain_index_free(h);
-	if ((iptcc_chain_index_alloc(h)) < 0)
-		return -ENOMEM;
-	iptcc_chain_index_build(h);
+	/* Count builtins */
+	for (i = 0; i < NUMHOOKS; i++) {
+		if (h->table.valid_hooks & (1 << i))
+			h->cache_num_builtins++;
+	}
+	h->entries_no_changed = 0;
+	
 	return 1;
 }
 
-/* Delete chain (pointer) from index array.  Removing an element from
- * the chain list only affects the chain index array, if the chain
- * index points-to/uses that list pointer.
- *
- * There are different strategies, the simple and safe is to rebuild
- * the chain index every time.  The more advanced is to update the
- * array index to point to the next element, but that requires some
- * house keeping and boundry checks.  The advanced is implemented, as
- * the simple approach behaves badly when all chains are deleted
- * because list_for_each processing will always hit the first chain
- * index, thus causing a rebuild for every chain.
- */
-static int iptcc_chain_index_delete_chain(struct chain_head *c, TC_HANDLE_T h)
+int check_handle(TC_HANDLE_T handle)
 {
-	struct list_head *index_ptr, *index_ptr2, *next;
-	struct chain_head *c2;
-	unsigned int idx, idx2;
-
-	index_ptr = iptcc_bsearch_chain_index(c->name, &idx, h);
-
-	debug("Del chain[%s] c->list:%p index_ptr:%p\n",
-	      c->name, &c->list, index_ptr);
-
-	/* Save the next pointer */
-	next = c->list.next;
-	list_del(&c->list);
-
-	if (index_ptr == &c->list) { /* Chain used as index ptr */
-
-		/* See if its possible to avoid a rebuild, by shifting
-		 * to next pointer.  Its possible if the next pointer
-		 * is located in the same index bucket.
-		 */
-		c2         = list_entry(next, struct chain_head, list);
-		index_ptr2 = iptcc_bsearch_chain_index(c2->name, &idx2, h);
-		if (idx != idx2) {
-			/* Rebuild needed */
-			return iptcc_chain_index_rebuild(h);
-		} else {
-			/* Avoiding rebuild */
-			debug("Update cindex[%d] with next ptr name:[%s]\n",
-			      idx, c2->name);
-			h->chain_index[idx]=c2;
-			return 0;
-		}
-	}
+	if(populate_cache(handle)) return 1;
+	
+	fprintf(stderr,"can't update cache info for table %s\n",
+					handle->table.name);
 	return 0;
 }
 
-
-/**********************************************************************
- * iptc cache utility functions (iptcc_*)
- **********************************************************************/
-
-/* Is the given chain builtin (1) or user-defined (0) */
-static inline unsigned int iptcc_is_builtin(struct chain_head *c)
-{
-	return (c->hooknum ? 1 : 0);
-}
-
-/* Get a specific rule within a chain */
-static struct rule_head *iptcc_get_rule_num(struct chain_head *c,
-					    unsigned int rulenum)
-{
-	struct rule_head *r;
-	unsigned int num = 0;
-
-	list_for_each_entry(r, &c->rules, list) {
-		num++;
-		if (num == rulenum)
-			return r;
-	}
-	return NULL;
-}
-
-/* Get a specific rule within a chain backwards */
-static struct rule_head *iptcc_get_rule_num_reverse(struct chain_head *c,
-					    unsigned int rulenum)
-{
-	struct rule_head *r;
-	unsigned int num = 0;
-
-	list_for_each_entry_reverse(r, &c->rules, list) {
-		num++;
-		if (num == rulenum)
-			return r;
-	}
-	return NULL;
-}
-
-/* Returns chain head if found, otherwise NULL. */
-static struct chain_head *
-iptcc_find_chain_by_offset(TC_HANDLE_T handle, unsigned int offset)
+/* Returns cache ptr if found, otherwise NULL. */
+static STRUCT_CHAIN_INFO *
+find_label(const char *name, TC_HANDLE_T handle)
 {
-	struct list_head *pos;
-
-	if (list_empty(&handle->chains))
-		return NULL;
-
-	list_for_each(pos, &handle->chains) {
-		struct chain_head *c = list_entry(pos, struct chain_head, list);
-		if (offset >= c->head_offset && offset <= c->foot_offset)
-			return c;
-	}
-
-	return NULL;
-}
-
-/* Returns chain head if found, otherwise NULL. */
-static struct chain_head *
-iptcc_find_label(const char *name, TC_HANDLE_T handle)
-{
-	struct list_head *pos;
-	struct list_head *list_start_pos;
-	unsigned int i=0;
-	int res;
-
-	if (list_empty(&handle->chains))
-		return NULL;
-
-	/* First look at builtin chains */
-	list_for_each(pos, &handle->chains) {
-		struct chain_head *c = list_entry(pos, struct chain_head, list);
-		if (!iptcc_is_builtin(c))
-			break;
-		if (!strcmp(c->name, name))
-			return c;
-	}
-
-	/* Find a smart place to start the search via chain index */
-  	//list_start_pos = iptcc_linearly_search_chain_index(name, handle);
-  	list_start_pos = iptcc_bsearch_chain_index(name, &i, handle);
-
-	/* Handel if bsearch bails out early */
-	if (list_start_pos == &handle->chains) {
-		list_start_pos = pos;
-	}
-#ifdef DEBUG
-	else {
-		/* Verify result of bsearch against linearly index search */
-		struct list_head *test_pos;
-		struct chain_head *test_c, *tmp_c;
-		test_pos = iptcc_linearly_search_chain_index(name, handle);
-		if (list_start_pos != test_pos) {
-			debug("BUG in chain_index search\n");
-			test_c=list_entry(test_pos,      struct chain_head,list);
-			tmp_c =list_entry(list_start_pos,struct chain_head,list);
-			debug("Verify search found:\n");
-			debug(" Chain:%s\n", test_c->name);
-			debug("BSearch found:\n");
-			debug(" Chain:%s\n", tmp_c->name);
-			exit(42);
-		}
-	}
-#endif
+	STRUCT_CHAIN_INFO *ici;
+	unsigned int i;
 
-	/* Initial/special case, no user defined chains */
-	if (handle->num_chains == 0)
-		return NULL;
+	if(!check_handle(handle)) return NULL;
 
-	/* Start searching through the chain list */
-	list_for_each(pos, list_start_pos->prev) {
-		struct chain_head *c = list_entry(pos, struct chain_head, list);
-		res = strcmp(c->name, name);
-		debug("List search name:%s == %s res:%d\n", name, c->name, res);
-		if (res==0)
-			return c;
-
-		/* We can stop earlier as we know list is sorted */
-		if (res>0 && !iptcc_is_builtin(c)) { /* Walked too far*/
-			debug(" Not in list, walked too far, sorted list\n");
-			return NULL;
-		}
+	ici = (void *) handle->table_chains_headers->chains_info;
+	
+	for (i = 0; i < handle->cache_num_chains; i++) {
+		if(strcmp( ici->name, name ) == 0) return ici;
 
-		/* Stop on wrap around, if list head is reached */
-		if (pos == &handle->chains) {
-			debug("Stop, list head reached\n");
-			return NULL;
-		}
+		ici= (void *) ici->entries;
 	}
-
-	debug("List search NOT found name:%s\n", name);
+	errno = ENOENT;
 	return NULL;
 }
 
-/* called when rule is to be removed from cache */
-static void iptcc_delete_rule(struct rule_head *r)
-{
-	DEBUGP("deleting rule %p (offset %u)\n", r, r->offset);
-	/* clean up reference count of called chain */
-	if (r->type == IPTCC_R_JUMP
-	    && r->jump)
-		r->jump->references--;
-
-	list_del(&r->list);
-	free(r);
-}
-
-
-/**********************************************************************
- * RULESET PARSER (blob -> cache)
- **********************************************************************/
-
-/* Delete policy rule of previous chain, since cache doesn't contain
- * chain policy rules.
- * WARNING: This function has ugly design and relies on a lot of context, only
- * to be called from specific places within the parser */
-static int __iptcc_p_del_policy(TC_HANDLE_T h, unsigned int num)
-{
-	if (h->chain_iterator_cur) {
-		/* policy rule is last rule */
-		struct rule_head *pr = (struct rule_head *)
-			h->chain_iterator_cur->rules.prev;
-
-		/* save verdict */
-		h->chain_iterator_cur->verdict = 
-			*(int *)GET_TARGET(pr->entry)->data;
-
-		/* save counter and counter_map information */
-		h->chain_iterator_cur->counter_map.maptype = 
-						COUNTER_MAP_NORMAL_MAP;
-		h->chain_iterator_cur->counter_map.mappos = num-1;
-		memcpy(&h->chain_iterator_cur->counters, &pr->entry->counters, 
-			sizeof(h->chain_iterator_cur->counters));
-
-		/* foot_offset points to verdict rule */
-		h->chain_iterator_cur->foot_index = num;
-		h->chain_iterator_cur->foot_offset = pr->offset;
-
-		/* delete rule from cache */
-		iptcc_delete_rule(pr);
-		h->chain_iterator_cur->num_rules--;
-
-		return 1;
-	}
-	return 0;
-}
-
-/* alphabetically insert a chain into the list */
-static inline void iptc_insert_chain(TC_HANDLE_T h, struct chain_head *c)
-{
-	struct chain_head *tmp;
-	struct list_head  *list_start_pos;
-	unsigned int i=1;
-
-	/* Find a smart place to start the insert search */
-  	list_start_pos = iptcc_bsearch_chain_index(c->name, &i, h);
-
-	/* Handle the case, where chain.name is smaller than index[0] */
-	if (i==0 && strcmp(c->name, h->chain_index[0]->name) <= 0) {
-		h->chain_index[0] = c; /* Update chain index head */
-		list_start_pos = h->chains.next;
-		debug("Update chain_index[0] with %s\n", c->name);
-	}
-
-	/* Handel if bsearch bails out early */
-	if (list_start_pos == &h->chains) {
-		list_start_pos = h->chains.next;
-	}
-
-	/* sort only user defined chains */
-	if (!c->hooknum) {
-		list_for_each_entry(tmp, list_start_pos->prev, list) {
-			if (!tmp->hooknum && strcmp(c->name, tmp->name) <= 0) {
-				list_add(&c->list, tmp->list.prev);
-				return;
-			}
-
-			/* Stop if list head is reached */
-			if (&tmp->list == &h->chains) {
-				debug("Insert, list head reached add to tail\n");
-				break;
-			}
-		}
-	}
-
-	/* survived till end of list: add at tail */
-	list_add_tail(&c->list, &h->chains);
-}
-
-/* Another ugly helper function split out of cache_add_entry to make it less
- * spaghetti code */
-static void __iptcc_p_add_chain(TC_HANDLE_T h, struct chain_head *c,
-				unsigned int offset, unsigned int *num)
-{
-	struct list_head  *tail = h->chains.prev;
-	struct chain_head *ctail;
-
-	__iptcc_p_del_policy(h, *num);
-
-	c->head_offset = offset;
-	c->index = *num;
-
-	/* Chains from kernel are already sorted, as they are inserted
-	 * sorted. But there exists an issue when shifting to 1.4.0
-	 * from an older version, as old versions allow last created
-	 * chain to be unsorted.
-	 */
-	if (iptcc_is_builtin(c)) /* Only user defined chains are sorted*/
-		list_add_tail(&c->list, &h->chains);
-	else {
-		ctail = list_entry(tail, struct chain_head, list);
-		if (strcmp(c->name, ctail->name) > 0)
-			list_add_tail(&c->list, &h->chains);/* Already sorted*/
-		else
-			iptc_insert_chain(h, c);/* Was not sorted */
-	}
-
-	h->chain_iterator_cur = c;
-}
-
-/* main parser function: add an entry from the blob to the cache */
-static int cache_add_entry(STRUCT_ENTRY *e, 
-			   TC_HANDLE_T h, 
-			   STRUCT_ENTRY **prev,
-			   unsigned int *num)
-{
-	unsigned int builtin;
-	unsigned int offset = (char *)e - (char *)h->entries->entrytable;
-
-	DEBUGP("entering...");
-
-	/* Last entry ("policy rule"). End it.*/
-	if (iptcb_entry2offset(h,e) + e->next_offset == h->entries->size) {
-		/* This is the ERROR node at the end of the chain */
-		DEBUGP_C("%u:%u: end of table:\n", *num, offset);
-
-		__iptcc_p_del_policy(h, *num);
-
-		h->chain_iterator_cur = NULL;
-		goto out_inc;
-	}
-
-	/* We know this is the start of a new chain if it's an ERROR
-	 * target, or a hook entry point */
-
-	if (strcmp(GET_TARGET(e)->u.user.name, ERROR_TARGET) == 0) {
-		struct chain_head *c = 
-			iptcc_alloc_chain_head((const char *)GET_TARGET(e)->data, 0);
-		DEBUGP_C("%u:%u:new userdefined chain %s: %p\n", *num, offset, 
-			(char *)c->name, c);
-		if (!c) {
-			errno = -ENOMEM;
-			return -1;
-		}
-		h->num_chains++; /* New user defined chain */
-
-		__iptcc_p_add_chain(h, c, offset, num);
-
-	} else if ((builtin = iptcb_ent_is_hook_entry(e, h)) != 0) {
-		struct chain_head *c =
-			iptcc_alloc_chain_head((char *)hooknames[builtin-1], 
-						builtin);
-		DEBUGP_C("%u:%u new builtin chain: %p (rules=%p)\n", 
-			*num, offset, c, &c->rules);
-		if (!c) {
-			errno = -ENOMEM;
-			return -1;
-		}
-
-		c->hooknum = builtin;
-
-		__iptcc_p_add_chain(h, c, offset, num);
-
-		/* FIXME: this is ugly. */
-		goto new_rule;
-	} else {
-		/* has to be normal rule */
-		struct rule_head *r;
-new_rule:
-
-		if (!(r = iptcc_alloc_rule(h->chain_iterator_cur, 
-					   e->next_offset))) {
-			errno = ENOMEM;
-			return -1;
-		}
-		DEBUGP_C("%u:%u normal rule: %p: ", *num, offset, r);
-
-		r->index = *num;
-		r->offset = offset;
-		memcpy(r->entry, e, e->next_offset);
-		r->counter_map.maptype = COUNTER_MAP_NORMAL_MAP;
-		r->counter_map.mappos = r->index;
-
-		/* handling of jumps, etc. */
-		if (!strcmp(GET_TARGET(e)->u.user.name, STANDARD_TARGET)) {
-			STRUCT_STANDARD_TARGET *t;
-
-			t = (STRUCT_STANDARD_TARGET *)GET_TARGET(e);
-			if (t->target.u.target_size
-			    != ALIGN(sizeof(STRUCT_STANDARD_TARGET))) {
-				errno = EINVAL;
-				return -1;
-			}
-
-			if (t->verdict < 0) {
-				DEBUGP_C("standard, verdict=%d\n", t->verdict);
-				r->type = IPTCC_R_STANDARD;
-			} else if (t->verdict == r->offset+e->next_offset) {
-				DEBUGP_C("fallthrough\n");
-				r->type = IPTCC_R_FALLTHROUGH;
-			} else {
-				DEBUGP_C("jump, target=%u\n", t->verdict);
-				r->type = IPTCC_R_JUMP;
-				/* Jump target fixup has to be deferred
-				 * until second pass, since we migh not
-				 * yet have parsed the target */
-			}
-		} else {
-			DEBUGP_C("module, target=%s\n", GET_TARGET(e)->u.user.name);
-			r->type = IPTCC_R_MODULE;
-		}
-
-		list_add_tail(&r->list, &h->chain_iterator_cur->rules);
-		h->chain_iterator_cur->num_rules++;
-	}
-out_inc:
-	(*num)++;
-	return 0;
-}
-
-
-/* parse an iptables blob into it's pieces */
-static int parse_table(TC_HANDLE_T h)
-{
-	STRUCT_ENTRY *prev;
-	unsigned int num = 0;
-	struct chain_head *c;
-
-	/* First pass: over ruleset blob */
-	ENTRY_ITERATE(h->entries->entrytable, h->entries->size,
-			cache_add_entry, h, &prev, &num);
-
-	/* Build the chain index, used for chain list search speedup */
-	if ((iptcc_chain_index_alloc(h)) < 0)
-		return -ENOMEM;
-	iptcc_chain_index_build(h);
-
-	/* Second pass: fixup parsed data from first pass */
-	list_for_each_entry(c, &h->chains, list) {
-		struct rule_head *r;
-		list_for_each_entry(r, &c->rules, list) {
-			struct chain_head *lc;
-			STRUCT_STANDARD_TARGET *t;
-
-			if (r->type != IPTCC_R_JUMP)
-				continue;
-
-			t = (STRUCT_STANDARD_TARGET *)GET_TARGET(r->entry);
-			lc = iptcc_find_chain_by_offset(h, t->verdict);
-			if (!lc)
-				return -1;
-			r->jump = lc;
-			lc->references++;
-		}
-	}
-
-	/* FIXME: sort chains */
-
-	return 1;
-}
-
+static int 
+populate_entries_cache(STRUCT_CHAIN_INFO *chain, TC_HANDLE_T handle){
+	STRUCT_COMMAND *cmd;
+	socklen_t s;
 
-/**********************************************************************
- * RULESET COMPILATION (cache -> blob)
- **********************************************************************/
+	if(handle->entries_cache && !handle->entries_info_changed 
+				&& !strcmp(chain->name, handle->entries_cache->name)) 
+					return 1;
 
-/* Convenience structures */
-struct iptcb_chain_start{
-	STRUCT_ENTRY e;
-	struct ipt_error_target name;
-};
-#define IPTCB_CHAIN_START_SIZE	(sizeof(STRUCT_ENTRY) +			\
-				 ALIGN(sizeof(struct ipt_error_target)))
+	if(handle->entries_cache) free(handle->entries_cache);
+	handle->entries_cache = NULL;
 
-struct iptcb_chain_foot {
-	STRUCT_ENTRY e;
-	STRUCT_STANDARD_TARGET target;
-};
-#define IPTCB_CHAIN_FOOT_SIZE	(sizeof(STRUCT_ENTRY) +			\
-				 ALIGN(sizeof(STRUCT_STANDARD_TARGET)))
+	s= ( sizeof(STRUCT_COMMAND) > sizeof(STRUCT_CHAIN_INFO))?
+		sizeof(STRUCT_COMMAND) : sizeof(STRUCT_CHAIN_INFO);
+	s+= chain->size;
 
-struct iptcb_chain_error {
-	STRUCT_ENTRY entry;
-	struct ipt_error_target target;
-};
-#define IPTCB_CHAIN_ERROR_SIZE	(sizeof(STRUCT_ENTRY) +			\
-				 ALIGN(sizeof(struct ipt_error_target)))
+	cmd= malloc(s); if(cmd == NULL){ errno = ENOMEM; return 0; }
 
-
-
-/* compile rule from cache into blob */
-static inline int iptcc_compile_rule (TC_HANDLE_T h, STRUCT_REPLACE *repl, struct rule_head *r)
-{
-	/* handle jumps */
-	if (r->type == IPTCC_R_JUMP) {
-		STRUCT_STANDARD_TARGET *t;
-		t = (STRUCT_STANDARD_TARGET *)GET_TARGET(r->entry);
-		/* memset for memcmp convenience on delete/replace */
-		memset(t->target.u.user.name, 0, FUNCTION_MAXNAMELEN);
-		strcpy(t->target.u.user.name, STANDARD_TARGET);
-		/* Jumps can only happen to builtin chains, so we
-		 * can safely assume that they always have a header */
-		t->verdict = r->jump->head_offset + IPTCB_CHAIN_START_SIZE;
-	} else if (r->type == IPTCC_R_FALLTHROUGH) {
-		STRUCT_STANDARD_TARGET *t;
-		t = (STRUCT_STANDARD_TARGET *)GET_TARGET(r->entry);
-		t->verdict = r->offset + r->size;
-	}
+	cmd->command= PKTT_CHAIN_GET_ENTRIES;
+	strcpy(cmd->table_name, handle->table.name);
+	strcpy(cmd->chain_name, chain->name);
+	cmd->family = TC_AF;
 	
-	/* copy entry from cache to blob */
-	memcpy((char *)repl->entries+r->offset, r->entry, r->size);
-
-	return 1;
-}
-
-/* compile chain from cache into blob */
-static int iptcc_compile_chain(TC_HANDLE_T h, STRUCT_REPLACE *repl, struct chain_head *c)
-{
-	int ret;
-	struct rule_head *r;
-	struct iptcb_chain_start *head;
-	struct iptcb_chain_foot *foot;
-
-	/* only user-defined chains have heaer */
-	if (!iptcc_is_builtin(c)) {
-		/* put chain header in place */
-		head = (void *)repl->entries + c->head_offset;
-		head->e.target_offset = sizeof(STRUCT_ENTRY);
-		head->e.next_offset = IPTCB_CHAIN_START_SIZE;
-		strcpy(head->name.t.u.user.name, ERROR_TARGET);
-		head->name.t.u.target_size = 
-				ALIGN(sizeof(struct ipt_error_target));
-		strcpy(head->name.error, c->name);
-	} else {
-		repl->hook_entry[c->hooknum-1] = c->head_offset;	
-		repl->underflow[c->hooknum-1] = c->foot_offset;
-	}
-
-	/* iterate over rules */
-	list_for_each_entry(r, &c->rules, list) {
-		ret = iptcc_compile_rule(h, repl, r);
-		if (ret < 0)
-			return ret;
-	}
-
-	/* put chain footer in place */
-	foot = (void *)repl->entries + c->foot_offset;
-	foot->e.target_offset = sizeof(STRUCT_ENTRY);
-	foot->e.next_offset = IPTCB_CHAIN_FOOT_SIZE;
-	strcpy(foot->target.target.u.user.name, STANDARD_TARGET);
-	foot->target.target.u.target_size =
-				ALIGN(sizeof(STRUCT_STANDARD_TARGET));
-	/* builtin targets have verdict, others return */
-	if (iptcc_is_builtin(c))
-		foot->target.verdict = c->verdict;
-	else
-		foot->target.verdict = RETURN;
-	/* set policy-counters */
-	memcpy(&foot->e.counters, &c->counters, sizeof(STRUCT_COUNTERS));
-
-	return 0;
-}
-
-/* calculate offset and number for every rule in the cache */
-static int iptcc_compile_chain_offsets(TC_HANDLE_T h, struct chain_head *c,
-				       unsigned int *offset, unsigned int *num)
-{
-	struct rule_head *r;
-
-	c->head_offset = *offset;
-	DEBUGP("%s: chain_head %u, offset=%u\n", c->name, *num, *offset);
-
-	if (!iptcc_is_builtin(c))  {
-		/* Chain has header */
-		*offset += sizeof(STRUCT_ENTRY) 
-			     + ALIGN(sizeof(struct ipt_error_target));
-		(*num)++;
-	}
-
-	list_for_each_entry(r, &c->rules, list) {
-		DEBUGP("rule %u, offset=%u, index=%u\n", *num, *offset, *num);
-		r->offset = *offset;
-		r->index = *num;
-		*offset += r->size;
-		(*num)++;
-	}
-
-	DEBUGP("%s; chain_foot %u, offset=%u, index=%u\n", c->name, *num, 
-		*offset, *num);
-	c->foot_offset = *offset;
-	c->foot_index = *num;
-	*offset += sizeof(STRUCT_ENTRY)
-		   + ALIGN(sizeof(STRUCT_STANDARD_TARGET));
-	(*num)++;
-
-	return 1;
-}
-
-/* put the pieces back together again */
-static int iptcc_compile_table_prep(TC_HANDLE_T h, unsigned int *size)
-{
-	struct chain_head *c;
-	unsigned int offset = 0, num = 0;
-	int ret = 0;
-
-	/* First pass: calculate offset for every rule */
-	list_for_each_entry(c, &h->chains, list) {
-		ret = iptcc_compile_chain_offsets(h, c, &offset, &num);
-		if (ret < 0)
-			return ret;
-	}
-
-	/* Append one error rule at end of chain */
-	num++;
-	offset += sizeof(STRUCT_ENTRY)
-		  + ALIGN(sizeof(struct ipt_error_target));
-
-	/* ruleset size is now in offset */
-	*size = offset;
-	return num;
-}
-
-static int iptcc_compile_table(TC_HANDLE_T h, STRUCT_REPLACE *repl)
-{
-	struct chain_head *c;
-	struct iptcb_chain_error *error;
-
-	/* Second pass: copy from cache to offsets, fill in jumps */
-	list_for_each_entry(c, &h->chains, list) {
-		int ret = iptcc_compile_chain(h, repl, c);
-		if (ret < 0)
-			return ret;
+	if(getsockopt(sockfd, TC_IPPROTO, SO_GET_ENTRIES, cmd, &s) <0){
+		free(cmd); errno = EFAULT;
+		return 0;
 	}
+	
+	handle->entries_cache = (void *) cmd;
+	handle->end_of_entries = (void *)
+		((void *)handle->entries_cache->entries + chain->size);
 
-	/* Append error rule at end of chain */
-	error = (void *)repl->entries + repl->size - IPTCB_CHAIN_ERROR_SIZE;
-	error->entry.target_offset = sizeof(STRUCT_ENTRY);
-	error->entry.next_offset = IPTCB_CHAIN_ERROR_SIZE;
-	error->target.t.u.user.target_size = 
-		ALIGN(sizeof(struct ipt_error_target));
-	strcpy((char *)&error->target.t.u.user.name, ERROR_TARGET);
-	strcpy((char *)&error->target.error, "ERROR");
-
+	handle->entries_info_changed = 0;
 	return 1;
 }
 
-/**********************************************************************
- * EXTERNAL API (operates on cache only)
- **********************************************************************/
-
-/* Allocate handle of given size */
-static TC_HANDLE_T
-alloc_handle(const char *tablename, unsigned int size, unsigned int num_rules)
-{
-	size_t len;
-	TC_HANDLE_T h;
-
-	len = sizeof(STRUCT_TC_HANDLE) + size;
-
-	h = malloc(sizeof(STRUCT_TC_HANDLE));
-	if (!h) {
-		errno = ENOMEM;
-		return NULL;
-	}
-	memset(h, 0, sizeof(*h));
-	INIT_LIST_HEAD(&h->chains);
-	strcpy(h->info.name, tablename);
-
-	h->entries = malloc(sizeof(STRUCT_GET_ENTRIES) + size);
-	if (!h->entries)
-		goto out_free_handle;
-
-	strcpy(h->entries->name, tablename);
-	h->entries->size = size;
-
-	return h;
-
-out_free_handle:
-	free(h);
-
-	return NULL;
-}
-
-
 TC_HANDLE_T
 TC_INIT(const char *tablename)
 {
 	TC_HANDLE_T h;
-	STRUCT_GETINFO info;
-	unsigned int tmp;
-	socklen_t s;
 
 	iptc_fn = TC_INIT;
 
-	if (strlen(tablename) >= TABLE_MAXNAMELEN) {
-		errno = EINVAL;
-		return NULL;
-	}
-	
-	if (sockfd_use == 0) {
-		sockfd = socket(TC_AF, SOCK_RAW, IPPROTO_RAW);
-		if (sockfd < 0)
-			return NULL;
-	}
-	sockfd_use++;
-retry:
-	s = sizeof(info);
-
-	strcpy(info.name, tablename);
-	if (getsockopt(sockfd, TC_IPPROTO, SO_GET_INFO, &info, &s) < 0) {
-		if (--sockfd_use == 0) {
-			close(sockfd);
-			sockfd = -1;
-		}
-		return NULL;
-	}
-
-	DEBUGP("valid_hooks=0x%08x, num_entries=%u, size=%u\n",
-		info.valid_hooks, info.num_entries, info.size);
-
-	if ((h = alloc_handle(info.name, info.size, info.num_entries))
-	    == NULL) {
-		if (--sockfd_use == 0) {
-			close(sockfd);
-			sockfd = -1;
-		}
-		return NULL;
-	}
-
-	/* Initialize current state */
-	h->info = info;
+	if(strlen(tablename)+1 >= TABLE_MAXNAMELEN){errno = E2BIG; return NULL;}
 
-	h->entries->size = h->info.size;
+	h = alloc_handle();
+	if(!h) return NULL;
 
-	tmp = sizeof(STRUCT_GET_ENTRIES) + h->info.size;
+	sockfd = socket(TC_AF, SOCK_RAW, IPPROTO_RAW);
+	if (sockfd < 0) {free(h); return NULL;}
 
-	if (getsockopt(sockfd, TC_IPPROTO, SO_GET_ENTRIES, h->entries,
-		       &tmp) < 0)
-		goto error;
+	strcpy(h->table.name, tablename);
+	set_changed(h, 0);
 
-#ifdef IPTC_DEBUG2
-	{
-		int fd = open("/tmp/libiptc-so_get_entries.blob", 
-				O_CREAT|O_WRONLY);
-		if (fd >= 0) {
-			write(fd, h->entries, tmp);
-			close(fd);
-		}
+	if(!populate_cache(h)){
+		free(h); close(sockfd); sockfd=-1;
+		return NULL;
 	}
-#endif
+	h->hooknames=hooknames;
 
-	if (parse_table(h) < 0)
-		goto error;
-
-	CHECK(h);
 	return h;
-error:
-	TC_FREE(&h);
-	/* A different process changed the ruleset size, retry */
-	if (errno == EAGAIN)
-		goto retry;
-	return NULL;
 }
 
 void
 TC_FREE(TC_HANDLE_T *h)
 {
-	struct chain_head *c, *tmp;
-
-	iptc_fn = TC_FREE;
-	if (--sockfd_use == 0) {
-		close(sockfd);
-		sockfd = -1;
-	}
-
-	list_for_each_entry_safe(c, tmp, &(*h)->chains, list) {
-		struct rule_head *r, *rtmp;
-
-		list_for_each_entry_safe(r, rtmp, &c->rules, list) {
-			free(r);
-		}
-
-		free(c);
-	}
-
-	iptcc_chain_index_free(*h);
+	if(sockfd!=-1) { close(sockfd); sockfd = -1;}
 
-	free((*h)->entries);
+	if ((*h)->table_chains_headers)
+		free((*h)->table_chains_headers);
+	if ((*h)->entries_cache)
+		free((*h)->entries_cache);
 	free(*h);
-
 	*h = NULL;
 }
 
@@ -1318,369 +271,270 @@ print_match(const STRUCT_ENTRY_MATCH *m)
 	return 0;
 }
 
-static int dump_entry(STRUCT_ENTRY *e, const TC_HANDLE_T handle);
+//static int dump_entry(STRUCT_ENTRY *e, const TC_HANDLE_T handle);
  
 void
 TC_DUMP_ENTRIES(const TC_HANDLE_T handle)
 {
-	iptc_fn = TC_DUMP_ENTRIES;
-	CHECK(handle);
-
-	printf("libiptc v%s. %u bytes.\n",
-	       XTABLES_VERSION, handle->entries->size);
-	printf("Table `%s'\n", handle->info.name);
-	printf("Hooks: pre/in/fwd/out/post = %u/%u/%u/%u/%u\n",
-	       handle->info.hook_entry[HOOK_PRE_ROUTING],
-	       handle->info.hook_entry[HOOK_LOCAL_IN],
-	       handle->info.hook_entry[HOOK_FORWARD],
-	       handle->info.hook_entry[HOOK_LOCAL_OUT],
-	       handle->info.hook_entry[HOOK_POST_ROUTING]);
-	printf("Underflows: pre/in/fwd/out/post = %u/%u/%u/%u/%u\n",
-	       handle->info.underflow[HOOK_PRE_ROUTING],
-	       handle->info.underflow[HOOK_LOCAL_IN],
-	       handle->info.underflow[HOOK_FORWARD],
-	       handle->info.underflow[HOOK_LOCAL_OUT],
-	       handle->info.underflow[HOOK_POST_ROUTING]);
-
-	ENTRY_ITERATE(handle->entries->entrytable, handle->entries->size,
-		      dump_entry, handle);
 }
 
 /* Does this chain exist? */
 int TC_IS_CHAIN(const char *chain, const TC_HANDLE_T handle)
 {
-	iptc_fn = TC_IS_CHAIN;
-	return iptcc_find_label(chain, handle) != NULL;
-}
-
-static void iptcc_chain_iterator_advance(TC_HANDLE_T handle)
-{
-	struct chain_head *c = handle->chain_iterator_cur;
-
-	if (c->list.next == &handle->chains)
-		handle->chain_iterator_cur = NULL;
-	else
-		handle->chain_iterator_cur = 
-			list_entry(c->list.next, struct chain_head, list);
+	return find_label(chain, handle) != NULL;
 }
 
 /* Iterator functions to run through the chains. */
 const char *
 TC_FIRST_CHAIN(TC_HANDLE_T *handle)
 {
-	struct chain_head *c = list_entry((*handle)->chains.next,
-					  struct chain_head, list);
-
 	iptc_fn = TC_FIRST_CHAIN;
 
+	if(!check_handle(*handle)) return NULL;
 
-	if (list_empty(&(*handle)->chains)) {
-		DEBUGP(": no chains\n");
-		return NULL;
-	}
-
-	(*handle)->chain_iterator_cur = c;
-	iptcc_chain_iterator_advance(*handle);
+	(*handle)->chains_iterator 
+		= (void *) &(*handle)->table_chains_headers->chains_info;
 
-	DEBUGP(": returning `%s'\n", c->name);
-	return c->name;
+	return (*handle)->chains_iterator->name;
 }
 
 /* Iterator functions to run through the chains.  Returns NULL at end. */
 const char *
 TC_NEXT_CHAIN(TC_HANDLE_T *handle)
 {
-	struct chain_head *c = (*handle)->chain_iterator_cur;
+	(*handle)->chains_iterator = 
+		    (void *) (*handle)->chains_iterator->entries;
 
-	iptc_fn = TC_NEXT_CHAIN;
-
-	if (!c) {
-		DEBUGP(": no more chains\n");
+	/* finished or not */
+	if ( ( (void *)(*handle)->chains_iterator - 
+		  (void *)(*handle)->table_chains_headers->chains_info ) 
+		  / sizeof( STRUCT_CHAIN_INFO) == (*handle)->cache_num_chains)
 		return NULL;
-	}
 
-	iptcc_chain_iterator_advance(*handle);
-	
-	DEBUGP(": returning `%s'\n", c->name);
-	return c->name;
+	return (*handle)->chains_iterator->name;
 }
 
 /* Get first rule in the given chain: NULL for empty chain. */
 const STRUCT_ENTRY *
 TC_FIRST_RULE(const char *chain, TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_ENTRY *e;
 
 	iptc_fn = TC_FIRST_RULE;
 
-	DEBUGP("first rule(%s): ", chain);
-
-	c = iptcc_find_label(chain, *handle);
-	if (!c) {
-		errno = ENOENT;
-		return NULL;
-	}
-
-	/* Empty chain: single return/policy rule */
-	if (list_empty(&c->rules)) {
-		DEBUGP_C("no rules, returning NULL\n");
-		return NULL;
-	}
+	ici = find_label(chain, *handle);
+	if (!ici) return NULL;
+	if (ici->num_entries == 0) {errno=-1; return NULL;}
 
-	r = list_entry(c->rules.next, struct rule_head, list);
-	(*handle)->rule_iterator_cur = r;
-	DEBUGP_C("%p\n", r);
+	if(!populate_entries_cache(ici, *handle)) return NULL;
 
-	return r->entry;
+	/* this is first entry */
+	e = (void *)(*handle)->entries_cache->entries;
+	return e;
 }
 
 /* Returns NULL when rules run out. */
 const STRUCT_ENTRY *
 TC_NEXT_RULE(const STRUCT_ENTRY *prev, TC_HANDLE_T *handle)
 {
-	struct rule_head *r;
-
-	iptc_fn = TC_NEXT_RULE;
-	DEBUGP("rule_iterator_cur=%p...", (*handle)->rule_iterator_cur);
-
-	if (!(*handle)->rule_iterator_cur) {
-		DEBUGP_C("returning NULL\n");
-		return NULL;
-	}
-	
-	r = list_entry((*handle)->rule_iterator_cur->list.next, 
-			struct rule_head, list);
-
-	iptc_fn = TC_NEXT_RULE;
-
-	DEBUGP_C("next=%p, head=%p...", &r->list, 
-		&(*handle)->rule_iterator_cur->chain->rules);
+	STRUCT_ENTRY *e;
 
-	if (&r->list == &(*handle)->rule_iterator_cur->chain->rules) {
-		(*handle)->rule_iterator_cur = NULL;
-		DEBUGP_C("finished, returning NULL\n");
+	if ((void *)prev + prev->size
+	    == (void *)(*handle)->end_of_entries)
 		return NULL;
-	}
-
-	(*handle)->rule_iterator_cur = r;
 
-	/* NOTE: prev is without any influence ! */
-	DEBUGP_C("returning rule %p\n", r);
-	return r->entry;
+	/* this is next entry */
+	e = (void *)prev + prev->size;
+	return e;
 }
 
 /* How many rules in this chain? */
-static unsigned int
+unsigned int
 TC_NUM_RULES(const char *chain, TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
+	STRUCT_CHAIN_INFO *pci;
+
 	iptc_fn = TC_NUM_RULES;
-	CHECK(*handle);
 
-	c = iptcc_find_label(chain, *handle);
-	if (!c) {
-		errno = ENOENT;
-		return (unsigned int)-1;
-	}
-	
-	return c->num_rules;
-}
+	pci = find_label(chain, *handle); 
+	if(!pci) return (unsigned int) -1;
 
-static const STRUCT_ENTRY *
-TC_GET_RULE(const char *chain, unsigned int n, TC_HANDLE_T *handle)
+	return pci->num_entries;
+}
+/* Get n'th rule in this chain. */
+const STRUCT_ENTRY *TC_GET_RULE(const char *chain,
+				unsigned int n,
+				TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
-	
+	STRUCT_CHAIN_INFO *pci;
+	STRUCT_ENTRY *e;
+	int i;
+
 	iptc_fn = TC_GET_RULE;
 
-	CHECK(*handle);
+	pci = find_label(chain, *handle);
+	if(!pci) return NULL; 
 
-	c = iptcc_find_label(chain, *handle);
-	if (!c) {
-		errno = ENOENT;
-		return NULL;
-	}
+	if(n > pci->num_entries) { errno=E2BIG; return NULL; }
+	if(!populate_entries_cache(pci, *handle)) return NULL;
 
-	r = iptcc_get_rule_num(c, n);
-	if (!r)
-		return NULL;
-	return r->entry;
+	e= (void *) (*handle)->entries_cache->entries;
+	for(i=1; i< n; ++i) e = (void*) e + e->size;
+	return e;
 }
 
-/* Returns a pointer to the target name of this position. */
-static const char *standard_target_map(int verdict)
+static const char *
+target_name(TC_HANDLE_T handle, const STRUCT_ENTRY *ce)
 {
-	switch (verdict) {
-		case RETURN:
-			return LABEL_RETURN;
-			break;
-		case -NF_ACCEPT-1:
-			return LABEL_ACCEPT;
-			break;
-		case -NF_DROP-1:
-			return LABEL_DROP;
-			break;
-		case -NF_QUEUE-1:
-			return LABEL_QUEUE;
-			break;
-		default:
-			fprintf(stderr, "ERROR: %d not a valid target)\n",
-				verdict);
-			abort();
-			break;
-	}
-	/* not reached */
+	int verdict;
+
+	/* To avoid const warnings */
+	STRUCT_ENTRY *e = (STRUCT_ENTRY *)ce;
+
+	if (strcmp(GET_TARGET(e)->u.user.name, STANDARD_TARGET) != 0)
+		return GET_TARGET(e)->u.user.name;
+
+	/* Standard target: evaluate */
+	verdict = *(int *)GET_TARGET(e)->data;
+
+	if (verdict == RETURN)			return LABEL_RETURN;
+	else if (verdict == CONTINUE )		return LABEL_CONTINUE;
+	else if (verdict == -NF_ACCEPT-1)	return LABEL_ACCEPT;
+	else if (verdict == -NF_DROP-1)		return LABEL_DROP;
+	else if (verdict == -NF_QUEUE-1)	return LABEL_QUEUE;
+
+	fprintf(stderr, "ERROR: not a valid target (%i)\n", verdict);
+
+	abort();
 	return NULL;
 }
 
 /* Returns a pointer to the target name of this position. */
-const char *TC_GET_TARGET(const STRUCT_ENTRY *ce,
+const char *TC_GET_TARGET(const STRUCT_ENTRY *e,
 			  TC_HANDLE_T *handle)
 {
-	STRUCT_ENTRY *e = (STRUCT_ENTRY *)ce;
-	struct rule_head *r = container_of(e, struct rule_head, entry[0]);
-
-	iptc_fn = TC_GET_TARGET;
-
-	switch(r->type) {
-		int spos;
-		case IPTCC_R_FALLTHROUGH:
-			return "";
-			break;
-		case IPTCC_R_JUMP:
-			DEBUGP("r=%p, jump=%p, name=`%s'\n", r, r->jump, r->jump->name);
-			return r->jump->name;
-			break;
-		case IPTCC_R_STANDARD:
-			spos = *(int *)GET_TARGET(e)->data;
-			DEBUGP("r=%p, spos=%d'\n", r, spos);
-			return standard_target_map(spos);
-			break;
-		case IPTCC_R_MODULE:
-			return GET_TARGET(e)->u.user.name;
-			break;
-	}
-	return NULL;
-}
-/* Is this a built-in chain?  Actually returns hook + 1. */
-int
-TC_BUILTIN(const char *chain, const TC_HANDLE_T handle)
-{
-	struct chain_head *c;
-	
-	iptc_fn = TC_BUILTIN;
-
-	c = iptcc_find_label(chain, handle);
-	if (!c) {
-		errno = ENOENT;
-		return 0;
-	}
-
-	return iptcc_is_builtin(c);
+	return target_name(*handle, e);
 }
 
-/* Get the policy of a given built-in chain */
+/* Get the policy of a given chain */
 const char *
 TC_GET_POLICY(const char *chain,
 	      STRUCT_COUNTERS *counters,
 	      TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
+	STRUCT_CHAIN_INFO *ici;
 
-	iptc_fn = TC_GET_POLICY;
+	iptc_fn=TC_GET_POLICY;
 
-	DEBUGP("called for chain %s\n", chain);
+	ici = find_label( chain, *handle );
+	if( !ici ) return NULL;
 
-	c = iptcc_find_label(chain, *handle);
-	if (!c) {
-		errno = ENOENT;
-		return NULL;
-	}
+	(*counters).pcnt = (*counters).bcnt = 0;
+	if(populate_entries_cache(ici, *handle)){
+		STRUCT_ENTRY *e = (void*)(*handle)->entries_cache->entries;
+		int i;
 
-	if (!iptcc_is_builtin(c))
-		return NULL;
+		for(i=0; i< ici->num_entries; ++i) {
+			(*counters).pcnt += e->counters.pcnt;
+			(*counters).bcnt += e->counters.bcnt;
+			e = (void *) e + e->size;
+		}
+	}
 
-	*counters = c->counters;
+	switch( ici->policy ){
+	case cACCEPT:  	return LABEL_ACCEPT;
+	case cDROP:	return LABEL_DROP;
+	case cRETURN:	return LABEL_RETURN;
+	case cQUEUE:	return LABEL_QUEUE;
+	}
 
-	return standard_target_map(c->verdict);
+	return NULL;
 }
 
 static int
-iptcc_standard_map(struct rule_head *r, int verdict)
+standard_map(STRUCT_ENTRY *e, int verdict)
 {
-	STRUCT_ENTRY *e = r->entry;
 	STRUCT_STANDARD_TARGET *t;
 
 	t = (STRUCT_STANDARD_TARGET *)GET_TARGET(e);
 
 	if (t->target.u.target_size
 	    != ALIGN(sizeof(STRUCT_STANDARD_TARGET))) {
-		errno = EINVAL;
-		return 0;
+		errno = EINVAL; return 0;
 	}
 	/* memset for memcmp convenience on delete/replace */
 	memset(t->target.u.user.name, 0, FUNCTION_MAXNAMELEN);
 	strcpy(t->target.u.user.name, STANDARD_TARGET);
 	t->verdict = verdict;
 
-	r->type = IPTCC_R_STANDARD;
-
 	return 1;
 }
 
 static int
-iptcc_map_target(const TC_HANDLE_T handle,
-	   struct rule_head *r)
+map_target(const TC_HANDLE_T handle,
+	   STRUCT_ENTRY *e,
+	   STRUCT_ENTRY_TARGET *old)
 {
-	STRUCT_ENTRY *e = r->entry;
 	STRUCT_ENTRY_TARGET *t = GET_TARGET(e);
 
+	/* Save old target (except data, which we don't change, except for
+	   standard case, where we don't care). */
+	*old = *t;
+
 	/* Maybe it's empty (=> fall through) */
-	if (strcmp(t->u.user.name, "") == 0) {
-		r->type = IPTCC_R_FALLTHROUGH;
-		return 1;
-	}
+	if (strcmp(t->u.user.name, "") == 0 || 
+			strcmp(t->u.user.name, LABEL_CONTINUE) == 0)
+		/* yesterday: next offset as a jump ( oook )
+		   today: be relax, just say continue.
+		 */
+		return standard_map(e, CONTINUE);
 	/* Maybe it's a standard target name... */
 	else if (strcmp(t->u.user.name, LABEL_ACCEPT) == 0)
-		return iptcc_standard_map(r, -NF_ACCEPT - 1);
+		return standard_map(e, -NF_ACCEPT - 1);
 	else if (strcmp(t->u.user.name, LABEL_DROP) == 0)
-		return iptcc_standard_map(r, -NF_DROP - 1);
+		return standard_map(e, -NF_DROP - 1);
 	else if (strcmp(t->u.user.name, LABEL_QUEUE) == 0)
-		return iptcc_standard_map(r, -NF_QUEUE - 1);
+		return standard_map(e, -NF_QUEUE - 1);
 	else if (strcmp(t->u.user.name, LABEL_RETURN) == 0)
-		return iptcc_standard_map(r, RETURN);
-	else if (TC_BUILTIN(t->u.user.name, handle)) {
-		/* Can't jump to builtins. */
-		errno = EINVAL;
-		return 0;
-	} else {
+		return standard_map(e, RETURN);
+	/* yesterday: afraid from builtin chains to take palce as targets
+	   today: can use from every chain as target
+	 */
+	else {
 		/* Maybe it's an existing chain name. */
-		struct chain_head *c;
-		DEBUGP("trying to find chain `%s': ", t->u.user.name);
-
-		c = iptcc_find_label(t->u.user.name, handle);
-		if (c) {
-			DEBUGP_C("found!\n");
-			r->type = IPTCC_R_JUMP;
-			r->jump = c;
-			c->references++;
+		STRUCT_CHAIN_INFO *ici;
+
+		ici = find_label(t->u.user.name, handle);
+		if (ici)
+			/* yesterday: using from target offset to jump to him
+			   today: very easy, we send him to kernel, the kernel
+				will jump in his traces to the appropriate
+				places
+			 */
 			return 1;
-		}
-		DEBUGP_C("not found :(\n");
 	}
-
+	
 	/* Must be a module?  If not, kernel will reject... */
-	/* memset to all 0 for your memcmp convenience: don't clear version */
+	/* memset to all 0 for your memcmp convenience. */
 	memset(t->u.user.name + strlen(t->u.user.name),
 	       0,
-	       FUNCTION_MAXNAMELEN - 1 - strlen(t->u.user.name));
-	r->type = IPTCC_R_MODULE;
-	set_changed(handle);
+	       FUNCTION_MAXNAMELEN - strlen(t->u.user.name));
 	return 1;
 }
 
+static void
+unmap_target(STRUCT_ENTRY *e, STRUCT_ENTRY_TARGET *old)
+{
+	STRUCT_ENTRY_TARGET *t = GET_TARGET(e);
+
+	/* Save old target (except data, which we don't change, except for
+	   standard case, where we don't care). */
+	*t = *old;
+}
+
+static STRUCT_ENTRY_TARGET save;
+
 /* Insert the entry `fw' in chain `chain' into position `rulenum'. */
 int
 TC_INSERT_ENTRY(const IPT_CHAINLABEL chain,
@@ -1688,215 +542,135 @@ TC_INSERT_ENTRY(const IPT_CHAINLABEL chain,
 		unsigned int rulenum,
 		TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
-	struct list_head *prev;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND *c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_INSERT_ENTRY;
 
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
-
-	/* first rulenum index = 0
-	   first c->num_rules index = 1 */
-	if (rulenum > c->num_rules) {
-		errno = E2BIG;
-		return 0;
-	}
+	ici= find_label(chain, *handle);
+	if(!ici) return 0;
 
-	/* If we are inserting at the end just take advantage of the
-	   double linked list, insert will happen before the entry
-	   prev points to. */
-	if (rulenum == c->num_rules) {
-		prev = &c->rules;
-	} else if (rulenum + 1 <= c->num_rules/2) {
-		r = iptcc_get_rule_num(c, rulenum + 1);
-		prev = &r->list;
-	} else {
-		r = iptcc_get_rule_num_reverse(c, c->num_rules - rulenum);
-		prev = &r->list;
-	}
+	if(rulenum > (ici->num_entries+1) ){errno = E2BIG; return 0;}
+	((STRUCT_ENTRY*)e)->family = TC_AF;	
 
-	if (!(r = iptcc_alloc_rule(c, e->next_offset))) {
-		errno = ENOMEM;
-		return 0;
-	}
+	s= sizeof(STRUCT_COMMAND) + e->size;
+	c= malloc(s);
+	if(!c){errno = ENOMEM; return 0; }
 
-	memcpy(r->entry, e, e->next_offset);
-	r->counter_map.maptype = COUNTER_MAP_SET;
+	map_target(*handle, (STRUCT_ENTRY *)e, &save);
 
-	if (!iptcc_map_target(*handle, r)) {
-		free(r);
-		return 0;
-	}
+	/* copy entry as payload */
+	memcpy((void *)c+sizeof(STRUCT_COMMAND), e, e->size );
 
-	list_add_tail(&r->list, prev);
-	c->num_rules++;
+	unmap_target((STRUCT_ENTRY *)e, &save);
 
-	set_changed(*handle);
+	c->command = PKTT_ENTRY_ADD;
+	strcpy(c->table_name , (*handle)->table.name);
+	strcpy(c->chain_name , ici->name);
+	c->ext.ent.rule_number = (rulenum > ici->num_entries)?/*it means append*/
+						ici->num_entries+1:rulenum ;
+	c->family = TC_AF;
 
+	if((ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, c, s))<0){
+		free(c); errno = EFAULT;
+		return 0;
+	}
+	set_changed(*handle, 1);
+	
+	free(c);
 	return 1;
 }
 
-/* Atomically replace rule `rulenum' in `chain' with `fw'. */
+/* Atomically replace rule `rulenum' in `chain' with `e'. */
 int
 TC_REPLACE_ENTRY(const IPT_CHAINLABEL chain,
 		 const STRUCT_ENTRY *e,
 		 unsigned int rulenum,
 		 TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r, *old;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND *c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_REPLACE_ENTRY;
 
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
+	ici = find_label(chain, *handle);
+	if(!ici) return 0;
 
-	if (rulenum >= c->num_rules) {
-		errno = E2BIG;
-		return 0;
-	}
+	if(rulenum > ici->num_entries) {errno = E2BIG; return 0;}
+	((STRUCT_ENTRY*)e)->family = TC_AF;
 
-	/* Take advantage of the double linked list if possible. */
-	if (rulenum + 1 <= c->num_rules/2) {
-		old = iptcc_get_rule_num(c, rulenum + 1);
-	} else {
-		old = iptcc_get_rule_num_reverse(c, c->num_rules - rulenum);
-	}
+	s= sizeof(STRUCT_COMMAND) + e->size;
+	if(!(c = malloc( s ))){errno = ENOMEM;	return 0; }
 
-	if (!(r = iptcc_alloc_rule(c, e->next_offset))) {
-		errno = ENOMEM;
-		return 0;
-	}
+	map_target(*handle, (STRUCT_ENTRY *)e, &save);
 
-	memcpy(r->entry, e, e->next_offset);
-	r->counter_map.maptype = COUNTER_MAP_SET;
+	/* copy entry as payload */
+	memcpy( (void *)c+ sizeof(STRUCT_COMMAND), e, e->size);
 
-	if (!iptcc_map_target(*handle, r)) {
-		free(r);
-		return 0;
-	}
+	unmap_target((STRUCT_ENTRY *)e, &save);
 
-	list_add(&r->list, &old->list);
-	iptcc_delete_rule(old);
+	c->command = PKTT_ENTRY_REPLACE;
+	strcpy(c->table_name, (*handle)->table.name);
+	strcpy(c->chain_name, ici->name );
+	c->ext.ent.rule_number = rulenum;
+	c->family = TC_AF;
 
-	set_changed(*handle);
+	if( (ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, c, s)) <0 ){
+		free(c); errno = EFAULT;
+		return 0;
+	}
+	set_changed(*handle, 1);
 
+	free(c);
 	return 1;
 }
 
 /* Append entry `fw' to chain `chain'.  Equivalent to insert with
-   rulenum = length of chain. */
+   rulenum = (#chain_entries) + 1. */
 int
 TC_APPEND_ENTRY(const IPT_CHAINLABEL chain,
 		const STRUCT_ENTRY *e,
 		TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
-
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND *c;
+	socklen_t s;
+	int ret;
 	iptc_fn = TC_APPEND_ENTRY;
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		DEBUGP("unable to find chain `%s'\n", chain);
-		errno = ENOENT;
-		return 0;
-	}
 
-	if (!(r = iptcc_alloc_rule(c, e->next_offset))) {
-		DEBUGP("unable to allocate rule for chain `%s'\n", chain);
-		errno = ENOMEM;
-		return 0;
-	}
-
-	memcpy(r->entry, e, e->next_offset);
-	r->counter_map.maptype = COUNTER_MAP_SET;
-
-	if (!iptcc_map_target(*handle, r)) {
-		DEBUGP("unable to map target of rule for chain `%s'\n", chain);
-		free(r);
-		return 0;
-	}
-
-	list_add_tail(&r->list, &c->rules);
-	c->num_rules++;
-
-	set_changed(*handle);
-
-	return 1;
-}
-
-static inline int
-match_different(const STRUCT_ENTRY_MATCH *a,
-		const unsigned char *a_elems,
-		const unsigned char *b_elems,
-		unsigned char **maskptr)
-{
-	const STRUCT_ENTRY_MATCH *b;
-	unsigned int i;
+	ici = find_label(chain, *handle);
+	if(!ici) return 0;
+	
+	((STRUCT_ENTRY *)e)->family = TC_AF;
 
-	/* Offset of b is the same as a. */
-	b = (void *)b_elems + ((unsigned char *)a - a_elems);
+	s= sizeof(STRUCT_COMMAND) + e->size;
+	if(!(c = malloc( s ))){	errno = ENOMEM;	return 0;}
 
-	if (a->u.match_size != b->u.match_size)
-		return 1;
+	map_target(*handle, (STRUCT_ENTRY *)e, &save);
 
-	if (strcmp(a->u.user.name, b->u.user.name) != 0)
-		return 1;
+	memcpy( (void *)c + sizeof(STRUCT_COMMAND), e, e->size );
 
-	*maskptr += ALIGN(sizeof(*a));
+	unmap_target((STRUCT_ENTRY *)e, &save);
 
-	for (i = 0; i < a->u.match_size - ALIGN(sizeof(*a)); i++)
-		if (((a->data[i] ^ b->data[i]) & (*maskptr)[i]) != 0)
-			return 1;
-	*maskptr += i;
-	return 0;
-}
+	c->command = PKTT_ENTRY_ADD;
+	strcpy( c->table_name, (*handle)->table.name );
+	strcpy( c->chain_name, ici->name);
+	c->ext.ent.rule_number = ici->num_entries+1;
+	c->family = TC_AF;
 
-static inline int
-target_same(struct rule_head *a, struct rule_head *b,const unsigned char *mask)
-{
-	unsigned int i;
-	STRUCT_ENTRY_TARGET *ta, *tb;
-
-	if (a->type != b->type)
+	if( (ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, c, s))<0){
+		free(c); errno = EFAULT;
 		return 0;
-
-	ta = GET_TARGET(a->entry);
-	tb = GET_TARGET(b->entry);
-
-	switch (a->type) {
-	case IPTCC_R_FALLTHROUGH:
-		return 1;
-	case IPTCC_R_JUMP:
-		return a->jump == b->jump;
-	case IPTCC_R_STANDARD:
-		return ((STRUCT_STANDARD_TARGET *)ta)->verdict
-			== ((STRUCT_STANDARD_TARGET *)tb)->verdict;
-	case IPTCC_R_MODULE:
-		if (ta->u.target_size != tb->u.target_size)
-			return 0;
-		if (strcmp(ta->u.user.name, tb->u.user.name) != 0)
-			return 0;
-
-		for (i = 0; i < ta->u.target_size - sizeof(*ta); i++)
-			if (((ta->data[i] ^ tb->data[i]) & mask[i]) != 0)
-				return 0;
-		return 1;
-	default:
-		fprintf(stderr, "ERROR: bad type %i\n", a->type);
-		abort();
 	}
-}
+	set_changed(*handle, 1);
 
-static unsigned char *
-is_same(const STRUCT_ENTRY *a,
-	const STRUCT_ENTRY *b,
-	unsigned char *matchmask);
+	free(c);
+	return 1;
+}
 
 /* Delete the first rule in `chain' which matches `fw'. */
 int
@@ -1905,112 +679,68 @@ TC_DELETE_ENTRY(const IPT_CHAINLABEL chain,
 		unsigned char *matchmask,
 		TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r, *i;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND *c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_DELETE_ENTRY;
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
+	if (!(ici = find_label(chain, *handle))) return 0;
 
-	/* Create a rule_head from origfw. */
-	r = iptcc_alloc_rule(c, origfw->next_offset);
-	if (!r) {
-		errno = ENOMEM;
-		return 0;
-	}
+	((STRUCT_ENTRY*)origfw)->family = TC_AF;
 
-	memcpy(r->entry, origfw, origfw->next_offset);
-	r->counter_map.maptype = COUNTER_MAP_NOMAP;
-	if (!iptcc_map_target(*handle, r)) {
-		DEBUGP("unable to map target of rule for chain `%s'\n", chain);
-		free(r);
-		return 0;
-	} else {
-		/* iptcc_map_target increment target chain references
-		 * since this is a fake rule only used for matching
-		 * the chain references count is decremented again. 
-		 */
-		if (r->type == IPTCC_R_JUMP
-		    && r->jump)
-			r->jump->references--;
-	}
+	s= sizeof(STRUCT_COMMAND) + origfw->size;
+	if(!(c = malloc( s ))){ errno = ENOMEM; return 0; }
 
-	list_for_each_entry(i, &c->rules, list) {
-		unsigned char *mask;
+	map_target(*handle, (STRUCT_ENTRY *)origfw, &save);
 
-		mask = is_same(r->entry, i->entry, matchmask);
-		if (!mask)
-			continue;
+	memcpy( (void *)c+sizeof(STRUCT_COMMAND), origfw, origfw->size);
 
-		if (!target_same(r, i, mask))
-			continue;
-
-		/* If we are about to delete the rule that is the
-		 * current iterator, move rule iterator back.  next
-		 * pointer will then point to real next node */
-		if (i == (*handle)->rule_iterator_cur) {
-			(*handle)->rule_iterator_cur = 
-				list_entry((*handle)->rule_iterator_cur->list.prev,
-					   struct rule_head, list);
-		}
+	unmap_target((STRUCT_ENTRY *)origfw, &save);
 
-		c->num_rules--;
-		iptcc_delete_rule(i);
+	c->command = PKTT_ENTRY_DEL_WITH_RULE;
+	strcpy(c->table_name, (*handle)->table.name);
+	strcpy(c->chain_name, ici->name);
+	c->family = TC_AF;
 
-		set_changed(*handle);
-		free(r);
-		return 1;
+	if((ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, c, s))<0){
+		free(c); errno = EFAULT;
+		return 0;
 	}
+	set_changed(*handle, 1);
 
-	free(r);
-	errno = ENOENT;
-	return 0;
+	free(c);
+	return 1;
 }
 
-
 /* Delete the rule in position `rulenum' in `chain'. */
 int
 TC_DELETE_NUM_ENTRY(const IPT_CHAINLABEL chain,
 		    unsigned int rulenum,
 		    TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_DELETE_NUM_ENTRY;
+	if(!(ici = find_label(chain, *handle))) return 0;
 
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
-
-	if (rulenum >= c->num_rules) {
-		errno = E2BIG;
-		return 0;
-	}
+	if(rulenum > ici->num_entries) {errno = E2BIG; return 0;}
 
-	/* Take advantage of the double linked list if possible. */
-	if (rulenum + 1 <= c->num_rules/2) {
-		r = iptcc_get_rule_num(c, rulenum + 1);
-	} else {
-		r = iptcc_get_rule_num_reverse(c, c->num_rules - rulenum);
-	}
+	c.command = PKTT_ENTRY_DEL_WITH_NUM;
+	strcpy(c.table_name, (*handle)->table.name);
+	strcpy(c.chain_name, ici->name);
+	c.ext.ent.rule_number = rulenum;
+	c.family = TC_AF;
 
-	/* If we are about to delete the rule that is the current
-	 * iterator, move rule iterator back.  next pointer will then
-	 * point to real next node */
-	if (r == (*handle)->rule_iterator_cur) {
-		(*handle)->rule_iterator_cur = 
-			list_entry((*handle)->rule_iterator_cur->list.prev,
-				   struct rule_head, list);
+	s= sizeof( STRUCT_COMMAND);
+	if((ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
+		return 0;
 	}
-
-	c->num_rules--;
-	iptcc_delete_rule(r);
-
-	set_changed(*handle);
+	set_changed(*handle, 1);
 
 	return 1;
 }
@@ -2022,7 +752,6 @@ TC_CHECK_PACKET(const IPT_CHAINLABEL chain,
 		STRUCT_ENTRY *entry,
 		TC_HANDLE_T *handle)
 {
-	iptc_fn = TC_CHECK_PACKET;
 	errno = ENOSYS;
 	return NULL;
 }
@@ -2031,49 +760,53 @@ TC_CHECK_PACKET(const IPT_CHAINLABEL chain,
 int
 TC_FLUSH_ENTRIES(const IPT_CHAINLABEL chain, TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r, *tmp;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_FLUSH_ENTRIES;
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
-
-	list_for_each_entry_safe(r, tmp, &c->rules, list) {
-		iptcc_delete_rule(r);
-	}
-
-	c->num_rules = 0;
+	if(!(ici = find_label(chain, *handle))) return 0;
 
-	set_changed(*handle);
+	c.command = PKTT_CHAIN_FLUSH;
+	strcpy(c.table_name, (*handle)->table.name);
+	strcpy(c.chain_name, ici->name);
+	c.family = TC_AF;
 
+	s = sizeof(STRUCT_COMMAND);
+	if((ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
+		return 0;
+	}
+	set_changed(*handle, 1);
+	
 	return 1;
 }
 
-/* Zeroes the counters in a chain. */
+/* Zeroes the counters of the entries in a chain. */
 int
 TC_ZERO_ENTRIES(const IPT_CHAINLABEL chain, TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
-	iptc_fn = TC_ZERO_ENTRIES;
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
+	iptc_fn= TC_ZERO_ENTRIES;
+	if (!(ici = find_label(chain, *handle))) return 0;
 
-	if (c->counter_map.maptype == COUNTER_MAP_NORMAL_MAP)
-		c->counter_map.maptype = COUNTER_MAP_ZEROED;
+	c.command = PKTT_CHAIN_ZERO;
+	strcpy(c.table_name, (*handle)->table.name );
+	strcpy(c.chain_name, ici->name );
+	c.family = TC_AF;
 
-	list_for_each_entry(r, &c->rules, list) {
-		if (r->counter_map.maptype == COUNTER_MAP_NORMAL_MAP)
-			r->counter_map.maptype = COUNTER_MAP_ZEROED;
+	s= sizeof(STRUCT_COMMAND);
+	if((ret= setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
+		return 0;
 	}
-
-	set_changed(*handle);
-
+	set_changed(*handle, 2);
+	
 	return 1;
 }
 
@@ -2082,23 +815,36 @@ TC_READ_COUNTER(const IPT_CHAINLABEL chain,
 		unsigned int rulenum,
 		TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
-
-	iptc_fn = TC_READ_COUNTER;
-	CHECK(*handle);
-
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return NULL;
-	}
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COUNTERS *cnt;
+	STRUCT_COMMAND *c;
+	socklen_t s;
+	int ret;
+	
+	iptc_fn= TC_READ_COUNTER;
+	if(!(ici=find_label(chain, *handle))){ return NULL;}
 
-	if (!(r = iptcc_get_rule_num(c, rulenum))) {
-		errno = E2BIG;
-		return NULL;
+	if(rulenum > ici->num_entries) {errno = E2BIG; return NULL;}
+	
+	s = (sizeof(STRUCT_COUNTERS)  > sizeof(STRUCT_COMMAND))?
+		  sizeof(STRUCT_COUNTERS):sizeof(STRUCT_COMMAND);
+	if(!(c=malloc(s))){ errno=ENOMEM; return NULL; };
+
+	c->command = PKTT_ENTRY_GET_COUNTERS;
+	strcpy(c->table_name, (*handle)->table.name);
+	strcpy(c->chain_name, ici->name);
+	c->ext.ent.rule_number = rulenum;
+	c->family = TC_AF;
+
+	if((ret=getsockopt(sockfd, TC_IPPROTO, SO_GET_ENTRIES, c, &s))<0){
+		errno = EFAULT; free(c);
+		return 0;
 	}
+	cnt = malloc( sizeof(STRUCT_COUNTERS)); if(!cnt){errno=ENOMEM; free(c); return NULL;}
+	memcpy(cnt, c, sizeof(STRUCT_COUNTERS));
 
-	return &r->entry[0].counters;
+	free(c);
+	return cnt;
 }
 
 int
@@ -2106,26 +852,30 @@ TC_ZERO_COUNTER(const IPT_CHAINLABEL chain,
 		unsigned int rulenum,
 		TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
-	
-	iptc_fn = TC_ZERO_COUNTER;
-	CHECK(*handle);
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
+	iptc_fn= TC_ZERO_COUNTER;
+	if(!(ici = find_label(chain, *handle))){return 0;}
 
-	if (!(r = iptcc_get_rule_num(c, rulenum))) {
-		errno = E2BIG;
-		return 0;
-	}
+	if(rulenum > ici->num_entries){ errno = E2BIG; return 0;}
 
-	if (r->counter_map.maptype == COUNTER_MAP_NORMAL_MAP)
-		r->counter_map.maptype = COUNTER_MAP_ZEROED;
+	c.command = PKTT_ENTRY_SET_COUNTER;
+	strcpy(c.table_name, (*handle)->table.name );
+	strcpy(c.chain_name, ici->name );
+	c.ext.ent.rule_number = rulenum;
+	c.ext.ent.counter.bcnt =0;
+	c.ext.ent.counter.pcnt =0;
+	c.family = TC_AF;
 
-	set_changed(*handle);
+	s= sizeof(STRUCT_COMMAND);
+	if((ret=setsockopt(sockfd, TC_IPPROTO, SO_SET_ADD_COUNTERS, &c, s))<0){
+		errno = EFAULT;
+		return 0;
+	}
+	set_changed(*handle, 2);
 
 	return 1;
 }
@@ -2136,90 +886,74 @@ TC_SET_COUNTER(const IPT_CHAINLABEL chain,
 	       STRUCT_COUNTERS *counters,
 	       TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
-	struct rule_head *r;
-	STRUCT_ENTRY *e;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
-	iptc_fn = TC_SET_COUNTER;
-	CHECK(*handle);
+	iptc_fn= TC_SET_COUNTER;
+	if(!(ici= find_label(chain, *handle))){	return 0;}
 
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
+	if(rulenum > ici->num_entries) {errno = E2BIG; return 0;}
 
-	if (!(r = iptcc_get_rule_num(c, rulenum))) {
-		errno = E2BIG;
-		return 0;
-	}
+	c.command = PKTT_ENTRY_SET_COUNTER;
+	strcpy( c.table_name, (*handle)->table.name );
+	strcpy( c.chain_name, ici->name);
+	c.ext.ent.rule_number= rulenum;
+	c.ext.ent.counter.bcnt = counters->bcnt;
+	c.ext.ent.counter.pcnt = counters->pcnt;
+	c.family = TC_AF;
 
-	e = r->entry;
-	r->counter_map.maptype = COUNTER_MAP_SET;
+	s = sizeof(STRUCT_COMMAND);
+	if((ret=setsockopt(sockfd, TC_IPPROTO, SO_SET_ADD_COUNTERS, &c, s))<0){
+		errno = EFAULT; return 0;
+	}
+	set_changed(*handle, 2);
 
-	memcpy(&e->counters, counters, sizeof(STRUCT_COUNTERS));
+	return 1;
+}
 
-	set_changed(*handle);
+int
+TC_BUILTIN(const IPT_CHAINLABEL chain, const TC_HANDLE_T handle)
+{
+	unsigned int i;
+	
+	iptc_fn= TC_BUILTIN;
 
-	return 1;
+	for(i=0; i<NUMHOOKS; ++i){
+		if( !(handle->table.valid_hooks & (1<<i)) )
+			continue;
+		if( !strcmp( chain , handle->hooknames[i] ) )
+			return 1;
+	}
+	return 0;
 }
 
 /* Creates a new chain. */
-/* To create a chain, create two rules: error node and unconditional
- * return. */
 int
 TC_CREATE_CHAIN(const IPT_CHAINLABEL chain, TC_HANDLE_T *handle)
 {
-	static struct chain_head *c;
-	int capacity;
-	int exceeded;
+	STRUCT_CHAIN_INFO *pci;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_CREATE_CHAIN;
 
-	/* find_label doesn't cover built-in targets: DROP, ACCEPT,
-           QUEUE, RETURN. */
-	if (iptcc_find_label(chain, *handle)
-	    || strcmp(chain, LABEL_DROP) == 0
-	    || strcmp(chain, LABEL_ACCEPT) == 0
-	    || strcmp(chain, LABEL_QUEUE) == 0
-	    || strcmp(chain, LABEL_RETURN) == 0) {
-		DEBUGP("Chain `%s' already exists\n", chain);
-		errno = EEXIST;
-		return 0;
-	}
+	pci = find_label(chain, *handle);
+	if(pci){ errno = EEXIST; return 0;}
 
-	if (strlen(chain)+1 > sizeof(IPT_CHAINLABEL)) {
-		DEBUGP("Chain name `%s' too long\n", chain);
-		errno = EINVAL;
-		return 0;
-	}
+	c.command = PKTT_CHAIN_NEW;
+	strcpy(c.table_name, (*handle)->table.name );
+	strcpy(c.chain_name, chain );
+	c.family = TC_AF;
 
-	c = iptcc_alloc_chain_head(chain, 0);
-	if (!c) {
-		DEBUGP("Cannot allocate memory for chain `%s'\n", chain);
-		errno = ENOMEM;
+	s = sizeof(STRUCT_COMMAND);
+	if( (ret=setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
 		return 0;
-
-	}
-	(*handle)->num_chains++; /* New user defined chain */
-
-	DEBUGP("Creating chain `%s'\n", chain);
-	iptc_insert_chain(*handle, c); /* Insert sorted */
-
-	/* Inserting chains don't change the correctness of the chain
-	 * index (except if its smaller than index[0], but that
-	 * handled by iptc_insert_chain).  It only causes longer lists
-	 * in the buckets. Thus, only rebuild chain index when the
-	 * capacity is exceed with CHAIN_INDEX_INSERT_MAX chains.
-	 */
-	capacity = (*handle)->chain_index_sz * CHAIN_INDEX_BUCKET_LEN;
-	exceeded = ((((*handle)->num_chains)-capacity));
-	if (exceeded > CHAIN_INDEX_INSERT_MAX) {
-		debug("Capacity(%d) exceeded(%d) rebuild (chains:%d)\n",
-		      capacity, exceeded, (*handle)->num_chains);
-		iptcc_chain_index_rebuild(*handle);
 	}
-
-	set_changed(*handle);
+	set_changed(*handle, 0);
 
 	return 1;
 }
@@ -2229,71 +963,53 @@ int
 TC_GET_REFERENCES(unsigned int *ref, const IPT_CHAINLABEL chain,
 		  TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
+	STRUCT_CHAIN_INFO *ici;
 
-	iptc_fn = TC_GET_REFERENCES;
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		errno = ENOENT;
-		return 0;
-	}
-
-	*ref = c->references;
+	iptc_fn= TC_GET_REFERENCES;
+	if (!(ici = find_label(chain, *handle))){ return 0;}
+	*ref = ici->refcnt;
 
 	return 1;
 }
 
+/* Get the chain classifier */
+const char *
+TC_GET_CLASSIFIER(const IPT_CHAINLABEL chain, TC_HANDLE_T *handle)
+{
+	STRUCT_CHAIN_INFO *ici;
+
+	iptc_fn = TC_GET_CLASSIFIER;
+	if(!(ici = find_label(chain, *handle))){ return NULL;}
+
+	return ici->classifier_name;
+}
+
 /* Deletes a chain. */
 int
 TC_DELETE_CHAIN(const IPT_CHAINLABEL chain, TC_HANDLE_T *handle)
 {
-	unsigned int references;
-	struct chain_head *c;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_DELETE_CHAIN;
+	if( !(ici = find_label(chain, *handle)) ){ return 0;}
+	
+	if( TC_BUILTIN(chain, *handle ) ){ errno = EINVAL; return 0;}
+	if( ici->refcnt ) {errno = EMLINK; return 0;}
 
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		DEBUGP("cannot find chain `%s'\n", chain);
-		errno = ENOENT;
-		return 0;
-	}
-
-	if (TC_BUILTIN(chain, *handle)) {
-		DEBUGP("cannot remove builtin chain `%s'\n", chain);
-		errno = EINVAL;
-		return 0;
-	}
-
-	if (!TC_GET_REFERENCES(&references, chain, handle)) {
-		DEBUGP("cannot get references on chain `%s'\n", chain);
-		return 0;
-	}
-
-	if (references > 0) {
-		DEBUGP("chain `%s' still has references\n", chain);
-		errno = EMLINK;
-		return 0;
-	}
-
-	if (c->num_rules) {
-		DEBUGP("chain `%s' is not empty\n", chain);
-		errno = ENOTEMPTY;
+	c.command = PKTT_CHAIN_DELETE;
+	strcpy(c.table_name, (*handle)->table.name);
+	strcpy(c.chain_name, chain);
+	c.family = TC_AF;
+	
+	s = sizeof( STRUCT_COMMAND );
+	if( (ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
 		return 0;
 	}
-
-	/* If we are about to delete the chain that is the current
-	 * iterator, move chain iterator forward. */
-	if (c == (*handle)->chain_iterator_cur)
-		iptcc_chain_iterator_advance(*handle);
-
-	(*handle)->num_chains--; /* One user defined chain deleted */
-
-	//list_del(&c->list); /* Done in iptcc_chain_index_delete_chain() */
-	iptcc_chain_index_delete_chain(c, *handle);
-	free(c);
-
-	DEBUGP("chain `%s' deleted\n", chain);
-
-	set_changed(*handle);
+	set_changed(*handle, 0);
 
 	return 1;
 }
@@ -2303,333 +1019,111 @@ int TC_RENAME_CHAIN(const IPT_CHAINLABEL oldname,
 		    const IPT_CHAINLABEL newname,
 		    TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
+
 	iptc_fn = TC_RENAME_CHAIN;
+	if(!(ici=find_label(oldname, *handle))){ return 0;}
 
-	/* find_label doesn't cover built-in targets: DROP, ACCEPT,
-           QUEUE, RETURN. */
-	if (iptcc_find_label(newname, *handle)
-	    || strcmp(newname, LABEL_DROP) == 0
-	    || strcmp(newname, LABEL_ACCEPT) == 0
-	    || strcmp(newname, LABEL_QUEUE) == 0
-	    || strcmp(newname, LABEL_RETURN) == 0) {
-		errno = EEXIST;
-		return 0;
+	if( TC_BUILTIN( oldname, *handle ) ){
+		errno = EINVAL; return 0;
 	}
-
-	if (!(c = iptcc_find_label(oldname, *handle))
-	    || TC_BUILTIN(oldname, *handle)) {
-		errno = ENOENT;
-		return 0;
+	if( (strlen( newname ) +1) > CHAIN_MAXNAMELEN ){
+		errno = E2BIG; return 0;
 	}
 
-	if (strlen(newname)+1 > sizeof(IPT_CHAINLABEL)) {
-		errno = EINVAL;
+	c.command = PKTT_CHAIN_RENAME;
+	strcpy(c.table_name, (*handle)->table.name);
+	strcpy(c.chain_name, oldname);
+	strcpy(c.ext.new_chain_name, newname);
+	c.family = TC_AF;
+
+	s = sizeof(STRUCT_COMMAND);
+	if((ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
 		return 0;
 	}
-
-	strncpy(c->name, newname, sizeof(IPT_CHAINLABEL));
-	
-	set_changed(*handle);
+	strcpy(ici->name, newname);
 
 	return 1;
 }
 
-/* Sets the policy on a built-in chain. */
+/* Sets the policy on a chain. */
 int
 TC_SET_POLICY(const IPT_CHAINLABEL chain,
 	      const IPT_CHAINLABEL policy,
 	      STRUCT_COUNTERS *counters,
 	      TC_HANDLE_T *handle)
 {
-	struct chain_head *c;
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
 	iptc_fn = TC_SET_POLICY;
-
-	if (!(c = iptcc_find_label(chain, *handle))) {
-		DEBUGP("cannot find chain `%s'\n", chain);
-		errno = ENOENT;
-		return 0;
-	}
-
-	if (!iptcc_is_builtin(c)) {
-		DEBUGP("cannot set policy of userdefinedchain `%s'\n", chain);
-		errno = ENOENT;
-		return 0;
-	}
-
-	if (strcmp(policy, LABEL_ACCEPT) == 0)
-		c->verdict = -NF_ACCEPT - 1;
-	else if (strcmp(policy, LABEL_DROP) == 0)
-		c->verdict = -NF_DROP - 1;
-	else {
-		errno = EINVAL;
+	if(!(ici=find_label( chain, *handle))){ return 0; }
+
+	c.command = PKTT_CHAIN_SET_POLICY;
+	strcpy( c.table_name, (*handle)->table.name);
+	strcpy( c.chain_name, ici->name);
+	c.family = TC_AF;
+
+	if( !strcmp(policy , LABEL_ACCEPT) ) c.ext.policy=cACCEPT;
+	else if( !strcmp(policy, LABEL_DROP) ) c.ext.policy=cDROP;
+	else if( !strcmp(policy, LABEL_QUEUE) ) c.ext.policy=cQUEUE;
+	else if( !strcmp(policy, LABEL_RETURN) ) c.ext.policy=cRETURN;
+	else { errno=EINVAL; return 0; }
+
+	s = sizeof(STRUCT_COMMAND);
+	if((ret= setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT;
 		return 0;
 	}
-
-	if (counters) {
-		/* set byte and packet counters */
-		memcpy(&c->counters, counters, sizeof(STRUCT_COUNTERS));
-		c->counter_map.maptype = COUNTER_MAP_SET;
-	} else {
-		c->counter_map.maptype = COUNTER_MAP_NOMAP;
-	}
-
-	set_changed(*handle);
+	ici->policy = c.ext.policy;
 
 	return 1;
 }
 
-/* Without this, on gcc 2.7.2.3, we get:
-   libiptc.c: In function `TC_COMMIT':
-   libiptc.c:833: fixed or forbidden register was spilled.
-   This may be due to a compiler bug or to impossible asm
-   statements or clauses.
-*/
-static void
-subtract_counters(STRUCT_COUNTERS *answer,
-		  const STRUCT_COUNTERS *a,
-		  const STRUCT_COUNTERS *b)
-{
-	answer->pcnt = a->pcnt - b->pcnt;
-	answer->bcnt = a->bcnt - b->bcnt;
-}
-
-
-static void counters_nomap(STRUCT_COUNTERS_INFO *newcounters, unsigned int idx)
-{
-	newcounters->counters[idx] = ((STRUCT_COUNTERS) { 0, 0});
-	DEBUGP_C("NOMAP => zero\n");
-}
-
-static void counters_normal_map(STRUCT_COUNTERS_INFO *newcounters,
-				STRUCT_REPLACE *repl, unsigned int idx,
-				unsigned int mappos)
-{
-	/* Original read: X.
-	 * Atomic read on replacement: X + Y.
-	 * Currently in kernel: Z.
-	 * Want in kernel: X + Y + Z.
-	 * => Add in X + Y
-	 * => Add in replacement read.
-	 */
-	newcounters->counters[idx] = repl->counters[mappos];
-	DEBUGP_C("NORMAL_MAP => mappos %u \n", mappos);
-}
-
-static void counters_map_zeroed(STRUCT_COUNTERS_INFO *newcounters,
-				STRUCT_REPLACE *repl, unsigned int idx,
-				unsigned int mappos, STRUCT_COUNTERS *counters)
+int
+TC_CHG_CLASSIFIER(const IPT_CHAINLABEL chain,
+		  const IPT_CHAINLABEL new_classifier,
+		  TC_HANDLE_T *handle)
 {
-	/* Original read: X.
-	 * Atomic read on replacement: X + Y.
-	 * Currently in kernel: Z.
-	 * Want in kernel: Y + Z.
-	 * => Add in Y.
-	 * => Add in (replacement read - original read).
-	 */
-	subtract_counters(&newcounters->counters[idx],
-			  &repl->counters[mappos],
-			  counters);
-	DEBUGP_C("ZEROED => mappos %u\n", mappos);
-}
+	STRUCT_CHAIN_INFO *ici;
+	STRUCT_COMMAND c;
+	socklen_t s;
+	int ret;
 
-static void counters_map_set(STRUCT_COUNTERS_INFO *newcounters,
-                             unsigned int idx, STRUCT_COUNTERS *counters)
-{
-	/* Want to set counter (iptables-restore) */
+	iptc_fn = TC_CHG_CLASSIFIER;
+	if(!(ici = find_label(chain, *handle))){ return 0;}
+	
+	c.command = PKTT_CHAIN_CHG_CLASSIFIER;
+	strcpy(c.table_name, (*handle)->table.name);
+	strcpy(c.chain_name, ici -> name);
+	strcpy(c.ext.new_classifier, new_classifier);
+	c.family = TC_AF;
 
-	memcpy(&newcounters->counters[idx], counters,
-		sizeof(STRUCT_COUNTERS));
+	s = sizeof( STRUCT_COMMAND );
+	if((ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, &c, s))<0){
+		errno = EFAULT; return 0;
+	}
+	strcpy( ici->classifier_name, new_classifier);
 
-	DEBUGP_C("SET\n");
+	return 1;
 }
 
-
 int
 TC_COMMIT(TC_HANDLE_T *handle)
 {
-	/* Replace, then map back the counters. */
-	STRUCT_REPLACE *repl;
-	STRUCT_COUNTERS_INFO *newcounters;
-	struct chain_head *c;
-	int ret;
-	size_t counterlen;
-	int new_number;
-	unsigned int new_size;
-
-	iptc_fn = TC_COMMIT;
-	CHECK(*handle);
-
-	/* Don't commit if nothing changed. */
-	if (!(*handle)->changed)
-		goto finished;
-
-	new_number = iptcc_compile_table_prep(*handle, &new_size);
-	if (new_number < 0) {
-		errno = ENOMEM;
-		goto out_zero;
-	}
-
-	repl = malloc(sizeof(*repl) + new_size);
-	if (!repl) {
-		errno = ENOMEM;
-		goto out_zero;
-	}
-	memset(repl, 0, sizeof(*repl) + new_size);
-
-#if 0
-	TC_DUMP_ENTRIES(*handle);
-#endif
-
-	counterlen = sizeof(STRUCT_COUNTERS_INFO)
-			+ sizeof(STRUCT_COUNTERS) * new_number;
-
-	/* These are the old counters we will get from kernel */
-	repl->counters = malloc(sizeof(STRUCT_COUNTERS)
-				* (*handle)->info.num_entries);
-	if (!repl->counters) {
-		errno = ENOMEM;
-		goto out_free_repl;
-	}
-	/* These are the counters we're going to put back, later. */
-	newcounters = malloc(counterlen);
-	if (!newcounters) {
-		errno = ENOMEM;
-		goto out_free_repl_counters;
-	}
-	memset(newcounters, 0, counterlen);
-
-	strcpy(repl->name, (*handle)->info.name);
-	repl->num_entries = new_number;
-	repl->size = new_size;
-
-	repl->num_counters = (*handle)->info.num_entries;
-	repl->valid_hooks = (*handle)->info.valid_hooks;
-
-	DEBUGP("num_entries=%u, size=%u, num_counters=%u\n",
-		repl->num_entries, repl->size, repl->num_counters);
-
-	ret = iptcc_compile_table(*handle, repl);
-	if (ret < 0) {
-		errno = ret;
-		goto out_free_newcounters;
-	}
-
-
-#ifdef IPTC_DEBUG2
-	{
-		int fd = open("/tmp/libiptc-so_set_replace.blob", 
-				O_CREAT|O_WRONLY);
-		if (fd >= 0) {
-			write(fd, repl, sizeof(*repl) + repl->size);
-			close(fd);
-		}
-	}
-#endif
-
-	ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_REPLACE, repl,
-			 sizeof(*repl) + repl->size);
-	if (ret < 0)
-		goto out_free_newcounters;
-
-	/* Put counters back. */
-	strcpy(newcounters->name, (*handle)->info.name);
-	newcounters->num_counters = new_number;
-
-	list_for_each_entry(c, &(*handle)->chains, list) {
-		struct rule_head *r;
-
-		/* Builtin chains have their own counters */
-		if (iptcc_is_builtin(c)) {
-			DEBUGP("counter for chain-index %u: ", c->foot_index);
-			switch(c->counter_map.maptype) {
-			case COUNTER_MAP_NOMAP:
-				counters_nomap(newcounters, c->foot_index);
-				break;
-			case COUNTER_MAP_NORMAL_MAP:
-				counters_normal_map(newcounters, repl,
-						    c->foot_index, 
-						    c->counter_map.mappos);
-				break;
-			case COUNTER_MAP_ZEROED:
-				counters_map_zeroed(newcounters, repl,
-						    c->foot_index, 
-						    c->counter_map.mappos,
-						    &c->counters);
-				break;
-			case COUNTER_MAP_SET:
-				counters_map_set(newcounters, c->foot_index,
-						 &c->counters);
-				break;
-			}
-		}
-
-		list_for_each_entry(r, &c->rules, list) {
-			DEBUGP("counter for index %u: ", r->index);
-			switch (r->counter_map.maptype) {
-			case COUNTER_MAP_NOMAP:
-				counters_nomap(newcounters, r->index);
-				break;
-
-			case COUNTER_MAP_NORMAL_MAP:
-				counters_normal_map(newcounters, repl,
-						    r->index, 
-						    r->counter_map.mappos);
-				break;
-
-			case COUNTER_MAP_ZEROED:
-				counters_map_zeroed(newcounters, repl,
-						    r->index,
-						    r->counter_map.mappos,
-						    &r->entry->counters);
-				break;
-
-			case COUNTER_MAP_SET:
-				counters_map_set(newcounters, r->index,
-						 &r->entry->counters);
-				break;
-			}
-		}
-	}
-
-#ifdef IPTC_DEBUG2
-	{
-		int fd = open("/tmp/libiptc-so_set_add_counters.blob", 
-				O_CREAT|O_WRONLY);
-		if (fd >= 0) {
-			write(fd, newcounters, counterlen);
-			close(fd);
-		}
-	}
-#endif
-
-	ret = setsockopt(sockfd, TC_IPPROTO, SO_SET_ADD_COUNTERS,
-			 newcounters, counterlen);
-	if (ret < 0)
-		goto out_free_newcounters;
-
-	free(repl->counters);
-	free(repl);
-	free(newcounters);
-
-finished:
 	TC_FREE(handle);
 	return 1;
-
-out_free_newcounters:
-	free(newcounters);
-out_free_repl_counters:
-	free(repl->counters);
-out_free_repl:
-	free(repl);
-out_zero:
-	return 0;
 }
 
 /* Get raw socket. */
 int
-TC_GET_RAW_SOCKET(void)
+TC_GET_RAW_SOCKET()
 {
 	return sockfd;
 }
@@ -2644,40 +1138,36 @@ TC_STRERROR(int err)
 		int err;
 		const char *message;
 	} table [] =
-	  { { TC_INIT, EPERM, "Permission denied (you must be root)" },
-	    { TC_INIT, EINVAL, "Module is wrong version" },
-	    { TC_INIT, ENOENT, 
-		    "Table does not exist (do you need to insmod?)" },
-	    { TC_DELETE_CHAIN, ENOTEMPTY, "Chain is not empty" },
+	  {  	    
+	    { TC_INIT, EPERM, "Permission denied (you must be root)" },
+	    { TC_INIT, E2BIG, "Table name length is too big" },
+	    { TC_INIT, EFAULT, "Check table name" },
+	    { TC_GET_RULE, E2BIG, "Rule index is too big" },
 	    { TC_DELETE_CHAIN, EINVAL, "Can't delete built-in chain" },
 	    { TC_DELETE_CHAIN, EMLINK,
 	      "Can't delete chain with references left" },
+	    { TC_RENAME_CHAIN, EINVAL, "Can't rename built-in chain" },
+	    { TC_RENAME_CHAIN, E2BIG, "Chain name is too big" },
 	    { TC_CREATE_CHAIN, EEXIST, "Chain already exists" },
 	    { TC_INSERT_ENTRY, E2BIG, "Index of insertion too big" },
+	    { TC_INSERT_ENTRY, EINVAL, "Target Problem" },
 	    { TC_REPLACE_ENTRY, E2BIG, "Index of replacement too big" },
+	    { TC_REPLACE_ENTRY, EINVAL, "Target problem" },
 	    { TC_DELETE_NUM_ENTRY, E2BIG, "Index of deletion too big" },
+	    { TC_DELETE_ENTRY, EFAULT,
+	      "Bad rule (does a matching rule exist in that chain?)" },
 	    { TC_READ_COUNTER, E2BIG, "Index of counter too big" },
 	    { TC_ZERO_COUNTER, E2BIG, "Index of counter too big" },
-	    { TC_INSERT_ENTRY, ELOOP, "Loop found in table" },
-	    { TC_INSERT_ENTRY, EINVAL, "Target problem" },
-	    /* EINVAL for CHECK probably means bad interface. */
-	    { TC_CHECK_PACKET, EINVAL,
-	      "Bad arguments (does that interface exist?)" },
-	    { TC_CHECK_PACKET, ENOSYS,
-	      "Checking will most likely never get implemented" },
-	    /* ENOENT for DELETE probably means no matching rule */
-	    { TC_DELETE_ENTRY, ENOENT,
-	      "Bad rule (does a matching rule exist in that chain?)" },
-	    { TC_SET_POLICY, ENOENT,
-	      "Bad built-in chain name" },
-	    { TC_SET_POLICY, EINVAL,
-	      "Bad policy name" },
-
+	    { TC_SET_COUNTER, E2BIG, "Index of counter too big" },
+	    { TC_SET_POLICY, EINVAL, "Bad policy name" },
 	    { NULL, 0, "Incompatible with this kernel" },
+	    { NULL, EPERM, "Permission denied ( you must be root )" },
 	    { NULL, ENOPROTOOPT, "iptables who? (do you need to insmod?)" },
 	    { NULL, ENOSYS, "Will be implemented real soon.  I promise ;)" },
 	    { NULL, ENOMEM, "Memory allocation problem" },
 	    { NULL, ENOENT, "No chain/target/match by that name" },
+	    { NULL, EFAULT, "Some Errors were Rised in Kernel Level"},
+	    { NULL, EINVAL, "Chain/Table Name is too long"},
 	  };
 
 	for (i = 0; i < sizeof(table)/sizeof(struct table_struct); i++) {
diff --git a/include/libiptc/libiptc.h b/include/libiptc/libiptc.h
index 1f6f95d..895b1d0 100644
--- a/include/libiptc/libiptc.h
+++ b/include/libiptc/libiptc.h
@@ -25,6 +25,7 @@ typedef char ipt_chainlabel[32];
 #define IPTC_LABEL_DROP    "DROP"
 #define IPTC_LABEL_QUEUE   "QUEUE"
 #define IPTC_LABEL_RETURN  "RETURN"
+#define IPTC_LABEL_CONTINUE "CONTINUE"
 
 /* Transparent handle type. */
 typedef struct iptc_handle *iptc_handle_t;
@@ -59,7 +60,7 @@ int iptc_builtin(const char *chain, const iptc_handle_t handle);
 
 /* Get the policy of a given built-in chain */
 const char *iptc_get_policy(const char *chain,
-			    struct ipt_counters *counter,
+			    struct pktt_counters *counter,
 			    iptc_handle_t *handle);
 
 /* These functions return TRUE for OK or 0 and set errno.  If errno ==
@@ -123,19 +124,28 @@ int iptc_rename_chain(const ipt_chainlabel oldname,
 		      const ipt_chainlabel newname,
 		      iptc_handle_t *handle);
 
-/* Sets the policy on a built-in chain. */
+/* Sets the policy on a chain. */
 int iptc_set_policy(const ipt_chainlabel chain,
 		    const ipt_chainlabel policy,
-		    struct ipt_counters *counters,
+		    struct pktt_counters *counters,
 		    iptc_handle_t *handle);
 
+/* change the chain classifier */
+int iptc_chg_classifier(const ipt_chainlabel chain,
+                        const ipt_chainlabel new_classifier,
+                        iptc_handle_t *handle);
+
+/* Get the chain classifier */
+const char * iptc_get_classifier(const ipt_chainlabel chain,
+                                 iptc_handle_t *handle);
+
 /* Get the number of references to this chain */
 int iptc_get_references(unsigned int *ref,
 			const ipt_chainlabel chain,
 			iptc_handle_t *handle);
 
 /* read packet and byte counters for a specific rule */
-struct ipt_counters *iptc_read_counter(const ipt_chainlabel chain,
+struct pktt_counters *iptc_read_counter(const ipt_chainlabel chain,
 				       unsigned int rulenum,
 				       iptc_handle_t *handle);
 
@@ -147,7 +157,7 @@ int iptc_zero_counter(const ipt_chainlabel chain,
 /* set packet and byte counters for a specific rule */
 int iptc_set_counter(const ipt_chainlabel chain,
 		     unsigned int rulenum,
-		     struct ipt_counters *counters,
+		     struct pktt_counters *counters,
 		     iptc_handle_t *handle);
 
 /* Makes the actual changes. */

