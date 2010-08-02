From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 6/9] cxgb4: support running the driver on PCI functions besides 0
Date: Mon,  2 Aug 2010 16:19:21 -0700
Message-ID: <1280791164-14181-7-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
 <1280791164-14181-4-git-send-email-dm@chelsio.com>
 <1280791164-14181-5-git-send-email-dm@chelsio.com>
 <1280791164-14181-6-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14700 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJP1f025638
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:25 -0700
In-Reply-To: <1280791164-14181-6-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for running the driver on any PCI function.  Mostly this
entails replacing a constant 0 in a number of calls with the variable
function number.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    3 +-
 drivers/net/cxgb4/cxgb4_main.c |  128 ++++++++++++++++++++++-----------------
 drivers/net/cxgb4/sge.c        |   38 +++++++-----
 3 files changed, 97 insertions(+), 72 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 4769c1c..6e562c0 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -482,7 +482,8 @@ struct adapter {
 	struct pci_dev *pdev;
 	struct device *pdev_dev;
 	unsigned long registered_device_map;
-	unsigned long flags;
+	unsigned int fn;
+	unsigned int flags;
 
 	const char *name;
 	int msg_enable;
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index e80d4a5..5d5ea82 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -171,10 +171,10 @@ enum {
 			 NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP |\
 			 NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
 
-#define CH_DEVICE(devid) { PCI_VDEVICE(CHELSIO, devid), 0 }
+#define CH_DEVICE(devid, data) { PCI_VDEVICE(CHELSIO, devid), (data) }
 
 static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
-	CH_DEVICE(0xa000),  /* PE10K */
+	CH_DEVICE(0xa000, 0),  /* PE10K */
 	{ 0, }
 };
 
@@ -314,12 +314,13 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
 	int uc_cnt = netdev_uc_count(dev);
 	int mc_cnt = netdev_mc_count(dev);
 	const struct port_info *pi = netdev_priv(dev);
+	unsigned int mb = pi->adapter->fn;
 
 	/* first do the secondary unicast addresses */
 	netdev_for_each_uc_addr(ha, dev) {
 		addr[naddr++] = ha->addr;
 		if (--uc_cnt == 0 || naddr >= ARRAY_SIZE(addr)) {
-			ret = t4_alloc_mac_filt(pi->adapter, 0, pi->viid, free,
+			ret = t4_alloc_mac_filt(pi->adapter, mb, pi->viid, free,
 					naddr, addr, filt_idx, &uhash, sleep);
 			if (ret < 0)
 				return ret;
@@ -333,7 +334,7 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
 	netdev_for_each_mc_addr(ha, dev) {
 		addr[naddr++] = ha->addr;
 		if (--mc_cnt == 0 || naddr >= ARRAY_SIZE(addr)) {
-			ret = t4_alloc_mac_filt(pi->adapter, 0, pi->viid, free,
+			ret = t4_alloc_mac_filt(pi->adapter, mb, pi->viid, free,
 					naddr, addr, filt_idx, &mhash, sleep);
 			if (ret < 0)
 				return ret;
@@ -343,7 +344,7 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
 		}
 	}
 
-	return t4_set_addr_hash(pi->adapter, 0, pi->viid, uhash != 0,
+	return t4_set_addr_hash(pi->adapter, mb, pi->viid, uhash != 0,
 				uhash | mhash, sleep);
 }
 
@@ -358,7 +359,7 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 
 	ret = set_addr_filters(dev, sleep_ok);
 	if (ret == 0)
-		ret = t4_set_rxmode(pi->adapter, 0, pi->viid, mtu,
+		ret = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, mtu,
 				    (dev->flags & IFF_PROMISC) ? 1 : 0,
 				    (dev->flags & IFF_ALLMULTI) ? 1 : 0, 1, -1,
 				    sleep_ok);
@@ -375,15 +376,16 @@ static int link_start(struct net_device *dev)
 {
 	int ret;
 	struct port_info *pi = netdev_priv(dev);
+	unsigned int mb = pi->adapter->fn;
 
 	/*
 	 * We do not set address filters and promiscuity here, the stack does
 	 * that step explicitly.
 	 */
-	ret = t4_set_rxmode(pi->adapter, 0, pi->viid, dev->mtu, -1, -1, -1,
+	ret = t4_set_rxmode(pi->adapter, mb, pi->viid, dev->mtu, -1, -1, -1,
 			    pi->vlan_grp != NULL, true);
 	if (ret == 0) {
-		ret = t4_change_mac(pi->adapter, 0, pi->viid,
+		ret = t4_change_mac(pi->adapter, mb, pi->viid,
 				    pi->xact_addr_filt, dev->dev_addr, true,
 				    true);
 		if (ret >= 0) {
@@ -392,9 +394,10 @@ static int link_start(struct net_device *dev)
 		}
 	}
 	if (ret == 0)
-		ret = t4_link_start(pi->adapter, 0, pi->tx_chan, &pi->link_cfg);
+		ret = t4_link_start(pi->adapter, mb, pi->tx_chan,
+				    &pi->link_cfg);
 	if (ret == 0)
-		ret = t4_enable_vi(pi->adapter, 0, pi->viid, true, true);
+		ret = t4_enable_vi(pi->adapter, mb, pi->viid, true, true);
 	return ret;
 }
 
@@ -618,8 +621,8 @@ static int write_rss(const struct port_info *pi, const u16 *queues)
 	for (i = 0; i < pi->rss_size; i++, queues++)
 		rss[i] = q[*queues].rspq.abs_id;
 
-	err = t4_config_rss_range(pi->adapter, 0, pi->viid, 0, pi->rss_size,
-				  rss, pi->rss_size);
+	err = t4_config_rss_range(pi->adapter, pi->adapter->fn, pi->viid, 0,
+				  pi->rss_size, rss, pi->rss_size);
 	kfree(rss);
 	return err;
 }
@@ -1307,16 +1310,18 @@ static int restart_autoneg(struct net_device *dev)
 		return -EAGAIN;
 	if (p->link_cfg.autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
-	t4_restart_aneg(p->adapter, 0, p->tx_chan);
+	t4_restart_aneg(p->adapter, p->adapter->fn, p->tx_chan);
 	return 0;
 }
 
 static int identify_port(struct net_device *dev, u32 data)
 {
+	struct adapter *adap = netdev2adap(dev);
+
 	if (data == 0)
 		data = 2;     /* default to 2 seconds */
 
-	return t4_identify_port(netdev2adap(dev), 0, netdev2pinfo(dev)->viid,
+	return t4_identify_port(adap, adap->fn, netdev2pinfo(dev)->viid,
 				data * 5);
 }
 
@@ -1456,7 +1461,8 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	lc->autoneg = cmd->autoneg;
 
 	if (netif_running(dev))
-		return t4_link_start(p->adapter, 0, p->tx_chan, lc);
+		return t4_link_start(p->adapter, p->adapter->fn, p->tx_chan,
+				     lc);
 	return 0;
 }
 
@@ -1488,7 +1494,8 @@ static int set_pauseparam(struct net_device *dev,
 	if (epause->tx_pause)
 		lc->requested_fc |= PAUSE_TX;
 	if (netif_running(dev))
-		return t4_link_start(p->adapter, 0, p->tx_chan, lc);
+		return t4_link_start(p->adapter, p->adapter->fn, p->tx_chan,
+				     lc);
 	return 0;
 }
 
@@ -1620,7 +1627,8 @@ static int set_rxq_intr_params(struct adapter *adap, struct sge_rspq *q,
 			v = FW_PARAMS_MNEM(FW_PARAMS_MNEM_DMAQ) |
 			    FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DMAQ_IQ_INTCNTTHRESH) |
 			    FW_PARAMS_PARAM_YZ(q->cntxt_id);
-			err = t4_set_params(adap, 0, 0, 0, 1, &v, &new_idx);
+			err = t4_set_params(adap, adap->fn, adap->fn, 0, 1, &v,
+					    &new_idx);
 			if (err)
 				return err;
 		}
@@ -2496,9 +2504,11 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.adapter_type = adap->params.rev;
 	lli.iscsi_iolen = MAXRXDATA_GET(t4_read_reg(adap, TP_PARA_REG2));
 	lli.udb_density = 1 << QUEUESPERPAGEPF0_GET(
-			t4_read_reg(adap, SGE_EGRESS_QUEUES_PER_PAGE_PF));
+			t4_read_reg(adap, SGE_EGRESS_QUEUES_PER_PAGE_PF) >>
+			(adap->fn * 4));
 	lli.ucq_density = 1 << QUEUESPERPAGEPF0_GET(
-			t4_read_reg(adap, SGE_INGRESS_QUEUES_PER_PAGE_PF));
+			t4_read_reg(adap, SGE_INGRESS_QUEUES_PER_PAGE_PF) >>
+			(adap->fn * 4));
 	lli.gts_reg = adap->regs + MYPF_REG(SGE_PF_GTS);
 	lli.db_reg = adap->regs + MYPF_REG(SGE_PF_KDOORBELL);
 	lli.fw_vers = adap->params.fw_vers;
@@ -2715,7 +2725,7 @@ static int cxgb_close(struct net_device *dev)
 
 	netif_tx_stop_all_queues(dev);
 	netif_carrier_off(dev);
-	return t4_enable_vi(adapter, 0, pi->viid, false, false);
+	return t4_enable_vi(adapter, adapter->fn, pi->viid, false, false);
 }
 
 static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
@@ -2762,6 +2772,7 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 
 static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
+	unsigned int mbox;
 	int ret = 0, prtad, devad;
 	struct port_info *pi = netdev_priv(dev);
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&req->ifr_data;
@@ -2784,11 +2795,12 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		} else
 			return -EINVAL;
 
+		mbox = pi->adapter->fn;
 		if (cmd == SIOCGMIIREG)
-			ret = t4_mdio_rd(pi->adapter, 0, prtad, devad,
+			ret = t4_mdio_rd(pi->adapter, mbox, prtad, devad,
 					 data->reg_num, &data->val_out);
 		else
-			ret = t4_mdio_wr(pi->adapter, 0, prtad, devad,
+			ret = t4_mdio_wr(pi->adapter, mbox, prtad, devad,
 					 data->reg_num, data->val_in);
 		break;
 	default:
@@ -2810,8 +2822,8 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 
 	if (new_mtu < 81 || new_mtu > MAX_MTU)         /* accommodate SACK */
 		return -EINVAL;
-	ret = t4_set_rxmode(pi->adapter, 0, pi->viid, new_mtu, -1, -1, -1, -1,
-			    true);
+	ret = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, new_mtu, -1,
+			    -1, -1, -1, true);
 	if (!ret)
 		dev->mtu = new_mtu;
 	return ret;
@@ -2826,8 +2838,8 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
-	ret = t4_change_mac(pi->adapter, 0, pi->viid, pi->xact_addr_filt,
-			    addr->sa_data, true, true);
+	ret = t4_change_mac(pi->adapter, pi->adapter->fn, pi->viid,
+			    pi->xact_addr_filt, addr->sa_data, true, true);
 	if (ret < 0)
 		return ret;
 
@@ -2841,8 +2853,8 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	struct port_info *pi = netdev_priv(dev);
 
 	pi->vlan_grp = grp;
-	t4_set_rxmode(pi->adapter, 0, pi->viid, -1, -1, -1, -1, grp != NULL,
-		      true);
+	t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1, -1, -1, -1,
+		      grp != NULL, true);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2926,7 +2938,7 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
 			       FW_CMD_REQUEST | FW_CMD_READ);
 	c->retval_len16 = htonl(FW_LEN16(*c));
