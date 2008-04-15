From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: fec_mpc5200: reset FEC on error
Date: Tue, 15 Apr 2008 17:44:39 +0200
Message-ID: <20080415154439.GZ13814@pengutronix.de>
References: <20080415152638.GW13814@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Domen Puncer <domen@coderock.org>
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20080415152638.GW13814@pengutronix.de>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Sascha Hauer <s.hauer@pengutronix.de>

The error handling for the mpc5200 fec interrupt is broken. The intended
behaviour is like this:

* If one of FEC_IEVENT_RFIFO_ERROR and FEC_IEVENT_XFIFO_ERROR happens,
  the datasheet says (MPC5200B User's Guide R1.2, p. 14-13): "When this
  occurs, software must ensure both the FIFO Controller and BestComm are
  soft-reset".

* On any other error (non-TFINT) interrupt, just issue a debug message.

v2 changed to -p1 and posted on linuxppc list (2008-04-15).

v1 posted on linuxppc list (2008-04-15).

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

---
 drivers/net/fec_mpc52xx.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

Index: drivers/net/fec_mpc52xx.c
===================================================================
--- a/drivers/net/fec_mpc52xx.c.orig
+++ b/drivers/net/fec_mpc52xx.c
@@ -491,20 +491,23 @@
 
 	out_be32(&fec->ievent, ievent);		/* clear pending events */
 
-	if (ievent & ~(FEC_IEVENT_RFIFO_ERROR | FEC_IEVENT_XFIFO_ERROR)) {
-		if (ievent & ~FEC_IEVENT_TFINT)
-			dev_dbg(&dev->dev, "ievent: %08x\n", ievent);
+	/* on fifo error, soft-reset fec */
+	if (ievent & (FEC_IEVENT_RFIFO_ERROR | FEC_IEVENT_XFIFO_ERROR)) {
+
+		if (net_ratelimit() && (ievent & FEC_IEVENT_RFIFO_ERROR))
+			dev_warn(&dev->dev, "FEC_IEVENT_RFIFO_ERROR\n");
+		if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
+			dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");
+
+		mpc52xx_fec_reset(dev);
+
+		netif_wake_queue(dev);
 		return IRQ_HANDLED;
 	}
 
-	if (net_ratelimit() && (ievent & FEC_IEVENT_RFIFO_ERROR))
-		dev_warn(&dev->dev, "FEC_IEVENT_RFIFO_ERROR\n");
-	if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
-		dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");
-
-	mpc52xx_fec_reset(dev);
+	if (ievent & ~FEC_IEVENT_TFINT)
+		dev_dbg(&dev->dev, "ievent: %08x\n", ievent);
 
-	netif_wake_queue(dev);
 	return IRQ_HANDLED;
 }
