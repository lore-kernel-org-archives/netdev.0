From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] stir4200 update for 2.6.4-rc1
Date: Tue, 2 Mar 2004 12:05:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040302120501.7fa8f698@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>, netdev@oss.sgi.com,
        Irda Users
 <irda-users@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

New revision of the Sigmatel irda driver.  This version has much
better performance and doesn't drop frames in FIR mode.
Tested with both UHCI and EHCI/OHCI against nsc-ircc on laptop.
Thanks to Martin for additional testing and feedback.

* Receiver:
	- changed from interrupt to bulk URB.  Queue's one bulk
	  urb per USB tick (1ms).
	- FIR unpack now uses get_unaligned and cpu32_le
	  instead of explicit shifts
	- FIR unpack copies small frames
* Transmitter:
	- pack data into io buffer.  Since irda is half duplex
	  can use same buffer for transmit and receive.
	- use xchange and wait_event for synchronization
* Other:
	- use USB format messages rather than IRDA (ugly)
	- clean up USB startup
	- reset device on network open to clear up stuck state
	- handle FIFO errors
	- disconnect cleanup (from viro)
	- don't DMA onto stack when reading fifo status

David, please apply.  There maybe more small tweaks later as it gets
wider usage.

--- linux-2.6/drivers/net/irda/stir4200.c	2004-02-18 14:14:14.000000000 -0800
+++ test-2.6/drivers/net/irda/stir4200.c	2004-03-02 11:11:21.413890216 -0800
@@ -49,12 +49,14 @@
 #include <linux/suspend.h>
 #include <linux/slab.h>
 #include <linux/usb.h>
+#include <linux/crc32.h>
 #include <net/irda/irda.h>
 #include <net/irda/irlap.h>
 #include <net/irda/irda_device.h>
 #include <net/irda/wrapper.h>
 #include <net/irda/crc.h>
-#include <linux/crc32.h>
+#include <asm/byteorder.h>
+#include <asm/unaligned.h>
 
 MODULE_AUTHOR("Stephen Hemminger <shemminger@osdl.org>");
 MODULE_DESCRIPTION("IrDA-USB Dongle Driver for SigmaTel STIr4200");
@@ -72,15 +74,11 @@ static int tx_power = 0;	/* 0 = highest 
 module_param(tx_power, int, 0);
 MODULE_PARM_DESC(tx_power, "Set Transmitter power (0-3, 0 is highest power)");
 
-static int rx_interval = 5;  /* milliseconds */
-module_param(rx_interval, int, 0);
-MODULE_PARM_DESC(rx_interval, "Receive polling interval (ms)");
-
 #define STIR_IRDA_HEADER  	4
 #define CTRL_TIMEOUT		100	   /* milliseconds */
 #define TRANSMIT_TIMEOUT	200	   /* milliseconds */
 #define STIR_FIFO_SIZE		4096
