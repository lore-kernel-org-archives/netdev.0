From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 05/17] wpan-phy: allow specifying a per-page channel mask
Date: Fri,  6 Nov 2009 15:39:29 +0300
Message-ID: <1257511181-19403-6-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757668AbZKFMko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:44 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:49 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 802.15.4-2006 defines channel pages that hold channels (max 32 pages,
27 channels per page). Allow the driver to specify supported channels
on pages, other than the first one.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c |    2 +-
 include/net/wpan-phy.h        |    2 +-
 net/ieee802154/wpan-class.c   |   20 +++++++++++++++++++-
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 96a2959..f6f2afe 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -356,7 +356,7 @@ static int __devinit ieee802154fake_probe(struct platform_device *pdev)
 			dev->addr_len);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	phy->channels_supported = (1 << 27) - 1;
+	phy->channels_supported[0] = (1 << 27) - 1;
 	phy->transmit_power = 0xbf;
 
 	dev->netdev_ops = &fake_ops;
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index 3367dd9..7b7fc58 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -34,7 +34,7 @@ struct wpan_phy {
 	 */
 	u8 current_channel;
 	u8 current_page;
-	u32 channels_supported;
+	u32 channels_supported[32];
 	u8 transmit_power;
 	u8 cca_mode;
 
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 68ccde6..0c51f85 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -40,12 +40,30 @@ static ssize_t name ## _show(struct device *dev,			\
 
 MASTER_SHOW(current_channel, "%d");
 MASTER_SHOW(current_page, "%d");
-MASTER_SHOW(channels_supported, "%#x");
 MASTER_SHOW_COMPLEX(transmit_power, "%d +- %d dB",
 	((signed char) (phy->transmit_power << 2)) >> 2,
 	(phy->transmit_power >> 6) ? (phy->transmit_power >> 6) * 3 : 1 );
 MASTER_SHOW(cca_mode, "%d");
 
+static ssize_t channels_supported_show(struct device *dev,
+			    struct device_attribute *attr, char *buf)
+{
+	struct wpan_phy *phy = container_of(dev, struct wpan_phy, dev);
+	int ret;
+	int i, len = 0;
+
+	mutex_lock(&phy->pib_lock);
+	for (i = 0; i < 32; i++) {
+		ret = snprintf(buf + len, PAGE_SIZE - len,
+				"%#09x\n", phy->channels_supported[i]);
+		if (ret < 0)
+			break;
+		len += ret;
+	}
+	mutex_unlock(&phy->pib_lock);
+	return len;
+}
+
 static struct device_attribute pmib_attrs[] = {
 	__ATTR_RO(current_channel),
 	__ATTR_RO(current_page),
-- 
1.6.5

