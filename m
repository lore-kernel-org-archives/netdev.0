From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 06 Nov 2002 23:08:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCA1152.7040002@candelatech.com>
References: <Pine.LNX.4.44.0211061458310.13934-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080602000200060108030909"
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080602000200060108030909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Here's an update of the tulip-NAPI and skb-recycle patches.  I made some
changes to get it to compile and work when the RECYCLE define in skbuff.h
was not enabled.

I also got some test runs in.  Nothing really conclusive.

Test setup:  Phobos 4-port NIC in each P-IV 1.8Ghz machine 32/33 PCI bus.
Kernel 2.4.20-rc1 + my patches.  NICs connected to each other over CX cables.
Sending 4k 1514 byte packets per second, send + receive. (48Mbps or so)
RX ring size is 1024 for all of these tests.  No significant errors reported
by the driver.  I don't know where these dropped packets go..no counter
seems to be catching them.

I sent 1 million packets (or very close to that) on every interface (received
the same, mostly)

Without SKB-Recycle:
   dropped 339 out of 1Million, repeated test twice, numbers very similar.
   When packets do drop, they drop on all interfaces in bursts of 10-150, generally.
   Latency was about .3ms

With SKB-Recycle (300 pkt hot-list)
   dropped 230, 500, and 180 in consecutive runs.  They also drop in bursts.
   The middle run may be bad luck...don't know.
   Latency was about .3ms
   While typing, I ran a longer test.  Dropped about 1600 out of 4 million.

So, I think I can't draw too much from any of this.  The bottleneck and/or
problem seems to lie elsewhere.  I will work on testing various rx-buffer
sizes tomorrow...

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


--------------080602000200060108030909
Content-Type: text/plain;
 name="napi_tune_2.4.19.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="napi_tune_2.4.19.patch"

--- linux-2.4.19.p3/include/linux/skbuff.h	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.p4/include/linux/skbuff.h	Wed Nov  6 22:21:52 2002
@@ -14,6 +14,8 @@
 #ifndef _LINUX_SKBUFF_H
 #define _LINUX_SKBUFF_H
 
+#define CONFIG_NET_SKB_RECYCLING
+
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -25,6 +27,7 @@
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
+#include <linux/if_packet.h> /* PACKET_HOST */
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -194,6 +197,11 @@
 	unsigned char 	*end;			/* End pointer					*/
 
 	void 		(*destructor)(struct sk_buff *);	/* Destruct function		*/
+#ifdef CONFIG_NET_SKB_RECYCLING
+       struct net_device *recycle_dev;         /* Device we arrived on                         */
+         int  tag;                               /* Device private tag. */
+#endif
+
 #ifdef CONFIG_NETFILTER
 	/* Can be used for communication between hooks. */
         unsigned long	nfmark;
@@ -1109,6 +1117,45 @@
 #endif
 }
 
+
+/*
+ *	Slab constructor for a skb head. 
+ */ 
+static inline void skb_headerinit(void *p, kmem_cache_t *cache, 
+				  unsigned long flags)
+{
+	struct sk_buff *skb = p;
+
+	skb->next = NULL;
+	skb->prev = NULL;
+	skb->list = NULL;
+	skb->sk = NULL;
+	skb->stamp.tv_sec=0;	/* No idea about time */
+	skb->dev = NULL;
+	skb->dst = NULL;
+	memset(skb->cb, 0, sizeof(skb->cb));
+	skb->pkt_type = PACKET_HOST;	/* Default type */
+	skb->ip_summed = 0;
+	skb->priority = 0;
+	skb->security = 0;	/* By default packets are insecure */
+	skb->destructor = NULL;
+
+#ifdef CONFIG_NET_SKB_RECYCLING
+	skb->recycle_dev = 0;
+#endif
+
+#ifdef CONFIG_NETFILTER
+	skb->nfmark = skb->nfcache = 0;
+	skb->nfct = NULL;
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug = 0;
+#endif
+#endif
+#ifdef CONFIG_NET_SCHED
+	skb->tc_index = 0;
+#endif
+}
+
 #define skb_queue_walk(queue, skb) \
 		for (skb = (queue)->next;			\
 		     (skb != (struct sk_buff *)(queue));	\
--- linux-2.4.19.p3/net/core/skbuff.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.p4/net/core/skbuff.c	Tue Nov  5 22:02:57 2002
@@ -217,40 +217,6 @@
 }
 
 
