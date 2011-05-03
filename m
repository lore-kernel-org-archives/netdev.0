From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] ipheth: Properly distinguish length and
 alignment in URBs and skbs
Date: Tue, 03 May 2011 18:49:25 +0100
Message-ID: <1304444965.2873.11.camel@bwh-desktop>
References: <1304264799.2833.82.camel@localhost>
	 <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
	 <1304370274.2833.192.camel@localhost>
	 <20110503165751.GA6566@bart.evergreen.loc>
	 <710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "L. Alberto" =?ISO-8859-1?Q?Gim=E9nez?= <agimenez@sysvalve.es>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dgiagio@gmail.com" <dgiagio@gmail.com>,
	"dborca@yahoo.com" <dborca@yahoo.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"pmcenery@gmail.com" <pmcenery@gmail.com>,
	"open list:USB SUBSYSTEM" <linux-usb@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: David Hill <david.hill@ubisoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The USB protocol this driver implements appears to require 2 bytes of
padding in front of each received packet.  This used to be equal to
the value of NET_IP_ALIGN on x86, so the driver abused that constant
and mostly worked, but this is no longer the case.  The driver also
mixed up the URB and packet lengths, resulting in 2 bytes of junk at
the end of the skb.

Introduce a private constant for the 2 bytes of padding; fix this
confusion and check for the under-length case.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only, as I'm not cool enough for an iPhone either.
This is applicable to net-next-2.6 or v2.6.38.

Ben.

 drivers/net/usb/ipheth.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 7d42f9a..81126ff 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -65,6 +65,7 @@
 #define IPHETH_USBINTF_PROTO    1
 
 #define IPHETH_BUF_SIZE         1516
+#define IPHETH_IP_ALIGN		2	/* padding at front of URB */
 #define IPHETH_TX_TIMEOUT       (5 * HZ)
 
 #define IPHETH_INTFNUM          2
@@ -202,18 +203,21 @@ static void ipheth_rcvbulk_callback(struct urb *urb)
 		return;
 	}
 
-	len = urb->actual_length;
-	buf = urb->transfer_buffer;
+	if (urb->actual_length <= IPHETH_IP_ALIGN) {
+		dev->net->stats.rx_length_errors++;
+		return;
+	}
+	len = urb->actual_length - IPHETH_IP_ALIGN;
+	buf = urb->transfer_buffer + IPHETH_IP_ALIGN;
 
-	skb = dev_alloc_skb(NET_IP_ALIGN + len);
+	skb = dev_alloc_skb(len);
 	if (!skb) {
 		err("%s: dev_alloc_skb: -ENOMEM", __func__);
 		dev->net->stats.rx_dropped++;
 		return;
 	}
 
-	skb_reserve(skb, NET_IP_ALIGN);
-	memcpy(skb_put(skb, len), buf + NET_IP_ALIGN, len - NET_IP_ALIGN);
+	memcpy(skb_put(skb, len), buf, len);
 	skb->dev = dev->net;
 	skb->protocol = eth_type_trans(skb, dev->net);
 
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
