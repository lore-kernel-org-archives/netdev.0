From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 08:24:43 -0400
Message-ID: <1154867083.6269.35.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-rnqhw2ZtOHJnW8m57OvY"
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:49887 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751444AbWHFMYs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 08:24:48 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G9hgX-0000RI-Dw
	for netdev@vger.kernel.org; Sun, 06 Aug 2006 08:24:49 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060806025123.GA27051@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rnqhw2ZtOHJnW8m57OvY
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2006-06-08 at 12:51 +1000, Herbert Xu wrote:
> On Sat, Aug 05, 2006 at 07:36:50PM -0400, jamal wrote:
> > 
> > I know the qlen is >= 0 otherwise i will hit the BUG().
> > A qlen of 0 will be interesting to find as well.
> 
> When the queue is woken it will always to qdisc_run regardless of
> whether there are packets queued so this might explain what you're
> seeing.
> 

That aligns with what i was thinking as well - i.e what i referred to as
possibly enthusiasm on part of the tx softirq.
i.e if there was nothing queued, why is the softirq even woken up?
Note, I observed this behavior to be a lot worse on systems that had
very little traffic going out. Anyways, I hope to find out.

> Anyway, I've changed the unconditional atomic op into a memory
> barrier instead.  Let me know if this changes things for you.
> 

Will try it before end of day. Machine is about 20 minutes drive from
where i am.

> I wonder if we could do the TX clean up within the transmission
> routine most of the time.  Has anyone tried this before?

I actually have - as recently as last week when i was looking at the
qdisc_is_running thing. Patch for e1000 attached. 

One of the experiments i attempted was similar to the one described by
edgar.iglesias@axis.com 
I would only clean up on the rx path if netif_stopped and the rest
happened in tx path. I tried variations of the above (ex: cleanup on tx
path only if we exceed a threshold etc).

I did not see _any_ improvement for forwarding tests ;-> 
Infact at one point i think i saw a decrease in throughput, but it may
have been within tolerance of experimental errors.

In the old days, both Robert and I did this with the tulip and it used
to be an improvement. But now that i think about it, probably the reason
was by doing so we reduced the EOT interrupts. Note, the NAPI 
approach on tulip allows that tx pruning to be done via interrupts.
I liked that approach; but most people didnt and the e1000 and tg3 is
what you see now.

My gut feeling is to let the cleaning happen in the receive path. The
reason is that this leaves the tx path doing a lot less work. In a way
this gives a pseudo higher-priority to the tx path at least for the case
of forwarding where it is important for me to make sure the packet that
i have sweated doing all the forwarding work on is going to go out. IOW,
if the rx path gets very busy packets will end up being dropped on the
receive path by virtue of DMA rings being filled up while the driver is
busy - and that is an acceptable compromise.

cheers,
jamal

--=-rnqhw2ZtOHJnW8m57OvY
Content-Disposition: attachment; filename=e1000-p1
Content-Type: text/x-patch; name=e1000-p1; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index d304297..270ec35 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -183,6 +183,10 @@ struct e1000_tx_ring {
 	unsigned int size;
 	/* number of descriptors in the ring */
 	unsigned int count;
+	/* number of descriptors needed to wake up netdev */
+	unsigned int waket;
+	/* number of descriptors we allow to prune at a time */
+	unsigned int prunet;
 	/* next descriptor to associate a buffer with */
 	unsigned int next_to_use;
 	/* next descriptor to check for DD status bit */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index da62db8..c90d5c3 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
 err_up:
@@ -1371,6 +1372,11 @@ setup_tx_desc_die:
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
+	/* hard-coding for now, but we should be able to
+	 * use ethtool or module params in the future
+	*/
+	txdr->prunet = txdr->count>>2;
+	txdr->waket = txdr->count>>3;
 	spin_lock_init(&txdr->tx_lock);
 
 	return 0;
@@ -2861,6 +2867,10 @@ e1000_transfer_dhcp_info(struct e1000_ad
 	return 0;
 }
 
+static unsigned int
+e1000_prune_tx_ring(struct e1000_adapter *adapter,
+                   struct e1000_tx_ring *tx_ring);
+
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -2980,6 +2990,14 @@ #endif
 		return NETDEV_TX_BUSY;
 	}
 
+#ifdef jamal
+	{ 
+		int fdesc = E1000_DESC_UNUSED(tx_ring);
+		if (unlikely(fdesc < tx_ring->waket)) 
+			e1000_prune_tx_ring(adapter,tx_ring);
+	}
+#endif
+
 	if (unlikely(adapter->hw.mac_type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
@@ -3468,24 +3496,30 @@ quit_polling:
 }
 
 #endif
-/**
- * e1000_clean_tx_irq - Reclaim resources after transmit completes
- * @adapter: board private structure
- **/
+static inline void
+e1000_schedule_tx(struct net_device *netdev,
+		  struct e1000_tx_ring *tx_ring)
+{
+	if (netif_carrier_ok(netdev)) {
+		if (E1000_DESC_UNUSED(tx_ring) >= tx_ring->waket)
+			netif_wake_queue(netdev);
+	}
+}
 
-static boolean_t
-e1000_clean_tx_irq(struct e1000_adapter *adapter,
+/* 
+ * Must hold tx lock when invoking this ..
+*/
+static unsigned int
+e1000_prune_tx_ring(struct e1000_adapter *adapter,
                    struct e1000_tx_ring *tx_ring)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_desc *tx_desc, *eop_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
-#ifdef CONFIG_E1000_NAPI
-	unsigned int count = 0;
-#endif
+	unsigned int count = 0, cleaned_count = 0;
 	boolean_t cleaned = FALSE;
 
+
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
@@ -3498,6 +3532,7 @@ #endif
 
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			memset(tx_desc, 0, sizeof(struct e1000_tx_desc));
+			cleaned_count++;
 
 			if (unlikely(++i == tx_ring->count)) i = 0;
 		}
@@ -3506,59 +3541,94 @@ #endif
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
 #ifdef CONFIG_E1000_NAPI
-#define E1000_TX_WEIGHT 64
-		/* weight of a sort for tx, to avoid endless transmit cleanup */
-		if (count++ == E1000_TX_WEIGHT) break;
+		/* avoid endless transmit cleanup */
+		if (count++ == tx_ring->prunet) break;
 #endif
 	}
 
 	tx_ring->next_to_clean = i;
 
