From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 5/9] inet: frag: don't account number of fragment queues
Date: Thu, 24 Jul 2014 16:50:33 +0200
Message-ID: <1406213437-6155-6-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:13829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933322AbaGXOwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:03 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The 'nqueues' counter is protected by the lru list lock,
once thats removed this needs to be converted to atomic
counter.  Given this isn't used for anything except for
reporting it to userspace via /proc, just remove it.

We still report the memory currently used by fragment
reassembly queues.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h  | 3 ---
 include/net/ip.h         | 1 -
 include/net/ipv6.h       | 5 -----
 net/ipv4/inet_fragment.c | 1 -
 net/ipv4/ip_fragment.c   | 5 -----
 net/ipv4/proc.c          | 5 +++--
 net/ipv6/proc.c          | 4 ++--
 7 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index e975032ea11b..68de33765705 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -4,7 +4,6 @@
 #include <linux/percpu_counter.h>
 
 struct netns_frags {
-	int			nqueues;
 	struct list_head	lru_list;
 	spinlock_t		lru_lock;
 
@@ -158,7 +157,6 @@ static inline void inet_frag_lru_del(struct inet_frag_queue *q)
 {
 	spin_lock(&q->net->lru_lock);
 	list_del_init(&q->lru_list);
-	q->net->nqueues--;
 	spin_unlock(&q->net->lru_lock);
 }
 
@@ -167,7 +165,6 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 {
 	spin_lock(&nf->lru_lock);
 	list_add_tail(&q->lru_list, &nf->lru_list);
-	q->net->nqueues++;
 	spin_unlock(&nf->lru_lock);
 }
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 2e8f055989c3..ca14799545fd 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -495,7 +495,6 @@ static inline struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 }
 #endif
 int ip_frag_mem(struct net *net);
-int ip_frag_nqueues(struct net *net);
 
 /*
  *	Functions provided by ip_forward.c
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 25c2170e1298..a2db816e8461 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -299,11 +299,6 @@ static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline int ip6_frag_nqueues(struct net *net)
-{
-	return net->ipv6.frags.nqueues;
-}
-
 static inline int ip6_frag_mem(struct net *net)
 {
 	return sum_frag_mem_limit(&net->ipv6.frags);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 43315ecb9400..231ca0b40811 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -193,7 +193,6 @@ EXPORT_SYMBOL(inet_frags_init);
 
 void inet_frags_init_net(struct netns_frags *nf)
 {
-	nf->nqueues = 0;
 	init_frag_mem_limit(nf);
 	INIT_LIST_HEAD(&nf->lru_list);
 	spin_lock_init(&nf->lru_lock);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 54bd170c5eb4..1f42c2e3966b 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -86,11 +86,6 @@ static inline u8 ip4_frag_ecn(u8 tos)
 
 static struct inet_frags ip4_frags;
 
-int ip_frag_nqueues(struct net *net)
-{
-	return net->ipv4.frags.nqueues;
-}
-
 int ip_frag_mem(struct net *net)
 {
 	return sum_frag_mem_limit(&net->ipv4.frags);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ae0af9386f7c..8e3eb39f84e7 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -52,6 +52,7 @@
 static int sockstat_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
+	unsigned int frag_mem;
 	int orphans, sockets;
 
 	local_bh_disable();
@@ -71,8 +72,8 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 		   sock_prot_inuse_get(net, &udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n",
 		   sock_prot_inuse_get(net, &raw_prot));
-	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
-			ip_frag_nqueues(net), ip_frag_mem(net));
+	frag_mem = ip_frag_mem(net);
+	seq_printf(seq,  "FRAG: inuse %u memory %u\n", !!frag_mem, frag_mem);
 	return 0;
 }
 
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 3317440ea341..2d6f860e5c1e 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -33,6 +33,7 @@
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
+	unsigned int frag_mem = ip6_frag_mem(net);
 
 	seq_printf(seq, "TCP6: inuse %d\n",
 		       sock_prot_inuse_get(net, &tcpv6_prot));
@@ -42,8 +43,7 @@ static int sockstat6_seq_show(struct seq_file *seq, void *v)
 			sock_prot_inuse_get(net, &udplitev6_prot));
 	seq_printf(seq, "RAW6: inuse %d\n",
 		       sock_prot_inuse_get(net, &rawv6_prot));
-	seq_printf(seq, "FRAG6: inuse %d memory %d\n",
-		       ip6_frag_nqueues(net), ip6_frag_mem(net));
+	seq_printf(seq, "FRAG6: inuse %u memory %u\n", !!frag_mem, frag_mem);
 	return 0;
 }
 
-- 
1.9.3
