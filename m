From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V5 5/9] liquidio CN23XX: VF related operations
Date: Wed, 9 Nov 2016 15:13:48 -0800
Message-ID: <1478733232-15739-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0081.outbound.protection.outlook.com ([104.47.32.81]:54484
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754718AbcKIXOf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 18:14:35 -0500
In-Reply-To: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF related operations like mac address vlan
and link changes.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    |  22 +++
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   5 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 211 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   5 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   8 +
 5 files changed, 251 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index ffc94ac..d01b00b 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -23,6 +23,7 @@
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
+#include <linux/etherdevice.h>
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
@@ -1416,3 +1417,24 @@ int cn23xx_fw_loaded(struct octeon_device *oct)
 	val = octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1);
 	return (val >> 1) & 1ULL;
 }
+
+void cn23xx_tell_vf_its_macaddr_changed(struct octeon_device *oct, int vfidx,
+					u8 *mac)
+{
+	if (oct->sriov_info.vf_drv_loaded_mask & BIT_ULL(vfidx)) {
+		struct octeon_mbox_cmd mbox_cmd;
+
+		mbox_cmd.msg.u64 = 0;
+		mbox_cmd.msg.s.type = OCTEON_MBOX_REQUEST;
+		mbox_cmd.msg.s.resp_needed = 0;
+		mbox_cmd.msg.s.cmd = OCTEON_PF_CHANGED_VF_MACADDR;
+		mbox_cmd.msg.s.len = 1;
+		mbox_cmd.recv_len = 0;
+		mbox_cmd.recv_status = 0;
+		mbox_cmd.fn = NULL;
+		mbox_cmd.fn_arg = 0;
+		ether_addr_copy(mbox_cmd.msg.s.params, mac);
+		mbox_cmd.q_no = vfidx * oct->sriov_info.rings_per_vf;
+		octeon_mbox_write(oct, &mbox_cmd);
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index 21b5c90..cee346a 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -29,6 +29,8 @@
 
 #include "cn23xx_pf_regs.h"
 
+#define LIO_CMD_WAIT_TM 100
+
 /* Register address and configuration for a CN23XX devices.
  * If device specific changes need to be made then add a struct to include
  * device specific fields as shown in the commented section
@@ -56,4 +58,7 @@ int validate_cn23xx_pf_config_info(struct octeon_device *oct,
 void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct);
 
 int cn23xx_fw_loaded(struct octeon_device *oct);
+
+void cn23xx_tell_vf_its_macaddr_changed(struct octeon_device *oct, int vfidx,
+					u8 *mac);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index f776808..6e435db 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3573,6 +3573,151 @@ static void liquidio_del_vxlan_port(struct net_device *netdev,
 				    OCTNET_CMD_VXLAN_PORT_DEL);
 }
 
+static int __liquidio_set_vf_mac(struct net_device *netdev, int vfidx,
+				 u8 *mac, bool is_admin_assigned)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+
+	if (!is_valid_ether_addr(mac))
+		return -EINVAL;
+
+	if (vfidx < 0 || vfidx >= oct->sriov_info.max_vfs)
+		return -EINVAL;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_CHANGE_MACADDR;
+	/* vfidx is 0 based, but vf_num (param1) is 1 based */
+	nctrl.ncmd.s.param1 = vfidx + 1;
+	nctrl.ncmd.s.param2 = (is_admin_assigned ? 1 : 0);
+	nctrl.ncmd.s.more = 1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.cb_fn = 0;
+	nctrl.wait_time = LIO_CMD_WAIT_TM;
+
+	nctrl.udd[0] = 0;
+	/* The MAC Address is presented in network byte order. */
+	ether_addr_copy((u8 *)&nctrl.udd[0] + 2, mac);
+
+	oct->sriov_info.vf_macaddr[vfidx] = nctrl.udd[0];
+
+	octnet_send_nic_ctrl_pkt(oct, &nctrl);
+
+	return 0;
+}
+
+static int liquidio_set_vf_mac(struct net_device *netdev, int vfidx, u8 *mac)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	int retval;
+
+	retval = __liquidio_set_vf_mac(netdev, vfidx, mac, true);
+	if (!retval)
+		cn23xx_tell_vf_its_macaddr_changed(oct, vfidx, mac);
+
+	return retval;
+}
+
+static int liquidio_set_vf_vlan(struct net_device *netdev, int vfidx,
+				u16 vlan, u8 qos, __be16 vlan_proto)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	u16 vlantci;
+
+	if (vfidx < 0 || vfidx >= oct->sriov_info.num_vfs_alloced)
+		return -EINVAL;
+
+	if (vlan_proto != htons(ETH_P_8021Q))
+		return -EPROTONOSUPPORT;
+
+	if (vlan >= VLAN_N_VID || qos > 7)
+		return -EINVAL;
+
+	if (vlan)
+		vlantci = vlan | (u16)qos << VLAN_PRIO_SHIFT;
+	else
+		vlantci = 0;
+
+	if (oct->sriov_info.vf_vlantci[vfidx] == vlantci)
+		return 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	if (vlan)
+		nctrl.ncmd.s.cmd = OCTNET_CMD_ADD_VLAN_FILTER;
+	else
+		nctrl.ncmd.s.cmd = OCTNET_CMD_DEL_VLAN_FILTER;
+
+	nctrl.ncmd.s.param1 = vlantci;
+	nctrl.ncmd.s.param2 =
+	    vfidx + 1; /* vfidx is 0 based, but vf_num (param2) is 1 based */
+	nctrl.ncmd.s.more = 0;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.cb_fn = 0;
+	nctrl.wait_time = LIO_CMD_WAIT_TM;
+
+	octnet_send_nic_ctrl_pkt(oct, &nctrl);
+
+	oct->sriov_info.vf_vlantci[vfidx] = vlantci;
+
+	return 0;
+}
+
+static int liquidio_get_vf_config(struct net_device *netdev, int vfidx,
+				  struct ifla_vf_info *ivi)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	u8 *macaddr;
+
+	if (vfidx < 0 || vfidx >= oct->sriov_info.num_vfs_alloced)
+		return -EINVAL;
+
+	ivi->vf = vfidx;
+	macaddr = 2 + (u8 *)&oct->sriov_info.vf_macaddr[vfidx];
+	ether_addr_copy(&ivi->mac[0], macaddr);
+	ivi->vlan = oct->sriov_info.vf_vlantci[vfidx] & VLAN_VID_MASK;
+	ivi->qos = oct->sriov_info.vf_vlantci[vfidx] >> VLAN_PRIO_SHIFT;
+	ivi->linkstate = oct->sriov_info.vf_linkstate[vfidx];
+	return 0;
+}
+
+static int liquidio_set_vf_link_state(struct net_device *netdev, int vfidx,
+				      int linkstate)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+
+	if (vfidx < 0 || vfidx >= oct->sriov_info.num_vfs_alloced)
+		return -EINVAL;
+
+	if (oct->sriov_info.vf_linkstate[vfidx] == linkstate)
+		return 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+	nctrl.ncmd.s.cmd = OCTNET_CMD_SET_VF_LINKSTATE;
+	nctrl.ncmd.s.param1 =
+	    vfidx + 1; /* vfidx is 0 based, but vf_num (param1) is 1 based */
+	nctrl.ncmd.s.param2 = linkstate;
+	nctrl.ncmd.s.more = 0;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.cb_fn = 0;
+	nctrl.wait_time = LIO_CMD_WAIT_TM;
+
+	octnet_send_nic_ctrl_pkt(oct, &nctrl);
+
+	oct->sriov_info.vf_linkstate[vfidx] = linkstate;
+
+	return 0;
+}
+
 static struct net_device_ops lionetdevops = {
 	.ndo_open		= liquidio_open,
 	.ndo_stop		= liquidio_stop,
@@ -3590,6 +3735,10 @@ static void liquidio_del_vxlan_port(struct net_device *netdev,
 	.ndo_set_features	= liquidio_set_features,
 	.ndo_udp_tunnel_add	= liquidio_add_vxlan_port,
 	.ndo_udp_tunnel_del	= liquidio_del_vxlan_port,
+	.ndo_set_vf_mac		= liquidio_set_vf_mac,
+	.ndo_set_vf_vlan	= liquidio_set_vf_vlan,
+	.ndo_get_vf_config	= liquidio_get_vf_config,
+	.ndo_set_vf_link_state  = liquidio_set_vf_link_state,
 };
 
 /** \brief Entry point for the liquidio module
@@ -3912,6 +4061,19 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			"if%d gmx: %d hw_addr: 0x%llx\n", i,
 			lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
 
+		for (j = 0; j < octeon_dev->sriov_info.max_vfs; j++) {
+			u8 vfmac[ETH_ALEN];
+
+			random_ether_addr(&vfmac[0]);
+			if (__liquidio_set_vf_mac(netdev, j,
+						  &vfmac[0], false)) {
+				dev_err(&octeon_dev->pci_dev->dev,
+					"Error setting VF%d MAC address\n",
+					j);
+				goto setup_nic_dev_fail;
+			}
+		}
+
 		/* 64-bit swap required on LE machines */
 		octeon_swap_8B_data(&lio->linfo.hw_addr, 1);
 		for (j = 0; j < 6; j++)
@@ -4207,6 +4369,52 @@ static void nic_starter(struct work_struct *work)
 	complete(&handshake[oct->octeon_id].started);
 }
 