-	ret = t4_wr_mbox(adap, 0, c, sizeof(*c), c);
+	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), c);
 	if (ret < 0)
 		return ret;
 
@@ -2942,36 +2954,33 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	}
 	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
 			       FW_CMD_REQUEST | FW_CMD_WRITE);
-	ret = t4_wr_mbox(adap, 0, c, sizeof(*c), NULL);
+	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), NULL);
 	if (ret < 0)
 		return ret;
 
-	ret = t4_config_glbl_rss(adap, 0,
+	ret = t4_config_glbl_rss(adap, adap->fn,
 				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
 				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN |
 				 FW_RSS_GLB_CONFIG_CMD_TNLALLLKP);
 	if (ret < 0)
 		return ret;
 
-	ret = t4_cfg_pfvf(adap, 0, 0, 0, MAX_EGRQ, 64, MAX_INGQ, 0, 0, 4,
-			  0xf, 0xf, 16, FW_CMD_CAP_PF, FW_CMD_CAP_PF);
+	ret = t4_cfg_pfvf(adap, adap->fn, adap->fn, 0, MAX_EGRQ, 64, MAX_INGQ,
+			  0, 0, 4, 0xf, 0xf, 16, FW_CMD_CAP_PF, FW_CMD_CAP_PF);
 	if (ret < 0)
 		return ret;
 
 	t4_sge_init(adap);
 
-	/* get basic stuff going */
-	ret = t4_early_init(adap, 0);
-	if (ret < 0)
-		return ret;
-
 	/* tweak some settings */
 	t4_write_reg(adap, TP_SHIFT_CNT, 0x64f8849);
 	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(PAGE_SHIFT - 12));
 	t4_write_reg(adap, TP_PIO_ADDR, TP_INGRESS_CONFIG);
 	v = t4_read_reg(adap, TP_PIO_DATA);
 	t4_write_reg(adap, TP_PIO_DATA, v & ~CSUM_HAS_PSEUDO_HDR);
