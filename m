From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Sun, 28 Mar 2004 22:19:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403282219.56799.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403272328.51291.vda@port.imtp.ilyichevsk.odessa.ua> <20040328005533.A6117@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_sNzZAIeDI9IXpk2"
Cc: Jeff Garzik <jgarzik@pobox.com>, Andreas Henriksson <andreas@fjortis.info>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040328005533.A6117@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_sNzZAIeDI9IXpk2
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 28 March 2004 01:55, Francois Romieu wrote:
> Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
> [...]
>
> > Sorry Jeff your patch does not fix my problem.
> > I also verified that it happens this way:
> > (1) rx skb is processed and freed
> > (2) allocation failure for new skb
> > (3) next rx intr occurs, cur_rx->skbuff still == NULL
> > (4) oops
>
> Your previous analysis made sense: the logic responsible for low memory
> handling is broken in several ways.
>
> Patch against2.6.5-rc2-mm3 below, without warranty

I tested on 2.4.25, patch applied with minimal manual correction
in last hunk (rediffed patch attached).

Patched driver oopses in allocate_rx_buffers() shortly after boot,
before I can login. It dies here (sorry, only objdump for now,
I am -EBADLYNEEDTOSLEEP. Can track it to src line tomorrow):

0000065c <allocate_rx_buffers>:
     65c:       55                      push   %ebp
     65d:       89 e5                   mov    %esp,%ebp
     65f:       56                      push   %esi
     660:       53                      push   %ebx
     661:       8b 75 08                mov    0x8(%ebp),%esi
     664:       8b 5e 6c                mov    0x6c(%esi),%ebx
     667:       83 bb 9c 00 00 00 0c    cmpl   $0xc,0x9c(%ebx)
     66e:       0f 84 8a 00 00 00       je     6fe <allocate_rx_buffers+0xa2>
     674:       6a 20                   push   $0x20
     676:       8b 83 b0 00 00 00       mov    0xb0(%ebx),%eax
     67c:       83 c0 10                add    $0x10,%eax
     67f:       50                      push   %eax
     680:       e8 fc ff ff ff          call   681 <allocate_rx_buffers+0x25>
     685:       85 c0                   test   %eax,%eax
     687:       5a                      pop    %edx
     688:       59                      pop    %ecx
     689:       74 73                   je     6fe <allocate_rx_buffers+0xa2>
     68b:       83 80 84 00 00 00 10    addl   $0x10,0x84(%eax)
     692:       83 80 88 00 00 00 10    addl   $0x10,0x88(%eax)
     699:       85 c0                   test   %eax,%eax
     69b:       74 61                   je     6fe <allocate_rx_buffers+0xa2>
     69d:       8b 93 98 00 00 00       mov    0x98(%ebx),%edx
     6a3:       8b 4a 14                mov    0x14(%edx),%ecx
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%edx == 0 here

     6a6:       85 c9                   test   %ecx,%ecx
     6a8:       74 12                   je     6bc <allocate_rx_buffers+0x60>
     6aa:       89 f6                   mov    %esi,%esi
     6ac:       8b 52 10                mov    0x10(%edx),%edx
     6af:       89 93 98 00 00 00       mov    %edx,0x98(%ebx)
     6b5:       8b 4a 14                mov    0x14(%edx),%ecx
     6b8:       85 c9                   test   %ecx,%ecx
     6ba:       75 f0                   jne    6ac <allocate_rx_buffers+0x50>
     6bc:       89 42 14                mov    %eax,0x14(%edx)
     6bf:       89 70 18                mov    %esi,0x18(%eax)
     6c2:       8b 93 98 00 00 00       mov    0x98(%ebx),%edx
     6c8:       8b 80 88 00 00 00       mov    0x88(%eax),%eax
     6ce:       f0 83 44 24 00 00       lock addl $0x0,0x0(%esp,1)
     6d4:       05 00 00 00 40          add    $0x40000000,%eax
     6d9:       89 42 08                mov    %eax,0x8(%edx)
     6dc:       8b 83 98 00 00 00       mov    0x98(%ebx),%eax
     6e2:       c7 00 00 00 00 80       movl   $0x80000000,(%eax)
     6e8:       8b 83 9c 00 00 00       mov    0x9c(%ebx),%eax
     6ee:       40                      inc    %eax
     6ef:       83 f8 0c                cmp    $0xc,%eax
     6f2:       89 83 9c 00 00 00       mov    %eax,0x9c(%ebx)
     6f8:       0f 85 76 ff ff ff       jne    674 <allocate_rx_buffers+0x18>
     6fe:       8d 65 f8                lea    0xfffffff8(%ebp),%esp
...
--
vda

