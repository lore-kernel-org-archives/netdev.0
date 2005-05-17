From: Arthur Kepner <akepner@sgi.com>
Subject: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 09:18:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505170914130.29021@linux.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The Problem
-----------

There's a well-known problem with IPv4 fragmentation/ 
reassembly - the 16-bit IP ID can uniquely identify 
only 65535 datagrams, and a gigabit/sec source can 
emit that many datagrams in seconds. Since fragments 
can sit on a reassembly queue for a "long time" 
(30 seconds is the default in Linux), there's a 
possibility of reassembling fragments from different 
datagrams.

The Bigger Problem
------------------

This is mainly a problem for UDP, where IP fragmentation 
at the source is not uncommon. The UDP checksum is only 
16 bits, so there's a not-insignificant possibility that 
it won't detect when a datagram has been incorrectly 
reassembled. The result can be silent data corruption, 
and much unhappiness.

What next?
----------

This is a fundamental problem with IP(v4), which was 
designed before people dreamed of gigabit/sec network 
links. There's no simple, completely effective fix that 
preserves compatability. 

There has been at least a little discussion here 
before:
http://marc.theaimsgroup.com/?l=linux-netdev&m=108987122412812&w=2

A simple, obvious, partial remedy is to tune 
"sysctl_ipfrag_time" down.

Another simple change which preserves compatability in 
practice, is "strict ipv4 reassembly". Being "strict" about 
reassembly means that you don't allow gaps or overlaps in 
the reassembly queue. Fragments which would introduce gaps 
or overlaps are dropped. Disallowing gaps and overlaps also 
implies that:

  1) Fragments must arrive in order (or in reverse order) -
     out of order fragments are dropped. 

  2) If the first (or last) fragment of a datagram arrives 
     and there's already a reassembly queue for that (proto, 
     ipid, src, dst), then the existing reassembly queue is
     dropped, and a new one started.

Strict reassembly has been very effective in practice at 
preventing incorrect IP reassembly. (We have tests which 
attempt to produce and then detect corruption produced 
by bad IP reassembly.)

Following is a patch which implements strict reassembly. 
Strict reassembly is off by default (so the default 
behavior is not changed.)  Strict reassembly is enabled 
by doing "echo 1 > /proc/sys/net/ipv4/strict_reassembly".

Patch is against 2.6.12-rc4.

 include/linux/sysctl.h     |    1
 net/ipv4/ip_fragment.c     |  189 ++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c |    9 ++
 3 files changed, 198 insertions(+), 1 deletion(-)

Signed-off-by: Arthur Kepner <akepner@sgi.com>

diff -pur linux.old/include/linux/sysctl.h linux.new/include/linux/sysctl.h
--- linux.old/include/linux/sysctl.h	2005-05-16 16:29:55.236056917 -0700
+++ linux.new/include/linux/sysctl.h	2005-05-17 00:57:16.889588271 -0700
@@ -347,6 +347,7 @@ enum
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
 	NET_TCP_BIC_BETA=108,