-/*
- *	Slab constructor for a skb head. 
- */ 
-static inline void skb_headerinit(void *p, kmem_cache_t *cache, 
-				  unsigned long flags)
-{
-	struct sk_buff *skb = p;
-
-	skb->next = NULL;
-	skb->prev = NULL;
-	skb->list = NULL;
-	skb->sk = NULL;
-	skb->stamp.tv_sec=0;	/* No idea about time */
-	skb->dev = NULL;
-	skb->dst = NULL;
-	memset(skb->cb, 0, sizeof(skb->cb));
-	skb->pkt_type = PACKET_HOST;	/* Default type */
-	skb->ip_summed = 0;
-	skb->priority = 0;
-	skb->security = 0;	/* By default packets are insecure */
-	skb->destructor = NULL;
-
-#ifdef CONFIG_NETFILTER
-	skb->nfmark = skb->nfcache = 0;
-	skb->nfct = NULL;
-#ifdef CONFIG_NETFILTER_DEBUG
-	skb->nf_debug = 0;
-#endif
-#endif
-#ifdef CONFIG_NET_SCHED
-	skb->tc_index = 0;
-#endif
-}
-
 static void skb_drop_fraglist(struct sk_buff *skb)
 {
 	struct sk_buff *list = skb_shinfo(skb)->frag_list;
@@ -326,8 +292,15 @@
 #ifdef CONFIG_NETFILTER
 	nf_conntrack_put(skb->nfct);
 #endif
-	skb_headerinit(skb, NULL, 0);  /* clean state */
-	kfree_skbmem(skb);
+
+#ifdef CONFIG_NET_SKB_RECYCLING
+       if(skb->recycle_dev && skb->recycle_dev->skb_recycle ) {
+	       if(skb->recycle_dev->skb_recycle(skb)) return;
+       }
+#endif
+
+       skb_headerinit(skb, NULL, 0);  /* clean state */
+       kfree_skbmem(skb);
 }
 
 /**
@@ -384,6 +357,9 @@
 	C(tail);
 	C(end);
 	n->destructor = NULL;
+#ifdef CONFIG_NET_SKB_RECYCLING
+	skb->recycle_dev = 0;
+#endif
 #ifdef CONFIG_NETFILTER
 	C(nfmark);
 	C(nfcache);
@@ -428,6 +404,9 @@
 	new->pkt_type=old->pkt_type;
 	new->stamp=old->stamp;
 	new->destructor = NULL;
+#ifdef CONFIG_NET_SKB_RECYCLING
+	new->recycle_dev = 0;
+#endif
 	new->security=old->security;
 #ifdef CONFIG_NETFILTER
 	new->nfmark=old->nfmark;
--- linux-2.4.19.p3/Documentation/networking/skb_recycling.txt	Wed Dec 31 16:00:00 1969
+++ linux-2.4.19.p4/Documentation/networking/skb_recycling.txt	Tue Nov  5 22:02:57 2002
@@ -0,0 +1,186 @@
+
+skb reuse. 
+-----------
+
+Q: Why?
+A: With skb recycling one has the option of recycling the skb with the
+   driver that allocated it in the first place.  This decreases the need
+   to malloc memory for each packet, and also should help keep from
+   invalidating the cache so often.  This all leads to higher performance
+   networking, and also provides better ways to tune a system to your high
+   performance needs.
+
+Q: Slab does the job already.
+A: Yes and RC uses slab for object coloring etc but can have some advances
+   of having a closer loop. Also there are some upcoming hardware that needs 
+   this skb handling.
+
+Q: With this memory will be allocated in "private" that kernel cannot use?
+A: Yes true. But do deal with a new driver method is added. "mem_reclaim"
+   this can be called from anyone (kernel) to ask the driver to give back
+   allocated memory.  The amount of memory kept by the driver can be made
+   run-time adjustable easily, and it can also be specified at module load
+   time.
+
+Q: Isn't the same job to be done now at the driver instead of at kfree?
+A: No by knowing that the same skb is returned the driver/allocator can do 
+   a minimal refresh of the skb header and avoid the relatively costly 
+   alloc and free of the "data" part. Just a minimal "refresh" is needed 
+   the when driver gets it's old skb back. The skb was good before...
+   Also this can be used to re-route an skb to initialized in CPU where
+   is was created. With SMP the TX interrupt can come in any CPU and this
+   causes cache bouncing. Eventually we can reduce this be marking 
+   the skb where is was created and at the recycler put it back on that
+   list. Not slab uses per-CPU lists but just put the skb back on the
+   "current" slab.
+
+Q: SMP and L2 cache locality?
+A: Driver can have "per-CPU" recycling and stores recycled skb's in LIFO 
+   this should result in L2 cache friendliness. Tests to be done...
+
+Q: Compatibility? Does it break "old" drivers?
+A: No, because old drivers do not mark any recycler callback. Alloc and 
+   kfree runs as usual. 
+
+Q: The skb's are added lot of states as the they travel through the IP 
+   stack. How is this handled?
+A: Well we wait util the "states" are properly handled we have no hurry 
+   to recycle the skb and clearing of the states has to be done anyway.
+
+Q: Is it proven in "real life" yet?
+A: No. It's research and under development
+   It works for me. --Ben
+
+
+1) Implementation
+
+
+* Kernel part.
+
+
+
+* Driver part.
+
+
+Recycling callback and skb buffers in e1000
+===========================================
+In the private driver field:
+
+
+#ifdef CONFIG_NET_SKB_RECYCLING
+        unsigned int cnt[NR_CPUS];
+
+        union {
+                struct sk_buff_head     list;
+                char                    pad[SMP_CACHE_BYTES];
+        } e1000_recycle[NR_CPUS];
+        
+#endif 
+
+
+The main recycler
+=================
+
+
+int skb_hotlist = 300;
+
+int e1000_recycle(struct sk_buff *skb)
+{
+
+	/* Note! skb->skb_recycle CANNOT be NULL here */
+ 	struct e1000_adapter *adapter = skb->recycle_dev->priv;
+
+	/* Store for right CPU. For this we use skb->tag */
+	struct sk_buff_head *list = &adapter->e1000_recycle[skb->tag].list;
+
+	/* 
+	   decrease our outstanding skb's:
+	   1) either we store in the list OR
+	   2) we ignore so gets to kfree
+	*/
+
+	adapter->cnt[smp_processor_id()]--;
+
+	if (skb_queue_len(list) <= skb_hotlist) {
+
+		/* LIFO queue for cache friendliness */
+
+		skb_queue_head(list, skb);
+		return 1;
+	} 
+	return 0;
+}
+
+
+At open:
+========
+
+        for (i=0; i<NR_CPUS; i++) {
+                skb_queue_head_init(&adapter->e1000_recycle[i].list);
+        }
+
+At close:
+=========
+
+        /* Schedule while outstanding skb's exists  */
+
+        for (i=0; i<NR_CPUS; i++) {
+                while(adapter->cnt[i]) {
+                        current->state = TASK_INTERRUPTIBLE;
+                        schedule_timeout(1);
+                }
+        }
+
+        for (i=0; i<NR_CPUS; i++) {
+                struct sk_buff *skb;
+                struct sk_buff_head *list = &adapter->e1000_recycle[i].list;
+                while ((skb=skb_dequeue(list))!=NULL) {
+                        skb->recycle_dev = NULL;
+                        kfree_skb(skb);
+                }
+                
+        }
+
+
+When allocting RX buffers:
+==========================
+
+		skb = skb_dequeue(list); /* Try recycler list */
+
+		if(skb) {
+	                 skb_headerinit(skb, NULL, 0);  /* clean state */
+
+			 /* NOTE. e1000 uses not dev_alloc_skb */
+			 
+			 skb->data = skb->head;
+			 skb->tail = skb->head;
+			 skb->len = 0;
+			 adapter->RC_hit++;
+		}
+		else adapter->RC_miss++;
+
+	      	if(!skb) 
+
+		skb = alloc_skb(adapter->rx_buffer_len + reserve_len, GFP_ATOMIC);
+
+		if(!skb) {
+			/* Better luck next round */
+			break;
+		}
+
+		adapter->cnt[smp_processor_id()]++;
+		skb->tag = smp_processor_id();
+		skb->recycle_dev = netdev;
+		skb->recycle_dev->skb_recycle = e1000_recycle;
+
+
+And to well behaved kernel citizen
+==================================
+void e1000_mem_reclaim(struct net_device *dev)
+{
+/* Someone (kernel probably) is asking us to reduce memory usage */
+
+        /* If we use RC we purge private buffers etc.*/
+        /* TODO: */
+
+}

