From: Ben Greear <greearb@candelatech.com>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Thu, 27 May 2004 12:29:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B641A3.7070209@candelatech.com>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com> <20031213182925.A1791@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        "Linux 802.1Q VLAN" <vlan@wanfear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031213182925.A1791@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Rask Ingemann Lambertsen wrote:
 > On Tue, Dec 09, 2003 at 11:45:42AM -0500, Jeff Garzik wrote:
 >
 >>Two questions and a comment...
 >>
 >>Would you split this into two patches?  The first simply adds, and uses,
 >>tp->rx_buf_sz.  The second adds PKT_BUF_SZ_MAX and mtu-related changes.
 >
 >
 > The first patch is attached to this message. I'm not happy with the second
 > part yet because it is too hackish and I would prefer to have a look at the
 > tulip documentation first.


Whatever became of this?  For what it's worth, I have been using
a patch originally by Ben McKeegan that seems to work fine.  But,
I'd be happy for either of the patches to go in so long as we can finally
get the tulip driver to work with VLANs.


--- linux-2.4.25/drivers/net/tulip/interrupt.c	2003-06-13 07:51:35.000000000 -0700
+++ linux-2.4.25.p4/drivers/net/tulip/interrupt.c	2004-05-24 17:24:26.000000000 -0700
@@ -1,4 +1,4 @@
-/*
+/*  -*-linux-c-*-
  	drivers/net/tulip/interrupt.c

  	Maintained by Jeff Garzik <jgarzik@pobox.com>
@@ -122,14 +122,34 @@
  	/* If we own the next entry, it is a new packet. Send it up. */
  	while ( ! (tp->rx_ring[entry].status & cpu_to_le32(DescOwned))) {
  		s32 status = le32_to_cpu(tp->rx_ring[entry].status);
-
+		short pkt_len;
+
  		if (tulip_debug > 5)
  			printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
  				   dev->name, entry, status);
  		if (--rx_work_limit < 0)
  			break;
