From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Mon, 6 Dec 2004 23:29:51 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412062313580.1981@tux.rsn.bth.se>
References: <16820.44722.748743.6711@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, jamal <hadi@cyberus.ca>,
        Scott Feldman <sfeldma@pobox.com>, P@draigBrady.com,
        mellia@prezzemolo.polito.it,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16820.44722.748743.6711@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Dec 2004, Robert Olsson wrote:

> pktgen performance is measured on router box. Remember Scotts patch uses
> 4096 TX buffers and w. pktgen we use clone_skb. So with real skb's we probably
> see lower performance due to this. This may explain results below so routing
> performance doesn't follow pktgen performance as seen.

I've performed some tests with and without clone_skb with various versions
of the driver.

> Vanilla. T-PUT 657 kpps. pktgen TX perf 818 kpps

> e1000-TX-prefetch+scott tx patch. T-PUT 540 kpps. pktgen TX perf 1.48 Mpps

> e1000-TX-prefetch. T-PUT 657 kpps. pktgen TX perf 1.15 Mpps

This matches the data I see in my tests here with and without clone_skb.

I've included a lot of pps numbers below, they might need some
description.

I tested generating packets with four diffrent drivers with and without
clone_skb.

vanilla is the vanilla driver in 2.6.10-rc3

copy is using the patch found at the bottom of this mail, just a small
test to see if there's any gain or loss using "static" buffers to dma
from. Prefetch doesn't help at all here, just makes things worse, even for
clone_skb. Tried with delayed TDT updating as well, didn't help.

vanilla + prefetch is just the vanilla driver + prefetching.

feldman tx is using scotts tx-path rewrite patch.
I didn't bother listing feldman tx + prefetch as the results were even
lower for the non clone_skb case.
The only thing I can think of that can cause this is cache trashing, or
overhead in slab when we have a lot of skb's in the wild.

I don't have oprofile on my testmachine at the moment and it's time to go
to bed now, maybe tomorrow...

Does anyone have any suggestions of what to test next?


vanilla and clone
60      854886
64      772341
68      759531
72      758872
76      758926
80      761136
84      742109
88      742070
92      741616
96      744083
100     727430
104     725242
108     724153
112     725841
116     707331
120     706000
124     704923
128     662547

vanilla and noclone
60      748552
64      702464
68      649066
72      671992
76      680251
80      627711
84      625468
88      640115
92      679365
96      650544
100     666423
104     652057
108     665821
112     679443
116     652507
120     661279
124     648627
128     635780

copy and clone
60      897165
64      872767
68      750694
72      750427
76      749583
80      748242
84      732760
88      731129
92      732603
96      732631
100     717123
104     717678
108     716839
112     719258
116     703824
120     706047
124     701885
128     695575

copy and noclone
60      882227
64      649614
68      691327
72      700706
76      700795
80      696594
84      686016
88      691689
92      696136
96      691348
100     684596
104     687800
108     689218
112     671483
116     675867
120     679089
124     672385
128     650148

vanilla + prefetch and clone
60      1300075
64      1079069
68      1082091
72      1068791
76      1067630
80      1026222
84      1053055
88      1024442
92      1032112
96      1014844
100     991346
104     976483
108     947019
112     919193
116     892863
120     868054
124     844679
128     822347

vanilla + prefetch and noclone
60      738538
64      800927
68      719832
72      725353
76      822738
80      743134
84      813520
88      721522
92      797838
96      724031
100     812198
104     717811
108     713072
112     789771
116     696027
120     682168
124     749020
128     703233

feldman tx and clone
60      1029997
64      916706
68      898601
72      895378
76      896171
80      898594
84      861434
88      861446
92      861444
96      863669
100     837624
104     836225
108     835528
112     835527
116     817102
120     817101
124     817100
128     757683

feldman tx and noclone
60      626646
64      628148
68      628935
72      625084
76      623527
80      623510
84      624286
88      625086
92      623907
96      630199
100     613933
104     618025
108     620326
112     607884
116     606124
120     538434
124     531699
128     532719



