From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] stir4200 - new version
Date: Fri, 27 Feb 2004 15:44:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040227154452.680613b7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>, Martin Diehl <lists@mdiehl.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the latest stir4200 driver for testing. The diff is against 2.6.3-bk9.

The major change is getting rid of using the receive interrupt pipe.
I could never get it to work reliably with FIR; it would miss frames.
Performance is way better.

Still not reliable in FIR with large packet sizes..
Also, the whole timer scheme will die if HZ=100 because then the granularity
is too big.

--- linux-2.6/drivers/net/irda/stir4200.c	2004-02-18 14:14:14.000000000 -0800
+++ test-2.6/drivers/net/irda/stir4200.c	2004-02-27 15:37:04.236288689 -0800
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
@@ -72,7 +74,7 @@
 module_param(tx_power, int, 0);
 MODULE_PARM_DESC(tx_power, "Set Transmitter power (0-3, 0 is highest power)");
 
-static int rx_interval = 5;  /* milliseconds */
+static int rx_interval = 4;  /* milliseconds */
 module_param(rx_interval, int, 0);
 MODULE_PARM_DESC(rx_interval, "Receive polling interval (ms)");
 
@@ -80,7 +82,6 @@
 #define CTRL_TIMEOUT		100	   /* milliseconds */
 #define TRANSMIT_TIMEOUT	200	   /* milliseconds */
 #define STIR_FIFO_SIZE		4096
-#define NUM_RX_URBS		2
 
 enum FirChars {
 	FIR_CE   = 0x7d,
@@ -167,36 +168,27 @@
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
+	spinlock_t	  tx_lock;
+	struct sk_buff	  *tx_pending;
 
-	unsigned int	  rx_intpipe;
 	iobuff_t  	  rx_buff;	/* receive unwrap state machine */
-	struct timespec	  rx_time;
-
-	struct urb	 *rx_urbs[NUM_RX_URBS];
-	void		 *rx_data[NUM_RX_URBS];
+	struct timeval	  rx_time;
+	int		  rx_receiving;
+	struct urb	 *rx_urb;
+	void		 *rx_data;
+	struct timer_list rx_poll_timer;
 };
 
 
@@ -209,7 +201,6 @@
 
 MODULE_DEVICE_TABLE(usb, dongles);
 
-static int fifo_txwait(struct stir_cb *stir, unsigned space);
 static void stir_usb_receive(struct urb *urb, struct pt_regs *regs);
 
 /* Send control message to set dongle register */
@@ -239,6 +230,11 @@
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
@@ -310,12 +306,13 @@
 	return wraplen + STIR_IRDA_HEADER;
 }
 
-static unsigned wrap_sir_skb(struct sk_buff *skb, __u8 *buf)
+static unsigned wrap_sir_skb(struct sk_buff *skb, __u8 *buf, 
+			     unsigned space)
 {
 	__u16 wraplen;
 
 	wraplen = async_wrap_skb(skb, buf + STIR_IRDA_HEADER,
-				 STIR_FIFO_SIZE - STIR_IRDA_HEADER);
+				 space - STIR_IRDA_HEADER);
 	buf[0] = 0x55;
 	buf[1] = 0xAA;
 	buf[2] = wraplen & 0xff;
@@ -325,6 +322,43 @@
 }
 
 /*
+ * Take raw data and encapsulate as appropriate into
+ * a new socket buffer.
+ */         
+static struct sk_buff *wrap_skb(struct sk_buff *skb, unsigned speed)
+{
+	struct sk_buff *nskb;
+	unsigned len;
+
+	/* 
+	 * need enough space for worst case
+	 * In addition to the stir-header we need 1 byte for each BOF+EOF
+	 * plus space for the whole data and 16-bit CRC all probably escaped
+	 * and thus doubled in size. Furthermore, depending on negotiation
+	 * and/or turnaround delay there might be up to 163 xbofs.
+	 * And we need to be careful with non-SIR speeds where we have
+	 * 2+2 bytes for BOF/EOF and in the case of FIR even further
+	 * 16 PA-bytes. And FIR-CRC is 32 bit, not 16.
+	 */
+	if (isfir(speed))
+		len = STIR_IRDA_HEADER + 16 + 2 + 2*skb->len + 8 + 2;
+	else
+		len = STIR_IRDA_HEADER + 163 + 2*skb->len + 4 + 1;
+
+	nskb = dev_alloc_skb(len);
+	if (likely(nskb)) {
+		if (isfir(speed))
+			len = wrap_fir_skb(skb, nskb->data);
+		else
+			len = wrap_sir_skb(skb, nskb->data, len);
+		
+		skb_put(nskb, len);
+	}
+
+	return nskb;
+}
+
+/*
  * Frame is fully formed in the rx_buff so check crc
  * and pass up to irlap
  * setup for next receive
@@ -333,8 +367,8 @@
 {
 	iobuff_t *rx_buff = &stir->rx_buff;
 	int len = rx_buff->len - 4;
+	struct sk_buff *skb, *nskb;
 	__u32 fcs;
-	struct sk_buff *nskb;
 
 	if (unlikely(len <= 0)) {
 		pr_debug("%s: short frame len %d\n",
@@ -345,41 +379,46 @@
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
 		skb_reserve(nskb, 1);
+		skb = nskb;
+		memcpy(nskb->data, rx_buff->data, len);
+	} else {
+		nskb = dev_alloc_skb(rx_buff->truesize);
+		if (unlikely(!nskb)) {
+			++stir->stats.rx_dropped;
+			return;
+		}
+		skb_reserve(nskb, 1);
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
@@ -402,7 +441,6 @@
 				continue;
 			/* Now receiving frame */
 			rx_buff->state = BEGIN_FRAME;
