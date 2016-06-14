From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 8/9] liquidio: Replace ifidx for FW commands
Date: Tue, 14 Jun 2016 16:54:50 -0700
Message-ID: <1465948491-10541-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:3775
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751401AbcFNXzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 19:55:54 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch decoupled the firmware side ifidx and host side interface
number. It also has some minor name change for linkinfo sturct field.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  33 ++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 205 +++++++++++----------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  55 +++---
 .../net/ethernet/cavium/liquidio/octeon_device.c   |   2 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   1 +
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   4 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |   3 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  12 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   6 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  12 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |  23 ++-
 .../net/ethernet/cavium/liquidio/request_manager.c |   5 +
 12 files changed, 187 insertions(+), 174 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 2937c802..4523c86 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -127,7 +127,7 @@ static int lio_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		dev_err(&oct->pci_dev->dev, "Unknown link interface reported\n");
 	}
 
-	if (linfo->link.s.status) {
+	if (linfo->link.s.link_up) {
 		ethtool_cmd_speed_set(ecmd, linfo->link.s.speed);
 		ecmd->duplex = linfo->link.s.duplex;
 	} else {
@@ -222,23 +222,20 @@ static int octnet_gpio_access(struct net_device *netdev, int addr, int val)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int ret = 0;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_GPIO_ACCESS;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = addr;
-	nctrl.ncmd.s.param3 = val;
+	nctrl.ncmd.s.param1 = addr;
+	nctrl.ncmd.s.param2 = val;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Failed to configure gpio value\n");
 		return -EINVAL;
@@ -303,9 +300,10 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 	mdio_cmd->mdio_addr = loc;
 	if (op)
 		mdio_cmd->value1 = *value;
-	mdio_cmd->value2 = lio->linfo.ifidx;
 	octeon_swap_8B_data((u64 *)mdio_cmd, sizeof(struct oct_mdio_cmd) / 8);
 
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
 	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC, OPCODE_NIC_MDIO45,
 				    0, 0, 0);
 
@@ -503,10 +501,10 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	if ((msglvl ^ lio->msg_enable) & NETIF_MSG_HW) {
 		if (msglvl & NETIF_MSG_HW)
 			liquidio_set_feature(netdev,
-					     OCTNET_CMD_VERBOSE_ENABLE);
+					     OCTNET_CMD_VERBOSE_ENABLE, 0);
 		else
 			liquidio_set_feature(netdev,
-					     OCTNET_CMD_VERBOSE_DISABLE);
+					     OCTNET_CMD_VERBOSE_DISABLE, 0);
 	}
 
 	lio->msg_enable = msglvl;
@@ -950,7 +948,6 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	struct octeon_device *oct = lio->oct_dev;
 	struct oct_link_info *linfo;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int ret = 0;
 
 	/* get the link info */
@@ -978,9 +975,9 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_SETTINGS;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 1000;
 	nctrl.netpndev = (u64)netdev;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
 	/* Passing the parameters sent by ethtool like Speed, Autoneg & Duplex
@@ -990,19 +987,17 @@ static int lio_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		/* Autoneg ON */
 		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON |
 				     OCTNIC_NCMD_AUTONEG_ON;
