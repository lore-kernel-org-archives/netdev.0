From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP] MIB: Fine-tune reordered ACK's SACK block counting
 more
Date: Wed, 26 Sep 2007 17:07:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709261653110.5141@kivilampi-30.cs.helsinki.fi>
References: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070925.224711.26514452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-419636326-1190815624=:5141"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49264 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758816AbXIZOHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 10:07:06 -0400
In-Reply-To: <20070925.224711.26514452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-419636326-1190815624=:5141
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 25 Sep 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 24 Sep 2007 12:04:07 +0300
> 
> > In case of ACK reordering, the SACK block might be valid in it's
> > time but is already obsoleted since we've received another kind
> > of confirmation about arrival of the segments through snd_una
> > advancement of an earlier packet.
> > 
> > I didn't bother to build distinguishing of valid and invalid
> > SACK blocks but simply made reordered SACK blocks that are too
> > old always not counted regardless of their "real" validity which
> > could be determined by using the ack field of the reordered
> > packet (won't be significant IMHO).
> > 
> > DSACKs can very well be considered useful even in this situation,
> > so won't do any of this for them.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> This looks fine to me, applied.
> 
> If the skipped case is interesting we can add another MIB
> stat for it :-)

Hmm, thought a bit more about it... How about this then? No additional 
counter. Compile tested. Not that I see a large benefit from it, in theory 
could help logging in some malicious attempt cases; we safely discarded in 
such case anyway... ...of course if somebody is paranoid enough one might 
rejoice in it more than I do... :-) Buggy cases will very likely show up 
regardless this reordering corner-case.


From: =?ISO-8859-1?q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Date: Wed, 26 Sep 2007 14:17:12 +0300
Subject: [PATCH] [TCP] MIB: Fine-tune reordered ACK's SACK block counting more

Check the SACK block against the state that TCP was in at the
time of that ACK. Not really since we can summon just snd_una
back and not snd_nxt but that shouldn't be a problem. Reused
checking code which avoids adding other nasty wrap, etc. holes.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 259f517..95c8a4a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1063,7 +1063,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
  * be used as an exaggerated estimate.
  */
 static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
-				  u32 start_seq, u32 end_seq)
+				  u32 start_seq, u32 end_seq, u32 snd_una)
 {
 	/* Too far in future, or reversed (interpretation is ambiguous) */
 	if (after(end_seq, tp->snd_nxt) || !before(start_seq, end_seq))
@@ -1076,14 +1076,14 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
 	/* In outstanding window? ...This is valid exit for DSACKs too.
 	 * start_seq == snd_una is non-sensical (see comments above)
 	 */
-	if (after(start_seq, tp->snd_una))
+	if (after(start_seq, snd_una))
 		return 1;
 
 	if (!is_dsack || !tp->undo_marker)
 		return 0;
 
 	/* ...Then it's D-SACK, and must reside below snd_una completely */
-	if (!after(end_seq, tp->snd_una))
+	if (!after(end_seq, snd_una))
 		return 0;
 
 	if (!before(start_seq, tp->undo_marker))
@@ -1244,16 +1244,21 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		int fack_count;
 		int dup_sack = (found_dup_sack && (i == first_sack_index));
 
-		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq)) {
+		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq,
+					    tp->snd_una)) {
 			if (dup_sack) {
 				if (!tp->undo_marker)
 					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
 				else
 					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
 			} else {
-				/* Don't count olds caused by ACK reordering */
+				/* Don't count old SACK blocks caused by ACK
+				 * reordering if it was valid back then
+				 */
 				if ((TCP_SKB_CB(ack_skb)->ack_seq != tp->snd_una) &&
-				    !after(end_seq, tp->snd_una))
+				    tcp_is_sackblock_valid(tp, dup_sack,
+							   start_seq, end_seq,
+							   TCP_SKB_CB(ack_skb)->ack_seq))
 					continue;
 				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
 			}
-- 
1.5.0.6

---696243703-419636326-1190815624=:5141--
