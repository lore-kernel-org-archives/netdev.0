From: "Rusty Russell (IBM)" <rusty@au1.ibm.com>
Subject: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 15:57:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089871078.3571.56.camel@bach>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

	I spoke about this today, thought I'd send the code out.  Useful only
for reading, as it's entirely untested and some is tricky and needs
careful thinking.

Name: Fragment ID Wrap Workaround
Status: Untested
Signed-off-by: Rusty Russell <rusty@au.ibm.com> (authored)

There's at least one old IBM Bugzilla bug, in which fragement IDs
wrapped, causing NFS data corruption on UDP stresstesting.

Solution presented here is twofold:

1) Move the offset of the fragments every time the ID wraps (usually
   the packet doesn't fit exactly into the MTU, so we have some
   slack), and

2) Check overlapping fragments that the contents match: if not, drop
   the whole thing.

Note that I also implemented skb_iter functions, so I could compare
the fragment overlap efficiently: really should be a separate patch.
DaveM points out (FIXME) that doing the double walk means we need to
guarantee two kmaps for the networking code.

Also applies to IPv6.  Simpler implementation would just drop all
fragments on any overlap as a "doesn't happen IRL" case (it needs
someone to duplicate a packet, then send each one by a different MTU
path).

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .4882-linux-2.6.7-bk20/include/linux/ip.h .4882-linux-2.6.7-bk20.updated/include/linux/ip.h
--- .4882-linux-2.6.7-bk20/include/linux/ip.h	2004-07-08 15:10:10.000000000 +1000
+++ .4882-linux-2.6.7-bk20.updated/include/linux/ip.h	2004-07-09 13:08:42.000000000 +1000
@@ -118,12 +118,12 @@ struct inet_opt {
 	int			tos;		/* TOS */
 	unsigned	   	cmsg_flags;
 	struct ip_options	*opt;
+	__u32			id;		/* ID counter for DF pkts */
 	__u16			sport;		/* Source port */
 	unsigned char		hdrincl;	/* Include headers ? */
 	__u8			mc_ttl;		/* Multicasting TTL */
 	__u8			mc_loop;	/* Loopback */
 	__u8			pmtudisc;
-	__u16			id;		/* ID counter for DF pkts */
 	unsigned		recverr : 1,
 				freebind : 1;
 	int			mc_index;	/* Multicast device index */
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .4882-linux-2.6.7-bk20/include/linux/skbuff.h .4882-linux-2.6.7-bk20.updated/include/linux/skbuff.h
--- .4882-linux-2.6.7-bk20/include/linux/skbuff.h	2004-07-08 15:10:11.000000000 +1000
+++ .4882-linux-2.6.7-bk20.updated/include/linux/skbuff.h	2004-07-09 14:31:11.000000000 +1000
@@ -1108,6 +1108,23 @@ extern void	       skb_split(struct sk_b
 extern void skb_init(void);
 extern void skb_add_mtu(int mtu);
 
+struct skb_iter
+{
+	/* Iteration functions set these */
+	unsigned char *data;
+	unsigned int len;
+
+	/* Private to iteration */
+	unsigned int nextfrag;
+	struct sk_buff *fraglist;
+};
+
+/* Keep iterating until skb_iter_next returns false. */
+extern void skb_iter_first(const struct sk_buff *skb, struct skb_iter *i);
+extern int skb_iter_next(const struct sk_buff *skb, struct skb_iter *i);
+/* Call this if aborting loop before !skb_iter_next */
+extern void skb_iter_abort(const struct sk_buff *skb, struct skb_iter *i);
+
 #ifdef CONFIG_NETFILTER
 static inline void nf_conntrack_put(struct nf_ct_info *nfct)
 {
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .4882-linux-2.6.7-bk20/net/core/skbuff.c .4882-linux-2.6.7-bk20.updated/net/core/skbuff.c
--- .4882-linux-2.6.7-bk20/net/core/skbuff.c	2004-07-08 15:10:12.000000000 +1000
+++ .4882-linux-2.6.7-bk20.updated/net/core/skbuff.c	2004-07-09 14:35:28.000000000 +1000
@@ -929,6 +929,70 @@ fault:
 	return -EFAULT;
 }
 
+/* Keep iterating until skb_iter_next returns false. */
+void skb_iter_first(const struct sk_buff *skb, struct skb_iter *i)
+{
+	i->len = skb_headlen(skb);
+	i->data = (unsigned char *)skb->data;
+	i->nextfrag = 0;
+	i->fraglist = NULL;
+}
+
+int skb_iter_next(const struct sk_buff *skb, struct skb_iter *i)
+{
+	/* Unmap previous, if not head fragment. */
+	if (i->nextfrag)
+		kunmap_skb_frag(i->data);
+
+	if (i->fraglist) {
+	fraglist:
+		/* We're iterating through fraglist. */
+		if (i->nextfrag < skb_shinfo(i->fraglist)->nr_frags) {
+			i->data = kmap_skb_frag(&skb_shinfo(i->fraglist)
+						->frags[i->nextfrag]);
+			i->len = skb_shinfo(i->fraglist)->frags[i->nextfrag]
+				.size;
+			i->nextfrag++;
+			return 1;
+		}
+		/* Fragments with fragments?  Too hard! */
+		BUG_ON(skb_shinfo(i->fraglist)->frag_list);
+		i->fraglist = i->fraglist->next;
+		if (!i->fraglist)
+			goto end;
+
+		i->len = skb_headlen(i->fraglist);
+		i->data = i->fraglist->data;
+		i->nextfrag = 0;
+		return 1;
+	}
+
+	if (i->nextfrag < skb_shinfo(skb)->nr_frags) {
+		i->data = kmap_skb_frag(&skb_shinfo(skb)->frags[i->nextfrag]);
+		i->len = skb_shinfo(skb)->frags[i->nextfrag].size;
+		i->nextfrag++;
+		return 1;
+	}
+
+	i->fraglist = skb_shinfo(skb)->frag_list;
+	if (i->fraglist)
+		goto fraglist;
+
+end:
+	/* Bug trap for callers */
+	i->data = NULL;
+	return 0;
+}
+
+void skb_iter_abort(const struct sk_buff *skb, struct skb_iter *i)
+{
+	/* Unmap previous, if not head fragment. */
+	if (i->data && i->nextfrag)
+		kunmap_skb_frag(i->data);
+	/* Bug trap for callers */
+	i->data = NULL;
+}
+
 /* Checksum skb data. */
 
 unsigned int skb_checksum(const struct sk_buff *skb, int offset,
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .4882-linux-2.6.7-bk20/net/ipv4/ip_fragment.c .4882-linux-2.6.7-bk20.updated/net/ipv4/ip_fragment.c
--- .4882-linux-2.6.7-bk20/net/ipv4/ip_fragment.c	2004-06-17 08:49:53.000000000 +1000
+++ .4882-linux-2.6.7-bk20.updated/net/ipv4/ip_fragment.c	2004-07-09 15:28:48.000000000 +1000
@@ -399,8 +399,81 @@ static inline struct ipq *ip_find(struct
 	return ip_frag_create(hash, iph);
 }
 
-/* Add new segment to existing queue. */
-static void ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int skb_data_equal(const struct sk_buff *new, int startnew,
+			  const struct sk_buff *old, int startold,
+			  int len)
+{
+	struct skb_iter newi, oldi;
+	int ret = 1;
+
+	/* Move to first chunk with this offset in both cases */
+	skb_iter_first(new, &newi);
+	while (newi.len < startnew) {
+		startnew -= newi.len;
+		skb_iter_next(new, &newi);
+	}
+
+	skb_iter_first(old, &oldi);
+	while (oldi.len < startold) {
+		startold -= oldi.len;
+		skb_iter_next(old, &oldi);
+	}
+
+	while (len > 0) {
+		int cmplen = len;
+
+		/* How much can we compare? */
+		if (cmplen > oldi.len - startold)
+			cmplen = oldi.len - startold;
+		if (cmplen > newi.len - startnew)
+			cmplen = newi.len - startnew;
+		if (memcmp(oldi.data+startold, newi.data+startnew, cmplen)) {
+			ret = 0;
+			break;
+		}
+		startnew += cmplen;
+		startold += cmplen;
+		if (startold == oldi.len) {
+			skb_iter_next(old, &oldi);
+			startold = 0;
+		}
+		if (startnew == newi.len) {
+			skb_iter_next(new, &newi);
+			startnew = 0;
+		}
+		len -= cmplen;
+	}
+
+	skb_iter_abort(new, &newi);
+	skb_iter_abort(old, &oldi);
+	return ret;
+}
+
+static int frag_overlap_mismatch(const struct sk_buff *new,
+				 int offset,
+				 const struct sk_buff *old)
+{
+	int old_offset = FRAG_CB(old)->offset;
+	int startnew, startold, len;
+
+	if (offset < old_offset) {
+		startnew = old_offset - offset;
+		startold = 0;
+	} else {
+		startnew = 0;
+		startold = offset - old_offset;
+	}
+
+	len = min(old->len - startold, new->len - startnew);
+	if (len < 0)
+		return 0;
+
+	return !skb_data_equal(new, startnew, old, startold, len);
+}
+
+/* Add new segment to existing queue.  Return false if whole queue
+ * must drop. */
+static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 {
 	struct sk_buff *prev, *next;
 	int flags, offset;
@@ -471,6 +544,8 @@ static void ip_frag_queue(struct ipq *qp
 			offset += i;
 			if (end <= offset)
 				goto err;
+			if (frag_overlap_mismatch(skb, offset, prev))
+				goto mismatch;
 			if (!pskb_pull(skb, i))
 				goto err;
 			if (skb->ip_summed != CHECKSUM_UNNECESSARY)
@@ -481,6 +556,9 @@ static void ip_frag_queue(struct ipq *qp
 	while (next && FRAG_CB(next)->offset < end) {
 		int i = end - FRAG_CB(next)->offset; /* overlap is 'i' bytes */
 
+		if (frag_overlap_mismatch(skb, offset, next))
+			goto mismatch;
+
 		if (i < next->len) {
 			/* Eat head of the next overlapped fragment
 			 * and leave the loop. The next ones cannot overlap.
@@ -532,10 +610,17 @@ static void ip_frag_queue(struct ipq *qp
 	list_move_tail(&qp->lru_list, &ipq_lru_list);
 	write_unlock(&ipfrag_lock);
 
-	return;
+	return 1;
 
 err:
 	kfree_skb(skb);
+	return 1;
+
+mismatch:
+	/* Roughly equiv. to checksum incorrect. */
+	ipq_kill(qp);
+	kfree_skb(skb);
+	return 0;
 }
 
 
@@ -650,12 +735,13 @@ struct sk_buff *ip_defrag(struct sk_buff
 
 		spin_lock(&qp->lock);
 
-		ip_frag_queue(qp, skb);
-
-		if (qp->last_in == (FIRST_IN|LAST_IN) &&
-		    qp->meat == qp->len)
-			ret = ip_frag_reasm(qp, dev);
-
+		if (!ip_frag_queue(qp, skb))
+			ipq_kill(qp);
+		else {
+			if (qp->last_in == (FIRST_IN|LAST_IN) &&
+			    qp->meat == qp->len)
+				ret = ip_frag_reasm(qp, dev);
+		}
 		spin_unlock(&qp->lock);
 		ipq_put(qp);
 		return ret;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .4882-linux-2.6.7-bk20/net/ipv4/ip_output.c .4882-linux-2.6.7-bk20.updated/net/ipv4/ip_output.c
--- .4882-linux-2.6.7-bk20/net/ipv4/ip_output.c	2004-07-08 15:10:12.000000000 +1000
+++ .4882-linux-2.6.7-bk20.updated/net/ipv4/ip_output.c	2004-07-10 09:44:49.000000000 +1000
@@ -582,20 +582,33 @@ slow_path:
 	offset = (ntohs(iph->frag_off) & IP_OFFSET) << 3;
 	not_last_frag = iph->frag_off & htons(IP_MF);
 
+	len = left;
+	/* IF: it doesn't fit, use 'mtu' - the data space left */
+	if (len > mtu)
+		len = mtu;
+
+	/* IF: we are not sending upto and including the packet end
+	   then align the next start on an eight byte boundary */
+	if (len < left)
+		len &= ~7;
+
+	/* Try to shift initial fragment boundary if we can, to help
+	 * other end detect ID wrap. */
+	if (skb->sk) {
+		unsigned int slack;
+		struct inet_opt *inet = inet_sk(skb->sk);
+
+		slack = (left % mtu);
+		if (slack)
+			/* Shift by 8 bytes per id wrap. */
+			len = mtu - (slack % ((inet->id >> 16) << 3));
+	}
+
 	/*
 	 *	Keep copying data until we run out.
 	 */
 
 	while(left > 0)	{
-		len = left;
-		/* IF: it doesn't fit, use 'mtu' - the data space left */
-		if (len > mtu)
-			len = mtu;
-		/* IF: we are not sending upto and including the packet end
-		   then align the next start on an eight byte boundary */
-		if (len < left)	{
-			len &= ~7;
-		}
 		/*
 		 *	Allocate buffer.
 		 */
@@ -674,6 +687,16 @@ slow_path:
 		err = output(skb2);
 		if (err)
 			goto fail;
+
+		len = left;
+		/* IF: it doesn't fit, use 'mtu' - the data space left */
+		if (len > mtu)
+			len = mtu;
+		/* IF: we are not sending upto and including the packet end
+		   then align the next start on an eight byte boundary */
+		if (len < left)	{
+			len &= ~7;
+		}
 	}
 	kfree_skb(skb);
 	IP_INC_STATS(FragOKs);
