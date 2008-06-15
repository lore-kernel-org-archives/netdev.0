From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] firmware: convert e100 driver to request_firmware()
Date: Sun, 15 Jun 2008 10:42:46 +0100
Message-ID: <1213522966.26255.433.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jaswinder Singh <jaswinderlinux@gmail.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49186 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761AbYFOJmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 05:42:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jaswinder Singh <jaswinderlinux@gmail.com>

Thanks to David Woodhouse for help.

Signed-off-by: Jaswinder Singh <jaswinderlinux@gmail.com>
Signed-off-by: David Woodhouse <dwmw2@infradead.org>
---
We have assumed that in the no-=C2=B5code case, there's no actual _reas=
on_
for the cb_nop command which e100_setup_ucode() was sending; it's just
that there was no way for it to simply refrain from sending a command,
since it returns void.

Abusing the skb parameter for e100_exec_cb() isn't massively pretty, bu=
t
it should work. We could always add a struct firmware * into 'struct
nic' if people really object.

And finally, we've assumed that aborting is the correct thing to do whe=
n
the =C2=B5code can't be loaded. Should we instead just complain and mov=
e on?=20

 drivers/net/Kconfig                |    8 +
 drivers/net/e100.c                 |  283 +++++++++++-----------------=
--------
 firmware/Makefile                  |    2 +
 firmware/WHENCE                    |   12 ++
 firmware/e100/d101m_ucode.bin.ihex |   38 +++++
 firmware/e100/d101s_ucode.bin.ihex |   38 +++++
 firmware/e100/d102e_ucode.bin.ihex |   38 +++++
 7 files changed, 222 insertions(+), 197 deletions(-)
 create mode 100644 firmware/e100/d101m_ucode.bin.ihex
 create mode 100644 firmware/e100/d101s_ucode.bin.ihex
 create mode 100644 firmware/e100/d102e_ucode.bin.ihex

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd0ec9e..d040b7b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1443,6 +1443,7 @@ config E100
 	tristate "Intel(R) PRO/100+ support"
 	depends on NET_PCI && PCI
 	select MII
+	select FW_LOADER
 	---help---
 	  This driver supports Intel(R) PRO/100 family of adapters.
 	  To verify that your adapter is supported, find the board ID number=20
@@ -1465,6 +1466,13 @@ config E100
 	  To compile this driver as a module, choose M here. The module
 	  will be called e100.
=20
+config E100_FIRMWARE
+	bool "Include firmware for Intel(R) PRO/100+"
+	depends on E100
+	---help---
+	  This includes firmware for the Intel(R) PRO/100 family of adapters.
+	  Say 'N' and let it get loaded from userspace on demand.
+
 config LNE390
 	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
 	depends on NET_PCI && EISA && EXPERIMENTAL
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index f3cba5e..ec8fb09 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -161,6 +161,7 @@
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/string.h>
+#include <linux/firmware.h>
 #include <asm/unaligned.h>
=20
=20
@@ -178,6 +179,9 @@ MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
+MODULE_FIRMWARE("e100/d101m_ucode.bin");
+MODULE_FIRMWARE("e100/d101s_ucode.bin");
+MODULE_FIRMWARE("e100/d102e_ucode.bin");
=20
 static int debug =3D 3;
 static int eeprom_bad_csum_allow =3D 0;
@@ -1049,178 +1053,6 @@ static void e100_configure(struct nic *nic, str=
uct cb *cb, struct sk_buff *skb)
 		c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
 }
