From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmenation icmp 1/2] ipv4_fragment: Add a bit in IPCB to control ICMP generation
Date: Tue,  5 May 2015 18:59:53 -0700
Message-ID: <1430877594-32054-2-git-send-email-azhou@nicira.com>
References: <1430877594-32054-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:43574 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756011AbbEFC24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 22:28:56 -0400
Received: by mail-pa0-f46.google.com with SMTP id yx8so212206832pac.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 19:28:56 -0700 (PDT)
In-Reply-To: <1430877594-32054-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, on fragmentation or defragmentation error, ICMP error message
can be generated. This is fine when they are used in a routing context,
but does not make sense when they are used in a bridging context, i.e.
netfilter for bridging.

This patch adds a bit in IPCB to control whether ICMP error message
should be generated.

IPV6 fragmentation and defragmentation functions are not reused by
bridge netfilter. Thus, this change is only required for IPV4.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/inet_frag.h |  2 ++
 include/net/ip.h        |  1 +
 net/ipv4/ip_fragment.c  | 11 ++++++++++-
 net/ipv4/ip_output.c    |  5 +++--
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 8d17655..1d57045 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -44,6 +44,7 @@ enum {
  * @meat: length of received fragments so far
  * @flags: fragment queue flags
  * @max_size: (ipv4 only) maximum received fragment size with IP_DF set
+ * @no_icmp:  Do not generate any fragmentation related icmp packet
  * @net: namespace that this frag belongs to
  */
 struct inet_frag_queue {
@@ -58,6 +59,7 @@ struct inet_frag_queue {
 	int			meat;
 	__u8			flags;
 	u16			max_size;
+	bool			no_icmp;
 	struct netns_frags	*net;
 };
 
diff --git a/include/net/ip.h b/include/net/ip.h
index d14af7e..8d81c865 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -45,6 +45,7 @@ struct inet_skb_parm {
 #define IPSKB_FRAG_COMPLETE	BIT(3)
 #define IPSKB_REROUTED		BIT(4)
 #define IPSKB_DOREDIRECT	BIT(5)
+#define IPSKB_NO_FRAG_ICMP	BIT(6)
 
 	u16			frag_max_size;
 };
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cc1da6d..2f38d30 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -217,7 +217,8 @@ static void ip_expire(unsigned long arg)
 		/* Only an end host needs to send an ICMP
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
-		if (qp->user == IP_DEFRAG_AF_PACKET ||
+		if (qp->q.no_icmp ||
+		    qp->user == IP_DEFRAG_AF_PACKET ||
 		    ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
 		     (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) &&
 		     (skb_rtable(head)->rt_type != RTN_LOCAL)))
@@ -323,6 +324,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	int ihl, end;
 	int err = -ENOENT;
 	u8 ecn;
+	bool no_icmp;
 
 	if (qp->q.flags & INET_FRAG_COMPLETE)
 		goto err;
@@ -340,6 +342,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	offset &= IP_OFFSET;
 	offset <<= 3;		/* offset is in 8-byte chunks */
 	ihl = ip_hdrlen(skb);
+	no_icmp = IPCB(skb)->flags & IPSKB_NO_FRAG_ICMP;
 
 	/* Determine the position of this fragment. */
 	end = offset + skb->len - ihl;
@@ -478,6 +481,8 @@ found:
 	    skb->len + ihl > qp->q.max_size)
 		qp->q.max_size = skb->len + ihl;
 
+	qp->q.no_icmp = qp->q.no_icmp || no_icmp;
+
 	if (qp->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    qp->q.meat == qp->q.len) {
 		unsigned long orefdst = skb->_skb_refdst;
@@ -608,6 +613,10 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	head->tstamp = qp->q.stamp;
 	IPCB(head)->frag_max_size = qp->q.max_size;
 
+	IPCB(head)->flags &= ~IPSKB_NO_FRAG_ICMP;
+	if (qp->q.no_icmp)
+		IPCB(head)->flags |= IPSKB_NO_FRAG_ICMP;
+
 	iph = ip_hdr(head);
 	/* max_size != 0 implies at least one fragment had IP_DF set */
 	iph->frag_off = qp->q.max_size ? htons(IP_DF) : 0;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65b93a..dfa425c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -511,8 +511,9 @@ int ip_fragment(struct sock *sk, struct sk_buff *skb,
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(mtu));
+		if (!(IPCB(skb)->flags & IPSKB_NO_FRAG_ICMP))
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
-- 
1.9.1
