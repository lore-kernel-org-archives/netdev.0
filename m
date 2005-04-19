From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth Update error handling
Date: Tue, 19 Apr 2005 21:17:09 +0200
Message-ID: <42655935.9050703@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010900090107000400000007"
Cc: AAbdulla@nvidia.com, Netdev <netdev@oss.sgi.com>,
        Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2005@gmx.net>,
        adq@lidskialf.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010900090107000400000007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

Ayaz wrote an update to the error handling for forcedeth (which I 
modified heavily, thus all bugs are mine):
The ERROR4 bit is not a fatal error, it just indicates a mismatch 
between the actual packet len and the len according to the 802.3 header. 
The patch adds proper handling.
The patch also removes the code that drops all packets with RX_ERROR & 
(!RX_FRAMINGERR): ERROR4 errors are also not fatal.

Could you add it to your tree and forward it upstream?

--
    Manfred



--------------010900090107000400000007
Content-Type: text/plain;
 name="patch-forced-ERROR4"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forced-ERROR4"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 6
//  SUBLEVEL = 11
//  EXTRAVERSION = .6-bk4
--- 2.6/drivers/net/forcedeth.c	2005-03-02 08:37:45.000000000 +0100
+++ build-2.6/drivers/net/forcedeth.c	2005-04-16 13:38:21.000000000 +0200
@@ -81,6 +81,7 @@
  *			   cause DMA to kfree'd memory.
  *	0.31: 14 Nov 2004: ethtool support for getting/setting link
  *	                   capabilities.
+ *	0.32: 16 Apr 2005: RX_ERROR4 handling added.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -92,7 +93,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.31"
+#define FORCEDETH_VERSION		"0.32"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -109,6 +110,7 @@
 #include <linux/mii.h>
 #include <linux/random.h>
 #include <linux/init.h>
+#include <linux/if_vlan.h>
 
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -1013,6 +1015,59 @@ static void nv_tx_timeout(struct net_dev
 	spin_unlock_irq(&np->lock);
 }
 
+/*
+ * Called when the nic notices a mismatch between the actual data len on the
+ * wire and the len indicated in the 802 header
+ */
+static int nv_getlen(struct net_device *dev, void *packet, int datalen)
+{
+	int hdrlen;	/* length of the 802 header */
+	int protolen;	/* length as stored in the proto field */
+
+	/* 1) calculate len according to header */
+	if ( ((struct vlan_ethhdr *)packet)->h_vlan_proto == __constant_htons(ETH_P_8021Q)) {
+		protolen = ntohs( ((struct vlan_ethhdr *)packet)->h_vlan_encapsulated_proto );
+		hdrlen = VLAN_HLEN;
+	} else {
+		protolen = ntohs( ((struct ethhdr *)packet)->h_proto);
+		hdrlen = ETH_HLEN;
+	}
+	dprintk(KERN_DEBUG "%s: nv_getlen: datalen %d, protolen %d, hdrlen %d\n",
+				dev->name, datalen, protolen, hdrlen);
+	if (protolen > ETH_DATA_LEN)
+		return datalen; /* Value in proto field not a len, no checks possible */
+
+	protolen += hdrlen;
+	/* consistency checks: */
+	if (datalen > ETH_ZLEN) {
+		if (datalen >= protolen) {
+			/* more data on wire than in 802 header, trim of
+			 * additional data.
+			 */
+			dprintk(KERN_DEBUG "%s: nv_getlen: accepting %d bytes.\n",
+					dev->name, protolen);
+			return protolen;
+		} else {
+			/* less data on wire than mentioned in header.
+			 * Discard the packet.
+			 */
+			dprintk(KERN_DEBUG "%s: nv_getlen: discarding long packet.\n",
+					dev->name);
+			return -1;
+		}
+	} else {
+		/* short packet. Accept only if 802 values are also short */
+		if (protolen > ETH_ZLEN) {
+			dprintk(KERN_DEBUG "%s: nv_getlen: discarding short packet.\n",
+					dev->name);
+			return -1;
+		}
+		dprintk(KERN_DEBUG "%s: nv_getlen: accepting %d bytes.\n",
+				dev->name, datalen);
+		return datalen;
+	}
+}
+
 static void nv_rx_process(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
@@ -1064,7 +1119,7 @@ static void nv_rx_process(struct net_dev
 				np->stats.rx_errors++;
 				goto next_pkt;
 			}
-			if (Flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3|NV_RX_ERROR4)) {
+			if (Flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
 				np->stats.rx_errors++;
 				goto next_pkt;
 			}
@@ -1078,22 +1133,24 @@ static void nv_rx_process(struct net_dev
 				np->stats.rx_errors++;
 				goto next_pkt;
 			}
-			if (Flags & NV_RX_ERROR) {
-				/* framing errors are soft errors, the rest is fatal. */
-				if (Flags & NV_RX_FRAMINGERR) {
-					if (Flags & NV_RX_SUBSTRACT1) {
-						len--;
-					}
-				} else {
+			if (Flags & NV_RX_ERROR4) {
+				len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
+				if (len < 0) {
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
 			}
+			/* framing errors are soft errors. */
+			if (Flags & NV_RX_FRAMINGERR) {
+				if (Flags & NV_RX_SUBSTRACT1) {
+					len--;
+				}
+			}
 		} else {
 			if (!(Flags & NV_RX2_DESCRIPTORVALID))
 				goto next_pkt;
 
-			if (Flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3|NV_RX2_ERROR4)) {
+			if (Flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
 				np->stats.rx_errors++;
 				goto next_pkt;
 			}
@@ -1107,17 +1164,19 @@ static void nv_rx_process(struct net_dev
 				np->stats.rx_errors++;
 				goto next_pkt;
 			}
-			if (Flags & NV_RX2_ERROR) {
-				/* framing errors are soft errors, the rest is fatal. */
-				if (Flags & NV_RX2_FRAMINGERR) {
-					if (Flags & NV_RX2_SUBSTRACT1) {
-						len--;
-					}
-				} else {
+			if (Flags & NV_RX2_ERROR4) {
+				len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
+				if (len < 0) {
 					np->stats.rx_errors++;
 					goto next_pkt;
 				}
 			}
+			/* framing errors are soft errors */
+			if (Flags & NV_RX2_FRAMINGERR) {
+				if (Flags & NV_RX2_SUBSTRACT1) {
+					len--;
+				}
+			}
 			Flags &= NV_RX2_CHECKSUMMASK;
 			if (Flags == NV_RX2_CHECKSUMOK1 ||
 					Flags == NV_RX2_CHECKSUMOK2 ||

--------------010900090107000400000007--
