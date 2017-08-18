From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 05/14] amd-xgbe: Add additional debugfs support
Date: Thu, 17 Aug 2017 19:02:50 -0500
Message-ID: <20170818000250.10005.87855.stgit@tlendack-t1.amdoffice.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:22560
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753471AbdHRACy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:02:54 -0400
In-Reply-To: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add additional debugfs support for reading / writing registers of any
attached external phy devices as well as the SFP eeprom data.

These debugfs files will only be created if the phy implementation
supports them.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |  151 ++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c  |   87 +++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h         |   12 ++
 3 files changed, 250 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 7546b66..7409705 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -436,6 +436,126 @@ static ssize_t xi2c_reg_value_write(struct file *filp,
 	.write = xi2c_reg_value_write,
 };
 
+static ssize_t sfp_eeprom_read(struct file *filp, char __user *buffer,
+			       size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	struct xgbe_phy_impl_if *phy_impl;
+	unsigned char *eeprom;
+	ssize_t len;
+
+	phy_impl = &pdata->phy_if.phy_impl;
+	eeprom = phy_impl->sfp_eeprom(pdata);
+	if (!eeprom)
+		return 0;
+
+	len = simple_read_from_buffer(buffer, count, ppos,
+				      eeprom, strlen(eeprom));
+
+	kfree(eeprom);
+
+	return len;
+}
+
+static const struct file_operations sfp_eeprom_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = sfp_eeprom_read,
+};
+
+static ssize_t phydev_mmd_read(struct file *filp, char __user *buffer,
+			       size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_read(buffer, count, ppos, pdata->debugfs_phydev_mmd);
+}
+
+static ssize_t phydev_mmd_write(struct file *filp, const char __user *buffer,
+				size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_write(buffer, count, ppos,
+				 &pdata->debugfs_phydev_mmd);
+}
+
+static ssize_t phydev_reg_addr_read(struct file *filp, char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_read(buffer, count, ppos, pdata->debugfs_phydev_reg);
+}
+
+static ssize_t phydev_reg_addr_write(struct file *filp,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_write(buffer, count, ppos,
+				 &pdata->debugfs_phydev_reg);
+}
+
+static ssize_t phydev_reg_value_read(struct file *filp, char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	struct xgbe_phy_impl_if *phy_impl;
+	unsigned int value;
+
+	phy_impl = &pdata->phy_if.phy_impl;
+	value = phy_impl->phydev_read(pdata,
+				      pdata->debugfs_phydev_mmd,
+				      pdata->debugfs_phydev_reg);
+
+	return xgbe_common_read(buffer, count, ppos, value);
+}
+
+static ssize_t phydev_reg_value_write(struct file *filp,
+				      const char __user *buffer,
+				      size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	struct xgbe_phy_impl_if *phy_impl;
+	unsigned int value;
+	ssize_t len;
+
+	len = xgbe_common_write(buffer, count, ppos, &value);
+	if (len < 0)
+		return len;
+
+	phy_impl = &pdata->phy_if.phy_impl;
+	phy_impl->phydev_write(pdata,
+			       pdata->debugfs_phydev_mmd,
+			       pdata->debugfs_phydev_reg,
+			       value);
+
+	return len;
+}
+
+static const struct file_operations phydev_mmd_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = phydev_mmd_read,
+	.write = phydev_mmd_write,
+};
+
+static const struct file_operations phydev_reg_addr_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = phydev_reg_addr_read,
+	.write = phydev_reg_addr_write,
+};
+
+static const struct file_operations phydev_reg_value_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read = phydev_reg_value_read,
+	.write = phydev_reg_value_write,
+};
+
 void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
 {
 	struct dentry *pfile;
@@ -445,6 +565,8 @@ void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
 	pdata->debugfs_xgmac_reg = 0;
 	pdata->debugfs_xpcs_mmd = 1;
 	pdata->debugfs_xpcs_reg = 0;
+	pdata->debugfs_phydev_mmd = 1;
+	pdata->debugfs_phydev_reg = 0;
 
 	buf = kasprintf(GFP_KERNEL, "amd-xgbe-%s", pdata->netdev->name);
 	if (!buf)
@@ -519,6 +641,35 @@ void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
 				   "debugfs_create_file failed\n");
 	}
 
