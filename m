From: Stephane Doyon <sdoyon@max-t.com>
Subject: tg3: oops on incompletely initialized rx ring
Date: Wed, 12 Jul 2006 13:41:08 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607121249570.9755@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]:15590
	"EHLO mail.max-t.com") by vger.kernel.org with ESMTP
	id S1750827AbWGLRnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 13:43:01 -0400
To: netdev@vger.kernel.org, mchan@broadcom.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We have stumbled on a little problem with the tg3 driver. It would appear 
that some RX ring entries without buffers are still used for receive when 
memory allocation failures occur during initial RX ring setup, which 
causes an oops.

The tg3 driver sets tp->rx_jumbo_ptr and MAILBOX_RCV_JUMBO_PROD_IDX 
register to the full configured desired ring size (tp->rx_jumbo_pending), 
even when it fails to initialize all skbs for that ring due to having run 
out of memory. It does the same for the standard RX ring. tg3_init_rings() 
calls tg3_alloc_rx_skb() repeatedly in a for loop to allocate an skb for 
each ring entry. If an allocation fails, it simply breaks out of the loop 
and returns silently. tg3_reset_hw() programs MAILBOX_RCV_STD_PROD_IDX and 
MAILBOX_RCV_JUMBO_PROD_IDX to indicate the desired ring size, regardless 
of whether or not all allocations really did succeed. It would appear that 
when the NIC eventually receives a packet for the RX entry without a 
buffer, it still signals a receive event, and the tg3 driver oopSes when 
it finds no skb for that entry: NULL pointer dereference.

The EIP appears to point to a call to skb_put() in tgc_rx(). skb_put() 
calls SKB_LINEAR_ASSERT which calls skb_is_nonlinear, which dereferences 
skb->data_len but found skb to be null.

We have encountered the problem a few times when switching from standard 
to jumbo frames on a system that had been extensively used for about 
5days. Memory was probably very fragmented, and the multi-page jumbo 
buffers couldn't all be allocated. I imagine hitting this problem with the 
standard ring is pretty unlikely. OTOH the allocations are done with 
GFP_ATOMIC, which makes failures plausible for jumbo buffers.

We saw the problem on kernel 2.4.27, but from the code I believe that 
2.6.x and later 2.4.x kernels are also affected.

This bug is pretty hard to reproduce. I have managed to reproduce and 
confirm the bug by hacking tg3_init_rings(): have the for loop for jumbo 
sk_buffs exit after 100 iterations, instead of the desired 255 entries. 
The first few jumbo packets are received properly, and eventually an oops 
occurs.

A nasty aspect of the bug is that no error is returned during
initialization of the NIC and, assuming the problem is with the jumbo
ring, the NIC works normally with small packets. The OOPS will only occur
later, after having received one or a few jumbo packets, which made it 
hard to figure that the problem was with the initialization.

A possible fix that I am using now is to note the actual number of 
allocated buffers and tell the hardware the correct number. And tell the 
user. Patch below.

Some remaining issues:

-I believe the RX ring cannot grow back later if memory becomes available.

-IWBN to use GFP_KERNEL for initialization, if the locking can be 
rearranged.

-Performance will be degraded, reception may not work at all if 0 buffers 
were allocated. Or there may be the confusing case for the user that the 
standard RX ring entries were allocated but not the jumbo, so that some 
packets are received and others not. It might make sense to fail with an 
error, at least when 0 buffers were allocated.

-tg3_change_mtu() would then need to handle failures.

Something like this patch would at least avoid the nasty oops.
Against 2.6.17.

Thank you

Signed-off-by: Stephane Doyon <sdoyon@max-t.com>
--- linux/drivers/net/tg3.c.orig	2006-07-12 12:20:33.000000000 -0400
+++ linux/drivers/net/tg3.c	2006-07-12 12:40:53.000000000 -0400
@@ -4143,7 +4143,8 @@ static void tg3_free_rings(struct tg3 *t
   * end up in the driver.  tp->{tx,}lock are held and thus
   * we may not sleep.
   */
-static void tg3_init_rings(struct tg3 *tp)
+static void tg3_init_rings(struct tg3 *tp,
+	       u32 *actual_rx_std_pending, u32 *actual_rx_jumbo_pending)
  {
  	u32 i;

@@ -4196,6 +4197,7 @@ static void tg3_init_rings(struct tg3 *t
  				     -1, i) < 0)
  			break;
  	}
+	*actual_rx_std_pending = i;

  	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
  		for (i = 0; i < tp->rx_jumbo_pending; i++) {
@@ -4203,7 +4205,8 @@ static void tg3_init_rings(struct tg3 *t
  					     -1, i) < 0)
  				break;
  		}
-	}
+		*actual_rx_jumbo_pending = i;
+	}else *actual_rx_jumbo_pending = 0;
  }

  /*
@@ -5805,6 +5808,7 @@ static int tg3_reset_hw(struct tg3 *tp,
  {
  	u32 val, rdmac_mode;
  	int i, err, limit;
+	u32 actual_rx_std_pending, actual_rx_jumbo_pending;

  	tg3_disable_ints(tp);

@@ -5853,7 +5857,17 @@ static int tg3_reset_hw(struct tg3 *tp,
  	 * can only do this after the hardware has been
  	 * successfully reset.
  	 */
-	tg3_init_rings(tp);
+	tg3_init_rings(tp, &actual_rx_std_pending, &actual_rx_jumbo_pending);
+	if(actual_rx_std_pending < tp->rx_pending
+	   || actual_rx_jumbo_pending < tp->rx_jumbo_pending) {
+		printk(KERN_ERR PFX 
+		       "%s: Failed to allocate memory for complete RX rings, "
+		       "std %u/%u jumbo %u/%u.\n",
+		       tp->dev->name,
+		       actual_rx_std_pending, tp->rx_pending,
+		       actual_rx_jumbo_pending, tp->rx_jumbo_pending);
+		/* return -ENOMEM; ?? */
+	}

  	/* This value is determined during the probe time DMA
  	 * engine test, tg3_test_dma.
@@ -5946,7 +5960,7 @@ static int tg3_reset_hw(struct tg3 *tp,
  	}

  	/* Setup replenish threshold. */
-	tw32(RCVBDI_STD_THRESH, tp->rx_pending / 8);
+	tw32(RCVBDI_STD_THRESH, actual_rx_std_pending / 8);

  	/* Initialize TG3_BDINFO's at:
  	 *  RCVDBDI_STD_BD:	standard eth size rx ring
@@ -5986,7 +6000,7 @@ static int tg3_reset_hw(struct tg3 *tp,
  		     BDINFO_FLAGS_DISABLED);

  		/* Setup replenish threshold. */
-		tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
+		tw32(RCVBDI_JUMBO_THRESH, actual_rx_jumbo_pending / 8);

  		if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
  			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
@@ -6045,12 +6059,12 @@ static int tg3_reset_hw(struct tg3 *tp,
  			BDINFO_FLAGS_MAXLEN_SHIFT),
  		       0);

-	tp->rx_std_ptr = tp->rx_pending;
+	tp->rx_std_ptr = actual_rx_std_pending;
  	tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
  		     tp->rx_std_ptr);

  	tp->rx_jumbo_ptr = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
-						tp->rx_jumbo_pending : 0;
+						actual_rx_jumbo_pending : 0;
  	tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
  		     tp->rx_jumbo_ptr);

