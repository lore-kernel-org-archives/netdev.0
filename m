From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4: configure HW VLAN extraction through FW
Date: Mon, 10 May 2010 18:58:07 -0700
Message-ID: <1273543089-10938-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5417 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153Ab0EKB6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:58:11 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o4B1wAYu007191
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 18:58:10 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW VLAN extraction needs to be configured through FW to work correctly in
virtualization environments.  Remove the direct register manipulation and
rely on FW.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    4 ++--
 drivers/net/cxgb4/cxgb4_main.c |    9 +++++----
 drivers/net/cxgb4/t4_hw.c      |   31 ++++++++++---------------------
 drivers/net/cxgb4/t4fw_api.h   |    4 +++-
 4 files changed, 20 insertions(+), 28 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 8856a75..d3a5c34 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -656,7 +656,6 @@ int t4_check_fw_version(struct adapter *adapter);
 int t4_prep_adapter(struct adapter *adapter);
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
 void t4_fatal_err(struct adapter *adapter);
-void t4_set_vlan_accel(struct adapter *adapter, unsigned int ports, int on);
 int t4_set_trace_filter(struct adapter *adapter, const struct trace_params *tp,
 			int filter_index, int enable);
 void t4_get_trace_filter(struct adapter *adapter, struct trace_params *tp,
@@ -707,7 +706,8 @@ int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
 int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
 	       unsigned int vf, unsigned int viid);
 int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
-		int mtu, int promisc, int all_multi, int bcast, bool sleep_ok);
+		int mtu, int promisc, int all_multi, int bcast, int vlanex,
+		bool sleep_ok);
 int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		      unsigned int viid, bool free, unsigned int naddr,
 		      const u8 **addr, u16 *idx, u64 *hash, bool sleep_ok);
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 1bad500..a73cda9 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -290,7 +290,7 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 	if (ret == 0)
 		ret = t4_set_rxmode(pi->adapter, 0, pi->viid, mtu,
 				    (dev->flags & IFF_PROMISC) ? 1 : 0,
-				    (dev->flags & IFF_ALLMULTI) ? 1 : 0, 1,
+				    (dev->flags & IFF_ALLMULTI) ? 1 : 0, 1, -1,
 				    sleep_ok);
 	return ret;
 }
