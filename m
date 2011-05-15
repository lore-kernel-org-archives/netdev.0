From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Sun, 15 May 2011 15:35:42 +0200
Message-ID: <1305466542.3120.129.camel@edumazet-laptop>
References: <201105141938.28344.v13@v13.gr>
	 <1305393402.3120.67.camel@edumazet-laptop>
	 <1305393711.3120.69.camel@edumazet-laptop>  <201105151337.22831.v13@v13.gr>
	 <1305461344.3120.112.camel@edumazet-laptop>
	 <1305464176.3120.113.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stefanos Harhalakis <v13@v13.gr>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52594 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab1EONfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 09:35:46 -0400
Received: by wwa36 with SMTP id 36so4278574wwa.1
        for <netdev@vger.kernel.org>; Sun, 15 May 2011 06:35:45 -0700 (PDT)
In-Reply-To: <1305464176.3120.113.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6623e3b24a5e (ipv4: IP defragmentation must be ECN aware) was an
attempt to not lose "Congestion Experienced" (CE) indications when
performing datagram defragmentation.

Stefanos Harhalakis raised the point that RFC 3168 requirements were not
completely met by this commit.

In particular, we MUST detect invalid combinations and eventually drop
illegal frames.

Reported-by: Stefanos Harhalakis <v13@v13.gr>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_fragment.c |   66 ++++++++++++++++++++++++++-------------
 1 file changed, 44 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b1d282f..1f74089 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -77,20 +77,46 @@ struct ipq {
 	struct inet_peer *peer;
 };
 
-#define IPFRAG_ECN_CLEAR  0x01 /* one frag had INET_ECN_NOT_ECT */
-#define IPFRAG_ECN_SET_CE 0x04 /* one frag had INET_ECN_CE */
+/* RFC 3168 support :
+ * We want to check ECN values of all fragments, do detect invalid combinations.
+ * In ipq->ecn, we store the OR value of each ip4_frag_ecn() fragment value.
+ */
+enum {
+	IPFRAG_ECN_NOT_ECT	= 0x01, /* one frag had ECN_NOT_ECT */
+	IPFRAG_ECN_ECT_1	= 0x02, /* one frag had ECN_ECT_1 */
+	IPFRAG_ECN_ECT_0	= 0x04, /* one frag had ECN_ECT_0 */
+	IPFRAG_ECN_CE		= 0x08, /* one frag had ECN_CE */
+};
 
 static inline u8 ip4_frag_ecn(u8 tos)
 {
-	tos = (tos & INET_ECN_MASK) + 1;
-	/*
-	 * After the last operation we have (in binary):
-	 * INET_ECN_NOT_ECT => 001
-	 * INET_ECN_ECT_1   => 010
-	 * INET_ECN_ECT_0   => 011
-	 * INET_ECN_CE      => 100
-	 */
-	return (tos & 2) ? 0 : tos;
+	return 1 << (tos & INET_ECN_MASK);
+}
+
+/* Given the OR values of all fragments, apply RFC 3168 5.3 requirements
+ * Return : -1 if frame should be dropped.
+ *           >= 0 value, to be ORed in to final iph->tos field
+ */
+static inline int ip4_frag_ecn_fold(u8 ecn)
+{
+	switch (ecn) {
+	/* If same ECN combination was observed on all fragments, do nothing */
+	case IPFRAG_ECN_NOT_ECT:
+	case IPFRAG_ECN_ECT_1:
+	case IPFRAG_ECN_ECT_0:
+	case IPFRAG_ECN_CE:
+	/* if a ECT_1 ECT_0 combination was observed, do nothing as well */
+	case IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1:
+		return 0;
+	/* at least one fragment had CE, and others ECT_0 or ECT_1 */
+	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0:
+	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1:
+	case IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1:
+		return INET_ECN_CE;
+	/* other combinations are invalid : drop frame */
+	default:
+		return -1;
+	}
 }
 
 static struct inet_frags ip4_frags;
@@ -524,9 +550,15 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	int len;
 	int ihlen;
 	int err;
+	int ecn;
 
 	ipq_kill(qp);
 
+	ecn = ip4_frag_ecn_fold(qp->ecn);
+	if (unlikely(ecn == -1)) {
+		err = -EINVAL;
+		goto out_fail;
+	}
 	/* Make the one we just received the head. */
 	if (prev) {
 		head = prev->next;
@@ -605,17 +637,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	iph = ip_hdr(head);
 	iph->frag_off = 0;
 	iph->tot_len = htons(len);
-	/* RFC3168 5.3 Fragmentation support
-	 * If one fragment had INET_ECN_NOT_ECT,
-	 *	reassembled frame also has INET_ECN_NOT_ECT
-	 * Elif one fragment had INET_ECN_CE
-	 *	reassembled frame also has INET_ECN_CE
-	 */
-	if (qp->ecn & IPFRAG_ECN_CLEAR)
-		iph->tos &= ~INET_ECN_MASK;
-	else if (qp->ecn & IPFRAG_ECN_SET_CE)
-		iph->tos |= INET_ECN_CE;
-
+	iph->tos |= ecn;
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	qp->q.fragments_tail = NULL;


