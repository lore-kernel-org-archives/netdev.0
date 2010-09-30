From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 1/3] enic: Remove dead code
Date: Thu, 30 Sep 2010 16:35:34 -0700
Message-ID: <20100930233503.16528.47303.stgit@savbu-pc100.cisco.com>
References: <20100930233412.16528.52523.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, roprabhu@cisco.com,
	dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:45884 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab0I3Xff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 19:35:35 -0400
In-Reply-To: <20100930233412.16528.52523.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Removed code that is unused

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    3 -
 drivers/net/enic/enic_res.c  |   17 -------
 drivers/net/enic/enic_res.h  |    2 -
 drivers/net/enic/vnic_dev.c  |  104 ------------------------------------------
 drivers/net/enic/vnic_dev.h  |   12 -----
 drivers/net/enic/vnic_intr.c |    5 --
 drivers/net/enic/vnic_rss.h  |   45 ------------------
 7 files changed, 1 insertions(+), 187 deletions(-)
 delete mode 100644 drivers/net/enic/vnic_rss.h


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 75869ed..ae62320 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -28,11 +28,10 @@
 #include "vnic_intr.h"
 #include "vnic_stats.h"
 #include "vnic_nic.h"
-#include "vnic_rss.h"
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.2"
+#define DRV_VERSION		"1.4.1.2a"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 29ede8a..19a276c 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -35,7 +35,6 @@
 #include "vnic_intr.h"
 #include "vnic_stats.h"
 #include "vnic_nic.h"
-#include "vnic_rss.h"
 #include "enic_res.h"
 #include "enic.h"
 
@@ -149,22 +148,6 @@ int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
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
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 83bd172..3c59f54 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -137,8 +137,6 @@ int enic_del_vlan(struct enic *enic, u16 vlanid);
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	u8 rss_hash_bits, u8 rss_base_cpu, u8 rss_enable, u8 tso_ipid_split_en,
 	u8 ig_vlan_strip_en);
-int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len);
-int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len);
 void enic_get_res_counts(struct enic *enic);
 void enic_init_vnic_resources(struct enic *enic);
 int enic_alloc_vnic_resources(struct enic *);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 08d5d42..f99ddee 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -186,21 +186,6 @@ void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
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
@@ -384,18 +369,6 @@ static int vnic_dev_cmd_no_proxy(struct vnic_dev *vdev,
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
@@ -488,13 +461,6 @@ int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
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
@@ -528,19 +494,6 @@ int vnic_dev_enable(struct vnic_dev *vdev)
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
@@ -680,26 +633,6 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
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
@@ -748,19 +681,6 @@ int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
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
@@ -954,30 +874,6 @@ u32 vnic_dev_mtu(struct vnic_dev *vdev)
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
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 3a61873..008304b 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -84,8 +84,6 @@ unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
 	enum vnic_res_type type);
 void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	unsigned int index);
-dma_addr_t vnic_dev_get_res_bus_addr(struct vnic_dev *vdev,
-	enum vnic_res_type type, unsigned int index);
 unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size);
 void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
@@ -95,25 +93,19 @@ void vnic_dev_free_desc_ring(struct vnic_dev *vdev,
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
-int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr);
 int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
 	void *notify_addr, dma_addr_t notify_pa, u16 intr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
@@ -123,12 +115,8 @@ int vnic_dev_link_status(struct vnic_dev *vdev);
 u32 vnic_dev_port_speed(struct vnic_dev *vdev);
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
 u32 vnic_dev_mtu(struct vnic_dev *vdev);
-u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev);
-u32 vnic_dev_notify_status(struct vnic_dev *vdev);
-u32 vnic_dev_uif(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
 int vnic_dev_enable(struct vnic_dev *vdev);
-int vnic_dev_enable_wait(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);
 int vnic_dev_open(struct vnic_dev *vdev, int arg);
 int vnic_dev_open_done(struct vnic_dev *vdev, int *done);
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/enic/vnic_intr.c
index 52ab61a..3873771 100644
--- a/drivers/net/enic/vnic_intr.c
+++ b/drivers/net/enic/vnic_intr.c
@@ -65,8 +65,3 @@ void vnic_intr_clean(struct vnic_intr *intr)
 {
 	iowrite32(0, &intr->ctrl->int_credits);
 }
-
-void vnic_intr_raise(struct vnic_intr *intr)
-{
-	vnic_dev_raise_intr(intr->vdev, (u16)intr->index);
-}
diff --git a/drivers/net/enic/vnic_rss.h b/drivers/net/enic/vnic_rss.h
deleted file mode 100644
index f62d187..0000000
--- a/drivers/net/enic/vnic_rss.h
+++ /dev/null
@@ -1,45 +0,0 @@
-/*
- * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
- * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
- *
- * This program is free software; you may redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; version 2 of the License.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#ifndef _VNIC_RSS_H_
-#define _VNIC_RSS_H_
-
-/* RSS key array */
-union vnic_rss_key {
-	struct {
-		u8 b[10];
-		u8 b_pad[6];
-	} key[4];
-	u64 raw[8];
-};
-
-/* RSS cpu array */
-union vnic_rss_cpu {
-	struct {
-		u8 b[4] ;
-		u8 b_pad[4];
-	} cpu[32];
-	u64 raw[32];
-};
-
-void vnic_set_rss_key(union vnic_rss_key *rss_key, u8 *key);
-void vnic_set_rss_cpu(union vnic_rss_cpu *rss_cpu, u8 *cpu);
-void vnic_get_rss_key(union vnic_rss_key *rss_key, u8 *key);
-void vnic_get_rss_cpu(union vnic_rss_cpu *rss_cpu, u8 *cpu);
-
-#endif /* _VNIC_RSS_H_ */

