From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] firmware: convert tg3 driver to request_firmware()
Date: Wed, 18 Jun 2008 16:16:52 +0100
Message-ID: <1213802212.26255.1271.camel@pmac.infradead.org>
References: <1213799313.4794.20.camel@fc6.satnam>
	 <48592192.6060501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jaswinder Singh <jaswinder@infradead.org>,
	kernelnewbies@nl.linux.org, kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40307 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbYFRPRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 11:17:05 -0400
In-Reply-To: <48592192.6060501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-18 at 10:54 -0400, Jeff Garzik wrote:
> It just makes the patch longer and more difficult to read and review 
> with the two separate changes mushed together.  Having separate patches 
> also means it is easier to test and validate the loadable firmware approach.

In this _particular_ case, because the big hex arrays were directly in
tg3.c and not a header file, it might be a little easier to review the
code changes for correctness if we post a cut-down patch which doesn't
actually _remove_ the hex arrays, but instead just leaves them present
but unused. That cut-down patch is below.

It still doesn't make sense to add a completely _new_ code path for
loading firmware by request_firmware() though; that would just have to
add new functions to parallel with each function touched by patch below,
and it would be much harder to read the patch and actually see what's
changing.

This is the patch we're seeking constructive review of:

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07b3f77..a70147d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -38,6 +38,7 @@
 #include <linux/workqueue.h>
 #include <linux/prefetch.h>
 #include <linux/dma-mapping.h>
+#include <linux/firmware.h>
 
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -139,6 +140,9 @@ MODULE_AUTHOR("David S. Miller (davem@redhat.com) and Jeff Garzik (jgarzik@pobox
 MODULE_DESCRIPTION("Broadcom Tigon3 ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
+MODULE_FIRMWARE("tigon/tg3.bin");
+MODULE_FIRMWARE("tigon/tg3_tso.bin");
+MODULE_FIRMWARE("tigon/tg3_tso5.bin");
 
 static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
 module_param(tg3_debug, int, 0);
@@ -5778,15 +5658,9 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
 }
 
 struct fw_info {
-	unsigned int text_base;
-	unsigned int text_len;
-	const u32 *text_data;
-	unsigned int rodata_base;
-	unsigned int rodata_len;
-	const u32 *rodata_data;
-	unsigned int data_base;
-	unsigned int data_len;
-	const u32 *data_data;
+	unsigned int fw_base;
+	unsigned int fw_len;
+	const __be32 *fw_data;
 };
 
 /* tp->lock is held. */
@@ -5823,24 +5697,11 @@ static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base, u32 cpu_scratch_b
 		write_op(tp, cpu_scratch_base + i, 0);
 	tw32(cpu_base + CPU_STATE, 0xffffffff);
 	tw32(cpu_base + CPU_MODE, tr32(cpu_base+CPU_MODE)|CPU_MODE_HALT);
-	for (i = 0; i < (info->text_len / sizeof(u32)); i++)
-		write_op(tp, (cpu_scratch_base +
-			      (info->text_base & 0xffff) +
-			      (i * sizeof(u32))),
-			 (info->text_data ?
-			  info->text_data[i] : 0));
-	for (i = 0; i < (info->rodata_len / sizeof(u32)); i++)
-		write_op(tp, (cpu_scratch_base +
-			      (info->rodata_base & 0xffff) +
-			      (i * sizeof(u32))),
-			 (info->rodata_data ?
-			  info->rodata_data[i] : 0));
-	for (i = 0; i < (info->data_len / sizeof(u32)); i++)
+	for (i = 0; i < (info->fw_len / sizeof(u32)); i++)
 		write_op(tp, (cpu_scratch_base +
-			      (info->data_base & 0xffff) +
+			      (info->fw_base & 0xffff) +
 			      (i * sizeof(u32))),
-			 (info->data_data ?
-			  info->data_data[i] : 0));
+			      be32_to_cpu(info->fw_data[i]));
 
 	err = 0;
 
