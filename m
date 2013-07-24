From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] usbnet: do not pretend to support SG/TSO
Date: Tue, 23 Jul 2013 17:15:54 -0700
Message-ID: <1374624954.3449.61.camel@edumazet-glaptop>
References: <1374518841.4990.26.camel@edumazet-glaptop>
	 <1374522471.1635.48.camel@bwh-desktop.uk.level5networks.com>
	 <1374559827.4990.143.camel@edumazet-glaptop>
	 <20130723.164656.1794159338719943519.davem@davemloft.net>
	 <1374623813.3449.52.camel@edumazet-glaptop>
	 <1374624310.3449.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, oliver@neukum.org, grundler@google.com,
	freddy@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33575 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013Ab3GXAP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 20:15:58 -0400
In-Reply-To: <1374624310.3449.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

usbnet doesn't support yet SG, so drivers should not advertise SG or TSO
capabilities, as they allow TCP stack to build large TSO packets that 
need to be linearized and might use order-5 pages.

This adds an extra copy overhead and possible allocation failures.

Current code ignore skb_linearize() return code so crashes are even
possible.

Best is to not pretend SG/TSO is supported, and add this again when/if
usbnet really supports SG for devices who could get a performance gain.

Based on a prior patch from Freddy Xin <freddy@asix.com.tw>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/usb/ax88179_178a.c |    9 ++++-----
 drivers/net/usb/smsc75xx.c     |   12 +++---------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 1e3c302..2bc87e3 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1029,10 +1029,10 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->mii.supports_gmii = 1;
 
 	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			      NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
+			      NETIF_F_RXCSUM;
 
 	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				 NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
+				 NETIF_F_RXCSUM;
 
 	/* Enable checksum offload */
 	*tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
@@ -1173,7 +1173,6 @@ ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	if (((skb->len + 8) % frame_size) == 0)
 		tx_hdr2 |= 0x80008000;	/* Enable padding */
 
-	skb_linearize(skb);
 	headroom = skb_headroom(skb);
 	tailroom = skb_tailroom(skb);
 
@@ -1317,10 +1316,10 @@ static int ax88179_reset(struct usbnet *dev)
 			  1, 1, tmp);
 
 	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			      NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
+			      NETIF_F_RXCSUM;
 
 	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				 NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
+				 NETIF_F_RXCSUM;
 
 	/* Enable checksum offload */
 	*tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 7540974..66ebbac 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -45,7 +45,6 @@
 #define EEPROM_MAC_OFFSET		(0x01)
 #define DEFAULT_TX_CSUM_ENABLE		(true)
 #define DEFAULT_RX_CSUM_ENABLE		(true)
-#define DEFAULT_TSO_ENABLE		(true)
 #define SMSC75XX_INTERNAL_PHY_ID	(1)
 #define SMSC75XX_TX_OVERHEAD		(8)
 #define MAX_RX_FIFO_SIZE		(20 * 1024)
@@ -1410,17 +1409,14 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	INIT_WORK(&pdata->set_multicast, smsc75xx_deferred_multicast_write);
 
-	if (DEFAULT_TX_CSUM_ENABLE) {
+	if (DEFAULT_TX_CSUM_ENABLE)
 		dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-		if (DEFAULT_TSO_ENABLE)
-			dev->net->features |= NETIF_F_SG |
-				NETIF_F_TSO | NETIF_F_TSO6;
-	}
+
 	if (DEFAULT_RX_CSUM_ENABLE)
 		dev->net->features |= NETIF_F_RXCSUM;
 
 	dev->net->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_RXCSUM;
+				NETIF_F_RXCSUM;
 
 	ret = smsc75xx_wait_ready(dev, 0);
 	if (ret < 0) {
@@ -2200,8 +2196,6 @@ static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
 {
 	u32 tx_cmd_a, tx_cmd_b;
 
-	skb_linearize(skb);
-
 	if (skb_headroom(skb) < SMSC75XX_TX_OVERHEAD) {
 		struct sk_buff *skb2 =
 			skb_copy_expand(skb, SMSC75XX_TX_OVERHEAD, 0, flags);
