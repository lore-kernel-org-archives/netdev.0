From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 2 Feb 2007 08:45:23 -0500
Message-ID: <20070202134523.GA21479@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41681 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161122AbXBBNp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:45:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/e100.c                      |    7 +--
 drivers/net/netxen/netxen_nic.h         |  136 +++++++++++++++----------------
 drivers/net/netxen/netxen_nic_ethtool.c |   22 +++---
 drivers/net/netxen/netxen_nic_hw.c      |   43 ++++------
 drivers/net/netxen/netxen_nic_hw.h      |   74 +++++++++---------
 drivers/net/netxen/netxen_nic_init.c    |   15 ++--
 drivers/net/netxen/netxen_nic_isr.c     |    4 +-
 drivers/net/netxen/netxen_nic_main.c    |    8 +-
 drivers/net/netxen/netxen_nic_niu.c     |  106 ++++++++++++------------
 drivers/net/spider_net.c                |    2 +
 10 files changed, 199 insertions(+), 218 deletions(-)

Al Viro (1):
      netxen patches (trivial sparse annotations)

Auke Kok (1):
      e100: fix napi ifdefs removing needed code

Jens Osterkamp (1):
      spidernet : fix memory leak in spider_net_stop

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 3208dac..0cefef5 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2718,14 +2718,12 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-#ifdef CONFIG_E100_NAPI
 	if (netif_running(netdev))
 		netif_poll_disable(nic->netdev);
-#endif
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
-
 	netif_device_detach(netdev);
+
 	pci_save_state(pdev);
 
 	if ((nic->flags & wol_magic) | e100_asf(nic)) {
@@ -2761,16 +2759,13 @@ static int e100_resume(struct pci_dev *pdev)
 }
 #endif /* CONFIG_PM */
 
-
 static void e100_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-#ifdef CONFIG_E100_NAPI
 	if (netif_running(netdev))
 		netif_poll_disable(nic->netdev);
-#endif
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
 
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 59324b1..e8598b8 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -239,49 +239,39 @@ extern unsigned long long netxen_dma_mask;
 
 typedef u32 netxen_ctx_msg;
 
-#define _netxen_set_bits(config_word, start, bits, val)	{\
-	unsigned long long mask = (((1ULL << (bits)) - 1) << (start));	\
-	unsigned long long value = (val);	\
-	(config_word) &= ~mask;	\
-	(config_word) |= (((value) << (start)) & mask); \
-}
-
 #define netxen_set_msg_peg_id(config_word, val)	\
-	_netxen_set_bits(config_word, 0, 2, val)
+	((config_word) &= ~3, (config_word) |= val & 3)
 #define netxen_set_msg_privid(config_word)	\
-	set_bit(2, (unsigned long*)&config_word)
+	((config_word) |= 1 << 2)
 #define netxen_set_msg_count(config_word, val)	\
-	_netxen_set_bits(config_word, 3, 15, val)
+	((config_word) &= ~(0x7fff<<3), (config_word) |= (val & 0x7fff) << 3)
 #define netxen_set_msg_ctxid(config_word, val)	\
-	_netxen_set_bits(config_word, 18, 10, val)
+	((config_word) &= ~(0x3ff<<18), (config_word) |= (val & 0x3ff) << 18)
 #define netxen_set_msg_opcode(config_word, val)	\
-	_netxen_set_bits(config_word, 28, 4, val)
+	((config_word) &= ~(0xf<<24), (config_word) |= (val & 0xf) << 24)
 
 struct netxen_rcv_context {
-	u32 rcv_ring_addr_lo;
-	u32 rcv_ring_addr_hi;
-	u32 rcv_ring_size;
-	u32 rsrvd;
+	__le64 rcv_ring_addr;
+	__le32 rcv_ring_size;
+	__le32 rsrvd;
 };
 
 struct netxen_ring_ctx {
 
 	/* one command ring */
-	u64 cmd_consumer_offset;
-	u32 cmd_ring_addr_lo;
-	u32 cmd_ring_addr_hi;
-	u32 cmd_ring_size;
-	u32 rsrvd;
+	__le64 cmd_consumer_offset;
+	__le64 cmd_ring_addr;
+	__le32 cmd_ring_size;
+	__le32 rsrvd;
 
 	/* three receive rings */
 	struct netxen_rcv_context rcv_ctx[3];
 
 	/* one status ring */
-	u32 sts_ring_addr_lo;
-	u32 sts_ring_addr_hi;
-	u32 sts_ring_size;
+	__le64 sts_ring_addr;
+	__le32 sts_ring_size;
 
-	u32 ctx_id;
+	__le32 ctx_id;
 } __attribute__ ((aligned(64)));
 
 /*
@@ -305,81 +295,85 @@ struct netxen_ring_ctx {
 	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
 
 #define netxen_set_cmd_desc_flags(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->flags_opcode, 0, 7, val)
+	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x7f), \
+	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
 #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->flags_opcode, 7, 6, val)
+	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
+	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & (0x3f<<7)))
 
 #define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->num_of_buffers_total_length, 0, 8, val);
+	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
+	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->num_of_buffers_total_length, 8, 24, val);
+	((cmd_desc)->num_of_buffers_total_length &= cpu_to_le32(0xff), \
+	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 24))
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
-	(((cmd_desc)->flags_opcode >> 7) & 0x003F)
+	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
 #define netxen_get_cmd_desc_totallength(cmd_desc)	\
-	(((cmd_desc)->num_of_buffers_total_length >> 8) & 0x0FFFFFF)
+	(le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8)
 
 struct cmd_desc_type0 {
 	u8 tcp_hdr_offset;	/* For LSO only */
 	u8 ip_hdr_offset;	/* For LSO only */
 	/* Bit pattern: 0-6 flags, 7-12 opcode, 13-15 unused */
