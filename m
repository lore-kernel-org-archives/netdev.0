From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/13] rocker: move rocker and rocker_port structs into header
Date: Tue, 16 Feb 2016 13:55:31 +0100
Message-ID: <1455627338-9872-7-git-send-email-jiri@resnulli.us>
References: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37292 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbcBPMzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:55:50 -0500
Received: by mail-wm0-f47.google.com with SMTP id g62so151409786wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:55:49 -0800 (PST)
In-Reply-To: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

And take some other related thing along. They are going to be pushed
into of-dpa part anyway.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h      | 75 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker_main.c | 73 ------------------------------
 2 files changed, 75 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 23b5e3d..05c1e1a 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -13,6 +13,8 @@
 #define _ROCKER_H
 
 #include <linux/types.h>
+#include <linux/hashtable.h>
+#include <linux/if_vlan.h>
 
 #include "rocker_hw.h"
 
@@ -24,4 +26,77 @@ struct rocker_desc_info {
 	dma_addr_t mapaddr;
 };
 
+struct rocker_dma_ring_info {
+	size_t size;
+	u32 head;
+	u32 tail;
+	struct rocker_desc *desc; /* mapped */
+	dma_addr_t mapaddr;
+	struct rocker_desc_info *desc_info;
+	unsigned int type;
+};
+
+struct rocker;
+
+enum {
+	ROCKER_CTRL_LINK_LOCAL_MCAST,
+	ROCKER_CTRL_LOCAL_ARP,
+	ROCKER_CTRL_IPV4_MCAST,
+	ROCKER_CTRL_IPV6_MCAST,
+	ROCKER_CTRL_DFLT_BRIDGING,
+	ROCKER_CTRL_DFLT_OVS,
+	ROCKER_CTRL_MAX,
+};
+
+#define ROCKER_INTERNAL_VLAN_ID_BASE	0x0f00
+#define ROCKER_N_INTERNAL_VLANS		255
+#define ROCKER_VLAN_BITMAP_LEN		BITS_TO_LONGS(VLAN_N_VID)
+#define ROCKER_INTERNAL_VLAN_BITMAP_LEN	BITS_TO_LONGS(ROCKER_N_INTERNAL_VLANS)
+
+struct rocker_port {
+	struct net_device *dev;
+	struct net_device *bridge_dev;
+	struct rocker *rocker;
+	unsigned int port_number;
+	u32 pport;
+	__be16 internal_vlan_id;
+	int stp_state;
+	u32 brport_flags;
+	unsigned long ageing_time;
+	bool ctrls[ROCKER_CTRL_MAX];
+	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
+	struct napi_struct napi_tx;
+	struct napi_struct napi_rx;
+	struct rocker_dma_ring_info tx_ring;
+	struct rocker_dma_ring_info rx_ring;
+};
+
+struct rocker {
+	struct pci_dev *pdev;
+	u8 __iomem *hw_addr;
+	struct msix_entry *msix_entries;
+	unsigned int port_count;
+	struct rocker_port **ports;
+	struct {
+		u64 id;
+	} hw;
+	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
+	struct rocker_dma_ring_info cmd_ring;
+	struct rocker_dma_ring_info event_ring;
+	DECLARE_HASHTABLE(flow_tbl, 16);
+	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
+	u64 flow_tbl_next_cookie;
+	DECLARE_HASHTABLE(group_tbl, 16);
+	spinlock_t group_tbl_lock;		/* for group tbl accesses */
+	struct timer_list fdb_cleanup_timer;
+	DECLARE_HASHTABLE(fdb_tbl, 16);
+	spinlock_t fdb_tbl_lock;		/* for fdb tbl accesses */
+	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
+	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
+	spinlock_t internal_vlan_tbl_lock;	/* for vlan tbl accesses */
+	DECLARE_HASHTABLE(neigh_tbl, 16);
+	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
+	u32 neigh_tbl_next_index;
+};
+
 #endif
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 1a99b35..a67a6c7 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -179,79 +179,6 @@ struct rocker_neigh_tbl_entry {
 	bool ttl_check;
 };
 
-struct rocker_dma_ring_info {
-	size_t size;
-	u32 head;
-	u32 tail;
-	struct rocker_desc *desc; /* mapped */
-	dma_addr_t mapaddr;
-	struct rocker_desc_info *desc_info;
-	unsigned int type;
-};
-
-struct rocker;
-
-enum {
-	ROCKER_CTRL_LINK_LOCAL_MCAST,
-	ROCKER_CTRL_LOCAL_ARP,
-	ROCKER_CTRL_IPV4_MCAST,
-	ROCKER_CTRL_IPV6_MCAST,
-	ROCKER_CTRL_DFLT_BRIDGING,
-	ROCKER_CTRL_DFLT_OVS,
-	ROCKER_CTRL_MAX,
-};
-
-#define ROCKER_INTERNAL_VLAN_ID_BASE	0x0f00
-#define ROCKER_N_INTERNAL_VLANS		255
-#define ROCKER_VLAN_BITMAP_LEN		BITS_TO_LONGS(VLAN_N_VID)
-#define ROCKER_INTERNAL_VLAN_BITMAP_LEN	BITS_TO_LONGS(ROCKER_N_INTERNAL_VLANS)
-
-struct rocker_port {
-	struct net_device *dev;
-	struct net_device *bridge_dev;
-	struct rocker *rocker;
-	unsigned int port_number;
-	u32 pport;
-	__be16 internal_vlan_id;
-	int stp_state;
-	u32 brport_flags;
-	unsigned long ageing_time;
-	bool ctrls[ROCKER_CTRL_MAX];
-	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
-	struct napi_struct napi_tx;
-	struct napi_struct napi_rx;
-	struct rocker_dma_ring_info tx_ring;
-	struct rocker_dma_ring_info rx_ring;
-};
-
-struct rocker {
-	struct pci_dev *pdev;
-	u8 __iomem *hw_addr;
-	struct msix_entry *msix_entries;
-	unsigned int port_count;
-	struct rocker_port **ports;
-	struct {
-		u64 id;
-	} hw;
-	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
-	struct rocker_dma_ring_info cmd_ring;
-	struct rocker_dma_ring_info event_ring;
-	DECLARE_HASHTABLE(flow_tbl, 16);
-	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
-	u64 flow_tbl_next_cookie;
-	DECLARE_HASHTABLE(group_tbl, 16);
-	spinlock_t group_tbl_lock;		/* for group tbl accesses */
-	struct timer_list fdb_cleanup_timer;
-	DECLARE_HASHTABLE(fdb_tbl, 16);
-	spinlock_t fdb_tbl_lock;		/* for fdb tbl accesses */
-	unsigned long internal_vlan_bitmap[ROCKER_INTERNAL_VLAN_BITMAP_LEN];
-	DECLARE_HASHTABLE(internal_vlan_tbl, 8);
-	spinlock_t internal_vlan_tbl_lock;	/* for vlan tbl accesses */
-	DECLARE_HASHTABLE(neigh_tbl, 16);
-	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
-	u32 neigh_tbl_next_index;
-};
-
 static const u8 zero_mac[ETH_ALEN]   = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
 static const u8 ff_mac[ETH_ALEN]     = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 static const u8 ll_mac[ETH_ALEN]     = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
-- 
1.9.3