=20
-/********************************************************/
-/*  Micro code for 8086:1229 Rev 8                      */
-/********************************************************/
-
-/*  Parameter values for the D101M B-step  */
-#define D101M_CPUSAVER_TIMER_DWORD		78
-#define D101M_CPUSAVER_BUNDLE_DWORD		65
-#define D101M_CPUSAVER_MIN_SIZE_DWORD		126
-
-#define D101M_B_RCVBUNDLE_UCODE \
-{\
-0x00550215, 0xFFFF0437, 0xFFFFFFFF, 0x06A70789, 0xFFFFFFFF, 0x0558FFFF=
, \
-0x000C0001, 0x00101312, 0x000C0008, 0x00380216, \
-0x0010009C, 0x00204056, 0x002380CC, 0x00380056, \
-0x0010009C, 0x00244C0B, 0x00000800, 0x00124818, \
-0x00380438, 0x00000000, 0x00140000, 0x00380555, \
-0x00308000, 0x00100662, 0x00100561, 0x000E0408, \
-0x00134861, 0x000C0002, 0x00103093, 0x00308000, \
-0x00100624, 0x00100561, 0x000E0408, 0x00100861, \
-0x000C007E, 0x00222C21, 0x000C0002, 0x00103093, \
-0x00380C7A, 0x00080000, 0x00103090, 0x00380C7A, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x0010009C, 0x00244C2D, 0x00010004, 0x00041000, \
-0x003A0437, 0x00044010, 0x0038078A, 0x00000000, \
-0x00100099, 0x00206C7A, 0x0010009C, 0x00244C48, \
-0x00130824, 0x000C0001, 0x00101213, 0x00260C75, \
-0x00041000, 0x00010004, 0x00130826, 0x000C0006, \
-0x002206A8, 0x0013C926, 0x00101313, 0x003806A8, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00080600, 0x00101B10, 0x00050004, 0x00100826, \
-0x00101210, 0x00380C34, 0x00000000, 0x00000000, \
-0x0021155B, 0x00100099, 0x00206559, 0x0010009C, \
-0x00244559, 0x00130836, 0x000C0000, 0x00220C62, \
-0x000C0001, 0x00101B13, 0x00229C0E, 0x00210C0E, \
-0x00226C0E, 0x00216C0E, 0x0022FC0E, 0x00215C0E, \
-0x00214C0E, 0x00380555, 0x00010004, 0x00041000, \
-0x00278C67, 0x00040800, 0x00018100, 0x003A0437, \
-0x00130826, 0x000C0001, 0x00220559, 0x00101313, \
-0x00380559, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00130831, 0x0010090B, 0x00124813, \
-0x000CFF80, 0x002606AB, 0x00041000, 0x00010004, \
-0x003806A8, 0x00000000, 0x00000000, 0x00000000, \
-}
-
-/********************************************************/
-/*  Micro code for 8086:1229 Rev 9                      */
-/********************************************************/
-
-/*  Parameter values for the D101S  */
-#define D101S_CPUSAVER_TIMER_DWORD		78
-#define D101S_CPUSAVER_BUNDLE_DWORD		67
-#define D101S_CPUSAVER_MIN_SIZE_DWORD		128
-
-#define D101S_RCVBUNDLE_UCODE \
-{\
-0x00550242, 0xFFFF047E, 0xFFFFFFFF, 0x06FF0818, 0xFFFFFFFF, 0x05A6FFFF=
, \
-0x000C0001, 0x00101312, 0x000C0008, 0x00380243, \
-0x0010009C, 0x00204056, 0x002380D0, 0x00380056, \
-0x0010009C, 0x00244F8B, 0x00000800, 0x00124818, \
-0x0038047F, 0x00000000, 0x00140000, 0x003805A3, \
-0x00308000, 0x00100610, 0x00100561, 0x000E0408, \
-0x00134861, 0x000C0002, 0x00103093, 0x00308000, \
-0x00100624, 0x00100561, 0x000E0408, 0x00100861, \
-0x000C007E, 0x00222FA1, 0x000C0002, 0x00103093, \
-0x00380F90, 0x00080000, 0x00103090, 0x00380F90, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x0010009C, 0x00244FAD, 0x00010004, 0x00041000, \
-0x003A047E, 0x00044010, 0x00380819, 0x00000000, \
-0x00100099, 0x00206FFD, 0x0010009A, 0x0020AFFD, \
-0x0010009C, 0x00244FC8, 0x00130824, 0x000C0001, \
-0x00101213, 0x00260FF7, 0x00041000, 0x00010004, \
-0x00130826, 0x000C0006, 0x00220700, 0x0013C926, \
-0x00101313, 0x00380700, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00080600, 0x00101B10, 0x00050004, 0x00100826, \
-0x00101210, 0x00380FB6, 0x00000000, 0x00000000, \
-0x002115A9, 0x00100099, 0x002065A7, 0x0010009A, \
-0x0020A5A7, 0x0010009C, 0x002445A7, 0x00130836, \
-0x000C0000, 0x00220FE4, 0x000C0001, 0x00101B13, \
-0x00229F8E, 0x00210F8E, 0x00226F8E, 0x00216F8E, \
-0x0022FF8E, 0x00215F8E, 0x00214F8E, 0x003805A3, \
-0x00010004, 0x00041000, 0x00278FE9, 0x00040800, \
-0x00018100, 0x003A047E, 0x00130826, 0x000C0001, \
-0x002205A7, 0x00101313, 0x003805A7, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00130831, \
-0x0010090B, 0x00124813, 0x000CFF80, 0x00260703, \
-0x00041000, 0x00010004, 0x00380700  \
-}
-
-/********************************************************/
-/*  Micro code for the 8086:1229 Rev F/10               */
-/********************************************************/
-
-/*  Parameter values for the D102 E-step  */
-#define D102_E_CPUSAVER_TIMER_DWORD		42
-#define D102_E_CPUSAVER_BUNDLE_DWORD		54
-#define D102_E_CPUSAVER_MIN_SIZE_DWORD		46
-
-#define     D102_E_RCVBUNDLE_UCODE \
-{\
-0x007D028F, 0x0E4204F9, 0x14ED0C85, 0x14FA14E9, 0x0EF70E36, 0x1FFF1FFF=
, \
-0x00E014B9, 0x00000000, 0x00000000, 0x00000000, \
-0x00E014BD, 0x00000000, 0x00000000, 0x00000000, \
-0x00E014D5, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00E014C1, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00E014C8, 0x00000000, 0x00000000, 0x00000000, \
-0x00200600, 0x00E014EE, 0x00000000, 0x00000000, \
-0x0030FF80, 0x00940E46, 0x00038200, 0x00102000, \
-0x00E00E43, 0x00000000, 0x00000000, 0x00000000, \
-0x00300006, 0x00E014FB, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00906E41, 0x00800E3C, 0x00E00E39, 0x00000000, \
-0x00906EFD, 0x00900EFD, 0x00E00EF8, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-0x00000000, 0x00000000, 0x00000000, 0x00000000, \
-}
-
-static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk=
_buff *skb)
-{
-/* *INDENT-OFF* */
-	static struct {
-		u32 ucode[UCODE_SIZE + 1];
-		u8 mac;
-		u8 timer_dword;
-		u8 bundle_dword;
-		u8 min_size_dword;
-	} ucode_opts[] =3D {
-		{ D101M_B_RCVBUNDLE_UCODE,
-		  mac_82559_D101M,
-		  D101M_CPUSAVER_TIMER_DWORD,
-		  D101M_CPUSAVER_BUNDLE_DWORD,
-		  D101M_CPUSAVER_MIN_SIZE_DWORD },
-		{ D101S_RCVBUNDLE_UCODE,
-		  mac_82559_D101S,
-		  D101S_CPUSAVER_TIMER_DWORD,
-		  D101S_CPUSAVER_BUNDLE_DWORD,
-		  D101S_CPUSAVER_MIN_SIZE_DWORD },
-		{ D102_E_RCVBUNDLE_UCODE,
-		  mac_82551_F,
-		  D102_E_CPUSAVER_TIMER_DWORD,
-		  D102_E_CPUSAVER_BUNDLE_DWORD,
-		  D102_E_CPUSAVER_MIN_SIZE_DWORD },
-		{ D102_E_RCVBUNDLE_UCODE,
-		  mac_82551_10,
-		  D102_E_CPUSAVER_TIMER_DWORD,
-		  D102_E_CPUSAVER_BUNDLE_DWORD,
-		  D102_E_CPUSAVER_MIN_SIZE_DWORD },
-		{ {0}, 0, 0, 0, 0}
-	}, *opts;
-/* *INDENT-ON* */
-
 /*********************************************************************=
****
 *  CPUSaver parameters
 *
@@ -1280,42 +1112,99 @@ static void e100_setup_ucode(struct nic *nic, s=
truct cb *cb, struct sk_buff *skb
 #define BUNDLEMAX (u16)6
 #define INTDELAY (u16)1536 /* 0x600 */
=20
+static const struct firmware *e100_request_firmware(struct nic *nic)
+{
+	const char *fw_name;
+	const struct firmware *fw;
+	u8 timer, bundle, min_size;
+	int err;
+
 	/* do not load u-code for ICH devices */
 	if (nic->flags & ich)
-		goto noloaducode;
+		return NULL;
=20
 	/* Search for ucode match against h/w revision */
-	for (opts =3D ucode_opts; opts->mac; opts++) {
-		int i;
-		u32 *ucode =3D opts->ucode;
-		if (nic->mac !=3D opts->mac)
-			continue;
-
-		/* Insert user-tunable settings */
-		ucode[opts->timer_dword] &=3D 0xFFFF0000;
-		ucode[opts->timer_dword] |=3D INTDELAY;
-		ucode[opts->bundle_dword] &=3D 0xFFFF0000;
-		ucode[opts->bundle_dword] |=3D BUNDLEMAX;
-		ucode[opts->min_size_dword] &=3D 0xFFFF0000;
-		ucode[opts->min_size_dword] |=3D (BUNDLESMALL) ? 0xFFFF : 0xFF80;
+	if (nic->mac =3D=3D mac_82559_D101M)
+		fw_name =3D "e100/d101m_ucode.bin";
+	else if (nic->mac =3D=3D mac_82559_D101S)
+		fw_name =3D "e100/d101s_ucode.bin";
+	else if (nic->mac =3D=3D mac_82551_F || nic->mac =3D=3D mac_82551_10)
+		fw_name =3D "e100/d102e_ucode.bin";
+	else /* No ucode on other devices */
+		return NULL;
+
+	err =3D request_firmware(&fw, fw_name, &nic->pdev->dev);
+	if (err) {
+		DPRINTK(PROBE,ERR, "Failed to load firmware \"%s\": %d\n",
+			fw_name, err);
+		return ERR_PTR(err);
+	}
+	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
+	   indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
+	if (fw->size !=3D UCODE_SIZE * 4 + 3) {
+		DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %d\n",
+			fw_name, fw->size);
+		release_firmware(fw);
+		return ERR_PTR(-EINVAL);
+	}
=20
-		for (i =3D 0; i < UCODE_SIZE; i++)
-			cb->u.ucode[i] =3D cpu_to_le32(ucode[i]);
-		cb->command =3D cpu_to_le16(cb_ucode | cb_el);
-		return;
+	/* Read timer, bundle and min_size from end of firmware blob */
+	timer =3D fw->data[UCODE_SIZE * 4];
+	bundle =3D fw->data[UCODE_SIZE * 4 + 1];
+	min_size =3D fw->data[UCODE_SIZE * 4 + 2];
+
+	if (timer >=3D UCODE_SIZE || bundle >=3D UCODE_SIZE ||
+	    min_size >=3D UCODE_SIZE) {
+		DPRINTK(PROBE,ERR, "Firmware \"%s\" has bogus offset values (0x%x,0x=
%x,0x%x)\n",
+			fw_name, timer, bundle, min_size);
+		release_firmware(fw);
+		return ERR_PTR(-EINVAL);
 	}
+	/* OK, firmware is validated and ready to use... */
+	return fw;
+}
+
+static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk=
_buff *skb)
+{
+	const struct firmware *fw =3D (void *)skb;
+	u8 timer, bundle, min_size;
+
+	/* It's not a real skb; we just abused the fact that e100_exec_cb
+	   will pass it through to here... */
+	cb->skb =3D NULL;
+
+	/* firmware is stored as little endian already */
+	memcpy(cb->u.ucode, fw->data, UCODE_SIZE * 4);
=20
-noloaducode:
-	cb->command =3D cpu_to_le16(cb_nop | cb_el);
+	/* Read timer, bundle and min_size from end of firmware blob */
+	timer =3D fw->data[UCODE_SIZE * 4];
+	bundle =3D fw->data[UCODE_SIZE * 4 + 1];
+	min_size =3D fw->data[UCODE_SIZE * 4 + 2];
+
+	/* Insert user-tunable settings in cb->u.ucode */
+	cb->u.ucode[timer] &=3D cpu_to_le32(0xFFFF0000);
+	cb->u.ucode[timer] |=3D cpu_to_le32(INTDELAY);
+	cb->u.ucode[bundle] &=3D cpu_to_le32(0xFFFF0000);
+	cb->u.ucode[bundle] |=3D cpu_to_le32(BUNDLEMAX);
+	cb->u.ucode[min_size] &=3D cpu_to_le32(0xFFFF0000);
+	cb->u.ucode[min_size] |=3D cpu_to_le32((BUNDLESMALL) ? 0xFFFF : 0xFF8=
0);
+
+	cb->command =3D cpu_to_le16(cb_ucode | cb_el);
 }