+	NET_IPV4_STRICT_REASM=109,
 };
 
 enum {
diff -pur linux.old/net/ipv4/ip_fragment.c linux.new/net/ipv4/ip_fragment.c
--- linux.old/net/ipv4/ip_fragment.c	2005-05-16 16:30:18.610281655 -0700
+++ linux.new/net/ipv4/ip_fragment.c	2005-05-17 00:53:53.243293277 -0700
@@ -56,6 +56,9 @@
 int sysctl_ipfrag_high_thresh = 256*1024;
 int sysctl_ipfrag_low_thresh = 192*1024;
 
+/* strict reassembly is off by default */
+int sysctl_strict_reassembly = 0;
+
 /* Important NOTE! Fragment queue must be destroyed before MSL expires.
  * RFC791 is wrong proposing to prolongate timer each fragment arrival by TTL.
  */
@@ -353,6 +356,24 @@ static struct ipq *ip_frag_create(unsign
 {
 	struct ipq *qp;
 
+	if (sysctl_strict_reassembly) {
+		/* make a new reassembly queue iff this is the first or
+		 * last fragment */
+		int frag_off = ntohs(iph->frag_off);
+		int offset   = (frag_off & IP_OFFSET);
+
+		if ((offset == 0) && !(frag_off & IP_MF)) {
+			/* first fragment and there aren't anymore coming -
+			 * nonsense, drop the fragment */
+			return NULL;
+		}
+		if ((offset != 0) && (frag_off & IP_MF)) {
+			/* if this isn't either the first or last fragment,
+			 * don't make a new reassembly queue */
+			return NULL;
+		}
+	}
+
 	if ((qp = frag_alloc_queue()) == NULL)
 		goto out_nomem;
 
@@ -381,6 +402,35 @@ out_nomem:
 	return NULL;
 }
 
+/* a reassembly queue match has been found and we're being
+ * "strict" about reassembly. If this fragment is first (last)
+ * in a reassembly queue which already has a first (last)
+ * fragment, then drop the existing reassembly queue. Return
+ * 1 if the existing queue was dropped, 0 otherwise.
+ *
+ * This function is called with (and returns with) a read_lock
+ * on ipfrag_lock
+ */
+static int __ip_find_strict_check(const struct iphdr *iph, struct ipq *qp)
+{
+	int frag_off = ntohs(iph->frag_off);
+	int offset   = (frag_off & IP_OFFSET);
+
+	if (((offset == 0) && (qp->last_in & FIRST_IN)) ||
+		(!(frag_off & IP_MF) && (qp->last_in & LAST_IN))) {
+		atomic_inc(&qp->refcnt);
+		read_unlock(&ipfrag_lock);
+		spin_lock(&qp->lock);
+		if (!(qp->last_in&COMPLETE))
+			ipq_kill(qp);
+		spin_unlock(&qp->lock);
+		ipq_put(qp, NULL);
+		read_lock(&ipfrag_lock);
+		return 1;
+	}
+	return 0;
+}
+
 /* Find the correct entry in the "incomplete datagrams" queue for
  * this IP datagram, and create new one, if nothing is found.
  */
@@ -400,6 +450,10 @@ static inline struct ipq *ip_find(struct
 		   qp->daddr == daddr	&&
 		   qp->protocol == protocol &&
 		   qp->user == user) {
+			if (sysctl_strict_reassembly &&
+				__ip_find_strict_check(iph, qp)) {
+				break;
+			}
 			atomic_inc(&qp->refcnt);
 			read_unlock(&ipfrag_lock);
 			return qp;
@@ -549,6 +603,136 @@ err:
 	kfree_skb(skb);
 }
 
+/* Add new segment to existing queue using "strict" semantics. 
+ * The segment is rejected if it introduces gaps in the reassembly 
+ * queue or overlaps with any existing fragments in the reassembly 
+ * queue. 
+ */
+static void ip_frag_queue_strict(struct ipq *qp, struct sk_buff *skb)
+{
+	struct sk_buff *prev, *next;
+	int flags, offset;
+	int ihl, end;
+
+	if (qp->last_in & COMPLETE)
+		goto err;
+
+ 	offset = ntohs(skb->nh.iph->frag_off);
+	flags = offset & ~IP_OFFSET;
+	offset &= IP_OFFSET;
+	offset <<= 3;		/* offset is in 8-byte chunks */
+ 	ihl = skb->nh.iph->ihl * 4;
+
+	/* Determine the position of this fragment. */
+ 	end = offset + skb->len - ihl;
+
+	if ((!(flags & IP_MF) && (qp->last_in & LAST_IN)) ||
+		((offset == 0) && (qp->last_in & FIRST_IN))) {
+		/* This can happen only if sysctl_strict_reassembly 
+		 * was toggled on after we did ip_find() for this 
+		 * fragment.
+		 */
+		goto err;
+	}
+
+	/* Is this the final fragment? */
+	if ((flags & IP_MF) == 0) {
+		/* If we already have some bits beyond end 
+		 * drop this fragment.
+		 */
+		if (end < qp->len)
+			goto err;
+		qp->len = end;
+	} else {
+		if (end&7) {
+			end &= ~7;
+			if (skb->ip_summed != CHECKSUM_UNNECESSARY)
+				skb->ip_summed = CHECKSUM_NONE;
+		}
+		if (end > qp->len) {
+			/* Some bits beyond end -> corruption. */
+			if (qp->last_in & LAST_IN)
+				goto err;
+			qp->len = end;
+		}
+	}
+	if (end == offset)
+		goto err;
+
+	if (pskb_pull(skb, ihl) == NULL)
+		goto err;
+	if (pskb_trim(skb, end-offset))
+		goto err;
+
+	/* Find out which fragments are in front and at the back of us
+	 * in the chain of fragments so far.  We must know where to put
+	 * this fragment, right?
+	 */
+	prev = NULL;
+	for(next = qp->fragments; next != NULL; next = next->next) {
+		if (FRAG_CB(next)->offset >= offset)
+			break;	/* bingo! */
+		prev = next;
+	}
+
+	WARN_ON(prev && next);
+
+	/* We found where to put this one. Make sure there are no overlaps */
+
+	if (prev) {
+		int i = (FRAG_CB(prev)->offset + prev->len) - offset;
+
+		/* if i > 0, this fragment overlaps with the previous 
+		 * fragment. if i < 0, this fragment would introduce a 
+		 * "hole" in the reassembly chain. Drop it in either 
+		 * case. 
+		 */
+
+		if (i != 0) goto err;
+
+	}
+
+	if (next) {
+		int i = end - FRAG_CB(next)->offset;
+
+		/* if i > 0, this fragment overlaps with the next.
+		 * if i < 0,  this fragment would introduce a
+		 * "hole" in the reassembly chain. Drop it in either
+		 * case.
+		 */
+
+		if (i != 0) goto err;
+	}
+
+	FRAG_CB(skb)->offset = offset;
+
+	/* Insert this fragment in the chain of fragments. */
+	skb->next = next;
+	if (prev)
+		prev->next = skb;
+	else
+		qp->fragments = skb;
+
+ 	if (skb->dev)
+ 		qp->iif = skb->dev->ifindex;
+	skb->dev = NULL;
+	qp->stamp = skb->stamp;
+	qp->meat += skb->len;
+	atomic_add(skb->truesize, &ip_frag_mem);
+	if (offset == 0)
+		qp->last_in |= FIRST_IN;
+	if ((flags & IP_MF) == 0) 
+		qp->last_in |= LAST_IN;
+
+	write_lock(&ipfrag_lock);
+	list_move_tail(&qp->lru_list, &ipq_lru_list);
+	write_unlock(&ipfrag_lock);
+
+	return;
+
+err:
+	kfree_skb(skb);
+}
 
 /* Build a new IP datagram from all its fragments. */
 
@@ -661,7 +845,10 @@ struct sk_buff *ip_defrag(struct sk_buff
 
 		spin_lock(&qp->lock);
 
-		ip_frag_queue(qp, skb);
+		if (sysctl_strict_reassembly)
+			ip_frag_queue_strict(qp, skb);
+		else
+			ip_frag_queue(qp, skb);
 
 		if (qp->last_in == (FIRST_IN|LAST_IN) &&
 		    qp->meat == qp->len)
diff -pur linux.old/net/ipv4/sysctl_net_ipv4.c linux.new/net/ipv4/sysctl_net_ipv4.c
--- linux.old/net/ipv4/sysctl_net_ipv4.c	2005-05-16 16:30:31.773480692 -0700
+++ linux.new/net/ipv4/sysctl_net_ipv4.c	2005-05-16 17:18:07.125138363 -0700
@@ -29,6 +29,7 @@ extern int sysctl_ipfrag_low_thresh;
 extern int sysctl_ipfrag_high_thresh; 
 extern int sysctl_ipfrag_time;
 extern int sysctl_ipfrag_secret_interval;
+extern int sysctl_strict_reassembly;
 
 /* From ip_output.c */
 extern int sysctl_ip_dynaddr;
@@ -258,6 +259,14 @@ ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_jiffies
 	},
 	{
+		.ctl_name	= NET_IPV4_STRICT_REASM,
+		.procname	= "strict_reassembly",
+		.data		= &sysctl_strict_reassembly,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{
 		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_TIME,
 		.procname	= "tcp_keepalive_time",
 		.data		= &sysctl_tcp_keepalive_time,


--
Arthur
