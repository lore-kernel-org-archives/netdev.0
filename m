From: "David S. Miller" <davem@redhat.com>
Subject: Re: ip_evictor can loop
Date: Wed, 18 Aug 2004 19:25:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818192514.7332af06.davem@redhat.com>
References: <41240E63.CAD19093@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Prasanna Meda <pmeda@akamai.com>
In-Reply-To: <41240E63.CAD19093@akamai.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


BTW, I forgot to mention to Parsanna when I discussed this
with him in private that ipv6 has an identical problem since
the ipv6 code is derived from the ipv4 stuff.

Fix for that one follows.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/18 14:34:14-07:00 davem@nuts.davemloft.net 
#   [IPV6]: ip6_evictor() has same problem as ip_evictor().
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv6/reassembly.c
#   2004/08/18 14:33:54-07:00 davem@nuts.davemloft.net +22 -15
#   [IPV6]: ip6_evictor() has same problem as ip_evictor().
# 
diff -Nru a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
--- a/net/ipv6/reassembly.c	2004-08-18 19:13:13 -07:00
+++ b/net/ipv6/reassembly.c	2004-08-18 19:13:13 -07:00
@@ -195,14 +195,18 @@
 atomic_t ip6_frag_mem = ATOMIC_INIT(0);
 
 /* Memory Tracking Functions. */
-static inline void frag_kfree_skb(struct sk_buff *skb)
+static inline void frag_kfree_skb(struct sk_buff *skb, int *work)
 {
+	if (work)
+		*work -= skb->truesize;
 	atomic_sub(skb->truesize, &ip6_frag_mem);
 	kfree_skb(skb);
 }
 
-static inline void frag_free_queue(struct frag_queue *fq)
+static inline void frag_free_queue(struct frag_queue *fq, int *work)
 {
+	if (work)
+		*work -= sizeof(struct frag_queue);
 	atomic_sub(sizeof(struct frag_queue), &ip6_frag_mem);
 	kfree(fq);
 }
@@ -220,7 +224,7 @@
 /* Destruction primitives. */
 
 /* Complete destruction of fq. */
-static void ip6_frag_destroy(struct frag_queue *fq)
+static void ip6_frag_destroy(struct frag_queue *fq, int *work)
 {
 	struct sk_buff *fp;
 
@@ -232,17 +236,17 @@
 	while (fp) {
 		struct sk_buff *xp = fp->next;
 
-		frag_kfree_skb(fp);
+		frag_kfree_skb(fp, work);
 		fp = xp;
 	}
 
-	frag_free_queue(fq);
+	frag_free_queue(fq, work);
 }
 
-static __inline__ void fq_put(struct frag_queue *fq)
+static __inline__ void fq_put(struct frag_queue *fq, int *work)
 {
 	if (atomic_dec_and_test(&fq->refcnt))
-		ip6_frag_destroy(fq);
+		ip6_frag_destroy(fq, work);
 }
 
 /* Kill fq entry. It is not destroyed immediately,
@@ -264,10 +268,13 @@
 {
 	struct frag_queue *fq;
 	struct list_head *tmp;
+	int work;
 
-	for(;;) {
-		if (atomic_read(&ip6_frag_mem) <= sysctl_ip6frag_low_thresh)
-			return;
+	work = atomic_read(&ip6_frag_mem) - sysctl_ip6frag_low_thresh;
+	if (work <= 0)
+		return;
+
+	while(work > 0) {
 		read_lock(&ip6_frag_lock);
 		if (list_empty(&ip6_frag_lru_list)) {
 			read_unlock(&ip6_frag_lock);
@@ -283,7 +290,7 @@
 			fq_kill(fq);
 		spin_unlock(&fq->lock);
 
-		fq_put(fq);
+		fq_put(fq, &work);
 		IP6_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
 	}
 }
@@ -320,7 +327,7 @@
 	}
 out:
 	spin_unlock(&fq->lock);
-	fq_put(fq);
+	fq_put(fq, NULL);
 }
 
 /* Creation primitives. */
@@ -340,7 +347,7 @@
 			atomic_inc(&fq->refcnt);
 			write_unlock(&ip6_frag_lock);
 			fq_in->last_in |= COMPLETE;
-			fq_put(fq_in);
+			fq_put(fq_in, NULL);
 			return fq;
 		}
 	}
@@ -539,7 +546,7 @@
 				fq->fragments = next;
 
 			fq->meat -= free_it->len;
-			frag_kfree_skb(free_it);
+			frag_kfree_skb(free_it, NULL);
 		}
 	}
 
@@ -734,7 +741,7 @@
 			ret = ip6_frag_reasm(fq, skbp, nhoffp, dev);
 
 		spin_unlock(&fq->lock);
-		fq_put(fq);
+		fq_put(fq, NULL);
 		return ret;
 	}
 
