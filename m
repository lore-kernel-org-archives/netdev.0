From: "Arce, Abraham" <x0066660@ti.com>
Subject: RE: NULL Pointer Deference: NFS & Telnet
Date: Tue, 7 Sep 2010 16:43:49 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A5304509AF8DA@dlee03.ent.ti.com>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
	 <1274851741.25136.16.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
 <1274906933.2542.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
	"Ha, Tristram" <Tristram.Ha@micrel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:45608 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab0IGVny convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:43:54 -0400
In-Reply-To: <1274906933.2542.17.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, David,

> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]

[..]

> > By increasing the allocation length of our rx skbuff the corruption issue is
> fixed... I have increased it by 2... Were we writing outside our boundaries of
> skb data?
> >
>
> Yes that makes sense, nr_frag is right after the packet (padded to L1
> cache size)
>
> But please do the correct allocation ?
>
> Also, we dont need FCS ?

FCS -> CRC is enable in hardware, under ks8851_net_open()

 TXCR_TXCRC | /* add CRC */

How about the following patch? I am using added helper function:
netdev_alloc_skb_ip_align()

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b4fb07a..df70a83 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -503,17 +503,14 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
                ks8851_wrreg16(ks, KS_RXQCR,
                               ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);

-               if (rxlen > 0) {
-                       skb = netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
+               if (rxlen > 4) {
+                       rxlen -= 4;
+                       skb = netdev_alloc_skb_ip_align(ks->netdev, 2 + rxlen);
                        if (!skb) {
                                /* todo - dump frame and move on */
                        }

-                       /* two bytes to ensure ip is aligned, and four bytes
-                        * for the status header and 4 bytes of garbage */
-                       skb_reserve(skb, 2 + 4 + 4);
-
-                       rxpkt = skb_put(skb, rxlen - 4) - 8;
+                       rxpkt = skb_put(skb, rxlen) - 8;

                        /* align the packet length to 4 bytes, and add 4 bytes
                         * as we're getting the rx status header as well */
@@ -526,7 +523,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
                        netif_rx(skb);

                        ks->netdev->stats.rx_packets++;
-                       ks->netdev->stats.rx_bytes += rxlen - 4;
+                       ks->netdev->stats.rx_bytes += rxlen;
                }

                ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);

Best Regards
Abraham
