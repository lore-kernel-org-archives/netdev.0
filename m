From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 3/4] netxen: added miniDIMM support in driver.
Date: Tue, 8 May 2012 08:01:27 -0700
Message-ID: <1336489288-22347-4-git-send-email-rajesh.borundia@qlogic.com>
References: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:50728
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756085Ab2EHPRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 11:17:42 -0400
In-Reply-To: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Driver queries DIMM information from firmware and accordingly
sets "presence" field of the structure.
"presence" field when set to 0xff denotes invalid flag. And when
set to 0x0 denotes DIMM memory is not present.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    7 +
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |   25 ++++
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  131 ++++++++++++++++++++
 3 files changed, 163 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index b8614af..a43a26c 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -1818,6 +1818,13 @@ struct netxen_brdinfo {
 	char short_name[NETXEN_MAX_SHORT_NAME];
 };
 
+struct netxen_dimm_cfg {
+	u8 presence;
+	u8 mem_type;
+	u8 dimm_type;
+	u32 size;
+};
+
 static const struct netxen_brdinfo netxen_boards[] = {
 	{NETXEN_BRDTYPE_P2_SB31_10G_CX4, 1, "XGb CX4"},
 	{NETXEN_BRDTYPE_P2_SB31_10G_HMEZ, 1, "XGb HMEZ"},
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
index b1a897c..a41106b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
@@ -955,6 +955,31 @@ enum {
 #define NX_CRB_DEV_REF_COUNT		(NETXEN_CAM_RAM(0x138))
 #define NX_CRB_DEV_STATE		(NETXEN_CAM_RAM(0x140))
 
+/* MiniDIMM related macros */
+#define NETXEN_DIMM_CAPABILITY		(NETXEN_CAM_RAM(0x258))
+#define NETXEN_DIMM_PRESENT			0x1
+#define NETXEN_DIMM_MEMTYPE_DDR2_SDRAM	0x2
+#define NETXEN_DIMM_SIZE			0x4
+#define NETXEN_DIMM_MEMTYPE(VAL)		((VAL >> 3) & 0xf)
+#define	NETXEN_DIMM_NUMROWS(VAL)		((VAL >> 7) & 0xf)
+#define	NETXEN_DIMM_NUMCOLS(VAL)		((VAL >> 11) & 0xf)
+#define	NETXEN_DIMM_NUMRANKS(VAL)		((VAL >> 15) & 0x3)
+#define NETXEN_DIMM_DATAWIDTH(VAL)		((VAL >> 18) & 0x3)
+#define NETXEN_DIMM_NUMBANKS(VAL)		((VAL >> 21) & 0xf)
+#define NETXEN_DIMM_TYPE(VAL)		((VAL >> 25) & 0x3f)
+#define NETXEN_DIMM_VALID_FLAG		0x80000000
+
+#define NETXEN_DIMM_MEM_DDR2_SDRAM	0x8
+
+#define NETXEN_DIMM_STD_MEM_SIZE	512
+
+#define NETXEN_DIMM_TYPE_RDIMM	0x1
+#define NETXEN_DIMM_TYPE_UDIMM	0x2
+#define NETXEN_DIMM_TYPE_SO_DIMM	0x4
+#define NETXEN_DIMM_TYPE_Micro_DIMM	0x8
+#define NETXEN_DIMM_TYPE_Mini_RDIMM	0x10
+#define NETXEN_DIMM_TYPE_Mini_UDIMM	0x20
+
 /* Device State */
 #define NX_DEV_COLD		1
 #define NX_DEV_INITALIZING	2
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 65a718f..05f3ffe 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2926,6 +2926,134 @@ static struct bin_attribute bin_attr_mem = {
 	.write = netxen_sysfs_write_mem,
 };
 
+static ssize_t
+netxen_sysfs_read_dimm(struct file *filp, struct kobject *kobj,
+		struct bin_attribute *attr,
+		char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct netxen_adapter *adapter = dev_get_drvdata(dev);
+	struct net_device *netdev = adapter->netdev;
+	struct netxen_dimm_cfg dimm;
+	u8 dw, rows, cols, banks, ranks;
+	u32 val;
+
+	if (size != sizeof(struct netxen_dimm_cfg)) {
+		netdev_err(netdev, "Invalid size\n");
+		return -1;
+	}
+
+	memset(&dimm, 0, sizeof(struct netxen_dimm_cfg));
+	val = NXRD32(adapter, NETXEN_DIMM_CAPABILITY);
+
+	/* Checks if DIMM info is valid. */
+	if (val & NETXEN_DIMM_VALID_FLAG) {
+		netdev_err(netdev, "Invalid DIMM flag\n");
+		dimm.presence = 0xff;
+		goto out;
+	}
+
+	rows = NETXEN_DIMM_NUMROWS(val);
+	cols = NETXEN_DIMM_NUMCOLS(val);
+	ranks = NETXEN_DIMM_NUMRANKS(val);
+	banks = NETXEN_DIMM_NUMBANKS(val);
+	dw = NETXEN_DIMM_DATAWIDTH(val);
+
+	dimm.presence = (val & NETXEN_DIMM_PRESENT);
+
+	/* Checks if DIMM info is present. */
+	if (!dimm.presence) {
+		netdev_err(netdev, "DIMM not present\n");
+		goto out;
+	}
+
+	dimm.dimm_type = NETXEN_DIMM_TYPE(val);
+
+	switch (dimm.dimm_type) {
+	case NETXEN_DIMM_TYPE_RDIMM:
+	case NETXEN_DIMM_TYPE_UDIMM:
+	case NETXEN_DIMM_TYPE_SO_DIMM:
+	case NETXEN_DIMM_TYPE_Micro_DIMM:
+	case NETXEN_DIMM_TYPE_Mini_RDIMM:
+	case NETXEN_DIMM_TYPE_Mini_UDIMM:
+		break;
+	default:
+		netdev_err(netdev, "Invalid DIMM type %x\n", dimm.dimm_type);
+		goto out;
+	}
+
+	if (val & NETXEN_DIMM_MEMTYPE_DDR2_SDRAM)
+		dimm.mem_type = NETXEN_DIMM_MEM_DDR2_SDRAM;
+	else
+		dimm.mem_type = NETXEN_DIMM_MEMTYPE(val);
+
+	if (val & NETXEN_DIMM_SIZE) {
+		dimm.size = NETXEN_DIMM_STD_MEM_SIZE;
+		goto out;
+	}
+
+	if (!rows) {
+		netdev_err(netdev, "Invalid no of rows %x\n", rows);
+		goto out;
+	}
+
+	if (!cols) {
+		netdev_err(netdev, "Invalid no of columns %x\n", cols);
+		goto out;
+	}
+
+	if (!banks) {
+		netdev_err(netdev, "Invalid no of banks %x\n", banks);
+		goto out;
+	}
+
+	ranks += 1;
+
+	switch (dw) {
+	case 0x0:
+		dw = 32;
+		break;
+	case 0x1:
+		dw = 33;
+		break;
+	case 0x2:
+		dw = 36;
+		break;
+	case 0x3:
+		dw = 64;
+		break;
+	case 0x4:
+		dw = 72;
+		break;
+	case 0x5:
+		dw = 80;
+		break;
+	case 0x6:
+		dw = 128;
+		break;
+	case 0x7:
+		dw = 144;
+		break;
+	default:
+		netdev_err(netdev, "Invalid data-width %x\n", dw);
+		goto out;
+	}
+
+	dimm.size = ((1 << rows) * (1 << cols) * dw * banks * ranks) / 8;
+	/* Size returned in MB. */
+	dimm.size = (dimm.size) / 0x100000;
+out:
+	memcpy(buf, &dimm, sizeof(struct netxen_dimm_cfg));
+	return sizeof(struct netxen_dimm_cfg);
+
+}
+
+static struct bin_attribute bin_attr_dimm = {
+	.attr = {.name = "dimm", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = netxen_sysfs_read_dimm,
+};
+
 
 static void
 netxen_create_sysfs_entries(struct netxen_adapter *adapter)
@@ -2963,6 +3091,8 @@ netxen_create_diag_entries(struct netxen_adapter *adapter)
 		dev_info(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
 		dev_info(dev, "failed to create mem sysfs entry\n");
+	if (device_create_bin_file(dev, &bin_attr_dimm))
+		dev_info(dev, "failed to create dimm sysfs entry\n");
 }
 
 
@@ -2975,6 +3105,7 @@ netxen_remove_diag_entries(struct netxen_adapter *adapter)
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
+	device_remove_bin_file(dev, &bin_attr_dimm);
 }
 
 #ifdef CONFIG_INET
-- 
1.7.3.3