@@ -5852,17 +5713,20 @@ out:
 static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 {
 	struct fw_info info;
+	const __be32 *fw_data;
 	int err, i;
 
-	info.text_base = TG3_FW_TEXT_ADDR;
-	info.text_len = TG3_FW_TEXT_LEN;
-	info.text_data = &tg3FwText[0];
-	info.rodata_base = TG3_FW_RODATA_ADDR;
-	info.rodata_len = TG3_FW_RODATA_LEN;
-	info.rodata_data = &tg3FwRodata[0];
-	info.data_base = TG3_FW_DATA_ADDR;
-	info.data_len = TG3_FW_DATA_LEN;
-	info.data_data = NULL;
+	fw_data = (void *)tp->fw->data;
+
+	/* Firmware blob starts with version numbers, followed by
+	   start address and length. We are setting complete length.
+	   length = end_address_of_bss - start_address_of_text.
+	   Remainder is the blob to be loaded contiguously
+	   from start address. */
+
+	info.fw_base = be32_to_cpu(fw_data[1]);
+	info.fw_len = tp->fw->size-12;
+	info.fw_data = &fw_data[3];
 
 	err = tg3_load_firmware_cpu(tp, RX_CPU_BASE,
 				    RX_CPU_SCRATCH_BASE, RX_CPU_SCRATCH_SIZE,
@@ -5878,21 +5742,21 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 
 	/* Now startup only the RX cpu. */
 	tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
-	tw32_f(RX_CPU_BASE + CPU_PC,    TG3_FW_TEXT_ADDR);
+	tw32_f(RX_CPU_BASE + CPU_PC,    info.fw_base);
 
 	for (i = 0; i < 5; i++) {
-		if (tr32(RX_CPU_BASE + CPU_PC) == TG3_FW_TEXT_ADDR)
+		if (tr32(RX_CPU_BASE + CPU_PC) == info.fw_base)
 			break;
 		tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
 		tw32(RX_CPU_BASE + CPU_MODE,  CPU_MODE_HALT);
-		tw32_f(RX_CPU_BASE + CPU_PC,    TG3_FW_TEXT_ADDR);
+		tw32_f(RX_CPU_BASE + CPU_PC,    info.fw_base);
 		udelay(1000);
 	}
 	if (i >= 5) {
 		printk(KERN_ERR PFX "tg3_load_firmware fails for %s "
 		       "to set RX CPU PC, is %08x should be %08x\n",
 		       tp->dev->name, tr32(RX_CPU_BASE + CPU_PC),
-		       TG3_FW_TEXT_ADDR);
+		       info.fw_base);
 		return -ENODEV;
 	}
 	tw32(RX_CPU_BASE + CPU_STATE, 0xffffffff);
@@ -5901,41 +5765,32 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 
 /* tp->lock is held. */
 static int tg3_load_tso_firmware(struct tg3 *tp)
 {
 	struct fw_info info;
+	const __be32 *fw_data;
 	unsigned long cpu_base, cpu_scratch_base, cpu_scratch_size;
 	int err, i;
 
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
 		return 0;
 
+	fw_data = (void *)tp->fw->data;
+
+	/* Firmware blob starts with version numbers, followed by
+	   start address and length. We are setting complete length.
+	   length = end_address_of_bss - start_address_of_text.
+	   Remainder is the blob to be loaded contiguously
+	   from start address. */
+
+	info.fw_base = be32_to_cpu(fw_data[1]);
+	cpu_scratch_size = tp->fw_len;
+	info.fw_len = tp->fw->size-12;
+	info.fw_data = &fw_data[3];
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
-		info.text_base = TG3_TSO5_FW_TEXT_ADDR;
-		info.text_len = TG3_TSO5_FW_TEXT_LEN;
-		info.text_data = &tg3Tso5FwText[0];
-		info.rodata_base = TG3_TSO5_FW_RODATA_ADDR;
-		info.rodata_len = TG3_TSO5_FW_RODATA_LEN;
-		info.rodata_data = &tg3Tso5FwRodata[0];
-		info.data_base = TG3_TSO5_FW_DATA_ADDR;
-		info.data_len = TG3_TSO5_FW_DATA_LEN;
-		info.data_data = &tg3Tso5FwData[0];
 		cpu_base = RX_CPU_BASE;
 		cpu_scratch_base = NIC_SRAM_MBUF_POOL_BASE5705;
-		cpu_scratch_size = (info.text_len +
-				    info.rodata_len +
-				    info.data_len +
-				    TG3_TSO5_FW_SBSS_LEN +
-				    TG3_TSO5_FW_BSS_LEN);
 	} else {
-		info.text_base = TG3_TSO_FW_TEXT_ADDR;
-		info.text_len = TG3_TSO_FW_TEXT_LEN;
-		info.text_data = &tg3TsoFwText[0];
-		info.rodata_base = TG3_TSO_FW_RODATA_ADDR;
-		info.rodata_len = TG3_TSO_FW_RODATA_LEN;
-		info.rodata_data = &tg3TsoFwRodata[0];
-		info.data_base = TG3_TSO_FW_DATA_ADDR;
-		info.data_len = TG3_TSO_FW_DATA_LEN;
-		info.data_data = &tg3TsoFwData[0];
 		cpu_base = TX_CPU_BASE;
 		cpu_scratch_base = TX_CPU_SCRATCH_BASE;
 		cpu_scratch_size = TX_CPU_SCRATCH_SIZE;
@@ -6455,21 +5808,21 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 
 	/* Now startup the cpu. */
 	tw32(cpu_base + CPU_STATE, 0xffffffff);
-	tw32_f(cpu_base + CPU_PC,    info.text_base);
+	tw32_f(cpu_base + CPU_PC,    info.fw_base);
 
 	for (i = 0; i < 5; i++) {
-		if (tr32(cpu_base + CPU_PC) == info.text_base)
+		if (tr32(cpu_base + CPU_PC) == info.fw_base)
 			break;
 		tw32(cpu_base + CPU_STATE, 0xffffffff);
 		tw32(cpu_base + CPU_MODE,  CPU_MODE_HALT);
-		tw32_f(cpu_base + CPU_PC,    info.text_base);
+		tw32_f(cpu_base + CPU_PC,    info.fw_base);
 		udelay(1000);
 	}
 	if (i >= 5) {
 		printk(KERN_ERR PFX "tg3_load_tso_firmware fails for %s "
 		       "to set CPU PC, is %08x should be %08x\n",
 		       tp->dev->name, tr32(cpu_base + CPU_PC),
-		       info.text_base);
+		       info.fw_base);
 		return -ENODEV;
 	}
 	tw32(cpu_base + CPU_STATE, 0xffffffff);
@@ -6731,11 +6084,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		int fw_len;
 
-		fw_len = (TG3_TSO5_FW_TEXT_LEN +
-			  TG3_TSO5_FW_RODATA_LEN +
-			  TG3_TSO5_FW_DATA_LEN +
-			  TG3_TSO5_FW_SBSS_LEN +
-			  TG3_TSO5_FW_BSS_LEN);
+		fw_len = tp->fw_len;
 		fw_len = (fw_len + (0x80 - 1)) & ~(0x80 - 1);
 		tw32(BUFMGR_MB_POOL_ADDR,
 		     NIC_SRAM_MBUF_POOL_BASE5705 + fw_len);
@@ -12706,6 +12055,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	struct net_device *dev;
 	struct tg3 *tp;
 	int err, pm_cap;
+	const __be32 *fw_data;
+	const char *fw_name = NULL;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
 	DECLARE_MAC_BUF(mac);
@@ -12878,8 +12229,16 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_bufmgr_config(tp);
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
+		fw_name = "tigon/tg3.bin";
+
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+			fw_name = "tigon/tg3_tso5.bin";
+		else
+			fw_name = "tigon/tg3_tso.bin";
 	}
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
@@ -12891,6 +12250,31 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE | TG3_FLG2_TSO_BUG;
 	}
 