--------------080602000200060108030909
Content-Type: text/plain;
 name="tulip_2.4.19.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tulip_2.4.19.patch"

--- linux-2.4.19.p3/drivers/net/tulip/interrupt.c	Tue Nov  5 21:33:22 2002
+++ linux-2.4.19.p4/drivers/net/tulip/interrupt.c	Tue Nov  5 22:08:45 2002
@@ -1,4 +1,4 @@
-/*
+/* -*-linux-c-*-
 	drivers/net/tulip/interrupt.c
 
 	Maintained by Jeff Garzik <jgarzik@mandrakesoft.com>
@@ -23,9 +23,14 @@
 int tulip_rx_copybreak;
 unsigned int tulip_max_interrupt_work;
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
+#ifdef CONFIG_NET_SKB_RECYCLING
+int tulip_recycle(struct sk_buff *skb);
+#endif
 
+#ifdef USE_MITIGATION
 #define MIT_SIZE 15
+#define MIT_TABLE 15 /* We use 0 or max */
+
 unsigned int mit_table[MIT_SIZE+1] =
 {
         /*  CRS11 21143 hardware Mitigation Control Interrupt
@@ -99,16 +104,28 @@
 	return refilled;
 }
 
+void oom_timer(unsigned long data)
+{
+        struct net_device *dev = (struct net_device *)data;
+	netif_rx_schedule(dev);
+}
+
 
-static int tulip_rx(struct net_device *dev)
+int tulip_poll(struct net_device *dev, int *budget)
 {
 	struct tulip_private *tp = (struct tulip_private *)dev->priv;
 	int entry = tp->cur_rx % RX_RING_SIZE;
-	int rx_work_limit = tp->dirty_rx + RX_RING_SIZE - tp->cur_rx;
+	int rx_work_limit = *budget;
 	int received = 0;
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        int drop = 0, mit_sel = 0;
+#ifdef EXTRA_STATS     
+	tp->stats_poll_starts++;
+#endif
+
+	if (rx_work_limit > dev->quota)
+		rx_work_limit = dev->quota;
+
+#ifdef USE_MITIGATION
 
 /* that one buffer is needed for mit activation; or might be a
    bug in the ring buffer code; check later -- JHS*/
@@ -118,177 +135,266 @@
 
 	if (tulip_debug > 4)
 		printk(KERN_DEBUG " In tulip_rx(), entry %d %8.8x.\n", entry,
-			   tp->rx_ring[entry].status);
-	/* If we own the next entry, it is a new packet. Send it up. */
-	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
-		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
-
-		if (tulip_debug > 5)
-			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
-				   dev->name, entry, status);
-		if (--rx_work_limit < 0)
-			break;
-		if ((status & 0x38008300) != 0x0300) {
-			if ((status & 0x38000300) != 0x0300) {
-				/* Ingore earlier buffers. */
-				if ((status & 0xffff) != 0x7fff) {
-					if (tulip_debug > 1)
-						printk(KERN_WARNING "%s: Oversized Ethernet frame "
-							   "spanned multiple buffers, status %8.8x!\n",
-							   dev->name, status);
-					tp->stats.rx_length_errors++;
-				}
-			} else if (status & RxDescFatalErr) {
+		       tp->rx_ring[entry].status);
+
+
+	do {
+		/* Acknowledge current RX interrupt sources. */
+		outl((RxIntr | RxNoBuf), dev->base_addr + CSR5);
+
+
+		/* If we own the next entry, it is a new packet. Send it up. */
+		while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
+			s32 status = le32_to_cpu(tp->rx_ring[entry].status);
+
+
+			if (tp->dirty_rx + RX_RING_SIZE == tp->cur_rx)
+				break;
+
+			if (tulip_debug > 5)
+				printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
+				       dev->name, entry, status);
+			if (--rx_work_limit < 0)
+				goto not_done;
+
+			if ((status & 0x38008300) != 0x0300) {
+				if ((status & 0x38000300) != 0x0300) {
+				/* Ignore earlier buffers. */
+					if ((status & 0xffff) != 0x7fff) {
+						if (tulip_debug > 1)
+							printk(KERN_WARNING "%s: Oversized Ethernet frame "
+							       "spanned multiple buffers, status %8.8x!\n",
+							       dev->name, status);
+						tp->stats.rx_length_errors++;
+					}
+				} else if (status & RxDescFatalErr) {
 				/* There was a fatal error. */
-				if (tulip_debug > 2)
-					printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
-						   dev->name, status);
-				tp->stats.rx_errors++; /* end of a packet.*/
-				if (status & 0x0890) tp->stats.rx_length_errors++;
-				if (status & 0x0004) tp->stats.rx_frame_errors++;
-				if (status & 0x0002) tp->stats.rx_crc_errors++;
-				if (status & 0x0001) tp->stats.rx_fifo_errors++;
-			}
-		} else {
-			/* Omit the four octet CRC from the length. */
-			short pkt_len = ((status >> 16) & 0x7ff) - 4;
-			struct sk_buff *skb;
+					if (tulip_debug > 2)
+						printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
+						       dev->name, status);
+					tp->stats.rx_errors++; /* end of a packet.*/
+					if (status & 0x0890) tp->stats.rx_length_errors++;
+					if (status & 0x0004) tp->stats.rx_frame_errors++;
+					if (status & 0x0002) tp->stats.rx_crc_errors++;
+					if (status & 0x0001) tp->stats.rx_fifo_errors++;
+				}
+			} else {
+				/* Omit the four octet CRC from the length. */
+				short pkt_len = ((status >> 16) & 0x7ff) - 4;
+				struct sk_buff *skb = NULL;
 
 #ifndef final_version
-			if (pkt_len > 1518) {
-				printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
-					   dev->name, pkt_len, pkt_len);
-				pkt_len = 1518;
-				tp->stats.rx_length_errors++;
-			}
+				if (pkt_len > 1518) {
+					printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
+					       dev->name, pkt_len, pkt_len);
+					pkt_len = 1518;
+					tp->stats.rx_length_errors++;
+				}
 #endif
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        drop = atomic_read(&netdev_dropping);
-                        if (drop)
-                                goto throttle;
-#endif
-			/* Check if the packet is long enough to accept without copying
-			   to a minimally-sized skbuff. */
-			if (pkt_len < tulip_rx_copybreak
-				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
-				skb->dev = dev;
-				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-				pci_dma_sync_single(tp->pdev,
-						    tp->rx_buffers[entry].mapping,
-						    pkt_len, PCI_DMA_FROMDEVICE);
+				/* Check if the packet is long enough to accept without copying
+				   to a minimally-sized skbuff. */
+#ifdef CONFIG_NET_SKB_RECYCLING
+                                if (pkt_len < tulip_rx_copybreak) {
+                                        /* Allocate an skb from our private queue if possible */
+                                        skb = skb_dequeue(&(tp->tulip_recycle[smp_processor_id()].list));
+                                        if (skb) {
+                                                skb_headerinit(skb, NULL, 0);  /* clean state */
+                                                
+                                                skb->data = skb->head;
+                                                skb->tail = skb->head;
+                                                skb->len = 0;
+                                        }
+                                }
+#endif                                
+				if ((pkt_len < tulip_rx_copybreak)
+				    && ((skb != NULL)
+                                        || ((skb = dev_alloc_skb(pkt_len + 2)) != NULL))) {
+					skb->dev = dev;
+					skb_reserve(skb, 2);	/* 16 byte align the IP header */
+					pci_dma_sync_single(tp->pdev,
+							    tp->rx_buffers[entry].mapping,
+							    pkt_len, PCI_DMA_FROMDEVICE);
 #if ! defined(__alpha__)
-				eth_copy_and_sum(skb, tp->rx_buffers[entry].skb->tail,
-						 pkt_len, 0);
-				skb_put(skb, pkt_len);
+					eth_copy_and_sum(skb, tp->rx_buffers[entry].skb->tail,
+							 pkt_len, 0);
+					skb_put(skb, pkt_len);
 #else
-				memcpy(skb_put(skb, pkt_len),
-				       tp->rx_buffers[entry].skb->tail,
-				       pkt_len);
-#endif
-			} else { 	/* Pass up the skb already on the Rx ring. */
-				char *temp = skb_put(skb = tp->rx_buffers[entry].skb,
-						     pkt_len);
+					memcpy(skb_put(skb, pkt_len),
+					       tp->rx_buffers[entry].skb->tail,
+					       pkt_len);
+#endif
+#ifdef CONFIG_NET_SKB_RECYCLING
+                                        skb->tag = smp_processor_id();
+                                        tp->cnt[skb->tag]++;
+                                        skb->recycle_dev = dev;
+                                        skb->recycle_dev->skb_recycle = tulip_recycle;
+#endif
+				} else { 	/* Pass up the skb already on the Rx ring. */
+					char *temp = skb_put(skb = tp->rx_buffers[entry].skb,
+							     pkt_len);
 
 #ifndef final_version
-				if (tp->rx_buffers[entry].mapping !=
-				    le32_to_cpu(tp->rx_ring[entry].buffer1)) {
-					printk(KERN_ERR "%s: Internal fault: The skbuff addresses "
-					       "do not match in tulip_rx: %08x vs. %08x %p / %p.\n",
-					       dev->name,
-					       le32_to_cpu(tp->rx_ring[entry].buffer1),
-					       tp->rx_buffers[entry].mapping,
-					       skb->head, temp);
-				}
+					if (tp->rx_buffers[entry].mapping !=
+					    le32_to_cpu(tp->rx_ring[entry].buffer1)) {
+						printk(KERN_ERR "%s: Internal fault: The skbuff addresses "
+						       "do not match in tulip_rx: %08x vs. %08x %p / %p.\n",
+						       dev->name,
+						       le32_to_cpu(tp->rx_ring[entry].buffer1),
+						       tp->rx_buffers[entry].mapping,
+						       skb->head, temp);
+					}
 #endif
 
-				pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
-						 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+					pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
+							 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 
-				tp->rx_buffers[entry].skb = NULL;
-				tp->rx_buffers[entry].mapping = 0;
-			}
-			skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        mit_sel =
-#endif
-			netif_rx(skb);
-
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        switch (mit_sel) {
-                        case NET_RX_SUCCESS:
-                        case NET_RX_CN_LOW:
-                        case NET_RX_CN_MOD:
-                                break;
-
-                        case NET_RX_CN_HIGH:
-                                rx_work_limit -= NET_RX_CN_HIGH; /* additional*/
-                                break;
-                        case NET_RX_DROP:
-                                rx_work_limit = -1;
-                                break;
-                        default:
-                                printk("unknown feedback return code %d\n", mit_sel);
-                                break;
-                        }
+					tp->rx_buffers[entry].skb = NULL;
+					tp->rx_buffers[entry].mapping = 0;
+				}
+				skb->protocol = eth_type_trans(skb, dev);
 
