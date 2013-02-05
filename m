From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbe: allow reading of SFF-8472 data over i2c
Date: Tue,  5 Feb 2013 02:02:23 -0800
Message-ID: <1360058548-18158-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	=?UTF-8?q?Aur=C3=A9lien=20Guillaume?= <footplus@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38716 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753932Ab3BEKDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:03:00 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds functions needed for reading SFF-8472 diagnostic data
from SFP modules.

Based on original patch from Aur=C3=A9lien Guillaume <footplus@gmail.co=
m>

CC: Aur=C3=A9lien Guillaume <footplus@gmail.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c | 45 ++++++++++++++++++=
++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c   | 16 +++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h   |  9 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  |  1 +
 6 files changed, 66 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_82598.c
index 7fd3833..6030de5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1003,15 +1003,16 @@ static s32 ixgbe_write_analog_reg8_82598(struct=
 ixgbe_hw *hw, u32 reg, u8 val)
 }
=20
 /**
- *  ixgbe_read_i2c_eeprom_82598 - Reads 8 bit word over I2C interface.
+ *  ixgbe_read_i2c_phy_82598 - Reads 8 bit word over I2C interface.
  *  @hw: pointer to hardware structure
- *  @byte_offset: EEPROM byte offset to read
+ *  @dev_addr: address to read from
+ *  @byte_offset: byte offset to read from dev_addr
  *  @eeprom_data: value read
  *
- *  Performs 8 byte read operation to SFP module's EEPROM over I2C int=
erface.
+ *  Performs 8 byte read operation to SFP module's data over I2C inter=
face.
  **/
-static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_of=
fset,
-				       u8 *eeprom_data)
+static s32 ixgbe_read_i2c_phy_82598(struct ixgbe_hw *hw, u8 dev_addr,
+				    u8 byte_offset, u8 *eeprom_data)
 {
 	s32 status =3D 0;
 	u16 sfp_addr =3D 0;
@@ -1025,7 +1026,7 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixg=
be_hw *hw, u8 byte_offset,
 		 * 0xC30D.  These registers are used to talk to the SFP+
 		 * module's EEPROM through the SDA/SCL (I2C) interface.
 		 */
-		sfp_addr =3D (IXGBE_I2C_EEPROM_DEV_ADDR << 8) + byte_offset;
+		sfp_addr =3D (dev_addr << 8) + byte_offset;
 		sfp_addr =3D (sfp_addr | IXGBE_I2C_EEPROM_READ_MASK);
 		hw->phy.ops.write_reg(hw,
 		                      IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR,
@@ -1057,7 +1058,6 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixg=
be_hw *hw, u8 byte_offset,
 		*eeprom_data =3D (u8)(sfp_data >> 8);
 	} else {
 		status =3D IXGBE_ERR_PHY;
-		goto out;
 	}
=20
 out:
@@ -1065,6 +1065,36 @@ out:
 }
=20
 /**
+ *  ixgbe_read_i2c_eeprom_82598 - Reads 8 bit word over I2C interface.
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: EEPROM byte offset to read
+ *  @eeprom_data: value read
+ *
+ *  Performs 8 byte read operation to SFP module's EEPROM over I2C int=
erface.
+ **/
+static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_of=
fset,
+				       u8 *eeprom_data)
+{
+	return ixgbe_read_i2c_phy_82598(hw, IXGBE_I2C_EEPROM_DEV_ADDR,
+					byte_offset, eeprom_data);
+}
+
+/**
+ *  ixgbe_read_i2c_sff8472_82598 - Reads 8 bit word over I2C interface=
=2E
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: byte offset at address 0xA2
+ *  @eeprom_data: value read
+ *
+ *  Performs 8 byte read operation to SFP module's SFF-8472 data over =
I2C
+ **/
+static s32 ixgbe_read_i2c_sff8472_82598(struct ixgbe_hw *hw, u8 byte_o=
ffset,
+				       u8 *sff8472_data)
+{
+	return ixgbe_read_i2c_phy_82598(hw, IXGBE_I2C_EEPROM_DEV_ADDR2,
+					byte_offset, sff8472_data);
+}
+
+/**
  *  ixgbe_get_supported_physical_layer_82598 - Returns physical layer =
type
  *  @hw: pointer to hardware structure
  *
@@ -1297,6 +1327,7 @@ static struct ixgbe_phy_operations phy_ops_82598 =
=3D {
 	.write_reg		=3D &ixgbe_write_phy_reg_generic,
 	.setup_link		=3D &ixgbe_setup_phy_link_generic,
 	.setup_link_speed	=3D &ixgbe_setup_phy_link_speed_generic,
+	.read_i2c_sff8472	=3D &ixgbe_read_i2c_sff8472_82598,
 	.read_i2c_eeprom	=3D &ixgbe_read_i2c_eeprom_82598,
 	.check_overtemp   =3D &ixgbe_tn_check_overtemp,
 };
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_82599.c
index 3350461..d1f4d45 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2241,6 +2241,7 @@ static struct ixgbe_phy_operations phy_ops_82599 =
=3D {
 	.setup_link_speed	=3D &ixgbe_setup_phy_link_speed_generic,
 	.read_i2c_byte		=3D &ixgbe_read_i2c_byte_generic,
 	.write_i2c_byte		=3D &ixgbe_write_i2c_byte_generic,
+	.read_i2c_sff8472	=3D &ixgbe_read_i2c_sff8472_generic,
 	.read_i2c_eeprom	=3D &ixgbe_read_i2c_eeprom_generic,
 	.write_i2c_eeprom	=3D &ixgbe_write_i2c_eeprom_generic,
 	.check_overtemp		=3D &ixgbe_tn_check_overtemp,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net=
/ethernet/intel/ixgbe/ixgbe_phy.c
index f4b2c0d..d034cc5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1204,6 +1204,22 @@ s32 ixgbe_read_i2c_eeprom_generic(struct ixgbe_h=
w *hw, u8 byte_offset,
 }
=20
 /**
+ *  ixgbe_read_i2c_sff8472_generic - Reads 8 bit word over I2C interfa=
ce
+ *  @hw: pointer to hardware structure
+ *  @byte_offset: byte offset at address 0xA2
+ *  @eeprom_data: value read
+ *
+ *  Performs byte read operation to SFP module's SFF-8472 data over I2=
C
+ **/
+s32 ixgbe_read_i2c_sff8472_generic(struct ixgbe_hw *hw, u8 byte_offset=
,
+				   u8 *sff8472_data)
+{
+	return hw->phy.ops.read_i2c_byte(hw, byte_offset,
+					 IXGBE_I2C_EEPROM_DEV_ADDR2,
+					 sff8472_data);
+}
+
+/**
  *  ixgbe_write_i2c_eeprom_generic - Writes 8 bit EEPROM word over I2C=
 interface
  *  @hw: pointer to hardware structure
  *  @byte_offset: EEPROM byte offset to write
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net=
/ethernet/intel/ixgbe/ixgbe_phy.h
index 51b0a91..bbfe55c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -30,6 +30,7 @@
=20
 #include "ixgbe_type.h"
 #define IXGBE_I2C_EEPROM_DEV_ADDR    0xA0
+#define IXGBE_I2C_EEPROM_DEV_ADDR2   0xA2
=20
 /* EEPROM byte offsets */
 #define IXGBE_SFF_IDENTIFIER         0x0