+	if (fw_name) {
+		err = request_firmware(&tp->fw, fw_name, &tp->pdev->dev);
+		if (err) {
+			printk(KERN_ERR "tg3: Failed to load firmware \"%s\"\n",
+				fw_name);
+			goto err_out_apeunmap;
+		}
+
+		fw_data = (void *)tp->fw->data;
+
+	/* Firmware blob starts with version numbers, followed by
+	   start address and length. We are setting complete length.
+	   length = end_address_of_bss - start_address_of_text.
+	   Remainder is the blob to be loaded contiguously
+	   from start address. */
+
+		tp->fw_len = be32_to_cpu(fw_data[2]);	/* includes bss */
+		if (tp->fw_len < (tp->fw->size-12)) {
+			printk(KERN_ERR "tg3: bogus length %d in \"%s\"\n",
+				tp->fw_len, fw_name);
+			err = -EINVAL;
+			goto err_out_apeunmap;
+		}
+	}
+
 	/* TSO is on by default on chips that support hardware TSO.
 	 * Firmware TSO on older chips gives lower performance, so it
 	 * is off by default, but can be enabled using ethtool.
@@ -13017,6 +12401,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	return 0;
 
 err_out_apeunmap:
+	if (tp->fw)
+		release_firmware(tp->fw);
+
 	if (tp->aperegs) {
 		iounmap(tp->aperegs);
 		tp->aperegs = NULL;
@@ -13047,6 +12434,9 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 	if (dev) {
 		struct tg3 *tp = netdev_priv(dev);
 
+		if (tp->fw)
+			release_firmware(tp->fw);
+
 		flush_scheduled_work();
 		unregister_netdev(dev);
 		if (tp->aperegs) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0404f93..435ff9b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2611,6 +2611,10 @@ struct tg3 {
 #define SST_25VF0X0_PAGE_SIZE		4098
 
 	struct ethtool_coalesce		coal;
+
+	/* firmware info */
+	const struct firmware		*fw;
+	u32				fw_len;
 };
 
 #endif /* !(_T3_H) */


-- 
dwmw2

