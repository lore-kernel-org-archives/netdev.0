From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/3] netns: fix net_generic() "id - 1" bloat
Date: Fri, 2 Dec 2016 04:21:32 +0300
Message-ID: <20161202012132.GD31170@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33622 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbcLAXVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:21:42 -0500
Received: by mail-lf0-f67.google.com with SMTP id 98so20431106lfs.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 15:21:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_generic() function is both a) inline and b) used ~600 times.

It has the following code inside

		...
	ptr = ng->ptr[id - 1];
		...

"id" is never compile time constant so compiler is forced to subtract 1.
And those decrements or LEA [r32 - 1] instructions add up.

We also start id'ing from 1 to catch bugs where pernet sybsystem id
is not initialized and 0. This is quite pointless idea (nothing will
work or immediate interference with first registered subsystem) in
general but it hints what needs to be done for code size reduction.

Namely, overlaying allocation of pointer array and fixed part of
structure in the beginning and using usual base-0 addressing.

Ids are just cookies, their exact values do not matter, so lets start
with 3 on x86_64.

Code size savings (oh boy): -4.2 KB

As usual, ignore the initial compiler stupidity part of the table.

	add/remove: 0/0 grow/shrink: 12/670 up/down: 89/-4297 (-4208)
	function                                     old     new   delta
	tipc_nametbl_insert_publ                    1250    1270     +20
	nlmclnt_lookup_host                          686     703     +17
	nfsd4_encode_fattr                          5930    5941     +11
	nfs_get_client                              1050    1061     +11
	register_pernet_operations                   333     342      +9
	tcf_mirred_init                              843     849      +6
	tcf_bpf_init                                1143    1149      +6
	gss_setup_upcall                             990     994      +4
	idmap_name_to_id                             432     434      +2
	ops_init                                     274     275      +1
	nfsd_inject_forget_client                    259     260      +1
	nfs4_alloc_client                            612     613      +1
	tunnel_key_walker                            164     163      -1

		...

	tipc_bcbase_select_primary                   392     360     -32
	mac80211_hwsim_new_radio                    2808    2767     -41
	ipip6_tunnel_ioctl                          2228    2186     -42
	tipc_bcast_rcv                               715     672     -43
	tipc_link_build_proto_msg                   1140    1089     -51
	nfsd4_lock                                  3851    3796     -55
	tipc_mon_rcv                                1012     956     -56
	Total: Before=156643951, After=156639743, chg -0.00%


Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/generic.h |   16 +++++++++-------
 net/core/net_namespace.c    |   20 ++++++++++++--------
 2 files changed, 21 insertions(+), 15 deletions(-)

--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -25,12 +25,14 @@
  */
 
 struct net_generic {
-	struct {
-		unsigned int len;
-		struct rcu_head rcu;
-	} s;
-
-	void *ptr[0];
+	union {
+		struct {
+			unsigned int len;
+			struct rcu_head rcu;
+		} s;
+
+		void *ptr[0];
+	};
 };
 
 static inline void *net_generic(const struct net *net, unsigned int id)
@@ -40,7 +42,7 @@ static inline void *net_generic(const struct net *net, unsigned int id)
 
 	rcu_read_lock();
 	ng = rcu_dereference(net->gen);
-	ptr = ng->ptr[id - 1];
+	ptr = ng->ptr[id];
 	rcu_read_unlock();
 
 	return ptr;
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -39,6 +39,9 @@ EXPORT_SYMBOL(init_net);
 
 static bool init_net_initialized;
 
+#define MIN_PERNET_OPS_ID	\
+	((sizeof(struct net_generic) + sizeof(void *) - 1) / sizeof(void *))
+
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
 static unsigned int max_gen_ptrs = INITIAL_NET_GEN_PTRS;
@@ -46,7 +49,7 @@ static unsigned int max_gen_ptrs = INITIAL_NET_GEN_PTRS;
 static struct net_generic *net_alloc_generic(void)
 {
 	struct net_generic *ng;
-	size_t generic_size = offsetof(struct net_generic, ptr[max_gen_ptrs]);
+	unsigned int generic_size = offsetof(struct net_generic, ptr[max_gen_ptrs]);
 
 	ng = kzalloc(generic_size, GFP_KERNEL);
 	if (ng)
@@ -60,12 +63,12 @@ static int net_assign_generic(struct net *net, unsigned int id, void *data)
 	struct net_generic *ng, *old_ng;
 
 	BUG_ON(!mutex_is_locked(&net_mutex));
-	BUG_ON(id == 0);
+	BUG_ON(id < MIN_PERNET_OPS_ID);
 
 	old_ng = rcu_dereference_protected(net->gen,
 					   lockdep_is_held(&net_mutex));
-	if (old_ng->s.len >= id) {
-		old_ng->ptr[id - 1] = data;
+	if (old_ng->s.len > id) {
+		old_ng->ptr[id] = data;
 		return 0;
 	}
 
@@ -84,8 +87,9 @@ static int net_assign_generic(struct net *net, unsigned int id, void *data)
 	 * the old copy for kfree after a grace period.
 	 */
 
-	memcpy(&ng->ptr, &old_ng->ptr, old_ng->s.len * sizeof(void*));
-	ng->ptr[id - 1] = data;
+	memcpy(&ng->ptr[MIN_PERNET_OPS_ID], &old_ng->ptr[MIN_PERNET_OPS_ID],
+	       (old_ng->s.len - MIN_PERNET_OPS_ID) * sizeof(void *));
+	ng->ptr[id] = data;
 
 	rcu_assign_pointer(net->gen, ng);
 	kfree_rcu(old_ng, s.rcu);
@@ -874,7 +878,7 @@ static int register_pernet_operations(struct list_head *list,
 
 	if (ops->id) {
 again:
-		error = ida_get_new_above(&net_generic_ids, 1, ops->id);
+		error = ida_get_new_above(&net_generic_ids, MIN_PERNET_OPS_ID, ops->id);
 		if (error < 0) {
 			if (error == -EAGAIN) {
 				ida_pre_get(&net_generic_ids, GFP_KERNEL);
@@ -882,7 +886,7 @@ static int register_pernet_operations(struct list_head *list,
 			}
 			return error;
 		}
-		max_gen_ptrs = max(max_gen_ptrs, *ops->id);
+		max_gen_ptrs = max(max_gen_ptrs, *ops->id + 1);
 	}
 	error = __register_pernet_operations(list, ops);
 	if (error) {
