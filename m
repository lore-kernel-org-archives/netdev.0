From: David Brownell <david-b@pacbell.net>
Subject: [RE(*2)SEND/patch 2.6.25-rc2-git] net/enc28j60: oops fix
Date: Tue, 4 Mar 2008 17:17:32 -0800
Message-ID: <200803041717.32868.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <20080206173342.21CDF8E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47AADC51.8060401@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:47948 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1765171AbYCEBRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 20:17:36 -0500
In-Reply-To: <47AADC51.8060401@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent oops on enc28j60 packet RX:  make sure buffers are aligned.
Not all architectures support unaligned accesses in kernel space.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
---
Seems the enc28j60 patches didn't get picked up, ergo (2x) resend...
they're not in net-2.6.git, even this oops fix (which I'd expect
would be prioritized for 2.6.25)

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
