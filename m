From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Initialize RSS mode for all Ports
Date: Wed,  6 May 2015 19:48:37 +0530
Message-ID: <1430921917-26206-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9974 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750769AbbEFJGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:06:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements t4_init_rss_mode() to initialize the rss_mode for all the ports. If
Tunnel All Lookup isn't specified in the global RSS Configuration, then we need
to specify a default Ingress Queue for any ingress packets which aren't hashed.
We'll use our first ingress queue.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  3 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 37 +++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 47 +++++++++++++++++++++++++
 3 files changed, 80 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 1f52d9f..932ab3b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1201,12 +1201,15 @@ int t4_init_devlog_params(struct adapter *adapter);
 int t4_init_sge_params(struct adapter *adapter);
 int t4_init_tp_params(struct adapter *adap);
 int t4_filter_field_shift(const struct adapter *adap, int filter_sel);
+int t4_init_rss_mode(struct adapter *adap, int mbox);
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
 void t4_fatal_err(struct adapter *adapter);
 int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 			int start, int n, const u16 *rspq, unsigned int nrspq);
 int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 		       unsigned int flags);
+int t4_config_vi_rss(struct adapter *adapter, int mbox, unsigned int viid,
+		     unsigned int flags, unsigned int defq);
 int t4_read_rss(struct adapter *adapter, u16 *entries);
 void t4_read_rss_key(struct adapter *adapter, u32 *key);
 void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6c781c1..223995e7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -856,23 +856,39 @@ static void free_msix_queue_irqs(struct adapter *adap)
  *
  *	Sets up the portion of the HW RSS table for the port's VI to distribute
  *	packets to the Rx queues in @queues.
+ *	Should never be called before setting up sge eth rx queues
  */
 int cxgb4_write_rss(const struct port_info *pi, const u16 *queues)
 {
 	u16 *rss;
 	int i, err;
-	const struct sge_eth_rxq *q = &pi->adapter->sge.ethrxq[pi->first_qset];
+	struct adapter *adapter = pi->adapter;
+	const struct sge_eth_rxq *rxq;
 
+	rxq = &adapter->sge.ethrxq[pi->first_qset];
 	rss = kmalloc(pi->rss_size * sizeof(u16), GFP_KERNEL);
 	if (!rss)
 		return -ENOMEM;
 
 	/* map the queue indices to queue ids */
 	for (i = 0; i < pi->rss_size; i++, queues++)
-		rss[i] = q[*queues].rspq.abs_id;
+		rss[i] = rxq[*queues].rspq.abs_id;
 
-	err = t4_config_rss_range(pi->adapter, pi->adapter->fn, pi->viid, 0,
+	err = t4_config_rss_range(adapter, adapter->fn, pi->viid, 0,
 				  pi->rss_size, rss, pi->rss_size);
+	/* If Tunnel All Lookup isn't specified in the global RSS
+	 * Configuration, then we need to specify a default Ingress
+	 * Queue for any ingress packets which aren't hashed.  We'll
+	 * use our first ingress queue ...
+	 */
+	if (!err)
+		err = t4_config_vi_rss(adapter, adapter->mbox, pi->viid,
+				       FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_F |
+				       FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F |
+				       FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_F |
+				       FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F |
+				       FW_RSS_VI_CONFIG_CMD_UDPEN_F,
+				       rss[0]);
 	kfree(rss);
 	return err;
 }
@@ -885,11 +901,15 @@ int cxgb4_write_rss(const struct port_info *pi, const u16 *queues)
  */
 static int setup_rss(struct adapter *adap)
 {
-	int i, err;
+	int i, j, err;
 
 	for_each_port(adap, i) {
 		const struct port_info *pi = adap2pinfo(adap, i);
 
+		/* Fill default values with equal distribution */
+		for (j = 0; j < pi->rss_size; j++)
+			pi->rss[j] = j % pi->nqsets;
+
 		err = cxgb4_write_rss(pi, pi->rss);
 		if (err)
 			return err;
@@ -4343,7 +4363,12 @@ static int enable_msix(struct adapter *adap)
 
 static int init_rss(struct adapter *adap)
 {
-	unsigned int i, j;
+	unsigned int i;
+	int err;
+
+	err = t4_init_rss_mode(adap, adap->mbox);
+	if (err)
+		return err;
 
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
@@ -4351,8 +4376,6 @@ static int init_rss(struct adapter *adap)
 		pi->rss = kcalloc(pi->rss_size, sizeof(u16), GFP_KERNEL);
 		if (!pi->rss)
 			return -ENOMEM;
-		for (j = 0; j < pi->rss_size; j++)
-			pi->rss[j] = ethtool_rxfh_indir_default(j, pi->nqsets);
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 6164ef3..c626252 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3014,6 +3014,31 @@ int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 	return t4_wr_mbox(adapter, mbox, &c, sizeof(c), NULL);
 }
 
+/**
+ *	t4_config_vi_rss - configure per VI RSS settings
+ *	@adapter: the adapter
+ *	@mbox: mbox to use for the FW command
+ *	@viid: the VI id
+ *	@flags: RSS flags
+ *	@defq: id of the default RSS queue for the VI.
+ *
+ *	Configures VI-specific RSS properties.
+ */
+int t4_config_vi_rss(struct adapter *adapter, int mbox, unsigned int viid,
+		     unsigned int flags, unsigned int defq)
+{
+	struct fw_rss_vi_config_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				   FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
+				   FW_RSS_VI_CONFIG_CMD_VIID_V(viid));
+	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
+	c.u.basicvirtual.defaultq_to_udpen = cpu_to_be32(flags |
+					FW_RSS_VI_CONFIG_CMD_DEFAULTQ_V(defq));
+	return t4_wr_mbox(adapter, mbox, &c, sizeof(c), NULL);
+}
+
 /* Read an RSS table row */
 static int rd_rss_row(struct adapter *adap, int row, u32 *val)
 {
@@ -5373,6 +5398,28 @@ int t4_filter_field_shift(const struct adapter *adap, int filter_sel)
 	return field_shift;
 }
 
+int t4_init_rss_mode(struct adapter *adap, int mbox)
+{
+	int i, ret;
+	struct fw_rss_vi_config_cmd rvc;
+
+	memset(&rvc, 0, sizeof(rvc));
+
+	for_each_port(adap, i) {
+		struct port_info *p = adap2pinfo(adap, i);
+
+		rvc.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
+				       FW_CMD_REQUEST_F | FW_CMD_READ_F |
+				       FW_RSS_VI_CONFIG_CMD_VIID_V(p->viid));
+		rvc.retval_len16 = htonl(FW_LEN16(rvc));
+		ret = t4_wr_mbox(adap, mbox, &rvc, sizeof(rvc), &rvc);
+		if (ret)
+			return ret;
+		p->rss_mode = ntohl(rvc.u.basicvirtual.defaultq_to_udpen);
+	}
+	return 0;
+}
+
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 {
 	u8 addr[6];
-- 
2.3.4
