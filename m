From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: panic on 2.6.11
Date: Sat, 5 Mar 2005 00:02:14 +0100
Message-ID: <20050304230214.GC1148@electric-eye.fr.zoreil.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net> <4228D523.2070703@pobox.com> <20050304215044.GB1148@electric-eye.fr.zoreil.com> <20050304135922.0b0a3911@dxpl.pdx.osdl.net> <20050304221826.GA1028@electric-eye.fr.zoreil.com> <20050304145317.772859da@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050304145317.772859da@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> NAPI is not enabled, it is the IRQ version. Hitting 
> 
> Added instrumentation:.
> 
> skb=0xd1e28380 len=8172 head=d1e32000 data=d1e32012 tail=d1e33ffe end=d1e32620
> 
> Looks like the board is running back-to-back packets together, MTU is 1500.
> No Jumbo frames exist on my little network and the gigabit switch (Netgear) won't 
> even take them.  Probably a chip bug.

/me scratches head: play with the interframe gap ?

> Need to add a check for len > mtu before processing?

Please.

diff -puN drivers/net/r8169.c~r8169-470 drivers/net/r8169.c
--- linux-2.6.11/drivers/net/r8169.c~r8169-470	2005-03-04 22:51:35.038710839 +0100
+++ linux-2.6.11-fr/drivers/net/r8169.c	2005-03-04 23:16:29.422289316 +0100
@@ -2194,6 +2194,7 @@ rtl8169_rx_interrupt(struct net_device *
 			int pkt_size = (status & 0x00001FFF) - 4;
 			void (*pci_action)(struct pci_dev *, dma_addr_t,
 				size_t, int) = pci_dma_sync_single_for_device;
+			static int show_size = 0;
 
 			rtl8169_rx_csum(skb, desc);
 			
@@ -2210,6 +2211,24 @@ rtl8169_rx_interrupt(struct net_device *
 			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
 				   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
+			if (pkt_size >= tp->rx_buf_sz) {
+				show_size = 1;
+				pkt_size = tp->rx_buf_sz;
+			}
+
+			if (show_size) {
+				printk(KERN_INFO "%s: pkt_size=%d\n", dev->name,
+				       pkt_size);
+				printk(KERN_INFO "%s: opts1= %08x\n", dev->name,
+				       desc->opts1);
+				printk(KERN_INFO "%s: opts2= %08x\n", dev->name,
+				       desc->opts2);
+				printk(KERN_INFO "%s: addrl= %08x\n", dev->name,
+				       (u32)desc->addr);
+				printk(KERN_INFO "%s: addrh= %08x\n", dev->name,
+				       (u32)(desc->addr >> 32));
+			}
+
 			skb->dev = dev;
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);

_
