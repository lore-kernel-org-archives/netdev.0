From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169 NAPI addition
Date: Mon, 19 Apr 2004 20:25:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419202530.A16586@electric-eye.fr.zoreil.com>
References: <OFDB678E23.389CBC51-ON87256E7B.00620100-86256E7B.00637457@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFDB678E23.389CBC51-ON87256E7B.00620100-86256E7B.00637457@us.ibm.com>; from jonmason@us.ibm.com on Mon, Apr 19, 2004 at 01:10:09PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> :
[...]
> +/* The number of Rx iterations processed (if NAPI enabled) */
> +#define R8169_NAPI_WEIGHT      16
> +

May be a bit low. 64 ?

[...]
> @@ -990,7 +1001,10 @@ rtl8169_remove_one(struct pci_dev *pdev)
>         assert(dev != NULL);
>         assert(tp != NULL);
> 
> +       printk(KERN_INFO "Before unregister_netdev %d\n", 
> atomic_read(&dev->refcnt));
>         unregister_netdev(dev);
> +       printk(KERN_INFO "After unregister_netdev\n");
> +
>         iounmap(tp->mmio_addr);
>         pci_release_regions(pdev);

What is the previous change intended for ?

[...]
>  rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
>                      void *ioaddr)
>  {
>         unsigned long cur_rx, rx_left;
>         int delta;
> +       uint32_t count = 0;
          ^^^^^^^^ 
The r8169 driver mostly uses u32 and such. A plain old int would be enough.

[...]
> @@ -1497,7 +1513,11 @@ rtl8169_rx_interrupt(struct net_device *
> 
>                         skb_put(skb, pkt_size);
>                         skb->protocol = eth_type_trans(skb, dev);
> +#ifdef CONFIG_R8169_NAPI
> +                       netif_receive_skb(skb);
> +#else
>                         netif_rx(skb);
> +#endif

I'd probably favor something like r8169_rx_skb() to avoid the flashy #ifdef.

[...]
> @@ -1558,7 +1582,19 @@ rtl8169_interrupt(int irq, void *dev_ins
> 
>                 // Rx interrupt
>                 if (status & (RxOK | RxUnderrun | RxOverflow | 
> RxFIFOOver)) {
> +#ifdef CONFIG_R8169_NAPI
> +                       if(netif_rx_schedule_prep(dev)) {
                          ^^^
-> "if (" please.

> +                               RTL_W16(IntrMask, rtl8169_intr_mask |
> +                                       ~(RxOK | RxUnderrun | RxOverflow | 
> RxFIFOOver));
> +                               __netif_rx_schedule(dev);
> +                       } else {
> +                               printk(KERN_INFO "driver bug! interrupt 
> while in poll\n");
> +                               RTL_W16(IntrMask, rtl8169_intr_mask |
> +                                       ~(RxOK | RxUnderrun | RxOverflow | 
> RxFIFOOver));
> +                       }
> +#else
>                         rtl8169_rx_interrupt(dev, tp, ioaddr);
> +#endif
>                 }
>                 // Tx interrupt
>                 if (status & (TxOK | TxErr)) {
> @@ -1692,6 +1728,28 @@ static struct net_device_stats *rtl8169_
>         return &tp->stats;
>  }
> 
> +#ifdef CONFIG_R8169_NAPI
> +static int rtl8169_poll(struct net_device *dev, int *budget)
> +{
> +       uint32_t work_done = 0,
          ^^^^^^^^ 
See above.

> +               work_to_do = min(*budget, dev->quota);

Please put this on a separate line after the declarations of the variables.


> +       struct rtl8169_private *tp = (struct rtl8169_private *)dev->priv;

The cast is not needed (nor used anywhere in the current driver).

> +       void *ioaddr = tp->mmio_addr;
> +
> +       work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);

Nothing will prevent rtl8169_rx_interrupt() to process packets in
excess of *budget. A simple min(rx_left, *budget) for rx_left in
rtl8169_rx_interrupt() should fix it.

> +
> +       *budget -= work_done;
> +       dev->quota -= work_done;
> +
> +       if (!work_done || !netif_running(dev)) {
> +               netif_rx_complete(dev);
> +               RTL_W16(IntrMask, rtl8169_intr_mask);

- it may as well complete as soon as work_done > 0. Not all drivers
  are equally fair in this regard.
- if irq are not disabled, the previous code will race with the irq
  handler. Btw, be it here or in rtl8169_interrupt(), RTL_W16() is a
  posted pci write.

Global remarks:
- you probably want a larger Rx ring;
- please tell Notes to not turn the tabs into whitespaces.

Have you considered Tx napi ? :o)

Please Cc: Jeff.

--
Ueimor