-	return 0;
+
+	/* get basic stuff going */
+	return t4_early_init(adap, adap->fn);
 }
 
 /*
@@ -2999,7 +3008,7 @@ static int adap_init0(struct adapter *adap)
 		return ret;
 
 	/* contact FW, request master */
-	ret = t4_fw_hello(adap, 0, 0, MASTER_MUST, &state);
+	ret = t4_fw_hello(adap, adap->fn, adap->fn, MASTER_MUST, &state);
 	if (ret < 0) {
 		dev_err(adap->pdev_dev, "could not connect to FW, error %d\n",
 			ret);
@@ -3007,7 +3016,7 @@ static int adap_init0(struct adapter *adap)
 	}
 
 	/* reset device */
-	ret = t4_fw_reset(adap, 0, PIORSTMODE | PIORST);
+	ret = t4_fw_reset(adap, adap->fn, PIORSTMODE | PIORST);
 	if (ret < 0)
 		goto bye;
 
@@ -3023,7 +3032,7 @@ static int adap_init0(struct adapter *adap)
 	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_##param))
 
 	params[0] = FW_PARAM_DEV(CCLK);
-	ret = t4_query_params(adap, 0, 0, 0, 1, params, val);
+	ret = t4_query_params(adap, adap->fn, adap->fn, 0, 1, params, val);
 	if (ret < 0)
 		goto bye;
 	adap->params.vpd.cclk = val[0];
