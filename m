From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 12/15] wireless/orinoco: Use netif routines
	rather than keeping link state ourselves
Date: Tue, 26 Oct 2004 15:20:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098818429.3663.84.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Use netif routines rather than keeping link state ourselves

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco.c.12-netif	2004-10-26 13:09:22.313994688 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 13:20:51.649199808 -0400
@@ -851,7 +851,7 @@
 		return 1;
 	}
 
-	if (! priv->connected) {
+	if (! netif_carrier_ok(dev)) {
 		/* Oops, the firmware hasn't established a connection,
                    silently drop the packet (this seems to be the
                    safest approach). */
@@ -966,8 +966,6 @@
 			printk(KERN_WARNING "%s: Allocate event on unexpected fid (%04X)\n",
 			       dev->name, fid);
 		return;
-	} else {
-		netif_wake_queue(dev);
 	}
 
 	hermes_write_regn(hw, ALLOCFID, DUMMY_FID);
@@ -980,6 +978,8 @@
 
 	stats->tx_packets++;
 
+	netif_wake_queue(dev);
+
 	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
 }
 
@@ -1006,6 +1006,8 @@
 	
 	stats->tx_errors++;
 
+	netif_wake_queue(dev);
+
 	hermes_write_regn(hw, TXCOMPLFID, DUMMY_FID);
 }
 
@@ -1338,6 +1340,7 @@
 	case HERMES_INQ_LINKSTATUS: {
 		struct hermes_linkstatus linkstatus;
 		u16 newstatus;
+		int connected;
 
 		if (len != sizeof(linkstatus)) {
 			printk(KERN_WARNING "%s: Unexpected size for linkstatus frame (%d bytes)\n",
@@ -1345,24 +1348,26 @@
 			break;
 		}
 
-		hermes_read_words(hw, HERMES_DATA1, (void *) &linkstatus,
-				  len / 2);
+		err = hermes_bap_pread(hw, IRQ_BAP, &linkstatus, len,
+				       infofid, sizeof(info));
+		if (err)
+			break;
+
 		newstatus = le16_to_cpu(linkstatus.linkstatus);
 
-		if ( (newstatus == HERMES_LINKSTATUS_CONNECTED)
+		connected = (newstatus == HERMES_LINKSTATUS_CONNECTED)
 		     || (newstatus == HERMES_LINKSTATUS_AP_CHANGE)
-		     || (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE) )
-			priv->connected = 1;
-		else if ( (newstatus == HERMES_LINKSTATUS_NOT_CONNECTED)
-			  || (newstatus == HERMES_LINKSTATUS_DISCONNECTED)
-			  || (newstatus == HERMES_LINKSTATUS_AP_OUT_OF_RANGE)
-			  || (newstatus == HERMES_LINKSTATUS_ASSOC_FAILED) )
-			priv->connected = 0;
+		     || (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE);
 
-		if (newstatus != priv->last_linkstatus)
-			print_linkstatus(dev, newstatus);
+		if (connected)
+			netif_carrier_on(dev);
+		else if (!ignore_disconnect)
+			netif_carrier_off(dev);
 
-		priv->last_linkstatus = newstatus;
+		if (newstatus != priv->last_linkstatus) {
+			priv->last_linkstatus = newstatus;
+			print_linkstatus(dev, newstatus);
+		}
 	}
 	break;
 	default:
@@ -1389,6 +1394,8 @@
 	struct hermes *hw = &priv->hw;
 	int err;
 
+	netif_carrier_off(dev); /* just to make sure */
+
 	err = __orinoco_program_rids(dev);
 	if (err) {
 		printk(KERN_ERR "%s: Error %d configuring card\n",
@@ -1435,8 +1442,8 @@
 	}
 	
 	/* firmware will have to reassociate */
+	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
-	priv->connected = 0;
 
 	return 0;
 }
@@ -1957,7 +1964,7 @@
 
 	priv->hw_unavailable++;
 	priv->last_linkstatus = 0xffff; /* firmware will have to reassociate */
-	priv->connected = 0;
+	netif_carrier_off(dev);
 
 	orinoco_unlock(priv, &flags);
 
@@ -2493,8 +2500,8 @@
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
 
+	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
-	priv->connected = 0;
 
 	return dev;
 
--- a/drivers/net/wireless/orinoco.h.12-netif	2004-10-26 13:09:29.785858792 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 13:09:38.486536088 -0400
@@ -54,7 +54,6 @@
 	/* driver state */
 	int open;
 	u16 last_linkstatus;
-	int connected;
 
 	/* Net device stuff */
 	struct net_device *ndev;