-	u16 flags_opcode;
+	__le16 flags_opcode;
 	/* Bit pattern: 0-7 total number of segments,
 	   8-31 Total size of the packet */
-	u32 num_of_buffers_total_length;
+	__le32 num_of_buffers_total_length;
 	union {
 		struct {
-			u32 addr_low_part2;
-			u32 addr_high_part2;
+			__le32 addr_low_part2;
+			__le32 addr_high_part2;
 		};
-		u64 addr_buffer2;
+		__le64 addr_buffer2;
 	};
 
-	u16 reference_handle;	/* changed to u16 to add mss */
-	u16 mss;		/* passed by NDIS_PACKET for LSO */
+	__le16 reference_handle;	/* changed to u16 to add mss */
+	__le16 mss;		/* passed by NDIS_PACKET for LSO */
 	/* Bit pattern 0-3 port, 0-3 ctx id */
 	u8 port_ctxid;
 	u8 total_hdr_length;	/* LSO only : MAC+IP+TCP Hdr size */
-	u16 conn_id;		/* IPSec offoad only */
+	__le16 conn_id;		/* IPSec offoad only */
 
 	union {
 		struct {
-			u32 addr_low_part3;
-			u32 addr_high_part3;
+			__le32 addr_low_part3;
+			__le32 addr_high_part3;
 		};
-		u64 addr_buffer3;
+		__le64 addr_buffer3;
 	};
 	union {
 		struct {
-			u32 addr_low_part1;
-			u32 addr_high_part1;
+			__le32 addr_low_part1;
+			__le32 addr_high_part1;
 		};
-		u64 addr_buffer1;
+		__le64 addr_buffer1;
 	};
 
-	u16 buffer1_length;
-	u16 buffer2_length;
-	u16 buffer3_length;
-	u16 buffer4_length;
+	__le16 buffer1_length;
+	__le16 buffer2_length;
+	__le16 buffer3_length;
+	__le16 buffer4_length;
 
 	union {
 		struct {
-			u32 addr_low_part4;
-			u32 addr_high_part4;
+			__le32 addr_low_part4;
+			__le32 addr_high_part4;
 		};
-		u64 addr_buffer4;
+		__le64 addr_buffer4;
 	};
 
-	u64 unused;
+	__le64 unused;
 
 } __attribute__ ((aligned(64)));
 
 /* Note: sizeof(rcv_desc) should always be a mutliple of 2 */
 struct rcv_desc {
-	u16 reference_handle;
-	u16 reserved;
-	u32 buffer_length;	/* allocated buffer length (usually 2K) */
-	u64 addr_buffer;
+	__le16 reference_handle;
+	__le16 reserved;
+	__le32 buffer_length;	/* allocated buffer length (usually 2K) */
+	__le64 addr_buffer;
 };
 
 /* opcode field in status_desc */
@@ -405,36 +399,36 @@ struct rcv_desc {
 	(((status_desc)->lro & 0x80) >> 7)
 
 #define netxen_get_sts_port(status_desc)	\
-	((status_desc)->status_desc_data & 0x0F)
+	(le64_to_cpu((status_desc)->status_desc_data) & 0x0F)
 #define netxen_get_sts_status(status_desc)	\
-	(((status_desc)->status_desc_data >> 4) & 0x0F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 4) & 0x0F)
 #define netxen_get_sts_type(status_desc)	\
-	(((status_desc)->status_desc_data >> 8) & 0x0F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 8) & 0x0F)
 #define netxen_get_sts_totallength(status_desc)	\
-	(((status_desc)->status_desc_data >> 12) & 0xFFFF)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 12) & 0xFFFF)
 #define netxen_get_sts_refhandle(status_desc)	\
-	(((status_desc)->status_desc_data >> 28) & 0xFFFF)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 28) & 0xFFFF)
 #define netxen_get_sts_prot(status_desc)	\
-	(((status_desc)->status_desc_data >> 44) & 0x0F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 44) & 0x0F)
 #define netxen_get_sts_owner(status_desc)	\