-                        drop = atomic_read(&netdev_dropping);
-                        if (drop) {
-throttle:
-                                rx_work_limit = -1;
-                                mit_sel = NET_RX_DROP;
-
-                                if (tp->fc_bit) {
-                                        long ioaddr = dev->base_addr;
-
-                                        /* disable Rx & RxNoBuf ints. */
-                                        outl(tulip_tbl[tp->chip_id].valid_intrs&RX_A_NBF_STOP, ioaddr + CSR7);
-                                        set_bit(tp->fc_bit, &netdev_fc_xoff);
-                                }
-                        }
+				netif_receive_skb(skb);
+
+				dev->last_rx = jiffies;
+				tp->stats.rx_packets++;
+				tp->stats.rx_bytes += pkt_len;
+			}
+			received++;
+#ifdef EXTRA_STATS
+			tp->stats_poll_pkts++;
+#ifdef USE_MITIGATION
+			if(tp->mit_on) tp->stats_poll_pkts_mit++;
+#endif
 #endif
-			dev->last_rx = jiffies;
-			tp->stats.rx_packets++;
-			tp->stats.rx_bytes += pkt_len;
+			entry = (++tp->cur_rx) % RX_RING_SIZE;
+			if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/4)
+				tulip_refill_rx(dev);
+
 		}
