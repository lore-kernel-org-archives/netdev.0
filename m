From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] skge: add VPD display into debug interface
Date: Mon, 13 Oct 2008 13:13:10 -0700
Message-ID: <20081013201453.344338423@vyatta.com>
References: <20081013201302.899587376@vyatta.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40284 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755415AbYJMVDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 17:03:51 -0400
Content-Disposition: inline; filename=skge-vpd-debug.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VPD stuff has more data and useful only when debugging.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/skge.c	2008-10-13 13:04:10.000000000 -0700
+++ b/drivers/net/skge.c	2008-10-13 13:04:16.000000000 -0700
@@ -3670,19 +3670,102 @@ static int skge_reset(struct skge_hw *hw
 
 static struct dentry *skge_debug;
 
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
+static void skge_show_vpd(struct seq_file *seq, struct skge_hw *hw)
+{
+	size_t vpd_size;
+	loff_t offs;
+	u8 len;
+	unsigned char *buf;
+	u32 reg2;
+
+	pci_read_config_dword(hw->pdev, PCI_DEV_REG2, &reg2);
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
 static int skge_debug_show(struct seq_file *seq, void *v)
 {
 	struct net_device *dev = seq->private;
 	const struct skge_port *skge = netdev_priv(dev);
-	const struct skge_hw *hw = skge->hw;
+	struct skge_hw *hw = skge->hw;
 	const struct skge_element *e;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
+	skge_show_vpd(seq, hw);
 
 	seq_printf(seq, "IRQ src=%x mask=%x\n", skge_read32(hw, B0_ISRC),
 		   skge_read32(hw, B0_IMSK));
 
+	if (!netif_running(dev)) {
+		seq_printf(seq, "network not running\n");
+		return 0;
+	}
+
 	seq_printf(seq, "Tx Ring: (%d)\n", skge_avail(&skge->tx_ring));
 	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
 		const struct skge_tx_desc *t = e->desc;

-- 

