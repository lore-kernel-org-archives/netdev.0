From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/2] enic: remove dead code
Date: Wed, 29 Sep 2010 15:29:30 +0900
Message-ID: <20100929152930.520cc3b4@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53492 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab0I2G3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 02:29:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver seems to have lots of leftover dead code that is defined
globally but never used.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/enic/enic_res.c  |   16 -----
 drivers/net/enic/enic_res.h  |    2 
 drivers/net/enic/vnic_dev.c  |  128 -------------------------------------------
 drivers/net/enic/vnic_dev.h  |   10 ---
 drivers/net/enic/vnic_intr.c |    5 -
 5 files changed, 161 deletions(-)

--- a/drivers/net/enic/enic_res.c	2010-09-29 15:21:47.983306313 +0900
+++ b/drivers/net/enic/enic_res.c	2010-09-29 15:26:29.273306571 +0900
@@ -149,22 +149,6 @@ int enic_set_nic_cfg(struct enic *enic, 
 	return vnic_dev_cmd(enic->vdev, CMD_NIC_CFG, &a0, &a1, wait);
 }
 
-int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len)
-{
-	u64 a0 = (u64)key_pa, a1 = len;
-	int wait = 1000;
-
-	return vnic_dev_cmd(enic->vdev, CMD_RSS_KEY, &a0, &a1, wait);
-}
-
-int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len)
-{
-	u64 a0 = (u64)cpu_pa, a1 = len;
-	int wait = 1000;
-
-	return vnic_dev_cmd(enic->vdev, CMD_RSS_CPU, &a0, &a1, wait);
-}
-
 void enic_free_vnic_resources(struct enic *enic)
 {
 	unsigned int i;
--- a/drivers/net/enic/enic_res.h	2010-09-29 15:21:47.993306327 +0900
+++ b/drivers/net/enic/enic_res.h	2010-09-29 15:26:29.273306571 +0900
@@ -137,8 +137,6 @@ int enic_del_vlan(struct enic *enic, u16
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	u8 rss_hash_bits, u8 rss_base_cpu, u8 rss_enable, u8 tso_ipid_split_en,
 	u8 ig_vlan_strip_en);
-int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len);
-int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len);
 void enic_get_res_counts(struct enic *enic);
 void enic_init_vnic_resources(struct enic *enic);
 int enic_alloc_vnic_resources(struct enic *);
--- a/drivers/net/enic/vnic_dev.c	2010-09-29 15:21:48.003304595 +0900
+++ b/drivers/net/enic/vnic_dev.c	2010-09-29 15:27:22.315218464 +0900
@@ -186,21 +186,6 @@ void __iomem *vnic_dev_get_res(struct vn
 	}
 }
 
-dma_addr_t vnic_dev_get_res_bus_addr(struct vnic_dev *vdev,
-	enum vnic_res_type type, unsigned int index)
-{
-	switch (type) {
-	case RES_TYPE_WQ:
-	case RES_TYPE_RQ:
-	case RES_TYPE_CQ:
-	case RES_TYPE_INTR_CTRL:
-		return vdev->res[type].bus_addr +
-			index * VNIC_RES_STRIDE;
-	default:
-		return vdev->res[type].bus_addr;
-	}
-}
-
 unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size)
 {
@@ -384,18 +369,6 @@ static int vnic_dev_cmd_no_proxy(struct 
 	return err;
 }
 
-void vnic_dev_cmd_proxy_by_bdf_start(struct vnic_dev *vdev, u16 bdf)
-{
-	vdev->proxy = PROXY_BY_BDF;
-	vdev->proxy_index = bdf;
-}
-
-void vnic_dev_cmd_proxy_end(struct vnic_dev *vdev)
-{
-	vdev->proxy = PROXY_NONE;
-	vdev->proxy_index = 0;
-}
-
 int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait)
 {
@@ -488,13 +461,6 @@ int vnic_dev_spec(struct vnic_dev *vdev,
 	return err;
 }
 
-int vnic_dev_stats_clear(struct vnic_dev *vdev)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_STATS_CLEAR, &a0, &a1, wait);
-}
-
 int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats)
 {
 	u64 a0, a1;
@@ -528,19 +494,6 @@ int vnic_dev_enable(struct vnic_dev *vde
 	return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
 }
 
-int vnic_dev_enable_wait(struct vnic_dev *vdev)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	err = vnic_dev_cmd(vdev, CMD_ENABLE_WAIT, &a0, &a1, wait);
-	if (err == ERR_ECMDUNKNOWN)
-		return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
-
-	return err;
-}
-
 int vnic_dev_disable(struct vnic_dev *vdev)
 {
 	u64 a0 = 0, a1 = 0;
@@ -572,30 +525,6 @@ int vnic_dev_open_done(struct vnic_dev *
 	return 0;
 }
 
-int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
-{
-	u64 a0 = (u32)arg, a1 = 0;
-	int wait = 1000;
-	return vnic_dev_cmd(vdev, CMD_SOFT_RESET, &a0, &a1, wait);
-}
-
-int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
-{
-	u64 a0 = 0, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	*done = 0;
-
-	err = vnic_dev_cmd(vdev, CMD_SOFT_RESET_STATUS, &a0, &a1, wait);
-	if (err)
-		return err;
-
-	*done = (a0 == 0);
-
-	return 0;
-}
-
 int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg)
 {
 	u64 a0 = (u32)arg, a1 = 0;
@@ -680,26 +609,6 @@ int vnic_dev_packet_filter(struct vnic_d
 	return err;
 }
 
-int vnic_dev_packet_filter_all(struct vnic_dev *vdev, int directed,
-	int multicast, int broadcast, int promisc, int allmulti)
-{
-	u64 a0, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	a0 = (directed ? CMD_PFILTER_DIRECTED : 0) |
-	     (multicast ? CMD_PFILTER_MULTICAST : 0) |
-	     (broadcast ? CMD_PFILTER_BROADCAST : 0) |
-	     (promisc ? CMD_PFILTER_PROMISCUOUS : 0) |
-	     (allmulti ? CMD_PFILTER_ALL_MULTICAST : 0);
-
-	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER_ALL, &a0, &a1, wait);
-	if (err)
-		pr_err("Can't set packet filter\n");
-
-	return err;
-}
-
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 {
 	u64 a0 = 0, a1 = 0;
@@ -748,19 +657,6 @@ int vnic_dev_set_ig_vlan_rewrite_mode(st
 	return err;
 }
 
-int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr)
-{
-	u64 a0 = intr, a1 = 0;
-	int wait = 1000;
-	int err;
-
-	err = vnic_dev_cmd(vdev, CMD_IAR, &a0, &a1, wait);
-	if (err)
-		pr_err("Failed to raise INTR[%d], err %d\n", intr, err);
-
-	return err;
-}
-
 int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
 	void *notify_addr, dma_addr_t notify_pa, u16 intr)
 {
@@ -954,30 +850,6 @@ u32 vnic_dev_mtu(struct vnic_dev *vdev)
 	return vdev->notify_copy.mtu;
 }
 
