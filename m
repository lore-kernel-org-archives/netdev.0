From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: netns ct: per-netns nf_expect_max
Date: Sun, 22 Jun 2008 05:19:53 +0400
Message-ID: <20080622011953.GY5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_expect.h |    1 -
 include/net/netns/conntrack.h               |    1 +
 net/netfilter/nf_conntrack_expect.c         |    6 ++----
 net/netfilter/nf_conntrack_standalone.c     |    2 +-
 4 files changed, 4 insertions(+), 6 deletions(-)

--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -7,7 +7,6 @@
 #include <net/netfilter/nf_conntrack.h>
 
 extern unsigned int nf_ct_expect_hsize;
-extern unsigned int nf_ct_expect_max;
 
 struct nf_conntrack_expect
 {
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -10,6 +10,7 @@ struct netns_ct {
 	struct hlist_head	*hash;
 	int			hash_vmalloc;
 	unsigned int		expect_count;
+	unsigned int		expect_max;
 	struct hlist_head	*expect_hash;
 	int			expect_vmalloc;
 	struct hlist_head	unconfirmed;
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -32,7 +32,6 @@ unsigned int nf_ct_expect_hsize __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
 
 static unsigned int nf_ct_expect_hash_rnd __read_mostly;
-unsigned int nf_ct_expect_max __read_mostly;
 static int nf_ct_expect_hash_rnd_initted __read_mostly;
 
 static struct kmem_cache *nf_ct_expect_cachep __read_mostly;
@@ -404,7 +403,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
 		}
 	}
 
-	if (net->ct.expect_count >= nf_ct_expect_max) {
+	if (net->ct.expect_count >= net->ct.expect_max) {
 		if (net_ratelimit())
 			printk(KERN_WARNING
 			       "nf_conntrack: expectation table full\n");
@@ -569,9 +568,8 @@ int nf_conntrack_expect_init(struct net *net)
 			if (!nf_ct_expect_hsize)
 				nf_ct_expect_hsize = 1;
 		}
-		nf_ct_expect_max = nf_ct_expect_hsize * 4;
 	}
-
+	net->ct.expect_max = nf_ct_expect_hsize * 4;
 	net->ct.expect_count = 0;
 	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
 						  &net->ct.expect_vmalloc);
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -387,7 +387,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_expect_max",
-		.data		= &nf_ct_expect_max,
+		.data		= &init_net.ct.expect_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
-- 
1.5.4.5


