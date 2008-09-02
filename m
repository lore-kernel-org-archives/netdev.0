From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 4/4] e1000e: prevent corruption of EEPROM/NVM
Date: Tue, 02 Sep 2008 14:48:20 -0700
Message-ID: <200809022148.m82LmKQu014384@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	chrisl@vmware.com, arvidjaar@mail.ru, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, peter.p.waskiewicz.jr@intel.com,
	pratap@vmware.com, zach@vmware.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38142 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbYIBVzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 17:55:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher Li <chrisl@vmware.com> 

Andrey reports e1000e corruption, and that a patch in vmware's ESX fixed
it.

The EEPROM corruption is triggered by concurrent access of the EEPROM
read/write. Putting a lock around it solve the problem.

[akpm@linux-foundation.org: use DEFINE_SPINLOCK to avoid confusing lockdep]
Signed-off-by: Christopher Li <chrisl@vmware.com>
Reported-by: Andrey Borzenkov <arvidjaar@mail.ru>
Cc: Zach Amsden <zach@vmware.com>
Cc: Pratap Subrahmanyam <pratap@vmware.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000/e1000_hw.c |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff -puN drivers/net/e1000/e1000_hw.c~e1000e-prevent-corruption-of-eeprom-nvm drivers/net/e1000/e1000_hw.c
--- a/drivers/net/e1000/e1000_hw.c~e1000e-prevent-corruption-of-eeprom-nvm
+++ a/drivers/net/e1000/e1000_hw.c
@@ -144,6 +144,8 @@ static s32 e1000_host_if_read_cookie(str
 static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
 static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex);
 static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
+static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 
 /* IGP cable length table */
 static const
@@ -168,6 +170,8 @@ u16 e1000_igp_2_cable_length_table[IGP02
       83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
       104, 109, 114, 118, 121, 124};
 
+static DEFINE_SPINLOCK(e1000_eeprom_lock);
+
 /******************************************************************************
  * Set the phy type member in the hw struct.
  *
@@ -4904,6 +4908,15 @@ static s32 e1000_spi_eeprom_ready(struct
  *****************************************************************************/
 s32 e1000_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
+    s32 ret;
+    spin_lock(&e1000_eeprom_lock);
+    ret = e1000_do_read_eeprom(hw, offset, words, data);
+    spin_unlock(&e1000_eeprom_lock);
+    return ret;
+}
+
+static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 i = 0;
 
@@ -5236,6 +5249,16 @@ s32 e1000_update_eeprom_checksum(struct 
  *****************************************************************************/
 s32 e1000_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
+    s32 ret;
+    spin_lock(&e1000_eeprom_lock);
+    ret = e1000_do_write_eeprom(hw, offset, words, data);
+    spin_unlock(&e1000_eeprom_lock);
+    return ret;
+}
+
+
+static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     s32 status = 0;
 
_
