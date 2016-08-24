From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4/cxgb4vf: Add support for ndo_set_vf_vlan
Date: Wed, 24 Aug 2016 12:20:33 +0530
Message-ID: <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:20843 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752605AbcHXGvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:51:44 -0400
In-Reply-To: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   21 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   25 +++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   15 ++++++++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   28 ++++++++++++++++++++
 8 files changed, 91 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 3f7b33a..b20d345 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1627,6 +1627,7 @@ void t4_idma_monitor(struct adapter *adapter,
 		     int hz, int ticks);
 int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int vf,
 		      unsigned int naddr, u8 *addr);
+int t4_set_vf_vlan_acl(struct adapter *adapter, unsigned int vf, u16 vlan);
 void uld_mem_free(struct adapter *adap);
 int uld_mem_alloc(struct adapter *adap);
 void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq, struct sge_fl *fl);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 44019bd..330e18a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3111,6 +3111,26 @@ static int cxgb_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 		 "Setting MAC %pM on VF %d\n", mac, vf);
 	return t4_set_vf_mac_acl(adap, vf + 1, 1, mac);
 }
+
+static int cxgb_set_vf_vlan(struct net_device *dev, int vf, u16 vlan, u8 qos)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
+
+	if (vlan > 4095 || qos > 7) {
+		dev_err(pi->adapter->pdev_dev,
+			"Illegal vlan value %u qos %u\n", vlan, qos);
+		return -EINVAL;
+	}
+
+	dev_info(pi->adapter->pdev_dev,
+		 "Setting Vlan %u to VF [%d]\n", vlan, vf);
+	dev_info(pi->adapter->pdev_dev,
+		 "The VF [%d] interface needs to brought down and up, "
+		 "if VF is already up and running, for VST to work\n", vf);
+	vlan |= qos << VLAN_PRIO_SHIFT;
+	return t4_set_vf_vlan_acl(adap, vf + 1, vlan);
+}
 #endif
 
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
@@ -3259,6 +3279,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
 	.ndo_open             = dummy_open,
 	.ndo_set_vf_mac       = cxgb_set_vf_mac,
+	.ndo_set_vf_vlan      = cxgb_set_vf_vlan,
 };
 #endif
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index de451ee..210979c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -8334,3 +8334,28 @@ int t4_sched_params(struct adapter *adapter, int type, int level, int mode,
 	return t4_wr_mbox_meat(adapter, adapter->mbox, &cmd, sizeof(cmd),
 			       NULL, 1);
 }
