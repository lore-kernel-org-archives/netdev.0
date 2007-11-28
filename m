From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] [TCP]: Two fixes to new sacktag code
Date: Wed, 28 Nov 2007 16:19:36 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711281614500.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-730418246-1196259576=:18529"
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33587 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754618AbXK1OTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 09:19:38 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-730418246-1196259576=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


1) Skip condition used to be wrong way around which made SACK
processing very broken, missed many blocks because of that.

2) Use highest_sack advancement only if some skbs are already
sacked because otherwise tcp_write_queue_next may move things
too far (occurs mainly with GSO). The other similar advancement
is not problem because highest_sack was previosly put to point
a sacked skb.

These problems were located because of problem report from Matt
Mathis <mathis@psc.edu>.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

...I verified result from time-seq graphs now, they are right in my simple 
test case.

In case there's a rebase of net-2.6.25, it might be good to just combine 
173b7ae366ac3f69b3030a6ab308cf3fa3ab751a ([TCP]: Correct DSACK check 
placing) and this one to the a1598ba3339ebeeb0a959141a122cbe69956e713 
([TCP]: Rewrite SACK block processing & sack_recv_cache use), they just 
fix its bugs.

 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0cee3dc..cadde8b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1384,7 +1384,7 @@ static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct sock *sk,
 		if (skb == tcp_send_head(sk))
 			break;
 
-		if (before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
+		if (!before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
 			break;
 	}
 	return skb;
@@ -1575,7 +1575,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			continue;
 		}
 
-		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
+		if (tp->sacked_out && after(start_seq, tcp_highest_sack_seq(tp))) {
 			skb = tcp_write_queue_next(sk, tp->highest_sack);
 			fack_count = tp->fackets_out;
 		}
-- 
1.5.0.6

---696243703-730418246-1196259576=:18529--
