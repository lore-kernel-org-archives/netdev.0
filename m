From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/6] rt2x00 - pci request/release regions
Date: Tue, 8 Aug 2006 15:46:54 +0200
Message-ID: <200608081546.54739.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:28394 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932500AbWHHNrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:47:24 -0400
Received: by nf-out-0910.google.com with SMTP id q29so175926nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 06:47:23 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to Documentation/pci.txt in 2.6.18 pci_request_regions()
should be called _before_ pci_enable_device().
And pci_release_regions() should be called after pci_disable_device().

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:18:32.000000000 +0200
+++ wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:35:53.000000000 +0200
@@ -2851,10 +2851,16 @@
 	struct net_device *net_dev;
 	int status;
 
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
+		ERROR("PCI request regions failed.\n");
+		return status;
+	}
+
 	status = pci_enable_device(pci_dev);
 	if (status) {
 		ERROR("Enable device failed.\n");
-		return status;
+		goto exit_release_regions;
 	}
 
 	pci_set_master(pci_dev);
@@ -2869,17 +2875,11 @@
 		goto exit_disable_device;
 	}
 
-	status = pci_request_regions(pci_dev, pci_name(pci_dev));
-	if (status) {
-		ERROR("PCI request regions failed.\n");
-		goto exit_disable_device;
-	}
-
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
 	if (!net_dev) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
-		goto exit_release_regions;
+		goto exit_disable_device;
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2400pci_ethtool_ops);
@@ -2898,13 +2898,13 @@
 exit_free_device:
 	ieee80211_free_hw(net_dev);
 
-exit_release_regions:
-	pci_release_regions(pci_dev);
-
 exit_disable_device:
 	if (status != -EBUSY)
 		pci_disable_device(pci_dev);
 
+exit_release_regions:
+	pci_release_regions(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return status;
@@ -2927,9 +2927,9 @@
 
 	pci_set_drvdata(pci_dev, NULL);
 
-	pci_release_regions(pci_dev);
-
 	pci_disable_device(pci_dev);
+
+	pci_release_regions(pci_dev);
 }
 
 #ifdef CONFIG_PM
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:18:32.000000000 +0200
+++ wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:35:38.000000000 +0200
@@ -3134,10 +3134,16 @@
 	struct net_device *net_dev;
 	int status;
 
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
+		ERROR("PCI request regions failed.\n");
+		return status;
+	}
+
 	status = pci_enable_device(pci_dev);
 	if (status) {
 		ERROR("Enable device failed.\n");
-		return status;
+		goto exit_release_regions;
 	}
 
 	pci_set_master(pci_dev);
@@ -3152,17 +3158,11 @@
 		goto exit_disable_device;
 	}
 
-	status = pci_request_regions(pci_dev, pci_name(pci_dev));
-	if (status) {
-		ERROR("PCI request regions failed.\n");
-		goto exit_disable_device;
-	}
-
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
 	if (!net_dev) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
-		goto exit_release_regions;
+		goto exit_disable_device;
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2500pci_ethtool_ops);
@@ -3181,13 +3181,13 @@
 exit_free_device:
 	ieee80211_free_hw(net_dev);
 
-exit_release_regions:
-	pci_release_regions(pci_dev);
-
 exit_disable_device:
 	if (status != -EBUSY)
 		pci_disable_device(pci_dev);
 
+exit_release_regions:
+	pci_release_regions(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return status;
@@ -3210,9 +3210,9 @@
 
 	pci_set_drvdata(pci_dev, NULL);
 
-	pci_release_regions(pci_dev);
-
 	pci_disable_device(pci_dev);
+
+	pci_release_regions(pci_dev);
 }
 
 #ifdef CONFIG_PM
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:18:32.000000000 +0200
+++ wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:35:44.000000000 +0200
@@ -3665,10 +3665,16 @@
 	struct net_device *net_dev;
 	int status;
 
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
+		ERROR("PCI request regions failed.\n");
+		return status;
+	}
+
 	status = pci_enable_device(pci_dev);
 	if (status) {
 		ERROR("Enable device failed.\n");
-		return status;
+		goto exit_release_regions;
 	}
 
 	pci_set_master(pci_dev);
@@ -3683,17 +3689,11 @@
 		goto exit_disable_device;
 	}
 
-	status = pci_request_regions(pci_dev, pci_name(pci_dev));
-	if (status) {
-		ERROR("PCI request regions failed.\n");
-		goto exit_disable_device;
-	}
-
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
 	if (!net_dev) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
-		goto exit_release_regions;
+		goto exit_disable_device;
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt61pci_ethtool_ops);
@@ -3712,13 +3712,13 @@
 exit_free_device:
 	ieee80211_free_hw(net_dev);
 
-exit_release_regions:
-	pci_release_regions(pci_dev);
-
 exit_disable_device:
 	if (status != -EBUSY)
 		pci_disable_device(pci_dev);
 
+exit_release_regions:
+	pci_release_regions(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return status;
@@ -3741,9 +3741,9 @@
 
 	pci_set_drvdata(pci_dev, NULL);
 
-	pci_release_regions(pci_dev);
-
 	pci_disable_device(pci_dev);
+
+	pci_release_regions(pci_dev);
 }
 
 #ifdef CONFIG_PM
