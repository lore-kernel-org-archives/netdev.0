From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/16] nfp: make sure debug accesses don't depend on netdevs
Date: Mon,  5 Jun 2017 17:01:47 -0700
Message-ID: <20170606000157.17556-7-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34243 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdFFACU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:20 -0400
Received: by mail-pf0-f178.google.com with SMTP id 9so89898221pfj.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:20 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to be able to inspect the state of descriptor rings of
the control vNIC, so it will use the same interface as data vNICs.

Make sure the code doesn't use netdevs to determine state
of the rings and names things appropriately.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h         | 11 +++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c |  9 ++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index b14aa31d494a..3eec4195c155 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -805,6 +805,17 @@ static inline u32 nfp_qcp_wr_ptr_read(u8 __iomem *q)
 	return _nfp_qcp_read(q, NFP_QCP_WRITE_PTR);
 }
 
+static inline bool nfp_net_is_data_vnic(struct nfp_net *nn)
+{
+	WARN_ON_ONCE(!nn->dp.netdev && nn->port);
+	return !!nn->dp.netdev;
+}
+
+static inline bool nfp_net_running(struct nfp_net *nn)
+{
+	return nn->dp.ctrl & NFP_NET_CFG_CTRL_ENABLE;
+}
+
 /* Globals */
 extern const char nfp_driver_version[];
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 8c52c0e8379c..40217ece5fcb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -54,7 +54,7 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 		goto out;
 	nn = r_vec->nfp_net;
 	rx_ring = r_vec->rx_ring;
-	if (!netif_running(nn->dp.netdev))
+	if (!nfp_net_running(nn))
 		goto out;
 
 	rxd_cnt = rx_ring->cnt;
@@ -138,7 +138,7 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	if (!r_vec->nfp_net || !tx_ring)
 		goto out;
 	nn = r_vec->nfp_net;
-	if (!netif_running(nn->dp.netdev))
+	if (!nfp_net_running(nn))
 		goto out;
 
 	txd_cnt = tx_ring->cnt;
@@ -209,7 +209,10 @@ void nfp_net_debugfs_vnic_add(struct nfp_net *nn, struct dentry *ddir, int id)
 	if (IS_ERR_OR_NULL(nfp_dir))
 		return;
 
-	sprintf(name, "vnic%d", id);
+	if (nfp_net_is_data_vnic(nn))
+		sprintf(name, "vnic%d", id);
+	else
+		strcpy(name, "ctrl-vnic");
 	nn->debugfs_dir = debugfs_create_dir(name, ddir);
 	if (IS_ERR_OR_NULL(nn->debugfs_dir))
 		return;
-- 
2.11.0