diff -X /home/gandalf/dontdiff.ny -urNp drivers/net/e1000-vanilla/e1000_main.c drivers/net/e1000/e1000_main.c
--- drivers/net/e1000-vanilla/e1000_main.c	2004-12-05 18:27:50.000000000 +0100
+++ drivers/net/e1000/e1000_main.c	2004-12-06 22:21:10.000000000 +0100
@@ -132,6 +132,7 @@ static void e1000_irq_disable(struct e10
 static void e1000_irq_enable(struct e1000_adapter *adapter);
 static irqreturn_t e1000_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
+static boolean_t e1000_alloc_tx_buffers(struct e1000_adapter *adapter);
 #ifdef CONFIG_E1000_NAPI
 static int e1000_clean(struct net_device *netdev, int *budget);
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
@@ -264,6 +265,7 @@ e1000_up(struct e1000_adapter *adapter)
 	e1000_restore_vlan(adapter);

 	e1000_configure_tx(adapter);
+	e1000_alloc_tx_buffers(adapter);
 	e1000_setup_rctl(adapter);
 	e1000_configure_rx(adapter);
 	e1000_alloc_rx_buffers(adapter);
@@ -1048,10 +1052,21 @@ e1000_configure_rx(struct e1000_adapter
 void
 e1000_free_tx_resources(struct e1000_adapter *adapter)
 {
+	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
+	struct e1000_buffer *buffer_info;
 	struct pci_dev *pdev = adapter->pdev;
+	unsigned int i;

 	e1000_clean_tx_ring(adapter);

+	for(i = 0; i < tx_ring->count; i++) {
+		buffer_info = &tx_ring->buffer_info[i];
+		if(buffer_info->skb) {
+			kfree(buffer_info->skb);
+			buffer_info->skb = NULL;
+		}
+	}
+
 	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info = NULL;

@@ -1079,16 +1094,12 @@ e1000_clean_tx_ring(struct e1000_adapter

 	for(i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
-		if(buffer_info->skb) {
-
+		if(buffer_info->dma) {
 			pci_unmap_page(pdev,
 				       buffer_info->dma,
 				       buffer_info->length,
 				       PCI_DMA_TODEVICE);
-
-			dev_kfree_skb(buffer_info->skb);
-
-			buffer_info->skb = NULL;
+			buffer_info->dma = 0;
 		}
 	}

@@ -1579,8 +1590,6 @@ e1000_tx_map(struct e1000_adapter *adapt
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
-	unsigned int f;
-	len -= skb->data_len;

 	i = tx_ring->next_to_use;

@@ -1600,10 +1609,12 @@ e1000_tx_map(struct e1000_adapter *adapt
 		   size > 4))
 			size -= 4;

+		skb_copy_bits(skb, offset, buffer_info->skb, size);
+
 		buffer_info->length = size;
 		buffer_info->dma =
 			pci_map_single(adapter->pdev,
-				skb->data + offset,
+				buffer_info->skb,
 				size,
 				PCI_DMA_TODEVICE);
 		buffer_info->time_stamp = jiffies;
@@ -1614,50 +1625,11 @@ e1000_tx_map(struct e1000_adapter *adapt
 		if(unlikely(++i == tx_ring->count)) i = 0;
 	}

-	for(f = 0; f < nr_frags; f++) {
-		struct skb_frag_struct *frag;
-
-		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
-		offset = frag->page_offset;
-
-		while(len) {
-			buffer_info = &tx_ring->buffer_info[i];
-			size = min(len, max_per_txd);
-#ifdef NETIF_F_TSO
-			/* Workaround for premature desc write-backs
-			 * in TSO mode.  Append 4-byte sentinel desc */
-			if(unlikely(mss && f == (nr_frags-1) && size == len && size > 8))
-				size -= 4;
-#endif
-			/* Workaround for potential 82544 hang in PCI-X.
-			 * Avoid terminating buffers within evenly-aligned
-			 * dwords. */
-			if(unlikely(adapter->pcix_82544 &&
-			   !((unsigned long)(frag->page+offset+size-1) & 4) &&
-			   size > 4))
-				size -= 4;
-
-			buffer_info->length = size;
-			buffer_info->dma =
-				pci_map_page(adapter->pdev,
-					frag->page,
-					offset,
-					size,
-					PCI_DMA_TODEVICE);
-			buffer_info->time_stamp = jiffies;
-
-			len -= size;
-			offset += size;
-			count++;
-			if(unlikely(++i == tx_ring->count)) i = 0;
-		}
-	}
-
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
-	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;

+	dev_kfree_skb_any(skb);
+
 	return count;
 }

@@ -2213,11 +2185,6 @@ e1000_clean_tx_irq(struct e1000_adapter
 				buffer_info->dma = 0;
 			}

-			if(buffer_info->skb) {
-				dev_kfree_skb_any(buffer_info->skb);
-				buffer_info->skb = NULL;
-			}
-
 			tx_desc->buffer_addr = 0;
 			tx_desc->lower.data = 0;
 			tx_desc->upper.data = 0;
@@ -2243,6 +2210,28 @@ e1000_clean_tx_irq(struct e1000_adapter
 	return cleaned;
 }

+
+static boolean_t
+e1000_alloc_tx_buffers(struct e1000_adapter *adapter)
+{
+        struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
+        struct e1000_buffer *buffer_info;
+        unsigned int i;
+
+	for (i = 0; i < tx_ring->count; i++) {
+		buffer_info = &tx_ring->buffer_info[i];
+		if (!buffer_info->skb) {
+			buffer_info->skb = kmalloc(2048, GFP_ATOMIC);
+			if (unlikely(!buffer_info->skb)) {
+				printk("eek!\n");
+				return FALSE;
+			}
+		}
+	}
+
+	return TRUE;
+}
+
 /**
  * e1000_clean_rx_irq - Send received data up the network stack
  * @adapter: board private structure

/Martin