-#define NUM_RX_URBS		2
+#define FIFO_REGS_SIZE		3
 
 enum FirChars {
 	FIR_CE   = 0x7d,
@@ -167,36 +165,26 @@ enum StirTestMask {
 	TEST_TSTOSC = 0x0F,
 };
 
-enum StirState {
-	STIR_STATE_RECEIVING=0,
-	STIR_STATE_TXREADY,
-};
-
 struct stir_cb {
         struct usb_device *usbdev;      /* init: probe_irda */
         struct net_device *netdev;      /* network layer */
         struct irlap_cb   *irlap;       /* The link layer we are binded to */
         struct net_device_stats stats;	/* network statistics */
         struct qos_info   qos;
-	unsigned long     state;
 	unsigned 	  speed;	/* Current speed */
 
 	wait_queue_head_t thr_wait;	/* transmit thread wakeup */
 	struct completion thr_exited;
 	pid_t		  thr_pid;
 
-	unsigned int	  tx_bulkpipe;
-	void		 *tx_data;	/* wrapped data out */
-	unsigned	  tx_len;
-	unsigned	  tx_newspeed;
-	unsigned	  tx_mtt;
+	struct sk_buff	  *tx_pending;
+	void		  *io_buf;	/* transmit/receive buffer */
+	__u8		  *fifo_status;
 
-	unsigned int	  rx_intpipe;
 	iobuff_t  	  rx_buff;	/* receive unwrap state machine */
-	struct timespec	  rx_time;
-
-	struct urb	 *rx_urbs[NUM_RX_URBS];
-	void		 *rx_data[NUM_RX_URBS];
+	struct timeval	  rx_time;
+	int		  receiving;
+	struct urb	 *rx_urb;
 };
 
 
@@ -209,9 +197,6 @@ static struct usb_device_id dongles[] = 
 
 MODULE_DEVICE_TABLE(usb, dongles);
 
-static int fifo_txwait(struct stir_cb *stir, unsigned space);
-static void stir_usb_receive(struct urb *urb, struct pt_regs *regs);
-
 /* Send control message to set dongle register */
 static int write_reg(struct stir_cb *stir, __u16 reg, __u8 value)
 {
@@ -239,6 +224,11 @@ static inline int read_reg(struct stir_c
 			       MSECS_TO_JIFFIES(CTRL_TIMEOUT));
 }
 
+static inline int isfir(u32 speed)
+{
+	return (speed == 4000000);
+}
+
 /*
  * Prepare a FIR IrDA frame for transmission to the USB dongle.  The
  * FIR transmit frame is documented in the datasheet.  It consists of
@@ -333,8 +323,8 @@ static void fir_eof(struct stir_cb *stir
 {
 	iobuff_t *rx_buff = &stir->rx_buff;
 	int len = rx_buff->len - 4;
+	struct sk_buff *skb, *nskb;
 	__u32 fcs;
-	struct sk_buff *nskb;
 
 	if (unlikely(len <= 0)) {
 		pr_debug("%s: short frame len %d\n",
@@ -345,41 +335,46 @@ static void fir_eof(struct stir_cb *stir
 		return;
 	}
 
-	fcs = rx_buff->data[len] |
-		rx_buff->data[len+1] << 8 |
-		rx_buff->data[len+2] << 16 |
-		rx_buff->data[len+3] << 24;
-
-	if (unlikely(fcs != ~(crc32_le(~0, rx_buff->data, len)))) {
-		pr_debug("%s: crc error\n", stir->netdev->name);
-		irda_device_set_media_busy(stir->netdev, TRUE);
+	fcs = ~(crc32_le(~0, rx_buff->data, len));
+	if (fcs != le32_to_cpu(get_unaligned((u32 *)(rx_buff->data+len)))) {
+		pr_debug("crc error calc 0x%x len %d\n", fcs, len);
 		stir->stats.rx_errors++;
 		stir->stats.rx_crc_errors++;
 		return;
 	}
 
-	/* If can't get new buffer, just drop and reuse */
-	nskb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
-	if (unlikely(!nskb))
-		++stir->stats.rx_dropped;
-	else {
-		struct sk_buff *oskb = rx_buff->skb;
+	/* if frame is short then just copy it */
+	if (len < IRDA_RX_COPY_THRESHOLD) {
+		nskb = dev_alloc_skb(len + 1);
+		if (unlikely(!nskb)) {
+			++stir->stats.rx_dropped;
+			return;
+		}
+		skb_reserve(nskb, 1);
+		skb = nskb;
+		memcpy(nskb->data, rx_buff->data, len);
+	} else {
+		nskb = dev_alloc_skb(rx_buff->truesize);
+		if (unlikely(!nskb)) {
+			++stir->stats.rx_dropped;
+			return;
+		}
 		skb_reserve(nskb, 1);
+		skb = rx_buff->skb;
+		rx_buff->skb = nskb;
+		rx_buff->head = nskb->data;
+	}
 
-		/* Set correct length in socket buffer */
-		skb_put(oskb, len);
+	skb_put(skb, len);
 
-		oskb->mac.raw  = oskb->data;
-		oskb->protocol = htons(ETH_P_IRDA);
-		oskb->dev = stir->netdev;
+	skb->mac.raw  = skb->data;
+	skb->protocol = htons(ETH_P_IRDA);
+	skb->dev = stir->netdev;
 
-		netif_rx(oskb);
+	netif_rx(skb);
 
-		stir->stats.rx_packets++;
-		stir->stats.rx_bytes += len;
-		rx_buff->skb = nskb;
-		rx_buff->head = nskb->data;
-	}
+	stir->stats.rx_packets++;
+	stir->stats.rx_bytes += len;
 
 	rx_buff->data = rx_buff->head;
 	rx_buff->len = 0;
@@ -402,7 +397,6 @@ static void stir_fir_chars(struct stir_c
 				continue;
 			/* Now receiving frame */
 			rx_buff->state = BEGIN_FRAME;
-			rx_buff->in_frame = TRUE;
 
 			/* Time to initialize receive buffer */
 			rx_buff->data = rx_buff->head;
@@ -424,6 +418,7 @@ static void stir_fir_chars(struct stir_c
 			if (byte == FIR_EOF)
 				continue;
 			rx_buff->state = INSIDE_FRAME;
+			rx_buff->in_frame = TRUE;
 
 			/* fall through */
 		case INSIDE_FRAME:
@@ -461,7 +456,6 @@ static void stir_fir_chars(struct stir_c
 
 	error_recovery:
 		++stir->stats.rx_errors;
-		irda_device_set_media_busy(stir->netdev, TRUE);
 		rx_buff->state = OUTSIDE_FRAME;
 		rx_buff->in_frame = FALSE;
 	}
@@ -478,11 +472,6 @@ static void stir_sir_chars(struct stir_c
 				  &stir->rx_buff, bytes[i]);
 }
 
-static inline int isfir(u32 speed)
-{
-	return (speed == 4000000);
-}
-
 static inline void unwrap_chars(struct stir_cb *stir,
 				const __u8 *bytes, int length)
 {
@@ -519,25 +508,31 @@ static int change_speed(struct stir_cb *
 	int i, err;
 	__u8 mode;
 
-	pr_debug("%s: change speed %d\n", stir->netdev->name, speed);
 	for (i = 0; i < ARRAY_SIZE(stir_modes); ++i) {
 		if (speed == stir_modes[i].speed)
 			goto found;
 	}
 
-	ERROR("%s: invalid speed %d\n", stir->netdev->name, speed);
+	warn("%s: invalid speed %d", stir->netdev->name, speed);
 	return -EINVAL;
 
  found:
-	pr_debug("%s: speed change from %d to %d\n",
-		 stir->netdev->name, stir->speed, speed);
+	pr_debug("speed change from %d to %d\n", stir->speed, speed);
+
+	/* sometimes needed to get chip out of stuck state */
+	err = usb_reset_device(stir->usbdev);
+	if (err)
+		goto out;
+
+	/* Reset modulator */
+	err = write_reg(stir, REG_CTRL1, CTRL1_SRESET);
+	if (err)
+		goto out;
 
-	/* Make sure any previous Tx is really finished. This happens
-	 * when we answer an incomming request ; the ua:rsp and the
-	 * speed change are bundled together, so we need to wait until
-	 * the packet we just submitted has been sent. Jean II */
-	if (fifo_txwait(stir, 0))
-		return -EIO;
+	/* Undocumented magic to tweak the DPLL */
+	err = write_reg(stir, REG_DPLL, 0x15);
+	if (err)
+		goto out;
 
 	/* Set clock */
 	err = write_reg(stir, REG_PDCLK, stir_modes[i].pdclk);
@@ -564,33 +559,13 @@ static int change_speed(struct stir_cb *
 		goto out;
 
 	err = write_reg(stir, REG_CTRL1, (tx_power & 3) << 1);
-
- out:
-	stir->speed = speed;
-	return err;
-}
-
-static int stir_reset(struct stir_cb *stir)
-{
-	int err;
-
-	/* reset state */
-	stir->rx_buff.in_frame = FALSE;
-	stir->rx_buff.state = OUTSIDE_FRAME;
-	stir->speed = -1;
-
-	/* Undocumented magic to tweak the DPLL */
-	err = write_reg(stir, REG_DPLL, 0x15);
 	if (err)
 		goto out;
 
 	/* Reset sensitivity */
 	err = write_reg(stir, REG_CTRL2, (rx_sensitivity & 7) << 5);
-	if (err)
-		goto out;
-
-	err = change_speed(stir, 9600);
  out:
+	stir->speed = speed;
 	return err;
 }
 
@@ -606,48 +581,62 @@ static int stir_hard_xmit(struct sk_buff
 	/* the IRDA wrapping routines don't deal with non linear skb */
 	SKB_LINEAR_ASSERT(skb);
 
-	if (unlikely(skb->len) == 0) 		/* speed change only */
-		stir->tx_len = 0;
-	else if (isfir(stir->speed))
-		stir->tx_len = wrap_fir_skb(skb, stir->tx_data);
-	else
-		stir->tx_len = wrap_sir_skb(skb, stir->tx_data);
-
-	stir->stats.tx_packets++;
-	stir->stats.tx_bytes += skb->len;
-
-	stir->tx_mtt = irda_get_mtt(skb);
-	stir->tx_newspeed = irda_get_next_speed(skb);
-
-	if (!test_and_set_bit(STIR_STATE_TXREADY, &stir->state))
-		wake_up(&stir->thr_wait);
+	skb = xchg(&stir->tx_pending, skb);
+	wake_up(&stir->thr_wait);
+	
+	/* this should never happen unless stop/wakeup problem */
+	if (unlikely(skb)) {
+		WARN_ON(1);
+		dev_kfree_skb(skb);
+	}
 
-	dev_kfree_skb(skb);
 	return 0;
 }
 
 /*
  * Wait for the transmit FIFO to have space for next data
+ *
+ * If space < 0 then wait till FIFO completely drains.
+ * FYI: can take up to 13 seconds at 2400baud.
  */
-static int fifo_txwait(struct stir_cb *stir, unsigned space)
+static int fifo_txwait(struct stir_cb *stir, int space)
 {
 	int err;
-	unsigned count;
-	__u8 regs[3];
-	unsigned long timeout = jiffies + HZ/10;
+	unsigned long count, status;
 
+	/* Read FIFO status and count */
 	for(;;) {
-		/* Read FIFO status and count */
-		err = read_reg(stir, REG_FIFOCTL, regs, 3);
-		if (unlikely(err != 3)) {
-			WARNING("%s: FIFO register read error: %d\n",
-				stir->netdev->name, err);
+		err = read_reg(stir, REG_FIFOCTL, stir->fifo_status, 
+				   FIFO_REGS_SIZE);
+		if (unlikely(err != FIFO_REGS_SIZE)) {
+			warn("%s: FIFO register read error: %d", 
+			     stir->netdev->name, err);
+
 			return err;
 		}
 
+		status = stir->fifo_status[0];
+		count = (unsigned)(stir->fifo_status[2] & 0x1f) << 8 
+			| stir->fifo_status[1];
+
+		pr_debug("fifo status 0x%lx count %lu\n", status, count);
+
+		/* error when receive/transmit fifo gets confused */
+		if (status & FIFOCTL_RXERR) {
+			stir->stats.rx_fifo_errors++;
+			stir->stats.rx_errors++;
+			break;
+		}
+
+		if (status & FIFOCTL_TXERR) {
+			stir->stats.tx_fifo_errors++;
+			stir->stats.tx_errors++;
+			break;
+		}
+
 		/* is fifo receiving already, or empty */
-		if (!(regs[0] & FIFOCTL_DIR)
-		    || (regs[0] & FIFOCTL_EMPTY))
+		if (!(status & FIFOCTL_DIR)
+		    || (status & FIFOCTL_EMPTY))
 			return 0;
 
 		if (signal_pending(current))
@@ -658,40 +647,37 @@ static int fifo_txwait(struct stir_cb *s
 		    || !netif_device_present(stir->netdev))
 			return -ESHUTDOWN;
 
-		count = (unsigned)(regs[2] & 0x1f) << 8 | regs[1];
-
-		pr_debug("%s: fifo status 0x%x count %u\n",
-			 stir->netdev->name, regs[0], count);
-
 		/* only waiting for some space */
-		if (space && STIR_FIFO_SIZE - 4 > space + count)
+		if (space >= 0 && STIR_FIFO_SIZE - 4 > space + count)
 			return 0;
 
-		if (time_after(jiffies, timeout)) {
-			WARNING("%s: transmit fifo timeout status=0x%x count=%d\n",
-				stir->netdev->name, regs[0], count);
-			++stir->stats.tx_errors;
-			irda_device_set_media_busy(stir->netdev, TRUE);
-			return -ETIMEDOUT;
-		}
-
 		/* estimate transfer time for remaining chars */
 		wait_ms((count * 8000) / stir->speed);
 	}
+			
+	err = write_reg(stir, REG_FIFOCTL, FIFOCTL_CLR);
+	if (err) 
+		return err;
+	err = write_reg(stir, REG_FIFOCTL, 0);
+	if (err)
+		return err;
+
+	return 0;
 }
 
 
 /* Wait for turnaround delay before starting transmit.  */
-static void turnaround_delay(long us, const struct timespec *last)
+static void turnaround_delay(const struct stir_cb *stir, long us)
 {
 	long ticks;
-	struct timespec now = CURRENT_TIME;
+	struct timeval now;
 
 	if (us <= 0)
 		return;
 
-	us -= (now.tv_sec - last->tv_sec) * USEC_PER_SEC;
-	us -= (now.tv_nsec - last->tv_nsec) / NSEC_PER_USEC;
+	do_gettimeofday(&now);
+	us -= (now.tv_sec - stir->rx_time.tv_sec) * USEC_PER_SEC;
+	us -= now.tv_usec - stir->rx_time.tv_usec;
 	if (us < 10)
 		return;
 
@@ -707,77 +693,60 @@ static void turnaround_delay(long us, co
  * Start receiver by submitting a request to the receive pipe.
  * If nothing is available it will return after rx_interval.
  */
-static void receive_start(struct stir_cb *stir)
+static int receive_start(struct stir_cb *stir)
 {
-	int i;
-
-	if (test_and_set_bit(STIR_STATE_RECEIVING, &stir->state))
-		return;
-
-	if (fifo_txwait(stir, 0))
-		return;
-
-	for (i = 0; i < NUM_RX_URBS; i++) {
-		struct urb *urb = stir->rx_urbs[i];
-
-		usb_fill_int_urb(urb, stir->usbdev, stir->rx_intpipe,
-				 stir->rx_data[i], STIR_FIFO_SIZE,
-				 stir_usb_receive, stir, rx_interval);
-
-		if (usb_submit_urb(urb, GFP_KERNEL))
-			urb->status = -EINVAL;
-	}
+	/* reset state */
+	stir->receiving = 1;
 
-	if (i == 0) {
-		/* if nothing got queued, then just retry next time */
-		if (net_ratelimit())
-			WARNING("%s: no receive buffers avaiable\n",
-				stir->netdev->name);
+	stir->rx_buff.in_frame = FALSE;
+	stir->rx_buff.state = OUTSIDE_FRAME;
 
-		clear_bit(STIR_STATE_RECEIVING, &stir->state);
-	}
+	stir->rx_urb->status = 0;
+	return usb_submit_urb(stir->rx_urb, GFP_KERNEL);
 }
 
 /* Stop all pending receive Urb's */
 static void receive_stop(struct stir_cb *stir)
 {
-	int i;
+	stir->receiving = 0;
+	usb_unlink_urb(stir->rx_urb);
 
-	for (i = 0; i < NUM_RX_URBS; i++) {
-		struct urb *urb = stir->rx_urbs[i];
-		usb_unlink_urb(urb);
-	}
+	if (stir->rx_buff.in_frame) 
+		stir->stats.collisions++;
 }
-
-/* Send wrapped data (in tx_data) to device */
-static void stir_send(struct stir_cb *stir)
+/*
+ * Wrap data in socket buffer and send it.
+ */
+static void stir_send(struct stir_cb *stir, struct sk_buff *skb)
 {
-	int rc;
+	unsigned wraplen;
+	int first_frame = 0;
 
-	if (test_and_clear_bit(STIR_STATE_RECEIVING, &stir->state)) {
+	/* if receiving, need to turnaround */
+	if (stir->receiving) {
 		receive_stop(stir);
-
-		turnaround_delay(stir->tx_mtt, &stir->rx_time);
-
-		if (stir->rx_buff.in_frame)
-			++stir->stats.collisions;
+		turnaround_delay(stir, irda_get_mtt(skb));
+		first_frame = 1;
 	}
-	else if (fifo_txwait(stir, stir->tx_len))
-		return; /* shutdown or major errors */
 
+	if (isfir(stir->speed))
+		wraplen = wrap_fir_skb(skb, stir->io_buf);
+	else
+		wraplen = wrap_sir_skb(skb, stir->io_buf);
+		
+	/* check for space available in fifo */
+	if (!first_frame)
+		fifo_txwait(stir, wraplen);
+
+	stir->stats.tx_packets++;
+	stir->stats.tx_bytes += skb->len;
 	stir->netdev->trans_start = jiffies;
+	pr_debug("send %d (%d)\n", skb->len, wraplen);
 
-	pr_debug("%s: send %d\n", stir->netdev->name, stir->tx_len);
-	rc = usb_bulk_msg(stir->usbdev,
-			  stir->tx_bulkpipe,
-			  stir->tx_data, stir->tx_len,
-			  NULL, MSECS_TO_JIFFIES(TRANSMIT_TIMEOUT));
-
-	if (unlikely(rc)) {
-		WARNING("%s: usb bulk message failed %d\n",
-			stir->netdev->name, rc);
+	if (usb_bulk_msg(stir->usbdev, usb_sndbulkpipe(stir->usbdev, 1),
+			 stir->io_buf, wraplen,
+			 NULL, MSECS_TO_JIFFIES(TRANSMIT_TIMEOUT))) 
 		stir->stats.tx_errors++;
-	}
 }
 
 /*
@@ -787,7 +756,7 @@ static int stir_transmit_thread(void *ar
 {
 	struct stir_cb *stir = arg;
 	struct net_device *dev = stir->netdev;
-	DECLARE_WAITQUEUE(wait, current);
+	struct sk_buff *skb;
 
 	daemonize("%s", dev->name);
 	allow_signal(SIGTERM);
@@ -796,44 +765,58 @@ static int stir_transmit_thread(void *ar
 	       && netif_device_present(dev)
 	       && !signal_pending(current))
 	{
-		/* make swsusp happy with our thread */
+		/* if suspending, then power off and wait */
 		if (current->flags & PF_FREEZE) {
-			receive_stop(stir);
+			if (stir->receiving)
+				receive_stop(stir);
+			else
+				fifo_txwait(stir, -1);
 
 			write_reg(stir, REG_CTRL1, CTRL1_TXPWD|CTRL1_RXPWD);
 
 			refrigerator(PF_IOTHREAD);
 
-			stir_reset(stir);
+			if (change_speed(stir, stir->speed))
+				break;
 		}
 
 		/* if something to send? */
-		if (test_and_clear_bit(STIR_STATE_TXREADY, &stir->state)) {
-			unsigned new_speed = stir->tx_newspeed;
-
-			/* Note that we may both send a packet and
-			 * change speed in some cases. Jean II */
-
-			if (stir->tx_len != 0)
-				stir_send(stir);
-
-			if (stir->speed != new_speed)
-				change_speed(stir, new_speed);
-
-			netif_wake_queue(stir->netdev);
+		skb = xchg(&stir->tx_pending, NULL);
+		if (skb) {
+			unsigned new_speed = irda_get_next_speed(skb);
+			netif_wake_queue(dev);
+
+			if (skb->len > 0)
+				stir_send(stir, skb);
+			dev_kfree_skb(skb);
+
+			if (stir->speed != new_speed) {
+				if (fifo_txwait(stir, -1) ||
+				    change_speed(stir, new_speed))
+					break;
+			}
 			continue;
 		}
 
-		if (irda_device_txqueue_empty(dev))
-			receive_start(stir);
+		/* nothing to send? start receiving */
+		if (!stir->receiving 
+		    && irda_device_txqueue_empty(dev)) {
+			/* Wait otherwise chip gets confused. */
+			if (fifo_txwait(stir, -1))
+				break;
+
+			if (unlikely(receive_start(stir))) {
+				if (net_ratelimit())
+					info("%s: receive usb submit failed",
+					     stir->netdev->name);
+				stir->receiving = 0;
+				wait_ms(10);
+				continue;
+			}
+		}
 
-		set_task_state(current, TASK_INTERRUPTIBLE);
-		add_wait_queue(&stir->thr_wait, &wait);
-		if (test_bit(STIR_STATE_TXREADY, &stir->state))
-			__set_task_state(current, TASK_RUNNING);
-		else
-			schedule_timeout(HZ/10);
-		remove_wait_queue(&stir->thr_wait, &wait);
+		/* sleep if nothing to send */
+		wait_event_interruptible(stir->thr_wait, stir->tx_pending);
 	}
 
 	complete_and_exit (&stir->thr_exited, 0);
@@ -841,48 +824,34 @@ static int stir_transmit_thread(void *ar
 
 
 /*
- * Receive wrapped data into rx_data buffer.
- * This chip doesn't block until data is available, we just have
- * to read the FIFO perodically (ugh).
+ * USB bulk receive completion callback.
+ * Wakes up every ms (usb round trip) with wrapped 
+ * data.
  */
-static void stir_usb_receive(struct urb *urb, struct pt_regs *regs)
+static void stir_rcv_irq(struct urb *urb, struct pt_regs *regs)
 {
 	struct stir_cb *stir = urb->context;
 	int err;
 
+	/* in process of stopping, just drop data */
 	if (!netif_running(stir->netdev))
 		return;
 
-	switch (urb->status) {
-	case 0:
-		if(urb->actual_length > 0) {
-			pr_debug("%s: receive %d\n",
-				 stir->netdev->name, urb->actual_length);
-			unwrap_chars(stir, urb->transfer_buffer,
-				     urb->actual_length);
-
-			stir->netdev->last_rx = jiffies;
-			stir->rx_time = CURRENT_TIME;
-		}
-		break;
-
-	case -ECONNRESET:	/* killed but pending */
-	case -ENOENT:		/* killed but not in use */
-	case -ESHUTDOWN:
-		/* These are normal errors when URB is cancelled */
-		stir->rx_buff.in_frame = FALSE;
-		stir->rx_buff.state = OUTSIDE_FRAME;
+	/* unlink, shutdown, unplug, other nasties */
+	if (urb->status != 0) 
 		return;
 
-	default:
-		WARNING("%s: received status %d\n", stir->netdev->name,
-			urb->status);
-		stir->stats.rx_errors++;
-		urb->status = 0;
+	if (urb->actual_length > 0) {
+		pr_debug("receive %d\n", urb->actual_length);
+		unwrap_chars(stir, urb->transfer_buffer,
+			     urb->actual_length);
+		
+		stir->netdev->last_rx = jiffies;
+		do_gettimeofday(&stir->rx_time);
 	}
 
 	/* kernel thread is stopping receiver don't resubmit */
-	if (!test_bit(STIR_STATE_RECEIVING, &stir->state))
+	if (!stir->receiving)
 		return;
 
 	/* resubmit existing urb */
@@ -890,14 +859,13 @@ static void stir_usb_receive(struct urb 
 
 	/* in case of error, the kernel thread will restart us */
 	if (err) {
-		WARNING("%s: usb receive submit error: %d\n",
+		warn("%s: usb receive submit error: %d",
 			stir->netdev->name, err);
-		urb->status = -ENOENT;
+		stir->receiving = 0;
 		wake_up(&stir->thr_wait);
 	}
 }
 
-
 /*
  * Function stir_net_open (dev)
  *
@@ -906,50 +874,50 @@ static void stir_usb_receive(struct urb 
 static int stir_net_open(struct net_device *netdev)
 {
 	struct stir_cb *stir = netdev->priv;
-	int i, err;
-	char	hwname[16];
+	int err;
+	char hwname[16];
 
-	err = stir_reset(stir);
+	err = usb_clear_halt(stir->usbdev, usb_sndbulkpipe(stir->usbdev, 1));
+	if (err)
+		goto err_out1;
+	err = usb_clear_halt(stir->usbdev, usb_rcvbulkpipe(stir->usbdev, 2));
 	if (err)
 		goto err_out1;
 
-	err = -ENOMEM;
-
-	/* Note: Max SIR frame possible is 4273 */
-	stir->tx_data = kmalloc(STIR_FIFO_SIZE, GFP_KERNEL);
-	if (!stir->tx_data) {
-		ERROR("%s(), alloc failed for rxbuf!\n", __FUNCTION__);
+	err = change_speed(stir, 9600);
+	if (err)
 		goto err_out1;
-	}
+
+	err = -ENOMEM;
 
 	/* Initialize for SIR/FIR to copy data directly into skb.  */
+	stir->receiving = 0;
 	stir->rx_buff.truesize = IRDA_SKB_MAX_MTU;
 	stir->rx_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
-	if (!stir->rx_buff.skb) {
-		ERROR("%s(), dev_alloc_skb() failed for rxbuf!\n",
-		      __FUNCTION__);
-		goto err_out2;
-	}
+	if (!stir->rx_buff.skb) 
+		goto err_out1;
+
 	skb_reserve(stir->rx_buff.skb, 1);
 	stir->rx_buff.head = stir->rx_buff.skb->data;
-	stir->rx_time = CURRENT_TIME;
+	do_gettimeofday(&stir->rx_time);
 
-	/* Allocate N receive buffer's and urbs */
-	for (i = 0; i < NUM_RX_URBS; i++) {
-		stir->rx_urbs[i] = usb_alloc_urb(0, GFP_KERNEL);
-		if (!stir->rx_urbs[i]){
-			ERROR("%s(), usb_alloc_urb failed\n", __FUNCTION__);
-			goto err_out3;
-		}
+	stir->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!stir->rx_urb) 
+		goto err_out2;
 
-		stir->rx_data[i] = kmalloc(STIR_FIFO_SIZE, GFP_KERNEL);
-		if (!stir->rx_data) {
-			usb_free_urb(stir->rx_urbs[i]);
-			ERROR("%s(), alloc failed for rxbuf!\n", __FUNCTION__);
-			goto err_out3;
-		}
-	}
+	stir->io_buf = kmalloc(STIR_FIFO_SIZE, GFP_KERNEL);
+	if (!stir->io_buf)
+		goto err_out3;
 
+	usb_fill_bulk_urb(stir->rx_urb, stir->usbdev,
+			  usb_rcvbulkpipe(stir->usbdev, 2),
+			  stir->io_buf, STIR_FIFO_SIZE,
+			  stir_rcv_irq, stir);
+
+	stir->fifo_status = kmalloc(FIFO_REGS_SIZE, GFP_KERNEL);
+	if (!stir->fifo_status) 
+		goto err_out4;
+		
 	/*
 	 * Now that everything should be initialized properly,
 	 * Open new IrLAP layer instance to take care of us...
@@ -958,8 +926,8 @@ static int stir_net_open(struct net_devi
 	sprintf(hwname, "usb#%d", stir->usbdev->devnum);
 	stir->irlap = irlap_open(netdev, &stir->qos, hwname);
 	if (!stir->irlap) {
-		ERROR("%s(): irlap_open failed\n", __FUNCTION__);
-		goto err_out3;
+		err("irlap_open failed");
+		goto err_out5;
 	}
 
 	/** Start kernel thread for transmit.  */
@@ -967,25 +935,24 @@ static int stir_net_open(struct net_devi
 				      CLONE_FS|CLONE_FILES);
 	if (stir->thr_pid < 0) {
 		err = stir->thr_pid;
-		WARNING("%s: unable to start kernel thread\n",
-			stir->netdev->name);
-		goto err_out4;
+		err("unable to start kernel thread");
+		goto err_out6;
 	}
 
 	netif_start_queue(netdev);
 
 	return 0;
 
- err_out4:
+ err_out6:
 	irlap_close(stir->irlap);
+ err_out5:
+	kfree(stir->fifo_status);
+ err_out4:
+	kfree(stir->io_buf);
  err_out3:
-	while(--i >= 0) {
-		usb_free_urb(stir->rx_urbs[i]);
-		kfree(stir->rx_data[i]);
-	}
-	kfree_skb(stir->rx_buff.skb);
+	usb_free_urb(stir->rx_urb);
  err_out2:
-	kfree(stir->tx_data);
+	kfree_skb(stir->rx_buff.skb);
  err_out1:
 	return err;
 }
@@ -999,7 +966,6 @@ static int stir_net_open(struct net_devi
 static int stir_net_close(struct net_device *netdev)
 {
 	struct stir_cb *stir = netdev->priv;
-	int i;
 
 	/* Stop transmit processing */
 	netif_stop_queue(netdev);
@@ -1007,15 +973,13 @@ static int stir_net_close(struct net_dev
 	/* Kill transmit thread */
 	kill_proc(stir->thr_pid, SIGTERM, 1);
 	wait_for_completion(&stir->thr_exited);
-	kfree(stir->tx_data);
-
-	clear_bit(STIR_STATE_RECEIVING, &stir->state);
-	receive_stop(stir);
+	kfree(stir->fifo_status);
 
-	for (i = 0; i < NUM_RX_URBS; i++) {
-		usb_free_urb(stir->rx_urbs[i]);
-		kfree(stir->rx_data[i]);
-	}
+	/* Mop up receive urb's */
+	usb_unlink_urb(stir->rx_urb);
+	
+	kfree(stir->io_buf);
+	usb_free_urb(stir->rx_urb);
 	kfree_skb(stir->rx_buff.skb);
 
 	/* Stop and remove instance of IrLAP */
@@ -1057,7 +1021,7 @@ static int stir_net_ioctl(struct net_dev
 
 	case SIOCGRECEIVING:
 		/* Only approximately true */
-		irq->ifr_receiving = test_bit(STIR_STATE_RECEIVING, &stir->state);
+		irq->ifr_receiving = stir->receiving;
 		break;
 
 	default:
@@ -1077,53 +1041,6 @@ static struct net_device_stats *stir_net
 }
 
 /*
- *    Parse the various endpoints and find the one we need.
- *
- * The endpoint are the pipes used to communicate with the USB device.
- * The spec defines 2 endpoints of type bulk transfer, one in, and one out.
- * These are used to pass frames back and forth with the dongle.
- */
-static int stir_setup_usb(struct stir_cb *stir, struct usb_interface *intf)
-{
-	struct usb_device *usbdev = interface_to_usbdev(intf);
-	const struct usb_host_interface *interface
-		= &intf->altsetting[intf->act_altsetting];
-	const struct usb_endpoint_descriptor *ep_in = NULL;
-	const struct usb_endpoint_descriptor *ep_out = NULL;
-	int i;
-
-	if (interface->desc.bNumEndpoints != 2) {
-		WARNING("%s: expected two endpoints\n", __FUNCTION__);
-		return -ENODEV;
-	}
-
-	for(i = 0; i < interface->desc.bNumEndpoints; i++) {
-		const struct usb_endpoint_descriptor *ep
-			= &interface->endpoint[i].desc;
-
-		if ((ep->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK)
-		    == USB_ENDPOINT_XFER_BULK) {
-			/* We need to find an IN and an OUT */
-			if ((ep->bEndpointAddress & USB_ENDPOINT_DIR_MASK) == USB_DIR_IN)
-				ep_in = ep;
-			else
-				ep_out = ep;
-		} else
-			WARNING("%s: unknown endpoint type 0x%x\n",
-				__FUNCTION__, ep->bmAttributes);
-	}
-
-	if (!ep_in || !ep_out)
-		return -EIO;
-
-	stir->tx_bulkpipe = usb_sndbulkpipe(usbdev,
-			    ep_out->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
-	stir->rx_intpipe = usb_rcvintpipe(usbdev,
-			    ep_in->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
-	return 0;
-}
-
-/*
  * This routine is called by the USB subsystem for each new device
  * in the system. We need to check if the device is ours, and in
  * this case start handling it.
@@ -1149,9 +1066,9 @@ static int stir_probe(struct usb_interfa
 	stir->netdev = net;
 	stir->usbdev = dev;
 
-	ret = stir_setup_usb(stir, intf);
+	ret = usb_reset_configuration(dev);
 	if (ret != 0) {
-		ERROR("%s(), Bogus endpoints...\n", __FUNCTION__);
+		err("usb reset configuration failed");
 		goto err_out2;
 	}
 
@@ -1180,10 +1097,6 @@ static int stir_probe(struct usb_interfa
 	net->get_stats	     = stir_net_get_stats;
 	net->do_ioctl        = stir_net_ioctl;
 
-	ret = stir_reset(stir);
-	if (ret)
-		goto err_out2;
-
 	ret = register_netdev(net);
 	if (ret != 0)
 		goto err_out2;
@@ -1206,23 +1119,14 @@ err_out1:
 static void stir_disconnect(struct usb_interface *intf)
 {
 	struct stir_cb *stir = usb_get_intfdata(intf);
-	struct net_device *net;
 
-	usb_set_intfdata(intf, NULL);
 	if (!stir)
 		return;
 
-	/* Stop transmitter */
-	net = stir->netdev;
-	netif_device_detach(net);
-
-	/* Remove netdevice */
-	unregister_netdev(net);
-
-	/* No longer attached to USB bus */
-	stir->usbdev = NULL;
+	unregister_netdev(stir->netdev);
+	free_netdev(stir->netdev);
 
-	free_netdev(net);
+	usb_set_intfdata(intf, NULL);
 }
 
 
