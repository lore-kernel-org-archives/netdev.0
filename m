From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Wed, 13 Mar 2013 02:27:15 +0100
Message-ID: <20130313012715.GE14801@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60158 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462Ab3CMB1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 21:27:16 -0400
Content-Disposition: inline
In-Reply-To: <1362756219.15793.240.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc'ing Jesper, too]

On Fri, Mar 08, 2013 at 07:23:39AM -0800, Eric Dumazet wrote:
> On Fri, 2013-03-08 at 16:08 +0100, Hannes Frederic Sowa wrote:
> > On Fri, Mar 08, 2013 at 06:53:06AM -0800, Eric Dumazet wrote:
> > > No matter how you hash, a hacker can easily fill your defrag unit with
> > > not complete datagrams, so what's the point ?
> > 
> > I want to harden reassembly logic against all fragments being put in
> > the same hash bucket because of malicious traffic and thus creating
> > long list traversals in the fragment queue hash table.
> 
> Note that the long traversal was a real issue with TCP (thats why I
> introduced ipv6_addr_jhash()), as a single ehash slot could contains
> thousand of sockets.
> 
> But with fragments, we should just limit the depth of any particular
> slot, and drop above a particular threshold.

[PATCH net-next RFC] inet: add max_depth to limit list length in inet_frags hash

This does implement trivial drop for fragments where the hash queue
is above some limit.

I calculate the limit as follow:

I averaged the folowing formula

max_depth = max_threshold / INETFRAGS_HASHSZ / rounded up (SKB_TRUELEN(0)
            sizeof(struct ipq or struct frag_queue))

to

max_threshold >> 15

So we start with a maximum list length of 128. I think we could halve
this value to 64, but because I have no real performance data I left it
at this higher value for now.

This patch does only protect IPv6 (and not netfilter ipv6 defragmentation)
and will switch off limit checking if max_depth is zero. I'll rewrite
the check if we agree that this simple solution is the way to go (simple
drop) and will clamp the minimum value to 1 as soon as I also migrated
ipv4 and netfilter to the new sysctl handler.

When testing this patch:

Disable netfilter defragmenation for ipv6 on your machine if you test
this patch, otherwise you won't see the improvment. Machine now runs
smoothly under fragmentation dos.

Ok if I target this patch for net next time because the hashing changes
are in there already?

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_frag.h  | 13 +++++++++++++
 net/ipv4/inet_fragment.c | 25 ++++++++++++++++++++++++-
 net/ipv6/reassembly.c    |  6 +++++-
 3 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 76c3fe5..9ba6ada 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -17,6 +17,7 @@ struct netns_frags {
 	int			timeout;
 	int			high_thresh;
 	int			low_thresh;
+	int			max_depth;
 };
 
 struct inet_frag_queue {
@@ -43,6 +44,11 @@ struct inet_frag_queue {
 
 #define INETFRAGS_HASHSZ		64
 
+/* max_depth = max_threshold / INETFRAGS_HASHSZ / rounded up (SKB_TRUELEN(0) +
+ *	       sizeof(struct ipq or struct frag_queue))
+ */
+#define INETFRAGS_MAXDEPTH_SHIFT	15
+
 struct inet_frags {
 	struct hlist_head	hash[INETFRAGS_HASHSZ];
 	/* This rwlock is a global lock (seperate per IPv4, IPv6 and
@@ -144,4 +150,11 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 	list_add_tail(&q->lru_list, &nf->lru_list);
 	spin_unlock(&nf->lru_lock);
 }
+
+#ifdef CONFIG_SYSCTL
+int inet_frag_update_high_thresh(struct ctl_table *table, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos);
+#endif
+
 #endif
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 245ae07..92f1fdd 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -277,6 +277,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	__releases(&f->lock)
 {
 	struct inet_frag_queue *q;
+	int depth = 0;
 
 	hlist_for_each_entry(q, &f->hash[hash], list) {
 		if (q->net == nf && f->match(q, key)) {
@@ -284,9 +285,31 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 			read_unlock(&f->lock);
 			return q;
 		}
+		depth++;
 	}
 	read_unlock(&f->lock);
 
-	return inet_frag_create(nf, f, key);
+	if (!nf->max_depth || depth <= nf->max_depth)
+		return inet_frag_create(nf, f, key);
+	else
+		return NULL;
 }
 EXPORT_SYMBOL(inet_frag_find);
+
+#ifdef CONFIG_SYSCTL
+int inet_frag_update_high_thresh(struct ctl_table *table, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos)
+{
+	int ret;
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+
+	if (!ret && write && table->extra1) {
+		int *data = table->data;
+		int *max_depth = table->extra1;
+		*max_depth = *data >> INETFRAGS_MAXDEPTH_SHIFT;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(inet_frag_update_high_thresh);
+#endif
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 3c6a772..84b35f6 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -558,7 +558,8 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= inet_frag_update_high_thresh,
+		.extra1		= &init_net.ipv6.frags.max_depth
 	},
 	{
 		.procname	= "ip6frag_low_thresh",
@@ -600,6 +601,7 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 			goto err_alloc;
 
 		table[0].data = &net->ipv6.frags.high_thresh;
+		table[0].extra1 = &net->ipv6.frags.max_depth;
 		table[1].data = &net->ipv6.frags.low_thresh;
 		table[2].data = &net->ipv6.frags.timeout;
 
@@ -670,6 +672,8 @@ static int __net_init ipv6_frags_init_net(struct net *net)
 	net->ipv6.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
 	net->ipv6.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	net->ipv6.frags.timeout = IPV6_FRAG_TIMEOUT;
+	net->ipv6.frags.max_depth =
+		IPV6_FRAG_HIGH_THRESH >> INETFRAGS_MAXDEPTH_SHIFT;
 
 	inet_frags_init_net(&net->ipv6.frags);
 
-- 
1.8.1.4
