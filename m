From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 11:08:15 +1000
Message-ID: <20070531010814.GA30709@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Doug Chapman <doug.chapman@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4010 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759042AbXEaBIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 21:08:22 -0400
Content-Disposition: inline
In-Reply-To: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 05:22:30PM -0400, Doug Chapman wrote:
> 
> but once again broken just yesterday by the following commit.  I have
> backed just this commit out and verified I no longer panic.

Hmm, the only way I can see this happening is if the hardware signals
an interrupt even though we've explicitly shut it off.  Does this patch
help? If it does help, does it produce the warning in dmesg?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9ec35b7..c6cf82f 100644
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
@@ -1427,6 +1427,10 @@ e1000_open(struct net_device *netdev)
 	 * clean_rx handler before we do so.  */
 	e1000_configure(adapter);
 
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_enable(netdev);
+#endif
+
 	err = e1000_request_irq(adapter);
 	if (err)
 		goto err_req_irq;
@@ -1434,10 +1438,6 @@ e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000_up() */
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
-#endif
-
 	e1000_irq_enable(adapter);
 
 	/* fire a link status change interrupt to start the watchdog */
@@ -3756,6 +3756,11 @@ e1000_intr_msi(int irq, void *data)
 #endif
 	uint32_t icr = E1000_READ_REG(hw, ICR);
 
+	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags) &&
+		     atomic_read(&adapter->irq_sem)))
+		printk(KERN_WARNING "e1000: Unexpected MSI icr=0x%x\n",
+		       icr);
+
 #ifdef CONFIG_E1000_NAPI
 	/* read ICR disables interrupts using IAM, so keep up with our
 	 * enable/disable accounting */
@@ -3823,6 +3828,11 @@ e1000_intr(int irq, void *data)
 	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
+	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags) &&
+		     atomic_read(&adapter->irq_sem)))
+		printk(KERN_WARNING "e1000: Unexpected interrupt icr=0x%x\n",
+		       icr);
+
 #ifdef CONFIG_E1000_NAPI
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
 	 * not set, then the adapter didn't send an interrupt */