=20
-static inline int e100_exec_cb_wait(struct nic *nic, struct sk_buff *s=
kb,
-	void (*cb_prepare)(struct nic *, struct cb *, struct sk_buff *))
+static inline int e100_load_ucode_wait(struct nic *nic)
 {
+	const struct firmware *fw;
+
 	int err =3D 0, counter =3D 50;
 	struct cb *cb =3D nic->cb_to_clean;
=20
-	if ((err =3D e100_exec_cb(nic, NULL, e100_setup_ucode)))
+	fw =3D e100_request_firmware(nic);
+	/* If it's NULL, then no ucode is required */
+	if (!fw || IS_ERR(fw))
+		return PTR_ERR(fw);
+
+	if ((err =3D e100_exec_cb(nic, (void *)fw, e100_setup_ucode)))
 		DPRINTK(PROBE,ERR, "ucode cmd failed with error %d\n", err);
=20
 	/* must restart cuc */
@@ -1435,7 +1324,7 @@ static int e100_hw_init(struct nic *nic)
 		return err;
 	if((err =3D e100_exec_cmd(nic, ruc_load_base, 0)))
 		return err;
-	if ((err =3D e100_exec_cb_wait(nic, NULL, e100_setup_ucode)))
+	if ((err =3D e100_load_ucode_wait(nic)))
 		return err;
 	if((err =3D e100_exec_cb(nic, NULL, e100_configure)))
 		return err;
diff --git a/firmware/Makefile b/firmware/Makefile
index 0266044..b7802a9 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -18,6 +18,8 @@ fw-shipped-$(CONFIG_USB_KAWETH_FIRMWARE) +=3D kaweth/=
new_code.bin \
 		kaweth/new_code_fix.bin kaweth/trigger_code.bin \
 		kaweth/trigger_code_fix.bin
 fw-shipped-$(CONFIG_DVB_TTUSB_BUDGET_FIRMWARE) +=3D ttusb-budget/dspbo=
otcode.bin
+fw-shipped-$(CONFIG_E100_FIRMWARE) +=3D e100/d101m_ucode.bin \
+		e100/d101s_ucode.bin e100/d102e_ucode.bin
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_MPR) +=3D keyspan/mpr.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA18X) +=3D keyspan/usa18x.fw
 fw-shipped-$(CONFIG_USB_SERIAL_KEYSPAN_USA19) +=3D keyspan/usa19.fw
