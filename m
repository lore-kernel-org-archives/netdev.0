From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [RFT] stir4200 - new version
Date: Tue, 2 Mar 2004 00:22:21 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403012344400.1408-100000@notebook.home.mdiehl.de>
References: <20040227154452.680613b7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040227154452.680613b7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 27 Feb 2004, Stephen Hemminger wrote:

> Here is the latest stir4200 driver for testing. The diff is against 2.6.3-bk9.

Thanks Stephen,
some feedback here, while we are fighting with the usb-issues...

> The major change is getting rid of using the receive interrupt pipe.
> I could never get it to work reliably with FIR; it would miss frames.
> Performance is way better.

Agreed, I get better performance too. I still believe the interrupt rx-urb 
would be the better approach due to the latencies. The bulk-urb 
resubmitted by a timer needs: 1 msec for submission + up to 2 msec for 
completion (uhci) + poll-timer delay + timer latency. Even with HZ=1000 I 
believe it's not possible to guarantee a min poll rate < 4 msec. At FIR 
with a lot of transparency-escapes the fifo get filled at a rate of 
1MB/sec so it might be overrun meanwhile. Maybe some double-buffering 
would help...

> Still not reliable in FIR with large packet sizes..

Yep, I don't see some significant change wrt. to the FIFO stalls/lockups. 
Additionally, the new issues with ohci-hcd are now - let's see...

> +	if (isfir(speed))
> +		len = STIR_IRDA_HEADER + 16 + 2 + 2*skb->len + 8 + 2;
> +	else
> +		len = STIR_IRDA_HEADER + 163 + 2*skb->len + 4 + 1;

off-by-one: in SIR there is also a BOF between the XBOF and data