-		nctrl.ncmd.s.param2 = ecmd->advertising;
+		nctrl.ncmd.s.param1 = ecmd->advertising;
 	} else {
 		/* Autoneg OFF */
 		nctrl.ncmd.s.more = OCTNIC_NCMD_PHY_ON;
 
-		nctrl.ncmd.s.param3 = ecmd->duplex;
+		nctrl.ncmd.s.param2 = ecmd->duplex;
 
-		nctrl.ncmd.s.param2 = ecmd->speed;
+		nctrl.ncmd.s.param1 = ecmd->speed;
 	}
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Failed to set settings\n");
 		return -1;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 1f1a28d..4119e70 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -710,7 +710,7 @@ static void start_txq(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 
-	if (lio->linfo.link.s.status) {
+	if (lio->linfo.link.s.link_up) {
 		txqs_start(netdev);
 		return;
 	}
@@ -918,7 +918,7 @@ static void print_link_info(struct net_device *netdev)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED) {
 		struct oct_link_info *linfo = &lio->linfo;
 
-		if (linfo->link.s.status) {
+		if (linfo->link.s.link_up) {
 			netif_info(lio, link, lio->netdev, "%d Mbps %s Duplex UP\n",
 				   linfo->link.s.speed,
 				   (linfo->link.s.duplex) ? "Full" : "Half");
@@ -940,13 +940,15 @@ static inline void update_link_status(struct net_device *netdev,
 				      union oct_link_status *ls)
 {
 	struct lio *lio = GET_LIO(netdev);
+	int changed = (lio->linfo.link.u64 != ls->u64);
 
-	if ((lio->intf_open) && (lio->linfo.link.u64 != ls->u64)) {
-		lio->linfo.link.u64 = ls->u64;
+	lio->linfo.link.u64 = ls->u64;
 
+	if ((lio->intf_open) && (changed)) {
 		print_link_info(netdev);
+		lio->link_changes++;
 
-		if (lio->linfo.link.s.status) {
+		if (lio->linfo.link.s.link_up) {
 			netif_carrier_on(netdev);
 			/* start_txq(netdev); */
 			txqs_wake(netdev);
@@ -1219,18 +1221,15 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 static void send_rx_ctrl_cmd(struct lio *lio, int start_stop)
 {
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.s.cmd = OCTNET_CMD_RX_CTL;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = start_stop;
+	nctrl.ncmd.s.param1 = start_stop;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.netpndev = (u64)lio->netdev;
 
-	nparams.resp_order = OCTEON_RESP_NORESPONSE;
-
-	if (octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams) < 0)
+	if (octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl) < 0)
 		netif_info(lio, rx_err, lio->netdev, "Failed to send RX Control message\n");
 }
 
@@ -1269,6 +1268,8 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 
 	free_netdev(netdev);
 
+	oct->props[ifidx].gmxport = -1;
+
 	oct->props[ifidx].netdev = NULL;
 }
 
@@ -1833,21 +1834,21 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
  * @param len      - size of total data received.
  * @param rh       - Control header associated with the packet
  * @param param    - additional control data with the packet
+ * @param arg	   - farg registered in droq_ops
  */
 static void
 liquidio_push_packet(u32 octeon_id,
 		     void *skbuff,
 		     u32 len,
 		     union octeon_rh *rh,
-		     void *param)
+		     void *param,
+		     void *arg)
 {
 	struct napi_struct *napi = param;
-	struct octeon_device *oct = lio_get_device(octeon_id);
 	struct sk_buff *skb = (struct sk_buff *)skbuff;
 	struct skb_shared_hwtstamps *shhwtstamps;
 	u64 ns;
-	struct net_device *netdev =
-		(struct net_device *)oct->props[rh->r_dh.link].netdev;
+	struct net_device *netdev = (struct net_device *)arg;
 	struct octeon_droq *droq = container_of(param, struct octeon_droq,
 						napi);
 	if (netdev) {
@@ -2043,10 +2044,10 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
  * are for ingress packets.
  */
 static inline int setup_io_queues(struct octeon_device *octeon_dev,
-				  struct net_device *net_device)
+				  int ifidx)
 {
-	static int first_time = 1;
-	static struct octeon_droq_ops droq_ops;
+	struct octeon_droq_ops droq_ops;
+	struct net_device *netdev;
 	static int cpu_id;
 	static int cpu_id_modulus;
 	struct octeon_droq *droq;
@@ -2055,18 +2056,19 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 	struct lio *lio;
 	int num_tx_descs;
 
-	lio = GET_LIO(net_device);
-	if (first_time) {
-		first_time = 0;
-		memset(&droq_ops, 0, sizeof(struct octeon_droq_ops));
+	netdev = octeon_dev->props[ifidx].netdev;
+
+	lio = GET_LIO(netdev);
 
-		droq_ops.fptr = liquidio_push_packet;
+	memset(&droq_ops, 0, sizeof(struct octeon_droq_ops));
 
-		droq_ops.poll_mode = 1;
-		droq_ops.napi_fn = liquidio_napi_drv_callback;
-		cpu_id = 0;
-		cpu_id_modulus = num_present_cpus();
-	}
+	droq_ops.fptr = liquidio_push_packet;
+	droq_ops.farg = (void *)netdev;
+
+	droq_ops.poll_mode = 1;
+	droq_ops.napi_fn = liquidio_napi_drv_callback;
+	cpu_id = 0;
+	cpu_id_modulus = num_present_cpus();
 
 	/* set up DROQs. */
 	for (q = 0; q < lio->linfo.num_rxpciq; q++) {
@@ -2090,7 +2092,11 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 
 		droq = octeon_dev->droq[q_no];
 		napi = &droq->napi;
-		netif_napi_add(net_device, napi, liquidio_napi_poll, 64);
+		dev_dbg(&octeon_dev->pci_dev->dev,
+			"netif_napi_add netdev:%llx oct:%llx\n",
+			(u64)netdev,
+			(u64)octeon_dev);
+		netif_napi_add(netdev, napi, liquidio_napi_poll, 64);
 
 		/* designate a CPU for this droq */
 		droq->cpu_id = cpu_id;
@@ -2106,9 +2112,9 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 		num_tx_descs = CFG_GET_NUM_TX_DESCS_NIC_IF(octeon_get_conf
 							   (octeon_dev),
 							   lio->ifidx);
-		retval = octeon_setup_iq(octeon_dev, lio->linfo.txpciq[q],
-					 num_tx_descs,
-					 netdev_get_tx_queue(net_device, q));
+		retval = octeon_setup_iq(octeon_dev, ifidx, q,
+					 lio->linfo.txpciq[q], num_tx_descs,
+					 netdev_get_tx_queue(netdev, q));
 		if (retval) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				" %s : Runtime IQ(TxQ) creation failed.\n",
@@ -2206,7 +2212,8 @@ static int liquidio_stop(struct net_device *netdev)
 	netif_info(lio, ifdown, lio->netdev, "Stopping interface!\n");
 	/* Inform that netif carrier is down */
 	lio->intf_open = 0;
-	lio->linfo.link.s.status = 0;
+	lio->linfo.link.s.link_up = 0;
+	lio->link_changes++;
 
 	netif_carrier_off(netdev);
 
@@ -2345,7 +2352,6 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	struct netdev_hw_addr *ha;
 	u64 *mc;
 	int ret, i;
@@ -2356,10 +2362,10 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	/* Create a ctrl pkt command to be sent to core app. */
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_MULTI_LIST;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = get_new_flags(netdev);
-	nctrl.ncmd.s.param3 = mc_count;
+	nctrl.ncmd.s.param1 = get_new_flags(netdev);
+	nctrl.ncmd.s.param2 = mc_count;
 	nctrl.ncmd.s.more = mc_count;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
@@ -2380,9 +2386,7 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	 */
 	nctrl.wait_time = 0;
 
-	nparams.resp_order = OCTEON_RESP_NORESPONSE;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "DEVFLAGS change failed in core (ret: 0x%x)\n",
 			ret);
@@ -2400,19 +2404,17 @@ static int liquidio_set_mac(struct net_device *netdev, void *p)
 	struct octeon_device *oct = lio->oct_dev;
 	struct sockaddr *addr = (struct sockaddr *)p;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 
-	if ((!is_valid_ether_addr(addr->sa_data)) ||
-	    (ifstate_check(lio, LIO_IFSTATE_RUNNING)))
+	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MACADDR;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = 0;
+	nctrl.ncmd.s.param1 = 0;
 	nctrl.ncmd.s.more = 1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 	nctrl.wait_time = 100;
@@ -2421,9 +2423,7 @@ static int liquidio_set_mac(struct net_device *netdev, void *p)
 	/* The MAC Address is presented in network byte order. */
 	memcpy((u8 *)&nctrl.udd[0] + 2, addr->sa_data, ETH_ALEN);
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "MAC Address change failed\n");
 		return -ENOMEM;
@@ -2493,7 +2493,6 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int max_frm_size = new_mtu + OCTNET_FRM_HEADER_SIZE;
 	int ret = 0;
 
@@ -2513,15 +2512,13 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MTU;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = new_mtu;
+	nctrl.ncmd.s.param1 = new_mtu;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
-	nparams.resp_order = OCTEON_RESP_ORDERED;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Failed to set MTU\n");
 		return -1;
@@ -2742,11 +2739,11 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * transmitted.
 	 */
 	if (!(atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING) ||
-	    (!lio->linfo.link.s.status) ||
+	    (!lio->linfo.link.s.link_up) ||
 	    (skb->len <= 0)) {
 		netif_info(lio, tx_err, lio->netdev,
 			   "Transmit failed link_status : %d\n",
-			   lio->linfo.link.s.status);
+			   lio->linfo.link.s.link_up);
 		goto lio_xmit_failed;
 	}
 
@@ -2789,7 +2786,6 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	ndata.datasize = skb->len;
 
 	cmdsetup.u64 = 0;
-	cmdsetup.s.ifidx = lio->linfo.ifidx;
 	cmdsetup.s.iq_no = iq_no;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -2802,7 +2798,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	if (skb_shinfo(skb)->nr_frags == 0) {
 		cmdsetup.s.u.datasize = skb->len;
-		octnet_prepare_pci_cmd(&ndata.cmd, &cmdsetup, tag);
+		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
 		/* Offload checksum calculation for TCP/UDP packets */
 		ndata.cmd.dptr = dma_map_single(&oct->pci_dev->dev,
 						skb->data,
@@ -2836,7 +2832,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		cmdsetup.s.gather = 1;
 		cmdsetup.s.u.gatherptrs = (skb_shinfo(skb)->nr_frags + 1);
-		octnet_prepare_pci_cmd(&ndata.cmd, &cmdsetup, tag);
+		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
 
 		memset(g->sg, 0, g->sg_size);
 
@@ -2952,27 +2948,24 @@ static void liquidio_tx_timeout(struct net_device *netdev)
 	txqs_wake(netdev);
 }
 
-int liquidio_set_feature(struct net_device *netdev, int cmd)
+int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	struct octnic_ctrl_params nparams;
 	int ret = 0;
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
 	nctrl.ncmd.s.cmd = cmd;
-	nctrl.ncmd.s.param1 = lio->linfo.ifidx;
-	nctrl.ncmd.s.param2 = OCTNIC_LROIPV4 | OCTNIC_LROIPV6;
+	nctrl.ncmd.s.param1 = param1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
 	nctrl.wait_time = 100;
 	nctrl.netpndev = (u64)netdev;
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
-	nparams.resp_order = OCTEON_RESP_NORESPONSE;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl, nparams);
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
 	if (ret < 0) {
 		dev_err(&oct->pci_dev->dev, "Feature change failed in core (ret: 0x%x)\n",
 			ret);
@@ -3028,10 +3021,12 @@ static int liquidio_set_features(struct net_device *netdev,
 		return 0;
 
 	if ((features & NETIF_F_LRO) && (lio->dev_capability & NETIF_F_LRO))
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE);
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 	else if (!(features & NETIF_F_LRO) &&
 		 (lio->dev_capability & NETIF_F_LRO))
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE);
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
 	return 0;
 }
@@ -3102,24 +3097,27 @@ static int lio_nic_info(struct octeon_recv_info *recv_info, void *buf)
 {
 	struct octeon_device *oct = (struct octeon_device *)buf;
 	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
-	int ifidx = 0;
+	int gmxport = 0;
 	union oct_link_status *ls;
 	int i;
 
-	if ((recv_pkt->buffer_size[0] != sizeof(*ls)) ||
-	    (recv_pkt->rh.r_nic_info.ifidx > oct->ifcount)) {
+	if (recv_pkt->buffer_size[0] != sizeof(*ls)) {
 		dev_err(&oct->pci_dev->dev, "Malformed NIC_INFO, len=%d, ifidx=%d\n",
 			recv_pkt->buffer_size[0],
-			recv_pkt->rh.r_nic_info.ifidx);
+			recv_pkt->rh.r_nic_info.gmxport);
 		goto nic_info_err;
 	}
 
-	ifidx = recv_pkt->rh.r_nic_info.ifidx;
+	gmxport = recv_pkt->rh.r_nic_info.gmxport;
 	ls = (union oct_link_status *)get_rbd(recv_pkt->buffer_ptr[0]);
 
 	octeon_swap_8B_data((u64 *)ls, (sizeof(union oct_link_status)) >> 3);
-
-	update_link_status(oct->props[ifidx].netdev, ls);
+	for (i = 0; i < oct->ifcount; i++) {
+		if (oct->props[i].gmxport == gmxport) {
+			update_link_status(oct->props[i].netdev, ls);
+			break;
+		}
+	}
 
 nic_info_err:
 	for (i = 0; i < recv_pkt->buffer_count; i++)
@@ -3146,12 +3144,12 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	struct liquidio_if_cfg_resp *resp;
 	struct octdev_props *props;
 	int retval, num_iqueues, num_oqueues;
-	u64 q_mask;
 	int num_cpus = num_online_cpus();
 	union oct_nic_if_cfg if_cfg;
 	unsigned int base_queue;
 	unsigned int gmx_port_id;
 	u32 resp_size, ctx_size;
+	u32 ifidx_or_pfnum;
 
 	/* This is to handle link status changes */
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
@@ -3187,13 +3185,14 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			CFG_GET_BASE_QUE_NIC_IF(octeon_get_conf(octeon_dev), i);
 		gmx_port_id =
 			CFG_GET_GMXID_NIC_IF(octeon_get_conf(octeon_dev), i);
+		ifidx_or_pfnum = i;
 		if (num_iqueues > num_cpus)
 			num_iqueues = num_cpus;
 		if (num_oqueues > num_cpus)
 			num_oqueues = num_cpus;
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"requesting config for interface %d, iqs %d, oqs %d\n",
-			i, num_iqueues, num_oqueues);
+			ifidx_or_pfnum, num_iqueues, num_oqueues);
 		ACCESS_ONCE(ctx->cond) = 0;
 		ctx->octeon_id = lio_get_device_id(octeon_dev);
 		init_waitqueue_head(&ctx->wc);
@@ -3203,8 +3202,11 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		if_cfg.s.num_oqueues = num_oqueues;
 		if_cfg.s.base_queue = base_queue;
 		if_cfg.s.gmx_port_id = gmx_port_id;
+
+		sc->iq_no = 0;
+
 		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
-					    OPCODE_NIC_IF_CFG, i,
+					    OPCODE_NIC_IF_CFG, 0,
 					    if_cfg.u64, 0);
 
 		sc->callback = if_cfg_callback;
@@ -3254,8 +3256,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			goto setup_nic_dev_fail;
 		}
 
-		props = &octeon_dev->props[i];
-		props->netdev = netdev;
+		SET_NETDEV_DEV(netdev, &octeon_dev->pci_dev->dev);
 
 		if (num_iqueues > 1)
 			lionetdevops.ndo_select_queue = select_q;
@@ -3269,18 +3270,18 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		memset(lio, 0, sizeof(struct lio));
 
-		lio->linfo.ifidx = resp->cfg_info.ifidx;
-		lio->ifidx = resp->cfg_info.ifidx;
+		lio->ifidx = ifidx_or_pfnum;
+
+		props = &octeon_dev->props[i];
+		props->gmxport = resp->cfg_info.linfo.gmxport;
+		props->netdev = netdev;
 
 		lio->linfo.num_rxpciq = num_oqueues;
 		lio->linfo.num_txpciq = num_iqueues;
-		q_mask = resp->cfg_info.oqmask;
-		/* q_mask is 0-based and already verified mask is nonzero */
 		for (j = 0; j < num_oqueues; j++) {
 			lio->linfo.rxpciq[j].u64 =
 				resp->cfg_info.linfo.rxpciq[j].u64;
 		}
-		q_mask = resp->cfg_info.iqmask;
 		for (j = 0; j < num_iqueues; j++) {
 			lio->linfo.txpciq[j].u64 =
 				resp->cfg_info.linfo.txpciq[j].u64;
@@ -3292,13 +3293,15 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		lio->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 		lio->dev_capability = NETIF_F_HIGHDMA
-				      | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-				      | NETIF_F_SG | NETIF_F_RXCSUM
-				      | NETIF_F_TSO | NETIF_F_TSO6
-				      | NETIF_F_LRO;
+				| NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
+				| NETIF_F_SG | NETIF_F_RXCSUM
+				| NETIF_F_GRO
+				| NETIF_F_TSO | NETIF_F_TSO6
+				| NETIF_F_LRO;
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
-		netdev->features = lio->dev_capability;
+		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
+
 		netdev->vlan_features = lio->dev_capability;
 
 		netdev->hw_features = lio->dev_capability;
@@ -3328,7 +3331,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		 */
 		lio->txq = lio->linfo.txpciq[0].s.q_no;
 		lio->rxq = lio->linfo.rxpciq[0].s.q_no;
-		if (setup_io_queues(octeon_dev, netdev)) {
+		if (setup_io_queues(octeon_dev, i)) {
 			dev_err(&octeon_dev->pci_dev->dev, "I/O queues creation failed\n");
 			goto setup_nic_dev_fail;
 		}
@@ -3347,10 +3350,13 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		/* Register ethtool support */
 		liquidio_set_ethtool_ops(netdev);
 
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE);
+		if (netdev->features & NETIF_F_LRO)
+		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
 		if ((debug != -1) && (debug & NETIF_MSG_HW))
-			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE);
+			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE,
+					     0);
 
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
@@ -3362,13 +3368,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			"Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
 			i, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
 		netif_carrier_off(netdev);
