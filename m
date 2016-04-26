From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/8] cxgb4: Refactor t4_port_init function
Date: Tue, 26 Apr 2016 20:10:26 +0530
Message-ID: <1461681629-28275-6-git-send-email-hariprasad@chelsio.com>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:3027 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751845AbcDZOgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:36:39 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor t4_port_init() so that the core functionality is done by
t4_init_portinfo() for a particular port. Also rename variables to
sensible ones.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |  2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 93 +++++++++++++++++-------------
 2 files changed, 55 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 459775884cad..f69119bc5990 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1333,6 +1333,8 @@ int t4_init_sge_params(struct adapter *adapter);
 int t4_init_tp_params(struct adapter *adap);
 int t4_filter_field_shift(const struct adapter *adap, int filter_sel);
 int t4_init_rss_mode(struct adapter *adap, int mbox);
+int t4_init_portinfo(struct port_info *pi, int mbox,
+		     int port, int pf, int vf, u8 mac[]);
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
 void t4_fatal_err(struct adapter *adapter);
 int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 2ced24fc569d..1ebbbb9323e3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7668,61 +7668,74 @@ int t4_init_rss_mode(struct adapter *adap, int mbox)
 	return 0;
 }
 
-int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
+/**
+ *	t4_init_portinfo - allocate a virtual interface amd initialize port_info
+ *	@pi: the port_info
+ *	@mbox: mailbox to use for the FW command
+ *	@port: physical port associated with the VI
+ *	@pf: the PF owning the VI
+ *	@vf: the VF owning the VI
+ *	@mac: the MAC address of the VI
+ *
+ *	Allocates a virtual interface for the given physical port.  If @mac is
+ *	not %NULL it contains the MAC address of the VI as assigned by FW.
+ *	@mac should be large enough to hold an Ethernet address.
+ *	Returns < 0 on error.
+ */
+int t4_init_portinfo(struct port_info *pi, int mbox,
+		     int port, int pf, int vf, u8 mac[])
 {
-	u8 addr[6];
-	int ret, i, j = 0;
+	int ret;
 	struct fw_port_cmd c;
-	struct fw_rss_vi_config_cmd rvc;
+	unsigned int rss_size;
 
 	memset(&c, 0, sizeof(c));
-	memset(&rvc, 0, sizeof(rvc));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+				     FW_CMD_REQUEST_F | FW_CMD_READ_F |
+				     FW_PORT_CMD_PORTID_V(port));
+	c.action_to_len16 = cpu_to_be32(
+		FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
+		FW_LEN16(c));
+	ret = t4_wr_mbox(pi->adapter, mbox, &c, sizeof(c), &c);
+	if (ret)
+		return ret;
+
+	ret = t4_alloc_vi(pi->adapter, mbox, port, pf, vf, 1, mac, &rss_size);
+	if (ret < 0)
+		return ret;
+
+	pi->viid = ret;
+	pi->tx_chan = port;
+	pi->lport = port;
+	pi->rss_size = rss_size;
+
+	ret = be32_to_cpu(c.u.info.lstatus_to_modtype);
+	pi->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP_F) ?
+		FW_PORT_CMD_MDIOADDR_G(ret) : -1;
+	pi->port_type = FW_PORT_CMD_PTYPE_G(ret);
+	pi->mod_type = FW_PORT_MOD_TYPE_NA;
+
+	init_link_config(&pi->link_cfg, be16_to_cpu(c.u.info.pcap));
+	return 0;
+}
+
+int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
+{
+	u8 addr[6];
+	int ret, i, j = 0;
 
 	for_each_port(adap, i) {
-		unsigned int rss_size;
-		struct port_info *p = adap2pinfo(adap, i);
+		struct port_info *pi = adap2pinfo(adap, i);
 
 		while ((adap->params.portvec & (1 << j)) == 0)
 			j++;
 
-		c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
-					     FW_CMD_REQUEST_F | FW_CMD_READ_F |
-					     FW_PORT_CMD_PORTID_V(j));
-		c.action_to_len16 = cpu_to_be32(
-			FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
-			FW_LEN16(c));
-		ret = t4_wr_mbox(adap, mbox, &c, sizeof(c), &c);
+		ret = t4_init_portinfo(pi, mbox, j, pf, vf, addr);
 		if (ret)
 			return ret;
 
-		ret = t4_alloc_vi(adap, mbox, j, pf, vf, 1, addr, &rss_size);
-		if (ret < 0)
-			return ret;
-
-		p->viid = ret;
-		p->tx_chan = j;
-		p->lport = j;
-		p->rss_size = rss_size;
 		memcpy(adap->port[i]->dev_addr, addr, ETH_ALEN);
 		adap->port[i]->dev_port = j;
-
-		ret = be32_to_cpu(c.u.info.lstatus_to_modtype);
-		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP_F) ?
-			FW_PORT_CMD_MDIOADDR_G(ret) : -1;
-		p->port_type = FW_PORT_CMD_PTYPE_G(ret);
-		p->mod_type = FW_PORT_MOD_TYPE_NA;
-
-		rvc.op_to_viid =
-			cpu_to_be32(FW_CMD_OP_V(FW_RSS_VI_CONFIG_CMD) |
-				    FW_CMD_REQUEST_F | FW_CMD_READ_F |
-				    FW_RSS_VI_CONFIG_CMD_VIID(p->viid));
-		rvc.retval_len16 = cpu_to_be32(FW_LEN16(rvc));
-		ret = t4_wr_mbox(adap, mbox, &rvc, sizeof(rvc), &rvc);
-		if (ret)
-			return ret;
-		p->rss_mode = be32_to_cpu(rvc.u.basicvirtual.defaultq_to_udpen);
-
-		init_link_config(&p->link_cfg, be16_to_cpu(c.u.info.pcap));
 		j++;
 	}
 	return 0;
-- 
2.3.4
