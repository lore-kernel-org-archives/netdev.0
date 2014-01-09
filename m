From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] qlcnic: Convert vmalloc/memset to kcalloc
Date: Wed, 08 Jan 2014 22:42:25 -0800
Message-ID: <1389249745.24222.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-driver <linux-driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vmalloc is a limited resource.  Don't use it unnecessarily.

It seems this allocation should work with kcalloc.

Remove unnecessary memset(,0,) of buf as it's completely
overwritten as the previously only unset field in
struct qlcnic_pci_func_cfg is now set to 0.

Use kfree instead of vfree.
Use ETH_ALEN instead of 6.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h       |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 16 ++++++----------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 35d4876..8d7aa4c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1267,7 +1267,7 @@ struct qlcnic_pci_func_cfg {
 	u16	port_num;
 	u8	pci_func;
 	u8	func_state;
-	u8	def_mac_addr[6];
+	u8	def_mac_addr[ETH_ALEN];
 };
 
 struct qlcnic_npar_func_cfg {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index b529667..c9b704d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -6,7 +6,6 @@
  */
 
 #include <linux/slab.h>
-#include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 
 #include "qlcnic.h"
@@ -927,38 +926,35 @@ static ssize_t qlcnic_sysfs_read_pci_config(struct file *file,
 	u32 pci_func_count = qlcnic_get_pci_func_count(adapter);
 	struct qlcnic_pci_func_cfg *pci_cfg;
 	struct qlcnic_pci_info *pci_info;
-	size_t pci_info_sz, pci_cfg_sz;
+	size_t pci_cfg_sz;
 	int i, ret;
 
 	pci_cfg_sz = pci_func_count * sizeof(*pci_cfg);
 	if (size != pci_cfg_sz)
 		return QL_STATUS_INVALID_PARAM;
 
-	pci_info_sz = pci_func_count * sizeof(*pci_info);
-	pci_info = vmalloc(pci_info_sz);
+	pci_info = kcalloc(pci_func_count, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
 
-	memset(pci_info, 0, pci_info_sz);
-	memset(buf, 0, pci_cfg_sz);
-	pci_cfg = (struct qlcnic_pci_func_cfg *)buf;
-
 	ret = qlcnic_get_pci_info(adapter, pci_info);
 	if (ret) {
-		vfree(pci_info);
+		kfree(pci_info);
 		return ret;
 	}
 
+	pci_cfg = (struct qlcnic_pci_func_cfg *)buf;
 	for (i = 0; i < pci_func_count; i++) {
 		pci_cfg[i].pci_func = pci_info[i].id;
 		pci_cfg[i].func_type = pci_info[i].type;
+		pci_cfg[i].func_state = 0;
 		pci_cfg[i].port_num = pci_info[i].default_port;
 		pci_cfg[i].min_bw = pci_info[i].tx_min_bw;
 		pci_cfg[i].max_bw = pci_info[i].tx_max_bw;
 		memcpy(&pci_cfg[i].def_mac_addr, &pci_info[i].mac, ETH_ALEN);
 	}
 
-	vfree(pci_info);
+	kfree(pci_info);
 	return size;
 }
 
