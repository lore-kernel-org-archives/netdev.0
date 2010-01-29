From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] IPv6:Send an ICMPv6 "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Fri, 29 Jan 2010 16:58:32 +0800
Message-ID: <4B62A338.6020106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, randy.dunlap@oracle.com, mst@redhat.com,
	johannes@sipsolutions.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, pablo@netfilter.org,
	ebiederm@xmission.com, adobriyan@gmail.com, brian.haley@hp.com,
	shemminger@vyatta.com, akpm@linux-foundation.org,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have made a patch for an end host with IPv4 connection track enable
to send an ICMP "Fragment Reassembly Timeout" message when defaging timeout.
So add same changes for IPv6 connection track according to the section 4.5 
in RFC2460.

Quote Begin:
 Section 4.5 in RFC2460.
   If insufficient fragments are received to complete reassembly of a
   packet within 60 seconds of the reception of the first-arriving
   fragment of that packet, reassembly of that packet must be
   abandoned and all the fragments that have been received for that
   packet must be discarded.  If the first fragment (i.e., the one
   with a Fragment Offset of zero) has been received, an ICMP Time
   Exceeded -- Fragment Reassembly Time Exceeded message should be
   sent to the source of that fragment.
Quote End.

I have tested the patch on both host type and route type.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com> 
---
 include/linux/skbuff.h                  |    5 ++++
 net/ipv6/netfilter/nf_conntrack_reasm.c |   34 ++++++++++++++++++++++++++++++-
 net/ipv6/route.c                        |    1 +
 3 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ae836fd..33a1784 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -431,6 +431,11 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 	return (struct rtable *)skb_dst(skb);
 }
 
+static inline struct rt6_info *skb_r6table(const struct sk_buff *skb)
+{
+	return (struct rt6_info *)skb_dst(skb);
+}
+
 extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 312c20a..2be0edc 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -27,10 +27,12 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/random.h>
+#include <linux/ipv6_route.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
 #include <net/inet_frag.h>
+#include <net/ip6_route.h>
 
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -160,6 +162,33 @@ static void nf_ct_frag6_expire(unsigned long data)
 
 	fq_kill(fq);
 
+	/* Don't send error if the first segment did not arrive. */
+	if (!(fq->q.last_in & INET_FRAG_FIRST_IN) || !fq->q.fragments)
+		goto out;
+
+	/*
+	 * Only search router table for the head fragment,
+	 * when defraging timeout at PRE_ROUTING HOOK.
+	 */
+	if (fq->user == IP6_DEFRAG_CONNTRACK_IN) {
+		struct sk_buff *head = fq->q.fragments;
+
+		ip6_route_input(head);
+		if (!skb_dst(head))
+			goto out;
+
+		/*
+		 * Only an end host needs to send an ICMP "Fragment Reassembly
+		 * Timeout" message, per section 4.5 of RFC2460.
+		 */
+		if (!(skb_r6table(head)->rt6i_flags & RTF_LOCAL))
+			goto out;
+
+		/* Send an ICMP "Fragment Reassembly Timeout" message. */
+		icmpv6_send(head, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0,
+			    head->dev);
+	}
+
 out:
 	spin_unlock(&fq->q.lock);
 	fq_put(fq);
@@ -349,17 +378,20 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	else
 		fq->q.fragments = skb;
 
-	skb->dev = NULL;
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
 	atomic_add(skb->truesize, &nf_init_frags.mem);
 
 	/* The first fragment.
 	 * nhoffset is obtained from the first fragment, of course.
+	 * Reserve dev for sending an ICMP "Fragment Reassembly Timeout"
+	 * message.
 	 */
 	if (offset == 0) {
 		fq->nhoffset = nhoff;
 		fq->q.last_in |= INET_FRAG_FIRST_IN;
+	} else {
+		skb->dev = NULL;
 	}
 	write_lock(&nf_frags.lock);
 	list_move_tail(&fq->q.lru_list, &nf_init_frags.lru_list);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2bd74c..0980d6c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -802,6 +802,7 @@ void ip6_route_input(struct sk_buff *skb)
 
 	skb_dst_set(skb, fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input));
 }
+EXPORT_SYMBOL(ip6_route_input);
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi *fl, int flags)
-- 
1.6.3.3

