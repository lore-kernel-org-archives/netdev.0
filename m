From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: [PATCH] r8169 NAPI addition
Date: Mon, 19 Apr 2004 15:57:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF39D4C0E0.23E33AF9-ON87256E7B.006F44E8-86256E7B.0072D05C@us.ibm.com>
References: <20040419202530.A16586@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040419202530.A16586@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[...]
>> +/* The number of Rx iterations processed (if NAPI enabled) */
>> +#define R8169_NAPI_WEIGHT      16
>> +
>May be a bit low. 64 ?

I used 16 because it was in the NAPI documentation.  The e1000 and tg3 use 
64, so that is good enough for me.  Done.

[...]
>> @@ -990,7 +1001,10 @@ rtl8169_remove_one(struct pci_dev *pdev)
>>         assert(dev != NULL);
>>         assert(tp != NULL);
>> 
>> +       printk(KERN_INFO "Before unregister_netdev %d\n", 
>> atomic_read(&dev->>refcnt));
>>         unregister_netdev(dev);
>> +       printk(KERN_INFO "After unregister_netdev\n");
>> +
>>         iounmap(tp->>mmio_addr);
>>         pci_release_regions(pdev);
>What is the previous change intended for ?

Sorry, it was debug code for an unrelated error. Removed.

[...]
>>  rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private 
*tp,
>>                      void *ioaddr)
>>  {
>>         unsigned long cur_rx, rx_left;
>>         int delta;
>> +       uint32_t count = 0;
>          ^^^^^^^^ 
>The r8169 driver mostly uses u32 and such. A plain old int would be 
enough.

Unsigned variables are a little bit faster on ppc hardware.  I figgured 
that it doesn't matter on x86/x86_64, but would help other archatectures.

[...]
>> @@ -1497,7 +1513,11 @@ rtl8169_rx_interrupt(struct net_device *
>> 
>>                         skb_put(skb, pkt_size);
>>                         skb->>protocol = eth_type_trans(skb, dev);
>> +#ifdef CONFIG_R8169_NAPI
>> +                       netif_receive_skb(skb);
>> +#else
>>                         netif_rx(skb);
>> +#endif
>I'd probably favor something like r8169_rx_skb() to avoid the flashy 
#ifdef.

I can try and hide as many #ifdefs as possible if you like, just didn't 
know your preferance. Will do.

[...]
>> @@ -1558,7 +1582,19 @@ rtl8169_interrupt(int irq, void *dev_ins
>> 
>>                 // Rx interrupt
>>                 if (status & (RxOK | RxUnderrun | RxOverflow | 
>> RxFIFOOver)) {
>> +#ifdef CONFIG_R8169_NAPI
>> +                       if(netif_rx_schedule_prep(dev)) {
                           ^^^
>> "if (" please.

Done.


>> @@ -1692,6 +1728,28 @@ static struct net_device_stats *rtl8169_
>>         return &tp->stats;
>>  }
>> 
>> +#ifdef CONFIG_R8169_NAPI
>> +static int rtl8169_poll(struct net_device *dev, int *budget)
>> +{
>> +       uint32_t work_done = 0,
>> +               work_to_do = min(*budget, dev->>quota);
>
>Please put this on a separate line after the declarations of the 
variables.

This is declaration and assignment.  Would you prefer decleration and 
assignment seperate?

>> +       struct rtl8169_private *tp = (struct rtl8169_private 
*)dev->priv;
>The cast is not needed (nor used anywhere in the current driver).

Removed.

>> +       void *ioaddr = tp->mmio_addr;
>> +
>> +       work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);
>
>Nothing will prevent rtl8169_rx_interrupt() to process packets in
>excess of *budget. A simple min(rx_left, *budget) for rx_left in
>rtl8169_rx_interrupt() should fix it.

That's true, I just didn't want to be too invasive in the Rx code.  Will 
do.

>> +
>> +       *budget -= work_done;
>> +       dev->>quota -= work_done;
>> +
>> +       if (!work_done || !netif_running(dev)) {
>> +               netif_rx_complete(dev);
>> +               RTL_W16(IntrMask, rtl8169_intr_mask);
>
>- it may as well complete as soon as work_done > 0. Not all drivers
>  are equally fair in this regard.

This is true.  Adding the requested rx_interrupt changes will fix this.

>- if irq are not disabled, the previous code will race with the irq
>  handler. Btw, be it here or in rtl8169_interrupt(), RTL_W16() is a
>  posted pci write.

I could be wrong, but I don't think its possible to be in the poll 
function with interrupts turned on.  The work scheduling is done in the 
interrupt handler, which turns off the Rx interrupts.  I could turn off 
interrupts prior to schduling the work in the interrupt handler, but I'm 
not sure that is necessary.

Not sure the significance of RTL_W16 being a posted pci write.  Can you 
clarify its significance for me?

>Global remarks:
>- you probably want a larger Rx ring;

It might be better to be a user turnable parameter, but I can increase the 
size for NAPI useage.  Any perefance as to the ring size?

>- please tell Notes to not turn the tabs into whitespaces.

I hate Notes!  Be assured that they are tabs and not whitespaces.  If you 
perfer, I can have the diffs as an attachment.

>Have you considered Tx napi ? :o)
Actually, I have a copy of the driver that does Tx.  After reading the 
NAPI howto, which states that there is a slight performance degridadtion 
if Tx is NAPI too, I figgured that you would want only Rx.  I can add Tx 
if you like.

>Please Cc: Jeff.
Sorry, I will copy him on directly (instead of the indirect netdev).