--Boundary-00=_sNzZAIeDI9IXpk2
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="fealnx_oom.24.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="fealnx_oom.24.patch"

--- fealnx.c.orig	Fri Nov 28 20:26:20 2003
+++ fealnx.c	Sun Mar 28 21:32:56 2004
@@ -1134,15 +1134,17 @@
 		struct sk_buff *skb;
 
 		skb = dev_alloc_skb(np->rx_buf_sz);
-		np->lack_rxbuf->skbuff = skb;
-
 		if (skb == NULL)
 			break;	/* Better luck next round. */
 
+		while (np->lack_rxbuf->skbuff)
+			np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
+		np->lack_rxbuf->skbuff = skb;
+
 		skb->dev = dev;	/* Mark as being used by this device. */
 		np->lack_rxbuf->buffer = pci_map_single(np->pci_dev, skb->tail,
 			np->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
+		np->lack_rxbuf->status = RXOWN;
 		++np->really_rx_count;
 	}
 }
@@ -1380,33 +1382,22 @@
 	return 0;
 }
 
-
-void free_one_rx_descriptor(struct netdev_private *np)
-{
-	if (np->really_rx_count == RX_RING_SIZE)
-		np->cur_rx->status = RXOWN;
-	else {
-		np->lack_rxbuf->skbuff = np->cur_rx->skbuff;
-		np->lack_rxbuf->buffer = np->cur_rx->buffer;
-		np->lack_rxbuf->status = RXOWN;
-		++np->really_rx_count;
-		np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
-	}
-	np->cur_rx = np->cur_rx->next_desc_logical;
-}
-
-
 void reset_rx_descriptors(struct net_device *dev)
 {
 	struct netdev_private *np = dev->priv;
+	struct fealnx_desc *cur = np->cur_rx;
+	int i;
 
 	stop_nic_rx(dev->base_addr, np->crvalue);
 
-	while (!(np->cur_rx->status & RXOWN))
-		free_one_rx_descriptor(np);
-
 	allocate_rx_buffers(dev);
 
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		if (cur->skbuff)
+			cur->status = RXOWN;
+		cur = cur->next_desc_logical;
+	}
+
 	writel(np->rx_ring_dma + (np->cur_rx - np->rx_ring),
 		dev->base_addr + RXLBA);
 	writel(np->crvalue, dev->base_addr + TCRRCR);
@@ -1576,7 +1567,7 @@
 	struct netdev_private *np = dev->priv;
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
-	while (!(np->cur_rx->status & RXOWN)) {
+	while (!(np->cur_rx->status & RXOWN) && np->cur_rx->skbuff) {
 		s32 rx_status = np->cur_rx->status;
 
 		if (np->really_rx_count == 0)
@@ -1628,8 +1619,15 @@
 					np->stats.rx_length_errors++;
 
 					/* free all rx descriptors related this long pkt */
-					for (i = 0; i < desno; ++i)
-						free_one_rx_descriptor(np);
+					for (i = 0; i < desno; ++i) {
+						if (!np->cur_rx->skbuff) {
+							printk(KERN_DEBUG
+								"%s: I'm scared\n", dev->name);
+							break;
+						}
+						np->cur_rx->status = RXOWN;
+						np->cur_rx = np->cur_rx->next_desc_logical;
+					}
 					continue;
 				} else {	/* something error, need to reset this chip */
 					reset_rx_descriptors(dev);
@@ -1671,8 +1669,6 @@
 			} else {
 				skb_put(skb = np->cur_rx->skbuff, pkt_len);
 				np->cur_rx->skbuff = NULL;
-				if (np->really_rx_count == RX_RING_SIZE)
-					np->lack_rxbuf = np->cur_rx;
 				--np->really_rx_count;
 			}
 			skb->protocol = eth_type_trans(skb, dev);
@@ -1682,22 +1678,7 @@
 			np->stats.rx_bytes += pkt_len;
 		}
 
-		if (np->cur_rx->skbuff == NULL) {
-			struct sk_buff *skb;
-
-			skb = dev_alloc_skb(np->rx_buf_sz);
-
-			if (skb != NULL) {
-				skb->dev = dev;	/* Mark as being used by this device. */
-				np->cur_rx->buffer = pci_map_single(np->pci_dev, skb->tail,
-					np->rx_buf_sz, PCI_DMA_FROMDEVICE);
-				np->cur_rx->skbuff = skb;
-				++np->really_rx_count;
-			}
-		}
-
-		if (np->cur_rx->skbuff != NULL)
-			free_one_rx_descriptor(np);
+		np->cur_rx = np->cur_rx->next_desc_logical;
 	}			/* end of while loop */
 
 	/*  allocate skb for rx buffers */

--Boundary-00=_sNzZAIeDI9IXpk2--
