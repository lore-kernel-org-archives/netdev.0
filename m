From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/7] nfp: add very basic access to NSP logs
Date: Fri, 17 Feb 2017 14:00:25 -0800
Message-ID: <20170217220027.189992-6-jakub.kicinski@netronome.com>
References: <20170217220027.189992-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36347 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935091AbdBQWBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 17:01:10 -0500
Received: by mail-pg0-f50.google.com with SMTP id v184so18590062pgv.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 14:01:09 -0800 (PST)
In-Reply-To: <20170217220027.189992-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow dumping "arm.diag" resource with ethtool -w.  This resource
should contain a text log of the NSP (control processor) application.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  2 +
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 76 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  1 +
 3 files changed, 79 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 5a0fc09dd6ea..e614a376b595 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -492,6 +492,7 @@ struct nfp_stat_pair {
  * @tx_bar:             Pointer to mapped TX queues
  * @rx_bar:             Pointer to mapped FL/RX queues
  * @debugfs_dir:	Device directory in debugfs
+ * @ethtool_dump_flag:	Ethtool dump flag
  * @port_list:		Entry on device port list
  * @cpp:		CPP device handle if available
  */
@@ -579,6 +580,7 @@ struct nfp_net {
 	u8 __iomem *rx_bar;
 
 	struct dentry *debugfs_dir;
+	u32 ethtool_dump_flag;
 
 	struct list_head port_list;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 48f623f68598..2649f7523c81 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -51,6 +51,10 @@
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
+enum nfp_dump_diag {
+	NFP_DUMP_NSP_DIAG = 0,
+};
+
 /* Support for stats. Returns netdev, driver, and device stats */
 enum { NETDEV_ET_STATS, NFP_NET_DRV_ET_STATS, NFP_NET_DEV_ET_STATS };
 struct _nfp_net_et_stats {
@@ -579,6 +583,75 @@ static int nfp_net_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+/* Other debug dumps
+ */
+static int
+nfp_dump_nsp_diag(struct nfp_net *nn, struct ethtool_dump *dump, void *buffer)
+{
+	struct nfp_resource *res;
+	int ret;
+
+	if (!nn->cpp)
+		return -EOPNOTSUPP;
+
+	dump->version = 1;
+	dump->flag = NFP_DUMP_NSP_DIAG;
+
+	res = nfp_resource_acquire(nn->cpp, NFP_RESOURCE_NSP_DIAG);
+	if (IS_ERR(res))
+		return PTR_ERR(res);
+
+	if (buffer) {
+		if (dump->len != nfp_resource_size(res)) {
+			ret = -EINVAL;
+			goto exit_release;
+		}
+
+		ret = nfp_cpp_read(nn->cpp, nfp_resource_cpp_id(res),
+				   nfp_resource_address(res),
+				   buffer, dump->len);
+		if (ret != dump->len)
+			ret = ret < 0 ? ret : -EIO;
+		else
+			ret = 0;
+	} else {
+		dump->len = nfp_resource_size(res);
+		ret = 0;
+	}
+exit_release:
+	nfp_resource_release(res);
+
+	return ret;
+}
+
+static int nfp_net_set_dump(struct net_device *netdev, struct ethtool_dump *val)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (!nn->cpp)
+		return -EOPNOTSUPP;
+
+	if (val->flag != NFP_DUMP_NSP_DIAG)
+		return -EINVAL;
+
+	nn->ethtool_dump_flag = val->flag;
+
+	return 0;
+}
+
+static int
+nfp_net_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
+{
+	return nfp_dump_nsp_diag(netdev_priv(netdev), dump, NULL);
+}
+
+static int
+nfp_net_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
+		      void *buffer)
+{
+	return nfp_dump_nsp_diag(netdev_priv(netdev), dump, buffer);
+}
+
 static int nfp_net_set_coalesce(struct net_device *netdev,
 				struct ethtool_coalesce *ec)
 {
@@ -743,6 +816,9 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.set_rxfh		= nfp_net_set_rxfh,
 	.get_regs_len		= nfp_net_get_regs_len,
 	.get_regs		= nfp_net_get_regs,
+	.set_dump		= nfp_net_set_dump,
+	.get_dump_flag		= nfp_net_get_dump_flag,
+	.get_dump_data		= nfp_net_get_dump_data,
 	.get_coalesce           = nfp_net_get_coalesce,
 	.set_coalesce           = nfp_net_set_coalesce,
 	.get_channels		= nfp_net_get_channels,
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 540027973a74..42cb720b696d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -86,6 +86,7 @@ int nfp_nsp_write_eth_table(struct nfp_nsp *state,
 
 /* Service Processor */
 #define NFP_RESOURCE_NSP		"nfp.sp"
+#define NFP_RESOURCE_NSP_DIAG		"arm.diag"
 
 /* Netronone Flow Firmware Table */
 #define NFP_RESOURCE_NFP_NFFW		"nfp.nffw"
-- 
2.11.0
