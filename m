From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Wed, 20 Feb 2013 09:49:25 -0600
Message-ID: <5124F085.7010700@lwfinger.net>
References: <20130219.005206.397289032011003833.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com> <5123BCFF.5090408@lwfinger.net> <20130219.131553.787630407148880340.davem@davemloft.net> <5123C43D.2020602@lwfinger.net> <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com> <512437FA.2030105@lwfinger.net> <CA+XFjipJHGTvzUx6yy1DTc74kbrPEQxM08zW=N1uf43=Q6pwdg@mail.gmail.com> <5124782D.3050803@lwfinger.net> <20130220081538.GO8730@medion.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060704060006080405010304"
To: =?ISO-8859-15?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>,
	Julian Calaby <julian.calaby@gmail.com>,
	David Miller <davem@davemloft.net>, David.Laight@aculab.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	openwrt-devel@lists.openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f177.google.com ([209.85.161.177]:34536 "EHLO
	mail-gg0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934760Ab3BTPt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 10:49:29 -0500
In-Reply-To: <20130220081538.GO8730@medion.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060704060006080405010304
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

On 02/20/2013 02:15 AM, Bastian Bittorf wrote:
> * Larry Finger <Larry.Finger@lwfinger.net> [20.02.2013 08:32]:
>> On 02/20/2013 12:26 AM, Gábor Stefanik wrote:
>>>
>>> Is this an issue that vendor drivers are also vulnerable to? If it is
>>> a firmware issue, I would certainly think so.
>>
>> I also think so, at least if they are using the firmware version that
>> Bastian is using. His logs don't have that info in them, but I
>> certainly saw the problem on my BCM4312 using firmware 508.154 from
>> 2009.
>
> Another test this morning with heavy downloading (but tcp only)
> show slot usage auf max 204/256. we are using firmware
>
> "version 666.2 (2011-02-23 01:15:07)" which is OpenWrt's default
> for b43. see here the full logs, including minstrel output and dmesg:
>
> http://intercity-vpn.de/files/openwrt/b43test2.dmesg.txt
>
> if a slot needs ~2500 bytes, so 256 slot are only 640kb which seems
> ok to me. ofcourse it raises the memory consumption by 500kb, but now
> the router is useful 8-)

Thanks for the testing and the report. The skb associated with each slot is 
allocated at 2390 bytes, but I think each allocation is a minimum of one page. 
In any case, using extra memory is much better than having the device freeze 
without explanation. I do not think there is any newer firmware for the 4318 
than the version you are using.

I have reworked the patch that resets on overflow, and added the section for 
64-bit DMA. I still need to test that part, but I am sending two patches to you 
for testing on the WRT54G. The first renames a couple of register names to make 
32- and 64-bit naming to only differ in the number. The second is the reset code 
patch.

Larry


--------------060704060006080405010304
Content-Type: text/plain; charset=UTF-8;
 name="b43_rename_B43_DMA64_RXSTAT"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="b43_rename_B43_DMA64_RXSTAT"

