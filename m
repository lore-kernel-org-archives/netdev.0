From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix
Date: Wed, 06 Feb 2008 09:33:42 -0800
Message-ID: <20080206173342.21CDF8E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
 <47A9EA42.3080800@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lanconelli.claudio@eptar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.sbc.mail.sp1.yahoo.com ([69.147.64.90]:44907 "HELO
	smtp117.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754328AbYBFRdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 12:33:43 -0500
In-Reply-To: <47A9EA42.3080800@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Prevent unaligned packet oops on enc28j60 packet RX.
>
> How can I reproduce the unaligned packet oops?

Use any architecture that doesn't support unaligned accesses
in kernel space.  I used AVR32 for this (it's got a pretty
solid SPI master controller driver). ARM isn't immune either,
and there are others.  That's why NET_IP_ALIGN exists.


> Did you use any utilities to force this condition?

"ping" ... the first RX packet oopsed.


> Can you split the patch in 2 parts, unaligned rx and power save?

Below is: unaligned access.

- Dave


=========== CUT HERE
Prevent oops on enc28j60 packet RX:  make sure buffers are aligned.
Not all architectures support unaligned accesses in kernel space.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/enc28j60.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/net/enc28j60.c	2008-02-06 09:29:00.000000000 -0800
+++ b/drivers/net/enc28j60.c	2008-02-06 09:30:03.000000000 -0800
@@ -900,7 +900,7 @@ static void enc28j60_hw_rx(struct net_de
 		if (RSV_GETBIT(rxstat, RSV_LENCHECKERR))
 			ndev->stats.rx_frame_errors++;
 	} else {
-		skb = dev_alloc_skb(len);
+		skb = dev_alloc_skb(len + NET_IP_ALIGN);
 		if (!skb) {
 			if (netif_msg_rx_err(priv))
 				dev_err(&ndev->dev,
@@ -908,6 +908,7 @@ static void enc28j60_hw_rx(struct net_de
 			ndev->stats.rx_dropped++;
 		} else {
 			skb->dev = ndev;
+			skb_reserve(skb, NET_IP_ALIGN);
 			/* copy the packet from the receive buffer */
 			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
 					len, skb_put(skb, len));
