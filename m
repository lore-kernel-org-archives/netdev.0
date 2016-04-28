From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 2/9] netfilter: conntrack: fix lookup race during hash resize
Date: Thu, 28 Apr 2016 19:13:41 +0200
Message-ID: <1461863628-23350-3-git-send-email-fw@strlen.de>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When resizing the conntrack hash table at runtime via
echo 42 > /sys/module/nf_conntrack/parameters/hashsize, we are racing with
the conntrack lookup path -- reads can happen in parallel and nothing
prevents readers from observing a the newly allocated hash but the old
size (or vice versa).

So access to hash[bucket] can trigger OOB read access in case the table got
expanded and we saw the new size but the old hash pointer (or it got shrunk
and we got new hash ptr but the size of the old and larger table):

kasan: GPF could be caused by NULL-ptr deref or user memory access general protection fault: 0000 [#1] SMP KASAN
CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 4.6.0-rc2+ #107
[..]
Call Trace:
[<ffffffff822c3d6a>] ? nf_conntrack_tuple_taken+0x12a/0xe90
[<ffffffff822c3ac1>] ? nf_ct_invert_tuplepr+0x221/0x3a0
[<ffffffff8230e703>] get_unique_tuple+0xfb3/0x2760

Use generation counter to obtain the address/length of the same table.

Also add a synchronize_net before freeing the old hash.
AFAICS, without it we might access ct_hash[bucket] after ct_hash has been
freed, provided that lockless reader got delayed by another event:

CPU1			CPU2
seq_begin
seq_retry
<delay>			resize occurs
			free oldhash
for_each(oldhash[size])

Note that resize is only supported in init_netns, it took over 2 minutes
of constant resizing+flooding to produce the warning, so this isn't a
big problem in practice.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/nf_conntrack_core.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1b63359..29fa08b 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -469,11 +469,18 @@ ____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple, u32 hash)
 {
 	struct nf_conntrack_tuple_hash *h;
+	struct hlist_nulls_head *ct_hash;
 	struct hlist_nulls_node *n;
-	unsigned int bucket = hash_bucket(hash, net);
+	unsigned int bucket, sequence;
 
 begin:
-	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[bucket], hnnode) {
+	do {
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
+		bucket = hash_bucket(hash, net);
+		ct_hash = net->ct.hash;
+	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+
+	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[bucket], hnnode) {
 		if (nf_ct_key_equal(h, tuple, zone)) {
 			NF_CT_STAT_INC_ATOMIC(net, found);
 			return h;
@@ -722,15 +729,21 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	struct net *net = nf_ct_net(ignored_conntrack);
 	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple_hash *h;
+	struct hlist_nulls_head *ct_hash;
+	unsigned int hash, sequence;
 	struct hlist_nulls_node *n;
 	struct nf_conn *ct;
-	unsigned int hash;
 
 	zone = nf_ct_zone(ignored_conntrack);
-	hash = hash_conntrack(net, tuple);
 
 	rcu_read_lock();
-	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
+	do {
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
+		hash = hash_conntrack(net, tuple);
+		ct_hash = net->ct.hash;
+	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+
+	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (ct != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple) &&
@@ -1607,6 +1620,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	nf_conntrack_all_unlock();
 	local_bh_enable();
 
+	synchronize_net();
 	nf_ct_free_hashtable(old_hash, old_size);
 	return 0;
 }
-- 
2.7.3

