From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Tue, 13 Nov 2007 23:35:39 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
References: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
 <Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-924179380-1194988972=:3997"
Cc: Netdev <netdev@vger.kernel.org>
To: Chazarain Guillaume <guichaz@yahoo.fr>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49301 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760193AbXKMVfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 16:35:44 -0500
In-Reply-To: <Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0711132324230.3997@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-924179380-1194988972=:3997
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0711132324231.3997@kivilampi-30.cs.helsinki.fi>

On Mon, 12 Nov 2007, Ilpo Järvinen wrote:

> Yeah, it's more likely a miscount somewhere rather than corruption but 
> that wasn't obvious from the first mail...
> 
> ...but alas, I haven't yet been able to come up with any theory on how 
> a miscount could occur....

Cancel that, first idea is presented in this patch (not sure if it's one 
that fixes your symptoms, but at least it seems a potential place where 
such thing could happen, no idea what events can cause that to occur 
though :-():

--
[PATCH] [TCP] FRTO: Plug potential LOST-bit leak

It might be possible that, in some extreme scenario that
I just cannot now construct in my mind, end_seq <=
frto_highmark check does not match causing the lost_out
and LOST bits become out-of-sync due to clearing and
recounting in the loop.

This may fix LOST-bit leak reported by Chazarain Guillaume
<guichaz@yahoo.fr>.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 23a0092..cc358d4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1706,6 +1706,8 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
+
+		TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		/*
 		 * Count the retransmission made on RTO correctly (only when
 		 * waiting for the first ACK and did not get it)...
@@ -1719,7 +1721,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 		} else {
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
 				tp->undo_marker = 0;
-			TCP_SKB_CB(skb)->sacked &= ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
+			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 		}
 
 		/* Don't lost mark skbs that were fwd transmitted after RTO */
-- 
1.5.0.6

---696243703-924179380-1194988972=:3997--