-			rx_buff->in_frame = TRUE;
 
 			/* Time to initialize receive buffer */
 			rx_buff->data = rx_buff->head;
@@ -424,6 +462,7 @@
 			if (byte == FIR_EOF)
 				continue;
 			rx_buff->state = INSIDE_FRAME;
+			rx_buff->in_frame = TRUE;
 
 			/* fall through */
 		case INSIDE_FRAME:
@@ -461,7 +500,6 @@
 
 	error_recovery:
 		++stir->stats.rx_errors;
-		irda_device_set_media_busy(stir->netdev, TRUE);
 		rx_buff->state = OUTSIDE_FRAME;
 		rx_buff->in_frame = FALSE;
 	}
@@ -478,11 +516,6 @@
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
@@ -519,25 +552,26 @@
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
@@ -564,33 +598,13 @@
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
 
@@ -606,43 +620,49 @@
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
+	spin_lock(&stir->tx_lock);
+	skb = xchg(&stir->tx_pending, skb);
+	wake_up(&stir->thr_wait);
+	spin_unlock(&stir->tx_lock);
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
 	__u8 regs[3];
-	unsigned long timeout = jiffies + HZ/10;
 
-	for(;;) {
-		/* Read FIFO status and count */
-		err = read_reg(stir, REG_FIFOCTL, regs, 3);
-		if (unlikely(err != 3)) {
-			WARNING("%s: FIFO register read error: %d\n",
-				stir->netdev->name, err);
-			return err;
+	/* Read FIFO status and count */
+	while ((err = read_reg(stir, REG_FIFOCTL, regs, 3)) == 3) {
+		unsigned count;
+
+		count = (unsigned)(regs[2] & 0x1f) << 8 | regs[1];
+		pr_debug("fifo status 0x%x count %u\n", regs[0], count);
+
+		/* error when receive/transmit fifo gets confused */
+		if (regs[0] & FIFOCTL_RXERR) {
+			stir->stats.rx_fifo_errors++;
+			stir->stats.rx_errors++;
+			goto clear_fifo;
+		}
+
+		if (regs[0] & FIFOCTL_TXERR) {
+			stir->stats.tx_fifo_errors++;
+			stir->stats.tx_errors++;
+			goto clear_fifo;
 		}
 
 		/* is fifo receiving already, or empty */
@@ -658,40 +678,42 @@
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
+	warn("%s: FIFO register read error: %d", stir->netdev->name, err);
+
+	return err;
+			
+ clear_fifo:
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
 
@@ -709,75 +731,71 @@
  */
 static void receive_start(struct stir_cb *stir)
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
+	int rc;
 
-		usb_fill_int_urb(urb, stir->usbdev, stir->rx_intpipe,
-				 stir->rx_data[i], STIR_FIFO_SIZE,
-				 stir_usb_receive, stir, rx_interval);
+	/* reset state */
+	stir->rx_receiving = 1;
 
-		if (usb_submit_urb(urb, GFP_KERNEL))
-			urb->status = -EINVAL;
-	}
+	stir->rx_buff.in_frame = FALSE;
+	stir->rx_buff.state = OUTSIDE_FRAME;
 
-	if (i == 0) {
-		/* if nothing got queued, then just retry next time */
-		if (net_ratelimit())
-			WARNING("%s: no receive buffers avaiable\n",
-				stir->netdev->name);
+	stir->rx_urb->status = 0;
+	usb_fill_bulk_urb(stir->rx_urb, stir->usbdev,
+			  usb_rcvbulkpipe(stir->usbdev, 2),
+			  stir->rx_data, STIR_FIFO_SIZE,
+			  stir_usb_receive, stir);
+
+	rc = usb_submit_urb(stir->rx_urb, GFP_KERNEL);
+	if (rc) {
+		info("%s: receive usb submit failed %d",
+		     stir->netdev->name, rc);
 
-		clear_bit(STIR_STATE_RECEIVING, &stir->state);
+		stir->rx_receiving = 0;
 	}
 }
 
 /* Stop all pending receive Urb's */
 static void receive_stop(struct stir_cb *stir)
 {
-	int i;
+	stir->rx_receiving = 0;
+	del_timer_sync(&stir->rx_poll_timer);
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
-
-	if (test_and_clear_bit(STIR_STATE_RECEIVING, &stir->state)) {
-		receive_stop(stir);
+	struct sk_buff *wskb = wrap_skb(skb, stir->speed);
 
-		turnaround_delay(stir->tx_mtt, &stir->rx_time);
+	if (unlikely(!wskb)) {
+		stir->stats.tx_errors++;
+		return;
+	}
 
-		if (stir->rx_buff.in_frame)
-			++stir->stats.collisions;
+	/* if receiving, need to turnaround */
+	if (stir->rx_receiving) {
+		receive_stop(stir);
+		turnaround_delay(stir, irda_get_mtt(skb));
 	}
-	else if (fifo_txwait(stir, stir->tx_len))
-		return; /* shutdown or major errors */
+	else if (fifo_txwait(stir, wskb->len))
+		goto out;	/* shutdown or error don't send */
 
+	stir->stats.tx_packets++;
+	stir->stats.tx_bytes += skb->len;
 	stir->netdev->trans_start = jiffies;
 
-	pr_debug("%s: send %d\n", stir->netdev->name, stir->tx_len);
-	rc = usb_bulk_msg(stir->usbdev,
-			  stir->tx_bulkpipe,
-			  stir->tx_data, stir->tx_len,
-			  NULL, MSECS_TO_JIFFIES(TRANSMIT_TIMEOUT));
-
-	if (unlikely(rc)) {
-		WARNING("%s: usb bulk message failed %d\n",
-			stir->netdev->name, rc);
+	pr_debug("send %d (%d)\n", skb->len, wskb->len);
+	if (usb_bulk_msg(stir->usbdev, usb_sndbulkpipe(stir->usbdev, 1),
+			 wskb->data, wskb->len,
+			 NULL, MSECS_TO_JIFFIES(TRANSMIT_TIMEOUT))) 
 		stir->stats.tx_errors++;
-	}
+
+ out:
+	dev_kfree_skb(wskb);
 }
 
 /*
@@ -787,6 +805,7 @@
 {
 	struct stir_cb *stir = arg;
 	struct net_device *dev = stir->netdev;
+	struct sk_buff *skb;
 	DECLARE_WAITQUEUE(wait, current);
 
 	daemonize("%s", dev->name);
@@ -796,44 +815,59 @@
 	       && netif_device_present(dev)
 	       && !signal_pending(current))
 	{
-		/* make swsusp happy with our thread */
+		/* if suspending, then power off and wait */
 		if (current->flags & PF_FREEZE) {
-			receive_stop(stir);
+			if (stir->rx_receiving)
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
+		/* nothing to send? start receiving */
+		if (!stir->rx_receiving 
+		    && irda_device_txqueue_empty(dev)) {
+			/* Wait otherwise chip gets confused. */
+			if (fifo_txwait(stir, -1))
+				break;
 			receive_start(stir);
+		}
 
-		set_task_state(current, TASK_INTERRUPTIBLE);
-		add_wait_queue(&stir->thr_wait, &wait);
-		if (test_bit(STIR_STATE_TXREADY, &stir->state))
-			__set_task_state(current, TASK_RUNNING);
-		else
-			schedule_timeout(HZ/10);
-		remove_wait_queue(&stir->thr_wait, &wait);
+		/* sleep if nothing to send */
+		spin_lock(&stir->tx_lock);
+		if (!stir->tx_pending) {
+			set_task_state(current, TASK_INTERRUPTIBLE);
+			add_wait_queue(&stir->thr_wait, &wait);
+			spin_unlock(&stir->tx_lock);
+			schedule();
+			spin_lock(&stir->tx_lock);
+			remove_wait_queue(&stir->thr_wait, &wait);
+		}
+		spin_unlock(&stir->tx_lock);
 	}
 
 	complete_and_exit (&stir->thr_exited, 0);
@@ -848,56 +882,41 @@
 static void stir_usb_receive(struct urb *urb, struct pt_regs *regs)
 {
 	struct stir_cb *stir = urb->context;
-	int err;
-
-	if (!netif_running(stir->netdev))
-		return;
 
-	switch (urb->status) {
-	case 0:
-		if(urb->actual_length > 0) {
-			pr_debug("%s: receive %d\n",
-				 stir->netdev->name, urb->actual_length);
+	if (stir->rx_receiving && urb->status == 0) {
+		if (urb->actual_length > 0) {
+			pr_debug("receive %d\n", urb->actual_length);
 			unwrap_chars(stir, urb->transfer_buffer,
 				     urb->actual_length);
-
+		
 			stir->netdev->last_rx = jiffies;
-			stir->rx_time = CURRENT_TIME;
+			do_gettimeofday(&stir->rx_time);
 		}
-		break;
-
-	case -ECONNRESET:	/* killed but pending */
-	case -ENOENT:		/* killed but not in use */
-	case -ESHUTDOWN:
-		/* These are normal errors when URB is cancelled */
-		stir->rx_buff.in_frame = FALSE;
-		stir->rx_buff.state = OUTSIDE_FRAME;
-		return;
 
-	default:
-		WARNING("%s: received status %d\n", stir->netdev->name,
-			urb->status);
-		stir->stats.rx_errors++;
-		urb->status = 0;
+		mod_timer(&stir->rx_poll_timer, 
+			  jiffies + MSECS_TO_JIFFIES(rx_interval));
 	}
+}
 
-	/* kernel thread is stopping receiver don't resubmit */
-	if (!test_bit(STIR_STATE_RECEIVING, &stir->state))
-		return;
-
-	/* resubmit existing urb */
-	err = usb_submit_urb(urb, GFP_ATOMIC);
+/*
+ * Timeout after last receive, time to resubmit
+ */
+static void stir_poll_timeout(unsigned long data)
+{
+	struct stir_cb *stir = (struct stir_cb *) data;
+	int err;
 
-	/* in case of error, the kernel thread will restart us */
+	/* Resubmit same urb to pick up more data */
+	err = usb_submit_urb(stir->rx_urb, GFP_ATOMIC);
 	if (err) {
-		WARNING("%s: usb receive submit error: %d\n",
-			stir->netdev->name, err);
-		urb->status = -ENOENT;
+		stir->rx_receiving = 0;
 		wake_up(&stir->thr_wait);
+		warn("usb resubmit failed %d", err);
 	}
 }
 
 
+
 /*
  * Function stir_net_open (dev)
  *
@@ -906,48 +925,46 @@
 static int stir_net_open(struct net_device *netdev)
 {
 	struct stir_cb *stir = netdev->priv;
-	int i, err;
+	int err;
 	char	hwname[16];
 
-	err = stir_reset(stir);
+	err = usb_clear_halt(stir->usbdev, usb_sndbulkpipe(stir->usbdev, 1));
+	if (err)
+		goto err_out1;
+	err = usb_clear_halt(stir->usbdev, usb_rcvbulkpipe(stir->usbdev, 2));
+	if (err)
+		goto err_out1;
+	err = change_speed(stir, 9600);
 	if (err)
 		goto err_out1;
 
 	err = -ENOMEM;
 
-	/* Note: Max SIR frame possible is 4273 */
-	stir->tx_data = kmalloc(STIR_FIFO_SIZE, GFP_KERNEL);
-	if (!stir->tx_data) {
-		ERROR("%s(), alloc failed for rxbuf!\n", __FUNCTION__);
-		goto err_out1;
-	}
-
 	/* Initialize for SIR/FIR to copy data directly into skb.  */
+	stir->rx_receiving = 0;
+	init_timer(&stir->rx_poll_timer);
+	stir->rx_poll_timer.function = stir_poll_timeout;
+	stir->rx_poll_timer.data = (unsigned long) stir;
 	stir->rx_buff.truesize = IRDA_SKB_MAX_MTU;
 	stir->rx_buff.skb = dev_alloc_skb(IRDA_SKB_MAX_MTU);
 	if (!stir->rx_buff.skb) {
-		ERROR("%s(), dev_alloc_skb() failed for rxbuf!\n",
-		      __FUNCTION__);
-		goto err_out2;
+		err("dev_alloc_skb() failed for rxbuf!");
+		goto err_out1;
 	}
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
+	if (!stir->rx_urb) {
+		err("usb_alloc_urb failed");
+		goto err_out2;
+	}
 
-		stir->rx_data[i] = kmalloc(STIR_FIFO_SIZE, GFP_KERNEL);
-		if (!stir->rx_data) {
-			usb_free_urb(stir->rx_urbs[i]);
-			ERROR("%s(), alloc failed for rxbuf!\n", __FUNCTION__);
-			goto err_out3;
-		}
+	stir->rx_data = kmalloc(STIR_FIFO_SIZE, GFP_KERNEL);
+	if (!stir->rx_data) {
+		err("alloc failed for rxbuf");
+		goto err_out3;
 	}
 
 	/*
@@ -958,8 +975,8 @@
 	sprintf(hwname, "usb#%d", stir->usbdev->devnum);
 	stir->irlap = irlap_open(netdev, &stir->qos, hwname);
 	if (!stir->irlap) {
-		ERROR("%s(): irlap_open failed\n", __FUNCTION__);
-		goto err_out3;
+		err("irlap_open failed");
+		goto err_out4;
 	}
 
 	/** Start kernel thread for transmit.  */
@@ -967,25 +984,22 @@
 				      CLONE_FS|CLONE_FILES);
 	if (stir->thr_pid < 0) {
 		err = stir->thr_pid;
-		WARNING("%s: unable to start kernel thread\n",
-			stir->netdev->name);
-		goto err_out4;
+		err("unable to start kernel thread");
+		goto err_out5;
 	}
 
 	netif_start_queue(netdev);
 
 	return 0;
 
- err_out4:
+ err_out5:
 	irlap_close(stir->irlap);
+ err_out4:
+	kfree(stir->rx_data);
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
@@ -999,7 +1013,6 @@
 static int stir_net_close(struct net_device *netdev)
 {
 	struct stir_cb *stir = netdev->priv;
-	int i;
 
 	/* Stop transmit processing */
 	netif_stop_queue(netdev);
@@ -1007,15 +1020,11 @@
 	/* Kill transmit thread */
 	kill_proc(stir->thr_pid, SIGTERM, 1);
 	wait_for_completion(&stir->thr_exited);
-	kfree(stir->tx_data);
 
-	clear_bit(STIR_STATE_RECEIVING, &stir->state);
-	receive_stop(stir);
-
-	for (i = 0; i < NUM_RX_URBS; i++) {
-		usb_free_urb(stir->rx_urbs[i]);
-		kfree(stir->rx_data[i]);
-	}
+	/* Mop up receive urb's */
+	usb_unlink_urb(stir->rx_urb);
+	usb_free_urb(stir->rx_urb);
+	kfree(stir->rx_data);
 	kfree_skb(stir->rx_buff.skb);
 
 	/* Stop and remove instance of IrLAP */
@@ -1057,7 +1066,7 @@
 
 	case SIOCGRECEIVING:
 		/* Only approximately true */
-		irq->ifr_receiving = test_bit(STIR_STATE_RECEIVING, &stir->state);
+		irq->ifr_receiving = stir->rx_receiving;
 		break;
 
 	default:
@@ -1077,53 +1086,6 @@
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
@@ -1149,9 +1111,9 @@
 	stir->netdev = net;
 	stir->usbdev = dev;
 
-	ret = stir_setup_usb(stir, intf);
+	ret = usb_reset_configuration(dev);
 	if (ret != 0) {
-		ERROR("%s(), Bogus endpoints...\n", __FUNCTION__);
+		err("usb reset configuration failed");
 		goto err_out2;
 	}
 
@@ -1172,6 +1134,7 @@
 
 	init_completion (&stir->thr_exited);
 	init_waitqueue_head (&stir->thr_wait);
+	spin_lock_init(&stir->tx_lock);
 
 	/* Override the network functions we need to use */
 	net->hard_start_xmit = stir_hard_xmit;
@@ -1180,10 +1143,6 @@
 	net->get_stats	     = stir_net_get_stats;
 	net->do_ioctl        = stir_net_ioctl;
 
-	ret = stir_reset(stir);
-	if (ret)
-		goto err_out2;
-
 	ret = register_netdev(net);
 	if (ret != 0)
 		goto err_out2;
@@ -1206,23 +1165,14 @@
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
+	unregister_netdev(stir->netdev);
+	free_netdev(stir->netdev);
 
-	/* No longer attached to USB bus */
-	stir->usbdev = NULL;
-
-	free_netdev(net);
+	usb_set_intfdata(intf, NULL);
 }
 
 