-		received++;
-		entry = (++tp->cur_rx) % RX_RING_SIZE;
-	}
-#ifdef CONFIG_NET_HW_FLOWCONTROL
+
+		/* New ack strategy... irq does not ack Rx any longer
+		   hopefully this helps */
+
+		/* Really bad things can happen here... If new packet arrives
+		 * and an irq arrives (tx or just due to occasionally unset
+		 * mask), it will be acked by irq handler, but new thread
+		 * is not scheduled. It is major hole in design.
+		 * No idea how to fix this if "playing with fire" will fail
+		 * tomorrow (night 011029). If it will not fail, we won
+		 * finally: amount of IO did not increase at all. */
+	} while ((inl(dev->base_addr + CSR5) & RxIntr));
+
+/* done: */
+
+#ifdef USE_MITIGATION
 
         /* We use this simplistic scheme for IM. It's proven by
            real life installations. We can have IM enabled
-           continuesly but this would cause unnecessary latency.
-           Unfortunely we can't use all the NET_RX_* feedback here.
-           This would turn on IM for devices that is not contributing
-           to backlog congestion with unnecessary latency.
+           continuesly but this would cause unnecessary latency. 
+           Unfortunely we can't use all the NET_RX_* feedback here. 
+           This would turn on IM for devices that is not contributing 
+           to backlog congestion with unnecessary latency. 
 
            We monitor the the device RX-ring and have:
 
            HW Interrupt Mitigation either ON or OFF.
 
-           ON:  More then 1 pkt received (per intr.) OR we are dropping
+           ON:  More then 1 pkt received (per intr.) OR we are dropping 
            OFF: Only 1 pkt received
-
+           
            Note. We only use min and max (0, 15) settings from mit_table */
 
 
         if( tp->flags &  HAS_INTR_MITIGATION) {
-                if((received > 1 || mit_sel == NET_RX_DROP)
-                   && tp->mit_sel != 15 ) {
-                        tp->mit_sel = 15;
-                        tp->mit_change = 1; /* Force IM change */
+                if( received > 1 ) {
+                        if( ! tp->mit_on ) {
+                                tp->mit_on = 1;
+                                outl(mit_table[MIT_TABLE], dev->base_addr + CSR11);
+                        }
                 }
-                if((received <= 1 && mit_sel != NET_RX_DROP) && tp->mit_sel != 0 ) {
-                        tp->mit_sel = 0;
-                        tp->mit_change = 1; /* Force IM change */
+                else {
+                        if( tp->mit_on ) {
+                                tp->mit_on = 0;
+                                outl(0, dev->base_addr + CSR11);
+                        }
                 }
         }
 
-        return RX_RING_SIZE+1; /* maxrx+1 */
-#else
-	return received;
 #endif
+
+        dev->quota -= received;
+        *budget -= received;
+
+        tulip_refill_rx(dev);
+        
+        /* If RX ring is not full we are out of memory. */
+        if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL) goto oom;
+
+#ifdef EXTRA_STATS
+        if((inl(dev->base_addr + CSR5) & RxIntr)) tp->stats_poll_exit_done_rx_pending++;
+        tp->stats_poll_exit_done++;
+#endif
+
+        /* Remove us from polling list and enable RX intr. */
+
+        netif_rx_complete(dev);
+        outl(tulip_tbl[tp->chip_id].valid_intrs, dev->base_addr+CSR7);
+
+        /* The last op happens after poll completion. Which means the following:
+         * 1. it can race with disabling irqs in irq handler
+         * 2. it can race with dise/enabling irqs in other poll threads
+         * 3. if an irq raised after beginning loop, it will be immediately
+         *    triggered here.
+         *
+         * Summarizing: the logic results in some redundant irqs both
+         * due to races in masking and due to too late acking of already
+         * processed irqs. But it must not result in losing events.
+         */
+
+        return 0;
+
+not_done:
+        if (!received) {
+#ifdef EXTRA_STATS
+                tp->stats_poll_zero_rx++;
+#endif
+                /* received = dev->quota; Why existed? --Ben */ /* Not to happen */
+        }
+        else {
+                dev->quota -= received;
+                *budget -= received;
+        }
+        
+        if (tp->cur_rx - tp->dirty_rx > RX_RING_SIZE/2 ||
+            tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL)
+                tulip_refill_rx(dev);
+
+        if (tp->rx_buffers[tp->dirty_rx % RX_RING_SIZE].skb == NULL) goto oom;
+
+#ifdef EXTRA_STATS
+        tp->stats_poll_exit_not_done++;
+#endif
+        return 1;
+
+
+oom:    /* Executed with RX ints disabled */
+        printk("ERROR: tulip:  Hit OOM trying to refill rx buffer.\n");
+        
+        /* Start timer, stop polling, but do not enable rx interrupts. */
+        mod_timer(&tp->oom_timer, jiffies+1);
+	
+        /* Think: timer_pending() was an explicit signature of bug.
+         * Timer can be pending now but fired and completed
+         * before we did netif_rx_complete(). See? We would lose it. */
+
+        /* remove ourselves from the polling list */
+        netif_rx_complete(dev);
+
+#ifdef EXTRA_STATS
+        tp->stats_poll_exit_oom++;
+#endif
+        return 0;
 }
 
 static inline void phy_interrupt (struct net_device *dev)
@@ -319,7 +425,6 @@
 	struct tulip_private *tp = (struct tulip_private *)dev->priv;
 	long ioaddr = dev->base_addr;
 	int csr5;
-	int entry;
 	int missed;
 	int rx = 0;
 	int tx = 0;
@@ -327,6 +432,7 @@
 	int maxrx = RX_RING_SIZE;
 	int maxtx = TX_RING_SIZE;
 	int maxoi = TX_RING_SIZE;
+	int rxd = 0;
 	unsigned int work_count = tulip_max_interrupt_work;
 
 	/* Let's see whether the interrupt really is for us */