-u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.link_down_cnt;
-}
-
-u32 vnic_dev_notify_status(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.status;
-}
-
-u32 vnic_dev_uif(struct vnic_dev *vdev)
-{
-	if (!vnic_dev_notify_ready(vdev))
-		return 0;
-
-	return vdev->notify_copy.uif;
-}
-
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode)
 {
--- a/drivers/net/enic/vnic_dev.h	2010-09-29 15:21:48.013306844 +0900
+++ b/drivers/net/enic/vnic_dev.h	2010-09-29 15:26:29.273306571 +0900
@@ -84,8 +84,6 @@ unsigned int vnic_dev_get_res_count(stru
 	enum vnic_res_type type);
 void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	unsigned int index);
-dma_addr_t vnic_dev_get_res_bus_addr(struct vnic_dev *vdev,
-	enum vnic_res_type type, unsigned int index);
 unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size);
 void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
@@ -95,21 +93,16 @@ void vnic_dev_free_desc_ring(struct vnic
 	struct vnic_dev_ring *ring);
 int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait);
-void vnic_dev_cmd_proxy_by_bdf_start(struct vnic_dev *vdev, u16 bdf);
-void vnic_dev_cmd_proxy_end(struct vnic_dev *vdev);
 int vnic_dev_fw_info(struct vnic_dev *vdev,
 	struct vnic_devcmd_fw_info **fw_info);
 int vnic_dev_hw_version(struct vnic_dev *vdev,
 	enum vnic_dev_hw_version *hw_ver);
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 	void *value);
-int vnic_dev_stats_clear(struct vnic_dev *vdev);
 int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
 int vnic_dev_hang_notify(struct vnic_dev *vdev);
 int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti);
-int vnic_dev_packet_filter_all(struct vnic_dev *vdev, int directed,
-	int multicast, int broadcast, int promisc, int allmulti);
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
@@ -124,11 +117,8 @@ u32 vnic_dev_port_speed(struct vnic_dev 
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
 u32 vnic_dev_mtu(struct vnic_dev *vdev);
 u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev);
-u32 vnic_dev_notify_status(struct vnic_dev *vdev);
-u32 vnic_dev_uif(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
 int vnic_dev_enable(struct vnic_dev *vdev);
-int vnic_dev_enable_wait(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
--- a/drivers/net/enic/vnic_intr.c	2010-09-29 15:21:48.033303590 +0900
+++ b/drivers/net/enic/vnic_intr.c	2010-09-29 15:26:29.273306571 +0900
@@ -65,8 +65,3 @@ void vnic_intr_clean(struct vnic_intr *i
 {
 	iowrite32(0, &intr->ctrl->int_credits);
 }
-
-void vnic_intr_raise(struct vnic_intr *intr)
-{
-	vnic_dev_raise_intr(intr->vdev, (u16)intr->index);
-}
