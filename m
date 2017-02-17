From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/7] nfp: report NSP ABI version in ethtool FW version
Date: Fri, 17 Feb 2017 14:00:24 -0800
Message-ID: <20170217220027.189992-5-jakub.kicinski@netronome.com>
References: <20170217220027.189992-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36577 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934994AbdBQWBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 17:01:09 -0500
Received: by mail-pf0-f178.google.com with SMTP id 189so16146053pfu.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 14:01:08 -0800 (PST)
In-Reply-To: <20170217220027.189992-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool_drvinfo->fw_version can cantain multiple FW strings.
We already report NFD ABI version there, add NSP ABI version
if available (i.e. on PF) with 'sp:' prefix.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  4 ++++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 25 ++++++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  1 +
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  3 +++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   | 10 +++++++++
 5 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index d37d2391b4fe..5a0fc09dd6ea 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -111,6 +111,7 @@
 				 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
 /* Forward declarations */
+struct nfp_cpp;
 struct nfp_net;
 struct nfp_net_r_vector;
 
@@ -492,6 +493,7 @@ struct nfp_stat_pair {
  * @rx_bar:             Pointer to mapped FL/RX queues
  * @debugfs_dir:	Device directory in debugfs
  * @port_list:		Entry on device port list
+ * @cpp:		CPP device handle if available
  */
 struct nfp_net {
 	struct pci_dev *pdev;
@@ -579,6 +581,8 @@ struct nfp_net {
 	struct dentry *debugfs_dir;
 
 	struct list_head port_list;
+
+	struct nfp_cpp *cpp;
 };
 
 struct nfp_net_ring_set {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 255f30252550..48f623f68598 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -47,6 +47,7 @@
 #include <linux/pci.h>
 #include <linux/ethtool.h>
 
+#include "nfpcore/nfp.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
@@ -127,19 +128,39 @@ static const struct _nfp_net_et_stats nfp_net_et_stats[] = {
 #define NN_ET_STATS_LEN (NN_ET_GLOBAL_STATS_LEN + NN_ET_RVEC_GATHER_STATS + \
 			 NN_ET_RVEC_STATS_LEN + NN_ET_QUEUE_STATS_LEN)
 
+static void nfp_net_get_nspinfo(struct nfp_net *nn, char *version)
+{
+	struct nfp_nsp *nsp;
+
+	if (!nn->cpp)
+		return;
+
+	nsp = nfp_nsp_open(nn->cpp);
+	if (IS_ERR(nsp))
+		return;
+
+	snprintf(version, ETHTOOL_FWVERS_LEN, "sp:%hu.%hu",
+		 nfp_nsp_get_abi_ver_major(nsp),
+		 nfp_nsp_get_abi_ver_minor(nsp));
+
+	nfp_nsp_close(nsp);
+}
+
 static void nfp_net_get_drvinfo(struct net_device *netdev,
 				struct ethtool_drvinfo *drvinfo)
 {
+	char nsp_version[ETHTOOL_FWVERS_LEN] = {};
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	strlcpy(drvinfo->driver, nn->pdev->driver->name,
 		sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, nfp_driver_version, sizeof(drvinfo->version));
 
+	nfp_net_get_nspinfo(nn, nsp_version);
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		 "%d.%d.%d.%d",
+		 "%d.%d.%d.%d %s",
 		 nn->fw_ver.resv, nn->fw_ver.class,
-		 nn->fw_ver.major, nn->fw_ver.minor);
+		 nn->fw_ver.major, nn->fw_ver.minor, nsp_version);
 	strlcpy(drvinfo->bus_info, pci_name(nn->pdev),
 		sizeof(drvinfo->bus_info));
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index eccd31003b0d..3afcdc11480c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -303,6 +303,7 @@ nfp_net_pf_alloc_port_netdev(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	if (IS_ERR(nn))
 		return nn;
 
+	nn->cpp = pf->cpp;
 	nn->fw_ver = *fw_ver;
 	nn->ctrl_bar = ctrl_bar;
 	nn->tx_bar = tx_bar;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 3d70a8578a98..540027973a74 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -40,6 +40,7 @@
 #define __NFP_H__
 
 #include <linux/device.h>
+#include <linux/types.h>
 
 #include "nfp_cpp.h"
 
@@ -54,6 +55,8 @@ struct firmware;
 
 struct nfp_nsp *nfp_nsp_open(struct nfp_cpp *cpp);
 void nfp_nsp_close(struct nfp_nsp *state);
+u16 nfp_nsp_get_abi_ver_major(struct nfp_nsp *state);
+u16 nfp_nsp_get_abi_ver_minor(struct nfp_nsp *state);
 int nfp_nsp_wait(struct nfp_nsp *state);
 int nfp_nsp_device_soft_reset(struct nfp_nsp *state);
 int nfp_nsp_load_fw(struct nfp_nsp *state, const struct firmware *fw);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
index f2d737c3d1df..34c50987c377 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c
@@ -182,6 +182,16 @@ void nfp_nsp_close(struct nfp_nsp *state)
 	kfree(state);
 }
 
+u16 nfp_nsp_get_abi_ver_major(struct nfp_nsp *state)
+{
+	return state->ver.major;
+}
+
+u16 nfp_nsp_get_abi_ver_minor(struct nfp_nsp *state)
+{
+	return state->ver.minor;
+}
+
 static int
 nfp_nsp_wait_reg(struct nfp_cpp *cpp, u64 *reg,
 		 u32 nsp_cpp, u64 addr, u64 mask, u64 val)
-- 
2.11.0
