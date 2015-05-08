From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmentation icmp v3 3/4] bridge_netfilter: No ICMP packet on IPv4 defragmentation timeout
Date: Thu,  7 May 2015 21:26:38 -0700
Message-ID: <1431059199-7139-4-git-send-email-azhou@nicira.com>
References: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:48215 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751374AbbEHEsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 00:48:19 -0400
Received: by mail-pd0-f169.google.com with SMTP id nk13so63029585pdb.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 21:48:18 -0700 (PDT)
In-Reply-To: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, on defragmentation timeout error, ICMP error message
will be generated. This is fine when they are used in a routing context,
but does not make sense in the context of bridging netfilter.

This patch adds a bit (IPSKB_NO_FRAG_ICMP) in IPCB to control
whether ICMP error message should be generated. br_netfiler sets
this bit.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/inet_frag.h   |  4 +++-
 include/net/ip.h          |  1 +
 net/bridge/br_netfilter.c |  5 +++++
 net/ipv4/ip_fragment.c    | 12 ++++++++++--
 4 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 8d17655..e3c8840 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -22,12 +22,14 @@ struct netns_frags {
  * @INET_FRAG_LAST_IN: final fragment has arrived
  * @INET_FRAG_COMPLETE: frag queue has been processed and is due for destruction
  * @INET_FRAG_EVICTED: frag queue is being evicted
+ * @INET_FRAG_NO_ICMP: Do not send icmp message on incomplete defrag
  */
 enum {
 	INET_FRAG_FIRST_IN	= BIT(0),
 	INET_FRAG_LAST_IN	= BIT(1),
 	INET_FRAG_COMPLETE	= BIT(2),
-	INET_FRAG_EVICTED	= BIT(3)
+	INET_FRAG_EVICTED	= BIT(3),
+	INET_FRAG_NO_ICMP	= BIT(4)
 };
 
 /**
diff --git a/include/net/ip.h b/include/net/ip.h
index f79193a..1119764 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -45,6 +45,7 @@ struct inet_skb_parm {
 #define IPSKB_FRAG_COMPLETE	BIT(3)
 #define IPSKB_REROUTED		BIT(4)
 #define IPSKB_DOREDIRECT	BIT(5)
+#define IPSKB_NO_FRAG_ICMP	BIT(6)
 
 	u16			frag_max_size;
 };
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ab55e24..6a2adba 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -663,6 +663,11 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 	if (br_parse_ip_options(skb))
 		return NF_DROP;
 
+	/* In case this is a fragmented packet, do not send icmp packet on
+	 * defragmentation error
+	 */
+	IPCB(skb)->flags |= IPSKB_NO_FRAG_ICMP;
+
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
 		return NF_DROP;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 3061ca8..fc5f41a 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -226,7 +226,8 @@ static void ip_expire(unsigned long arg)
 		/* Only an end host needs to send an ICMP
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
-		if (frag_expire_skip_icmp(qp->user) &&
+		if ((qp->q.flags & INET_FRAG_NO_ICMP) ||
+		    frag_expire_skip_icmp(qp->user) ||
 		    (skb_rtable(head)->rt_type != RTN_LOCAL))
 			goto out_rcu_unlock;
 
@@ -330,6 +331,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	int ihl, end;
 	int err = -ENOENT;
 	u8 ecn;
+	bool no_icmp;
 
 	if (qp->q.flags & INET_FRAG_COMPLETE)
 		goto err;
@@ -347,6 +349,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	offset &= IP_OFFSET;
 	offset <<= 3;		/* offset is in 8-byte chunks */
 	ihl = ip_hdrlen(skb);
+	no_icmp = IPCB(skb)->flags & IPSKB_NO_FRAG_ICMP;
 
 	/* Determine the position of this fragment. */
 	end = offset + skb->len - ihl;
@@ -485,7 +488,12 @@ found:
 	    skb->len + ihl > qp->q.max_size)
 		qp->q.max_size = skb->len + ihl;
 
-	if (qp->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	if (no_icmp) {
+		qp->q.flags |= INET_FRAG_NO_ICMP;
+	}
+
+	if (((qp->q.flags & ~INET_FRAG_NO_ICMP) ==
+		(INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN)) &&
 	    qp->q.meat == qp->q.len) {
 		unsigned long orefdst = skb->_skb_refdst;
 
-- 
1.9.1
