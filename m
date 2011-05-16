From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 20:37:37 +0200
Message-ID: <1305571057.2581.2.camel@edumazet-laptop>
References: <201105141938.28344.v13@v13.gr>
	 <1305464176.3120.113.camel@edumazet-laptop>
	 <1305466542.3120.129.camel@edumazet-laptop> <201105151808.39231.v13@v13.gr>
	 <1305475310.3120.146.camel@edumazet-laptop>
	 <1305566204.2898.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stefanos Harhalakis <v13@v13.gr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43697 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab1EPShk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 14:37:40 -0400
Received: by wya21 with SMTP id 21so3658852wya.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 11:37:39 -0700 (PDT)
In-Reply-To: <1305566204.2898.49.camel@edumazet-laptop>
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
v2 : Use a table instead of a switch()

 net/ipv4/ip_fragment.c |   60 ++++++++++++++++++++++++---------------
 1 file changed, 38 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b1d282f..9e1458d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -77,22 +77,42 @@ struct ipq {
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
 }
 
+/* Given the OR values of all fragments, apply RFC 3168 5.3 requirements
+ * Value : 0xff if frame should be dropped.
+ *         0 or INET_ECN_CE value, to be ORed in to final iph->tos field
+ */
+static const u8 ip4_frag_ecn_table[16] = {
+	/* at least one fragment had CE, and others ECT_0 or ECT_1 */
+	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0]			= INET_ECN_CE,
+	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1]			= INET_ECN_CE,
+	[IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1]	= INET_ECN_CE,
+
+	/* invalid combinations : drop frame */
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_0] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_1] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_1] = 0xff,
+	[IPFRAG_ECN_NOT_ECT | IPFRAG_ECN_CE | IPFRAG_ECN_ECT_0 | IPFRAG_ECN_ECT_1] = 0xff,
+};
+
 static struct inet_frags ip4_frags;
 
 int ip_frag_nqueues(struct net *net)
@@ -524,9 +544,15 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	int len;
 	int ihlen;
 	int err;
+	u8 ecn;
 
 	ipq_kill(qp);
 
+	ecn = ip4_frag_ecn_table[qp->ecn];
+	if (unlikely(ecn == 0xff)) {
+		err = -EINVAL;
+		goto out_fail;
+	}
 	/* Make the one we just received the head. */
 	if (prev) {
 		head = prev->next;
@@ -605,17 +631,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
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