> +	nskb = dev_alloc_skb(len);
> +	if (likely(nskb)) {
> +		if (isfir(speed))
> +			len = wrap_fir_skb(skb, nskb->data);
> +		else
> +			len = wrap_sir_skb(skb, nskb->data, len);
> +		
> +		skb_put(nskb, len);

IMHO the tx-skb for wrapped data doesn't work: skb->data will be used as 
usb transfer buffer. However, usb-rules are the transfer buffer must be a 
separate kmalloc-entity, because we need to have it both physically 
continous and cacheline-aligned. I don't think the second promision is 
held by skb->data due to headroom f.e.?

> +static int fifo_txwait(struct stir_cb *stir, int space)
>  {
>  	__u8 regs[3];

[...]

> +	/* Read FIFO status and count */
> +	while ((err = read_reg(stir, REG_FIFOCTL, regs, 3)) == 3) {

This breakes with usb. The regs argument is used as data buffer in 
usb_control_msg - so we would end up doing DMA to the stack. We need a 
separate kmalloc-object here.

> [stir_trasnmit_thread]
> 
>  	}
>  
>  	complete_and_exit (&stir->thr_exited, 0);

AFAICS we are racing with the poll-timer here which might resubmit the 
rx-urb. IMHO calling receive_stop before completing should do the job.

Below my current patch which I'm using on top of your version.

I've done some perfomrance/stability testing with ohci/ehci. SIR seems 
just fine like it was with the last version. FIR performance is definedly 
faster, but I don't yet understand why. Still lots of fifo lockups. But if 
it's working it's rather good now: about 200KB/s tx and up to 350 KB/s rx, 
with 2KB frames and window=7 - provided it doesn't stop in the middle ;-)

Martin

-------------------------

--- v2.6.3-bk9-md/drivers/net/irda/stir4200.c.sh-20040227	Sat Feb 28 20:02:44 2004
+++ v2.6.3-bk9-md/drivers/net/irda/stir4200.c	Mon Mar  1 21:41:13 2004
@@ -323,13 +323,15 @@ static unsigned wrap_sir_skb(struct sk_b
 
 /*
  * Take raw data and encapsulate as appropriate into
- * a new socket buffer.
+ * a new tx buffer and give it back to the caller.
  */         
-static struct sk_buff *wrap_skb(struct sk_buff *skb, unsigned speed)
+static u8 *wrap_skb(struct sk_buff *skb, unsigned speed, int *wraplen)
 {
-	struct sk_buff *nskb;
+	u8 *tx_buff;
 	unsigned len;
 
+	*wraplen = 0;
+
 	/* 
 	 * need enough space for worst case
 	 * In addition to the stir-header we need 1 byte for each BOF+EOF
@@ -343,19 +345,17 @@ static struct sk_buff *wrap_skb(struct s
 	if (isfir(speed))
 		len = STIR_IRDA_HEADER + 16 + 2 + 2*skb->len + 8 + 2;
 	else
-		len = STIR_IRDA_HEADER + 163 + 2*skb->len + 4 + 1;
+		len = STIR_IRDA_HEADER + 163 + 1 + 2*skb->len + 4 + 1;
 
-	nskb = dev_alloc_skb(len);
-	if (likely(nskb)) {
+	tx_buff = kmalloc(len, GFP_KERNEL);
+	if (likely(tx_buff)) {
 		if (isfir(speed))
-			len = wrap_fir_skb(skb, nskb->data);
+			*wraplen = wrap_fir_skb(skb, tx_buff);
 		else
-			len = wrap_sir_skb(skb, nskb->data, len);
-		
-		skb_put(nskb, len);
+			*wraplen = wrap_sir_skb(skb, tx_buff, len);
 	}
 
-	return nskb;
+	return tx_buff;
 }
 
 /*
@@ -643,7 +643,14 @@ static int stir_hard_xmit(struct sk_buff
 static int fifo_txwait(struct stir_cb *stir, int space)
 {
 	int err;
-	__u8 regs[3];
+	u8 *regs;
+
+	regs = kmalloc(3, GFP_KERNEL);
+	if (regs == NULL) {
+		/* low on memory - just wait one whole 500ms window */
+		mdelay(500);
+		return -ENOMEM;
+	}
 
 	/* Read FIFO status and count */
 	while ((err = read_reg(stir, REG_FIFOCTL, regs, 3)) == 3) {
@@ -665,40 +672,46 @@ static int fifo_txwait(struct stir_cb *s
 			goto clear_fifo;
 		}
 
+		err = 0;
+
 		/* is fifo receiving already, or empty */
 		if (!(regs[0] & FIFOCTL_DIR)
 		    || (regs[0] & FIFOCTL_EMPTY))
-			return 0;
+			goto out;
 
-		if (signal_pending(current))
-			return -EINTR;
+		if (signal_pending(current)) {
+			err = -EINTR;
+			goto out;
+		}
 
 		/* shutting down? */
 		if (!netif_running(stir->netdev)
-		    || !netif_device_present(stir->netdev))
-			return -ESHUTDOWN;
+		    || !netif_device_present(stir->netdev)) {
+			err = -ESHUTDOWN;
+			goto out;
+		}
 
 		/* only waiting for some space */
 		if (space >= 0 && STIR_FIFO_SIZE - 4 > space + count)
-			return 0;
+			goto out;
 
 		/* estimate transfer time for remaining chars */
 		wait_ms((count * 8000) / stir->speed);
 	}
 	
 	warn("%s: FIFO register read error: %d", stir->netdev->name, err);
-
-	return err;
+	goto out;
 			
  clear_fifo:
 	err = write_reg(stir, REG_FIFOCTL, FIFOCTL_CLR);
 	if (err) 
-		return err;
+		goto out;
 	err = write_reg(stir, REG_FIFOCTL, 0);
-	if (err)
-		return err;
 
-	return 0;
+out:
+	kfree(regs);
+
+	return err;
 }
 
 
@@ -765,37 +778,44 @@ static void receive_stop(struct stir_cb 
 		stir->stats.collisions++;
 }
 /*
- * Wrap data in socket buffer and send it.
+ * Wrap data from skb to usb transmit buffer and send it.
  */
 static void stir_send(struct stir_cb *stir, struct sk_buff *skb)
 {
-	struct sk_buff *wskb = wrap_skb(skb, stir->speed);
+	u8 *tx_buff;
+	int wraplen;
 
-	if (unlikely(!wskb)) {
+	tx_buff = wrap_skb(skb, stir->speed, &wraplen);
+
+	if (unlikely(!tx_buff)) {
 		stir->stats.tx_errors++;
 		return;
 	}
 
+	if (unlikely(wraplen < STIR_IRDA_HEADER))
+		goto out;
+
 	/* if receiving, need to turnaround */
 	if (stir->rx_receiving) {
 		receive_stop(stir);
 		turnaround_delay(stir, irda_get_mtt(skb));
 	}
-	else if (fifo_txwait(stir, wskb->len))
+	else if (fifo_txwait(stir, wraplen))
 		goto out;	/* shutdown or error don't send */
 
 	stir->stats.tx_packets++;
 	stir->stats.tx_bytes += skb->len;
 	stir->netdev->trans_start = jiffies;
 
-	pr_debug("send %d (%d)\n", skb->len, wskb->len);
+	pr_debug("send %d (%d)\n", skb->len, wraplen);
+
 	if (usb_bulk_msg(stir->usbdev, usb_sndbulkpipe(stir->usbdev, 1),
-			 wskb->data, wskb->len,
+			 tx_buff, wraplen,
 			 NULL, MSECS_TO_JIFFIES(TRANSMIT_TIMEOUT))) 
 		stir->stats.tx_errors++;
 
  out:
-	dev_kfree_skb(wskb);
+	kfree(tx_buff);
 }
 
 /*
@@ -870,6 +890,10 @@ static int stir_transmit_thread(void *ar
 		spin_unlock(&stir->tx_lock);
 	}
 
+	/* need to del_timer_sync and unlink the urb */
+	if (stir->rx_receiving)
+		receive_stop(stir);
+
 	complete_and_exit (&stir->thr_exited, 0);
 }
 
@@ -1022,7 +1046,6 @@ static int stir_net_close(struct net_dev
 	wait_for_completion(&stir->thr_exited);
 
 	/* Mop up receive urb's */
-	usb_unlink_urb(stir->rx_urb);
 	usb_free_urb(stir->rx_urb);
 	kfree(stir->rx_data);
 	kfree_skb(stir->rx_buff.skb);
