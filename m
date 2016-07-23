From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/25] netfilter: conntrack: fix race between nf_conntrack proc read and hash resize
Date: Sat, 23 Jul 2016 13:08:16 +0200
Message-ID: <1469272119-29942-3-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35879 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbcGWLJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 0D693E7DA7
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:12 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id EF6A1FF12B
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4CFD3FAB59
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:09 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Liping Zhang <liping.zhang@spreadtrum.com>

When we do "cat /proc/net/nf_conntrack", and meanwhile resize the connt=
rack
hash table via /sys/module/nf_conntrack/parameters/hashsize, race will
happen, because reader can observe a newly allocated hash but the old s=
ize
(or vice versa). So oops will happen like follows=EF=BC=9A

  BUG: unable to handle kernel NULL pointer dereference at 000000000000=
0017
  IP: [<ffffffffa0418e21>] seq_print_acct+0x11/0x50 [nf_conntrack]
  Call Trace:
  [<ffffffffa0412f4e>] ? ct_seq_show+0x14e/0x340 [nf_conntrack]
  [<ffffffff81261a1c>] seq_read+0x2cc/0x390
  [<ffffffff812a8d62>] proc_reg_read+0x42/0x70
  [<ffffffff8123bee7>] __vfs_read+0x37/0x130
  [<ffffffff81347980>] ? security_file_permission+0xa0/0xc0
  [<ffffffff8123cf75>] vfs_read+0x95/0x140
  [<ffffffff8123e475>] SyS_read+0x55/0xc0
  [<ffffffff817c2572>] entry_SYSCALL_64_fastpath+0x1a/0xa4

It is very easy to reproduce this kernel crash.
1. open one shell and input the following cmds:
  while : ; do
    echo $RANDOM > /sys/module/nf_conntrack/parameters/hashsize
  done
2. open more shells and input the following cmds:
  while : ; do
    cat /proc/net/nf_conntrack
  done
3. just wait a monent, oops will happen soon.

The solution in this patch is based on Florian's Commit 5e3c61f98175
("netfilter: conntrack: fix lookup race during hash resize"). And
add a wrapper function nf_conntrack_get_ht to get hash and hsize
suggested by Florian Westphal.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_core.h             |  2 ++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c | 14 ++++++++++-=
---
 net/netfilter/nf_conntrack_core.c                     | 17 +++++++++++=
++++++
 net/netfilter/nf_conntrack_standalone.c               | 14 +++++++++--=
---
 4 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/ne=
tfilter/nf_conntrack_core.h
index 3e2f332..79d7ac5 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -51,6 +51,8 @@ bool nf_ct_invert_tuple(struct nf_conntrack_tuple *in=
verse,
 			const struct nf_conntrack_l3proto *l3proto,
 			const struct nf_conntrack_l4proto *l4proto);
=20
+void nf_conntrack_get_ht(struct hlist_nulls_head **hash, unsigned int =
*hsize);
+
 /* Find a connection corresponding to a tuple. */
 struct nf_conntrack_tuple_hash *
 nf_conntrack_find_get(struct net *net,
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/ne=
t/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index c6f3c40..6392371 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -26,6 +26,8 @@
=20
 struct ct_iter_state {
 	struct seq_net_private p;
+	struct hlist_nulls_head *hash;
+	unsigned int htable_size;
 	unsigned int bucket;
 };
=20
@@ -35,10 +37,10 @@ static struct hlist_nulls_node *ct_get_first(struct=
 seq_file *seq)
 	struct hlist_nulls_node *n;
=20
 	for (st->bucket =3D 0;
-	     st->bucket < nf_conntrack_htable_size;
+	     st->bucket < st->htable_size;
 	     st->bucket++) {
 		n =3D rcu_dereference(
-			hlist_nulls_first_rcu(&nf_conntrack_hash[st->bucket]));
+			hlist_nulls_first_rcu(&st->hash[st->bucket]));
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -53,11 +55,11 @@ static struct hlist_nulls_node *ct_get_next(struct =
seq_file *seq,
 	head =3D rcu_dereference(hlist_nulls_next_rcu(head));
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
-			if (++st->bucket >=3D nf_conntrack_htable_size)
+			if (++st->bucket >=3D st->htable_size)
 				return NULL;
 		}
 		head =3D rcu_dereference(
-			hlist_nulls_first_rcu(&nf_conntrack_hash[st->bucket]));
+			hlist_nulls_first_rcu(&st->hash[st->bucket]));
 	}
 	return head;
 }
