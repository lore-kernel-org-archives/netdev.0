From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 4/7]IPv6:netfilter: Send an ICMPv6 "Fragment
 Reassembly Timeout" message when enabling connection track
Date: Sat, 27 Feb 2010 14:40:01 +0800
Message-ID: <4B88BE41.8070000__43021.8642847196$1267252827$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50076 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753092Ab0B0GkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 01:40:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An end host with IPv6 connection track enable should send an 
ICMP "Fragment Reassembly Timeout" message when defraging timeout
according to the section 4.5 in RFC2460.

This patch supports it and adds counter value of Ip6ReasmTimeout and Ip6ReasmFails.


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


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/linux/skbuff.h                  |    5 +++
 net/ipv6/netfilter/nf_conntrack_reasm.c |   48 ++++++++++++++++++++++++++++++-
 net/ipv6/route.c                        |    1 +
 3 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ba0f8e3..e0b72e4 100644
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
index 8f68373..27d8ac1 100644
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
@@ -64,6 +66,7 @@ struct nf_ct_frag6_queue
 	struct in6_addr		saddr;
 	struct in6_addr		daddr;
 
+	int			iif;
 	unsigned int		csum;
 	__u16			nhoffset;
 };
@@ -205,6 +208,8 @@ static void nf_ct_frag6_evictor(struct net *net)
 static void nf_ct_frag6_expire(unsigned long data)
 {
 	struct nf_ct_frag6_queue *fq;
+	struct net_device *dev = NULL;
+	struct net *net;
 
 	fq = container_of((struct inet_frag_queue *)data,
 			struct nf_ct_frag6_queue, q);
@@ -215,7 +220,44 @@ static void nf_ct_frag6_expire(unsigned long data)
 		goto out;
 
 	fq_kill(fq);
+	net = container_of(fq->q.net, struct net, ipv6.frags);
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, fq->iif);
+	if (!dev)
+		goto out_rcu_unlock;
+
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+
+	/* Don't send error if the first segment did not arrive. */
+	if (!(fq->q.last_in & INET_FRAG_FIRST_IN) || !fq->q.fragments)
+		goto out_rcu_unlock;
+
+	/*
+	 * Only search router table for the head fragment,
+	 * when defraging timeout at PRE_ROUTING HOOK.
+	 */
+	if (fq->user == IP6_DEFRAG_CONNTRACK_IN) {
+		struct sk_buff *head = fq->q.fragments;
+
+		head->dev = dev;
+		ip6_route_input(head);
+		if (!skb_dst(head))
+			goto out_rcu_unlock;
+
+		/*
+		 * Only an end host needs to send an ICMP "Fragment Reassembly
+		 * Timeout" message, per section 4.5 of RFC2460.
+		 */
+		if (!(skb_r6table(head)->rt6i_flags & RTF_LOCAL))
+			goto out_rcu_unlock;
 
+		/* Send an ICMP "Fragment Reassembly Timeout" message. */
+		icmpv6_send(head, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0);
+	}
+
+out_rcu_unlock:
+	rcu_read_unlock();
 out:
 	spin_unlock(&fq->q.lock);
 	fq_put(fq);
@@ -405,7 +447,11 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
 	else
 		fq->q.fragments = skb;
 
-	skb->dev = NULL;
+	if (skb->dev) {
+		fq->iif = skb->dev->ifindex;
+		skb->dev = NULL;
+	}
+
 	fq->q.stamp = skb->tstamp;
 	fq->q.meat += skb->len;
 	atomic_add(skb->truesize, &fq->q.net->mem);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 88c0a5c..ef4bdd9 100644
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
