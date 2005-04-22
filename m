From: "David S. Miller" <davem@davemloft.net>
Subject: [TG3]: test minimal hw coalescing
Date: Fri, 22 Apr 2005 11:50:30 -0700
Message-ID: <20050422115030.544fddf7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


For the folks who want to play around with trying to eliminate
some of the cruddy NAPI behavior with tg3, give the following
patch a try.

You can play with the LOW_{RX,TX}COL_TICKS, LOW_{RX,TX}MAX_FRAMES,
et al. values to see if some settings work better than others.
The current values are basically pulled out of a hat and should
be verified with real performance testing.

I'm more than happy to put something like this into the upstream
driver, especially so if someone can get some real numbers to show
both before and after (hint hint). :-)

I also have to fix tg3.c to use the tagged irq status mode.
Long ago when I wrote the NAPI support I couldn't figure out
how to make that mode work with NAPI's IRQ disabling/enabling,
but now I know that I have to keep track of the current semaphore
count in the driver software state in order to do it correctly.
This should help PIO overhead as well.

drivers/net/tg3.c: f65ca3b2da6f3fcdb464cd8f9d0b53b5611103b1
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5366,16 +5366,16 @@ static int tg3_reset_hw(struct tg3 *tp)
 		udelay(10);
 	}
 
-	tw32(HOSTCC_RXCOL_TICKS, 0);
+	tw32(HOSTCC_RXCOL_TICKS, LOW_RXCOL_TICKS);
 	tw32(HOSTCC_TXCOL_TICKS, LOW_TXCOL_TICKS);
-	tw32(HOSTCC_RXMAX_FRAMES, 1);
-	tw32(HOSTCC_TXMAX_FRAMES, LOW_RXMAX_FRAMES);
+	tw32(HOSTCC_RXMAX_FRAMES, LOW_RXMAX_FRAMES);
+	tw32(HOSTCC_TXMAX_FRAMES, LOW_TXMAX_FRAMES);
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
-		tw32(HOSTCC_RXCOAL_TICK_INT, 0);
-		tw32(HOSTCC_TXCOAL_TICK_INT, 0);
+		tw32(HOSTCC_RXCOAL_TICK_INT, DEFAULT_RXCOAL_TICK_INT);
+		tw32(HOSTCC_TXCOAL_TICK_INT, DEFAULT_TXCOAL_TICK_INT);
 	}
-	tw32(HOSTCC_RXCOAL_MAXF_INT, 1);
-	tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
+	tw32(HOSTCC_RXCOAL_MAXF_INT, DEFAULT_RXCOAL_MAXF_INT);
+	tw32(HOSTCC_TXCOAL_MAXF_INT, DEFAULT_TXCOAL_MAXF_INT);
 
 	/* set status block DMA address */
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
