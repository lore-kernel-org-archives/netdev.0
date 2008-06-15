From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert e100 driver to
	request_firmware()
Date: Sun, 15 Jun 2008 23:09:35 +0100
Message-ID: <1213567775.26255.534.camel@pmac.infradead.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>
	<48555677.7040209@garzik.org>
	<3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>
	<485562F8.2000400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jaswinder Singh <jaswinderlinux@gmail.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <485562F8.2000400@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2008-06-15 at 14:44 -0400, Jeff Garzik wrote:
> Each driver is _intimately_ tied to its firmware, so it only increases
> headaches by separating two pieces of a single, cohesive whole.

On reflection, that argument _does_ make me inclined to modify my
approach.

The _only_ thing that lets us justify the inclusion of this firmware
blob in the kernel in the first place is the rather tenuous claim that
it is "mere aggregation on a volume of a storage or distribution medium"
-- as if it's just some kind of coincidence that these two pieces of
work happen to be shipped together.

If they really are "intimately tied pieces of a single, cohesive whole",
as you say, then the claim that it's "mere aggregation on a volume of a
storage or distribution medium" loses whatever small amount of
credibility it had in the first place, and we have no option but to
remove the offending part immediately.

Revised patch follows....

 drivers/net/Kconfig |    1 
 drivers/net/e100.c  |  281 +++++++++++++++-------------------------------------
 2 files changed, 86 insertions(+), 196 deletions(-)

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
 	  To verify that your adapter is supported, find the board ID number 
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
 
 
@@ -178,6 +179,9 @@ MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
+MODULE_FIRMWARE("e100/d101m_ucode.bin");
+MODULE_FIRMWARE("e100/d101s_ucode.bin");
+MODULE_FIRMWARE("e100/d102e_ucode.bin");
 
 static int debug = 3;
 static int eeprom_bad_csum_allow = 0;
