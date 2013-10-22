From: Marek Vasut <marex@denx.de>
Subject: [PATCH] igb: Add EEPROM IO stubs for iNVM
Date: Tue, 22 Oct 2013 05:22:03 +0200
Message-ID: <1382412123-4782-1-git-send-email-marex@denx.de>
Cc: e1000-devel@lists.sourceforge.net, Marek Vasut <marex@denx.de>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:47750 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab3JVDWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 23:22:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add stub functions for EEPROM operations in case where the i210 is
used without external EEPROM. The EEPROM operations must not be set
to NULL, since otherwise we will get a backtrace when attempting the
command below. Once such place to trigger this is from igb_ethtool.c
igb_set_eeprom(), where hw->nvm.ops.write() is called without first
checking if .write() is valid . By grepping through the code, there
are more such occasions which assume .write() to be always valid.
Thus, instead of poluting the code with checks, add stubs. I believe
it'd be prefferable to possibly even implement those functions, but
my knowledge of the adapter is still limited and as far as I understand,
the iNVM is programmable only once.

Command:

$ ethtool -E eth0 magic 0x157b8086 offset 6 value 0x1b

Backtrace:

Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = be7ac000
[00000000] *pgd=4e6a6831, *pte=00000000, *ppte=00000000
Internal error: Oops: 80000007 [#1] SMP ARM
CPU: 2 PID: 59 Comm: ethtool Not tainted 3.12.0-rc6+ #8
task: bf8f3600 ti: be73c000 task.ti: be73c000
PC is at 0x0
LR is at igb_set_eeprom+0x27c/0x3b4
pc : [<00000000>]    lr : [<803bc780>]    psr: 20000013
sp : be73dd80  ip : 00000000  fp : be73ddf4
r10: 00000001  r9 : 00000003  r8 : be6d6000
r7 : bfa64a38  r6 : be6d7000  r5 : bfa64000  r4 : be73de20
r3 : be6d6000  r2 : 00000001  r1 : 00000003  r0 : bfa64a38
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c53c7d  Table: 4e7ac04a  DAC: 00000015
Process ethtool (pid: 59, stack limit = 0xbe73c240)
Stack: (0xbe73dd80 to 0xbe73e000)
dd80: 803c7e2c 803c8554 00000000 00000000 00000000 803c827c 00000004 00000000
dda0: 00000000 00000000 00010800 00080008 00000008 be73ddc0 800d1a34 8054db6c
ddc0: be6d6000 00000003 00ad97c8 00000001 be73c000 bfa64000 be6d7000 80584d58
dde0: be73de20 00ad97d8 be73de7c be73ddf8 80465e00 803bc510 be73de14 be6d7000
de00: e4114bb3 00000000 be73de6c 0000000c 8055048c 80076b5c 00000002 00000000
de20: 0000000c 157b8086 00000006 00000001 8094cac0 be73c000 00000000 00000000
de40: be73de7c 00008946 8094cac0 7e8cfcf4 be73de98 00008946 8094cac0 7e8cfcf4
de60: be73de98 be73c000 00000000 00000000 be73dee4 be73de80 80474f54 804656ac
de80: 000000a8 00000200 be73dec4 be73de98 80077c7c 80076b5c 30687465 00000000
dea0: 00000000 00000000 00ad97c8 00000000 00000000 00000000 be73c000 00008946
dec0: fffffdfd 7e8cfcf4 7e8cfcf4 7e8cfcf4 bf18c020 00000000 be73df04 be73dee8
dee0: 80449c18 80474ac8 80449b94 00008946 be6b0600 00000003 be73df74 be73df08
df00: 800e6d10 80449ba0 be6b0600 00030002 be6b5f40 be6b5f40 be73df3c be73df28
df20: 80554b2c 802b03e8 be6b5f6c be6b5f00 be73df5c be73c000 8000ea44 be73c000
df40: 8000eab0 bf8f3600 00000001 00008946 00000003 00000000 7e8cfcf4 be6b0600
df60: be73c000 00000000 be73dfa4 be73df78 800e72ac 800e6c98 be73df94 00000000
df80: 80076b64 0002bd0c 00000000 0002bcc8 00000036 8000ebe4 00000000 be73dfa8
dfa0: 8000ea20 800e7278 0002bd0c 00000000 00000003 00008946 7e8cfcf4 7e8cfcf4
dfc0: 0002bd0c 00000000 0002bcc8 00000036 00000000 00000000 00000000 7e8cfb84
dfe0: 7e8cfe65 7e8cfb78 0001201c 0004535c 20000010 00000003 00000000 00000000
Backtrace:
[<803bc504>] (igb_set_eeprom+0x0/0x3b4) from [<80465e00>] (dev_ethtool+0x760/0x1f68)
[<804656a0>] (dev_ethtool+0x0/0x1f68) from [<80474f54>] (dev_ioctl+0x498/0x86c)
[<80474abc>] (dev_ioctl+0x0/0x86c) from [<80449c18>] (sock_ioctl+0x84/0x258)
[<80449b94>] (sock_ioctl+0x0/0x258) from [<800e6d10>] (do_vfs_ioctl+0x84/0x5e0)
 r6:00000003 r5:be6b0600 r4:00008946 r3:80449b94
[<800e6c8c>] (do_vfs_ioctl+0x0/0x5e0) from [<800e72ac>] (SyS_ioctl+0x40/0x68)
[<800e726c>] (SyS_ioctl+0x0/0x68) from [<8000ea20>] (ret_fast_syscall+0x0/0x48)
 r8:8000ebe4 r7:00000036 r6:0002bcc8 r5:00000000 r4:0002bd0c
Code: bad PC value
---[ end trace 59379e9bf8fc8437 ]---

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/igb/e1000_i210.c | 46 +++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 0c03933..e4492fd 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -455,6 +455,46 @@ static s32 igb_read_invm_i210(struct e1000_hw *hw, u16 offset,
 }
 
 /**
+ *  igb_write_invm_i210 - Write invm stub function for I210/I211
+ *  @hw: pointer to the HW structure
+ *  @offset: offset within the iNVM to be written to
+ *  @words: number of words to write
+ *  @data: 16 bit word(s) to be written to the iNVM
+ *
+ *  This is just a stub for unimplemented function.
+ **/
+static s32 igb_write_invm_i210(struct e1000_hw *hw, u16 offset, u16 words,
+			       u16 *data)
+{
+	/* Unimplemented. */
+	return E1000_ERR_NVM;
+}
+
+/**
+ *  igb_validate_invm_checksum_i210 - Validate EEPROM checksum
+ *  @hw: pointer to the HW structure
+ *
+ *  This is just a stub for unimplemented function.
+ **/
+s32 igb_validate_invm_checksum_i210(struct e1000_hw *hw)
+{
+	/* Unimplemented. */
+	return E1000_ERR_NVM;
+}
+
+/**
+ *  igb_update_invm_checksum_i210 - Update EEPROM checksum
+ *  @hw: pointer to the HW structure
+ *
+ *  This is just a stub for unimplemented function.
+ **/
+s32 igb_update_invm_checksum_i210(struct e1000_hw *hw)
+{
+	/* Unimplemented. */
+	return E1000_ERR_NVM;
+}
+
+/**
  *  igb_read_invm_version - Reads iNVM version and image type
  *  @hw: pointer to the HW structure
  *  @invm_ver: version structure for the version read
@@ -829,9 +869,9 @@ s32 igb_init_nvm_params_i210(struct e1000_hw *hw)
 	} else {
 		hw->nvm.type = e1000_nvm_invm;
 		nvm->ops.read     = igb_read_invm_i210;
-		nvm->ops.write    = NULL;
-		nvm->ops.validate = NULL;
-		nvm->ops.update   = NULL;
+		nvm->ops.write    = igb_write_invm_i210;
+		nvm->ops.validate = igb_validate_invm_checksum_i210;
+		nvm->ops.update   = igb_update_invm_checksum_i210;
 	}
 	return ret_val;
 }
-- 
1.8.4.rc3
