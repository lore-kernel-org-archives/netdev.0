From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] netfilter: nf_conntrack: Batch cleanup
Date: Thu, 14 Mar 2013 13:40:14 +0400
Message-ID: <1363254014-10725-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devel@openvz.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:46692 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab3CNJkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 05:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch introduces nf_conntrack_cleanup_net_list(), which cleanups
nf_conntrack for a list of netns and calls synchronize_net() only once
for them all. This should reduce netns destruction time.
--
I've measured cleanup time for 1k dummy net ns. Here are the results:

 <without the patch>
 # modprobe nf_conntrack
 # time modprobe -r nf_conntrack

 real	0m10.337s
 user	0m0.000s
 sys	0m0.376s

 <with the patch>
 # modprobe nf_conntrack
 # time modprobe -r nf_conntrack

 real    0m5.661s
 user    0m0.000s
 sys     0m0.216s

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/nf_conntrack_core.h |    1 +
 net/netfilter/nf_conntrack_core.c         |   46 ++++++++++++++++++++---------
 net/netfilter/nf_conntrack_standalone.c   |   16 ++++++----
 3 files changed, 43 insertions(+), 20 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 930275f..fb2b623 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -27,6 +27,7 @@ extern unsigned int nf_conntrack_in(struct net *net,
 
 extern int nf_conntrack_init_net(struct net *net);
 extern void nf_conntrack_cleanup_net(struct net *net);
+extern void nf_conntrack_cleanup_net_list(struct list_head *net_exit_list);
 
 extern int nf_conntrack_proto_pernet_init(struct net *net);
 extern void nf_conntrack_proto_pernet_fini(struct net *net);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c8e001a..09c02ef 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1364,30 +1364,48 @@ void nf_conntrack_cleanup_end(void)
  */
 void nf_conntrack_cleanup_net(struct net *net)
 {
+	LIST_HEAD(single);
+
+	list_add(&net->exit_list, &single);
+	nf_conntrack_cleanup_net_list(&single);
+}
+
+void nf_conntrack_cleanup_net_list(struct list_head *net_exit_list)
+{
+	int busy;
+	struct net *net;
+
 	/*
 	 * This makes sure all current packets have passed through
 	 *  netfilter framework.  Roll on, two-stage module
 	 *  delete...
 	 */
 	synchronize_net();
- i_see_dead_people:
-	nf_ct_iterate_cleanup(net, kill_all, NULL);
-	nf_ct_release_dying_list(net);
-	if (atomic_read(&net->ct.count) != 0) {
+i_see_dead_people:
+	busy = 0;
+	list_for_each_entry(net, net_exit_list, exit_list) {
+		nf_ct_iterate_cleanup(net, kill_all, NULL);
+		nf_ct_release_dying_list(net);
+		if (atomic_read(&net->ct.count) != 0)
+			busy = 1;
+	}
+	if (busy) {
 		schedule();
 		goto i_see_dead_people;
 	}
 
-	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
-	nf_conntrack_proto_pernet_fini(net);
-	nf_conntrack_helper_pernet_fini(net);
-	nf_conntrack_ecache_pernet_fini(net);
-	nf_conntrack_tstamp_pernet_fini(net);
-	nf_conntrack_acct_pernet_fini(net);
-	nf_conntrack_expect_pernet_fini(net);
-	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
-	kfree(net->ct.slabname);
-	free_percpu(net->ct.stat);
+	list_for_each_entry(net, net_exit_list, exit_list) {
+		nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+		nf_conntrack_proto_pernet_fini(net);
+		nf_conntrack_helper_pernet_fini(net);
+		nf_conntrack_ecache_pernet_fini(net);
+		nf_conntrack_tstamp_pernet_fini(net);
+		nf_conntrack_acct_pernet_fini(net);
+		nf_conntrack_expect_pernet_fini(net);
+		kmem_cache_destroy(net->ct.nf_conntrack_cachep);
+		kfree(net->ct.slabname);
+		free_percpu(net->ct.stat);
+	}
 }
 
 void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 6bcce40..6c69fbd 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -545,16 +545,20 @@ out_init:
 	return ret;
 }
 
-static void nf_conntrack_pernet_exit(struct net *net)
+static void nf_conntrack_pernet_exit(struct list_head *net_exit_list)
 {
-	nf_conntrack_standalone_fini_sysctl(net);
-	nf_conntrack_standalone_fini_proc(net);
-	nf_conntrack_cleanup_net(net);
+	struct net *net;
+
+	list_for_each_entry(net, net_exit_list, exit_list) {
+		nf_conntrack_standalone_fini_sysctl(net);
+		nf_conntrack_standalone_fini_proc(net);
+	}
+	nf_conntrack_cleanup_net_list(net_exit_list);
 }
 
 static struct pernet_operations nf_conntrack_net_ops = {
-	.init = nf_conntrack_pernet_init,
-	.exit = nf_conntrack_pernet_exit,
+	.init		= nf_conntrack_pernet_init,
+	.exit_batch	= nf_conntrack_pernet_exit,
 };
 
 static int __init nf_conntrack_standalone_init(void)
-- 
1.7.1
