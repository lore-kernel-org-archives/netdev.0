From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v3 11/17] venet-tap: add the ability to set the client's
	mac address via sysfs
Date: Tue, 21 Apr 2009 14:35:15 -0400
Message-ID: <20090421183515.12548.1567.stgit@dev.haskins.net>
References: <20090421183341.12548.33393.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, alext@novell.com, anthony@codemonkey.ws,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	chrisw@sous-sol.org, shemminger@vyatta.com, alex.williamson@hp.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:53947 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756080AbZDUSln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 14:41:43 -0400
In-Reply-To: <20090421183341.12548.33393.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Mullaney <pmullaney@novell.com>

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/vbus/devices/venet-tap.c |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/drivers/vbus/devices/venet-tap.c b/drivers/vbus/devices/venet-tap.c
index 5e093a0..33ede4c 100644
--- a/drivers/vbus/devices/venet-tap.c
+++ b/drivers/vbus/devices/venet-tap.c
@@ -1214,6 +1214,39 @@ host_mac_show(struct vbus_device *dev, struct vbus_device_attribute *attr,
 static struct vbus_device_attribute attr_hmac =
 	__ATTR_RO(host_mac);
 
+
+static ssize_t
+cmac_store(struct vbus_device *dev, struct vbus_device_attribute *attr,
+	      const char *buf, size_t count)
+{
+	struct venettap *priv = vdev_to_priv(dev);
+	const char *pbuf = buf;
+	unsigned int uc;
+	int i;
+
+	/*
+	 * Format 00:11:22:33:44:55
+	 */
+	if (count != 18)
+		return -EINVAL;
+
+	for (i = 2; i < 17; i += 3) {
+		if (pbuf[i] != ':')
+			return -EINVAL;
+	}
+
+	if (priv->vbus.opened)
+		return -EINVAL;
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		sscanf(pbuf, "%x", &uc);
+		pbuf = pbuf + 3;
+		priv->cmac[i] = (u8)uc;
+	}
+
+	return count;
+}
+
 static ssize_t
 client_mac_show(struct vbus_device *dev, struct vbus_device_attribute *attr,
 	 char *buf)
@@ -1224,7 +1257,7 @@ client_mac_show(struct vbus_device *dev, struct vbus_device_attribute *attr,
 }
 
 static struct vbus_device_attribute attr_cmac =
-	__ATTR_RO(client_mac);
+	__ATTR(client_mac, S_IRUGO | S_IWUSR, client_mac_show, cmac_store);
 
 static ssize_t
 enabled_show(struct vbus_device *dev, struct vbus_device_attribute *attr,