diff --git a/firmware/WHENCE b/firmware/WHENCE
index 3072854..1dbf017 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -236,3 +236,15 @@ Licence: Unknown
 Found in hex form in kernel source.
=20
 ----------------------------------------------------------------------=
----
+
+Driver: e100 -- Intel PRO/100 Ethernet NIC
+
+File: e100/d101m_ucode.bin
+File: e100/d101s_ucode.bin
+File: e100/d102e_ucode.bin
+
+Licence: Unknown
+
+Found in hex form in kernel source.
+
+----------------------------------------------------------------------=
----
diff --git a/firmware/e100/d101m_ucode.bin.ihex b/firmware/e100/d101m_u=
code.bin.ihex
new file mode 100644
index 0000000..12971ed
--- /dev/null
+++ b/firmware/e100/d101m_ucode.bin.ihex
@@ -0,0 +1,38 @@
+:10000000150255003704FFFFFFFFFFFF8907A70612
+:10001000FFFFFFFFFFFF580501000C001213100047
+:1000200008000C00160238009C001000564020000A
+:10003000CC802300560038009C0010000B4C24009C
+:1000400000080000184812003804380000000000C2
+:1000500000001400550538000080300062061000D2
+:100060006105100008040E006148130002000C0036
+:10007000933010000080300024061000610510004D
+:1000800008040E00610810007E000C00212C2200E4
+:1000900002000C00933010007A0C380000000800B9
+:1000A000903010007A0C38000000000000000000C2
+:1000B00000000000000000009C0010002D4C2400F7
+:1000C000040001000010040037043A00104004004E
+:1000D0008A07380000000000990010007A6C2000A8
+:1000E0009C001000484C24002408130001000C0060
+:1000F00013121000750C260000100400040001000B
+:100100002608130006000C00A806220026C91300CA
+:1001100013131000A80638000000000000000000C3
+:1001200000000000000000000000000000000000CF
+:10013000000000000000000000060800101B100076
+:10014000040005002608100010121000340C3800BE
+:1001500000000000000000005B1521009900100065
+:10016000596520009C0010005945240036081300F2
+:1001700000000C00620C220001000C00131B100098
+:100180000E9C22000E0C21000E6C22000E6C210031
+:100190000EFC22000E5C21000E4C2100550538009B
+:1001A0000400010000100400678C27000008040010
+:1001B0000081010037043A002608130001000C00FA
+:1001C00059052200131310005905380000000000E3
+:1001D000000000000000000000000000000000001F
+:1001E00000000000000000000000000031081300C3
+:1001F0000B0910001348120080FF0C00AB0626000C
+:100200000010040004000100A806380000000000EF
+:0B02100000000000000000004E417ED6
+:00000001FF
+/********************************************************/
+/*  Micro code for 8086:1229 Rev 8                      */
+/********************************************************/
diff --git a/firmware/e100/d101s_ucode.bin.ihex b/firmware/e100/d101s_u=
code.bin.ihex
new file mode 100644
index 0000000..102c7fe
--- /dev/null
+++ b/firmware/e100/d101s_ucode.bin.ihex
@@ -0,0 +1,38 @@
+:10000000420255007E04FFFFFFFFFFFF1808FF06B6
+:10001000FFFFFFFFFFFFA60501000C0012131000F9
+:1000200008000C00430238009C00100056402000DD
+:10003000D0802300560038009C0010008B4F240015
+:1000400000080000184812007F043800000000007B
+:1000500000001400A30538000080300010061000D6
+:100060006105100008040E006148130002000C0036
+:10007000933010000080300024061000610510004D
+:1000800008040E00610810007E000C00A12F220061
+:1000900002000C0093301000900F380000000800A0
+:1000A00090301000900F38000000000000000000A9
+:1000B00000000000000000009C001000AD4F240074
+:1000C00004000100001004007E043A001040040007
+:1000D000190838000000000099001000FD6F200092
+:1000E0009A001000FDAF20009C001000C84F2400B3
+:1000F0002408130001000C0013121000F70F260053
+:1001000000100400040001002608130006000C0083
+:100110000007220026C9130013131000000738003F
+:1001200000000000000000000000000000000000CF
+:10013000000000000000000000060800101B100076
+:10014000040005002608100010121000B60F380039
+:100150000000000000000000A91521009900100017
+:10016000A76520009A001000A7A520009C001000A1
+:10017000A74524003608130000000C00E40F2200FD
+:1001800001000C00131B10008E9F22008E0F210017
+:100190008E6F22008E6F21008EFF22008E5F210065
+:1001A0008E4F2100A3053800040001000010040058
+:1001B000E98F270000080400008101007E043A0056
+:1001C0002608130001000C00A705220013131000DD
+:1001D000A70538000000000000000000000000003B
+:1001E000000000000000000000000000000000000F
+:1001F00000000000310813000B0910001348120022
+:1002000080FF0C000307260000100400040001001A
+:0B02100000073800000000004E438093
+:00000001FF
+/********************************************************/
+/*  Micro code for 8086:1229 Rev 9                      */
+/********************************************************/
diff --git a/firmware/e100/d102e_ucode.bin.ihex b/firmware/e100/d102e_u=
code.bin.ihex
new file mode 100644
index 0000000..9e806da
--- /dev/null
+++ b/firmware/e100/d102e_ucode.bin.ihex
@@ -0,0 +1,38 @@
+:100000008F027D00F904420E850CED14E914FA14F8
+:10001000360EF70EFF1FFF1FB914E00000000000AE
+:100020000000000000000000BD14E000000000001F
+:100030000000000000000000D514E00000000000F7
+:1000400000000000000000000000000000000000B0
+:100050000000000000000000C114E00000000000EB
+:100060000000000000000000000000000000000090
+:100070000000000000000000000000000000000080
+:100080000000000000000000000000000000000070
+:100090000000000000000000C814E00000000000A4
+:1000A000000000000000000000062000EE14E00048
+:1000B000000000000000000080FF3000460E9400A9
+:1000C0000082030000201000430EE000000000004A
+:1000D000000000000000000006003000FB14E000FB
+:1000E0000000000000000000000000000000000010
+:1000F0000000000000000000000000000000000000
+:1001000000000000000000000000000000000000EF
+:100110000000000000000000416E90003C0E8000D6
+:10012000390EE00000000000FD6E9000FD0E900012
+:10013000F80EE000000000000000000000000000D9
+:1001400000000000000000000000000000000000AF
+:10015000000000000000000000000000000000009F
+:10016000000000000000000000000000000000008F
+:10017000000000000000000000000000000000007F
+:10018000000000000000000000000000000000006F
+:10019000000000000000000000000000000000005F
+:1001A000000000000000000000000000000000004F
+:1001B000000000000000000000000000000000003F
+:1001C000000000000000000000000000000000002F
+:1001D000000000000000000000000000000000001F
+:1001E000000000000000000000000000000000000F
+:1001F00000000000000000000000000000000000FF
+:1002000000000000000000000000000000000000EE
+:0B02100000000000000000002A362E55
+:00000001FF
+/********************************************************/
+/*  Micro code for the 8086:1229 Rev F/10               */
+/********************************************************/
--=20
1.5.5.1


--=20
dwmw2

