From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/12] nfp: allow retreiving management FW logs on representors
Date: Fri, 18 Aug 2017 15:48:13 -0700
Message-ID: <20170818224822.8409-4-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34874 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdHRWt0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:26 -0400
Received: by mail-pg0-f45.google.com with SMTP id q6so1399909pgs.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:26 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users should be able to dump the management FW logs on any
of the driver's netdevs.  Make the code only depend on the
nfp_app and share it between vNICs and representors.

Storing the dump flag is simply dropped for now, since we
only support the argument being set to 0.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  2 --
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 33 +++++++++++-----------
 2 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index b1fa77bd708b..d51d8237b984 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -573,7 +573,6 @@ struct nfp_net_dp {
  * @tx_bar:             Pointer to mapped TX queues
  * @rx_bar:             Pointer to mapped FL/RX queues
  * @debugfs_dir:	Device directory in debugfs
- * @ethtool_dump_flag:	Ethtool dump flag
  * @vnic_list:		Entry on device vNIC list
  * @pdev:		Backpointer to PCI device
  * @app:		APP handle if available
@@ -640,7 +639,6 @@ struct nfp_net {
 	u8 __iomem *rx_bar;
 
 	struct dentry *debugfs_dir;
-	u32 ethtool_dump_flag;
 
 	struct list_head vnic_list;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 3c34c8b27dcf..289fa318a651 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -727,18 +727,18 @@ static int nfp_net_get_coalesce(struct net_device *netdev,
 /* Other debug dumps
  */
 static int
-nfp_dump_nsp_diag(struct nfp_net *nn, struct ethtool_dump *dump, void *buffer)
+nfp_dump_nsp_diag(struct nfp_app *app, struct ethtool_dump *dump, void *buffer)
 {
 	struct nfp_resource *res;
 	int ret;
 
-	if (!nn->app)
+	if (!app)
 		return -EOPNOTSUPP;
 
 	dump->version = 1;
 	dump->flag = NFP_DUMP_NSP_DIAG;
 
-	res = nfp_resource_acquire(nn->app->cpp, NFP_RESOURCE_NSP_DIAG);
+	res = nfp_resource_acquire(app->cpp, NFP_RESOURCE_NSP_DIAG);
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
@@ -748,7 +748,7 @@ nfp_dump_nsp_diag(struct nfp_net *nn, struct ethtool_dump *dump, void *buffer)
 			goto exit_release;
 		}
 
-		ret = nfp_cpp_read(nn->app->cpp, nfp_resource_cpp_id(res),
+		ret = nfp_cpp_read(app->cpp, nfp_resource_cpp_id(res),
 				   nfp_resource_address(res),
 				   buffer, dump->len);
 		if (ret != dump->len)
@@ -765,32 +765,30 @@ nfp_dump_nsp_diag(struct nfp_net *nn, struct ethtool_dump *dump, void *buffer)
 	return ret;
 }
 
-static int nfp_net_set_dump(struct net_device *netdev, struct ethtool_dump *val)
+static int nfp_app_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
-	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_app *app = nfp_app_from_netdev(netdev);
 
-	if (!nn->app)
+	if (!app)
 		return -EOPNOTSUPP;
 
 	if (val->flag != NFP_DUMP_NSP_DIAG)
 		return -EINVAL;
 
-	nn->ethtool_dump_flag = val->flag;
-
 	return 0;
 }
 
 static int
-nfp_net_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
+nfp_app_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 {
-	return nfp_dump_nsp_diag(netdev_priv(netdev), dump, NULL);
+	return nfp_dump_nsp_diag(nfp_app_from_netdev(netdev), dump, NULL);
 }
 
 static int
-nfp_net_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
+nfp_app_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 		      void *buffer)
 {
-	return nfp_dump_nsp_diag(netdev_priv(netdev), dump, buffer);
+	return nfp_dump_nsp_diag(nfp_app_from_netdev(netdev), dump, buffer);
 }
 
 static int nfp_net_set_coalesce(struct net_device *netdev,
@@ -947,9 +945,9 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.set_rxfh		= nfp_net_set_rxfh,
 	.get_regs_len		= nfp_net_get_regs_len,
 	.get_regs		= nfp_net_get_regs,
-	.set_dump		= nfp_net_set_dump,
-	.get_dump_flag		= nfp_net_get_dump_flag,
-	.get_dump_data		= nfp_net_get_dump_data,
+	.set_dump		= nfp_app_set_dump,
+	.get_dump_flag		= nfp_app_get_dump_flag,
+	.get_dump_data		= nfp_app_get_dump_data,
 	.get_coalesce           = nfp_net_get_coalesce,
 	.set_coalesce           = nfp_net_set_coalesce,
 	.get_channels		= nfp_net_get_channels,
@@ -961,6 +959,9 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 const struct ethtool_ops nfp_port_ethtool_ops = {
 	.get_drvinfo		= nfp_app_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.set_dump		= nfp_app_set_dump,
+	.get_dump_flag		= nfp_app_get_dump_flag,
+	.get_dump_data		= nfp_app_get_dump_data,
 };
 
 void nfp_net_set_ethtool_ops(struct net_device *netdev)
-- 
2.11.0
