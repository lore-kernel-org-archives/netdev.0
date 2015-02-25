From: Chris Rorvick <chris@rorvick.com>
Subject: [PATCH] fib_trie: Add proc entry for next-hop exceptions
Date: Tue, 24 Feb 2015 23:27:12 -0600
Message-ID: <1424842032-3151-1-git-send-email-chris@rorvick.com>
Cc: Chris Rorvick <chris@rorvick.com>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Exceptions are added to the FIB in response to ICMP redirects and to
account for PMTU, but there is little visibility into what the current
exceptions are.  Add a proc entry for listing the current next-hop
exceptions

Signed-off-by: Chris Rorvick <chris@rorvick.com>
---
I wrote this patch while looking into some issues on a network and found
it useful.  It caused me to realize that I needed to fix the routing on
my home network as the MTU over my PPPoE DSL service was causing the
exception list to grow very large.

Is there another way of getting the list of next-hop exceptions?  Or
even the current count?  Or is something similar to this patch a useful
addition?

Regards,

Chris

 net/ipv4/fib_trie.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3daf022..591d854 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2487,6 +2487,93 @@ static const struct file_operations fib_route_fops = {
 	.release = seq_release_net,
 };
 
+static void fib_nhe_seq_show_fib_info(struct seq_file *seq,
+				      const struct fib_info *fi)
+{
+	const struct fnhe_hash_bucket *bucket;
+	const struct fib_nh_exception *fnhe;
+	int i, j;
+
+	for (i = 0; i < fi->fib_nhs; i++) {
+		bucket = fi->fib_nh[i].nh_exceptions;
+		if (!bucket)
+			continue;
+
+		for (j = 0; j < FNHE_HASH_SIZE; j++, bucket++) {
+			if (!bucket->chain)
+				continue;
+
+			for (fnhe = rcu_dereference(bucket->chain); fnhe;
+			     fnhe = rcu_dereference(fnhe->fnhe_next)) {
+				seq_printf(seq, "%-8s %-16pI4 %-16pI4 %-6d %-6d %-11ld %ld\n",
+					   fi->fib_dev ? fi->fib_dev->name
+						       : "*",
+					   &fnhe->fnhe_daddr,
+					   fnhe->fnhe_gw ? &fnhe->fnhe_gw
+							 : &fi->fib_nh[i].nh_gw,
+					   fnhe->fnhe_pmtu,
+					   fnhe->fnhe_genid,
+					   fnhe->fnhe_stamp,
+					   fnhe->fnhe_expires);
+			}
+		}
+	}
+}
+
+static int fib_nhe_seq_show(struct seq_file *seq, void *v)
+{
+	struct tnode *l = v;
+	struct leaf_info *li;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq, "%-8s %-16s %-16s %-6s %-6s %-11s %s\n",
+			   "Iface",
+			   "Destination",
+			   "Next Hop",
+			   "PMTU",
+			   "GenID",
+			   "Time",
+			   "Expires");
+		return 0;
+	}
+
+	hlist_for_each_entry_rcu(li, &l->list, hlist) {
+		struct fib_alias *fa;
+
+		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+			const struct fib_info *fi = fa->fa_info;
+
+			if (!fi)
+				continue;
+
+			fib_nhe_seq_show_fib_info(seq, fi);
+		}
+	}
+
+	return 0;
+}
+
+static const struct seq_operations fib_nhe_seq_ops = {
+	.start  = fib_route_seq_start,
+	.next   = fib_route_seq_next,
+	.stop   = fib_route_seq_stop,
+	.show   = fib_nhe_seq_show,
+};
+
+static int fib_nhe_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &fib_nhe_seq_ops,
+			    sizeof(struct fib_route_iter));
+}
+
+static const struct file_operations fib_nhe_fops = {
+	.owner  = THIS_MODULE,
+	.open   = fib_nhe_seq_open,
+	.read   = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release_net,
+};
+
 int __net_init fib_proc_init(struct net *net)
 {
 	if (!proc_create("fib_trie", S_IRUGO, net->proc_net, &fib_trie_fops))
@@ -2499,8 +2586,13 @@ int __net_init fib_proc_init(struct net *net)
 	if (!proc_create("route", S_IRUGO, net->proc_net, &fib_route_fops))
 		goto out3;
 
+	if (!proc_create("fib_nh_exceptions", S_IRUGO, net->proc_net, &fib_nhe_fops))
+		goto out4;
+
 	return 0;
 
+out4:
+	remove_proc_entry("route", net->proc_net);
 out3:
 	remove_proc_entry("fib_triestat", net->proc_net);
 out2:
-- 
2.1.0