@@ -3034,14 +3043,15 @@ static int adap_init0(struct adapter *adap)
 
 #define FW_PARAM_PFVF(param) \
 	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) | \
-	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_##param))
+	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_##param) | \
+	 FW_PARAMS_PARAM_Y(adap->fn))
 
 	params[0] = FW_PARAM_DEV(PORTVEC);
 	params[1] = FW_PARAM_PFVF(L2T_START);
 	params[2] = FW_PARAM_PFVF(L2T_END);
 	params[3] = FW_PARAM_PFVF(FILTER_START);
 	params[4] = FW_PARAM_PFVF(FILTER_END);
-	ret = t4_query_params(adap, 0, 0, 0, 5, params, val);
+	ret = t4_query_params(adap, adap->fn, adap->fn, 0, 5, params, val);
 	if (ret < 0)
 		goto bye;
 	port_vec = val[0];
@@ -3056,7 +3066,8 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(TDDP_START);
 		params[4] = FW_PARAM_PFVF(TDDP_END);
 		params[5] = FW_PARAM_DEV(FLOWC_BUFFIFO_SZ);
-		ret = t4_query_params(adap, 0, 0, 0, 6, params, val);
+		ret = t4_query_params(adap, adap->fn, adap->fn, 0, 6, params,
+				      val);
 		if (ret < 0)
 			goto bye;
 		adap->tids.ntids = val[0];
