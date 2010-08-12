From: Matthieu CASTET <matthieu.castet-ITF29qwbsa/QT0dZR+AlfA@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Thu, 12 Aug 2010 19:08:57 +0200
Message-ID: <4C642AA9.1060404@parrot.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>	<4C627479.4060400@parrot.com>	<AANLkTinU2JEkeYJHo4tA+kD9Pd_F3YcUTbK9w6igc7s8@mail.gmail.com>	<4C62C7B3.2030706@nvidia.com> <20100811203505.GA463@n2100.arm.linux.org.uk> <4C632217.9000608@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------000304040002090608090408"
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Gary King <GKing-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: "mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C632217.9000608-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--------------000304040002090608090408
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 8bit

Martin Fuzzey a écrit :
>> We don't want to add support for this to DMA bounce.  DMA bounce is already
>> a pain in the backside and causes its own set of problems - please let it
>> die a long slow but quite death.
>>
>> If you want to see the kind of pain dmabounce causes, look at this long
>> standing and as yet unsolved bug:
>>
>>   http://bugzilla.kernel.org/show_bug.cgi?id=7760
>>
>>   
> Well I don't know the dmabounce code but why is using it likely to cause
> OOM problems (at least why more so than copying the buffer in the HCD or
> the usb core). In both cases there will be two copies of the buffer in
> memory which could I agree be a problem in memory constrained systems.
> But if we _do_ want to accept unaligned buffers from usb drivers I can't
> see  a way round that.
> 
memmove is our friend :
the buffer allocated in usbnet got an offset.
All you have to do it remove this offset and memmove the data. That what 
I did [1], and why it is better to do it in usb driver.


Matthieu




[1] http://article.gmane.org/gmane.linux.usb.general/28700

--------------000304040002090608090408
Content-Type: text/x-diff; name="gadget-align.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="gadget-align.diff"

diff --git a/drivers/usb/gadget/gadget_chips.h b/drivers/usb/gadget/gadget_chips.h
index 1edbc12..ed3ee67 100644
--- a/drivers/usb/gadget/gadget_chips.h
+++ b/drivers/usb/gadget/gadget_chips.h
@@ -214,4 +214,14 @@ static inline bool gadget_supports_altsettings(struct usb_gadget *gadget)
 	return true;
 }
 
+/**
+ * gadget_dma32 - return true if we want buffer aligned on 32 bits (for dma)
+ * @gadget: the gadget in question
+ */
+static inline bool gadget_dma32(struct usb_gadget *gadget)
+{
+	if (gadget_is_musbhdrc(gadget))
+		return true;
+	return false;
+}
 #endif /* __GADGET_CHIPS_H */
diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 84ca195..697af90 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -249,7 +249,12 @@ rx_submit(struct eth_dev *dev, struct usb_request *req, gfp_t gfp_flags)
 	 * but on at least one, checksumming fails otherwise.  Note:
 	 * RNDIS headers involve variable numbers of LE32 values.
 	 */
-	skb_reserve(skb, NET_IP_ALIGN);
+	/*
+	 * RX: Do not move data by IP_ALIGN:
+	 * if your DMA controller cannot handle it
+	 */
+	if (!gadget_dma32(dev->gadget))
+		skb_reserve(skb, NET_IP_ALIGN);
 
 	req->buf = skb->data;
 	req->length = size;
@@ -282,6 +287,12 @@ static void rx_complete(struct usb_ep *ep, struct usb_request *req)
 	/* normal completion */
 	case 0:
 		skb_put(skb, req->actual);
+		if (gadget_dma32(dev->gadget) && NET_IP_ALIGN) {
+			u8 *data = skb->data;
+			size_t len = skb_headlen(skb);
+			skb_reserve(skb, NET_IP_ALIGN);
+			memmove(skb->data, data, len);
+		}
 
 		if (dev->unwrap) {
 			unsigned long	flags;
@@ -573,6 +584,24 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 
 		length = skb->len;
 	}
+
+	/*
+	 * Align data to 32bit if the dma controller requires it
+	 */
+	if (gadget_dma32(dev->gadget)) {
+		unsigned long align = (unsigned long)skb->data & 3;
+		if (WARN_ON(skb_headroom(skb) < align)) {
+			dev_kfree_skb_any(skb);
+			goto drop;
+		} else if (align) {
+			u8 *data = skb->data;
+			size_t len = skb_headlen(skb);
+			skb->data -= align;
+			memmove(skb->data, data, len);
+			skb_set_tail_pointer(skb, len);
+		}
+	}
+
 	req->buf = skb->data;
 	req->context = skb;
 	req->complete = tx_complete;

--------------000304040002090608090408--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
