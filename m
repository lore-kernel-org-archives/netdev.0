From: "Roman Mashak" <romez777@gmail.com>
Subject: system lockup
Date: Tue, 27 Feb 2007 10:20:03 +0900
Message-ID: <40a670230702261720i33be62b0s33c42e397f9cfb6c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:47614 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbXB0BUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 20:20:05 -0500
Received: by ug-out-1314.google.com with SMTP id 44so976645uga
        for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 17:20:04 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

for learning device drivers I took 8139too.c to explore it. I
disrupted the code into several logical blocks and now I'm trying to
implement my own simplified version referring to original code from
time to time. I have rtl8139d NIC for experiments. So, by now I've
acomplished the following stages:
1) detected device
2) enable PCI device
3) memory mapped IO initialised
4) initialization of 'net_device' structure

And I'm stuck on the chip reset. Whenever I load driver and try to
enable interface (ifconfig eth1 up) my system just hangs, keyboard
locks up, I can't even use 'SysRq' shortcuts.

I figured out that problem occurs after I initialised chip, i.e. in
this routine called from 'net_device->open' method:


#define CmdTxEnb  (0x04)
...
#define RxOK   (0x01)
#define RxErr   (0x02)
#define TxOK   (0x04)
#define TxErr   (0x08)
#define RxOverFlow  (0x10)
#define RxUnderrun  (0x20)
#define RxFIFOOver  (0x40)
#define CableLen  (0x2000)
#define TimeOut   (0x4000)
#define SysErr   (0x8000)

#define INT_MASK (RxOK | RxErr | TxOK | TxErr | RxOverFlow | \
RxUnderrun | RxFIFOOver | CableLen | TimeOut | SysErr)


static void rtl8139_hw_start(struct net_device *dev)
{
   struct rtl8139_private *tp = dev->priv;
   void *ioaddr = tp->mmio_addr;
   ...
   writeb(CmdTxEnb, ioaddr + REG_COMMAND);
   writel(0x00000600, ioaddr + REG_TX_CONFIG);    /* DMA burst size 1024 */

/* init TX buffer DMA addresses */
for (i = 0; i < NUM_TX_DESC; i++) {
writel(tp->tx_bufs_dma + (tp->tx_buf[i] - tp->tx_bufs), ioaddr +
REG_TX_ADDR0 + (i * 4));
}


   /* enable all known interrupts by setting the interrupt mask */
   writew(INT_MASK, ioaddr + REG_INTR_MASK);


   netif_start_queue(dev);
   return;
}


static int rtl8139_open(struct net_device *dev)
{
   int retval;
   struct rtl8139_private *tp = dev->priv;
   ...
   retval = request_irq(dev->irq, rtl8139_interrupt, 0, dev->name, dev);
   if (retval)
       return retval;

/* Get memory for TX buffers. Memory must be DMA-able */
tp->tx_bufs = pci_alloc_consistent(tp->pci_dev, TOTAL_TX_BUF_SIZE,
&tp->tx_bufs_dma);
...
rtl8139_init_ring(dev);
rtl8139_hw_start(dev);

DPRINTK("init_ring() & hw_start() passed\n");


   return;
}

rtl8139_hw_start() is really invoked and returned, since I'm getting
printk output. Commenting 'rtl8139_hw_start(dev);' out brings the
interface up succesfully, that's why I came to conclusion the problem
is in chip initialization routine.

If anybody has any clue, I'd appreciate to hear it and get advice.
Thanks in advance.

-- 
Roman