-
-		if (lio->linfo.link.s.status) {
-			netif_carrier_on(netdev);
-			start_txq(netdev);
-		} else {
-			netif_carrier_off(netdev);
-		}
+		lio->link_changes++;
 
 		ifstate_set(lio, LIO_IFSTATE_REGISTERED);
 
@@ -3402,7 +3402,7 @@ setup_nic_dev_fail:
 static int liquidio_init_nic_module(struct octeon_device *oct)
 {
 	struct oct_intrmod_cfg *intrmod_cfg;
-	int retval = 0;
+	int i, retval = 0;
 	int num_nic_ports = CFG_GET_NUM_NIC_PORTS(octeon_get_conf(oct));
 
 	dev_dbg(&oct->pci_dev->dev, "Initializing network interfaces\n");
@@ -3416,6 +3416,9 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	memset(oct->props, 0,
 	       sizeof(struct octdev_props) * num_nic_ports);
 
+	for (i = 0; i < MAX_OCTEON_LINKS; i++)
+		oct->props[i].gmxport = -1;
+
 	retval = setup_nic_devices(oct);
 	if (retval) {
 		dev_err(&oct->pci_dev->dev, "Setup NIC devices failed\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index ebdb802..9917576 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -260,19 +260,19 @@ union octnet_cmd {
 
 		u64 more:6; /* How many udd words follow the command */
 
-		u64 param1:29;
+		u64 reserved:29;
 
-		u64 param2:16;
+		u64 param1:16;
 
-		u64 param3:8;
+		u64 param2:8;
 
 #else
 
-		u64 param3:8;
+		u64 param2:8;
 
-		u64 param2:16;
+		u64 param1:16;
 
-		u64 param1:29;
+		u64 reserved:29;
 
 		u64 more:6;
 
@@ -414,10 +414,9 @@ union octeon_rh {
 		u64 opcode:4;
 		u64 subcode:8;
 		u64 len:3;       /** additional 64-bit words */
-		u64 rid:13;
-		u64 reserved:4;
+		u64 reserved:8;
 		u64 extra:25;
-		u64 ifidx:7;
+		u64 gmxport:16;
 	} r_nic_info;
 #else
 	u64 u64;
@@ -450,10 +449,9 @@ union octeon_rh {
 		u64 opcode:4;
 	} r_core_drv_init;
 	struct {
-		u64 ifidx:7;
+		u64 gmxport:16;
 		u64 extra:25;
-		u64 reserved:4;
-		u64 rid:13;
+		u64 reserved:8;
 		u64 len:3;       /** additional 64-bit words */
 		u64 subcode:8;
 		u64 opcode:4;
@@ -467,7 +465,7 @@ union octnic_packet_params {
 	u32 u32;
 	struct {
 #ifdef __BIG_ENDIAN_BITFIELD
-		u32 reserved:16;
+		u32 reserved:24;
 		u32 ip_csum:1;		/* Perform IP header checksum(s) */
 		/* Perform Outer transport header checksum */
 		u32 transport_csum:1;
@@ -475,15 +473,13 @@ union octnic_packet_params {
 		u32 tnl_csum:1;
 		u32 tsflag:1;		/* Timestamp this packet */
 		u32 ipsec_ops:4;	/* IPsec operation */
-		u32 ifidx:8;
 #else
-		u32 ifidx:8;
 		u32 ipsec_ops:4;
 		u32 tsflag:1;
 		u32 tnl_csum:1;
 		u32 transport_csum:1;
 		u32 ip_csum:1;
-		u32 reserved:16;
+		u32 reserved:24;
 #endif
 	} s;
 };
@@ -495,21 +491,21 @@ union oct_link_status {
 	struct {
 #ifdef __BIG_ENDIAN_BITFIELD
 		u64 duplex:8;
-		u64 status:8;
 		u64 mtu:16;
 		u64 speed:16;
+		u64 link_up:1;
 		u64 autoneg:1;
 		u64 interface:4;
 		u64 pause:1;
-		u64 reserved:10;
+		u64 reserved:17;
 #else
-		u64 reserved:10;
+		u64 reserved:17;
 		u64 pause:1;
 		u64 interface:4;
 		u64 autoneg:1;
+		u64 link_up:1;
 		u64 speed:16;
 		u64 mtu:16;
-		u64 status:8;
 		u64 duplex:8;
 #endif
 	} s;
@@ -561,17 +557,15 @@ struct oct_link_info {
 	u64 hw_addr;
 
 #ifdef __BIG_ENDIAN_BITFIELD
-	u16 gmxport;
-	u8 rsvd[3];
-	u8 num_txpciq;
-	u8 num_rxpciq;
-	u8 ifidx;
+	u64 gmxport:16;
+	u64 rsvd:32;
+	u64 num_txpciq:8;
+	u64 num_rxpciq:8;
 #else
-	u8 ifidx;
-	u8 num_rxpciq;
-	u8 num_txpciq;
-	u8 rsvd[3];
-	u16 gmxport;
+	u64 num_rxpciq:8;
+	u64 num_txpciq:8;
+	u64 rsvd:32;
+	u64 gmxport:16;
 #endif
 
 	union oct_txpciq txpciq[MAX_IOQS_PER_NICIF];
@@ -581,7 +575,6 @@ struct oct_link_info {
 #define OCT_LINK_INFO_SIZE   (sizeof(struct oct_link_info))
 
 struct liquidio_if_cfg_info {
-	u64 ifidx;
 	u64 iqmask; /** mask for IQs enabled for  the port */
 	u64 oqmask; /** mask for OQs enabled for the port */
 	struct oct_link_info linfo; /** initial link information */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index c06807d..3290009 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -766,7 +766,9 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 	if (!oct->instr_queue[0])
 		return 1;
 	memset(oct->instr_queue[0], 0, sizeof(struct octeon_instr_queue));
+	oct->instr_queue[0]->q_index = 0;
 	oct->instr_queue[0]->app_ctx = (void *)(size_t)0;
+	oct->instr_queue[0]->ifidx = 0;
 	txpciq.u64 = 0;
 	txpciq.s.q_no = iq_no;
 	txpciq.s.use_qpg = 0;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 36e1f85..0950b94 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -267,6 +267,7 @@ struct octdev_props {
 	/* Each interface in the Octeon device has a network
 	 * device pointer (used for OS specific calls).
 	 */
+	int    gmxport;
 	struct net_device *netdev;
 };
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index a12beaa..59a5293 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -696,7 +696,8 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 				if (droq->ops.fptr) {
 					droq->ops.fptr(oct->octeon_id,
 						       nicbuf, pkt_len,
-						       rh, &droq->napi);
+						       rh, &droq->napi,
+						       droq->ops.farg);
 				} else {
 					recv_buffer_free(nicbuf);
 				}
@@ -963,6 +964,7 @@ int octeon_unregister_droq_ops(struct octeon_device *oct, u32 q_no)
 	spin_lock_irqsave(&droq->lock, flags);
 
 	droq->ops.fptr = NULL;
+	droq->ops.farg = NULL;
 	droq->ops.drop_on_max = 0;
 
 	spin_unlock_irqrestore(&droq->lock, flags);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 91c365c..1ca9c4f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -231,7 +231,8 @@ struct octeon_droq_ops {
 	 *  data in the buffer. The receive header gives the port
 	 *  number to the caller.  Function pointer is set by caller.
 	 */
-	void (*fptr)(u32, void *, u32, union octeon_rh *, void *);
+	void (*fptr)(u32, void *, u32, union octeon_rh *, void *, void *);
+	void *farg;
 
 	/* This function will be called by the driver for all NAPI related
 	 * events. The first param is the octeon id. The second param is the
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 658f1d0..14c5d70 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -147,6 +147,13 @@ struct octeon_instr_queue {
 
 	/** Application context */
 	void *app_ctx;
+
+	/* network stack queue index */
+	int q_index;
+
+	/*os ifidx associated with this queue */
+	int ifidx;
+
 };
 
 /*----------------------  INSTRUCTION FORMAT ----------------------------*/
@@ -314,7 +321,8 @@ void octeon_prepare_soft_command(struct octeon_device *oct,
 int octeon_send_soft_command(struct octeon_device *oct,
 			     struct octeon_soft_command *sc);
 
-int octeon_setup_iq(struct octeon_device *oct, union oct_txpciq,
-		    u32 num_descs, void *app_ctx);
+int octeon_setup_iq(struct octeon_device *oct, int ifidx,
+		    int q_index, union oct_txpciq iq_no, u32 num_descs,
+		    void *app_ctx);
 
 #endif				/* __OCTEON_IQ_H__ */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 0267fff..9c14484 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -67,6 +67,9 @@ struct lio {
 	/** Link information sent by the core application for this interface. */
 	struct oct_link_info linfo;
 
+	/** counter of link changes */
+	u64 link_changes;
+
 	/** Size of Tx queue for this octeon device. */
 	u32 tx_qsize;
 
@@ -111,8 +114,9 @@ struct lio {
  * \brief Enable or disable feature
  * @param netdev    pointer to network device
  * @param cmd       Command that just requires acknowledgment
+ * @param param1    Parameter to command
  */
-int liquidio_set_feature(struct net_device *netdev, int cmd);
+int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1);
 
 /**
  * \brief Link control command completion callback
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index aacabe4..20e0122 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -119,8 +119,7 @@ static void octnet_link_ctrl_callback(struct octeon_device *oct,
 
 static inline struct octeon_soft_command
 *octnic_alloc_ctrl_pkt_sc(struct octeon_device *oct,
-			  struct octnic_ctrl_pkt *nctrl,
-			  struct octnic_ctrl_params nparams)
+			  struct octnic_ctrl_pkt *nctrl)
 {
 	struct octeon_soft_command *sc = NULL;
 	u8 *data;
@@ -143,7 +142,7 @@ static inline struct octeon_soft_command
 
 	data = (u8 *)sc->virtdptr;
 
-	memcpy(data, &nctrl->ncmd,  OCTNET_CMD_SIZE);
+	memcpy(data, &nctrl->ncmd, OCTNET_CMD_SIZE);
 
 	octeon_swap_8B_data((u64 *)data, (OCTNET_CMD_SIZE >> 3));
 
@@ -152,6 +151,8 @@ static inline struct octeon_soft_command
 		memcpy(data + OCTNET_CMD_SIZE, nctrl->udd, uddsize);
 	}
 
+	sc->iq_no = (u32)nctrl->iq_no;
+
 	octeon_prepare_soft_command(oct, sc, OPCODE_NIC, OPCODE_NIC_CMD,
 				    0, 0, 0);
 
@@ -164,13 +165,12 @@ static inline struct octeon_soft_command
 
 int
 octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
-			 struct octnic_ctrl_pkt *nctrl,
-			 struct octnic_ctrl_params nparams)
+			 struct octnic_ctrl_pkt *nctrl)
 {
 	int retval;
 	struct octeon_soft_command *sc = NULL;
 
-	sc = octnic_alloc_ctrl_pkt_sc(oct, nctrl, nparams);
+	sc = octnic_alloc_ctrl_pkt_sc(oct, nctrl);
 	if (!sc) {
 		dev_err(&oct->pci_dev->dev, "%s soft command alloc failed\n",
 			__func__);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index a61dea3..5e53cc9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -52,6 +52,9 @@ struct octnic_ctrl_pkt {
 	/** Additional data that may be needed by some commands. */
 	u64 udd[MAX_NCTRL_UDD];
 
+	/** Input queue to use to send this command. */
+	u64 iq_no;
+
 	/** Time to wait for Octeon software to respond to this control command.
 	 *  If wait_time is 0, OSI assumes no response is expected.
 	 */
@@ -100,8 +103,7 @@ union octnic_cmd_setup {
 		u32 ip_csum:1;
 		u32 transport_csum:1;
 		u32 tnl_csum:1;
-		u32 ifidx:8;
-		u32 rsvd:11;
+		u32 rsvd:19;
 
 		union {
 			u32 datasize;
@@ -113,10 +115,6 @@ union octnic_cmd_setup {
 
 };
 
-struct octnic_ctrl_params {
-	u32 resp_order;
-};
-
 static inline int octnet_iq_is_full(struct octeon_device *oct, u32 q_no)
 {
 	return ((u32)atomic_read(&oct->instr_queue[q_no]->instr_pending)
@@ -131,12 +129,13 @@ static inline int octnet_iq_is_full(struct octeon_device *oct, u32 q_no)
  * Assumes the cmd instruction is pre-allocated, but no fields are filled in.
  */
 static inline void
-octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
+octnet_prepare_pci_cmd(struct octeon_device *oct, struct octeon_instr_64B *cmd,
 		       union octnic_cmd_setup *setup, u32 tag)
 {
 	struct octeon_instr_ih *ih;
 	struct octeon_instr_irh *irh;
 	union octnic_packet_params packet_params;
+	int port;
 
 	memset(cmd, 0, sizeof(struct octeon_instr_64B));
 
@@ -150,13 +149,15 @@ octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
 	ih->tagtype = ORDERED_TAG;
 	ih->grp = DEFAULT_POW_GRP;
 
+	port = (int)oct->instr_queue[setup->s.iq_no]->txpciq.s.port;
+
 	if (tag)
 		ih->tag = tag;
 	else
-		ih->tag = LIO_DATA(setup->s.ifidx);
+		ih->tag = LIO_DATA(port);
 
 	ih->raw = 1;
-	ih->qos = (setup->s.ifidx & 3) + 4;	/* map qos based on interface */
+	ih->qos = (port & 3) + 4;	/* map qos based on interface */
 
 	if (!setup->s.gather) {
 		ih->dlengsz = setup->s.u.datasize;
@@ -175,7 +176,6 @@ octnet_prepare_pci_cmd(struct octeon_instr_64B *cmd,
 	packet_params.s.ip_csum = setup->s.ip_csum;
 	packet_params.s.transport_csum = setup->s.transport_csum;
 	packet_params.s.tnl_csum = setup->s.tnl_csum;
-	packet_params.s.ifidx = setup->s.ifidx;
 	packet_params.s.tsflag = setup->s.timestamp;
 
 	irh->ossp = packet_params.u32;
@@ -216,7 +216,6 @@ int octnet_send_nic_data_pkt(struct octeon_device *oct,
  */
 int
 octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
-			 struct octnic_ctrl_pkt *nctrl,
-			 struct octnic_ctrl_params nparams);
+			 struct octnic_ctrl_pkt *nctrl);
 
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 1240461..b0a8d4d 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -202,6 +202,8 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 
 /* Return 0 on success, 1 on failure */
 int octeon_setup_iq(struct octeon_device *oct,
+		    int ifidx,
+		    int q_index,
 		    union oct_txpciq txpciq,
 		    u32 num_descs,
 		    void *app_ctx)
@@ -227,7 +229,10 @@ int octeon_setup_iq(struct octeon_device *oct,
 	memset(oct->instr_queue[iq_no], 0,
 	       sizeof(struct octeon_instr_queue));
 
+	oct->instr_queue[iq_no]->q_index = q_index;
 	oct->instr_queue[iq_no]->app_ctx = app_ctx;
+	oct->instr_queue[iq_no]->ifidx = ifidx;
+
 	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
 		vfree(oct->instr_queue[iq_no]);
 		oct->instr_queue[iq_no] = NULL;
-- 
1.8.3.1