+
+/**
+ *	t4_set_vf_vlan_acl - Set MAC address for the specified VF
+ *	@adapter: The adapter
+ *	@vf: one of the VFs instantiated by the specified PF
+ *	@vlan: the vlan id
+ *	@qos: QOS
+ */
+int t4_set_vf_vlan_acl(struct adapter *adapter, unsigned int vf, u16 vlan)
+{
+	struct fw_acl_vlan_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+
+	cmd.op_to_vfn = htonl(FW_CMD_OP_V(FW_ACL_VLAN_CMD) |
+			      FW_CMD_REQUEST_F |
+			      FW_CMD_WRITE_F |
+			      FW_ACL_MAC_CMD_PFN_V(adapter->pf) |
+			      FW_ACL_MAC_CMD_VFN_V(vf));
+	cmd.en_to_len16 = htonl((unsigned int)FW_LEN16(cmd));
+	cmd.nvlan = 1;
+	cmd.vlanid[0] = vlan;
+
+	return t4_wr_mbox(adapter, adapter->mbox, &cmd, sizeof(cmd), &cmd);
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 109bc63..ed1037e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -92,6 +92,7 @@ struct sge_rspq;
  */
 struct port_info {
 	struct adapter *adapter;	/* our adapter */
+	u32 vlan_id;			/* vlan id for VST */
 	u16 viid;			/* virtual interface ID */
 	s16 xact_addr_filt;		/* index of our MAC address filter */
 	u16 rss_size;			/* size of VI's RSS table slice */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index f2951bf..d6324a6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -795,6 +795,8 @@ static int cxgb4vf_open(struct net_device *dev)
 	if (err)
 		goto err_unwind;
 
+	pi->vlan_id = t4vf_get_vf_vlan_acl(adapter);
+
 	netif_tx_start_all_queues(dev);
 	set_bit(pi->port_id, &adapter->open_device_map);
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index c8fd4f8..9a9963b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1202,6 +1202,10 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	BUG_ON(qidx >= pi->nqsets);
 	txq = &adapter->sge.ethtxq[pi->first_qset + qidx];
 
+	if (pi->vlan_id && !skb_vlan_tag_present(skb))
+		__vlan_hwaccel_put_tag(skb, cpu_to_be16(ETH_P_8021Q),
+				       pi->vlan_id);
+
 	/*
 	 * Take this opportunity to reclaim any TX Descriptors whose DMA
 	 * transfers have completed.
@@ -1570,6 +1574,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 {
 	struct adapter *adapter = rxq->rspq.adapter;
 	struct sge *s = &adapter->sge;
+	struct port_info *pi;
 	int ret;
 	struct sk_buff *skb;
 
@@ -1586,8 +1591,9 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->truesize += skb->data_len;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
+	pi = netdev_priv(skb->dev);
 
-	if (pkt->vlan_ex) {
+	if (pkt->vlan_ex && !pi->vlan_id) {
 		__vlan_hwaccel_put_tag(skb, cpu_to_be16(ETH_P_8021Q),
 					be16_to_cpu(pkt->vlan));
 		rxq->stats.vlan_ex++;
@@ -1620,6 +1626,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
 	struct adapter *adapter = rspq->adapter;
 	struct sge *s = &adapter->sge;
+	struct port_info *pi;
 
 	/*
 	 * If this is a good TCP packet and we have Generic Receive Offload
@@ -1644,6 +1651,7 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	__skb_pull(skb, s->pktshift);
 	skb->protocol = eth_type_trans(skb, rspq->netdev);
 	skb_record_rx_queue(skb, rspq->idx);
+	pi = netdev_priv(skb->dev);
 	rxq->stats.pkts++;
 
 	if (csum_ok && !pkt->err_vec &&
@@ -1659,9 +1667,10 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	} else
 		skb_checksum_none_assert(skb);
 
-	if (pkt->vlan_ex) {
+	if (pkt->vlan_ex && !pi->vlan_id) {
 		rxq->stats.vlan_ex++;
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(pkt->vlan));
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       be16_to_cpu(pkt->vlan));
 	}
 
 	netif_receive_skb(skb);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 8067424..fa06344 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -384,5 +384,6 @@ int t4vf_handle_fw_rpl(struct adapter *, const __be64 *);
 int t4vf_prep_adapter(struct adapter *);
 int t4vf_get_vf_mac_acl(struct adapter *adapter, unsigned int pf,
 			unsigned int *naddr, u8 *addr);
+int t4vf_get_vf_vlan_acl(struct adapter *adapter);
 
 #endif /* __T4VF_COMMON_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 879f4c5..b46f6f3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -1858,3 +1858,31 @@ int t4vf_get_vf_mac_acl(struct adapter *adapter, unsigned int pf,
 
 	return ret;
 }
+
+/**
+ *	t4vf_get_vf_vlan_acl - Get the VLAN ID to be set to
+ *                             the VI of this VF.
+ *	@adapter: The adapter
+ *
+ *	Find the VLAN ID to be set to the VF's VI. The requested VLAN ID
+ *	is from the host OS via callback in the PF driver.
+ */
+int t4vf_get_vf_vlan_acl(struct adapter *adapter)
+{
+	struct fw_acl_vlan_cmd cmd;
+	int vlan = 0;
+	int ret = 0;
+
+	cmd.op_to_vfn = htonl(FW_CMD_OP_V(FW_ACL_VLAN_CMD) |
+			      FW_CMD_REQUEST_F | FW_CMD_READ_F);
+
+	/* Note: Do not enable the ACL */
+	cmd.en_to_len16 = htonl((unsigned int)FW_LEN16(cmd));
+
+	ret = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &cmd);
+
+	if (!ret)
+		vlan = cmd.vlanid[0];
+
+	return vlan;
+}
-- 
1.7.3
