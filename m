From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [TCP]: Process DSACKs that reside within a SACK block
Date: Wed, 31 Oct 2007 11:48:31 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0710311136200.16864@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1752703479-1193824111=:16864"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60779 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbXJaJsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 05:48:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1752703479-1193824111=:16864
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


DSACK inside another SACK block were missed if start_seq of DSACK
was larger than SACK block's because sorting prioritizes full
processing of the SACK block before DSACK. After SACK block
sorting situation is like this:

             SSSSSSSSS
                  D
                        SSSSSS
                               SSSSSSS

Because write_queue is walked in-order, when the first SACK block
has been processed, TCP is already past the skb for which the
DSACK arrived and we haven't taught it to backtrack (nor should
we), so TCP just continues processing by going to the next SACK
block after the DSACK (if any).

Whenever such DSACK is present, do an embedded checking during
the previous SACK block.

If the DSACK is below snd_una, there won't be overlapping SACK
block, and thus no problem in that case. Also if start_seq of
the DSACK is equal to the actual block, it will be processed
first.

Tested this by using netem to duplicate 15% of packets, and
by printing SACK block when found_dup_sack is true and the 
selected skb in the dup_sack = 1 branch (if taken):

  SACK block 0: 4344-5792 (relative to snd_una 2019137317)
  SACK block 1: 4344-5792 (relative to snd_una 2019137317) 

equal start seqnos => next_dup = 0, dup_sack = 1 won't occur...

  SACK block 0: 5792-7240 (relative to snd_una 2019214061)
  SACK block 1: 2896-7240 (relative to snd_una 2019214061)
  DSACK skb match 5792-7240 (relative to snd_una)

...and next_dup = 1 case (after the not shown start_seq sort),
went to dup_sack = 1 branch.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 69d8c38..4d72781 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1330,12 +1330,15 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		cached_fack_count = 0;
 	}
 
-	for (i=0; i<num_sacks; i++, sp++) {
+	for (i = 0; i < num_sacks; i++) {
 		struct sk_buff *skb;
 		__u32 start_seq = ntohl(sp->start_seq);
 		__u32 end_seq = ntohl(sp->end_seq);
 		int fack_count;
 		int dup_sack = (found_dup_sack && (i == first_sack_index));
+		int next_dup = (found_dup_sack && (i+1 == first_sack_index));
+
+		sp++;
 
 		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq)) {
 			if (dup_sack) {
@@ -1361,7 +1364,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			flag |= FLAG_DATA_LOST;
 
 		tcp_for_write_queue_from(skb, sk) {
-			int in_sack;
+			int in_sack = 0;
 			u8 sacked;
 
 			if (skb == tcp_send_head(sk))
@@ -1380,7 +1383,23 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 				break;
 
-			in_sack = tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+			dup_sack = (found_dup_sack && (i == first_sack_index));
+
+			/* Due to sorting DSACK may reside within this SACK block! */
+			if (next_dup) {
+				u32 dup_start = ntohl(sp->start_seq);
+				u32 dup_end = ntohl(sp->end_seq);
+
+				if (before(TCP_SKB_CB(skb)->seq, dup_end)) {
+					in_sack = tcp_match_skb_to_sack(sk, skb, dup_start, dup_end);
+					if (in_sack > 0)
+						dup_sack = 1;
+				}
+			}
+
+			/* DSACK info lost if out-of-mem, try SACK still */
+			if (in_sack <= 0)
+				in_sack = tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
 			if (in_sack < 0)
 				break;
 
-- 
1.5.0.6

---696243703-1752703479-1193824111=:16864--