@@ -341,21 +447,32 @@
 	tp->nir++;
 
 	do {
-		/* Acknowledge all of the current interrupt sources ASAP. */
-		outl(csr5 & 0x0001ffff, ioaddr + CSR5);
+#ifdef EXTRA_STATS
+		if(!rxd)
+			record_interrupt_cause(dev, csr5);
+		else
+			record_interrupt_cause(dev, csr5& 0x0001ff3f);
+#endif
 
+		if (!rxd && (csr5 & (RxIntr | RxNoBuf))) {
+			rxd++;
+			/* Mask RX intrs and add the device to poll list. */
+			outl(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ioaddr + CSR7);
+			netif_rx_schedule(dev);
+			
+			if (!(csr5&~(AbnormalIntr|NormalIntr|RxPollInt|TPLnkPass)))
+                               break;
+		}
+		
+               /* Acknowledge the interrupt sources we handle here ASAP
+                  the poll function does Rx and RxNoBuf acking */
+		
+		outl(csr5 & 0x0001ff3f, ioaddr + CSR5);
+		
 		if (tulip_debug > 4)
 			printk(KERN_DEBUG "%s: interrupt  csr5=%#8.8x new csr5=%#8.8x.\n",
-				   dev->name, csr5, inl(dev->base_addr + CSR5));
-
-		if (csr5 & (RxIntr | RxNoBuf)) {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        if ((!tp->fc_bit) ||
-			    (!test_bit(tp->fc_bit, &netdev_fc_xoff)))
-#endif
-				rx += tulip_rx(dev);
-			tulip_refill_rx(dev);
-		}
+			       dev->name, csr5, inl(dev->base_addr + CSR5));
+		
 
 		if (csr5 & (TxNoBuf | TxDied | TxIntr | TimerInt)) {
 			unsigned int dirty_tx;
@@ -457,15 +574,8 @@
 			}
 			if (csr5 & RxDied) {		/* Missed a Rx frame. */
                                 tp->stats.rx_missed_errors += inl(ioaddr + CSR8) & 0xffff;
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-				if (tp->fc_bit && !test_bit(tp->fc_bit, &netdev_fc_xoff)) {
-					tp->stats.rx_errors++;
-					tulip_start_rxtx(tp);
-				}
-#else
 				tp->stats.rx_errors++;
 				tulip_start_rxtx(tp);
-#endif
 			}
 			/*
 			 * NB: t21142_lnk_change() does a del_timer_sync(), so be careful if this
@@ -499,10 +609,6 @@
 			if (tulip_debug > 2)
 				printk(KERN_ERR "%s: Re-enabling interrupts, %8.8x.\n",
 					   dev->name, csr5);
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                        if (tp->fc_bit && (test_bit(tp->fc_bit, &netdev_fc_xoff)))
-                          if (net_ratelimit()) printk("BUG!! enabling interupt when FC off (timerintr.) \n");
-#endif
 			outl(tulip_tbl[tp->chip_id].valid_intrs, ioaddr + CSR7);
 			tp->ttimer = 0;
 			oi++;
@@ -515,11 +621,8 @@
                        /* Acknowledge all interrupt sources. */
                         outl(0x8001ffff, ioaddr + CSR5);
                         if (tp->flags & HAS_INTR_MITIGATION) {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-                                if(tp->mit_change) {
-                                        outl(mit_table[tp->mit_sel], ioaddr + CSR11);
-                                        tp->mit_change = 0;
-                                }
+#ifdef USE_MITIGATION
+				outl(mit_table[MIT_TABLE], ioaddr + CSR11);
 #else
                      /* Josip Loncaric at ICASE did extensive experimentation
 			to develop a good interrupt mitigation setting.*/
@@ -532,10 +635,8 @@
 			} else {
                           /* Mask all interrupting sources, set timer to
 				re-enable. */
-#ifndef CONFIG_NET_HW_FLOWCONTROL
                                 outl(((~csr5) & 0x0001ebef) | AbnormalIntr | TimerInt, ioaddr + CSR7);
                                 outl(0x0012, ioaddr + CSR11);
-#endif
                         }
 			break;
 		}
@@ -545,30 +646,18 @@
 			break;
 
 		csr5 = inl(ioaddr + CSR5);
-	} while ((csr5 & (NormalIntr|AbnormalIntr)) != 0);
-
-	tulip_refill_rx(dev);
-
-	/* check if the card is in suspend mode */
-	entry = tp->dirty_rx % RX_RING_SIZE;
-	if (tp->rx_buffers[entry].skb == NULL) {
-		if (tulip_debug > 1)
-			printk(KERN_WARNING "%s: in rx suspend mode: (%lu) (tp->cur_rx = %u, ttimer = %d, rx = %d) go/stay in suspend mode\n", dev->name, tp->nir, tp->cur_rx, tp->ttimer, rx);
-		if (tp->chip_id == LC82C168) {
-			outl(0x00, ioaddr + CSR7);
-			mod_timer(&tp->timer, RUN_AT(HZ/50));
-		} else {
-			if (tp->ttimer == 0 || (inl(ioaddr + CSR11) & 0xffff) == 0) {
-				if (tulip_debug > 1)
-					printk(KERN_WARNING "%s: in rx suspend mode: (%lu) set timer\n", dev->name, tp->nir);
-				outl(tulip_tbl[tp->chip_id].valid_intrs | TimerInt,
-					ioaddr + CSR7);
-				outl(TimerInt, ioaddr + CSR5);
-				outl(12, ioaddr + CSR11);
-				tp->ttimer = 1;
-			}
-		}
-	}
+		if (rxd)
+			csr5 &= ~RxPollInt;
+	} while ((csr5 & (TxNoBuf | 
+			  TxDied | 
+			  TxIntr | 
+			  TimerInt |
+			  /* Abnormal intr. */
+			  RxDied | 
+			  TxFIFOUnderflow | 
+			  TxJabber | 
+			  TPLnkFail |  
+			  SytemError )) != 0);
 
 	if ((missed = inl(ioaddr + CSR8) & 0x1ffff)) {
 		tp->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;
--- linux-2.4.19.p3/drivers/net/tulip/tulip_core.c	Tue Nov  5 21:33:22 2002
+++ linux-2.4.19.p4/drivers/net/tulip/tulip_core.c	Wed Nov  6 22:03:03 2002
@@ -1,4 +1,4 @@
-/* tulip_core.c: A DEC 21x4x-family ethernet driver for Linux. */
+/* -*-linux-c-*-  tulip_core.c: A DEC 21x4x-family ethernet driver for Linux. */
 
 /*
 	Maintained by Jeff Garzik <jgarzik@mandrakesoft.com>
@@ -14,10 +14,6 @@
 
 */
 
-#define DRV_NAME	"tulip"
-#define DRV_VERSION	"0.9.15-pre12"
-#define DRV_RELDATE	"Aug 9, 2002"
-
 #include <linux/config.h>
 #include <linux/module.h>
 #include "tulip.h"
@@ -44,7 +40,7 @@
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static unsigned int max_interrupt_work = 25;
 
-#define MAX_UNITS 8
+#define MAX_UNITS 16
 /* Used to pass the full-duplex flag, etc. */
 static int full_duplex[MAX_UNITS];
 static int options[MAX_UNITS];
@@ -105,6 +101,18 @@
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (4*HZ)
 
+/* Only used for SKB_RECYCLE, can't get it to #ifdef out on RH 7.3 */
+/* This is the maximum number of skbs per CPU that the driver will
+ * keep in it's recycle buffer list (per driver instance, ie per port).
+ * Each skb will cost you a little
+ * less than 2k, so if you have little memory and make this huge, bad
+ * things will happen.  For 256MB machines running at very high speeds,
+ * 1024 or 2048 may be better.  There seems to be no gain at higher
+ * values, at least on 100Mbps nics.
+ */
+static int skb_hotlist = 300;
+MODULE_PARM(skb_hotlist, "i");
+
 
 MODULE_AUTHOR("The Linux Kernel Team");
 MODULE_DESCRIPTION("Digital 21*4* Tulip ethernet driver");
@@ -494,29 +502,16 @@
 	   to an alternate media type. */
 	tp->timer.expires = RUN_AT(next_tick);
 	add_timer(&tp->timer);
-}
-
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-/* Enable receiver */
-void tulip_xon(struct net_device *dev)
-{
-        struct tulip_private *tp = (struct tulip_private *)dev->priv;
 
-        clear_bit(tp->fc_bit, &netdev_fc_xoff);
-        if (netif_running(dev)){
-
-                tulip_refill_rx(dev);
-                outl(tulip_tbl[tp->chip_id].valid_intrs,  dev->base_addr+CSR7);
-        }
+        init_timer(&tp->oom_timer);
+        tp->oom_timer.data = (unsigned long)dev;
+        tp->oom_timer.function = oom_timer;
 }
