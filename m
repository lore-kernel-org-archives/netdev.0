From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 4/4] inet: frags: use kmem_cache for inet_frag_queue
Date: Thu, 31 Jul 2014 17:11:39 +0200
Message-ID: <1406819499-11198-5-git-send-email-nikolay@redhat.com>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbaGaPOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 11:14:49 -0400
In-Reply-To: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kmem_cache to allocate/free inet_frag_queue objects since they're
all the same size per inet_frags user and are alloced/freed in high volumes
thus making it a perfect case for kmem_cache.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Note: I didn't use SLAB_HWCACHE_ALIGN to save some bytes in the allocation
      although they can easily be accounted for, in my tests I didn't find
      noticeable difference so I decided against it.

 include/net/inet_frag.h                 |  4 +++-
 net/ieee802154/reassembly.c             |  7 ++++++-
 net/ipv4/inet_fragment.c                | 13 ++++++++++---
 net/ipv4/ip_fragment.c                  |  5 ++++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |  8 ++++++--
 net/ipv6/reassembly.c                   |  7 ++++++-
 6 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 90015c47b447..65a8855e99fe 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -101,9 +101,11 @@ struct inet_frags {
 	void			(*destructor)(struct inet_frag_queue *);
 	void			(*skb_free)(struct sk_buff *);
 	void			(*frag_expire)(unsigned long data);
+	struct kmem_cache	*frags_cachep;
+	const char		*frags_cache_name;
 };
 
-void inet_frags_init(struct inet_frags *);
+int inet_frags_init(struct inet_frags *);
 void inet_frags_fini(struct inet_frags *);
 
 void inet_frags_init_net(struct netns_frags *nf);
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 5607accd2fee..ffec6ce51005 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -30,6 +30,8 @@
 
 #include "reassembly.h"
 
+static const char lowpan_frags_cache_name[] = "lowpan-frags";
+
 struct lowpan_frag_info {
 	__be16 d_tag;
 	u16 d_size;
@@ -571,7 +573,10 @@ int __init lowpan_net_frag_init(void)
 	lowpan_frags.qsize = sizeof(struct frag_queue);
 	lowpan_frags.match = lowpan_frag_match;
 	lowpan_frags.frag_expire = lowpan_frag_expire;
-	inet_frags_init(&lowpan_frags);
+	lowpan_frags.frags_cache_name = lowpan_frags_cache_name;
+	ret = inet_frags_init(&lowpan_frags);
+	if (ret)
+		goto err_pernet;
 
 	return ret;
 err_pernet:
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 1e9a9592a8ac..9d331d7ce646 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -198,7 +198,7 @@ static void inet_frag_schedule_worker(struct inet_frags *f)
 		schedule_work(&f->frags_work);
 }
 
-void inet_frags_init(struct inet_frags *f)
+int inet_frags_init(struct inet_frags *f)
 {
 	int i;
 
@@ -213,6 +213,12 @@ void inet_frags_init(struct inet_frags *f)
 
 	seqlock_init(&f->rnd_seqlock);
 	f->last_rebuild_jiffies = 0;
+	f->frags_cachep = kmem_cache_create(f->frags_cache_name, f->qsize, 0, 0,
+					    NULL);
+	if (!f->frags_cachep)
+		return -ENOMEM;
+
+	return 0;
 }
 EXPORT_SYMBOL(inet_frags_init);
 
@@ -225,6 +231,7 @@ EXPORT_SYMBOL(inet_frags_init_net);
 void inet_frags_fini(struct inet_frags *f)
 {
 	cancel_work_sync(&f->frags_work);
+	kmem_cache_destroy(f->frags_cachep);
 }
 EXPORT_SYMBOL(inet_frags_fini);
 
@@ -327,7 +334,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 
 	if (f->destructor)
 		f->destructor(q);
-	kfree(q);
+	kmem_cache_free(f->frags_cachep, q);
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
@@ -375,7 +382,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 		return NULL;
 	}
 
-	q = kzalloc(f->qsize, GFP_ATOMIC);
+	q = kmem_cache_zalloc(f->frags_cachep, GFP_ATOMIC);
 	if (q == NULL)
 		return NULL;
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cb56bcc1eee2..15f0e2bad7ad 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -55,6 +55,7 @@
  */
 
 static int sysctl_ipfrag_max_dist __read_mostly = 64;
+static const char ip_frag_cache_name[] = "ip4-frags";
 
 struct ipfrag_skb_cb
 {
@@ -860,5 +861,7 @@ void __init ipfrag_init(void)
 	ip4_frags.qsize = sizeof(struct ipq);
 	ip4_frags.match = ip4_frag_match;
 	ip4_frags.frag_expire = ip_expire;
-	inet_frags_init(&ip4_frags);
+	ip4_frags.frags_cache_name = ip_frag_cache_name;
+	if (inet_frags_init(&ip4_frags))
+		panic("IP: failed to allocate ip4_frags cache\n");
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index cca686e42b97..6f187c8d8a1b 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -50,6 +50,7 @@
 #include <linux/module.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
+static const char nf_frags_cache_name[] = "nf-frags";
 
 struct nf_ct_frag6_skb_cb
 {
@@ -677,12 +678,15 @@ int nf_ct_frag6_init(void)
 	nf_frags.qsize = sizeof(struct frag_queue);
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
-	inet_frags_init(&nf_frags);
-
+	nf_frags.frags_cache_name = nf_frags_cache_name;
+	ret = inet_frags_init(&nf_frags);
+	if (ret)
+		goto out;
 	ret = register_pernet_subsys(&nf_ct_net_ops);
 	if (ret)
 		inet_frags_fini(&nf_frags);
 
+out:
 	return ret;
 }
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index beb6872a8fa5..c6557d9f7808 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -60,6 +60,8 @@
 #include <net/inet_frag.h>
 #include <net/inet_ecn.h>
 
+static const char ip6_frag_cache_name[] = "ip6-frags";
+
 struct ip6frag_skb_cb
 {
 	struct inet6_skb_parm	h;
@@ -748,7 +750,10 @@ int __init ipv6_frag_init(void)
 	ip6_frags.qsize = sizeof(struct frag_queue);
 	ip6_frags.match = ip6_frag_match;
 	ip6_frags.frag_expire = ip6_frag_expire;
-	inet_frags_init(&ip6_frags);
+	ip6_frags.frags_cache_name = ip6_frag_cache_name;
+	ret = inet_frags_init(&ip6_frags);
+	if (ret)
+		goto err_pernet;
 out:
 	return ret;
 
-- 
1.9.3
