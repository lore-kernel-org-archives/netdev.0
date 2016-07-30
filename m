From: fxp2001640163@gmail.com
Subject: [PATCH 1/3] netfilter: nat: update hash bucket if nat changed after ct confirmed
Date: Sat, 30 Jul 2016 14:53:34 -0700
Message-ID: <1469915614-16800-1-git-send-email-xfan@codeaurora.org>
Cc: Xiaoping Fan <xfan@codeaurora.org>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34059 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbcG3Vxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 17:53:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaoping Fan <xfan@codeaurora.org>

In some situations, NAT information is created after connection is
confirmed. Since 5 tuple for reply direction is changed when creating
NAT information, so we need to update hash bucket of connection.

Signed-off-by: Xiaoping Fan <xfan@codeaurora.org>
---
 include/net/netfilter/nf_conntrack.h |  5 ++++
 net/netfilter/nf_conntrack_core.c    | 51 ++++++++++++++++++++++++++++++++++--
 net/netfilter/nf_nat_core.c          |  9 +++++++
 3 files changed, 63 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 445b019..cc9ba66 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -191,6 +191,9 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls);
 void nf_ct_free_hashtable(void *hash, unsigned int size);
 
 int nf_conntrack_hash_check_insert(struct nf_conn *ct);
+void nf_conntrack_ct_hash_bucket_update(struct nf_conn *ct,
+					unsigned int old_hash,
+					unsigned int old_reply_hash);
 bool nf_ct_delete(struct nf_conn *ct, u32 pid, int report);
 
 bool nf_ct_get_tuplepr(const struct sk_buff *skb, unsigned int nhoff,
@@ -305,6 +308,8 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 int nf_conntrack_hash_resize(unsigned int hashsize);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
+u_int32_t hash_conntrack(const struct net *net,
+			 const struct nf_conntrack_tuple *tuple);
 
 struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
 				 const struct nf_conntrack_zone *zone,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index dd2c43a..d4ee145 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -202,11 +202,12 @@ static u32 __hash_conntrack(const struct net *net,
 	return reciprocal_scale(hash_conntrack_raw(tuple, net), size);
 }
 
-static u32 hash_conntrack(const struct net *net,
-			  const struct nf_conntrack_tuple *tuple)
+u32 hash_conntrack(const struct net *net,
+		   const struct nf_conntrack_tuple *tuple)
 {
 	return scale_hash(hash_conntrack_raw(tuple, net));
 }
+EXPORT_SYMBOL(hash_conntrack);
 
 bool
 nf_ct_get_tuple(const struct sk_buff *skb,
@@ -636,6 +637,52 @@ out:
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
 
+/* Sometimes reply tuple of ct is changed by nat after ct is confirmed,
+ * hash bucket of ct has to be updated in this situation.
+ */
+void nf_conntrack_ct_hash_bucket_update(struct nf_conn *ct,
+					unsigned int old_hash,
+					unsigned int old_reply_hash)
+{
+	struct net *net;
+	unsigned int hash, reply_hash;
+	unsigned int sequence;
+
+	if (!ct || nf_ct_is_untracked(ct) || !nf_ct_is_confirmed(ct))
+		return;
+
+	net = nf_ct_net(ct);
+
+	local_bh_disable();
+	do {
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
+	} while (nf_conntrack_double_lock(net, old_hash, old_reply_hash, sequence));
+
+	/* Remove from confirmed list */
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode);
+
+	nf_conntrack_double_unlock(old_hash, old_reply_hash);
+
+	/* Make changes visible in other cores */
+	smp_wmb();
+
+	do {
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
+		hash = hash_conntrack(net,
+				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		reply_hash = hash_conntrack(net,
+					    &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	} while (nf_conntrack_double_lock(net, hash, reply_hash, sequence));
+
+	/* Insert to confirmed list again */
+	__nf_conntrack_hash_insert(ct, hash, reply_hash);
+
+	nf_conntrack_double_unlock(hash, reply_hash);
+	local_bh_enable();
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_ct_hash_bucket_update);
+
 static inline void nf_ct_acct_update(struct nf_conn *ct,
 				     enum ip_conntrack_info ctinfo,
 				     unsigned int len)
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index de31818..612d8d57 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -405,8 +405,10 @@ nf_nat_setup_info(struct nf_conn *ct,
 		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple curr_tuple, new_tuple;
 	struct nf_conn_nat *nat;
+	unsigned int old_hash, old_reply_hash;
 
 	/* nat helper or nfctnetlink also setup binding */
 	nat = nf_ct_nat_ext_add(ct);
@@ -417,6 +419,11 @@ nf_nat_setup_info(struct nf_conn *ct,
 		     maniptype == NF_NAT_MANIP_DST);
 	BUG_ON(nf_nat_initialized(ct, maniptype));
 
+	old_hash = hash_conntrack(net,
+				  &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+	old_reply_hash = hash_conntrack(net,
+					&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+
 	/* What we've got will look like inverse of reply. Normally
 	 * this is what is in the conntrack, except for prior
 	 * manipulations (future optimization: if num_manips == 0,
@@ -460,6 +467,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 	else
 		ct->status |= IPS_SRC_NAT_DONE;
 
+	nf_conntrack_ct_hash_bucket_update(ct, old_hash, old_reply_hash);
+
 	return NF_ACCEPT;
 }
 EXPORT_SYMBOL(nf_nat_setup_info);
-- 
1.9.1