+	if (pdata->phy_if.phy_impl.sfp_eeprom) {
+		pfile = debugfs_create_file("sfp_eeprom", 0400,
+					    pdata->xgbe_debugfs, pdata,
+					    &sfp_eeprom_fops);
+		if (!pfile)
+			netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+	}
+
+	if (pdata->phy_if.phy_impl.phydev_read &&
+	    pdata->phy_if.phy_impl.phydev_write) {
+		pfile = debugfs_create_file("phydev_mmd", 0600,
+					    pdata->xgbe_debugfs, pdata,
+					    &phydev_mmd_fops);
+		if (!pfile)
+			netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+		pfile = debugfs_create_file("phydev_register", 0600,
+					    pdata->xgbe_debugfs, pdata,
+					    &phydev_reg_addr_fops);
+		if (!pfile)
+			netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+		pfile = debugfs_create_file("phydev_register_value", 0600,
+					    pdata->xgbe_debugfs, pdata,
+					    &phydev_reg_value_fops);
+		if (!pfile)
+			netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+	}
+
 	kfree(buf);
 }
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 81c45fa..4463487 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -258,6 +258,8 @@ struct xgbe_sfp_eeprom {
 	u8 vendor[32];
 };
 
+#define XGBE_SFP_EEPROM_LINE			16
+
 #define XGBE_BEL_FUSE_VENDOR	"BEL-FUSE        "
 #define XGBE_BEL_FUSE_PARTNO	"1GBT-SFP06      "
 
@@ -1275,6 +1277,79 @@ static void xgbe_phy_sfp_detect(struct xgbe_prv_data *pdata)
 	xgbe_phy_put_comm_ownership(pdata);
 }
 
+static int xgbe_phy_phydev_write(struct xgbe_prv_data *pdata, unsigned int mmd,
+				 unsigned int reg, unsigned int val)
+{
+	struct xgbe_phy_data *phy_data = pdata->phy_data;
+	unsigned int ret;
+
+	if (!phy_data->phydev)
+		return -ENOTSUPP;
+
+	if (phy_data->phydev_mode == XGBE_MDIO_MODE_CL45)
+		reg = MII_ADDR_C45 | (mmd << 16) | (reg & 0xffff);
+
+	ret = xgbe_phy_mii_write(phy_data->mii, phy_data->mdio_addr, reg, val);
+
+	return ret;
+}
+
+static int xgbe_phy_phydev_read(struct xgbe_prv_data *pdata, unsigned int mmd,
+				unsigned int reg)
+{
+	struct xgbe_phy_data *phy_data = pdata->phy_data;
+	unsigned int ret;
+
+	if (!phy_data->phydev)
+		return -ENOTSUPP;
+
+	if (phy_data->phydev_mode == XGBE_MDIO_MODE_CL45)
+		reg = MII_ADDR_C45 | (mmd << 16) | (reg & 0xffff);
+
+	ret = xgbe_phy_mii_read(phy_data->mii, phy_data->mdio_addr, reg);
+
+	return ret;
+}
+
+static unsigned char *xgbe_phy_sfp_eeprom(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_phy_data *phy_data = pdata->phy_data;
+	unsigned char *eeprom, *eeprom_end;
+	char *buffer, *cur;
+	size_t size;
+
+	/* Calculate the buffer needed for hex_dump_to_buffer()
+	 * assuming XGBE_SFP_EEPROM_LINE bytes per line and ASCII data:
+	 *   sizeof(struct xgbe_sfp_eeprom) * 3  for the hex output
+	 *   sizeof(struct xgbe_sfp_eeprom)      for the ASCII output
+	 *   sizeof(struct xgbe_sfp_eeprom)
+	 *       / XGBE_SFP_EEPROM_LINE * 4      for extra spaces and newlines
+	 */
+	size = (sizeof(struct xgbe_sfp_eeprom) * 4) +
+	       (sizeof(struct xgbe_sfp_eeprom) / XGBE_SFP_EEPROM_LINE * 4);
+	buffer = kzalloc(size, GFP_ATOMIC);
+	if (!buffer)
+		return NULL;
+
+	cur = buffer;
+	eeprom = (unsigned char *)&phy_data->sfp_eeprom;
+	eeprom_end = eeprom + sizeof(struct xgbe_sfp_eeprom);
+	for (; eeprom < eeprom_end; eeprom += XGBE_SFP_EEPROM_LINE) {
+		hex_dump_to_buffer(eeprom, XGBE_SFP_EEPROM_LINE,
+				   XGBE_SFP_EEPROM_LINE, 1, cur, size, true);
+
+		/* Reduce size by new string length (including newline) */
+		size -= strlen(cur);
+		size--;
+
+		/* Adjust buffer and add a new line */
+		cur += strlen(cur);
+		*cur++ = '\n';
+	}
+
+	return buffer;
+}
+
 static void xgbe_phy_phydev_flowctrl(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_phy_data *phy_data = pdata->phy_data;
@@ -2744,6 +2819,7 @@ static void xgbe_phy_exit(struct xgbe_prv_data *pdata)
 
 static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 {
+	struct xgbe_phy_impl_if *phy_impl = &pdata->phy_if.phy_impl;
 	struct xgbe_phy_data *phy_data;
 	struct mii_bus *mii;
 	unsigned int reg;
@@ -2869,6 +2945,8 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 		}
 
 		phy_data->phydev_mode = XGBE_MDIO_MODE_CL22;
+		phy_impl->phydev_read = xgbe_phy_phydev_read;
+		phy_impl->phydev_write = xgbe_phy_phydev_write;
 		break;
 
 	/* MDIO Base-X support */
@@ -2880,6 +2958,8 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 		phy_data->start_mode = XGBE_MODE_X;
 
 		phy_data->phydev_mode = XGBE_MDIO_MODE_CL22;
+		phy_impl->phydev_read = xgbe_phy_phydev_read;
+		phy_impl->phydev_write = xgbe_phy_phydev_write;
 		break;
 
 	/* MDIO NBase-T support */
@@ -2901,6 +2981,8 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 		}
 
 		phy_data->phydev_mode = XGBE_MDIO_MODE_CL45;
