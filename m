From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Mon, 16 May 2005 10:43:02 -0700
Message-ID: <5fc59ff3050516104367a8d5cd@mail.gmail.com>
References: <20050516025901.4b26ccf3.akpm@osdl.org>
	 <E1DXdL8-0005mE-00@gondolin.me.apana.org.au>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, hejianj@cn.ibm.com,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, anton@samba.org,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DXdL8-0005mE-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jian:

Could you try the e100 from
http://prdownloads.sourceforge.net/e1000/e100-3.4.8.tar.gz?download?
This (e100 3.4.8) has a fix for the problem you've encountered.
Specifically this driver uses netif_poll_{enable|disable} to avoid the
race.

 static int e100_up(struct nic *nic)
 {
@@ -1688,13 +1753,18 @@ static int e100_up(struct nic *nic)
        if((err = e100_hw_init(nic)))
                goto err_clean_cbs;
        e100_set_multicast_list(nic->netdev);
-       e100_start_receiver(nic);
+       e100_start_receiver(nic, 0);
        mod_timer(&nic->watchdog, jiffies);
        if((err = request_irq(nic->pdev->irq, e100_intr, SA_SHIRQ,
                nic->netdev->name, nic->netdev)))
                goto err_no_irq;
-       e100_enable_irq(nic);
        netif_wake_queue(nic->netdev);
+#ifdef CONFIG_E100_NAPI
+       netif_poll_enable(nic->netdev);
+       /* enable ints _after_ enabling poll, preventing a race between
+        * disable ints+schedule */
+#endif
+       e100_enable_irq(nic);
        return 0;

 err_no_irq:
@@ -1708,11 +1778,15 @@ err_rx_clean_list:

 static void e100_down(struct nic *nic)
 {
+#ifdef CONFIG_E100_NAPI
+       /* wait here for poll to complete */
+       netif_poll_disable(nic->netdev);
+#endif
+       netif_stop_queue(nic->netdev);
        e100_hw_reset(nic);
        free_irq(nic->pdev->irq, nic->netdev);
        del_timer_sync(&nic->watchdog);
        netif_carrier_off(nic->netdev);
-       netif_stop_queue(nic->netdev);
        e100_clean_cbs(nic);
        e100_rx_clean_list(nic);


ganesh.


On 5/16/05, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > Might be a bug in the e100 driver, might not be.
> >
> > I assume this is the
> >
> >        BUG_ON(skb->list != NULL);
> 
> It certainly is a bug in e100.
> 
> e100_tx_timeout -> e100_down -> e100_rx_clean_list
> 
> is racing against
> 
> e100_poll -> e100_rx_clean -> e100_rx_indicate
> 
> e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
> while it's being processed e100_rx_clean_list comes along and
> frees it.
> 
> From a quick check similar problems may exist in other drivers that
> have lockless ->poll() functions with RX rings.
> 
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
>
