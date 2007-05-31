From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Fri, 1 Jun 2007 08:10:36 +1000
Message-ID: <20070531221036.GA9644@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <20070531010814.GA30709@gondor.apana.org.au> <1180624569.23536.7.camel@athlon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Doug Chapman <doug.chapman@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2143 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756472AbXEaWKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 18:10:46 -0400
Content-Disposition: inline
In-Reply-To: <1180624569.23536.7.camel@athlon>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2007 at 11:16:09AM -0400, Doug Chapman wrote:
> 
> # dmesg | grep e1000
> e1000: 0000:01:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f8
> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: 0000:01:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f9
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: 0000:15:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c4
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: 0000:15:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c5
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> e1000: Unexpected interrupt icr=0x4
> e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: RX

OK that's interesting.

Does this patch (please unapply the last one first) make the printk
go away or does it trigger a backtrace?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9ec35b7..167de10 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -625,15 +625,15 @@ e1000_down(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	/* signal that we're down so the interrupt handler does not
-	 * reschedule our watchdog timer */
-	set_bit(__E1000_DOWN, &adapter->flags);
-
 #ifdef CONFIG_E1000_NAPI
 	netif_poll_disable(netdev);
 #endif
 	e1000_irq_disable(adapter);
 
+	/* signal that we're down so the interrupt handler does not
+	 * reschedule our watchdog timer */
+	set_bit(__E1000_DOWN, &adapter->flags);
+
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
@@ -1328,6 +1328,7 @@ e1000_sw_init(struct e1000_adapter *adapter)
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	atomic_set(&adapter->irq_sem, 0);
 	e1000_irq_disable(adapter);
+	WARN_ON(E1000_READ_REG(&adapter->hw, ICR));
 
 	spin_lock_init(&adapter->stats_lock);
 
@@ -1427,6 +1428,10 @@ e1000_open(struct net_device *netdev)
 	 * clean_rx handler before we do so.  */
 	e1000_configure(adapter);
 
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_enable(netdev);
+#endif
+
 	err = e1000_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
@@ -1434,9 +1439,7 @@ e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000_up() */
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
-#endif
+	WARN_ON(E1000_READ_REG(&adapter->hw, ICR));
 
 	e1000_irq_enable(adapter);
 
@@ -3756,6 +3759,13 @@ e1000_intr_msi(int irq, void *data)
 #endif
 	uint32_t icr = E1000_READ_REG(hw, ICR);
 
+	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags))) {
+		mb();
+		if (unlikely(atomic_read(&adapter->irq_sem)))
+			printk(KERN_WARNING "e1000: Unexpected MSI icr=0x%x\n",
+			       icr);
+	}
+
 #ifdef CONFIG_E1000_NAPI
 	/* read ICR disables interrupts using IAM, so keep up with our
 	 * enable/disable accounting */
@@ -3823,6 +3833,14 @@ e1000_intr(int irq, void *data)
 	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
+
+	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags))) {
+		mb();
+		if (unlikely(atomic_read(&adapter->irq_sem)))
+			printk(KERN_WARNING
+			       "e1000: Unexpected interrupt icr=0x%x\n", icr);
+	}
+
 #ifdef CONFIG_E1000_NAPI
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
 	 * not set, then the adapter didn't send an interrupt */
