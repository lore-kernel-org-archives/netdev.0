From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: KERNEL: assertion ((int)tp->sacked_out >= 0) failed at
 net/ipv4/tcp_input.c (2626)
Date: Wed, 28 Mar 2007 16:24:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703281543460.14473@kivilampi-30.cs.helsinki.fi>
References: <460A5988.2050403@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1312850039-1175087894=:14473"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51941 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbXC1NYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 09:24:42 -0400
In-Reply-To: <460A5988.2050403@trash.net>
Content-ID: <Pine.LNX.4.64.0703281622420.14473@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1312850039-1175087894=:14473
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0703281620001.14473@kivilampi-30.cs.helsinki.fi>

On Wed, 28 Mar 2007, Patrick McHardy wrote:

> I got this warning with the current net-2.6.22 tree:
> 
> KERNEL: assertion ((int)tp->sacked_out >= 0) failed at
> net/ipv4/tcp_input.c (2626)
> Leak s=4294967292 3
> 
> Can't say what exactly triggered it.

It seems I'm being guilty to this one, Dave please apply to net-2.6.22 
(besides this I think the tcp_sync_left_out should be changed but I'll 
prepare a patch for that later). Btw, how should this kind of email with 
some non-patch description+patch be formatted?).

[PATCH] [TCP]: Timedout loop must skip SACKed skbs too while marking

Marking skb with both S and L is invalid, and that could easily
happen in the timedout loop. Later on the tcp_sync_left_out
reduces sacked_out if lost_out + sacked_out > packets_out and
then eventually sacked_out underflows triggering a debug trap in
tcp_clean_rtx_queue.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d116887..7a59ffe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1777,7 +1777,8 @@ static void tcp_timedout_mark_forward(st
 		if (skb == tcp_send_head(sk) || !tcp_skb_timedout(sk, skb))
 			break;
 		/* Could be lost already from a previous timedout check */
-		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
+		if (!(TCP_SKB_CB(skb)->sacked &
+		     (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			tp->lost_out += tcp_skb_pcount(skb);
 			tcp_verify_retransmit_hint(tp, skb);
-- 
1.4.2
---696243703-1312850039-1175087894=:14473--
