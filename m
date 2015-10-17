From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 2/4] inet: kill obsolete skb_free op
Date: Sat, 17 Oct 2015 22:14:23 +0200
Message-ID: <1445112865-31523-3-git-send-email-fw@strlen.de>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, azhou@nicira.com, joestringer@nicira.com,
	Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59655 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751560AbbJQUOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 16:14:43 -0400
In-Reply-To: <1445112865-31523-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only user was removed in preceeding commit.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h             |  1 -
 net/ieee802154/6lowpan/reassembly.c |  1 -
 net/ipv4/inet_fragment.c            | 10 +---------
 net/ipv4/ip_fragment.c              |  1 -
 net/ipv6/reassembly.c               |  1 -
 5 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 53eead2..9f9aa4d 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -99,7 +99,6 @@ struct inet_frags {
 	void			(*constructor)(struct inet_frag_queue *q,
 					       const void *arg);
 	void			(*destructor)(struct inet_frag_queue *);
-	void			(*skb_free)(struct sk_buff *);
 	void			(*frag_expire)(unsigned long data);
 	struct kmem_cache	*frags_cachep;
 	const char		*frags_cache_name;
diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lowpan/reassembly.c
index 12e8cf4..f85b08b 100644
--- a/net/ieee802154/6lowpan/reassembly.c
+++ b/net/ieee802154/6lowpan/reassembly.c
@@ -619,7 +619,6 @@ int __init lowpan_net_frag_init(void)
 	lowpan_frags.hashfn = lowpan_hashfn;
 	lowpan_frags.constructor = lowpan_frag_init;
 	lowpan_frags.destructor = NULL;
-	lowpan_frags.skb_free = NULL;
 	lowpan_frags.qsize = sizeof(struct frag_queue);
 	lowpan_frags.match = lowpan_frag_match;
 	lowpan_frags.frag_expire = lowpan_frag_expire;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index d0a7c03..bf63ea4 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -291,14 +291,6 @@ void inet_frag_kill(struct inet_frag_queue *fq, struct inet_frags *f)
 }
 EXPORT_SYMBOL(inet_frag_kill);
 
-static inline void frag_kfree_skb(struct netns_frags *nf, struct inet_frags *f,
-				  struct sk_buff *skb)
-{
-	if (f->skb_free)
-		f->skb_free(skb);
-	kfree_skb(skb);
-}
-
 void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 {
 	struct sk_buff *fp;
@@ -315,7 +307,7 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f)
 		struct sk_buff *xp = fp->next;
 
 		sum_truesize += fp->truesize;
-		frag_kfree_skb(nf, f, fp);
+		kfree_skb(fp);
 		fp = xp;
 	}
 	sum = sum_truesize + f->qsize;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 5482745..325106d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -885,7 +885,6 @@ void __init ipfrag_init(void)
 	ip4_frags.hashfn = ip4_hashfn;
 	ip4_frags.constructor = ip4_frag_init;
 	ip4_frags.destructor = ip4_frag_free;
-	ip4_frags.skb_free = NULL;
 	ip4_frags.qsize = sizeof(struct ipq);
 	ip4_frags.match = ip4_frag_match;
 	ip4_frags.frag_expire = ip_expire;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f1159bb..10bbcd1 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -745,7 +745,6 @@ int __init ipv6_frag_init(void)
 	ip6_frags.hashfn = ip6_hashfn;
 	ip6_frags.constructor = ip6_frag_init;
 	ip6_frags.destructor = NULL;
-	ip6_frags.skb_free = NULL;
 	ip6_frags.qsize = sizeof(struct frag_queue);
 	ip6_frags.match = ip6_frag_match;
 	ip6_frags.frag_expire = ip6_frag_expire;
-- 
2.0.5
