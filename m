From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] [TCP]: Correct DSACK check placing
Date: Fri, 16 Nov 2007 17:29:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711161724050.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1787533568-1195226986=:24866"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50081 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbXKPP3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 10:29:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1787533568-1195226986=:24866
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Previously one of the in-block skip branches was missing it.

Also, drop it from tail-fully-processed case because the next
iteration will do exactly the same thing, i.e., process the
SACK block that contains the DSACK information.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cd6924e..dae000b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1554,20 +1554,15 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			}
 
 			/* Rest of the block already fully processed? */
-			if (!after(end_seq, cache->end_seq)) {
-				skb = tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
-							       &fack_count, &reord, &flag);
+			if (!after(end_seq, cache->end_seq))
 				goto advance_sp;
-			}
+
+			skb = tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
+						       &fack_count, &reord, &flag);
 
 			/* ...tail remains todo... */
 			if (TCP_SKB_CB(tp->highest_sack)->end_seq == cache->end_seq) {
-				/* ...but better entrypoint exists! Check that DSACKs are
-				 * properly accounted while skipping here
-				 */
-				tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
-							 &fack_count, &reord, &flag);
-
+				/* ...but better entrypoint exists! */
 				skb = tcp_write_queue_next(sk, tp->highest_sack);
 				fack_count = tp->fackets_out;
 				cache++;
-- 
1.5.0.6

---696243703-1787533568-1195226986=:24866--