+		phy_impl->phydev_read = xgbe_phy_phydev_read;
+		phy_impl->phydev_write = xgbe_phy_phydev_write;
 		break;
 
 	/* 10GBase-T support */
@@ -2922,6 +3004,8 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 		}
 
 		phy_data->phydev_mode = XGBE_MDIO_MODE_CL45;
+		phy_impl->phydev_read = xgbe_phy_phydev_read;
+		phy_impl->phydev_write = xgbe_phy_phydev_write;
 		break;
 
 	/* 10GBase-R support */
@@ -2957,8 +3041,11 @@ static int xgbe_phy_init(struct xgbe_prv_data *pdata)
 		}
 
 		phy_data->phydev_mode = XGBE_MDIO_MODE_CL22;
+		phy_impl->phydev_read = xgbe_phy_phydev_read;
+		phy_impl->phydev_write = xgbe_phy_phydev_write;
 
 		xgbe_phy_sfp_setup(pdata);
+		phy_impl->sfp_eeprom = xgbe_phy_sfp_eeprom;
 		break;
 	default:
 		return -EINVAL;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index e9282c9..8a3fb9d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -776,6 +776,7 @@ struct xgbe_hw_if {
  * implementation of a PHY. All routines are required unless noted below.
  *   Optional routines:
  *     kr_training_pre, kr_training_post
+ *     eeprom_data, phydev_read, phydev_write
  */
 struct xgbe_phy_impl_if {
 	/* Perform Setup/teardown actions */
@@ -819,6 +820,14 @@ struct xgbe_phy_impl_if {
 	/* Pre/Post KR training enablement support */
 	void (*kr_training_pre)(struct xgbe_prv_data *);
 	void (*kr_training_post)(struct xgbe_prv_data *);
+
+	/* Return the eeprom data for an SFP */
+	unsigned char *(*sfp_eeprom)(struct xgbe_prv_data *);
+
+	/* Read the register of an attached PHY device */
+	int (*phydev_read)(struct xgbe_prv_data *, unsigned int, unsigned int);
+	int (*phydev_write)(struct xgbe_prv_data *, unsigned int, unsigned int,
+			    unsigned int);
 };
 
 struct xgbe_phy_if {
@@ -1183,6 +1192,9 @@ struct xgbe_prv_data {
 	unsigned int debugfs_xprop_reg;
 
 	unsigned int debugfs_xi2c_reg;
+
+	unsigned int debugfs_phydev_mmd;
+	unsigned int debugfs_phydev_reg;
 #endif
 };
 
