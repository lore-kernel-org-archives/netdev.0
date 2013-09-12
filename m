From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net/irda/mcs7780: fix memory leaks in mcs_net_open()
Date: Fri, 13 Sep 2013 00:51:20 +0400
Message-ID: <1379019080-25354-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If rx_urb allocation fails in mcs_setup_urbs(), tx_urb leaks.
If mcs_receive_start() fails in mcs_net_open(), the both urbs are not deallocated.

The patch fixes the issues and by the way fixes label indentation.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/irda/mcs7780.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index f07c340..3f138ca 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -191,8 +191,8 @@ static inline int mcs_setup_transceiver_vishay(struct mcs_cb *mcs)
 		goto error;
 
 	ret = 0;
-	error:
-		return ret;
+error:
+	return ret;
 }
 
 /* Setup a communication between mcs7780 and agilent chip. */
@@ -501,8 +501,11 @@ static inline int mcs_setup_urbs(struct mcs_cb *mcs)
 		return 0;
 
 	mcs->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!mcs->rx_urb)
+	if (!mcs->rx_urb) {
+		usb_free_urb(mcs->tx_urb);
+		mcs->tx_urb = NULL;
 		return 0;
+	}
 
 	return 1;
 }
@@ -643,9 +646,9 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 	ret = mcs_set_reg(mcs, MCS_MODE_REG, rval);
 
 	mcs->speed = mcs->new_speed;
-	error:
-		mcs->new_speed = 0;
-		return ret;
+error:
+	mcs->new_speed = 0;
+	return ret;
 }
 
 /* Ioctl calls not supported at this time.  Can be an area of future work. */
@@ -738,17 +741,20 @@ static int mcs_net_open(struct net_device *netdev)
 
 	ret = mcs_receive_start(mcs);
 	if (ret)
-		goto error3;
+		goto error4;
 
 	netif_start_queue(netdev);
 	return 0;
 
-	error3:
-		irlap_close(mcs->irlap);
-	error2:
-		kfree_skb(mcs->rx_buff.skb);
-	error1:
-		return ret;
+error4:
+	usb_free_urb(mcs->rx_urb);
+	usb_free_urb(mcs->tx_urb);
+error3:
+	irlap_close(mcs->irlap);
+error2:
+	kfree_skb(mcs->rx_buff.skb);
+error1:
+	return ret;
 }
 
 /* Receive callback function.  */
@@ -946,11 +952,11 @@ static int mcs_probe(struct usb_interface *intf,
 	usb_set_intfdata(intf, mcs);
 	return 0;
 
-	error2:
-		free_netdev(ndev);
+error2:
+	free_netdev(ndev);
 
-	error1:
-		return ret;
+error1:
+	return ret;
 }
 
 /* The current device is removed, the USB layer tells us to shut down. */
-- 
1.8.1.2
