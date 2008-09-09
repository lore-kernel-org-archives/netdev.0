From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] sky2: move VPD display into debug interface
Date: Tue, 09 Sep 2008 11:20:45 -0700
Message-ID: <20080909182057.270433056@vyatta.com>
References: <20080909182040.246073057@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:37565 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755012AbYIIT3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 15:29:30 -0400
Content-Disposition: inline; filename=sky2-vpd-debug.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VPD stuff has more data and isn't generally that useful, so move
it into the existing debugfs display and use the new PCI VPD
accessor routines.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2008-09-09 11:19:19.000000000 -0700
+++ b/drivers/net/sky2.c	2008-09-09 11:19:26.000000000 -0700
@@ -3861,6 +3861,86 @@ static const struct ethtool_ops sky2_eth
 
 static struct dentry *sky2_debug;
 
+
+/*
+ * Read and parse the first part of Vital Product Data
+ */
+#define VPD_SIZE	128
+#define VPD_MAGIC	0x82
+
+static const struct vpd_tag {
+	char tag[2];
+	char *label;
+} vpd_tags[] = {
+	{ "PN",	"Part Number" },
+	{ "EC", "Engineering Level" },
+	{ "MN", "Manufacturer" },
+	{ "SN", "Serial Number" },
+	{ "YA", "Asset Tag" },
+	{ "VL", "First Error Log Message" },
+	{ "VF", "Second Error Log Message" },
+	{ "VB", "Boot Agent ROM Configuration" },
+	{ "VE", "EFI UNDI Configuration" },
+};
+
+static void sky2_show_vpd(struct seq_file *seq, struct sky2_hw *hw)
+{
+	size_t vpd_size;
+	loff_t offs;
+	u8 len;
+	unsigned char *buf;
+	u16 reg2;
+
+	reg2 = sky2_pci_read16(hw, PCI_DEV_REG2);
+	vpd_size = 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+
+	seq_printf(seq, "%s Product Data\n", pci_name(hw->pdev));
+	buf = kmalloc(vpd_size, GFP_KERNEL);
+	if (!buf) {
+		seq_puts(seq, "no memory!\n");
+		return;
+	}
+
+	if (pci_read_vpd(hw->pdev, 0, vpd_size, buf) < 0) {
+		seq_puts(seq, "VPD read failed\n");
+		goto out;
+	}
+
+	if (buf[0] != VPD_MAGIC) {
+		seq_printf(seq, "VPD tag mismatch: %#x\n", buf[0]);
+		goto out;
+	}
+	len = buf[1];
+	if (len == 0 || len > vpd_size - 4) {
+		seq_printf(seq, "Invalid id length: %d\n", len);
+		goto out;
+	}
+
+	seq_printf(seq, "%.*s\n", len, buf + 3);
+	offs = len + 3;
+
+	while (offs < vpd_size - 4) {
+		int i;
+
+		if (!memcmp("RW", buf + offs, 2))	/* end marker */
+			break;
+		len = buf[offs + 2];
+		if (offs + len + 3 >= vpd_size)
+			break;
+
+		for (i = 0; i < ARRAY_SIZE(vpd_tags); i++) {
+			if (!memcmp(vpd_tags[i].tag, buf + offs, 2)) {
+				seq_printf(seq, " %s: %.*s\n",
+					   vpd_tags[i].label, len, buf + offs + 3);
+				break;
+			}
+		}
+		offs += len + 3;
+	}
+out:
+	kfree(buf);
+}
+
 static int sky2_debug_show(struct seq_file *seq, void *v)
 {
 	struct net_device *dev = seq->private;
@@ -3870,14 +3950,18 @@ static int sky2_debug_show(struct seq_fi
 	unsigned idx, last;
 	int sop;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
+	sky2_show_vpd(seq, hw);
 
-	seq_printf(seq, "IRQ src=%x mask=%x control=%x\n",
+	seq_printf(seq, "\nIRQ src=%x mask=%x control=%x\n",
 		   sky2_read32(hw, B0_ISRC),
 		   sky2_read32(hw, B0_IMSK),
 		   sky2_read32(hw, B0_Y2_SP_ICR));
 
+	if (!netif_running(dev)) {
+		seq_printf(seq, "network not running\n");
+		return 0;
+	}
+
 	napi_disable(&hw->napi);
 	last = sky2_read16(hw, STAT_PUT_IDX);
 
@@ -4191,69 +4275,6 @@ static int __devinit pci_wake_enabled(st
 	return value & PCI_PM_CTRL_PME_ENABLE;
 }
 
-/*
- * Read and parse the first part of Vital Product Data
- */
-#define VPD_SIZE	128
-#define VPD_MAGIC	0x82
-
-static void __devinit sky2_vpd_info(struct sky2_hw *hw)
-{
-	int cap = pci_find_capability(hw->pdev, PCI_CAP_ID_VPD);
-	const u8 *p;
-	u8 *vpd_buf = NULL;
-	u16 len;
-	static struct vpd_tag {
-		char tag[2];
-		char *label;
-	} vpd_tags[] = {
-		{ "PN",	"Part Number" },
-		{ "EC", "Engineering Level" },
-		{ "MN", "Manufacturer" },
-	};
-
-	if (!cap)
-		goto out;
-
-	vpd_buf = kmalloc(VPD_SIZE, GFP_KERNEL);
-	if (!vpd_buf)
-		goto out;
-
-	if (sky2_vpd_read(hw, cap, vpd_buf, 0, VPD_SIZE))
-		goto out;
-
-	if (vpd_buf[0] != VPD_MAGIC)
-		goto out;
-	len = vpd_buf[1];
-	if (len == 0 || len > VPD_SIZE - 4)
-		goto out;
-	p = vpd_buf + 3;
-	dev_info(&hw->pdev->dev, "%.*s\n", len, p);
-	p += len;
-
-	while (p < vpd_buf + VPD_SIZE - 4) {
-		int i;
-
-		if (!memcmp("RW", p, 2))	/* end marker */
-			break;
-
-		len = p[2];
-		if (len > (p - vpd_buf) - 4)
-			break;
-
-		for (i = 0; i < ARRAY_SIZE(vpd_tags); i++) {
-			if (!memcmp(vpd_tags[i].tag, p, 2)) {
-				printk(KERN_DEBUG " %s: %.*s\n",
-				       vpd_tags[i].label, len, p + 3);
-				break;
-			}
-		}
-		p += len + 3;
-	}
-out:
-	kfree(vpd_buf);
-}
-
 /* This driver supports yukon2 chipset only */
 static const char *sky2_name(u8 chipid, char *buf, int sz)
 {
@@ -4374,8 +4395,6 @@ static int __devinit sky2_probe(struct p
 
 	sky2_reset(hw);
 
-	sky2_vpd_info(hw);
-
 	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
 	if (!dev) {
 		err = -ENOMEM;

-- 