Index: wireless-testing-new/drivers/net/wireless/b43/dma.c
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/b43/dma.c
+++ wireless-testing-new/drivers/net/wireless/b43/dma.c
@@ -476,7 +476,7 @@ static int b43_dmacontroller_rx_reset(st
 				break;
 			}
 		} else {
-			value &= B43_DMA32_RXSTATE;
+			value &= B43_DMA32_RXSTAT;
 			if (value == B43_DMA32_RXSTAT_DISABLED) {
 				i = -1;
 				break;
@@ -513,7 +513,7 @@ static int b43_dmacontroller_tx_reset(st
 			    value == B43_DMA64_TXSTAT_STOPPED)
 				break;
 		} else {
-			value &= B43_DMA32_TXSTATE;
+			value &= B43_DMA32_TXSTAT;
 			if (value == B43_DMA32_TXSTAT_DISABLED ||
 			    value == B43_DMA32_TXSTAT_IDLEWAIT ||
 			    value == B43_DMA32_TXSTAT_STOPPED)
@@ -534,7 +534,7 @@ static int b43_dmacontroller_tx_reset(st
 				break;
 			}
 		} else {
-			value &= B43_DMA32_TXSTATE;
+			value &= B43_DMA32_TXSTAT;
 			if (value == B43_DMA32_TXSTAT_DISABLED) {
 				i = -1;
 				break;
Index: wireless-testing-new/drivers/net/wireless/b43/dma.h
===================================================================
--- wireless-testing-new.orig/drivers/net/wireless/b43/dma.h
+++ wireless-testing-new/drivers/net/wireless/b43/dma.h
@@ -27,7 +27,7 @@
 #define B43_DMA32_TXINDEX				0x08
 #define B43_DMA32_TXSTATUS				0x0C
 #define		B43_DMA32_TXDPTR			0x00000FFF
-#define		B43_DMA32_TXSTATE			0x0000F000
+#define		B43_DMA32_TXSTAT			0x0000F000
 #define			B43_DMA32_TXSTAT_DISABLED	0x00000000
 #define			B43_DMA32_TXSTAT_ACTIVE	0x00001000
 #define			B43_DMA32_TXSTAT_IDLEWAIT	0x00002000
@@ -52,7 +52,7 @@
 #define B43_DMA32_RXINDEX				0x18
 #define B43_DMA32_RXSTATUS				0x1C
 #define		B43_DMA32_RXDPTR			0x00000FFF
-#define		B43_DMA32_RXSTATE			0x0000F000
+#define		B43_DMA32_RXSTAT			0x0000F000
 #define			B43_DMA32_RXSTAT_DISABLED	0x00000000
 #define			B43_DMA32_RXSTAT_ACTIVE	0x00001000
 #define			B43_DMA32_RXSTAT_IDLEWAIT	0x00002000

--------------060704060006080405010304
Content-Type: text/plain; charset=UTF-8;
 name="b43_workaround_RX_buffer_overflow"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="b43_workaround_RX_buffer_overflow"

    Index: drivers/net/wireless/b43/dma.c
    ===================================================================
    --- a/drivers/net/wireless/b43/dma.c
    +++ b/drivers/net/wireless/b43/dma.c
    @@ -1689,6 +1692,31 @@
             sync_descbuffer_for_device(ring, dmaaddr, ring->rx_buffersize);
     }
     
    +static int dma_rx_check_overflow(struct b43_dmaring *ring)
    +{
    +        u32 state;
    +        u32 rxctl;
    +
    +        if (ring->type != B43_DMA_32BIT)
    +                return 0;
    +
    +        state = b43_dma_read(ring, B43_DMA32_RXSTATUS) & B43_DMA32_RXSTATE;
    +        if (state != B43_DMA32_RXSTAT_IDLEWAIT)
    +                return 0;
    +
    +        rxctl = b43_dma_read(ring, B43_DMA32_RXCTL);
    +        b43_dmacontroller_rx_reset(ring->dev, ring->mmio_base, ring->type);
    +
    +        b43_dma_write(ring, B43_DMA32_RXCTL, rxctl);
    +        b43_dma_write(ring, B43_DMA32_RXINDEX, ring->nr_slots *
    +                      sizeof(struct b43_dmadesc32));
    +        ring->current_slot = 0;
    +
    +        printk("DMA RX reset due to overflow\n");
    +
    +        return 1;
    +}
    +
     void b43_dma_rx(struct b43_dmaring *ring)
     {
             const struct b43_dma_ops *ops = ring->ops;
    @@ -1700,6 +1728,18 @@
             B43_WARN_ON(!(current_slot >= 0 && current_slot < ring->nr_slots));
     
             slot = ring->current_slot;
    +
    +        /* XXX: BRCM4318(?) dirty workaround:
    +         *      it seems sometimes the RX ring overflows due to interrupt latencies; 
    +         *      i.e. skb allocations are slow on routers with high CPU load
    +         *      and tight memory constraints */
    +        if (slot == current_slot) {
    +                /* Try to reset the RX channel, will cost us few lost frames,
    +                 * but will recover from an eternal stall */
    +                if (dma_rx_check_overflow(ring))
    +                        return;         
    +        }
    +        
             for (; slot != current_slot; slot = next_slot(ring, slot)) {
                     dma_rx(ring, &slot);
                     update_max_used_slots(ring, ++used_slots);


Index: wireless-testing/drivers/net/wireless/b43/dma.c
===================================================================
--- wireless-testing.orig/drivers/net/wireless/b43/dma.c
+++ wireless-testing/drivers/net/wireless/b43/dma.c
@@ -1692,6 +1692,50 @@ drop_recycle_buffer:
 	sync_descbuffer_for_device(ring, dmaaddr, ring->rx_buffersize);
 }
 
+/* check for overflow of the RX descriptor ring. If found, reset the DMA
+ * controller and return true.
+ */
+static bool dma_rx_check_overflow(struct b43_dmaring *ring)
+{
+	if (ring->type == B43_DMA_64BIT) {
+		u64 state;
+		u64 rxctl;
+
+		state = b43_dma_read(ring, B43_DMA64_RXSTATUS) &
+			B43_DMA64_RXSTAT;
+		if (state != B43_DMA64_RXSTAT_IDLEWAIT)
+			return false;
+		rxctl = b43_dma_read(ring, B43_DMA64_RXCTL);
+		b43_dmacontroller_rx_reset(ring->dev, ring->mmio_base,
+					   ring->type);
+
+		b43_dma_write(ring, B43_DMA64_RXCTL, rxctl);
+		b43_dma_write(ring, B43_DMA64_RXINDEX, ring->nr_slots *
+			      sizeof(struct b43_dmadesc64));
+	} else {
+		u32 state;
+		u32 rxctl;
+
+		state = b43_dma_read(ring, B43_DMA32_RXSTATUS) &
+				     B43_DMA32_RXSTAT;
+		if (state != B43_DMA32_RXSTAT_IDLEWAIT)
+			return false;
+
+		rxctl = b43_dma_read(ring, B43_DMA32_RXCTL);
+		b43_dmacontroller_rx_reset(ring->dev, ring->mmio_base,
+					   ring->type);
+
+		b43_dma_write(ring, B43_DMA32_RXCTL, rxctl);
+		b43_dma_write(ring, B43_DMA32_RXINDEX, ring->nr_slots *
+			      sizeof(struct b43_dmadesc32));
+	}
+	ring->current_slot = 0;
+
+	b43err(ring->dev->wl, "DMA RX reset due to overflow\n");
+
+	return true;
+}
+
 void b43_dma_rx(struct b43_dmaring *ring)
 {
 	const struct b43_dma_ops *ops = ring->ops;
@@ -1703,7 +1747,21 @@ void b43_dma_rx(struct b43_dmaring *ring
 	B43_WARN_ON(!(current_slot >= 0 && current_slot < ring->nr_slots));
 
 	slot = ring->current_slot;
-	for (; slot != current_slot; slot = next_slot(ring, slot)) {
+
+	/* XXX: BRCM4318(?) dirty workaround:
+	 *	it seems sometimes the RX ring overflows due to interrupt
+	 *	latencies; particularly for systems with slow CPUs and tight
+	 *	memory constraints
+	 */
+	if (slot == current_slot) {
+		/* Try to reset the RX channel, will cost us few lost frames,
+		 * but will recover from an eternal stall
+		 */
+		if (dma_rx_check_overflow(ring))
+			return; /* exit on overflow and reset */
+	}
+
+        for (; slot != current_slot; slot = next_slot(ring, slot)) {
 		dma_rx(ring, &slot);
 		update_max_used_slots(ring, ++used_slots);
 	}

--------------060704060006080405010304--
