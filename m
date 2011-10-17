From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] ixgbe: allow eeprom writes via ethtool
Date: Mon, 17 Oct 2011 05:21:00 -0700
Message-ID: <1318854062-3628-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33845 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753111Ab1JQMVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 08:21:08 -0400
In-Reply-To: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Implement support for ethtool -E

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   71 ++++++++++++++++++++++
 2 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index e02e911..ef2afef 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1305,6 +1305,8 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
 	.init_params		= &ixgbe_init_eeprom_params_generic,
 	.read			= &ixgbe_read_eerd_generic,
+	.write			= &ixgbe_write_eeprom_generic,
+	.write_buffer		= &ixgbe_write_eeprom_buffer_bit_bang_generic,
 	.read_buffer		= &ixgbe_read_eerd_buffer_generic,
 	.calc_checksum          = &ixgbe_calc_eeprom_checksum_generic,
 	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index e102ff6..7acfce3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -814,6 +814,76 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 	return ret_val;
 }
 
+static int ixgbe_set_eeprom(struct net_device *netdev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 *eeprom_buff;
+	void *ptr;
+	int max_len, first_word, last_word, ret_val = 0;
+	u16 i;
+
+	if (eeprom->len == 0)
+		return -EINVAL;
+
+	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
+		return -EINVAL;
+
+	max_len = hw->eeprom.word_size * 2;
+
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+	eeprom_buff = kmalloc(max_len, GFP_KERNEL);
+	if (!eeprom_buff)
+		return -ENOMEM;
+
+	ptr = eeprom_buff;
+
+	if (eeprom->offset & 1) {
+		/*
+		 * need read/modify/write of first changed EEPROM word
+		 * only the second byte of the word is being modified
+		 */
+		ret_val = hw->eeprom.ops.read(hw, first_word, &eeprom_buff[0]);
+		if (ret_val)
+			goto err;
+
+		ptr++;
+	}
+	if ((eeprom->offset + eeprom->len) & 1) {
+		/*
+		 * need read/modify/write of last changed EEPROM word
+		 * only the first byte of the word is being modified
+		 */
+		ret_val = hw->eeprom.ops.read(hw, last_word,
+					  &eeprom_buff[last_word - first_word]);
+		if (ret_val)
+			goto err;
+	}
+
+	/* Device's eeprom is always little-endian, word addressable */
+	for (i = 0; i < last_word - first_word + 1; i++)
+		le16_to_cpus(&eeprom_buff[i]);
+
+	memcpy(ptr, bytes, eeprom->len);
+
+	for (i = 0; i < last_word - first_word + 1; i++)
+		cpu_to_le16s(&eeprom_buff[i]);
+
+	ret_val = hw->eeprom.ops.write_buffer(hw, first_word,
+					      last_word - first_word + 1,
+					      eeprom_buff);
+
+	/* Update the checksum */
+	if (ret_val == 0)
+		hw->eeprom.ops.update_checksum(hw);
+
+err:
+	kfree(eeprom_buff);
+	return ret_val;
+}
+
 static void ixgbe_get_drvinfo(struct net_device *netdev,
                               struct ethtool_drvinfo *drvinfo)
 {
@@ -2524,6 +2594,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_link               = ethtool_op_get_link,
 	.get_eeprom_len         = ixgbe_get_eeprom_len,
 	.get_eeprom             = ixgbe_get_eeprom,
+	.set_eeprom             = ixgbe_set_eeprom,
 	.get_ringparam          = ixgbe_get_ringparam,
 	.set_ringparam          = ixgbe_set_ringparam,
 	.get_pauseparam         = ixgbe_get_pauseparam,
-- 
1.7.6.4
