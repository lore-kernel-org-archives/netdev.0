From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/15] igb: Support to read and export SFF-8472/8079 data
Date: Thu, 18 Apr 2013 16:30:12 -0700
Message-ID: <1366327822-10741-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	=?UTF-8?q?Aur=C3=A9lien=20Guillaume?= <footplus@gmail.com>,
	Ben Hutchings <bhuntchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14087 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936673Ab3DRXat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:30:49 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch adds support to read and export SFF-8472/8079 (SFP data)
over i2c, through Ethtool.

v2: Changed implementation to accommodate any offset within SFF module
    length boundary.

Reported-by: Aur=C3=A9lien Guillaume <footplus@gmail.com>
CC: Aur=C3=A9lien Guillaume <footplus@gmail.com>
CC: Ben Hutchings <bhuntchings@solarflare.com>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  8 +++
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 81 ++++++++++++++++++++=
++++++++
 2 files changed, 89 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/etherne=
t/intel/igb/igb.h
index 2515140..7cb0398 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -178,6 +178,14 @@ enum igb_tx_flags {
 #define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IGB_MAX_DATA_PER_TXD)
 #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
=20
+/* EEPROM byte offsets */
+#define IGB_SFF_8472_SWAP		0x5C
+#define IGB_SFF_8472_COMP		0x5E
+
+/* Bitmasks */
+#define IGB_SFF_ADDRESSING_MODE		0x4
+#define IGB_SFF_8472_UNSUP		0x00
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct igb_tx_buffer {
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net=
/ethernet/intel/igb/igb_ethtool.c
index 8499c48..6afd727 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2622,6 +2622,85 @@ static int igb_set_eee(struct net_device *netdev=
,
 	return 0;
 }
=20
+static int igb_get_module_info(struct net_device *netdev,
+			       struct ethtool_modinfo *modinfo)
+{
+	struct igb_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+	u32 status =3D E1000_SUCCESS;
+	u16 sff8472_rev, addr_mode;
+	bool page_swap =3D false;
+
+	if ((hw->phy.media_type =3D=3D e1000_media_type_copper) ||
+	    (hw->phy.media_type =3D=3D e1000_media_type_unknown))
+		return -EOPNOTSUPP;
+
+	/* Check whether we support SFF-8472 or not */
+	status =3D igb_read_phy_reg_i2c(hw, IGB_SFF_8472_COMP, &sff8472_rev);
+	if (status !=3D E1000_SUCCESS)
+		return -EIO;
+
+	/* addressing mode is not supported */
+	status =3D igb_read_phy_reg_i2c(hw, IGB_SFF_8472_SWAP, &addr_mode);
+	if (status !=3D E1000_SUCCESS)
+		return -EIO;
+
+	/* addressing mode is not supported */
+	if ((addr_mode & 0xFF) & IGB_SFF_ADDRESSING_MODE) {
+		hw_dbg("Address change required to access page 0xA2, but not support=
ed. Please report the module type to the driver maintainers.\n");
+		page_swap =3D true;
+	}
+
+	if ((sff8472_rev & 0xFF) =3D=3D IGB_SFF_8472_UNSUP || page_swap) {
+		/* We have an SFP, but it does not support SFF-8472 */
+		modinfo->type =3D ETH_MODULE_SFF_8079;
+		modinfo->eeprom_len =3D ETH_MODULE_SFF_8079_LEN;
+	} else {
+		/* We have an SFP which supports a revision of SFF-8472 */
+		modinfo->type =3D ETH_MODULE_SFF_8472;
+		modinfo->eeprom_len =3D ETH_MODULE_SFF_8472_LEN;
+	}
+
+	return 0;
+}
+
+static int igb_get_module_eeprom(struct net_device *netdev,
+				 struct ethtool_eeprom *ee, u8 *data)
+{
+	struct igb_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+	u32 status =3D E1000_SUCCESS;
+	u16 *dataword;
+	u16 first_word, last_word;
+	int i =3D 0;
+
+	if (ee->len =3D=3D 0)
+		return -EINVAL;
+
+	first_word =3D ee->offset >> 1;
+	last_word =3D (ee->offset + ee->len - 1) >> 1;
+
+	dataword =3D kmalloc(sizeof(u16) * (last_word - first_word + 1),
+			   GFP_KERNEL);
+	if (!dataword)
+		return -ENOMEM;
+
+	/* Read EEPROM block, SFF-8079/SFF-8472, word at a time */
+	for (i =3D 0; i < last_word - first_word + 1; i++) {
+		status =3D igb_read_phy_reg_i2c(hw, first_word + i, &dataword[i]);
+		if (status !=3D E1000_SUCCESS)
+			/* Error occurred while reading module */
+			return -EIO;
+
+		be16_to_cpus(&dataword[i]);
+	}
+
+	memcpy(data, (u8 *)dataword + (ee->offset & 1), ee->len);
+	kfree(dataword);
+
+	return 0;
+}
+
 static int igb_ethtool_begin(struct net_device *netdev)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
@@ -2666,6 +2745,8 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
 	.set_rxnfc		=3D igb_set_rxnfc,
 	.get_eee		=3D igb_get_eee,
 	.set_eee		=3D igb_set_eee,
+	.get_module_info	=3D igb_get_module_info,
+	.get_module_eeprom	=3D igb_get_module_eeprom,
 	.begin			=3D igb_ethtool_begin,
 	.complete		=3D igb_ethtool_complete,
 };
--=20
1.7.11.7
