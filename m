From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [net-next-2.6 PATCH] infiniband: convert to use
 netdev_for_each_mc_addr
Date: Wed, 24 Feb 2010 16:11:08 +0100
Message-ID: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Due to the loop complexicity in nes_nic.c, I'm using char* to copy mc addresses
to it.

Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/nes/nes_nic.c            |   85 ++++++++++++++----------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    8 +--
 2 files changed, 51 insertions(+), 42 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index c04f8fc..9384f5d 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -810,6 +810,20 @@ static int nes_netdev_set_mac_address(struct net_device *netdev, void *p)
 }
 
 
+static void set_allmulti(struct nes_device *nesdev, u32 nic_active_bit)
+{
+	u32 nic_active;
+
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL);
+	nic_active |= nic_active_bit;
+	nes_write_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL, nic_active);
+	nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_UNICAST_ALL);
+	nic_active &= ~nic_active_bit;
+	nes_write_indexed(nesdev, NES_IDX_NIC_UNICAST_ALL, nic_active);
+}
+
+#define get_addr(addrs, index) ((addrs) + (index) * ETH_ALEN)
+
 /**
  * nes_netdev_set_multicast_list
  */
@@ -818,7 +832,6 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 	struct nes_vnic *nesvnic = netdev_priv(netdev);
 	struct nes_device *nesdev = nesvnic->nesdev;
 	struct nes_adapter *nesadapter = nesvnic->nesdev->nesadapter;
-	struct dev_mc_list *multicast_addr;
 	u32 nic_active_bit;
 	u32 nic_active;
 	u32 perfect_filter_register_address;
@@ -831,6 +844,7 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 					nics_per_function, 4);
 	u8 max_pft_entries_avaiable = NES_PFT_SIZE - pft_entries_preallocated;
 	unsigned long flags;
+	int mc_count = netdev_mc_count(netdev);
 
 	spin_lock_irqsave(&nesadapter->resource_lock, flags);
 	nic_active_bit = 1 << nesvnic->nic_index;
@@ -845,12 +859,7 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 		mc_all_on = 1;
 	} else if ((netdev->flags & IFF_ALLMULTI) ||
 			   (nesvnic->nic_index > 3)) {
-		nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL);
-		nic_active |= nic_active_bit;
-		nes_write_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL, nic_active);
-		nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_UNICAST_ALL);
-		nic_active &= ~nic_active_bit;
-		nes_write_indexed(nesdev, NES_IDX_NIC_UNICAST_ALL, nic_active);
+		set_allmulti(nesdev, nic_active_bit);
 		mc_all_on = 1;
 	} else {
 		nic_active = nes_read_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL);
@@ -862,19 +871,30 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 	}
 
 	nes_debug(NES_DBG_NIC_RX, "Number of MC entries = %d, Promiscous = %d, All Multicast = %d.\n",
-		  netdev_mc_count(netdev), !!(netdev->flags & IFF_PROMISC),
+		  mc_count, !!(netdev->flags & IFF_PROMISC),
 		  !!(netdev->flags & IFF_ALLMULTI));
 	if (!mc_all_on) {
-		multicast_addr = netdev->mc_list;
+		char *addrs;
+		int i;
+		struct dev_mc_list *mcaddr;
+
+		addrs = kmalloc(ETH_ALEN * mc_count, GFP_ATOMIC);
+		if (!addrs) {
+			set_allmulti(nesdev, nic_active_bit);
+			goto unlock;
+		}
+		i = 0;
+		netdev_for_each_mc_addr(mcaddr, netdev)
+			memcpy(get_addr(addrs, i++),
+			       mcaddr->dmi_addr, ETH_ALEN);
+
 		perfect_filter_register_address = NES_IDX_PERFECT_FILTER_LOW +
 						pft_entries_preallocated * 0x8;
-		for (mc_index = 0; mc_index < max_pft_entries_avaiable;
-		mc_index++) {
-			while (multicast_addr && nesvnic->mcrq_mcast_filter &&
+		for (i = 0, mc_index = 0; mc_index < max_pft_entries_avaiable;
+		     mc_index++) {
+			while (i < mc_count && nesvnic->mcrq_mcast_filter &&
 			((mc_nic_index = nesvnic->mcrq_mcast_filter(nesvnic,
-					multicast_addr->dmi_addr)) == 0)) {
-				multicast_addr = multicast_addr->next;
-			}
+					get_addr(addrs, i++))) == 0));
 			if (mc_nic_index < 0)
 				mc_nic_index = nesvnic->nic_index;
 			while (nesadapter->pft_mcast_map[mc_index] < 16 &&
@@ -890,17 +910,19 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 			}
 			if (mc_index >= max_pft_entries_avaiable)
 				break;
