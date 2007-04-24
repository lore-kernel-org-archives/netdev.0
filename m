From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Tue, 24 Apr 2007 10:20:06 -0400
Message-ID: <1177424406.13684.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161771AbXDXOUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 10:20:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Broken by 4a1728a28a193aa388900714bbb1f375e08a6d8e which switched the
return semantics of read_mii_word() but didn't fix usage of
read_mii_word() to conform to the new semantics.

Setting carrier to off based on the NO_CARRIER flag is also incorrect as
that flag only triggers on TX failure and therefore isn't correct when
no frames are being transmitted.  Since there is already a 2*HZ MII
carrier check going on, defer to that.

Add a TRUST_LINK_STATUS feature flag for adapters where the LINK_STATUS
flag is actually correct, and use that rather than the NO_CARRIER flag.

Signed-off-by: Dan Williams <dcbw@redhat.com>

diff --git a/drivers/usb/net/pegasus.c b/drivers/usb/net/pegasus.c
index d48c024..6d12961 100644
--- a/drivers/usb/net/pegasus.c
+++ b/drivers/usb/net/pegasus.c
@@ -316,6 +316,7 @@ static int update_eth_regs_async(pegasus_t * pegasus)
 	return ret;
 }
 
+/* Returns 0 on success, error on failure */
 static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
 {
 	int i;
@@ -847,10 +848,16 @@ static void intr_callback(struct urb *urb)
 		 * d[0].NO_CARRIER kicks in only with failed TX.
 		 * ... so monitoring with MII may be safest.
 		 */
-		if (d[0] & NO_CARRIER)
-			netif_carrier_off(net);	
-		else
-			netif_carrier_on(net);
+		if (pegasus->features & TRUST_LINK_STATUS) {
+			if (d[5] & LINK_STATUS)
+				netif_carrier_on(net);
+			else
+				netif_carrier_off(net);
+		} else {
+			/* Never set carrier _on_ based on ! NO_CARRIER */
+			if (d[0] & NO_CARRIER)
+				netif_carrier_off(net);	
+		}
 
 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
@@ -950,7 +957,7 @@ static void set_carrier(struct net_device *net)
 	pegasus_t *pegasus = netdev_priv(net);
 	u16 tmp;
 
-	if (!read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
+	if (read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
 		return;
 
 	if (tmp & BMSR_LSTATUS)
diff --git a/drivers/usb/net/pegasus.h b/drivers/usb/net/pegasus.h
index c746782..c7aadb4 100644
--- a/drivers/usb/net/pegasus.h
+++ b/drivers/usb/net/pegasus.h
@@ -11,6 +11,7 @@
 
 #define	PEGASUS_II		0x80000000
 #define	HAS_HOME_PNA		0x40000000
+#define	TRUST_LINK_STATUS	0x20000000
 
 #define	PEGASUS_MTU		1536
 #define	RX_SKBS			4
@@ -203,7 +204,7 @@ PEGASUS_DEV( "AEI USB Fast Ethernet Adapter", VENDOR_AEILAB, 0x1701,
 PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
 		DEFAULT_GPIO_RESET | PEGASUS_II )
 PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
-		DEFAULT_GPIO_RESET | PEGASUS_II )
+		DEFAULT_GPIO_RESET | PEGASUS_II | TRUST_LINK_STATUS )
 PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
 		DEFAULT_GPIO_RESET )
 PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,