-		if ((status & 0x38008300) != 0x0300) {
-			if ((status & 0x38000300) != 0x0300) {
+		/*
+		  Omit the four octet CRC from the length.
+		  (May not be considered valid until we have
+		  checked status for RxLengthOver2047 bits)
+                */
+		pkt_len = ((status >> 16) & 0x7ff) - 4;
+
+		/*
+		  Maximum pkt_len is 1518 (1514 + vlan header)
+		  Anything higher than this is always invalid
+		  regardless of RxLengthOver2047 bits
+		*/
+
+		if (((status & (RxLengthOver2047 |
+				RxDescCRCError |
+				RxDescCollisionSeen |
+				RxDescRunt |
+				RxDescDescErr |
+				RxWholePkt)) != RxWholePkt)
+		    || (pkt_len > 1518) ) {
+			if ((status & (RxLengthOver2047 | RxWholePkt)) != RxWholePkt) {
  				/* Ingore earlier buffers. */
  				if ((status & 0xffff) != 0x7fff) {
  					if (tulip_debug > 1)
@@ -138,31 +158,21 @@
  							   dev->name, status);
  					tp->stats.rx_length_errors++;
  				}
-			} else if (status & RxDescFatalErr) {
+			} else {
  				/* There was a fatal error. */
  				if (tulip_debug > 2)
  					printk(KERN_DEBUG "%s: Receive error, Rx status %8.8x.\n",
  						   dev->name, status);
  				tp->stats.rx_errors++; /* end of a packet.*/
-				if (status & 0x0890) tp->stats.rx_length_errors++;
+				if ((pkt_len > 1518) || (status & RxDescRunt))
+					tp->stats.rx_length_errors++;
  				if (status & 0x0004) tp->stats.rx_frame_errors++;
  				if (status & 0x0002) tp->stats.rx_crc_errors++;
  				if (status & 0x0001) tp->stats.rx_fifo_errors++;
  			}
  		} else {
-			/* Omit the four octet CRC from the length. */
-			short pkt_len = ((status >> 16) & 0x7ff) - 4;
  			struct sk_buff *skb;

-#ifndef final_version
-			if (pkt_len > 1518) {
-				printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\n",
-					   dev->name, pkt_len, pkt_len);
-				pkt_len = 1518;
-				tp->stats.rx_length_errors++;
-			}
-#endif
-
  #ifdef CONFIG_NET_HW_FLOWCONTROL
                          drop = atomic_read(&netdev_dropping);
                          if (drop)
--- linux-2.4.25/drivers/net/tulip/tulip.h	2002-11-28 15:53:14.000000000 -0800
+++ linux-2.4.25.p4/drivers/net/tulip/tulip.h	2004-05-24 17:29:48.000000000 -0700
@@ -188,8 +188,40 @@

  enum desc_status_bits {
  	DescOwned = 0x80000000,
-	RxDescFatalErr = 0x8000,
+
+        /*
+	   Error summary flag is logical or of 'CRC Error',
+	   'Collision Seen', 'Frame Too Long', 'Runt' and
+	   'Descriptor Error' flags generated within tulip chip.
+	*/
+        RxDescErrorSummary = 0x8000,
+	
+	RxDescCRCError = 0x0002,
+        RxDescCollisionSeen = 0x0040,
+	
+        /*
+	   'Frame Too Long' flag is set if packet length including CRC
+	   exceeds 1518.  However, a full sized VLAN tagged frame is
+	   1522 bytes including CRC.
+	
+	   The tulip chip does not block oversized frames, and if this
+	   flag is set on a receive descriptor it does not indicate
+	   the frame has been truncated.  The receive descriptor also
+	   includes the actual length.  Therefore we can safety ignore
+	   this flag and check the length ourselves.
+        */
+        RxDescFrameTooLong = 0x0080,
+	RxDescRunt = 0x0800,
+	RxDescDescErr = 0x4000,
  	RxWholePkt = 0x0300,
+	
+	/*
+	  Top three bits of 14 bit frame length (status bits 27-29)
+          should never be set as that would make frame over 2047 bytes.
+	  The Receive Watchdog flag (bit 4) may indicate the length is
+          over 2048 and the length field is invalid.
+	*/
+	RxLengthOver2047 = 0x38000010
  };



> 
> 
>>Have you looked at Donald Becker's changes to tulip.c?  He went through 
>>most of his drivers and made the changes necessary to support larger 
>>MTUs.  IIRC his tulip.c changes (which should be easily translate-able 
>>to 2.6.x tulip) were a bit more minimal than your patch, but still 
>>served the purpose.
> 
> 
> I've just tested Becker's tulip.c v0.97 (7/22/2003) and it fails to receive
> packets larger than the standard 1514 bytes. "ping -s 1472" works while
> "ping -s 1473" doesn't (when pinging from another box).
> 
> 
> 
> ------------------------------------------------------------------------
> 
> --- linux-2.4.22/drivers/net/tulip/tulip.h-orig	Mon Dec  1 21:58:11 2003
> +++ linux-2.4.22/drivers/net/tulip/tulip.h	Mon Dec  1 22:09:14 2003
> @@ -347,6 +353,7 @@ struct tulip_private {
>  	struct ring_info tx_buffers[TX_RING_SIZE];
>  	/* The addresses of receive-in-place skbuffs. */
>  	struct ring_info rx_buffers[RX_RING_SIZE];
> +	uint rx_buf_sz;
>  	u16 setup_frame[96];	/* Pseudo-Tx frame to init address table. */
>  	int chip_id;
>  	int revision;
> --- linux-2.4.22/drivers/net/tulip/interrupt.c-orig	Mon Dec  1 21:52:10 2003
> +++ linux-2.4.22/drivers/net/tulip/interrupt.c	Mon Dec  1 22:03:50 2003
> @@ -74,11 +74,11 @@ int tulip_refill_rx(struct net_device *d
>  			struct sk_buff *skb;
>  			dma_addr_t mapping;
>  
> -			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(PKT_BUF_SZ);
> +			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(tp->rx_buf_sz);
>  			if (skb == NULL)
>  				break;
>  
> -			mapping = pci_map_single(tp->pdev, skb->tail, PKT_BUF_SZ,
> +			mapping = pci_map_single(tp->pdev, skb->tail, tp->rx_buf_sz,
>  						 PCI_DMA_FROMDEVICE);
>  			tp->rx_buffers[entry].mapping = mapping;
>  
> @@ -203,7 +202,7 @@ static int tulip_rx(struct net_device *d
>  #endif
>  
>  				pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
> -						 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
> +						 tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
>  
>  				tp->rx_buffers[entry].skb = NULL;
>  				tp->rx_buffers[entry].mapping = 0;
> --- linux-2.4.22/drivers/net/tulip/tulip_core.c-orig	Mon Dec  1 21:34:32 2003
> +++ linux-2.4.22/drivers/net/tulip/tulip_core.c	Mon Dec  1 22:10:53 2003
> @@ -518,9 +521,7 @@ void tulip_xon(struct net_device *dev)
>  static int
>  tulip_open(struct net_device *dev)
>  {
> -#ifdef CONFIG_NET_HW_FLOWCONTROL
>          struct tulip_private *tp = (struct tulip_private *)dev->priv;
> -#endif
>  	int retval;
>  	MOD_INC_USE_COUNT;
>  
> @@ -529,6 +530,7 @@ tulip_open(struct net_device *dev)
>  		return retval;
>  	}
>  
> + 	tp->rx_buf_sz = PKT_BUF_SZ;
>  	tulip_init_ring (dev);
>  
>  	tulip_up (dev);
> @@ -673,13 +678,13 @@ static void tulip_init_ring(struct net_d
>  
>  	for (i = 0; i < RX_RING_SIZE; i++) {
>  		tp->rx_ring[i].status = 0x00000000;
> -		tp->rx_ring[i].length = cpu_to_le32(PKT_BUF_SZ);
> +		tp->rx_ring[i].length = cpu_to_le32(tp->rx_buf_sz);
>  		tp->rx_ring[i].buffer2 = cpu_to_le32(tp->rx_ring_dma + sizeof(struct tulip_rx_desc) * (i + 1));
>  		tp->rx_buffers[i].skb = NULL;
>  		tp->rx_buffers[i].mapping = 0;
>  	}
>  	/* Mark the last entry as wrapping the ring. */
> -	tp->rx_ring[i-1].length = cpu_to_le32(PKT_BUF_SZ | DESC_RING_WRAP);
> +	tp->rx_ring[i-1].length = cpu_to_le32(tp->rx_buf_sz | DESC_RING_WRAP);
>  	tp->rx_ring[i-1].buffer2 = cpu_to_le32(tp->rx_ring_dma);
>  
>  	for (i = 0; i < RX_RING_SIZE; i++) {
> @@ -688,12 +693,12 @@ static void tulip_init_ring(struct net_d
>  		/* Note the receive buffer must be longword aligned.
>  		   dev_alloc_skb() provides 16 byte alignment.  But do *not*
>  		   use skb_reserve() to align the IP header! */
> -		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
> +		struct sk_buff *skb = dev_alloc_skb(tp->rx_buf_sz);
>  		tp->rx_buffers[i].skb = skb;
>  		if (skb == NULL)
>  			break;
>  		mapping = pci_map_single(tp->pdev, skb->tail,
> -					 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
> +					 tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
>  		tp->rx_buffers[i].mapping = mapping;
>  		skb->dev = dev;			/* Mark as being used by this device. */
>  		tp->rx_ring[i].status = cpu_to_le32(DescOwned);	/* Owned by Tulip chip */
> @@ -876,7 +881,7 @@ static int tulip_close (struct net_devic
>  		tp->rx_ring[i].length = 0;
>  		tp->rx_ring[i].buffer1 = 0xBADF00D0;	/* An invalid address. */
>  		if (skb) {
> -			pci_unmap_single(tp->pdev, mapping, PKT_BUF_SZ,
> +			pci_unmap_single(tp->pdev, mapping, tp->rx_buf_sz,
>  					 PCI_DMA_FROMDEVICE);
>  			dev_kfree_skb (skb);
>  		}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