-#endif
+
 
 static int
 tulip_open(struct net_device *dev)
 {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        struct tulip_private *tp = (struct tulip_private *)dev->priv;
-#endif
 	int retval;
 	MOD_INC_USE_COUNT;
 
@@ -525,14 +520,23 @@
 		return retval;
 	}
 
-	tulip_init_ring (dev);
+#ifdef CONFIG_NET_SKB_RECYCLING
+        {
+           int i;
+           struct tulip_private *adapter = dev->priv;
+           for (i=0; i<NR_CPUS; i++) {
+                skb_queue_head_init(&adapter->tulip_recycle[i].list);
+           }
+        }
+#endif
 
+	tulip_init_ring (dev);
+        
 	tulip_up (dev);
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        tp->fc_bit = netdev_register_fc(dev, tulip_xon);
-#endif
-
+#ifdef EXTRA_STATS
+	tulip_open_misc(dev);
+#endif 
 	netif_start_queue (dev);
 
 	return 0;
@@ -640,10 +644,7 @@
 #endif
 
 	/* Stop and restart the chip's Tx processes . */
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        if (tp->fc_bit && test_bit(tp->fc_bit,&netdev_fc_xoff))
-                printk("BUG tx_timeout restarting rx when fc on\n");
-#endif
+
 	tulip_restart_rxtx(tp);
 	/* Trigger an immediate transmit demand. */
 	outl(0, ioaddr + CSR1);
@@ -719,6 +720,16 @@
 
 	spin_lock_irqsave(&tp->lock, eflags);
 
+       /* See if we can free slots on the output ring. In real life 
+	  examples we have seen between 2-10% of the slots cleared here */
+
+#ifdef NOT_NOW
+#ifdef EXTRA_STATS
+        tp->stats_tx_xmit_refilled += 
+#endif          
+		tx_ring_free(dev);  
+#endif
+
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % TX_RING_SIZE;
 
@@ -802,6 +813,7 @@
 	unsigned long flags;
 
 	del_timer_sync (&tp->timer);
+	del_timer_sync (&tp->oom_timer);
 
 	spin_lock_irqsave (&tp->lock, flags);
 
@@ -845,15 +857,31 @@
 
 	netif_stop_queue (dev);
 
-#ifdef CONFIG_NET_HW_FLOWCONTROL
-        if (tp->fc_bit) {
-                int bit = tp->fc_bit;
-                tp->fc_bit = 0;
-                netdev_unregister_fc(bit);
-        }
+#ifdef tEXTRA_STATS
+	tulip_close_misc(dev);
 #endif
 	tulip_down (dev);
 
+        /* Schedule while outstanding skb's exists  */
+
+#ifdef CONFIG_NET_SKB_RECYCLING
+        for (i=0; i<NR_CPUS; i++) {
+                while (tp->cnt[i]) {
+                        current->state = TASK_INTERRUPTIBLE;
+                        schedule_timeout(1);
+                }
+        }
+
+        for (i=0; i<NR_CPUS; i++) {
+                struct sk_buff *skb;
+                struct sk_buff_head *list = &tp->tulip_recycle[i].list;
+                while ((skb=skb_dequeue(list))!=NULL) {
+                        skb->recycle_dev = NULL;
+                        kfree_skb(skb);
+                }
+        }
+#endif  
+
 	if (tulip_debug > 1)
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, inl (ioaddr + CSR5));
@@ -1717,6 +1745,8 @@
 	dev->hard_start_xmit = tulip_start_xmit;
 	dev->tx_timeout = tulip_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+	dev->poll = tulip_poll;
+	dev->weight = 64;
 	dev->stop = tulip_close;
 	dev->get_stats = tulip_get_stats;
 	dev->do_ioctl = private_ioctl;
@@ -1811,6 +1841,9 @@
 	/* put the chip in snooze mode until opened */
 	tulip_set_power_state (tp, 0, 1);
 
+#ifdef EXTRA_STATS
+	tulip_init_one_misc(dev);
+#endif
 	return 0;
 
 err_out_free_ring:
@@ -1876,6 +1909,10 @@
 	if (!dev)
 		return;
 
+#ifdef EXTRA_STATS
+	tulip_remove_one_misc(dev);
+#endif
+
 	tp = dev->priv;
 	pci_free_consistent (pdev,
 			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
@@ -1895,6 +1932,36 @@
 }
 
 