@@ -3075,7 +3086,8 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(RQ_END);
 		params[4] = FW_PARAM_PFVF(PBL_START);
 		params[5] = FW_PARAM_PFVF(PBL_END);
-		ret = t4_query_params(adap, 0, 0, 0, 6, params, val);
+		ret = t4_query_params(adap, adap->fn, adap->fn, 0, 6, params,
+				      val);
 		if (ret < 0)
 			goto bye;
 		adap->vres.stag.start = val[0];
@@ -3091,7 +3103,8 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(CQ_END);
 		params[4] = FW_PARAM_PFVF(OCQ_START);
 		params[5] = FW_PARAM_PFVF(OCQ_END);
-		ret = t4_query_params(adap, 0, 0, 0, 6, params, val);
+		ret = t4_query_params(adap, adap->fn, adap->fn, 0, 6, params,
+				      val);
 		if (ret < 0)
 			goto bye;
 		adap->vres.qp.start = val[0];
@@ -3104,7 +3117,8 @@ static int adap_init0(struct adapter *adap)
 	if (c.iscsicaps) {
 		params[0] = FW_PARAM_PFVF(ISCSI_START);
 		params[1] = FW_PARAM_PFVF(ISCSI_END);
-		ret = t4_query_params(adap, 0, 0, 0, 2, params, val);
+		ret = t4_query_params(adap, adap->fn, adap->fn, 0, 2, params,
+				      val);
 		if (ret < 0)
 			goto bye;
 		adap->vres.iscsi.start = val[0];
@@ -3142,7 +3156,7 @@ static int adap_init0(struct adapter *adap)
 
 			/* VF numbering starts at 1! */
 			for (vf = 1; vf <= num_vf[pf]; vf++) {
-				ret = t4_cfg_pfvf(adap, 0, pf, vf,
+				ret = t4_cfg_pfvf(adap, adap->fn, pf, vf,
 						  VFRES_NEQ, VFRES_NETHCTRL,
 						  VFRES_NIQFLINT, VFRES_NIQ,
 						  VFRES_TC, VFRES_NVI,
@@ -3168,7 +3182,7 @@ static int adap_init0(struct adapter *adap)
 	 * commands.
 	 */
 bye:	if (ret != -ETIMEDOUT && ret != -EIO)
-		t4_fw_bye(adap, 0);
+		t4_fw_bye(adap, adap->fn);
 	return ret;
 }
 
@@ -3224,7 +3238,7 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 
 	if (t4_wait_dev_ready(adap) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
-	if (t4_fw_hello(adap, 0, 0, MASTER_MUST, NULL))
+	if (t4_fw_hello(adap, adap->fn, adap->fn, MASTER_MUST, NULL))
 		return PCI_ERS_RESULT_DISCONNECT;
 	adap->flags |= FW_OK;
 	if (adap_init1(adap, &c))
@@ -3233,7 +3247,8 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 	for_each_port(adap, i) {
 		struct port_info *p = adap2pinfo(adap, i);
 
-		ret = t4_alloc_vi(adap, 0, p->tx_chan, 0, 0, 1, NULL, NULL);
+		ret = t4_alloc_vi(adap, adap->fn, p->tx_chan, adap->fn, 0, 1,
+				  NULL, NULL);
 		if (ret < 0)
 			return PCI_ERS_RESULT_DISCONNECT;
 		p->viid = ret;
@@ -3538,7 +3553,7 @@ static void free_some_resources(struct adapter *adapter)
 			free_netdev(adapter->port[i]);
 		}
 	if (adapter->flags & FW_OK)
-		t4_fw_bye(adapter, 0);
+		t4_fw_bye(adapter, adapter->fn);
 }
 
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
@@ -3561,9 +3576,9 @@ static int __devinit init_one(struct pci_dev *pdev,
 		return err;
 	}
 
-	/* We control everything through PF 0 */
+	/* We control everything through one PF */
 	func = PCI_FUNC(pdev->devfn);
-	if (func > 0) {
+	if (func != ent->driver_data) {
 		pci_save_state(pdev);        /* to restore SR-IOV later */
 		goto sriov;
 	}
@@ -3609,6 +3624,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 	adapter->pdev = pdev;
 	adapter->pdev_dev = &pdev->dev;
+	adapter->fn = func;
 	adapter->name = pci_name(pdev);
 	adapter->msg_enable = dflt_msg_enable;
 	memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
@@ -3660,7 +3676,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, adapter);
 
 	if (adapter->flags & FW_OK) {
-		err = t4_port_init(adapter, 0, 0, 0);
+		err = t4_port_init(adapter, func, func, 0);
 		if (err)
 			goto out_free_dev;
 	}
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 5cacfc7..bf38cfc 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1999,7 +1999,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP(FW_IQ_CMD) | FW_CMD_REQUEST |
 			    FW_CMD_WRITE | FW_CMD_EXEC |
-			    FW_IQ_CMD_PFN(0) | FW_IQ_CMD_VFN(0));
+			    FW_IQ_CMD_PFN(adap->fn) | FW_IQ_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC | FW_IQ_CMD_IQSTART(1) |
 				 FW_LEN16(c));
 	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE(FW_IQ_TYPE_FL_INT_CAP) |
@@ -2031,7 +2031,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		c.fl0addr = cpu_to_be64(fl->addr);
 	}
 