@@ -75,7 +77,11 @@ static struct hlist_nulls_node *ct_get_idx(struct se=
q_file *seq, loff_t pos)
 static void *ct_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
+	struct ct_iter_state *st =3D seq->private;
+
 	rcu_read_lock();
+
+	nf_conntrack_get_ht(&st->hash, &st->htable_size);
 	return ct_get_idx(seq, *pos);
 }
=20
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 153e33f..1289e7e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -460,6 +460,23 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 	       net_eq(net, nf_ct_net(ct));
 }
=20
+/* must be called with rcu read lock held */
+void nf_conntrack_get_ht(struct hlist_nulls_head **hash, unsigned int =
*hsize)
+{
+	struct hlist_nulls_head *hptr;
+	unsigned int sequence, hsz;
+
+	do {
+		sequence =3D read_seqcount_begin(&nf_conntrack_generation);
+		hsz =3D nf_conntrack_htable_size;
+		hptr =3D nf_conntrack_hash;
+	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+
+	*hash =3D hptr;
+	*hsize =3D hsz;
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_get_ht);
+
 /*
  * Warning :
  * - Caller must take a reference on returned object
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf=
_conntrack_standalone.c
index 2aaa188..958a145 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -48,6 +48,8 @@ EXPORT_SYMBOL_GPL(print_tuple);
=20
 struct ct_iter_state {
 	struct seq_net_private p;
+	struct hlist_nulls_head *hash;
+	unsigned int htable_size;
 	unsigned int bucket;
 	u_int64_t time_now;
 };
@@ -58,9 +60,10 @@ static struct hlist_nulls_node *ct_get_first(struct =
seq_file *seq)
 	struct hlist_nulls_node *n;
=20
 	for (st->bucket =3D 0;
-	     st->bucket < nf_conntrack_htable_size;
+	     st->bucket < st->htable_size;
 	     st->bucket++) {
-		n =3D rcu_dereference(hlist_nulls_first_rcu(&nf_conntrack_hash[st->b=
ucket]));
+		n =3D rcu_dereference(
+			hlist_nulls_first_rcu(&st->hash[st->bucket]));
 		if (!is_a_nulls(n))
 			return n;
 	}
@@ -75,12 +78,11 @@ static struct hlist_nulls_node *ct_get_next(struct =
seq_file *seq,
 	head =3D rcu_dereference(hlist_nulls_next_rcu(head));
 	while (is_a_nulls(head)) {
 		if (likely(get_nulls_value(head) =3D=3D st->bucket)) {
-			if (++st->bucket >=3D nf_conntrack_htable_size)
+			if (++st->bucket >=3D st->htable_size)
 				return NULL;
 		}
 		head =3D rcu_dereference(
-				hlist_nulls_first_rcu(
-					&nf_conntrack_hash[st->bucket]));
+			hlist_nulls_first_rcu(&st->hash[st->bucket]));
 	}
 	return head;
 }
@@ -102,6 +104,8 @@ static void *ct_seq_start(struct seq_file *seq, lof=
f_t *pos)
=20
 	st->time_now =3D ktime_get_real_ns();
 	rcu_read_lock();
+
+	nf_conntrack_get_ht(&st->hash, &st->htable_size);
 	return ct_get_idx(seq, *pos);
 }
=20
--=20
2.1.4