+
+
+#ifdef CONFIG_NET_SKB_RECYCLING
+
+int tulip_recycle(struct sk_buff *skb)
+{
+ 	struct tulip_private *adapter = skb->recycle_dev->priv;
+
+	/* Store for right CPU. For this we use skb->tag */
+	struct sk_buff_head *list = &adapter->tulip_recycle[skb->tag].list;
+
+	/* 
+	   decrease our outstanding skb's:
+	   1) either we store in the list OR
+	   2) we ignore so gets to kfree
+	*/
+
+	adapter->cnt[smp_processor_id()]--;
+
+	if (skb_queue_len(list) <= skb_hotlist) {
+
+		/* LIFO queue for cache friendliness */
+		skb_queue_head(list, skb);
+		return 1;
+	} 
+	return 0;
+}
+#endif
+
+
 static struct pci_driver tulip_driver = {
 	name:		DRV_NAME,
 	id_table:	tulip_pci_tbl,
--- linux-2.4.19.p3/drivers/net/tulip/tulip.h	Tue Nov  5 21:33:22 2002
+++ linux-2.4.19.p4/drivers/net/tulip/tulip.h	Wed Nov  6 22:28:21 2002
@@ -16,6 +16,11 @@
 #ifndef __NET_TULIP_H__
 #define __NET_TULIP_H__
 
+#define DRV_NAME	"tulip"
+#define DRV_VERSION	"1.1.1-NAPI"
+#define DRV_RELDATE	"Feb 16, 2002"
+
+
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -26,7 +31,12 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
+#ifdef CONFIG_PROC_FS
+#include <linux/proc_fs.h>
+#endif
 
+/* #define EXTRA_STATS 1 */
+#undef USE_MITIGATION
 
 /* undefine, or define to various debugging levels (>4 == obscene levels) */
 #define TULIP_DEBUG 1
@@ -126,6 +136,7 @@
 	CFDD_Snooze = (1 << 30),
 };
 
+#define RxPollInt (RxIntr|RxNoBuf|RxDied|RxJabber)
 
 /* The bits in the CSR5 status registers, mostly interrupt sources. */
 enum status_bits {
@@ -261,8 +272,8 @@
    Making the Tx ring too large decreases the effectiveness of channel
    bonding and packet priority.
    There are no ill effects from too-large receive rings. */
-#define TX_RING_SIZE	16
-#define RX_RING_SIZE	32
+#define TX_RING_SIZE	128
+#define RX_RING_SIZE	1024
 
 #define MEDIA_MASK     31
 
@@ -351,8 +362,45 @@
 	int chip_id;
 	int revision;
 	int flags;
+        int mit_on;
 	struct net_device_stats stats;
+#ifdef EXTRA_STATS
+	unsigned long stats_tx_xmit_refilled; /* Pkts xmit-filled */
+	unsigned long stats_tx_irq_refilled; /* Pktss irq-filled*/
+	unsigned long stats_poll_starts;
+	unsigned long stats_poll_pkts;
+#ifdef USE_MITIGATION
+	unsigned long stats_poll_pkts_mit;
+#endif
+	unsigned long stats_poll_exit_done;
+	unsigned long stats_poll_exit_not_done;
+	unsigned long stats_poll_exit_oom;
+	unsigned long stats_poll_exit_done_rx_pending;
+	unsigned long stats_poll_zero_rx;
+#ifdef CONFIG_PROC_FS
+        struct proc_dir_entry *proc_ent;
+        char proc_ent_name[32];
+#endif
+        /*Tulip interrupts causes */
+	unsigned long stats_intr_normal;
+	unsigned long stats_intr_abnormal;
+	unsigned long stats_intr_timer;
+	
+	unsigned long stats_intr_rx;
+	unsigned long stats_intr_rx_nobuf;
+	unsigned long stats_intr_rx_died;
+	unsigned long stats_intr_rx_jabber;
+
+	unsigned long stats_intr_tx;
+	unsigned long stats_intr_tx_died;
+	unsigned long stats_intr_tx_nobuf;
+        unsigned long rx_small_skb_failure;
+	unsigned long stats_intr_TPLnkPass;
+	unsigned long open_time; /* jiffies for last open */
+
+#endif /* EXTRA_STATS */
 	struct timer_list timer;	/* Media selection timer. */
+	struct timer_list oom_timer;    /* Out of memory timer. */
 	u32 mc_filter[2];
 	spinlock_t lock;
 	spinlock_t mii_lock;
@@ -391,6 +439,15 @@
 	unsigned long base_addr;
 	int csr12_shadow;
 	int pad0;		/* Used for 8-byte alignment */
+
+#ifdef CONFIG_NET_SKB_RECYCLING
+        unsigned int cnt[NR_CPUS];
+
+        union {
+                struct sk_buff_head     list;
+                char                    pad[SMP_CACHE_BYTES];
+        } tulip_recycle[NR_CPUS];
+#endif 
 };
 
 
@@ -424,6 +481,7 @@
 extern unsigned int tulip_max_interrupt_work;
 extern int tulip_rx_copybreak;
 void tulip_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
+int tulip_poll(struct net_device *dev, int *budget);
 int tulip_refill_rx(struct net_device *dev);
 
 /* media.c */
@@ -448,11 +506,22 @@
 extern const char * const medianame[];
 extern const char tulip_media_cap[];
 extern struct tulip_chip_table tulip_tbl[];
+void oom_timer(unsigned long data);
 extern u8 t21040_csr13[];
 extern u16 t21041_csr13[];
 extern u16 t21041_csr14[];
 extern u16 t21041_csr15[];
 
+/* tulip_misc.c */
+#ifdef EXTRA_STATS
+void tulip_init_one_misc(struct net_device *dev);
+void tulip_remove_one_misc (struct net_device *dev);
+void tulip_open_misc(struct net_device *dev);
+void tulip_close_misc(struct net_device *dev);
+void ave_get(unsigned long arg);
+void record_interrupt_cause( struct net_device *dev, int csr5);
+#endif
+
 #ifndef USE_IO_OPS
 #undef inb
 #undef inw
@@ -498,3 +567,6 @@
 }
 
 #endif /* __NET_TULIP_H__ */
+
+
+

--------------080602000200060108030909--