@@ -311,7 +311,7 @@ static int link_start(struct net_device *dev)
 	 * that step explicitly.
 	 */
 	ret = t4_set_rxmode(pi->adapter, 0, pi->viid, dev->mtu, -1, -1, -1,
-			    true);
+			    pi->vlan_grp != NULL, true);
 	if (ret == 0) {
 		ret = t4_change_mac(pi->adapter, 0, pi->viid,
 				    pi->xact_addr_filt, dev->dev_addr, true,
@@ -2614,7 +2614,7 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 
 	if (new_mtu < 81 || new_mtu > MAX_MTU)         /* accommodate SACK */
 		return -EINVAL;
-	ret = t4_set_rxmode(pi->adapter, 0, pi->viid, new_mtu, -1, -1, -1,
+	ret = t4_set_rxmode(pi->adapter, 0, pi->viid, new_mtu, -1, -1, -1, -1,
 			    true);
 	if (!ret)
 		dev->mtu = new_mtu;
@@ -2645,7 +2645,8 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	struct port_info *pi = netdev_priv(dev);
 
 	pi->vlan_grp = grp;
-	t4_set_vlan_accel(pi->adapter, 1 << pi->tx_chan, grp != NULL);
+	t4_set_rxmode(pi->adapter, 0, pi->viid, -1, -1, -1, -1, grp != NULL,
+		      true);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 2923dd4..da272a9 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -886,22 +886,6 @@ int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port)
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
-/**
- *	t4_set_vlan_accel - configure HW VLAN extraction
- *	@adap: the adapter
- *	@ports: bitmap of adapter ports to operate on
- *	@on: enable (1) or disable (0) HW VLAN extraction
- *
- *	Enables or disables HW extraction of VLAN tags for the ports specified
- *	by @ports.  @ports is a bitmap with the ith bit designating the port
- *	associated with the ith adapter channel.
- */
-void t4_set_vlan_accel(struct adapter *adap, unsigned int ports, int on)
-{
-	ports <<= VLANEXTENABLE_SHIFT;
-	t4_set_reg_field(adap, TP_OUT_CONFIG, ports, on ? ports : 0);
-}
-
 struct intr_info {
 	unsigned int mask;       /* bits to check in interrupt status */
 	const char *msg;         /* message to print or NULL */
@@ -2624,12 +2608,14 @@ int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
  *	@promisc: 1 to enable promiscuous mode, 0 to disable it, -1 no change
  *	@all_multi: 1 to enable all-multi mode, 0 to disable it, -1 no change
  *	@bcast: 1 to enable broadcast Rx, 0 to disable it, -1 no change
+ *	@vlanex: 1 to enable HW VLAN extraction, 0 to disable it, -1 no change
  *	@sleep_ok: if true we may sleep while awaiting command completion
  *
  *	Sets Rx properties of a virtual interface.
  */
 int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
-		  int mtu, int promisc, int all_multi, int bcast, bool sleep_ok)
+		  int mtu, int promisc, int all_multi, int bcast, int vlanex,
+		  bool sleep_ok)
 {
 	struct fw_vi_rxmode_cmd c;
 
@@ -2642,15 +2628,18 @@ int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
 		all_multi = FW_VI_RXMODE_CMD_ALLMULTIEN_MASK;
 	if (bcast < 0)
 		bcast = FW_VI_RXMODE_CMD_BROADCASTEN_MASK;
+	if (vlanex < 0)
+		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_MASK;
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_viid = htonl(FW_CMD_OP(FW_VI_RXMODE_CMD) | FW_CMD_REQUEST |
 			     FW_CMD_WRITE | FW_VI_RXMODE_CMD_VIID(viid));
 	c.retval_len16 = htonl(FW_LEN16(c));
-	c.mtu_to_broadcasten = htonl(FW_VI_RXMODE_CMD_MTU(mtu) |
-				     FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
-				     FW_VI_RXMODE_CMD_ALLMULTIEN(all_multi) |
-				     FW_VI_RXMODE_CMD_BROADCASTEN(bcast));
+	c.mtu_to_vlanexen = htonl(FW_VI_RXMODE_CMD_MTU(mtu) |
+				  FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
+				  FW_VI_RXMODE_CMD_ALLMULTIEN(all_multi) |
+				  FW_VI_RXMODE_CMD_BROADCASTEN(bcast) |
+				  FW_VI_RXMODE_CMD_VLANEXEN(vlanex));
 	return t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), NULL, sleep_ok);
 }
 
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
index 3393d05..63991d6 100644
--- a/drivers/net/cxgb4/t4fw_api.h
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -876,7 +876,7 @@ struct fw_vi_mac_cmd {
 struct fw_vi_rxmode_cmd {
 	__be32 op_to_viid;
 	__be32 retval_len16;
-	__be32 mtu_to_broadcasten;
+	__be32 mtu_to_vlanexen;
 	__be32 r4_lo;
 };
 
@@ -888,6 +888,8 @@ struct fw_vi_rxmode_cmd {
 #define FW_VI_RXMODE_CMD_ALLMULTIEN(x) ((x) << 12)
 #define FW_VI_RXMODE_CMD_BROADCASTEN_MASK 0x3
 #define FW_VI_RXMODE_CMD_BROADCASTEN(x) ((x) << 10)
+#define FW_VI_RXMODE_CMD_VLANEXEN_MASK 0x3
+#define FW_VI_RXMODE_CMD_VLANEXEN(x) ((x) << 8)
 
 struct fw_vi_enable_cmd {
 	__be32 op_to_viid;
-- 
1.5.4