@@ -1049,178 +1053,6 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
 }
 
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
-0x00550215, 0xFFFF0437, 0xFFFFFFFF, 0x06A70789, 0xFFFFFFFF, 0x0558FFFF, \
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
-0x00550242, 0xFFFF047E, 0xFFFFFFFF, 0x06FF0818, 0xFFFFFFFF, 0x05A6FFFF, \
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
-0x007D028F, 0x0E4204F9, 0x14ED0C85, 0x14FA14E9, 0x0EF70E36, 0x1FFF1FFF, \
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
-static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk_buff *skb)
-{
-/* *INDENT-OFF* */
-	static struct {
-		u32 ucode[UCODE_SIZE + 1];
-		u8 mac;
-		u8 timer_dword;
-		u8 bundle_dword;
-		u8 min_size_dword;
-	} ucode_opts[] = {
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
 /*************************************************************************
 *  CPUSaver parameters
 *
@@ -1280,42 +1112,99 @@ static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk_buff *skb
 #define BUNDLEMAX (u16)6
 #define INTDELAY (u16)1536 /* 0x600 */
 
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
 
 	/* Search for ucode match against h/w revision */
-	for (opts = ucode_opts; opts->mac; opts++) {
-		int i;
-		u32 *ucode = opts->ucode;
-		if (nic->mac != opts->mac)
-			continue;
-
-		/* Insert user-tunable settings */
-		ucode[opts->timer_dword] &= 0xFFFF0000;
-		ucode[opts->timer_dword] |= INTDELAY;
-		ucode[opts->bundle_dword] &= 0xFFFF0000;
-		ucode[opts->bundle_dword] |= BUNDLEMAX;
-		ucode[opts->min_size_dword] &= 0xFFFF0000;
-		ucode[opts->min_size_dword] |= (BUNDLESMALL) ? 0xFFFF : 0xFF80;
+	if (nic->mac == mac_82559_D101M)
+		fw_name = "e100/d101m_ucode.bin";
+	else if (nic->mac == mac_82559_D101S)
+		fw_name = "e100/d101s_ucode.bin";
+	else if (nic->mac == mac_82551_F || nic->mac == mac_82551_10)
+		fw_name = "e100/d102e_ucode.bin";
+	else /* No ucode on other devices */
+		return NULL;
+
+	err = request_firmware(&fw, fw_name, &nic->pdev->dev);
+	if (err) {
+		DPRINTK(PROBE,ERR, "Failed to load firmware \"%s\": %d\n",
+			fw_name, err);
+		return ERR_PTR(err);
+	}
+	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
+	   indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
+	if (fw->size != UCODE_SIZE * 4 + 3) {
+		DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %d\n",
+			fw_name, fw->size);
+		release_firmware(fw);
+		return ERR_PTR(-EINVAL);
+	}
 
-		for (i = 0; i < UCODE_SIZE; i++)
-			cb->u.ucode[i] = cpu_to_le32(ucode[i]);
-		cb->command = cpu_to_le16(cb_ucode | cb_el);
-		return;
+	/* Read timer, bundle and min_size from end of firmware blob */
+	timer = fw->data[UCODE_SIZE * 4];
+	bundle = fw->data[UCODE_SIZE * 4 + 1];
+	min_size = fw->data[UCODE_SIZE * 4 + 2];
+
+	if (timer >= UCODE_SIZE || bundle >= UCODE_SIZE ||
+	    min_size >= UCODE_SIZE) {
+		DPRINTK(PROBE,ERR, "Firmware \"%s\" has bogus offset values (0x%x,0x%x,0x%x)\n",
+			fw_name, timer, bundle, min_size);
+		release_firmware(fw);
+		return ERR_PTR(-EINVAL);
 	}
+	/* OK, firmware is validated and ready to use... */
+	return fw;
+}
+
+static void e100_setup_ucode(struct nic *nic, struct cb *cb, struct sk_buff *skb)
+{
+	const struct firmware *fw = (void *)skb;
+	u8 timer, bundle, min_size;
+
+	/* It's not a real skb; we just abused the fact that e100_exec_cb
+	   will pass it through to here... */
+	cb->skb = NULL;
+
+	/* firmware is stored as little endian already */
+	memcpy(cb->u.ucode, fw->data, UCODE_SIZE * 4);
 
-noloaducode:
-	cb->command = cpu_to_le16(cb_nop | cb_el);
+	/* Read timer, bundle and min_size from end of firmware blob */
+	timer = fw->data[UCODE_SIZE * 4];
+	bundle = fw->data[UCODE_SIZE * 4 + 1];
+	min_size = fw->data[UCODE_SIZE * 4 + 2];
+
+	/* Insert user-tunable settings in cb->u.ucode */
+	cb->u.ucode[timer] &= cpu_to_le32(0xFFFF0000);
+	cb->u.ucode[timer] |= cpu_to_le32(INTDELAY);
+	cb->u.ucode[bundle] &= cpu_to_le32(0xFFFF0000);
+	cb->u.ucode[bundle] |= cpu_to_le32(BUNDLEMAX);
+	cb->u.ucode[min_size] &= cpu_to_le32(0xFFFF0000);
+	cb->u.ucode[min_size] |= cpu_to_le32((BUNDLESMALL) ? 0xFFFF : 0xFF80);
+
+	cb->command = cpu_to_le16(cb_ucode | cb_el);
 }
 
-static inline int e100_exec_cb_wait(struct nic *nic, struct sk_buff *skb,
-	void (*cb_prepare)(struct nic *, struct cb *, struct sk_buff *))
+static inline int e100_load_ucode_wait(struct nic *nic)
 {
+	const struct firmware *fw;
+
 	int err = 0, counter = 50;
 	struct cb *cb = nic->cb_to_clean;
 
-	if ((err = e100_exec_cb(nic, NULL, e100_setup_ucode)))
+	fw = e100_request_firmware(nic);
+	/* If it's NULL, then no ucode is required */
+	if (!fw || IS_ERR(fw))
+		return PTR_ERR(fw);
+
+	if ((err = e100_exec_cb(nic, (void *)fw, e100_setup_ucode)))
 		DPRINTK(PROBE,ERR, "ucode cmd failed with error %d\n", err);
 
 	/* must restart cuc */
@@ -1435,7 +1324,7 @@ static int e100_hw_init(struct nic *nic)
 		return err;
 	if((err = e100_exec_cmd(nic, ruc_load_base, 0)))
 		return err;
-	if ((err = e100_exec_cb_wait(nic, NULL, e100_setup_ucode)))
+	if ((err = e100_load_ucode_wait(nic)))
 		return err;
 	if((err = e100_exec_cb(nic, NULL, e100_configure)))
 		return err;
diff --git a/firmware/Makefile b/firmware/Makefile
index 0266044..b7802a9 100644

-- 
dwmw2


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
