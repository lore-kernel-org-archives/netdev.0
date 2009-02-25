From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] pcmcia: worklimit reaches -1
Date: Wed, 25 Feb 2009 13:26:19 +0100
Message-ID: <49A538EB.8080008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:11719 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbZBYM0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 07:26:22 -0500
Received: by yw-out-2324.google.com with SMTP id 5so1325555ywh.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 04:26:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------------------------------>8-------------8<---------------------------------
with while (--worklimit >= 0); worklimit reaches -1 after the loop. In
3c589_cs.c this caused a warning not to be printed.

In 3c574_cs.c contrastingly, el3_rx() treats worklimit differently:

static int el3_rx(struct net_device *dev, int worklimit)
{
	while (--worklimit >= 0) { ... }
	return worklimit;
}

el3_rx() is only called by function el3_interrupt(): twice:

static irqreturn_t el3_interrupt(int irq, void *dev_id)
{
        int work_budget = max_interrupt_work;
	while(...) {
		if (...)
			work_budget = el3_rx(dev, work_budget);
		if (...)
			work_budget = el3_rx(dev, work_budget);
		if (--work_budget < 0) {
		        ...
		        break;
		}
	}
}
The error path can occur 2 too early.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
el3_rx() calls: lines 839 and 856
el3_interrupt(): line 810

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index e5cb6b1..2404a83 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -1035,7 +1035,8 @@ static int el3_rx(struct net_device *dev, int worklimit)
 	DEBUG(3, "%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
 		  dev->name, inw(ioaddr+EL3_STATUS), inw(ioaddr+RxStatus));
 	while (!((rx_status = inw(ioaddr + RxStatus)) & 0x8000) &&
-		   (--worklimit >= 0)) {
+			worklimit > 0) {
+		worklimit--;
 		if (rx_status & 0x4000) { /* Error, update stats. */
 			short error = rx_status & 0x3800;
 			dev->stats.rx_errors++;
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 73ecc65..1e01b8a 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -857,7 +857,8 @@ static int el3_rx(struct net_device *dev)
     DEBUG(3, "%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
 	  dev->name, inw(ioaddr+EL3_STATUS), inw(ioaddr+RX_STATUS));
     while (!((rx_status = inw(ioaddr + RX_STATUS)) & 0x8000) &&
-	   (--worklimit >= 0)) {
+		    worklimit > 0) {
+	worklimit--;
 	if (rx_status & 0x4000) { /* Error, update stats. */
 	    short error = rx_status & 0x3800;
 	    dev->stats.rx_errors++;
