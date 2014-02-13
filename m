From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH] usbnet: remove generic hard_header_len check
Date: Thu, 13 Feb 2014 01:03:56 +0100
Message-ID: <1392249836-27151-1-git-send-email-emilgoode@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <edumazet@google.com>,
	Ming Lei <ming.lei@canonical.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Liu Junliang <liujunliang_ljl@163.com>,
	Octavian Purdila <octavian.purdila@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes a generic hard_header_len check from the usbnet
module that is causing dropped packages under certain circumstances
for devices that send rx packets that cross urb boundaries.

One example is the AX88772B which occasionally send rx packets that
cross urb boundaries where the remaining partial packet is sent with
no hardware header. When the buffer with a partial packet is of less
number of octets than the value of hard_header_len the buffer is
discarded by the usbnet module.

With AX88772B this can be reproduced by using ping with a packet
size between 1965-1976.

The bug has been reported here:

https://bugzilla.kernel.org/show_bug.cgi?id=29082

This patch introduces the following changes:
- Removes the generic hard_header_len check in the rx_complete
  function in the usbnet module.
- Introduces a ETH_HLEN check for skbs that are not cloned from
  within a rx_fixup callback.
- For safety a hard_header_len check is added to each rx_fixup
  callback function that could be affected by this change.
  These extra checks could possibly be removed by someone
  who has the hardware to test.

The changes place full responsibility on the rx_fixup callback
functions that clone skbs to only pass valid skbs to the
usbnet_skb_return function.

Signed-off-by: Emil Goode <emilgoode@gmail.com>
Reported-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
---

An alternative solution is to add the ETH_HLEN check to
usbnet_skb_return() and add short skbs to the skb->done
list to be cleaned up in rx_process().

 drivers/net/usb/ax88179_178a.c |    4 ++++
 drivers/net/usb/gl620a.c       |    4 ++++
 drivers/net/usb/mcs7830.c      |    5 +++--
 drivers/net/usb/net1080.c      |    4 ++++
 drivers/net/usb/qmi_wwan.c     |    8 ++++----
 drivers/net/usb/rndis_host.c   |    4 ++++
 drivers/net/usb/smsc75xx.c     |    4 ++++
 drivers/net/usb/smsc95xx.c     |    4 ++++
 drivers/net/usb/sr9800.c       |    4 ++++
 drivers/net/usb/usbnet.c       |   25 ++++++++++---------------
 10 files changed, 45 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index d6f64da..955df81 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1118,6 +1118,10 @@ static int ax88179_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	u16 hdr_off;
 	u32 *pkt_hdr;
 
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	skb_trim(skb, skb->len - 4);
 	memcpy(&rx_hdr, skb_tail_pointer(skb), 4);
 	le32_to_cpus(&rx_hdr);
diff --git a/drivers/net/usb/gl620a.c b/drivers/net/usb/gl620a.c
index e4a8a93..1cc24e6 100644
--- a/drivers/net/usb/gl620a.c
+++ b/drivers/net/usb/gl620a.c
@@ -84,6 +84,10 @@ static int genelink_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	u32			size;
 	u32			count;
 
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	header = (struct gl_header *) skb->data;
 
 	// get the packet count of the received skb
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index a305a7b..82d844a 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -526,8 +526,9 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
 	u8 status;
 
-	if (skb->len == 0) {
-		dev_err(&dev->udev->dev, "unexpected empty rx frame\n");
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len) {
+		dev_err(&dev->udev->dev, "unexpected tiny rx frame\n");
 		return 0;
 	}
 
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 0a85d92..4cbdb13 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -364,6 +364,10 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	struct nc_trailer	*trailer;
 	u16			hdr_len, packet_len;
 
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	if (!(skb->len & 0x01)) {
 		netdev_dbg(dev->net, "rx framesize %d range %d..%d mtu %d\n",
 			   skb->len, dev->net->hard_header_len, dev->hard_mtu,
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index ff5c871..b2e2aee 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -80,10 +80,10 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
 	__be16 proto;
 
-	/* usbnet rx_complete guarantees that skb->len is at least
-	 * hard_header_len, so we can inspect the dest address without
-	 * checking skb->len
-	 */
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	switch (skb->data[0] & 0xf0) {
 	case 0x40:
 		proto = htons(ETH_P_IP);
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index a48bc0f..524a47a 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -492,6 +492,10 @@ EXPORT_SYMBOL_GPL(rndis_unbind);
  */
 int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	/* peripheral may have batched packets to us... */
 	while (likely(skb->len)) {
 		struct rndis_data_hdr	*hdr = (void *)skb->data;
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index f17b9e0..d9e7892 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -2106,6 +2106,10 @@ static void smsc75xx_rx_csum_offload(struct usbnet *dev, struct sk_buff *skb,
 
 static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	while (skb->len > 0) {
 		u32 rx_cmd_a, rx_cmd_b, align_count, size;
 		struct sk_buff *ax_skb;
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 8dd54a0..424db65e 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1723,6 +1723,10 @@ static void smsc95xx_rx_csum_offload(struct sk_buff *skb)
 
 static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	while (skb->len > 0) {
 		u32 header, align_count;
 		struct sk_buff *ax_skb;
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 4175eb9..575be80 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -63,6 +63,10 @@ static int sr_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
 	int offset = 0;
 
+	/* This check is no longer done by usbnet */
+	if (skb->len < dev->net->hard_header_len)
+		return 0;
+
 	while (offset + sizeof(u32) < skb->len) {
 		struct sk_buff *sr_skb;
 		u16 size;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4671da7..dd10d58 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -542,17 +542,19 @@ static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 	}
 	// else network stack removes extra byte if we forced a short packet
 
-	if (skb->len) {
-		/* all data was already cloned from skb inside the driver */
-		if (dev->driver_info->flags & FLAG_MULTI_PACKET)
-			dev_kfree_skb_any(skb);
-		else
-			usbnet_skb_return(dev, skb);
+	/* all data was already cloned from skb inside the driver */
+	if (dev->driver_info->flags & FLAG_MULTI_PACKET)
+		goto done;
+
+	if (skb->len < ETH_HLEN) {
+		dev->net->stats.rx_errors++;
+		dev->net->stats.rx_length_errors++;
+		netif_dbg(dev, rx_err, dev->net, "rx length %d\n", skb->len);
+	} else {
+		usbnet_skb_return(dev, skb);
 		return;
 	}
 
-	netif_dbg(dev, rx_err, dev->net, "drop\n");
-	dev->net->stats.rx_errors++;
 done:
 	skb_queue_tail(&dev->done, skb);
 }
@@ -574,13 +576,6 @@ static void rx_complete (struct urb *urb)
 	switch (urb_status) {
 	/* success */
 	case 0:
-		if (skb->len < dev->net->hard_header_len) {
-			state = rx_cleanup;
-			dev->net->stats.rx_errors++;
-			dev->net->stats.rx_length_errors++;
-			netif_dbg(dev, rx_err, dev->net,
-				  "rx length %d\n", skb->len);
-		}
 		break;
 
 	/* stalls need manual reset. this is rare ... except that
-- 
1.7.10.4