-	ret = t4_wr_mbox(adap, 0, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
 	if (ret)
 		goto err;
 
@@ -2110,7 +2110,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_ETH_CMD) | FW_CMD_REQUEST |
 			    FW_CMD_WRITE | FW_CMD_EXEC |
-			    FW_EQ_ETH_CMD_PFN(0) | FW_EQ_ETH_CMD_VFN(0));
+			    FW_EQ_ETH_CMD_PFN(adap->fn) | FW_EQ_ETH_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_ALLOC |
 				 FW_EQ_ETH_CMD_EQSTART | FW_LEN16(c));
 	c.viid_pkd = htonl(FW_EQ_ETH_CMD_VIID(pi->viid));
@@ -2123,7 +2123,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 				  FW_EQ_ETH_CMD_EQSIZE(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
-	ret = t4_wr_mbox(adap, 0, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
 	if (ret) {
 		kfree(txq->q.sdesc);
 		txq->q.sdesc = NULL;
@@ -2160,7 +2160,8 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 
 	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST |
 			    FW_CMD_WRITE | FW_CMD_EXEC |
-			    FW_EQ_CTRL_CMD_PFN(0) | FW_EQ_CTRL_CMD_VFN(0));
+			    FW_EQ_CTRL_CMD_PFN(adap->fn) |
+			    FW_EQ_CTRL_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_ALLOC |
 				 FW_EQ_CTRL_CMD_EQSTART | FW_LEN16(c));
 	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_CMPLIQID(cmplqid));
