From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH][REPOST] WAN: fix C101 card carrier handling
Date: Tue, 22 Aug 2006 14:59:17 +0200
Message-ID: <m3k651udsq.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:12518 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S932071AbWHVM7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 08:59:20 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

One of my recent changes broke C101 carrier handling, this patch
fixes it. Also fixes an old TX underrun checking bug.

2.6.18 material. Please apply.
Thanks.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 435e91e..6b63b35 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -118,7 +118,7 @@ #include "hd6457x.c"
 
 static inline void set_carrier(port_t *port)
 {
-	if (!sca_in(MSCI1_OFFSET + ST3, port) & ST3_DCD)
+	if (!(sca_in(MSCI1_OFFSET + ST3, port) & ST3_DCD))
 		netif_carrier_on(port_to_dev(port));
 	else
 		netif_carrier_off(port_to_dev(port));
@@ -127,10 +127,10 @@ static inline void set_carrier(port_t *p
 
 static void sca_msci_intr(port_t *port)
 {
-	u8 stat = sca_in(MSCI1_OFFSET + ST1, port); /* read MSCI ST1 status */
+	u8 stat = sca_in(MSCI0_OFFSET + ST1, port); /* read MSCI ST1 status */
 
-	/* Reset MSCI TX underrun status bit */
-	sca_out(stat & ST1_UDRN, MSCI0_OFFSET + ST1, port);
+	/* Reset MSCI TX underrun and CDCD (ignored) status bit */
+	sca_out(stat & (ST1_UDRN | ST1_CDCD), MSCI0_OFFSET + ST1, port);
 
 	if (stat & ST1_UDRN) {
 		struct net_device_stats *stats = hdlc_stats(port_to_dev(port));
@@ -138,6 +138,7 @@ static void sca_msci_intr(port_t *port)
 		stats->tx_fifo_errors++;
 	}
 
+	stat = sca_in(MSCI1_OFFSET + ST1, port); /* read MSCI1 ST1 status */
 	/* Reset MSCI CDCD status bit - uses ch#2 DCD input */
 	sca_out(stat & ST1_CDCD, MSCI1_OFFSET + ST1, port);
 