-	(((status_desc)->status_desc_data >> 56) & 0x03)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 56) & 0x03)
 #define netxen_get_sts_opcode(status_desc)	\
-	(((status_desc)->status_desc_data >> 58) & 0x03F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 58) & 0x03F)
 
 #define netxen_clear_sts_owner(status_desc)	\
 	((status_desc)->status_desc_data &=	\
-	~(((unsigned long long)3) << 56 ))
+	~cpu_to_le64(((unsigned long long)3) << 56 ))
 #define netxen_set_sts_owner(status_desc, val)	\
 	((status_desc)->status_desc_data |=	\
-	(((unsigned long long)((val) & 0x3)) << 56 ))
+	cpu_to_le64(((unsigned long long)((val) & 0x3)) << 56 ))
 
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
 	   28-43 reference_handle, 44-47 protocol, 48-52 unused
 	   53-55 desc_cnt, 56-57 owner, 58-63 opcode
 	 */
-	u64 status_desc_data;
-	u32 hash_value;
+	__le64 status_desc_data;
+	__le32 hash_value;
 	u8 hash_type;
 	u8 msg_type;
 	u8 unused;
@@ -1005,9 +999,9 @@ void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter, int port,
 void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter, int port,
 				  long enable);
 int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy, long reg,
-			    __le32 * readval);
+			    __u32 * readval);
 int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long phy,
-			     long reg, __le32 val);
+			     long reg, __u32 val);
 
 /* Functions available from netxen_nic_hw.c */
 int netxen_nic_set_mtu_xgb(struct netxen_port *port, int new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 3404461..c381d77 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -218,7 +218,7 @@ netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	__le32 status;
+	__u32 status;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
@@ -226,7 +226,7 @@ netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (adapter->phy_write
 		    && adapter->phy_write(adapter, port->portnum,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					  (__le32) ecmd->autoneg) != 0)
+					  ecmd->autoneg) != 0)
 			return -EIO;
 		else
 			port->link_autoneg = ecmd->autoneg;
@@ -279,7 +279,7 @@ static int netxen_nic_get_regs_len(struct net_device *dev)
 }
 
 struct netxen_niu_regs {
-	__le32 reg[NETXEN_NIC_REGS_COUNT];
+	__u32 reg[NETXEN_NIC_REGS_COUNT];
 };
 
 static struct netxen_niu_regs niu_registers[] = {
@@ -372,7 +372,7 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	__le32 mode, *regs_buff = p;
+	__u32 mode, *regs_buff = p;
 	void __iomem *addr;
 	int i, window;
 
@@ -415,7 +415,7 @@ static u32 netxen_nic_get_link(struct net_device *dev)
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	__le32 status;
+	__u32 status;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
@@ -482,13 +482,13 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	__le32 val;
+	__u32 val;
 
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* get flow control settings */
 		netxen_nic_read_w0(adapter,
 				   NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
-				   (u32 *) & val);
+				   &val);
 		pause->rx_pause = netxen_gb_get_rx_flowctl(val);
 		pause->tx_pause = netxen_gb_get_tx_flowctl(val);
 		/* get autoneg settings */
@@ -502,7 +502,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	__le32 val;
+	__u32 val;
 	unsigned int autoneg;
 
 	/* read mode */
@@ -522,13 +522,13 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 
 		netxen_nic_write_w0(adapter,
 				    NETXEN_NIU_GB_MAC_CONFIG_0(port->portnum),
-				    *(u32 *) (&val));
+				    *&val);
 		/* set autoneg */
 		autoneg = pause->autoneg;
 		if (adapter->phy_write
 		    && adapter->phy_write(adapter, port->portnum,
 					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					  (__le32) autoneg) != 0)