@@ -41,6 +42,8 @@
 #define IXGBE_SFF_10GBE_COMP_CODES   0x3
 #define IXGBE_SFF_CABLE_TECHNOLOGY   0x8
 #define IXGBE_SFF_CABLE_SPEC_COMP    0x3C
+#define IXGBE_SFF_SFF_8472_SWAP      0x5C
+#define IXGBE_SFF_SFF_8472_COMP      0x5E
=20
 /* Bitmasks */
 #define IXGBE_SFF_DA_PASSIVE_CABLE           0x4
@@ -51,6 +54,7 @@
 #define IXGBE_SFF_1GBASET_CAPABLE            0x8
 #define IXGBE_SFF_10GBASESR_CAPABLE          0x10
 #define IXGBE_SFF_10GBASELR_CAPABLE          0x20
+#define IXGBE_SFF_ADDRESSING_MODE	     0x4
 #define IXGBE_I2C_EEPROM_READ_MASK           0x100
 #define IXGBE_I2C_EEPROM_STATUS_MASK         0x3
 #define IXGBE_I2C_EEPROM_STATUS_NO_OPERATION 0x0
@@ -88,6 +92,9 @@
 #define IXGBE_TN_LASI_STATUS_REG        0x9005
 #define IXGBE_TN_LASI_STATUS_TEMP_ALARM 0x0008
=20
+/* SFP+ SFF-8472 Compliance code */
+#define IXGBE_SFF_SFF_8472_UNSUP      0x00
+
 s32 ixgbe_init_phy_ops_generic(struct ixgbe_hw *hw);
 s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw);
 s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw);
@@ -125,6 +132,8 @@ s32 ixgbe_write_i2c_byte_generic(struct ixgbe_hw *h=
w, u8 byte_offset,
                                  u8 dev_addr, u8 data);
 s32 ixgbe_read_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset,
                                   u8 *eeprom_data);
+s32 ixgbe_read_i2c_sff8472_generic(struct ixgbe_hw *hw, u8 byte_offset=
,
+				   u8 *sff8472_data);
 s32 ixgbe_write_i2c_eeprom_generic(struct ixgbe_hw *hw, u8 byte_offset=
,
                                    u8 eeprom_data);
 #endif /* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_type.h
index 0bdcc88..1af6289 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2874,6 +2874,7 @@ struct ixgbe_phy_operations {
 	s32 (*get_firmware_version)(struct ixgbe_hw *, u16 *);
 	s32 (*read_i2c_byte)(struct ixgbe_hw *, u8, u8, u8 *);
 	s32 (*write_i2c_byte)(struct ixgbe_hw *, u8, u8, u8);
+	s32 (*read_i2c_sff8472)(struct ixgbe_hw *, u8 , u8 *);
 	s32 (*read_i2c_eeprom)(struct ixgbe_hw *, u8 , u8 *);
 	s32 (*write_i2c_eeprom)(struct ixgbe_hw *, u8, u8);
 	s32 (*check_overtemp)(struct ixgbe_hw *);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_x540.c
index 2fa5843..4dc3725 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -878,6 +878,7 @@ static struct ixgbe_phy_operations phy_ops_X540 =3D=
 {
 	.setup_link_speed       =3D &ixgbe_setup_phy_link_speed_generic,
 	.read_i2c_byte          =3D &ixgbe_read_i2c_byte_generic,
 	.write_i2c_byte         =3D &ixgbe_write_i2c_byte_generic,
+	.read_i2c_sff8472	=3D &ixgbe_read_i2c_sff8472_generic,
 	.read_i2c_eeprom        =3D &ixgbe_read_i2c_eeprom_generic,
 	.write_i2c_eeprom       =3D &ixgbe_write_i2c_eeprom_generic,
 	.check_overtemp         =3D &ixgbe_tn_check_overtemp,
--=20
1.7.11.7
