From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] net: netxen: correct sysfs bin attribute return code
Date: Tue, 26 May 2015 03:50:04 +0300
Message-ID: <1432601404-24632-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:37132 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbbEZA5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 20:57:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If read() syscall requests unexpected number of bytes from "dimm" binary
attribute file, return EINVAL instead of EPERM.

At the same time pin down sysfs file size to the fixed
sizeof(struct netxen_dimm_cfg), which allows to exploit some missing
sanity checks from kernfs (file boundary checks vs offset etc.)

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index e0c31e3..6409a06 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -3025,9 +3025,9 @@ netxen_sysfs_read_dimm(struct file *filp, struct kobject *kobj,
 	u8 dw, rows, cols, banks, ranks;
 	u32 val;
 
-	if (size != sizeof(struct netxen_dimm_cfg)) {
+	if (size < attr->size) {
 		netdev_err(netdev, "Invalid size\n");
-		return -1;
+		return -EINVAL;
 	}
 
 	memset(&dimm, 0, sizeof(struct netxen_dimm_cfg));
@@ -3137,7 +3137,7 @@ out:
 
 static struct bin_attribute bin_attr_dimm = {
 	.attr = { .name = "dimm", .mode = (S_IRUGO | S_IWUSR) },
-	.size = 0,
+	.size = sizeof(struct netxen_dimm_cfg),
 	.read = netxen_sysfs_read_dimm,
 };
 
-- 
2.1.4
