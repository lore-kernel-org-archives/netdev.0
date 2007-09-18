From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] [PPP] L2TP: Fix skb handling in pppol2tp_recv_core
Date: Tue, 18 Sep 2007 20:08:24 +0800
Message-ID: <E1IXbsO-0002Ph-00@gondolin.me.apana.org.au>
References: <20070918120438.GA9121@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1031 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751740AbXIRMI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 08:08:28 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IXbsP-0002XK-BN
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 22:08:25 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IXbsO-0002Ph-00
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 20:08:24 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] L2TP: Fix skb handling in pppol2tp_recv_core

The function pppol2tp_recv_core doesn't handle non-linear packets properly.
It also fails to check the remote offset field.

This patch fixes these problems.  It also removes an unnecessary check on
the UDP header which has already been performed by the UDP layer.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppol2tp.c |   44 ++++++++++++++++++++++++--------------------
 1 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index ed8ead4..440e190 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -491,44 +491,46 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 	u16 hdrflags;
 	u16 tunnel_id, session_id;
 	int length;
-	struct udphdr *uh;
+	int offset;
 
 	tunnel = pppol2tp_sock_to_tunnel(sock);
 	if (tunnel == NULL)
 		goto error;
 
+	/* UDP always verifies the packet length. */
+	__skb_pull(skb, sizeof(struct udphdr));
+
 	/* Short packet? */
-	if (skb->len < sizeof(struct udphdr)) {
+	if (!pskb_may_pull(skb, 12)) {
 		PRINTK(tunnel->debug, PPPOL2TP_MSG_DATA, KERN_INFO,
 		       "%s: recv short packet (len=%d)\n", tunnel->name, skb->len);
 		goto error;
 	}
 
 	/* Point to L2TP header */
-	ptr = skb->data + sizeof(struct udphdr);
+	ptr = skb->data;
 
 	/* Get L2TP header flags */
 	hdrflags = ntohs(*(__be16*)ptr);
 
 	/* Trace packet contents, if enabled */
 	if (tunnel->debug & PPPOL2TP_MSG_DATA) {
+		length = min(16u, skb->len);
+		if (!pskb_may_pull(skb, length))
+			goto error;
+
 		printk(KERN_DEBUG "%s: recv: ", tunnel->name);
 
-		for (length = 0; length < 16; length++)
-			printk(" %02X", ptr[length]);
+		offset = 0;
+		do {
+			printk(" %02X", ptr[offset]);
+		} while (++offset < length);
+
 		printk("\n");
 	}
 
 	/* Get length of L2TP packet */
-	uh = (struct udphdr *) skb_transport_header(skb);
-	length = ntohs(uh->len) - sizeof(struct udphdr);
-
-	/* Too short? */
-	if (length < 12) {
-		PRINTK(tunnel->debug, PPPOL2TP_MSG_DATA, KERN_INFO,
-		       "%s: recv short L2TP packet (len=%d)\n", tunnel->name, length);
-		goto error;
-	}
+	length = skb->len;
 
 	/* If type is control packet, it is handled by userspace. */
 	if (hdrflags & L2TP_HDRFLAG_T) {
@@ -606,7 +608,6 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 			       "%s: recv data has no seq numbers when required. "
 			       "Discarding\n", session->name);
 			session->stats.rx_seq_discards++;
-			session->stats.rx_errors++;
 			goto discard;
 		}
 
@@ -625,7 +626,6 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 			       "%s: recv data has no seq numbers when required. "
 			       "Discarding\n", session->name);
 			session->stats.rx_seq_discards++;
-			session->stats.rx_errors++;
 			goto discard;
 		}
 
@@ -634,10 +634,14 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 	}
 
 	/* If offset bit set, skip it. */
-	if (hdrflags & L2TP_HDRFLAG_O)
-		ptr += 2 + ntohs(*(__be16 *) ptr);
+	if (hdrflags & L2TP_HDRFLAG_O) {
+		offset = ntohs(*(__be16 *)ptr);
+		skb->transport_header += 2 + offset;
+		if (!pskb_may_pull(skb, skb_transport_offset(skb) + 2))
+			goto discard;
+	}
 
-	skb_pull(skb, ptr - skb->data);
+	__skb_pull(skb, skb_transport_offset(skb));
 
 	/* Skip PPP header, if present.	 In testing, Microsoft L2TP clients
 	 * don't send the PPP header (PPP header compression enabled), but
@@ -673,7 +677,6 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 			 */
 			if (PPPOL2TP_SKB_CB(skb)->ns != session->nr) {
 				session->stats.rx_seq_discards++;
-				session->stats.rx_errors++;
 				PRINTK(session->debug, PPPOL2TP_MSG_SEQ, KERN_DEBUG,
 				       "%s: oos pkt %hu len %d discarded, "
 				       "waiting for %hu, reorder_q_len=%d\n",
@@ -698,6 +701,7 @@ static int pppol2tp_recv_core(struct sock *sock, struct sk_buff *skb)
 	return 0;
 
 discard:
+	session->stats.rx_errors++;
 	kfree_skb(skb);
 	sock_put(session->sock);
 