-#define TX_WAKE_THRESHOLD 32
-	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
-	             netif_carrier_ok(netdev))) {
-		spin_lock(&tx_ring->tx_lock);
-		if (netif_queue_stopped(netdev) &&
-		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
-			netif_wake_queue(netdev);
-		spin_unlock(&tx_ring->tx_lock);
-	}
-
-	if (adapter->detect_tx_hung) {
-		/* Detect a transmit hang in hardware, this serializes the
-		 * check with the clearing of time_stamp and movement of i */
-		adapter->detect_tx_hung = FALSE;
-		if (tx_ring->buffer_info[eop].dma &&
-		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
-		               (adapter->tx_timeout_factor * HZ))
-		    && !(E1000_READ_REG(&adapter->hw, STATUS) &
-		         E1000_STATUS_TXOFF)) {
-
-			/* detected Tx unit hang */
-			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
-					"  Tx Queue             <%lu>\n"
-					"  TDH                  <%x>\n"
-					"  TDT                  <%x>\n"
-					"  next_to_use          <%x>\n"
-					"  next_to_clean        <%x>\n"
-					"buffer_info[next_to_clean]\n"
-					"  time_stamp           <%lx>\n"
-					"  next_to_watch        <%x>\n"
-					"  jiffies              <%lx>\n"
-					"  next_to_watch.status <%x>\n",
-				(unsigned long)((tx_ring - adapter->tx_ring) /
-					sizeof(struct e1000_tx_ring)),
-				readl(adapter->hw.hw_addr + tx_ring->tdh),
-				readl(adapter->hw.hw_addr + tx_ring->tdt),
-				tx_ring->next_to_use,
-				tx_ring->next_to_clean,
-				tx_ring->buffer_info[eop].time_stamp,
-				eop,
-				jiffies,
-				eop_desc->upper.fields.status);
-			netif_stop_queue(netdev);
+	return cleaned_count;
+}
+
+static inline void
+e1000_detect_tx_hung(struct e1000_adapter *adapter,
+                   struct e1000_tx_ring *tx_ring)
+{
+	struct e1000_tx_desc *eop_desc;
+	struct net_device *netdev = adapter->netdev;
+	unsigned int i = tx_ring->next_to_clean;
+	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
+	eop_desc = E1000_TX_DESC(*tx_ring, eop);
+	/* Detect a transmit hang in hardware, this serializes the
+	 * check with the clearing of time_stamp and movement of i */
+	adapter->detect_tx_hung = FALSE;
+	if (tx_ring->buffer_info[eop].dma &&
+	    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
+		       (adapter->tx_timeout_factor * HZ))
+	    && !(E1000_READ_REG(&adapter->hw, STATUS) &
+		 E1000_STATUS_TXOFF)) {
+
+		/* detected Tx unit hang */
+		DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
+				"  Tx Queue             <%lu>\n"
+				"  TDH                  <%x>\n"
+				"  TDT                  <%x>\n"
+				"  next_to_use          <%x>\n"
+				"  next_to_clean        <%x>\n"
+				"buffer_info[next_to_clean]\n"
+				"  time_stamp           <%lx>\n"
+				"  next_to_watch        <%x>\n"
+				"  jiffies              <%lx>\n"
+				"  next_to_watch.status <%x>\n",
+			(unsigned long)((tx_ring - adapter->tx_ring) /
+				sizeof(struct e1000_tx_ring)),
+			readl(adapter->hw.hw_addr + tx_ring->tdh),
+			readl(adapter->hw.hw_addr + tx_ring->tdt),
+			tx_ring->next_to_use,
+			tx_ring->next_to_clean,
+			tx_ring->buffer_info[eop].time_stamp,
+			eop,
+			jiffies,
+			eop_desc->upper.fields.status);
+
+		netif_stop_queue(netdev);
+	}
+}
+
+/**
+ * e1000_clean_tx_irq - Reclaim resources after transmit completes
+ * @adapter: board private structure
+ **/
+
+static boolean_t
+e1000_clean_tx_irq(struct e1000_adapter *adapter,
+                   struct e1000_tx_ring *tx_ring)
+{
+	struct net_device *netdev = adapter->netdev;
+	boolean_t cleaned = FALSE;
+
+#ifdef jamal
+	spin_lock(&tx_ring->tx_lock);
+	{
+		int fdesc = E1000_DESC_UNUSED(tx_ring);
+		if (fdesc < tx_ring->prunet) {
+			if (e1000_prune_tx_ring(adapter,tx_ring))
+				cleaned = TRUE;
 		}
 	}
+	spin_unlock(&tx_ring->tx_lock);
+#else
+	if (e1000_prune_tx_ring(adapter,tx_ring))
+		cleaned = TRUE;
+#endif
+
+	if (unlikely(netif_queue_stopped(netdev) && cleaned))
+		e1000_schedule_tx(netdev, tx_ring);
+
+	if (unlikely(adapter->detect_tx_hung)) 
+		e1000_detect_tx_hung(adapter,tx_ring);
+
 	return cleaned;
 }

--=-rnqhw2ZtOHJnW8m57OvY--