@@ -2174,7 +2175,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 				  FW_EQ_CTRL_CMD_EQSIZE(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
-	ret = t4_wr_mbox(adap, 0, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
 	if (ret) {
 		dma_free_coherent(adap->pdev_dev,
 				  nentries * sizeof(struct tx_desc),
@@ -2210,7 +2211,8 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST |
 			    FW_CMD_WRITE | FW_CMD_EXEC |
-			    FW_EQ_OFLD_CMD_PFN(0) | FW_EQ_OFLD_CMD_VFN(0));
+			    FW_EQ_OFLD_CMD_PFN(adap->fn) |
+			    FW_EQ_OFLD_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC |
 				 FW_EQ_OFLD_CMD_EQSTART | FW_LEN16(c));
 	c.fetchszm_to_iqid = htonl(FW_EQ_OFLD_CMD_HOSTFCMODE(2) |
@@ -2222,7 +2224,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 				  FW_EQ_OFLD_CMD_EQSIZE(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
-	ret = t4_wr_mbox(adap, 0, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
 	if (ret) {
 		kfree(txq->q.sdesc);
 		txq->q.sdesc = NULL;
@@ -2258,8 +2260,8 @@ static void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
 	unsigned int fl_id = fl ? fl->cntxt_id : 0xffff;
 
 	adap->sge.ingr_map[rq->cntxt_id] = NULL;
-	t4_iq_free(adap, 0, 0, 0, FW_IQ_TYPE_FL_INT_CAP, rq->cntxt_id, fl_id,
-		   0xffff);
+	t4_iq_free(adap, adap->fn, adap->fn, 0, FW_IQ_TYPE_FL_INT_CAP,
+		   rq->cntxt_id, fl_id, 0xffff);
 	dma_free_coherent(adap->pdev_dev, (rq->size + 1) * rq->iqe_len,
 			  rq->desc, rq->phys_addr);
 	netif_napi_del(&rq->napi);
@@ -2296,7 +2298,8 @@ void t4_free_sge_resources(struct adapter *adap)
 		if (eq->rspq.desc)
 			free_rspq_fl(adap, &eq->rspq, &eq->fl);
 		if (etq->q.desc) {
-			t4_eth_eq_free(adap, 0, 0, 0, etq->q.cntxt_id);
+			t4_eth_eq_free(adap, adap->fn, adap->fn, 0,
+				       etq->q.cntxt_id);
 			free_tx_desc(adap, &etq->q, etq->q.in_use, true);
 			kfree(etq->q.sdesc);
 			free_txq(adap, &etq->q);
@@ -2319,7 +2322,8 @@ void t4_free_sge_resources(struct adapter *adap)
 
 		if (q->q.desc) {
 			tasklet_kill(&q->qresume_tsk);
-			t4_ofld_eq_free(adap, 0, 0, 0, q->q.cntxt_id);
+			t4_ofld_eq_free(adap, adap->fn, adap->fn, 0,
+					q->q.cntxt_id);
 			free_tx_desc(adap, &q->q, q->q.in_use, false);
 			kfree(q->q.sdesc);
 			__skb_queue_purge(&q->sendq);
@@ -2333,7 +2337,8 @@ void t4_free_sge_resources(struct adapter *adap)
 
 		if (cq->q.desc) {
 			tasklet_kill(&cq->qresume_tsk);
-			t4_ctrl_eq_free(adap, 0, 0, 0, cq->q.cntxt_id);
+			t4_ctrl_eq_free(adap, adap->fn, adap->fn, 0,
+					cq->q.cntxt_id);
 			__skb_queue_purge(&cq->sendq);
 			free_txq(adap, &cq->q);
 		}
@@ -2401,6 +2406,7 @@ void t4_sge_stop(struct adapter *adap)
  */
 void t4_sge_init(struct adapter *adap)
 {
+	unsigned int i, v;
 	struct sge *s = &adap->sge;
 	unsigned int fl_align_log = ilog2(FL_ALIGN);
 
@@ -2409,8 +2415,10 @@ void t4_sge_init(struct adapter *adap)
 			 INGPADBOUNDARY(fl_align_log - 5) | PKTSHIFT(2) |
 			 RXPKTCPLMODE |
 			 (STAT_LEN == 128 ? EGRSTATUSPAGESIZE : 0));
-	t4_set_reg_field(adap, SGE_HOST_PAGE_SIZE, HOSTPAGESIZEPF0_MASK,
-			 HOSTPAGESIZEPF0(PAGE_SHIFT - 10));
+
+	for (i = v = 0; i < 32; i += 4)
+		v |= (PAGE_SHIFT - 10) << i;
+	t4_write_reg(adap, SGE_HOST_PAGE_SIZE, v);
 	t4_write_reg(adap, SGE_FL_BUFFER_SIZE0, PAGE_SIZE);
 #if FL_PG_ORDER > 0
 	t4_write_reg(adap, SGE_FL_BUFFER_SIZE1, PAGE_SIZE << FL_PG_ORDER);
-- 
1.5.4

