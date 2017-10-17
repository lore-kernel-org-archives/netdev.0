From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 07/58] net/usb/usbnet: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:51 -0700
Message-ID: <1508200182-104605-8-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Oliver Neukum <oneukum@suse.com>, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Since the callback is called from
both a timer and a tasklet, adjust the tasklet to pass the timer address
too. When tasklets have their .data field removed, this can be refactored
to call a central function after resolving the correct container_of() for a
separate callback function for timer and tasklet.

Cc: Oliver Neukum <oneukum@suse.com>
Cc: netdev@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/usb/usbnet.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 6510e5cc1817..80348b6a8646 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1509,9 +1509,9 @@ static int rx_alloc_submit(struct usbnet *dev, gfp_t flags)
 
 // tasklet (work deferred from completions, in_irq) or timer
 
-static void usbnet_bh (unsigned long param)
+static void usbnet_bh (struct timer_list *t)
 {
-	struct usbnet		*dev = (struct usbnet *) param;
+	struct usbnet		*dev = from_timer(dev, t, delay);
 	struct sk_buff		*skb;
 	struct skb_data		*entry;
 
@@ -1694,13 +1694,11 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	skb_queue_head_init (&dev->txq);
 	skb_queue_head_init (&dev->done);
 	skb_queue_head_init(&dev->rxq_pause);
-	dev->bh.func = usbnet_bh;
-	dev->bh.data = (unsigned long) dev;
+	dev->bh.func = (void (*)(unsigned long))usbnet_bh;
+	dev->bh.data = (unsigned long)&dev->delay;
 	INIT_WORK (&dev->kevent, usbnet_deferred_kevent);
 	init_usb_anchor(&dev->deferred);
-	dev->delay.function = usbnet_bh;
-	dev->delay.data = (unsigned long) dev;
-	init_timer (&dev->delay);
+	timer_setup(&dev->delay, usbnet_bh, 0);
 	mutex_init (&dev->phy_mutex);
 	mutex_init(&dev->interrupt_mutex);
 	dev->interrupt_count = 0;
-- 
2.7.4
