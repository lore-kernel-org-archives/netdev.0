From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 (v2)] [TCP]: Two fixes to new sacktag code
Date: Wed, 28 Nov 2007 18:52:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711281847360.18529@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0711281614500.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2127161314-1196268771=:18529"
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50981 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbXK1Qwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 11:52:53 -0500
In-Reply-To: <Pine.LNX.4.64.0711281614500.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2127161314-1196268771=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 28 Nov 2007, Ilpo Järvinen wrote:

> @@ -1575,7 +1575,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  			continue;
>  		}
>  
> -		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
> +		if (tp->sacked_out && after(start_seq, tcp_highest_sack_seq(tp))) {

In this v2, of this patch I'll put !before back here instead, change 
to after is unnecessary here, checking that a sacked skb exists is
enough to avoid skipping in the problematic head case.

--

[PATCH] [TCP]: Two fixes to new sacktag code

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
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0cee3dc..9f12541 100644
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
+		if (tp->sacked_out && !before(start_seq, tcp_highest_sack_seq(tp))) {
 			skb = tcp_write_queue_next(sk, tp->highest_sack);
 			fack_count = tp->fackets_out;
 		}
-- 
1.5.0.6

---696243703-2127161314-1196268771=:18529--
