From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: Fix a TX IRQ causing BUG() in PC300 and PCI200SYN drivers.
Date: Sun, 12 Dec 2010 23:06:47 +0100
Message-ID: <m37hfe7iiw.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:44025 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351Ab0LLWPQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 17:15:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must not wake the TX queue without free TX descriptors.
sca_xmit() expects at least one free descriptor and BUGs otherwise.

Problem reported and fix tested by Bernie Innocenti and Ward Vandewege.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -293,6 +293,7 @@ static inline void sca_tx_done(port_t *port)
 	struct net_device *dev =3D port->netdev;
 	card_t* card =3D port->card;
 	u8 stat;
+	unsigned count =3D 0;
=20
 	spin_lock(&port->lock);
=20
@@ -316,10 +317,12 @@ static inline void sca_tx_done(port_t *port)
 			dev->stats.tx_bytes +=3D readw(&desc->len);
 		}
 		writeb(0, &desc->stat);	/* Free descriptor */
+		count++;
 		port->txlast =3D (port->txlast + 1) % card->tx_ring_buffers;
 	}
=20
-	netif_wake_queue(dev);
+	if (count)
+		netif_wake_queue(dev);
 	spin_unlock(&port->lock);
 }
=20
