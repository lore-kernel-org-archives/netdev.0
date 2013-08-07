From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH 2/2] net/usb: pegasus: allocate URB transfer_buffers as
 separate buffers
Date: Wed, 07 Aug 2013 16:33:31 +0300
Message-ID: <20130807133331.15270.39595.stgit@localhost6.localdomain6>
References: <20130807133326.15270.86891.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sypressi.dnainternet.net ([83.102.40.135]:41603 "EHLO
	sypressi.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933057Ab3HGNdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:33:38 -0400
In-Reply-To: <20130807133326.15270.86891.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

URB transfer_buffers must not be allocated as part of larger structure
because DMA coherence issues.

Patch changes pegasus to allocate intr_buff and tx_buff members of
'struct pegasus' as separate buffers.

Patch is only compile tested.

Cc: <stable@vger.kernel.org>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 drivers/net/usb/pegasus.c |   11 ++++++++++-
 drivers/net/usb/pegasus.h |    6 ++++--
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 3bce862..b734702 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -854,7 +854,7 @@ static int pegasus_open(struct net_device *net)
 
 	usb_fill_int_urb(pegasus->intr_urb, pegasus->usb,
 			 usb_rcvintpipe(pegasus->usb, 3),
-			 pegasus->intr_buff, sizeof(pegasus->intr_buff),
+			 pegasus->intr_buff, PEGASUS_INTR_BUFLEN,
 			 intr_callback, pegasus, pegasus->intr_interval);
 	if ((res = usb_submit_urb(pegasus->intr_urb, GFP_KERNEL))) {
 		if (res == -ENODEV)
@@ -1162,6 +1162,11 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus = netdev_priv(net);
 	pegasus->dev_index = dev_index;
 
+	pegasus->intr_buff = kzalloc(PEGASUS_INTR_BUFLEN, GFP_KERNEL);
+	pegasus->tx_buff = kzalloc(PEGASUS_MTU, GFP_KERNEL);
+	if (!pegasus->intr_buff || !pegasus->tx_buff)
+		goto out1;
+
 	res = alloc_urbs(pegasus);
 	if (res < 0) {
 		dev_err(&intf->dev, "can't allocate %s\n", "urbs");
@@ -1223,6 +1228,8 @@ out3:
 out2:
 	free_all_urbs(pegasus);
 out1:
+	kfree(pegasus->tx_buff);
+	kfree(pegasus->intr_buff);
 	free_netdev(net);
 out:
 	pegasus_dec_workqueue();
@@ -1248,6 +1255,8 @@ static void pegasus_disconnect(struct usb_interface *intf)
 		dev_kfree_skb(pegasus->rx_skb);
 		pegasus->rx_skb = NULL;
 	}
+	kfree(pegasus->tx_buff);
+	kfree(pegasus->intr_buff);
 	free_netdev(pegasus->net);
 	pegasus_dec_workqueue();
 }
diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
index d156462..6469aed 100644
--- a/drivers/net/usb/pegasus.h
+++ b/drivers/net/usb/pegasus.h
@@ -55,6 +55,8 @@
 #define	PEGASUS_REQ_SET_REGS	0xf1
 #define	PEGASUS_REQ_SET_REG	PEGASUS_REQ_SET_REGS
 
+#define PEGASUS_INTR_BUFLEN	8
+
 enum pegasus_registers {
 	EthCtrl0 = 0,
 	EthCtrl1 = 1,
@@ -96,8 +98,8 @@ typedef struct pegasus {
 	struct urb		*rx_urb, *tx_urb, *intr_urb;
 	struct sk_buff		*rx_skb;
 	int			chip;
-	unsigned char		intr_buff[8];
-	__u8			tx_buff[PEGASUS_MTU];
+	unsigned char		*intr_buff;
+	__u8			*tx_buff;
 	__u8			eth_regs[4];
 	__u8			phy;
 	__u8			gpio_res;
