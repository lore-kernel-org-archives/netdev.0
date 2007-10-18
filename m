From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Add highest_sack_end_seq check back to lost_retrans
 call
Date: Thu, 18 Oct 2007 12:40:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710181214140.3767@kivilampi-30.cs.helsinki.fi>
References: <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1192102867248-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071011.173622.09942622.davem@davemloft.net> <20071018.125045.90803775.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1294290608-1192700406=:3767"
Cc: David Miller <davem@davemloft.net>, y-kodama@aist.go.jp,
	Netdev <netdev@vger.kernel.org>
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42343 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755018AbXJRJkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:40:10 -0400
In-Reply-To: <20071018.125045.90803775.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1294290608-1192700406=:3767
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 18 Oct 2007, TAKANO Ryousei wrote:

> From: David Miller <davem@davemloft.net>
> Subject: Re: [PATCH 7/7] [TCP]: Limit processing lost_retrans loop to work-to-do cases
> Date: Thu, 11 Oct 2007 17:36:22 -0700 (PDT)
> 
> > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Thu, 11 Oct 2007 14:41:07 +0300
> > 
> > > This addition of lost_retrans_low to tcp_sock might be
> > > unnecessary, it's not clear how often lost_retrans worker is
> > > executed when there wasn't work to do.
> > > 
> > > Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
> > > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > 
> > Applied.
> 
> > +	    after(highest_sack_end_seq, tp->lost_retrans_low) &&
>
> This limit degrades the performance of my test case described before,

Thanks for testing.... Btw, just noticed that lost_retrans_low addition 
patch incorrectly dropped check for highest_sack_end_seq (probably due to 
incorrect resolution from my side at some point of development of those 
two patches as I added that check later on when realized it's necessary), 
patching that below... Since it causes zero received_upto in 
tcp_mark_lost_retrans, some RETRANS bits got cleared unintentionally
because of that.

> since it misses opportunities of detecting loss of retransmitted packets.

Do you have an idea how it does that except the problem now being fixed?
The lost_retrans_low was supposed to contain the minimum 
TCP_SKB_CB(skb)->ack_seq of those packets that hav TCPCB_SACKED_RETRANS 
set, so if the condition won't match, there shouldn't be any misses. Do 
you think there's something wrong in that approach?

The point of lost_retrans_low is to limit walking in retrans queue to two 
cases:

- There's at least one skb with SACKED_RETRANS to clear (except perhaps 
some corner cases where that specific skb got DSACKed in between and the 
R-bit was therefore cleared).

 or

- New lost_retrans_low has to calculated (should only occur if snd_una 
advanced past it and there are still some retransmissions, not too sure 
if that can occur, and that won't be very likely case anyway).


> "no limit" does as follows:
>         if (tp->retrans_out && highest_sack_end_seq &&
>             icsk->icsk_ca_state == TCP_CA_Recovery)
>                 flag |= tcp_mark_lost_retrans(sk, highest_sack_end_seq);

Having that highest_sack_end_seq there probably solved the problem. Yet 
it won't be good in performance wise like that because many unnecessary 
walks would occur during CA_Recovery, which all are prone to induce some 
cache misses.


--

[PATCH] [TCP]: Add highest_sack_end_seq check back to lost_retrans call

This was unintentionally dropped (probably due to incorrect
resolution from my side at some point of development of those
two patches as I added that check later on when realized it's
necessary). There won't be anything to mark if SACKs didn't
advance.

It causes passing of zero received_upto to tcp_mark_lost_retrans
which confuses after relations within the marker loop causing
incorrect TCPCB_SACKED_RETRANS clearing.

This problem was noticed because of a performance report from
TAKANO Ryousei <takano@axe-inc.co.jp>.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0f00966..c3c0183 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1489,7 +1489,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		}
 	}
 
-	if (tp->retrans_out &&
+	if (tp->retrans_out && highest_sack_end_seq &&
 	    after(highest_sack_end_seq, tp->lost_retrans_low) &&
 	    icsk->icsk_ca_state == TCP_CA_Recovery)
 		flag |= tcp_mark_lost_retrans(sk, highest_sack_end_seq);
-- 
1.5.0.6

---696243703-1294290608-1192700406=:3767--
