From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net [BUG-FIX][PATCH 1/1] udplite: fast-path computation of
 checksum coverage
Date: Mon, 17 Oct 2011 15:34:47 -0600
Message-ID: <20111017213447.GA4061@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36621 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754147Ab1JQVfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 17:35:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

can you please consider the fix below -- the checksum coverage in UDP-Lite had been broken for
over half a year; then reported by Thomas. I have tested the patch below in various scenarios
with IPv4 and IPv6, on localhost, and between multiple hosts.

Gerrit

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

udplite: fast-path computation of checksum coverage

Commit 903ab86d195cca295379699299c5fc10beba31c7 of 1 March this year ("udp: Add
lockless transmit path") introduced a new fast TX path that broke the checksum
coverage computation of UDP-lite, which so far depended on up->len (only set
if the socket is locked and 0 in the fast path).

Fixed by providing both fast- and slow-path computation of checksum coverage.
The latter can be removed when UDP(-lite)v6 also uses a lockless transmit path.
 
Reported-by: Thomas Volkert <thomas@homer-conferencing.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/net/udplite.h |   63 ++++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 32 deletions(-)

--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -66,40 +66,34 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
 	return 0;
 }
 
-static inline int udplite_sender_cscov(struct udp_sock *up, struct udphdr *uh)
+/* Slow-path computation of checksum. Socket is locked. */
+static inline __wsum udplite_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 {
+	const struct udp_sock *up = udp_sk(skb->sk);
 	int cscov = up->len;
+	__wsum csum = 0;
 
-	/*
-	 * Sender has set `partial coverage' option on UDP-Lite socket
-	 */
-	if (up->pcflag & UDPLITE_SEND_CC)    {
+	if (up->pcflag & UDPLITE_SEND_CC) {
+		/*
+		 * Sender has set `partial coverage' option on UDP-Lite socket.
+		 * The special case "up->pcslen == 0" signifies full coverage.
+		 */
 		if (up->pcslen < up->len) {
-		/* up->pcslen == 0 means that full coverage is required,
-		 * partial coverage only if  0 < up->pcslen < up->len */
-			if (0 < up->pcslen) {
-			       cscov = up->pcslen;
-			}
-			uh->len = htons(up->pcslen);
+			if (0 < up->pcslen)
+				cscov = up->pcslen;
+			udp_hdr(skb)->len = htons(up->pcslen);
 		}
-	/*
-	 * NOTE: Causes for the error case  `up->pcslen > up->len':
-	 *        (i)  Application error (will not be penalized).
-	 *       (ii)  Payload too big for send buffer: data is split
-	 *             into several packets, each with its own header.
-	 *             In this case (e.g. last segment), coverage may
-	 *             exceed packet length.
-	 *       Since packets with coverage length > packet length are
-	 *       illegal, we fall back to the defaults here.
-	 */
+		/*
+		 * NOTE: Causes for the error case  `up->pcslen > up->len':
+		 *        (i)  Application error (will not be penalized).
+		 *       (ii)  Payload too big for send buffer: data is split
+		 *             into several packets, each with its own header.
+		 *             In this case (e.g. last segment), coverage may
+		 *             exceed packet length.
+		 *       Since packets with coverage length > packet length are
+		 *       illegal, we fall back to the defaults here.
+		 */
 	}
-	return cscov;
-}
-
-static inline __wsum udplite_csum_outgoing(struct sock *sk, struct sk_buff *skb)
-{
-	int cscov = udplite_sender_cscov(udp_sk(sk), udp_hdr(skb));
-	__wsum csum = 0;
 
 	skb->ip_summed = CHECKSUM_NONE;     /* no HW support for checksumming */
 
@@ -115,16 +109,21 @@ static inline __wsum udplite_csum_outgoing(struct sock *sk, struct sk_buff *skb)
 	return csum;
 }
 
+/* Fast-path computation of checksum. Socket may not be locked. */
 static inline __wsum udplite_csum(struct sk_buff *skb)
 {
-	struct sock *sk = skb->sk;
-	int cscov = udplite_sender_cscov(udp_sk(sk), udp_hdr(skb));
+	const struct udp_sock *up = udp_sk(skb->sk);
 	const int off = skb_transport_offset(skb);
-	const int len = skb->len - off;
+	int len = skb->len - off;
 
+	if ((up->pcflag & UDPLITE_SEND_CC) && up->pcslen < len) {
+		if (0 < up->pcslen)
+			len = up->pcslen;
+		udp_hdr(skb)->len = htons(up->pcslen);
+	}
 	skb->ip_summed = CHECKSUM_NONE;     /* no HW support for checksumming */
 
-	return skb_checksum(skb, off, min(cscov, len), 0);
+	return skb_checksum(skb, off, len, 0);
 }
 
 extern void	udplite4_register(void);
