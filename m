From: Sebastien Jan <s-jan@ti.com>
Subject: [PATCH 3/4 v2] ks8851: companion eeprom access through ethtool
Date: Wed,  5 May 2010 20:45:54 +0200
Message-ID: <1273085155-1260-4-git-send-email-s-jan@ti.com>
References: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Cc: linux-omap@vger.kernel.org, Abraham Arce <x0066660@ti.com>,
	Ben Dooks <ben-linux@fluff.org>, Tristram.Ha@micrel.com,
	Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:33657 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758006Ab0EESpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 14:45:13 -0400
In-Reply-To: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accessing ks8851 companion eeprom permits modifying the ks8851 stored
MAC address.

Example how to change the MAC address using ethtool, to set the
01:23:45:67:89:AB MAC address:
$ echo "0:AB8976452301" | xxd -r > mac.bin
$ sudo ethtool -E eth0 magic 0x8870 offset 2 < mac.bin

Signed-off-by: Sebastien Jan <s-jan@ti.com>
---
 drivers/net/ks8851.c |  114 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 787f9df..8e38c36 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -1318,6 +1318,117 @@ static int ks8851_nway_reset(struct net_device *dev)
 	return mii_nway_restart(&ks->mii);
 }
 
+static int ks8851_get_eeprom_len(struct net_device *dev)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	return ks->eeprom_size;
+}
+
+static int ks8851_get_eeprom(struct net_device *dev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	u16 *eeprom_buff;
+	int first_word;
+	int last_word;
+	int ret_val = 0;
+	u16 i;
+
+	if (eeprom->len == 0)
+		return -EINVAL;
+
+	if (eeprom->len > ks->eeprom_size)
+		return -EINVAL;
+
+	eeprom->magic = ks8851_rdreg16(ks, KS_CIDER);
+
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+
+	eeprom_buff = kmalloc(sizeof(u16) *
+			(last_word - first_word + 1), GFP_KERNEL);
+	if (!eeprom_buff)
+		return -ENOMEM;
+
+	for (i = 0; i < last_word - first_word + 1; i++)
+		eeprom_buff[i] = ks8851_eeprom_read(dev, first_word + 1);
+
+	/* Device's eeprom is little-endian, word addressable */
+	for (i = 0; i < last_word - first_word + 1; i++)
+		le16_to_cpus(&eeprom_buff[i]);
+
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
+	kfree(eeprom_buff);
+
+	return ret_val;
+}
+
+static int ks8851_set_eeprom(struct net_device *dev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	u16 *eeprom_buff;
+	void *ptr;
+	int max_len;
+	int first_word;
+	int last_word;
+	int ret_val = 0;
+	u16 i;
+
+	if (eeprom->len == 0)
+		return -EOPNOTSUPP;
+
+	if (eeprom->len > ks->eeprom_size)
+		return -EINVAL;
+
+	if (eeprom->magic != ks8851_rdreg16(ks, KS_CIDER))
+		return -EFAULT;
+
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+	max_len = (last_word - first_word + 1) * 2;
+	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
+	if (!eeprom_buff)
+		return -ENOMEM;
+
+	ptr = (void *)eeprom_buff;
+
+	if (eeprom->offset & 1) {
+		/* need read/modify/write of first changed EEPROM word */
+		/* only the second byte of the word is being modified */
+		eeprom_buff[0] = ks8851_eeprom_read(dev, first_word);
+		ptr++;
+	}
+	if ((eeprom->offset + eeprom->len) & 1)
+		/* need read/modify/write of last changed EEPROM word */
+		/* only the first byte of the word is being modified */
+		eeprom_buff[last_word - first_word] =
+					ks8851_eeprom_read(dev, last_word);
+
+
+	/* Device's eeprom is little-endian, word addressable */
+	le16_to_cpus(&eeprom_buff[0]);
+	le16_to_cpus(&eeprom_buff[last_word - first_word]);
+
+	memcpy(ptr, bytes, eeprom->len);
+
+	for (i = 0; i < last_word - first_word + 1; i++)
+		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
+
+	ks8851_eeprom_write(dev, EEPROM_OP_EWEN, 0, 0);
+
+	for (i = 0; i < last_word - first_word + 1; i++) {
+		ks8851_eeprom_write(dev, EEPROM_OP_WRITE, first_word + i,
+							eeprom_buff[i]);
+		mdelay(EEPROM_WRITE_TIME);
+	}
+
+	ks8851_eeprom_write(dev, EEPROM_OP_EWDS, 0, 0);
+
+	kfree(eeprom_buff);
+	return ret_val;
+}
+
 static const struct ethtool_ops ks8851_ethtool_ops = {
 	.get_drvinfo	= ks8851_get_drvinfo,
 	.get_msglevel	= ks8851_get_msglevel,
@@ -1326,6 +1437,9 @@ static const struct ethtool_ops ks8851_ethtool_ops = {
 	.set_settings	= ks8851_set_settings,
 	.get_link	= ks8851_get_link,
 	.nway_reset	= ks8851_nway_reset,
+	.get_eeprom_len	= ks8851_get_eeprom_len,
+	.get_eeprom	= ks8851_get_eeprom,
+	.set_eeprom	= ks8851_set_eeprom,
 };
 
 /* MII interface controls */
-- 
1.6.3.3

