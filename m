From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] p54: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 20:45:35 +0100
Message-ID: <200612152045.36135.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	prism54-private@prism54.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49904
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbWLOTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:45:57 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes compilation for the d80211 hwmode API change.

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: jbenc-dscape/drivers/net/wireless/d80211/p54/prism54.h
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/p54/prism54.h	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/p54/prism54.h	2006-12-15 18:52:50.000000000 +0100
@@ -64,7 +64,7 @@ struct p54_common {
 	/* FIXME: this channels/modes/rates stuff sucks */
 	struct ieee80211_channel channels[14];
 	struct ieee80211_rate rates[12];
-	struct ieee80211_hw_modes modes[2];
+	struct ieee80211_hw_mode modes[2];
 };
 
 int p54_rx(struct ieee80211_hw *dev, struct sk_buff *skb);
Index: jbenc-dscape/drivers/net/wireless/d80211/p54/prism54common.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/p54/prism54common.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/p54/prism54common.c	2006-12-15 18:53:42.000000000 +0100
@@ -742,9 +742,6 @@ struct ieee80211_hw *p54_init_common(siz
 	dev->channel_change_time = 1000;	/* TODO: find actual value */
 	dev->maxssi = 100; // just to avoid dividing by zero
 
-	dev->num_modes = 2;
-	dev->modes = priv->modes;
-
 	dev->queues = 1;
 	dev->extra_tx_headroom = sizeof(struct p54_control_hdr) + 4 +
 				 sizeof(struct p54_tx_control_allocdata);
Index: jbenc-dscape/drivers/net/wireless/d80211/p54/prism54pci.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/p54/prism54pci.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/p54/prism54pci.c	2006-12-15 18:59:33.000000000 +0100
@@ -505,7 +505,7 @@ static int __devinit p54p_probe(struct p
 	struct p54p_priv *priv;
 	struct ieee80211_hw *dev;
 	unsigned long mem_addr, mem_len;
-	int err;
+	int i, err;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -596,12 +596,23 @@ static int __devinit p54p_probe(struct p
 		       pci_name(pdev));
 		goto err_free_desc;
 	}
+	for (i = 0; i < 2; i++) {
+		err = ieee80211_register_hwmode(dev, &priv->common.modes[i]);
+		if (err) {
+			printk(KERN_ERR "%s (prism54pci): Cannot register hwmode\n",
+				pci_name(pdev));
+			goto err_unreg_hw;
+		}
+	}
 
 	printk(KERN_INFO "wiphy%d: hwaddr " MAC_FMT ", isl38%02x\n",
 	       dev->index, MAC_ARG(dev->perm_addr), priv->common.version);
 
 	return 0;
 
+ err_unreg_hw:
+	ieee80211_unregister_hw(dev);
+
  err_free_desc:
 	p54_free_common(dev);
 	pci_free_consistent(pdev, sizeof(*priv->ring_control),
Index: jbenc-dscape/drivers/net/wireless/d80211/p54/prism54usb.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/p54/prism54usb.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/p54/prism54usb.c	2006-12-15 19:00:39.000000000 +0100
@@ -893,12 +893,22 @@ static int __devinit p54u_probe(struct u
 		printk(KERN_ERR "prism54usb: Cannot register netdevice\n");
 		goto err_free_dev;
 	}
+	for (i = 0; i < 2; i++) {
+		err = ieee80211_register_hwmode(dev, &priv->common.modes[i]);
+		if (err) {
+			printk(KERN_ERR "prism54usb: Cannot register hwmode\n");
+			goto err_unreg_hw;
+		}
+	}
 
 	printk(KERN_INFO "wiphy%d: hwaddr " MAC_FMT ", isl38%02x\n",
 	       dev->index, MAC_ARG(dev->perm_addr), priv->common.version);
 
 	return 0;
 
+ err_unreg_hw:
+	ieee80211_unregister_hw(dev);
+
  err_free_dev:
 	ieee80211_free_hw(dev);
 	usb_set_intfdata(intf, NULL);

-- 
Greetings Michael.
