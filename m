From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/26] netfilter: conntrack: allow increasing bucket size via sysctl too
Date: Wed,  6 Jul 2016 16:24:01 +0200
Message-ID: <1467815048-2240-20-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

No need to restrict this to module parameter.

We export a copy of the real hash size -- when user alters the value we
allocate the new table, copy entries etc before we update the real size
to the requested one.

This is also needed because the real size is used by concurrent readers
and cannot be changed without synchronizing the conntrack generation
seqcnt.

We only allow changing this value from the initial net namespace.

Tested using http-client-benchmark vs. httpterm with concurrent

while true;do
 echo $RANDOM > /proc/sys/net/netfilter/nf_conntrack_buckets
done

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/nf_conntrack-sysctl.txt |  3 +-
 include/net/netfilter/nf_conntrack.h             |  1 +
 net/netfilter/nf_conntrack_core.c                | 41 ++++++++++++++++--------
 net/netfilter/nf_conntrack_standalone.c          | 36 ++++++++++++++++++---
 4 files changed, 62 insertions(+), 19 deletions(-)

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
index f55599c..4fb51d3 100644
--- a/Documentation/networking/nf_conntrack-sysctl.txt
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -7,12 +7,13 @@ nf_conntrack_acct - BOOLEAN
 	Enable connection tracking flow accounting. 64-bit byte and packet
 	counters per flow are added.
 
-nf_conntrack_buckets - INTEGER (read-only)
+nf_conntrack_buckets - INTEGER
 	Size of hash table. If not specified as parameter during module
 	loading, the default size is calculated by dividing total memory
 	by 16384 to determine the number of buckets but the hash table will
 	never have fewer than 32 and limited to 16384 buckets. For systems
 	with more than 4GB of memory it will be 65536 buckets.
+	This sysctl is only writeable in the initial net namespace.
 
 nf_conntrack_checksum - BOOLEAN
 	0 - disabled
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 9c0ed3d..5d3397f 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -290,6 +290,7 @@ static inline bool nf_is_loopback_packet(const struct sk_buff *skb)
 struct kernel_param;
 
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
+int nf_conntrack_hash_resize(unsigned int hashsize);
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index a459176..e17d5c7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1595,24 +1595,14 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
 }
 EXPORT_SYMBOL_GPL(nf_ct_alloc_hashtable);
 
-int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
+int nf_conntrack_hash_resize(unsigned int hashsize)
 {
-	int i, bucket, rc;
-	unsigned int hashsize, old_size;
+	int i, bucket;
+	unsigned int old_size;
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 
-	if (current->nsproxy->net_ns != &init_net)
-		return -EOPNOTSUPP;
-
-	/* On boot, we can set this without any fancy locking. */
-	if (!nf_conntrack_htable_size)
-		return param_set_uint(val, kp);
-
-	rc = kstrtouint(val, 0, &hashsize);
-	if (rc)
-		return rc;
 	if (!hashsize)
 		return -EINVAL;
 
@@ -1620,6 +1610,12 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!hash)
 		return -ENOMEM;
 
+	old_size = nf_conntrack_htable_size;
+	if (old_size == hashsize) {
+		nf_ct_free_hashtable(hash, hashsize);
+		return 0;
+	}
+
 	local_bh_disable();
 	nf_conntrack_all_lock();
 	write_seqcount_begin(&nf_conntrack_generation);
@@ -1655,6 +1651,25 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	nf_ct_free_hashtable(old_hash, old_size);
 	return 0;
 }
+
+int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
+{
+	unsigned int hashsize;
+	int rc;
+
+	if (current->nsproxy->net_ns != &init_net)
+		return -EOPNOTSUPP;
+
+	/* On boot, we can set this without any fancy locking. */
+	if (!nf_conntrack_htable_size)
+		return param_set_uint(val, kp);
+
+	rc = kstrtouint(val, 0, &hashsize);
+	if (rc)
+		return rc;
+
+	return nf_conntrack_hash_resize(hashsize);
+}
 EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index f87e84e..a0cc191 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -434,8 +434,29 @@ static void nf_conntrack_standalone_fini_proc(struct net *net)
 
 #ifdef CONFIG_SYSCTL
 /* Log invalid packets of a given protocol */
-static int log_invalid_proto_min = 0;
-static int log_invalid_proto_max = 255;
+static int log_invalid_proto_min __read_mostly;
+static int log_invalid_proto_max __read_mostly = 255;
+
+/* size the user *wants to set */
+static unsigned int nf_conntrack_htable_size_user __read_mostly;
+
+static int
+nf_conntrack_hash_sysctl(struct ctl_table *table, int write,
+			 void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (ret < 0 || !write)
+		return ret;
+
+	/* update ret, we might not be able to satisfy request */
+	ret = nf_conntrack_hash_resize(nf_conntrack_htable_size_user);
+
+	/* update it to the actual value used by conntrack */
+	nf_conntrack_htable_size_user = nf_conntrack_htable_size;
+	return ret;
+}
 
 static struct ctl_table_header *nf_ct_netfilter_header;
 
@@ -456,10 +477,10 @@ static struct ctl_table nf_ct_sysctl_table[] = {
 	},
 	{
 		.procname       = "nf_conntrack_buckets",
-		.data           = &nf_conntrack_htable_size,
+		.data           = &nf_conntrack_htable_size_user,
 		.maxlen         = sizeof(unsigned int),
-		.mode           = 0444,
-		.proc_handler   = proc_dointvec,
+		.mode           = 0644,
+		.proc_handler   = nf_conntrack_hash_sysctl,
 	},
 	{
 		.procname	= "nf_conntrack_checksum",
@@ -517,6 +538,9 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 	if (net->user_ns != &init_user_ns)
 		table[0].procname = NULL;
 
+	if (!net_eq(&init_net, net))
+		table[2].mode = 0444;
+
 	net->ct.sysctl_header = register_net_sysctl(net, "net/netfilter", table);
 	if (!net->ct.sysctl_header)
 		goto out_unregister_netfilter;
@@ -606,6 +630,8 @@ static int __init nf_conntrack_standalone_init(void)
 		ret = -ENOMEM;
 		goto out_sysctl;
 	}
+
+	nf_conntrack_htable_size_user = nf_conntrack_htable_size;
 #endif
 
 	ret = register_pernet_subsys(&nf_conntrack_net_ops);
-- 
2.1.4