+					  autoneg) != 0)
 			return -EIO;
 		else {
 			port->link_autoneg = pause->autoneg;
@@ -543,7 +543,7 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
 	u32 data_read, data_written, save;
-	__le32 mode;
+	__u32 mode;
 
 	/* 
 	 * first test the "Read Only" registers by writing which mode
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 191e233..f263232 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -95,7 +95,7 @@ void netxen_nic_set_multi(struct net_device *netdev)
 	struct netxen_port *port = netdev_priv(netdev);
 	struct netxen_adapter *adapter = port->adapter;
 	struct dev_mc_list *mc_ptr;
-	__le32 netxen_mac_addr_cntl_data = 0;
+	__u32 netxen_mac_addr_cntl_data = 0;
 
 	mc_ptr = netdev->mc_list;
 	if (netdev->flags & IFF_PROMISC) {
@@ -236,8 +236,9 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 	}
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
 	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
-	adapter->ctx_desc->cmd_consumer_offset = adapter->ctx_desc_phys_addr
-	    + sizeof(struct netxen_ring_ctx);
+	adapter->ctx_desc->cmd_consumer_offset =
+	    cpu_to_le64(adapter->ctx_desc_phys_addr +
+			sizeof(struct netxen_ring_ctx));
 	adapter->cmd_consumer = (uint32_t *) (((char *)addr) +
 					      sizeof(struct netxen_ring_ctx));
 
@@ -253,11 +254,10 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	adapter->ctx_desc->cmd_ring_addr_lo =
-	    hw->cmd_desc_phys_addr & 0xffffffffUL;
-	adapter->ctx_desc->cmd_ring_addr_hi =
-	    ((u64) hw->cmd_desc_phys_addr >> 32);
-	adapter->ctx_desc->cmd_ring_size = adapter->max_tx_desc_count;
+	adapter->ctx_desc->cmd_ring_addr =
+		cpu_to_le64(hw->cmd_desc_phys_addr);
+	adapter->ctx_desc->cmd_ring_size =
+		cpu_to_le32(adapter->max_tx_desc_count);
 
 	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
 
@@ -278,12 +278,10 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 				return err;
 			}
 			rcv_desc->desc_head = (struct rcv_desc *)addr;
-			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr_lo =
-			    rcv_desc->phys_addr & 0xffffffffUL;
-			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr_hi =
-			    ((u64) rcv_desc->phys_addr >> 32);
+			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
+			    cpu_to_le64(rcv_desc->phys_addr);
 			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
-			    rcv_desc->max_rx_desc_count;
+			    cpu_to_le32(rcv_desc->max_rx_desc_count);
 		}
 
 		addr = netxen_alloc(adapter->ahw.pdev, STATUS_DESC_RINGSIZE,
@@ -297,11 +295,10 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			return err;
 		}
 		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
-		adapter->ctx_desc->sts_ring_addr_lo =
-		    recv_ctx->rcv_status_desc_phys_addr & 0xffffffffUL;
-		adapter->ctx_desc->sts_ring_addr_hi =
-		    ((u64) recv_ctx->rcv_status_desc_phys_addr >> 32);
-		adapter->ctx_desc->sts_ring_size = adapter->max_rx_desc_count;
+		adapter->ctx_desc->sts_ring_addr =
+		    cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
+		adapter->ctx_desc->sts_ring_size =
+		    cpu_to_le32(adapter->max_rx_desc_count);
 
 	}
 	/* Window = 1 */
@@ -387,10 +384,6 @@ void netxen_tso_check(struct netxen_adapter *adapter,
 	}
 	adapter->stats.xmitcsummed++;
 	desc->tcp_hdr_offset = skb->h.raw - skb->data;
-	netxen_set_cmd_desc_totallength(desc,
-					cpu_to_le32
-					(netxen_get_cmd_desc_totallength
-					 (desc)));
 	desc->ip_hdr_offset = skb->nh.raw - skb->data;
 }
 
