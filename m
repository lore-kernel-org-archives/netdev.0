From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: test minimal hw coalescing
Date: Fri, 22 Apr 2005 12:32:29 -0700
Message-ID: <1114198349.6158.20.camel@rh4>
References: <20050422115030.544fddf7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050422115030.544fddf7.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-04-22 at 11:50 -0700, David S. Miller wrote:
> For the folks who want to play around with trying to eliminate
> some of the cruddy NAPI behavior with tg3, give the following
> patch a try.
> 
> You can play with the LOW_{RX,TX}COL_TICKS, LOW_{RX,TX}MAX_FRAMES,
> et al. values to see if some settings work better than others.
> The current values are basically pulled out of a hat and should
> be verified with real performance testing.
> 

This patch to turn on "clear ticks" in coalescing mode on top of David's
patch may also be beneficial.

The "clear ticks" mode will reset the coalescing ticks counter when a
new packet is received. Without "clear ticks", you normally have to set
the ticks to be roughly equal to the time it takes to receive the number
packets to be coalesced. For example, if your RXCOL_FRAMES is set to 5,
your RXCOL_TICKS should be roughly 5 x 12 = 60 ticks. (It takes about 12
ticks (usec) to receive a 1.5K packet at Gigabit) The problem is that if
only 1 packet is received, you still have to wait for 60 usec to get the
rx interrupt and so latency will suffer.

With "clear ticks" mode enabled, RXCOL_TICKS can be set a lot lower and
independent of the RXCOL_FRAMES. You still get the benefit of coalescing
all the packets up to RXCOL_FRAMES if they actually arrive. If fewer
packets arrive, you get the interrupt sooner. A good starting value for
RXCOL_TICKS is 15 - 20 ticks.


diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2005-04-22 11:53:34.000000000 -0700
+++ b/drivers/net/tg3.c	2005-04-22 12:04:26.000000000 -0700
@@ -8494,6 +8494,11 @@
 	     grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788M))
 		tp->tg3_flags2 |= TG3_FLG2_IS_5788;
 
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_IS_5788))
+		tp->coalesce_mode |= HOSTCC_MODE_CLRTICK_TXBD |
+				     HOSTCC_MODE_CLRTICK_RXBD;
+
 	/* these are limited to 10/100 only */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
 	     (grc_misc_cfg == 0x8000 || grc_misc_cfg == 0x4000)) ||
diff -Nru a/drivers/net/tg3.h b/drivers/net/tg3.h
--- a/drivers/net/tg3.h	2005-04-22 11:53:34.000000000 -0700
+++ b/drivers/net/tg3.h	2005-04-22 12:04:26.000000000 -0700
@@ -875,7 +875,7 @@
 #define HOSTCC_STATUS			0x00003c04
 #define  HOSTCC_STATUS_ERROR_ATTN	 0x00000004
 #define HOSTCC_RXCOL_TICKS		0x00003c08
-#define  LOW_RXCOL_TICKS		 0x00000032
+#define  LOW_RXCOL_TICKS		 0x00000014
 #define  DEFAULT_RXCOL_TICKS		 0x00000048
 #define  HIGH_RXCOL_TICKS		 0x00000096
 #define HOSTCC_TXCOL_TICKS		0x00003c0c
@@ -891,7 +891,7 @@
 #define  DEFAULT_TXMAX_FRAMES		 0x0000004b
 #define  HIGH_TXMAX_FRAMES		 0x00000052
 #define HOSTCC_RXCOAL_TICK_INT		0x00003c18
-#define  DEFAULT_RXCOAL_TICK_INT	 0x00000019
+#define  DEFAULT_RXCOAL_TICK_INT	 0x00000014
 #define HOSTCC_TXCOAL_TICK_INT		0x00003c1c
 #define  DEFAULT_TXCOAL_TICK_INT	 0x00000019
 #define HOSTCC_RXCOAL_MAXF_INT		0x00003c20
