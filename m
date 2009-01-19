From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: error paths that need to free an skb should use kfree_skb()
Date: Mon, 19 Jan 2009 15:19:30 -0800
Message-ID: <1232407170-7746-1-git-send-email-inaky@linux.intel.com>
References: <200901191042.51813.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:46161 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752671AbZASXTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 18:19:31 -0500
In-Reply-To: <200901191042.51813.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin reported a bug in two error paths where skbs were wrongly
being freed using kfree(). He provided a fix where it was replaced to
kfree_skb(), as it should be.

However, in i2400mu_rx(), the error path was missing returning an
indication of the failure. Changed to reset rx_skb to NULL and return
it to the caller, i2400mu_rxd(). It will be treated as a transient
error and just ignore the packet.

Depending on the buffering conditions inside the device, the data
packet might be dropped or the device will signal the host again for
data-ready-to-read and the host will retry.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |    2 +-
 drivers/net/wimax/i2400m/usb-rx.c  |    9 ++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index d3d37fe..15d9f51 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -609,7 +609,7 @@ void i2400m_msg_to_dev_cancel_wait(struct i2400m *i2400m, int code)
 	spin_lock_irqsave(&i2400m->rx_lock, flags);
 	ack_skb = i2400m->ack_skb;
 	if (ack_skb && !IS_ERR(ack_skb))
-		kfree(ack_skb);
+		kfree_skb(ack_skb);
 	i2400m->ack_skb = ERR_PTR(code);
 	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 }
diff --git a/drivers/net/wimax/i2400m/usb-rx.c b/drivers/net/wimax/i2400m/usb-rx.c
index 074cc1f..b81a8b9 100644
--- a/drivers/net/wimax/i2400m/usb-rx.c
+++ b/drivers/net/wimax/i2400m/usb-rx.c
@@ -184,6 +184,8 @@ void i2400mu_rx_size_maybe_shrink(struct i2400mu *i2400mu)
  *   NOTE: this function might realloc the skb (if it is too small),
  *   so always update with the one returned.
  *   ERR_PTR() is < 0 on error.
+ *   Will return NULL if it cannot reallocate -- this can be
+ *   considered a transient retryable error. 
  */
 static
 struct sk_buff *i2400mu_rx(struct i2400mu *i2400mu, struct sk_buff *rx_skb)
@@ -243,8 +245,8 @@ retry:
 			if (printk_ratelimit())
 				dev_err(dev, "RX: Can't reallocate skb to %d; "
 					"RX dropped\n", rx_size);
-			kfree(rx_skb);
-			result = 0;
+			kfree_skb(rx_skb);
+			rx_skb = NULL;
 			goto out;	/* drop it...*/
 		}
 		kfree_skb(rx_skb);
@@ -344,7 +346,8 @@ int i2400mu_rxd(void *_i2400mu)
 		if (IS_ERR(rx_skb))
 			goto out;
 		atomic_dec(&i2400mu->rx_pending_count);
-		if (rx_skb->len == 0) {	/* some ignorable condition */
+		if (rx_skb == NULL || rx_skb->len == 0) {
+			/* some "ignorable" condition */
 			kfree_skb(rx_skb);
 			continue;
 		}
-- 
1.5.6.5