@@ -867,9 +860,9 @@ netxen_crb_writelit_adapter(struct netxen_adapter *adapter, unsigned long off,
 void netxen_nic_set_link_parameters(struct netxen_port *port)
 {
 	struct netxen_adapter *adapter = port->adapter;
-	__le32 status;
-	__le32 autoneg;
-	__le32 mode;
+	__u32 status;
+	__u32 autoneg;
+	__u32 mode;
 
 	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
 	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 0685633..ab1112e 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -124,28 +124,28 @@ typedef enum {
  */
 
 #define netxen_gb_enable_tx(config_word)	\
-	set_bit(0, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 0)
 #define netxen_gb_enable_rx(config_word)	\
-	set_bit(2, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 2)
 #define netxen_gb_tx_flowctl(config_word)	\
-	set_bit(4, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 4)
 #define netxen_gb_rx_flowctl(config_word)	\
-	set_bit(5, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 5)
 #define netxen_gb_tx_reset_pb(config_word)	\
-		set_bit(16, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 16)
 #define netxen_gb_rx_reset_pb(config_word)	\
-		set_bit(17, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 17)
 #define netxen_gb_tx_reset_mac(config_word)	\
-		set_bit(18, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 18)
 #define netxen_gb_rx_reset_mac(config_word)	\
-		set_bit(19, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 19)
 #define netxen_gb_soft_reset(config_word)	\
-		set_bit(31, (unsigned long*)(&config_word))
+	((config_word) |= 1 << 31)
 
 #define netxen_gb_unset_tx_flowctl(config_word)	\
-		clear_bit(4, (unsigned long *)(&config_word))
+	((config_word) &= ~(1 << 4))
 #define netxen_gb_unset_rx_flowctl(config_word)	\
-		clear_bit(5, (unsigned long*)(&config_word))
+	((config_word) &= ~(1 << 5))
 
 #define netxen_gb_get_tx_synced(config_word)	\
 		_netxen_crb_get_bit((config_word), 1)
@@ -171,15 +171,15 @@ typedef enum {
  */
 
 #define netxen_gb_set_duplex(config_word)	\
-		set_bit(0, (unsigned long*)&config_word)
+		((config_word) |= 1 << 0)
 #define netxen_gb_set_crc_enable(config_word)	\
-		set_bit(1, (unsigned long*)&config_word)
+		((config_word) |= 1 << 1)
 #define netxen_gb_set_padshort(config_word)	\
-		set_bit(2, (unsigned long*)&config_word)
+		((config_word) |= 1 << 2)
 #define netxen_gb_set_checklength(config_word)	\
-		set_bit(4, (unsigned long*)&config_word)
+		((config_word) |= 1 << 4)
 #define netxen_gb_set_hugeframes(config_word)	\
-		set_bit(5, (unsigned long*)&config_word)
+		((config_word) |= 1 << 5)
 #define netxen_gb_set_preamblelen(config_word, val)	\
 		((config_word) |= ((val) << 12) & 0xF000)
 #define netxen_gb_set_intfmode(config_word, val)		\
@@ -190,9 +190,9 @@ typedef enum {
 #define netxen_gb_set_mii_mgmt_clockselect(config_word, val)	\
 		((config_word) |= ((val) & 0x07))
 #define netxen_gb_mii_mgmt_reset(config_word)	\
-		set_bit(31, (unsigned long*)&config_word)
+		((config_word) |= 1 << 31)
 #define netxen_gb_mii_mgmt_unset(config_word)	\
-		clear_bit(31, (unsigned long*)&config_word)
+		((config_word) &= ~(1 << 31))
 
 /*
  * NIU GB MII Mgmt Command Register (applies to GB0, GB1, GB2, GB3)
@@ -201,7 +201,7 @@ typedef enum {
  */
 
 #define netxen_gb_mii_mgmt_set_read_cycle(config_word)	\
-		set_bit(0, (unsigned long*)&config_word)
+		((config_word) |= 1 << 0)
 #define netxen_gb_mii_mgmt_reg_addr(config_word, val)	\
 		((config_word) |= ((val) & 0x1F))
 #define netxen_gb_mii_mgmt_phy_addr(config_word, val)	\
@@ -274,9 +274,9 @@ typedef enum {
 #define netxen_set_phy_speed(config_word, val)	\
 		((config_word) |= ((val & 0x03) << 14))
 #define netxen_set_phy_duplex(config_word)	\
-		set_bit(13, (unsigned long*)&config_word)
+		((config_word) |= 1 << 13)
 #define netxen_clear_phy_duplex(config_word)	\
-		clear_bit(13, (unsigned long*)&config_word)
+		((config_word) &= ~(1 << 13))
 
 #define netxen_get_phy_jabber(config_word)	\
 		_netxen_crb_get_bit(config_word, 0)
@@ -350,11 +350,11 @@ typedef enum {
 		_netxen_crb_get_bit(config_word, 15)
 
 #define netxen_set_phy_int_link_status_changed(config_word)	\
-		set_bit(10, (unsigned long*)&config_word)
+		((config_word) |= 1 << 10)
 #define netxen_set_phy_int_autoneg_completed(config_word)	\
-		set_bit(11, (unsigned long*)&config_word)
+		((config_word) |= 1 << 11)
 #define netxen_set_phy_int_speed_changed(config_word)	\
-		set_bit(14, (unsigned long*)&config_word)
+		((config_word) |= 1 << 14)
 
 /*
  * NIU Mode Register.
@@ -382,22 +382,22 @@ typedef enum {
  */
 
 #define netxen_set_gb_drop_gb0(config_word)	\
-		set_bit(0, (unsigned long*)&config_word)
+		((config_word) |= 1 << 0)
 #define netxen_set_gb_drop_gb1(config_word)	\
-		set_bit(1, (unsigned long*)&config_word)
+		((config_word) |= 1 << 1)
 #define netxen_set_gb_drop_gb2(config_word)	\
-		set_bit(2, (unsigned long*)&config_word)
+		((config_word) |= 1 << 2)
 #define netxen_set_gb_drop_gb3(config_word)	\
-		set_bit(3, (unsigned long*)&config_word)
+		((config_word) |= 1 << 3)
 
 #define netxen_clear_gb_drop_gb0(config_word)	\
-		clear_bit(0, (unsigned long*)&config_word)
+		((config_word) &= ~(1 << 0))
 #define netxen_clear_gb_drop_gb1(config_word)	\
-		clear_bit(1, (unsigned long*)&config_word)
+		((config_word) &= ~(1 << 1))
 #define netxen_clear_gb_drop_gb2(config_word)	\
-		clear_bit(2, (unsigned long*)&config_word)
+		((config_word) &= ~(1 << 2))
 #define netxen_clear_gb_drop_gb3(config_word)	\
-		clear_bit(3, (unsigned long*)&config_word)
+		((config_word) &= ~(1 << 3))
 
 /*
  * NIU XG MAC Config Register
@@ -413,7 +413,7 @@ typedef enum {
  */
 
 #define netxen_xg_soft_reset(config_word)	\
-		set_bit(4, (unsigned long*)&config_word)
+		((config_word) |= 1 << 4)
 
 /*
  * MAC Control Register
@@ -433,19 +433,19 @@ typedef enum {
 #define netxen_nic_mcr_set_id_pool0(config, val)	\
 		((config) |= ((val) &0x03))
 #define netxen_nic_mcr_set_enable_xtnd0(config)	\
-		(set_bit(3, (unsigned long *)&(config)))
+		((config) |= 1 << 3)
 #define netxen_nic_mcr_set_id_pool1(config, val)	\
 		((config) |= (((val) & 0x03) << 4))
 #define netxen_nic_mcr_set_enable_xtnd1(config)	\
-		(set_bit(6, (unsigned long *)&(config)))
+		((config) |= 1 << 6)
 #define netxen_nic_mcr_set_id_pool2(config, val)	\
 		((config) |= (((val) & 0x03) << 8))
 #define netxen_nic_mcr_set_enable_xtnd2(config)	\
-		(set_bit(10, (unsigned long *)&(config)))
+		((config) |= 1 << 10)
 #define netxen_nic_mcr_set_id_pool3(config, val)	\
 		((config) |= (((val) & 0x03) << 12))
 #define netxen_nic_mcr_set_enable_xtnd3(config)	\
-		(set_bit(14, (unsigned long *)&(config)))
+		((config) |= 1 << 14)
 #define netxen_nic_mcr_set_mode_select(config, val)	\
 		((config) |= (((val) & 0x03) << 24))
 #define netxen_nic_mcr_set_enable_pool(config, val)	\
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c3e41f3..973af96 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -690,8 +690,7 @@ int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
 		desc_head = recv_ctx->rcv_status_desc_head;
 		desc = &desc_head[consumer];
 
-		if (((le16_to_cpu(netxen_get_sts_owner(desc)))
-		     & STATUS_OWNER_HOST))
+		if (netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)
 			return 1;
 	}
 
@@ -787,11 +786,11 @@ netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	struct netxen_port *port = adapter->port[netxen_get_sts_port(desc)];
 	struct pci_dev *pdev = port->pdev;
 	struct net_device *netdev = port->netdev;
-	int index = le16_to_cpu(netxen_get_sts_refhandle(desc));
+	int index = netxen_get_sts_refhandle(desc);
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = le16_to_cpu(netxen_get_sts_totallength(desc));
+	u32 length = netxen_get_sts_totallength(desc);
 	u32 desc_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ret;
@@ -918,16 +917,14 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 	 */
 	while (count < max) {
 		desc = &desc_head[consumer];
-		if (!
-		    (le16_to_cpu(netxen_get_sts_owner(desc)) &
-		     STATUS_OWNER_HOST)) {
+		if (!(netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)) {
 			DPRINTK(ERR, "desc %p ownedby %x\n", desc,
 				netxen_get_sts_owner(desc));
 			break;
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
 		netxen_clear_sts_owner(desc);
-		netxen_set_sts_owner(desc, cpu_to_le16(STATUS_OWNER_PHANTOM));
+		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
@@ -1232,7 +1229,7 @@ void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ctx,
 
 		/* make a rcv descriptor  */
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
-		pdesc->buffer_length = cpu_to_le16(rcv_desc->dma_size);
+		pdesc->buffer_length = cpu_to_le32(rcv_desc->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 		DPRINTK(INFO, "done writing descripter\n");
 		producer =
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 06847d4..be366e4 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -79,7 +79,7 @@ void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 portno,
 void netxen_handle_port_int(struct netxen_adapter *adapter, u32 portno,
 			    u32 enable)
 {
-	__le32 int_src;
+	__u32 int_src;
 	struct netxen_port *port;
 
 	/*  This should clear the interrupt source */
@@ -110,7 +110,7 @@ void netxen_handle_port_int(struct netxen_adapter *adapter, u32 portno,
 	/* write it down later.. */
 	if ((netxen_get_phy_int_speed_changed(int_src))
 	    || (netxen_get_phy_int_link_status_changed(int_src))) {
-		__le32 status;
+		__u32 status;
 
 		DPRINTK(INFO, "SPEED CHANGED OR LINK STATUS CHANGED \n");
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 96e1bee..69c1b9d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -117,7 +117,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	void __iomem *mem_ptr1 = NULL;
 	void __iomem *mem_ptr2 = NULL;
 
-	u8 *db_ptr = NULL;
+	u8 __iomem *db_ptr = NULL;
 	unsigned long mem_base, mem_len, db_base, db_len;
 	int pci_using_dac, i, err;
 	int ring;
@@ -191,7 +191,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		db_len);
 
 	db_ptr = ioremap(db_base, NETXEN_DB_MAPSIZE_BYTES);
-	if (db_ptr == 0UL) {
+	if (!db_ptr) {
 		printk(KERN_ERR "%s: Failed to allocate doorbell map.",
 		       netxen_nic_driver_name);
 		err = -EIO;
@@ -818,7 +818,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* Take skb->data itself */
 	pbuf = &adapter->cmd_buf_arr[producer];
 	if ((netdev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size > 0) {
-		pbuf->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+		pbuf->mss = skb_shinfo(skb)->gso_size;
 		hwdesc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 	} else {
 		pbuf->mss = 0;
@@ -882,7 +882,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			hwdesc->addr_buffer3 = cpu_to_le64(temp_dma);
 			break;
 		case 3:
-			hwdesc->buffer4_length = temp_len;
+			hwdesc->buffer4_length = cpu_to_le16(temp_len);
 			hwdesc->addr_buffer4 = cpu_to_le64(temp_dma);
 			break;
 		}
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 4987dc7..40d7003 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -89,15 +89,15 @@ static inline int phy_unlock(struct netxen_adapter *adapter)
  *
  */
 int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
-			    long reg, __le32 * readval)
+			    long reg, __u32 * readval)
 {
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
-	__le32 address;
-	__le32 command;
-	__le32 status;
-	__le32 mac_cfg0;
+	__u32 address;
+	__u32 command;
+	__u32 status;
+	__u32 mac_cfg0;
 
 	if (phy_lock(adapter) != 0) {
 		return -1;
@@ -112,7 +112,7 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
 				  &mac_cfg0, 4))
 		return -EIO;
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
-		__le32 temp;
+		__u32 temp;
 		temp = 0;
 		netxen_gb_tx_reset_pb(temp);
 		netxen_gb_rx_reset_pb(temp);
@@ -184,15 +184,15 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
  *
  */
 int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
-			     long phy, long reg, __le32 val)
+			     long phy, long reg, __u32 val)
 {
 	long timeout = 0;
 	long result = 0;
 	long restore = 0;
-	__le32 address;
-	__le32 command;
-	__le32 status;
-	__le32 mac_cfg0;
+	__u32 address;
+	__u32 command;
+	__u32 status;
+	__u32 mac_cfg0;
 
 	/*
 	 * MII mgmt all goes through port 0 MAC interface, so it
@@ -203,7 +203,7 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
 				  &mac_cfg0, 4))
 		return -EIO;
 	if (netxen_gb_get_soft_reset(mac_cfg0)) {
-		__le32 temp;
+		__u32 temp;
 		temp = 0;
 		netxen_gb_tx_reset_pb(temp);
 		netxen_gb_rx_reset_pb(temp);
@@ -269,7 +269,7 @@ int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter,
 					 int port)
 {
 	int result = 0;
-	__le32 enable = 0;
+	__u32 enable = 0;
 	netxen_set_phy_int_link_status_changed(enable);
 	netxen_set_phy_int_autoneg_completed(enable);
 	netxen_set_phy_int_speed_changed(enable);
@@ -402,7 +402,7 @@ void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
 int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 {
 	int result = 0;
-	__le32 status;
+	__u32 status;
 	if (adapter->disable_phy_interrupts)
 		adapter->disable_phy_interrupts(adapter, port);
 	mdelay(2);
@@ -410,7 +410,7 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 	if (0 ==
 	    netxen_niu_gbe_phy_read(adapter, port,
 				    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-				    (__le32 *) & status)) {
+				    &status)) {
 		if (netxen_get_phy_link(status)) {
 			if (netxen_get_phy_speed(status) == 2) {
 				netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
@@ -489,7 +489,7 @@ int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
 					int port, long enable)
 {
 	int result = 0;
-	__le32 int_src;
+	__u32 int_src;
 
 	printk(KERN_INFO PFX "NETXEN: Handling PHY interrupt on port %d"
 	       " (device enable = %d)\n", (int)port, (int)enable);
@@ -530,7 +530,7 @@ int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
 			printk(KERN_INFO PFX "autoneg_error ");
 		if ((netxen_get_phy_int_speed_changed(int_src))
 		    || (netxen_get_phy_int_link_status_changed(int_src))) {
-			__le32 status;
+			__u32 status;
 
 			printk(KERN_INFO PFX
 			       "speed_changed or link status changed");
@@ -583,9 +583,9 @@ int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
 int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 			   int phy, netxen_ethernet_macaddr_t * addr)
 {
-	u64 result = 0;
-	__le32 stationhigh;
-	__le32 stationlow;
+	u32 stationhigh;
+	u32 stationlow;
+	u8 val[8];
 
 	if (addr == NULL)
 		return -EINVAL;
@@ -598,10 +598,10 @@ int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
 				  &stationlow, 4))
 		return -EIO;
+	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
+	((__le32 *)val)[0] = cpu_to_le32(stationlow);
 
-	result = (u64) netxen_gb_get_stationaddress_low(stationlow);
-	result |= (u64) stationhigh << 16;
-	memcpy(*addr, &result, sizeof(netxen_ethernet_macaddr_t));
+	memcpy(addr, val + 2, 6);
 
 	return 0;
 }
@@ -613,24 +613,25 @@ int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
 int netxen_niu_macaddr_set(struct netxen_port *port,
 			   netxen_ethernet_macaddr_t addr)
 {
-	__le32 temp = 0;
+	u8 temp[4];
+	u32 val;
 	struct netxen_adapter *adapter = port->adapter;
 	int phy = port->portnum;
 	unsigned char mac_addr[6];
 	int i;
 
 	for (i = 0; i < 10; i++) {
-		memcpy(&temp, addr, 2);
-		temp <<= 16;
+		temp[0] = temp[1] = 0;
+		memcpy(temp + 2, addr, 2);
+		val = le32_to_cpu(*(__le32 *)temp);
 		if (netxen_nic_hw_write_wx
-		    (adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), &temp, 4))
+		    (adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy), &val, 4))
 			return -EIO;
 
-		temp = 0;
-
-		memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
+		memcpy(temp, ((u8 *) addr) + 2, sizeof(__le32));
+		val = le32_to_cpu(*(__le32 *)temp);
 		if (netxen_nic_hw_write_wx
-		    (adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), &temp, 4))
+		    (adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy), &val, 4))
 			return -2;
 
 		netxen_niu_macaddr_get(adapter, phy,
@@ -659,9 +660,9 @@ int netxen_niu_macaddr_set(struct netxen_port *port,
 int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 			       int port, netxen_niu_gbe_ifmode_t mode)
 {
-	__le32 mac_cfg0;
-	__le32 mac_cfg1;
-	__le32 mii_cfg;
+	__u32 mac_cfg0;
+	__u32 mac_cfg1;
+	__u32 mii_cfg;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;
@@ -736,7 +737,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
 /* Disable a GbE interface */
 int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, int port)
 {
-	__le32 mac_cfg0;
+	__u32 mac_cfg0;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;
@@ -752,7 +753,7 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, int port)
 /* Disable an XG interface */
 int netxen_niu_disable_xg_port(struct netxen_adapter *adapter, int port)
 {
-	__le32 mac_cfg;
+	__u32 mac_cfg;
 
 	if (port != 0)
 		return -EINVAL;
@@ -769,7 +770,7 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter, int port)
 int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, int port,
 				    netxen_niu_prom_mode_t mode)
 {
-	__le32 reg;
+	__u32 reg;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;
@@ -826,22 +827,21 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, int port,
 int netxen_niu_xg_macaddr_set(struct netxen_port *port,
 			      netxen_ethernet_macaddr_t addr)
 {
-	__le32 temp = 0;
+	u8 temp[4];
+	u32 val;
 	struct netxen_adapter *adapter = port->adapter;
 
-	memcpy(&temp, addr, 2);
-	temp = cpu_to_le32(temp);
-	temp <<= 16;
+	temp[0] = temp[1] = 0;
+	memcpy(temp + 2, addr, 2);
+	val = le32_to_cpu(*(__le32 *)temp);
 	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
-				   &temp, 4))
+				   &val, 4))
 		return -EIO;
 
-	temp = 0;
-
 	memcpy(&temp, ((u8 *) addr) + 2, sizeof(__le32));
-	temp = cpu_to_le32(temp);
+	val = le32_to_cpu(*(__le32 *)temp);
 	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
-				   &temp, 4))
+				   &val, 4))
 		return -EIO;
 
 	return 0;
@@ -854,9 +854,9 @@ int netxen_niu_xg_macaddr_set(struct netxen_port *port,
 int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
 			      netxen_ethernet_macaddr_t * addr)
 {
-	__le32 stationhigh;
-	__le32 stationlow;
-	u64 result;
+	u32 stationhigh;
+	u32 stationlow;
+	u8 val[8];
 
 	if (addr == NULL)
 		return -EINVAL;
@@ -869,10 +869,10 @@ int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
 	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
 				  &stationlow, 4))
 		return -EIO;
+	((__le32 *)val)[1] = cpu_to_le32(stationhigh);
+	((__le32 *)val)[0] = cpu_to_le32(stationlow);
 
-	result = ((u64) stationlow) >> 16;
-	result |= (u64) stationhigh << 16;
-	memcpy(*addr, &result, sizeof(netxen_ethernet_macaddr_t));
+	memcpy(addr, val + 2, 6);
 
 	return 0;
 }
@@ -880,7 +880,7 @@ int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
 int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
 				       int port, netxen_niu_prom_mode_t mode)
 {
-	__le32 reg;
+	__u32 reg;
 
 	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
 		return -EINVAL;
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index ebb6aa3..8ea2fc1 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1925,6 +1925,8 @@ spider_net_stop(struct net_device *netdev)
 	/* release chains */
 	spider_net_release_tx_chain(card, 1);
 
+	spider_net_free_rx_chain_contents(card);
+
 	spider_net_free_chain(card, &card->tx_chain);
 	spider_net_free_chain(card, &card->rx_chain);
 
