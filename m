From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 7/9] ixgb: Remove support for RAIDC interrupt moderation
Date: Thu, 6 Jan 2005 17:26:21 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061554430.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2005-01-05 17:13:28.000000000 -0800
@@ -182,7 +182,6 @@ struct ixgb_desc_ring {
 	uint64_t hw_csum_rx_error;
 	uint64_t hw_csum_rx_good;
 	uint32_t rx_int_delay;
-	boolean_t raidc;
 	boolean_t rx_csum;
 
 	/* OS defined structs */
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-01-05 17:13:29.000000000 -0800
@@ -850,44 +850,6 @@ ixgb_configure_rx(struct ixgb_adapter *a
 			| RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
-	if (adapter->raidc) {
-		uint32_t raidc;
-		uint8_t poll_threshold;
-
-		/* Poll every rx_int_delay period, if RBD exists
-		 * Receive Backlog Detection is set to <threshold> 
-		 * Rx Descriptors
-		 * max is 0x3F == set to poll when 504 RxDesc left 
-		 * min is 0 */
-
-		/* polling times are 1 == 0.8192us
-			2 == 1.6384us
-			3 == 3.2768us etc
-			...
-			511 == 418 us
-		 */
-#define IXGB_RAIDC_POLL_DEFAULT 122 /* set to poll every ~100 us under load 
-					   also known as 10000 interrupts / sec */
-
-		/* divide this by 2^3 (8) to get a register size count */
-		poll_threshold = ((adapter->rx_ring.count-1) >> 3);
-		/* poll at half of that size */
-		poll_threshold >>= 1;
-		/* make sure its not bigger than our max */
-		poll_threshold &= 0x3F;
-
-		raidc =
-			IXGB_RAIDC_EN | /* turn on raidc style moderation */
-			IXGB_RAIDC_RXT_GATE | /* don't interrupt with rxt0 while
-						 in RBD mode (polling) */
-			(IXGB_RAIDC_POLL_DEFAULT << IXGB_RAIDC_POLL_SHIFT) | 
-			  /* this sets the regular "min interrupt delay" */
-			(adapter-> rx_int_delay << IXGB_RAIDC_DELAY_SHIFT) |
-			poll_threshold;
-
-		IXGB_WRITE_REG(hw, RAIDC, raidc);
-	}
-
 	/* Enable Receive Checksum Offload for TCP and UDP */
 	if(adapter->rx_csum == TRUE) {
 		rxcsum = IXGB_READ_REG(hw, RXCSUM);
@@ -1684,16 +1684,7 @@ ixgb_intr(int irq, void *data, struct pt
 		if(!ixgb_clean_rx_irq(adapter) &
 		   !ixgb_clean_tx_irq(adapter))
 			break;
-	/* if RAIDC:EN == 1 and ICR:RXDMT0 == 1, we need to
-	 * set IMS:RXDMT0 to 1 to restart the RBD timer (POLL)
-	 */
-	if ((icr & IXGB_INT_RXDMT0) && adapter->raidc) {
-		/* ready the timer by writing the clear reg */
-		IXGB_WRITE_REG(hw, IMC, IXGB_INT_RXDMT0);
-		/* now restart it, h/w will decide if its necessary */
-		IXGB_WRITE_REG(hw, IMS, IXGB_INT_RXDMT0);
-	}
-#endif
+#endif 
 	return IRQ_HANDLED;
 }
 
@@ -1974,13 +1927,8 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 	buffer_info = &rx_ring->buffer_info[i];
 	cleancount = IXGB_DESC_UNUSED (rx_ring);
 
-	/* lessen this to 4 if we're
-	 * in the midst of raidc and rbd is occuring
-	 * because we don't want to delay returning buffers when low
-	 */
-	num_group_tail_writes 
-		= adapter->raidc ? 4 : IXGB_RX_BUFFER_WRITE;
-	
+	num_group_tail_writes = IXGB_RX_BUFFER_WRITE;
+
 	/* leave one descriptor unused */
 	while(--cleancount > 0) {
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_param.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_param.c	2005-01-05 18:01:29.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c	2005-01-05 18:01:31.000000000 -0800
@@ -121,15 +121,6 @@ IXGB_PARAM(TxIntDelay, "Transmit Interru
 
 IXGB_PARAM(RxIntDelay, "Receive Interrupt Delay");
 
-/* Receive Interrupt Moderation enable (uses RxIntDelay too)
- *
- * Valid Range: 0,1
- *
- * Default Value: 1
- */
-
-IXGB_PARAM(RAIDC, "Disable or enable Receive Interrupt Moderation");
-
 /* Receive Flow control high threshold (when we send a pause frame)
  * (FCRTH)
  *
@@ -430,17 +436,6 @@ ixgb_check_options(struct ixgb_adapter *
 		adapter->rx_int_delay = RxIntDelay[bd];
 		ixgb_validate_option(&adapter->rx_int_delay, &opt);
 	}
-	{ /* Receive Interrupt Moderation */
-		struct ixgb_option opt = {
-			.type = enable_option,
-			.name = "Advanced Receive Interrupt Moderation",
-			.err = "defaulting to Enabled",
-			.def = OPTION_ENABLED
-		};
-		int raidc = RAIDC[bd];
-
-		ixgb_validate_option(&raidc, &opt);
-		adapter->raidc = raidc;
 	}
 	{ /* Transmit Interrupt Delay */
 		struct ixgb_option opt = {