+static int
+octeon_recv_vf_drv_notice(struct octeon_recv_info *recv_info, void *buf)
+{
+	struct octeon_device *oct = (struct octeon_device *)buf;
+	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
+	int i, notice, vf_idx;
+	u64 *data, vf_num;
+
+	notice = recv_pkt->rh.r.ossp;
+	data = (u64 *)get_rbd(recv_pkt->buffer_ptr[0]);
+
+	/* the first 64-bit word of data is the vf_num */
+	vf_num = data[0];
+	octeon_swap_8B_data(&vf_num, 1);
+	vf_idx = (int)vf_num - 1;
+
+	if (notice == VF_DRV_LOADED) {
+		if (!(oct->sriov_info.vf_drv_loaded_mask & BIT_ULL(vf_idx))) {
+			oct->sriov_info.vf_drv_loaded_mask |= BIT_ULL(vf_idx);
+			dev_info(&oct->pci_dev->dev,
+				 "driver for VF%d was loaded\n", vf_idx);
+			try_module_get(THIS_MODULE);
+		}
+	} else if (notice == VF_DRV_REMOVED) {
+		if (oct->sriov_info.vf_drv_loaded_mask & BIT_ULL(vf_idx)) {
+			oct->sriov_info.vf_drv_loaded_mask &= ~BIT_ULL(vf_idx);
+			dev_info(&oct->pci_dev->dev,
+				 "driver for VF%d was removed\n", vf_idx);
+			module_put(THIS_MODULE);
+		}
+	} else if (notice == VF_DRV_MACADDR_CHANGED) {
+		u8 *b = (u8 *)&data[1];
+
+		oct->sriov_info.vf_macaddr[vf_idx] = data[1];
+		dev_info(&oct->pci_dev->dev,
+			 "VF driver changed VF%d's MAC address to %02x:%02x:%02x:%02x:%02x:%02x\n",
+			 vf_idx, b[2], b[3], b[4], b[5], b[6], b[7]);
+	}
+
+	for (i = 0; i < recv_pkt->buffer_count; i++)
+		recv_buffer_free(recv_pkt->buffer_ptr[i]);
+	octeon_free_recv_info(recv_info);
+
+	return 0;
+}
+
 /**
  * \brief Device initialization for each Octeon device that is probed
  * @param octeon_dev  octeon device
@@ -4265,6 +4473,9 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 				    octeon_core_drv_init,
 				    octeon_dev);
 
+	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
+				    OPCODE_NIC_VF_DRV_NOTICE,
+				    octeon_recv_vf_drv_notice, octeon_dev);
 	INIT_DELAYED_WORK(&octeon_dev->nic_poll_work.work, nic_starter);
 	octeon_dev->nic_poll_work.ctxptr = (void *)octeon_dev;
 	schedule_delayed_work(&octeon_dev->nic_poll_work.work,
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index caeff9a..edf1282 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -89,6 +89,10 @@ enum octeon_tag_type {
 #define OPCODE_NIC_TIMESTAMP           0x07
 #define OPCODE_NIC_INTRMOD_CFG         0x08
 #define OPCODE_NIC_IF_CFG              0x09
+#define OPCODE_NIC_VF_DRV_NOTICE       0x0A
+#define VF_DRV_LOADED                  1
+#define VF_DRV_REMOVED                -1
+#define VF_DRV_MACADDR_CHANGED         2
 
 #define CORE_DRV_TEST_SCATTER_OP    0xFFF5
 
@@ -235,6 +239,7 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 
 #define   OCTNET_CMD_ID_ACTIVE         0x1a
 
+#define   OCTNET_CMD_SET_VF_LINKSTATE  0x1c
 #define   OCTNET_CMD_VXLAN_PORT_ADD    0x0
 #define   OCTNET_CMD_VXLAN_PORT_DEL    0x1
 #define   OCTNET_CMD_RXCSUM_ENABLE     0x0
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index bdb10a0..70a0d98 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -354,6 +354,14 @@ struct octeon_sriov_info {
 
 	/*lookup table that maps DPI ring number to VF pci_dev struct pointer*/
 	struct pci_dev *dpiring_to_vfpcidev_lut[MAX_POSSIBLE_VFS];
+
+	u64	vf_macaddr[MAX_POSSIBLE_VFS];
+
+	u16	vf_vlantci[MAX_POSSIBLE_VFS];
+
+	int	vf_linkstate[MAX_POSSIBLE_VFS];
+
+	u64	vf_drv_loaded_mask;
 };
 
 struct octeon_ioq_vector {
-- 
1.8.3.1
