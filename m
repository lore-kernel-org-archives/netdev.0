From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH net-next 2/2] asix: Add support for programming the EEPROM
Date: Thu, 19 Jul 2012 12:23:07 +0200
Message-ID: <1342693387-17945-2-git-send-email-christian.riesch@omicron.at>
References: <1342693387-17945-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Allan Chou <allan@asix.com.tw>, Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:48638 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab2GSKXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 06:23:45 -0400
In-Reply-To: <1342693387-17945-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the asix_set_eeprom() function to provide support for
programming the configuration EEPROM via ethtool.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/asix.h         |    2 +
 drivers/net/usb/asix_common.c  |   81 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/asix_devices.c |    3 +
 drivers/net/usb/ax88172a.c     |    1 +
 4 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index fbff177..e889631 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -208,6 +208,8 @@ int asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo);
 int asix_get_eeprom_len(struct net_device *net);
 int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
 		    u8 *data);
+int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
+		    u8 *data);
 
 void asix_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info);
 
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 0b5b2d3..774d9ce 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -516,6 +516,87 @@ int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
 	return 0;
 }
 
+int asix_set_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
+		    u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u16 *eeprom_buff;
+	int first_word, last_word;
+	int i;
+	int ret;
+
+	netdev_dbg(net, "write EEPROM len %d, offset %d, magic 0x%x\n",
+		   eeprom->len, eeprom->offset, eeprom->magic);
+
+	if (eeprom->len == 0)
+		return -EINVAL;
+
+	if (eeprom->magic != AX_EEPROM_MAGIC)
+		return -EINVAL;
+
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+
+	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+			      GFP_KERNEL);
+	if (!eeprom_buff)
+		return -ENOMEM;
+
+	/* align data to 16 bit boundaries, read the missing data from
+	   the EEPROM */
+	if (eeprom->offset & 1) {
+		ret = asix_read_cmd(dev, AX_CMD_READ_EEPROM, first_word, 0, 2,
+				    &(eeprom_buff[0]));
+		if (ret < 0) {
+			netdev_err(net, "Failed to read EEPROM at offset 0x%02x.\n", first_word);
+			goto free;
+		}
+	}
+
+	if ((eeprom->offset + eeprom->len) & 1) {
+		ret = asix_read_cmd(dev, AX_CMD_READ_EEPROM, last_word, 0, 2,
+				    &(eeprom_buff[last_word - first_word]));
+		if (ret < 0) {
+			netdev_err(net, "Failed to read EEPROM at offset 0x%02x.\n", last_word);
+			goto free;
+		}
+	}
+
+	memcpy((u8 *)eeprom_buff + (eeprom->offset & 1), data, eeprom->len);
+
+	/* write data to EEPROM */
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0x0000, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(net, "Failed to enable EEPROM write\n");
+		goto free;
+	}
+	msleep(20);
+
+	for (i = first_word; i <= last_word; i++) {
+		netdev_dbg(net, "write to EEPROM at offset 0x%02x, data 0x%04x\n",
+			   i, eeprom_buff[i - first_word]);
+		ret = asix_write_cmd(dev, AX_CMD_WRITE_EEPROM, i,
+				     eeprom_buff[i - first_word], 0, NULL);
+		if (ret < 0) {
+			netdev_err(net, "Failed to write EEPROM at offset 0x%02x.\n",
+				   i);
+			goto free;
+		}
+		msleep(20);
+	}
+
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0x0000, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(net, "Failed to disable EEPROM write\n");
+		goto free;
+	}
+
+	ret = 0;
+free:
+	kfree(eeprom_buff);
+	return ret;
+}
+
 void asix_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 {
 	/* Inherit standard device info */
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 658c08f..4fd48df 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -119,6 +119,7 @@ static const struct ethtool_ops ax88172_ethtool_ops = {
 	.set_wol		= asix_set_wol,
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
+	.set_eeprom		= asix_set_eeprom,
 	.get_settings		= usbnet_get_settings,
 	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
@@ -258,6 +259,7 @@ static const struct ethtool_ops ax88772_ethtool_ops = {
 	.set_wol		= asix_set_wol,
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
+	.set_eeprom		= asix_set_eeprom,
 	.get_settings		= usbnet_get_settings,
 	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
@@ -478,6 +480,7 @@ static const struct ethtool_ops ax88178_ethtool_ops = {
 	.set_wol		= asix_set_wol,
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
+	.set_eeprom		= asix_set_eeprom,
 	.get_settings		= usbnet_get_settings,
 	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 97dce0f..c8e0aa8 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -194,6 +194,7 @@ static const struct ethtool_ops ax88172a_ethtool_ops = {
 	.set_wol		= asix_set_wol,
 	.get_eeprom_len		= asix_get_eeprom_len,
 	.get_eeprom		= asix_get_eeprom,
+	.set_eeprom		= asix_set_eeprom,
 	.get_settings		= ax88172a_get_settings,
 	.set_settings		= ax88172a_set_settings,
 	.nway_reset		= ax88172a_nway_reset,
-- 
1.7.0.4