-			if (multicast_addr) {
+			if (i < mc_count) {
+				char *addr = get_addr(addrs, i++);
+
 				nes_debug(NES_DBG_NIC_RX, "Assigning MC Address %pM to register 0x%04X nic_idx=%d\n",
-					  multicast_addr->dmi_addr,
+					  addr,
 					  perfect_filter_register_address+(mc_index * 8),
 					  mc_nic_index);
-				macaddr_high  = ((u16)multicast_addr->dmi_addr[0]) << 8;
-				macaddr_high += (u16)multicast_addr->dmi_addr[1];
-				macaddr_low   = ((u32)multicast_addr->dmi_addr[2]) << 24;
-				macaddr_low  += ((u32)multicast_addr->dmi_addr[3]) << 16;
-				macaddr_low  += ((u32)multicast_addr->dmi_addr[4]) << 8;
-				macaddr_low  += (u32)multicast_addr->dmi_addr[5];
+				macaddr_high  = ((u16) addr[0]) << 8;
+				macaddr_high += (u16) addr[1];
+				macaddr_low   = ((u32) addr[2]) << 24;
+				macaddr_low  += ((u32) addr[3]) << 16;
+				macaddr_low  += ((u32) addr[4]) << 8;
+				macaddr_low  += (u32) addr[5];
 				nes_write_indexed(nesdev,
 						perfect_filter_register_address+(mc_index * 8),
 						macaddr_low);
@@ -908,7 +930,6 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 						perfect_filter_register_address+4+(mc_index * 8),
 						(u32)macaddr_high | NES_MAC_ADDR_VALID |
 						((((u32)(1<<mc_nic_index)) << 16)));
-				multicast_addr = multicast_addr->next;
 				nesadapter->pft_mcast_map[mc_index] =
 							nesvnic->nic_index;
 			} else {
@@ -920,21 +941,13 @@ static void nes_netdev_set_multicast_list(struct net_device *netdev)
 				nesadapter->pft_mcast_map[mc_index] = 255;
 			}
 		}
+		kfree(addrs);
 		/* PFT is not large enough */
-		if (multicast_addr && multicast_addr->next) {
-			nic_active = nes_read_indexed(nesdev,
-						NES_IDX_NIC_MULTICAST_ALL);
-			nic_active |= nic_active_bit;
-			nes_write_indexed(nesdev, NES_IDX_NIC_MULTICAST_ALL,
-								nic_active);
-			nic_active = nes_read_indexed(nesdev,
-						NES_IDX_NIC_UNICAST_ALL);
-			nic_active &= ~nic_active_bit;
-			nes_write_indexed(nesdev, NES_IDX_NIC_UNICAST_ALL,
-								nic_active);
-		}
+		if (i < mc_count)
+			set_allmulti(nesdev, nic_active_bit);
 	}
 
+unlock:
 	spin_unlock_irqrestore(&nesadapter->resource_lock, flags);
 }
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 8763c1e..19eba3c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -767,11 +767,8 @@ void ipoib_mcast_dev_flush(struct net_device *dev)
 	}
 }
 
-static int ipoib_mcast_addr_is_valid(const u8 *addr, unsigned int addrlen,
-				     const u8 *broadcast)
+static int ipoib_mcast_addr_is_valid(const u8 *addr, const u8 *broadcast)
 {
-	if (addrlen != INFINIBAND_ALEN)
-		return 0;
 	/* reserved QPN, prefix, scope */
 	if (memcmp(addr, broadcast, 6))
 		return 0;
@@ -811,11 +808,10 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 		clear_bit(IPOIB_MCAST_FLAG_FOUND, &mcast->flags);
 
 	/* Mark all of the entries that are found or don't exist */
-	for (mclist = dev->mc_list; mclist; mclist = mclist->next) {
+	netdev_for_each_mc_addr(mclist, dev) {
 		union ib_gid mgid;
 
 		if (!ipoib_mcast_addr_is_valid(mclist->dmi_addr,
-					       mclist->dmi_addrlen,
 					       dev->broadcast))
 			continue;
 
-- 
1.6.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
