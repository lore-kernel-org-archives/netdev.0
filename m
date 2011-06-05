From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: ETH over USB: NFS state (seeking ARM platform for NFS-based builds)
Date: Sun, 5 Jun 2011 13:13:28 +0800
Message-ID: <BANLkTin3KKoa4A3xie7J0QaBcvr-NYPrbQ@mail.gmail.com>
References: <4DEA5D78.5030402@centrum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	linux-usb <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Karel Gardas <karel.gardas@centrum.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DEA5D78.5030402@centrum.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2011/6/5 Karel Gardas <karel.gardas@centrum.cz>:
> Hello,
>
> while searching for ARMv7/NEON platform for my own hacking I've found this
> interesting issue:
>
> [ 2945.114135] cc1: page allocation failure. order:3, mode:0x4020

Maybe the patch below can fix the issue, please try it:

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9ab439d..f16e448 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -324,12 +324,20 @@ static int rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 	unsigned long		lockflags;
 	size_t			size = dev->rx_urb_size;

-	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
-		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
+	if (atomic_read(&dev->rx_skb_on_fly) > MAX_RX_SKB_ON_FLY &&
+		flags == GFP_ATOMIC) {
+		netif_dbg(dev, rx_err, dev->net, "too many rx skbs on the fly\n");
+fail_rx_memory:
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);
 		return -ENOMEM;
 	}
+
+	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
+		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
+		goto fail_rx_memory;
+	}
+	atomic_inc(&dev->rx_skb_on_fly);
 	skb_reserve (skb, NET_IP_ALIGN);

 	entry = (struct skb_data *) skb->cb;
@@ -375,6 +383,7 @@ static int rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 	}
 	spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
 	if (retval) {
+		atomic_dec(&dev->rx_skb_on_fly);
 		dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
 	}
@@ -1177,8 +1186,9 @@ static void usbnet_bh (unsigned long param)
 			entry->state = rx_cleanup;
 			rx_process (dev, skb);
 			continue;
-		case tx_done:
 		case rx_cleanup:
+			atomic_dec(&dev->rx_skb_on_fly);
+		case tx_done:
 			usb_free_urb (entry->urb);
 			dev_kfree_skb (skb);
 			continue;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 605b0aa..1dace0d 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -33,6 +33,8 @@ struct usbnet {
 	wait_queue_head_t	*wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
+	atomic_t		rx_skb_on_fly;
+#		define MAX_RX_SKB_ON_FLY	2048

 	/* i/o info: pipes etc */
 	unsigned		in, out;


thanks,
-- 
Ming Lei
