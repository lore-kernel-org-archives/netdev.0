From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 26 Mar 2008 01:31:49 -0400
Message-ID: <20080326053149.GA29466@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56277 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbYCZFbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 01:31:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/b44.c                        |    5 +
 drivers/net/bonding/bond_3ad.c           |    4 +-
 drivers/net/bonding/bond_alb.c           |    6 +-
 drivers/net/bonding/bond_main.c          |    5 +-
 drivers/net/bonding/bonding.h            |    4 +-
 drivers/net/cxgb3/sge.c                  |   18 +-
 drivers/net/dm9000.c                     |   10 +-
 drivers/net/e100.c                       |    2 +-
 drivers/net/ehea/ehea.h                  |    2 +-
 drivers/net/ehea/ehea_main.c             |    2 +-
 drivers/net/igb/e1000_82575.h            |   42 +++---
 drivers/net/igb/e1000_hw.h               |   82 +++++-----
 drivers/net/igb/igb_main.c               |   21 ++-
 drivers/net/ixgb/ixgb_main.c             |    2 -
 drivers/net/netxen/netxen_nic.h          |   27 +---
 drivers/net/netxen/netxen_nic_ethtool.c  |    8 -
 drivers/net/netxen/netxen_nic_hdr.h      |   12 ++
 drivers/net/netxen/netxen_nic_hw.c       |    2 +
 drivers/net/netxen/netxen_nic_init.c     |  201 +++--------------------
 drivers/net/netxen/netxen_nic_isr.c      |   19 +--
 drivers/net/netxen/netxen_nic_main.c     |  265 ++++++++++--------------------
 drivers/net/netxen/netxen_nic_phan_reg.h |    3 +
 drivers/net/phy/marvell.c                |  129 ++++++++++++++-
 drivers/net/s2io.c                       |    3 +
 drivers/net/skge.c                       |    6 +-
 drivers/net/smc91x.h                     |    8 +-
 drivers/net/tokenring/smctr.c            |    2 +-
 drivers/net/usb/dm9601.c                 |    6 +-
 drivers/net/usb/rndis_host.c             |    9 +-
 29 files changed, 390 insertions(+), 515 deletions(-)

Al Viro (3):
      igb: endianness fix
      igb trivial annotations
      e100: endianness annotations

Alexandr Smirnov (1):
      Marvell PHY m88e1111 driver fix

Bryan Wu (1):
      smc91x: fix build breakage from the SMC_GET_MAC_ADDR API upgrade

Dhananjay Phadke (4):
      netxen: improve msi support
      netxen: napi and irq cleanup
      netxen: remove low level tx lock
      netxen: fix rx dropped stats

Jay Schulist (1):
      smctr.c: fix logical-bitwise-or confusion

Jay Vosburgh (3):
      bonding: Fix locking in 802.3ad mode
      bonding: fix two compiler warnings
      bonding: update version

Jeff Garzik (1):
      netxen, phy/marvell, skge: minor checkpatch fixes

Julia Lawall (1):
      ixgb: remove unused variable

Jussi Kivilinna (1):
      rndis_host: fix oops when query for OID_GEN_PHYSICAL_MEDIUM fails

Libor Pechacek (1):
      bonding: Fix sysfs attribute handling

Marin Mitov (1):
      skge napi->poll() locking bug

Michael Buesch (1):
      b44: Truncate PHY address

Peter Korsgaard (3):
      dm9601: add Hirose USB-100 device ID
      dm9601: configure MAC to drop invalid (crc/length) packets
      dm9000: Support promisc and all-multi modes

Roland Dreier (1):
      cxgb3: Fix lockdep problems with sge.reg_lock

Sreenivasa Honnur (1):
      S2io: Handle TX completions on the same CPU as the sender for MIS-X interrupts

Thomas Klein (1):
      ehea: Fix IPv6 support

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index ea2a2b5..25f1337 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2082,6 +2082,11 @@ static int __devinit b44_get_invariants(struct b44 *bp)
 		addr = sdev->bus->sprom.et0mac;
 		bp->phy_addr = sdev->bus->sprom.et0phyaddr;
 	}
+	/* Some ROMs have buggy PHY addresses with the high
+	 * bits set (sign extension?). Truncate them to a
+	 * valid PHY address. */
+	bp->phy_addr &= 0x1F;
+
 	memcpy(bp->dev->dev_addr, addr, 6);
 
 	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cb3c6fa..d16e0e1 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -310,7 +310,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  */
 static inline void __get_rx_machine_lock(struct port *port)
 {
-	spin_lock(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
 }
 
 /**
@@ -320,7 +320,7 @@ static inline void __get_rx_machine_lock(struct port *port)
  */
 static inline void __release_rx_machine_lock(struct port *port)
 {
-	spin_unlock(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
 }
 
 /**
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b57bc94..3f58c3d 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -678,12 +678,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 
 		if (!list_empty(&bond->vlan_list)) {
-			unsigned short vlan_id;
-			int res = vlan_get_tag(skb, &vlan_id);
-			if (!res) {
+			if (!vlan_get_tag(skb, &client_info->vlan_id))
 				client_info->tag = 1;
-				client_info->vlan_id = vlan_id;
-			}
 		}
 
 		if (!client_info->assigned) {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0942d82..0f06753 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -383,7 +383,7 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
  */
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev)
 {
-	unsigned short vlan_id;
+	unsigned short uninitialized_var(vlan_id);
 
 	if (!list_empty(&bond->vlan_list) &&
 	    !(slave_dev->features & NETIF_F_HW_VLAN_TX) &&
@@ -4528,8 +4528,7 @@ static void bond_free_all(void)
 		netif_tx_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
-		unregister_netdevice(bond_dev);
+		bond_destroy(bond);
 	}
 
 #ifdef CONFIG_PROC_FS
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 67ccad6..a3c74e2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.4"
-#define DRV_RELDATE	"January 28, 2008"
+#define DRV_VERSION	"3.2.5"
+#define DRV_RELDATE	"March 21, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index db58687..98a6bbd 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -557,9 +557,9 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 
 	for (i = 0; i < SGE_RXQ_PER_SET; ++i)
 		if (q->fl[i].desc) {
-			spin_lock(&adapter->sge.reg_lock);
+			spin_lock_irq(&adapter->sge.reg_lock);
 			t3_sge_disable_fl(adapter, q->fl[i].cntxt_id);
-			spin_unlock(&adapter->sge.reg_lock);
+			spin_unlock_irq(&adapter->sge.reg_lock);
 			free_rx_bufs(pdev, &q->fl[i]);
 			kfree(q->fl[i].sdesc);
 			dma_free_coherent(&pdev->dev,
@@ -570,9 +570,9 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 
 	for (i = 0; i < SGE_TXQ_PER_SET; ++i)
 		if (q->txq[i].desc) {
-			spin_lock(&adapter->sge.reg_lock);
+			spin_lock_irq(&adapter->sge.reg_lock);
 			t3_sge_enable_ecntxt(adapter, q->txq[i].cntxt_id, 0);
-			spin_unlock(&adapter->sge.reg_lock);
+			spin_unlock_irq(&adapter->sge.reg_lock);
 			if (q->txq[i].sdesc) {
 				free_tx_desc(adapter, &q->txq[i],
 					     q->txq[i].in_use);
@@ -586,9 +586,9 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 		}
 
 	if (q->rspq.desc) {
-		spin_lock(&adapter->sge.reg_lock);
+		spin_lock_irq(&adapter->sge.reg_lock);
 		t3_sge_disable_rspcntxt(adapter, q->rspq.cntxt_id);
-		spin_unlock(&adapter->sge.reg_lock);
+		spin_unlock_irq(&adapter->sge.reg_lock);
 		dma_free_coherent(&pdev->dev,
 				  q->rspq.size * sizeof(struct rsp_desc),
 				  q->rspq.desc, q->rspq.phys_addr);
@@ -2667,7 +2667,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		(16 * 1024) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) :
 		MAX_FRAME_SIZE + 2 + sizeof(struct cpl_rx_pkt);
 
-	spin_lock(&adapter->sge.reg_lock);
+	spin_lock_irq(&adapter->sge.reg_lock);
 
 	/* FL threshold comparison uses < */
 	ret = t3_sge_init_rspcntxt(adapter, q->rspq.cntxt_id, irq_vec_idx,
@@ -2711,7 +2711,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 			goto err_unlock;
 	}
 
-	spin_unlock(&adapter->sge.reg_lock);
+	spin_unlock_irq(&adapter->sge.reg_lock);
 
 	q->adap = adapter;
 	q->netdev = dev;
@@ -2728,7 +2728,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	return 0;
 
       err_unlock:
-	spin_unlock(&adapter->sge.reg_lock);
+	spin_unlock_irq(&adapter->sge.reg_lock);
       err:
 	t3_free_qset(adapter, q);
 	return ret;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 1fe305c..b09a53d 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -798,8 +798,6 @@ dm9000_init_dm9000(struct net_device *dev)
 	/* Set address filter table */
 	dm9000_hash_table(dev);
 
-	/* Activate DM9000 */
-	iow(db, DM9000_RCR, RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN);
 	/* Enable TX/RX interrupt mask */
 	iow(db, DM9000_IMR, IMR_PAR | IMR_PTM | IMR_PRM);
 
@@ -1197,6 +1195,7 @@ dm9000_hash_table(struct net_device *dev)
 	int i, oft;
 	u32 hash_val;
 	u16 hash_table[4];
+	u8 rcr = RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
 	unsigned long flags;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
@@ -1213,6 +1212,12 @@ dm9000_hash_table(struct net_device *dev)
 	/* broadcast address */
 	hash_table[3] = 0x8000;
 
+	if (dev->flags & IFF_PROMISC)
+		rcr |= RCR_PRMSC;
+
+	if (dev->flags & IFF_ALLMULTI)
+		rcr |= RCR_ALL;
+
 	/* the multicast address in Hash Table : 64 bits */
 	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
@@ -1225,6 +1230,7 @@ dm9000_hash_table(struct net_device *dev)
 		iow(db, oft++, hash_table[i] >> 8);
 	}
 
+	iow(db, DM9000_RCR, rcr);
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index cdf3090..2d139ec 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -960,7 +960,7 @@ static void e100_get_defaults(struct nic *nic)
 
 	/* Template for a freshly allocated RFD */
 	nic->blank_rfd.command = 0;
-	nic->blank_rfd.rbd = 0xFFFFFFFF;
+	nic->blank_rfd.rbd = cpu_to_le32(0xFFFFFFFF);
 	nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
 
 	/* MII setup */
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 7c4ead3..93b7fb2 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0087"
+#define DRV_VERSION	"EHEA_0089"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 21af674..07c742d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3108,7 +3108,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->vlan_rx_add_vid = ehea_vlan_rx_add_vid;
 	dev->vlan_rx_kill_vid = ehea_vlan_rx_kill_vid;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
-		      | NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX
+		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_LLTX;
 	dev->tx_timeout = &ehea_tx_watchdog;
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 6604d96..76ea846 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -61,28 +61,28 @@
 /* Receive Descriptor - Advanced */
 union e1000_adv_rx_desc {
 	struct {
-		u64 pkt_addr;             /* Packet buffer address */
-		u64 hdr_addr;             /* Header buffer address */
+		__le64 pkt_addr;             /* Packet buffer address */
+		__le64 hdr_addr;             /* Header buffer address */
 	} read;
 	struct {
 		struct {
 			struct {
-				u16 pkt_info;   /* RSS type, Packet type */
-				u16 hdr_info;   /* Split Header,
-						 * header buffer length */
+				__le16 pkt_info;   /* RSS type, Packet type */
+				__le16 hdr_info;   /* Split Header,
+						    * header buffer length */
 			} lo_dword;
 			union {
-				u32 rss;          /* RSS Hash */
+				__le32 rss;          /* RSS Hash */
 				struct {
-					u16 ip_id;    /* IP id */
-					u16 csum;     /* Packet Checksum */
+					__le16 ip_id;    /* IP id */
+					__le16 csum;     /* Packet Checksum */
 				} csum_ip;
 			} hi_dword;
 		} lower;
 		struct {
-			u32 status_error;     /* ext status/error */
-			u16 length;           /* Packet length */
-			u16 vlan;             /* VLAN tag */
+			__le32 status_error;     /* ext status/error */
+			__le16 length;           /* Packet length */
+			__le16 vlan;             /* VLAN tag */
 		} upper;
 	} wb;  /* writeback */
 };
@@ -97,14 +97,14 @@ union e1000_adv_rx_desc {
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
 	struct {
-		u64 buffer_addr;    /* Address of descriptor's data buf */
-		u32 cmd_type_len;
-		u32 olinfo_status;
+		__le64 buffer_addr;    /* Address of descriptor's data buf */
+		__le32 cmd_type_len;
+		__le32 olinfo_status;
 	} read;
 	struct {
-		u64 rsvd;       /* Reserved */
-		u32 nxtseq_seed;
-		u32 status;
+		__le64 rsvd;       /* Reserved */
+		__le32 nxtseq_seed;
+		__le32 status;
 	} wb;
 };
 
@@ -119,10 +119,10 @@ union e1000_adv_tx_desc {
 
 /* Context descriptors */
 struct e1000_adv_tx_context_desc {
-	u32 vlan_macip_lens;
-	u32 seqnum_seed;
-	u32 type_tucmd_mlhl;
-	u32 mss_l4len_idx;
+	__le32 vlan_macip_lens;
+	__le32 seqnum_seed;
+	__le32 type_tucmd_mlhl;
+	__le32 mss_l4len_idx;
 };
 
 #define E1000_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 161fb68..7b2c70a 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -143,35 +143,35 @@ enum e1000_fc_type {
 
 /* Receive Descriptor */
 struct e1000_rx_desc {
-	u64 buffer_addr; /* Address of the descriptor's data buffer */
-	u16 length;      /* Length of data DMAed into data buffer */
-	u16 csum;        /* Packet checksum */
+	__le64 buffer_addr; /* Address of the descriptor's data buffer */
+	__le16 length;      /* Length of data DMAed into data buffer */
+	__le16 csum;        /* Packet checksum */
 	u8  status;      /* Descriptor status */
 	u8  errors;      /* Descriptor Errors */
-	u16 special;
+	__le16 special;
 };
 
 /* Receive Descriptor - Extended */
 union e1000_rx_desc_extended {
 	struct {
-		u64 buffer_addr;
-		u64 reserved;
+		__le64 buffer_addr;
+		__le64 reserved;
 	} read;
 	struct {
 		struct {
-			u32 mrq;              /* Multiple Rx Queues */
+			__le32 mrq;              /* Multiple Rx Queues */
 			union {
-				u32 rss;            /* RSS Hash */
+				__le32 rss;            /* RSS Hash */
 				struct {
-					u16 ip_id;  /* IP id */
-					u16 csum;   /* Packet Checksum */
+					__le16 ip_id;  /* IP id */
+					__le16 csum;   /* Packet Checksum */
 				} csum_ip;
 			} hi_dword;
 		} lower;
 		struct {
-			u32 status_error;     /* ext status/error */
-			u16 length;
-			u16 vlan;             /* VLAN tag */
+			__le32 status_error;     /* ext status/error */
+			__le16 length;
+			__le16 vlan;             /* VLAN tag */
 		} upper;
 	} wb;  /* writeback */
 };
@@ -181,49 +181,49 @@ union e1000_rx_desc_extended {
 union e1000_rx_desc_packet_split {
 	struct {
 		/* one buffer for protocol header(s), three data buffers */
-		u64 buffer_addr[MAX_PS_BUFFERS];
+		__le64 buffer_addr[MAX_PS_BUFFERS];
 	} read;
 	struct {
 		struct {
-			u32 mrq;              /* Multiple Rx Queues */
+			__le32 mrq;              /* Multiple Rx Queues */
 			union {
-				u32 rss;              /* RSS Hash */
+				__le32 rss;              /* RSS Hash */
 				struct {
-					u16 ip_id;    /* IP id */
-					u16 csum;     /* Packet Checksum */
+					__le16 ip_id;    /* IP id */
+					__le16 csum;     /* Packet Checksum */
 				} csum_ip;
 			} hi_dword;
 		} lower;
 		struct {
-			u32 status_error;     /* ext status/error */
-			u16 length0;          /* length of buffer 0 */
-			u16 vlan;             /* VLAN tag */
+			__le32 status_error;     /* ext status/error */
+			__le16 length0;          /* length of buffer 0 */
+			__le16 vlan;             /* VLAN tag */
 		} middle;
 		struct {
-			u16 header_status;
-			u16 length[3];        /* length of buffers 1-3 */
+			__le16 header_status;
+			__le16 length[3];        /* length of buffers 1-3 */
 		} upper;
-		u64 reserved;
+		__le64 reserved;
 	} wb; /* writeback */
 };
 
 /* Transmit Descriptor */
 struct e1000_tx_desc {
-	u64 buffer_addr;      /* Address of the descriptor's data buffer */
+	__le64 buffer_addr;      /* Address of the descriptor's data buffer */
 	union {
-		u32 data;
+		__le32 data;
 		struct {
-			u16 length;    /* Data buffer length */
+			__le16 length;    /* Data buffer length */
 			u8 cso;        /* Checksum offset */
 			u8 cmd;        /* Descriptor control */
 		} flags;
 	} lower;
 	union {
-		u32 data;
+		__le32 data;
 		struct {
 			u8 status;     /* Descriptor status */
 			u8 css;        /* Checksum start */
-			u16 special;
+			__le16 special;
 		} fields;
 	} upper;
 };
@@ -231,49 +231,49 @@ struct e1000_tx_desc {
 /* Offload Context Descriptor */
 struct e1000_context_desc {
 	union {
-		u32 ip_config;
+		__le32 ip_config;
 		struct {
 			u8 ipcss;      /* IP checksum start */
 			u8 ipcso;      /* IP checksum offset */
-			u16 ipcse;     /* IP checksum end */
+			__le16 ipcse;     /* IP checksum end */
 		} ip_fields;
 	} lower_setup;
 	union {
-		u32 tcp_config;
+		__le32 tcp_config;
 		struct {
 			u8 tucss;      /* TCP checksum start */
 			u8 tucso;      /* TCP checksum offset */
-			u16 tucse;     /* TCP checksum end */
+			__le16 tucse;     /* TCP checksum end */
 		} tcp_fields;
 	} upper_setup;
-	u32 cmd_and_length;
+	__le32 cmd_and_length;
 	union {
-		u32 data;
+		__le32 data;
 		struct {
 			u8 status;     /* Descriptor status */
 			u8 hdr_len;    /* Header length */
-			u16 mss;       /* Maximum segment size */
+			__le16 mss;       /* Maximum segment size */
 		} fields;
 	} tcp_seg_setup;
 };
 
 /* Offload data descriptor */
 struct e1000_data_desc {
-	u64 buffer_addr;   /* Address of the descriptor's buffer address */
+	__le64 buffer_addr;   /* Address of the descriptor's buffer address */
 	union {
-		u32 data;
+		__le32 data;
 		struct {
-			u16 length;    /* Data buffer length */
+			__le16 length;    /* Data buffer length */
 			u8 typ_len_ext;
 			u8 cmd;
 		} flags;
 	} lower;
 	union {
-		u32 data;
+		__le32 data;
 		struct {
 			u8 status;     /* Descriptor status */
 			u8 popts;      /* Packet Options */
-			u16 special;
+			__le16 special;
 		} fields;
 	} upper;
 };
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 928ce82..aaee02e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3254,6 +3254,13 @@ quit_polling:
 
 	return 1;
 }
+
+static inline u32 get_head(struct igb_ring *tx_ring)
+{
+	void *end = (struct e1000_tx_desc *)tx_ring->desc + tx_ring->count;
+	return le32_to_cpu(*(volatile __le32 *)end);
+}
+
 /**
  * igb_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
@@ -3275,9 +3282,7 @@ static bool igb_clean_tx_irq(struct igb_adapter *adapter,
 	unsigned int total_bytes = 0, total_packets = 0;
 
 	rmb();
-	head = *(volatile u32 *)((struct e1000_tx_desc *)tx_ring->desc
-				 + tx_ring->count);
-	head = le32_to_cpu(head);
+	head = get_head(tx_ring);
 	i = tx_ring->next_to_clean;
 	while (1) {
 		while (i != head) {
@@ -3312,9 +3317,7 @@ static bool igb_clean_tx_irq(struct igb_adapter *adapter,
 		}
 		oldhead = head;
 		rmb();
-		head = *(volatile u32 *)((struct e1000_tx_desc *)tx_ring->desc
-					 + tx_ring->count);
-		head = le32_to_cpu(head);
+		head = get_head(tx_ring);
 		if (head == oldhead)
 			goto done_cleaning;
 	}  /* while (1) */
@@ -3388,7 +3391,7 @@ done_cleaning:
  * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
  * @skb: pointer to sk_buff to be indicated to stack
  **/
-static void igb_receive_skb(struct igb_adapter *adapter, u8 status, u16 vlan,
+static void igb_receive_skb(struct igb_adapter *adapter, u8 status, __le16 vlan,
 			    struct sk_buff *skb)
 {
 	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
@@ -3452,8 +3455,8 @@ static bool igb_clean_rx_irq_adv(struct igb_adapter *adapter,
 		 * that case, it fills the header buffer and spills the rest
 		 * into the page.
 		 */
-		hlen = le16_to_cpu((rx_desc->wb.lower.lo_dword.hdr_info &
-		  E1000_RXDADV_HDRBUFLEN_MASK) >> E1000_RXDADV_HDRBUFLEN_SHIFT);
+		hlen = (le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info) &
+		  E1000_RXDADV_HDRBUFLEN_MASK) >> E1000_RXDADV_HDRBUFLEN_SHIFT;
 		if (hlen > adapter->rx_ps_hdr_size)
 			hlen = adapter->rx_ps_hdr_size;
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 269e6f8..6738b4d 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2088,14 +2088,12 @@ ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
 	struct ixgb_buffer *buffer_info;
 	struct sk_buff *skb;
 	unsigned int i;
-	int num_group_tail_writes;
 	long cleancount;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 	cleancount = IXGB_DESC_UNUSED(rx_ring);
 
-	num_group_tail_writes = IXGB_RX_BUFFER_WRITE;
 
 	/* leave three descriptors unused */
 	while(--cleancount > 2) {
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2bc5eaa..7f20a03 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -85,7 +85,7 @@
 	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
 #define RCV_BUFFSIZE	\
 	(sizeof(struct netxen_rx_buffer) * rcv_desc->max_rx_desc_count)
-#define find_diff_among(a,b,range) ((a)<=(b)?((b)-(a)):((b)+(range)-(a)))
+#define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_NETDEV_STATUS		0x1
 #define NETXEN_RCV_PRODUCER_OFFSET	0
@@ -204,7 +204,7 @@ enum {
 			? RCV_DESC_LRO :	\
 			(RCV_DESC_NORMAL)))
 
-#define MAX_CMD_DESCRIPTORS		1024
+#define MAX_CMD_DESCRIPTORS		4096
 #define MAX_RCV_DESCRIPTORS		16384
 #define MAX_CMD_DESCRIPTORS_HOST	(MAX_CMD_DESCRIPTORS / 4)
 #define MAX_RCV_DESCRIPTORS_1G		(MAX_RCV_DESCRIPTORS / 4)
@@ -818,15 +818,8 @@ struct netxen_adapter_stats {
 	u64  badskblen;
 	u64  nocmddescriptor;
 	u64  polled;
-	u64  uphappy;
-	u64  updropped;
-	u64  uplcong;
-	u64  uphcong;
-	u64  upmcong;
-	u64  updunno;
-	u64  skbfreed;
+	u64  rxdropped;
 	u64  txdropped;
-	u64  txnullskb;
 	u64  csummed;
 	u64  no_rcv;
 	u64  rxbytes;
@@ -842,7 +835,6 @@ struct netxen_rcv_desc_ctx {
 	u32 flags;
 	u32 producer;
 	u32 rcv_pending;	/* Num of bufs posted in phantom */
-	u32 rcv_free;		/* Num of bufs in free list */
 	dma_addr_t phys_addr;
 	struct pci_dev *phys_pdev;
 	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
@@ -889,8 +881,6 @@ struct netxen_adapter {
 	int mtu;
 	int portnum;
 
-	spinlock_t tx_lock;
-	spinlock_t lock;
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
 	struct work_struct  tx_timeout_task;
@@ -899,16 +889,12 @@ struct netxen_adapter {
 
 	u32 cmd_producer;
 	__le32 *cmd_consumer;
-
 	u32 last_cmd_consumer;
+
 	u32 max_tx_desc_count;
 	u32 max_rx_desc_count;
 	u32 max_jumbo_rx_desc_count;
 	u32 max_lro_rx_desc_count;
-	/* Num of instances active on cmd buffer ring */
-	u32 proc_cmd_buf_counter;
-
-	u32 num_threads, total_threads;	/*Use to keep track of xmit threads */
 
 	u32 flags;
 	u32 irq;
@@ -942,6 +928,7 @@ struct netxen_adapter {
 	struct pci_dev *ctx_desc_pdev;
 	dma_addr_t ctx_desc_phys_addr;
 	int intr_scheme;
+	int msi_mode;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
 	void (*handle_phy_intr) (struct netxen_adapter *);
@@ -1075,12 +1062,10 @@ void netxen_tso_check(struct netxen_adapter *adapter,
 		      struct cmd_desc_type0 *desc, struct sk_buff *skb);
 int netxen_nic_hw_resources(struct netxen_adapter *adapter);
 void netxen_nic_clear_stats(struct netxen_adapter *adapter);
-int netxen_nic_rx_has_work(struct netxen_adapter *adapter);
-int netxen_nic_tx_has_work(struct netxen_adapter *adapter);
 void netxen_watchdog_task(struct work_struct *work);
 void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
 			    u32 ringid);
-int netxen_process_cmd_ring(unsigned long data);
+int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_nic_set_multi(struct net_device *netdev);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 7a876f4..6e98d83 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -64,15 +64,7 @@ static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
 	{"bad_skb_len", NETXEN_NIC_STAT(stats.badskblen)},
 	{"no_cmd_desc", NETXEN_NIC_STAT(stats.nocmddescriptor)},
 	{"polled", NETXEN_NIC_STAT(stats.polled)},
-	{"uphappy", NETXEN_NIC_STAT(stats.uphappy)},
-	{"updropped", NETXEN_NIC_STAT(stats.updropped)},
-	{"uplcong", NETXEN_NIC_STAT(stats.uplcong)},
-	{"uphcong", NETXEN_NIC_STAT(stats.uphcong)},
-	{"upmcong", NETXEN_NIC_STAT(stats.upmcong)},
-	{"updunno", NETXEN_NIC_STAT(stats.updunno)},
-	{"skb_freed", NETXEN_NIC_STAT(stats.skbfreed)},
 	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
-	{"tx_null_skb", NETXEN_NIC_STAT(stats.txnullskb)},
 	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
 	{"no_rcv", NETXEN_NIC_STAT(stats.no_rcv)},
 	{"rx_bytes", NETXEN_NIC_STAT(stats.rxbytes)},
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index d72f8f8..160f605 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -456,6 +456,12 @@ enum {
 #define ISR_INT_MASK_SLOW	(NETXEN_PCIX_PS_REG(PCIX_INT_MASK))
 #define ISR_INT_TARGET_STATUS	(NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS))
 #define ISR_INT_TARGET_MASK	(NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK))
+#define ISR_INT_TARGET_STATUS_F1   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F1))
+#define ISR_INT_TARGET_MASK_F1     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F1))
+#define ISR_INT_TARGET_STATUS_F2   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F2))
+#define ISR_INT_TARGET_MASK_F2     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F2))
+#define ISR_INT_TARGET_STATUS_F3   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F3))
+#define ISR_INT_TARGET_MASK_F3     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F3))
 
 #define NETXEN_PCI_MAPSIZE	128
 #define NETXEN_PCI_DDR_NET	(0x00000000UL)
@@ -662,6 +668,12 @@ enum {
 
 #define PCIX_TARGET_STATUS	(0x10118)
 #define PCIX_TARGET_MASK	(0x10128)
+#define PCIX_TARGET_STATUS_F1 (0x10160)
+#define PCIX_TARGET_MASK_F1   (0x10170)
+#define PCIX_TARGET_STATUS_F2 (0x10164)
+#define PCIX_TARGET_MASK_F2   (0x10174)
+#define PCIX_TARGET_STATUS_F3 (0x10168)
+#define PCIX_TARGET_MASK_F3   (0x10178)
 
 #define PCIX_MSI_F0		(0x13000)
 #define PCIX_MSI_F1		(0x13004)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 0135570..05748ca 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -398,6 +398,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
 	printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netxen_nic_driver_name,
 			adapter->intr_scheme);
+	adapter->msi_mode = readl(
+		NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_FW));
 	DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
 
 	addr = netxen_alloc(adapter->ahw.pdev,
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 9e38bcb..45fa33e 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -145,6 +145,8 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 	/* Window 1 call */
 	writel(INTR_SCHEME_PERPORT,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_HOST));
+	writel(MSI_MODE_MULTIFUNC,
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_HOST));
 	writel(MPORT_MULTI_FUNCTION_MODE,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
 	writel(PHAN_INITIALIZE_ACK,
@@ -183,7 +185,6 @@ void netxen_initialize_adapter_sw(struct netxen_adapter *adapter)
 		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
 			struct netxen_rx_buffer *rx_buf;
 			rcv_desc = &adapter->recv_ctx[ctxid].rcv_desc[ring];
-			rcv_desc->rcv_free = rcv_desc->max_rx_desc_count;
 			rcv_desc->begin_alloc = 0;
 			rx_buf = rcv_desc->rx_buf_arr;
 			num_rx_bufs = rcv_desc->max_rx_desc_count;
@@ -974,28 +975,6 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 	return 0;
 }
 
-int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
-{
-	int ctx;
-
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		struct netxen_recv_context *recv_ctx =
-		    &(adapter->recv_ctx[ctx]);
-		u32 consumer;
-		struct status_desc *desc_head;
-		struct status_desc *desc;
-
-		consumer = recv_ctx->status_rx_consumer;
-		desc_head = recv_ctx->rcv_status_desc_head;
-		desc = &desc_head[consumer];
-
-		if (netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)
-			return 1;
-	}
-
-	return 0;
-}
-
 static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1038,7 +1017,6 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 
 void netxen_watchdog_task(struct work_struct *work)
 {
-	struct net_device *netdev;
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, watchdog_task);
 
@@ -1048,20 +1026,6 @@ void netxen_watchdog_task(struct work_struct *work)
 	if (adapter->handle_phy_intr)
 		adapter->handle_phy_intr(adapter);
 
-	netdev = adapter->netdev;
-	if ((netif_running(netdev)) && !netif_carrier_ok(netdev) &&
-			netxen_nic_link_ok(adapter) ) {
-		printk(KERN_INFO "%s %s (port %d), Link is up\n",
-			       netxen_nic_driver_name, netdev->name, adapter->portnum);
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
-	} else if(!(netif_running(netdev)) && netif_carrier_ok(netdev)) {
-		printk(KERN_ERR "%s %s Link is Down\n",
-				netxen_nic_driver_name, netdev->name);
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
-	}
-
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
@@ -1125,7 +1089,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	skb = (struct sk_buff *)buffer->skb;
 
 	if (likely(adapter->rx_csum &&
-				netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
+			netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
@@ -1142,40 +1106,8 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	ret = netif_receive_skb(skb);
-
-	/*
-	 * RH: Do we need these stats on a regular basis. Can we get it from
-	 * Linux stats.
-	 */
-	switch (ret) {
-	case NET_RX_SUCCESS:
-		adapter->stats.uphappy++;
-		break;
-
-	case NET_RX_CN_LOW:
-		adapter->stats.uplcong++;
-		break;
-
-	case NET_RX_CN_MOD:
-		adapter->stats.upmcong++;
-		break;
-
-	case NET_RX_CN_HIGH:
-		adapter->stats.uphcong++;
-		break;
-
-	case NET_RX_DROP:
-		adapter->stats.updropped++;
-		break;
-
-	default:
-		adapter->stats.updunno++;
-		break;
-	}
-
 	netdev->last_rx = jiffies;
 
-	rcv_desc->rcv_free++;
 	rcv_desc->rcv_pending--;
 
 	/*
@@ -1200,13 +1132,6 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 	u32 producer = 0;
 	int count = 0, ring;
 
-	DPRINTK(INFO, "procesing receive\n");
-	/*
-	 * we assume in this case that there is only one port and that is
-	 * port #1...changes need to be done in firmware to indicate port
-	 * number as part of the descriptor. This way we will be able to get
-	 * the netdev which is associated with that device.
-	 */
 	while (count < max) {
 		desc = &desc_head[consumer];
 		if (!(netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)) {
@@ -1219,11 +1144,8 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
-	if (count) {
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
-		}
-	}
+	for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
+		netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
 
 	/* update the consumer index in phantom */
 	if (count) {
@@ -1233,108 +1155,60 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		/* Window = 1 */
 		writel(consumer,
 		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[adapter->portnum].
+				    recv_crb_registers[adapter->portnum].
 					    crb_rcv_status_consumer));
-		wmb();
 	}
 
 	return count;
 }
 
 /* Process Command status ring */
-int netxen_process_cmd_ring(unsigned long data)
+int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 {
-	u32 last_consumer;
-	u32 consumer;
-	struct netxen_adapter *adapter = (struct netxen_adapter *)data;
-	int count1 = 0;
-	int count2 = 0;
+	u32 last_consumer, consumer;
+	int count = 0, i;
 	struct netxen_cmd_buffer *buffer;
-	struct pci_dev *pdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *netdev = adapter->netdev;
 	struct netxen_skb_frag *frag;
-	u32 i;
-	int done;
+	int done = 0;
 
-	spin_lock(&adapter->tx_lock);
 	last_consumer = adapter->last_cmd_consumer;
-	DPRINTK(INFO, "procesing xmit complete\n");
-	/* we assume in this case that there is only one port and that is
-	 * port #1...changes need to be done in firmware to indicate port
-	 * number as part of the descriptor. This way we will be able to get
-	 * the netdev which is associated with that device.
-	 */
-
 	consumer = le32_to_cpu(*(adapter->cmd_consumer));
-	if (last_consumer == consumer) {	/* Ring is empty    */
-		DPRINTK(INFO, "last_consumer %d == consumer %d\n",
-			last_consumer, consumer);
-		spin_unlock(&adapter->tx_lock);
-		return 1;
-	}
-
-	adapter->proc_cmd_buf_counter++;
-	/*
-	 * Not needed - does not seem to be used anywhere.
-	 * adapter->cmd_consumer = consumer;
-	 */
-	spin_unlock(&adapter->tx_lock);
 
-	while ((last_consumer != consumer) && (count1 < MAX_STATUS_HANDLE)) {
+	while (last_consumer != consumer) {
 		buffer = &adapter->cmd_buf_arr[last_consumer];
-		pdev = adapter->pdev;
 		if (buffer->skb) {
 			frag = &buffer->frag_array[0];
 			pci_unmap_single(pdev, frag->dma, frag->length,
 					 PCI_DMA_TODEVICE);
 			frag->dma = 0ULL;
 			for (i = 1; i < buffer->frag_count; i++) {
-				DPRINTK(INFO, "getting fragment no %d\n", i);
 				frag++;	/* Get the next frag */
 				pci_unmap_page(pdev, frag->dma, frag->length,
 					       PCI_DMA_TODEVICE);
 				frag->dma = 0ULL;
 			}
 
-			adapter->stats.skbfreed++;
+			adapter->stats.xmitfinished++;
 			dev_kfree_skb_any(buffer->skb);
 			buffer->skb = NULL;
-		} else if (adapter->proc_cmd_buf_counter == 1) {
-			adapter->stats.txnullskb++;
-		}
-		if (unlikely(netif_queue_stopped(adapter->netdev)
-			     && netif_carrier_ok(adapter->netdev))
-		    && ((jiffies - adapter->netdev->trans_start) >
-			adapter->netdev->watchdog_timeo)) {
-			SCHEDULE_WORK(&adapter->tx_timeout_task);
 		}
 
 		last_consumer = get_next_index(last_consumer,
 					       adapter->max_tx_desc_count);
-		count1++;
+		if (++count >= MAX_STATUS_HANDLE)
+			break;
 	}
 
-	count2 = 0;
-	spin_lock(&adapter->tx_lock);
-	if ((--adapter->proc_cmd_buf_counter) == 0) {
+	if (count) {
 		adapter->last_cmd_consumer = last_consumer;
-		while ((adapter->last_cmd_consumer != consumer)
-		       && (count2 < MAX_STATUS_HANDLE)) {
-			buffer =
-			    &adapter->cmd_buf_arr[adapter->last_cmd_consumer];
-			count2++;
-			if (buffer->skb)
-				break;
-			else
-				adapter->last_cmd_consumer =
-				    get_next_index(adapter->last_cmd_consumer,
-						   adapter->max_tx_desc_count);
-		}
-	}
-	if (count1 || count2) {
-		if (netif_queue_stopped(adapter->netdev)
-		    && (adapter->flags & NETXEN_NETDEV_STATUS)) {
-			netif_wake_queue(adapter->netdev);
-			adapter->flags &= ~NETXEN_NETDEV_STATUS;
+		smp_mb();
+		if (netif_queue_stopped(netdev) && netif_running(netdev)) {
+			netif_tx_lock(netdev);
+			netif_wake_queue(netdev);
+			smp_mb();
+			netif_tx_unlock(netdev);
 		}
 	}
 	/*
@@ -1350,16 +1224,9 @@ int netxen_process_cmd_ring(unsigned long data)
 	 * There is still a possible race condition and the host could miss an
 	 * interrupt. The card has to take care of this.
 	 */
-	if (adapter->last_cmd_consumer == consumer &&
-	    (((adapter->cmd_producer + 1) %
-	      adapter->max_tx_desc_count) == adapter->last_cmd_consumer)) {
-		consumer = le32_to_cpu(*(adapter->cmd_consumer));
-	}
-	done = (adapter->last_cmd_consumer == consumer);
+	consumer = le32_to_cpu(*(adapter->cmd_consumer));
+	done = (last_consumer == consumer);
 
-	spin_unlock(&adapter->tx_lock);
-	DPRINTK(INFO, "last consumer is %d in %s\n", last_consumer,
-		__FUNCTION__);
 	return (done);
 }
 
@@ -1433,8 +1300,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
 		rcv_desc->producer = producer;
-		if (rcv_desc->rcv_free >= 32) {
-			rcv_desc->rcv_free = 0;
 			/* Window = 1 */
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
@@ -1458,8 +1323,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
-			wmb();
-		}
 	}
 }
 
@@ -1523,8 +1386,6 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 		rcv_desc->begin_alloc = index;
 		rcv_desc->rcv_pending += count;
 		rcv_desc->producer = producer;
-		if (rcv_desc->rcv_free >= 32) {
-			rcv_desc->rcv_free = 0;
 			/* Window = 1 */
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
@@ -1534,21 +1395,9 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 						    rcv_desc_crb[ringid].
 						    crb_rcv_producer_offset));
 			wmb();
-		}
 	}
 }
 
-int netxen_nic_tx_has_work(struct netxen_adapter *adapter)
-{
-	if (find_diff_among(adapter->last_cmd_consumer,
-			    adapter->cmd_producer,
-			    adapter->max_tx_desc_count) > 0)
-		return 1;
-
-	return 0;
-}
-
-
 void netxen_nic_clear_stats(struct netxen_adapter *adapter)
 {
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 48a404a..c81313b 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -59,7 +59,7 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 	/* packet transmit problems */
 	stats->tx_errors = adapter->stats.nocmddescriptor;
 	/* no space in linux buffers    */
-	stats->rx_dropped = adapter->stats.updropped;
+	stats->rx_dropped = adapter->stats.rxdropped;
 	/* no space available in linux  */
 	stats->tx_dropped = adapter->stats.txdropped;
 
@@ -193,14 +193,14 @@ int netxen_nic_link_ok(struct netxen_adapter *adapter)
 void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 val, val1;
+	u32 val;
 
 	/* WINDOW = 1 */
 	val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
 	val >>= (physical_port[adapter->portnum] * 8);
-	val1 = val & 0xff;
+	val &= 0xff;
 
-	if (adapter->ahw.xg_linkup == 1 && val1 != XG_LINK_UP) {
+	if (adapter->ahw.xg_linkup == 1 && val != XG_LINK_UP) {
 		printk(KERN_INFO "%s: %s NIC Link is down\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 0;
@@ -208,16 +208,7 @@ void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
-		/* read twice to clear sticky bits */
-		/* WINDOW = 0 */
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
-		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
-
-		if ((val & 0xffb) != 0xffb) {
-			printk(KERN_INFO "%s ISR: Sync/Align BAD: 0x%08x\n",
-			       netxen_nic_driver_name, val1);
-		}
-	} else if (adapter->ahw.xg_linkup == 0 && val1 == XG_LINK_UP) {
+	} else if (adapter->ahw.xg_linkup == 0 && val == XG_LINK_UP) {
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 1;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9737eae..a8fb439 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -63,12 +63,12 @@ static int netxen_nic_xmit_frame(struct sk_buff *, struct net_device *);
 static void netxen_tx_timeout(struct net_device *netdev);
 static void netxen_tx_timeout_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
-static int netxen_handle_int(struct netxen_adapter *, struct net_device *);
 static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev);
 #endif
 static irqreturn_t netxen_intr(int irq, void *data);
+static irqreturn_t netxen_msi_intr(int irq, void *data);
 
 int physical_port[] = {0, 1, 2, 3};
 
@@ -149,33 +149,30 @@ static void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
 
 #define	ADAPTER_LIST_SIZE 12
 
+static uint32_t msi_tgt_status[4] = {
+	ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
+	ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3
+};
+
+static uint32_t sw_int_mask[4] = {
+	CRB_SW_INT_MASK_0, CRB_SW_INT_MASK_1,
+	CRB_SW_INT_MASK_2, CRB_SW_INT_MASK_3
+};
+
 static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
-	uint32_t	mask = 0x7ff;
+	u32 mask = 0x7ff;
 	int retries = 32;
+	int port = adapter->portnum;
+	int pci_fn = adapter->ahw.pci_func;
 
-	DPRINTK(1, INFO, "Entered ISR Disable \n");
-
-	switch (adapter->portnum) {
-	case 0:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
-		break;
-	case 1:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
-		break;
-	case 2:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
-		break;
-	case 3:
-		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
-		break;
-	}
+	if (adapter->msi_mode != MSI_MODE_MULTIFUNC)
+		writel(0x0, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
 
 	if (adapter->intr_scheme != -1 &&
 	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
 		writel(mask,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
 
-	/* Window = 0 or 1 */
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		do {
 			writel(0xffffffff,
@@ -190,14 +187,18 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 			printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
 					netxen_nic_driver_name);
 		}
+	} else {
+		if (adapter->msi_mode == MSI_MODE_MULTIFUNC) {
+			writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
+						msi_tgt_status[pci_fn]));
+		}
 	}
-
-	DPRINTK(1, INFO, "Done with Disable Int\n");
 }
 
 static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
 	u32 mask;
+	int port = adapter->portnum;
 
 	DPRINTK(1, INFO, "Entered ISR Enable \n");
 
@@ -218,20 +219,7 @@ static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
 	}
 
-	switch (adapter->portnum) {
-	case 0:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
-		break;
-	case 1:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
-		break;
-	case 2:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
-		break;
-	case 3:
-		writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
-		break;
-	}
+	writel(0x1, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
@@ -328,7 +316,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter->ahw.pdev = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
-	spin_lock_init(&adapter->tx_lock);
 
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
@@ -401,6 +388,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* this will be read from FW later */
 	adapter->intr_scheme = -1;
+	adapter->msi_mode = -1;
 
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
@@ -415,7 +403,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->set_mac_address    = netxen_nic_set_mac;
 	netdev->change_mtu	   = netxen_nic_change_mtu;
 	netdev->tx_timeout	   = netxen_tx_timeout;
-	netdev->watchdog_timeo     = HZ;
+	netdev->watchdog_timeo     = 2*HZ;
 
 	netxen_nic_change_mtu(netdev, netdev->mtu);
 
@@ -543,7 +531,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
 	adapter->ahw.pdev = pdev;
-	adapter->proc_cmd_buf_counter = 0;
 	adapter->ahw.revision_id = pdev->revision;
 
 	/* make sure Window == 1 */
@@ -833,6 +820,8 @@ static int netxen_nic_open(struct net_device *netdev)
 	struct netxen_adapter *adapter = (struct netxen_adapter *)netdev->priv;
 	int err = 0;
 	int ctx, ring;
+	irq_handler_t handler;
+	unsigned long flags = IRQF_SAMPLE_RANDOM;
 
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
 		err = netxen_init_firmware(adapter);
@@ -856,9 +845,14 @@ static int netxen_nic_open(struct net_device *netdev)
 				netxen_post_rx_buffers(adapter, ctx, ring);
 		}
 		adapter->irq = adapter->ahw.pdev->irq;
-		err = request_irq(adapter->ahw.pdev->irq, netxen_intr,
-				  IRQF_SHARED|IRQF_SAMPLE_RANDOM, netdev->name,
-				  adapter);
+		if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
+			handler = netxen_msi_intr;
+		else {
+			flags |= IRQF_SHARED;
+			handler = netxen_intr;
+		}
+		err = request_irq(adapter->irq, handler,
+				  flags, netdev->name, adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
 			netxen_free_hw_resources(adapter);
@@ -867,21 +861,12 @@ static int netxen_nic_open(struct net_device *netdev)
 
 		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	}
-	if (!adapter->driver_mismatch)
-		mod_timer(&adapter->watchdog_timer, jiffies);
-
-	napi_enable(&adapter->napi);
-
-	netxen_nic_enable_int(adapter);
-
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
 	if (adapter->init_port
 	    && adapter->init_port(adapter, adapter->portnum) != 0) {
-	    del_timer_sync(&adapter->watchdog_timer);
 		printk(KERN_ERR "%s: Failed to initialize port %d\n",
 				netxen_nic_driver_name, adapter->portnum);
-		napi_disable(&adapter->napi);
 		return -EIO;
 	}
 	if (adapter->macaddr_set)
@@ -894,6 +879,12 @@ static int netxen_nic_open(struct net_device *netdev)
 		adapter->set_mtu(adapter, netdev->mtu);
 
 	if (!adapter->driver_mismatch)
+		mod_timer(&adapter->watchdog_timer, jiffies);
+
+	napi_enable(&adapter->napi);
+	netxen_nic_enable_int(adapter);
+
+	if (!adapter->driver_mismatch)
 		netif_start_queue(netdev);
 
 	return 0;
@@ -958,41 +949,17 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct netxen_skb_frag *buffrag;
 	unsigned int i;
 
-	u32 producer = 0;
+	u32 producer, consumer;
 	u32 saved_producer = 0;
 	struct cmd_desc_type0 *hwdesc;
 	int k;
 	struct netxen_cmd_buffer *pbuf = NULL;
-	static int dropped_packet = 0;
 	int frag_count;
-	u32 local_producer = 0;
-	u32 max_tx_desc_count = 0;
-	u32 last_cmd_consumer = 0;
 	int no_of_desc;
+	u32 num_txd = adapter->max_tx_desc_count;
 
-	adapter->stats.xmitcalled++;
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
-	if (unlikely(skb->len <= 0)) {
-		dev_kfree_skb_any(skb);
-		adapter->stats.badskblen++;
-		return NETDEV_TX_OK;
-	}
-
-	if (frag_count > MAX_BUFFERS_PER_CMD) {
-		printk("%s: %s netxen_nic_xmit_frame: frag_count (%d) "
-		       "too large, can handle only %d frags\n",
-		       netxen_nic_driver_name, netdev->name,
-		       frag_count, MAX_BUFFERS_PER_CMD);
-		adapter->stats.txdropped++;
-		if ((++dropped_packet & 0xff) == 0xff)
-			printk("%s: %s droppped packets = %d\n",
-			       netxen_nic_driver_name, netdev->name,
-			       dropped_packet);
-
-		return NETDEV_TX_OK;
-	}
-
 	/* There 4 fragments per descriptor */
 	no_of_desc = (frag_count + 3) >> 2;
 	if (netdev->features & NETIF_F_TSO) {
@@ -1007,27 +974,16 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	spin_lock_bh(&adapter->tx_lock);
-	if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
-		goto out_requeue;
-	}
-	local_producer = adapter->cmd_producer;
-	k = adapter->cmd_producer;
-	max_tx_desc_count = adapter->max_tx_desc_count;
-	last_cmd_consumer = adapter->last_cmd_consumer;
-	if ((k + no_of_desc) >=
-	    ((last_cmd_consumer <= k) ? last_cmd_consumer + max_tx_desc_count :
-	     last_cmd_consumer)) {
-		goto out_requeue;
+	producer = adapter->cmd_producer;
+	smp_mb();
+	consumer = adapter->last_cmd_consumer;
+	if ((no_of_desc+2) > find_diff_among(producer, consumer, num_txd)) {
+		netif_stop_queue(netdev);
+		smp_mb();
+		return NETDEV_TX_BUSY;
 	}
-	k = get_index_range(k, max_tx_desc_count, no_of_desc);
-	adapter->cmd_producer = k;
-	adapter->total_threads++;
-	adapter->num_threads++;
 
-	spin_unlock_bh(&adapter->tx_lock);
 	/* Copy the descriptors into the hardware    */
-	producer = local_producer;
 	saved_producer = producer;
 	hwdesc = &hw->cmd_desc_head[producer];
 	memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
@@ -1067,8 +1023,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* move to next desc. if there is a need */
 		if ((i & 0x3) == 0) {
 			k = 0;
-			producer = get_next_index(producer,
-						  adapter->max_tx_desc_count);
+			producer = get_next_index(producer, num_txd);
 			hwdesc = &hw->cmd_desc_head[producer];
 			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
 			pbuf = &adapter->cmd_buf_arr[producer];
@@ -1086,7 +1041,6 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		buffrag->dma = temp_dma;
 		buffrag->length = temp_len;
 
-		DPRINTK(INFO, "for loop. i=%d k=%d\n", i, k);
 		switch (k) {
 		case 0:
 			hwdesc->buffer1_length = cpu_to_le16(temp_len);
@@ -1107,7 +1061,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 		frag++;
 	}
-	producer = get_next_index(producer, adapter->max_tx_desc_count);
+	producer = get_next_index(producer, num_txd);
 
 	/* might change opcode to TX_TCP_LSO */
 	netxen_tso_check(adapter, &hw->cmd_desc_head[saved_producer], skb);
@@ -1134,7 +1088,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* copy the first 64 bytes */
 		memcpy(((void *)hwdesc) + 2,
 		       (void *)(skb->data), first_hdr_len);
-		producer = get_next_index(producer, max_tx_desc_count);
+		producer = get_next_index(producer, num_txd);
 
 		if (more_hdr) {
 			hwdesc = &hw->cmd_desc_head[producer];
@@ -1147,35 +1101,19 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 							 hwdesc,
 							 (hdr_len -
 							  first_hdr_len));
-			producer = get_next_index(producer, max_tx_desc_count);
+			producer = get_next_index(producer, num_txd);
 		}
 	}
 
-	spin_lock_bh(&adapter->tx_lock);
+	adapter->cmd_producer = producer;
 	adapter->stats.txbytes += skb->len;
 
-	/* Code to update the adapter considering how many producer threads
-	   are currently working */
-	if ((--adapter->num_threads) == 0) {
-		/* This is the last thread */
-		u32 crb_producer = adapter->cmd_producer;
-		netxen_nic_update_cmd_producer(adapter, crb_producer);
-		wmb();
-		adapter->total_threads = 0;
-	}
+	netxen_nic_update_cmd_producer(adapter, adapter->cmd_producer);
 
-	adapter->stats.xmitfinished++;
+	adapter->stats.xmitcalled++;
 	netdev->trans_start = jiffies;
 
-	spin_unlock_bh(&adapter->tx_lock);
 	return NETDEV_TX_OK;
-
-out_requeue:
-	netif_stop_queue(netdev);
-	adapter->flags |= NETXEN_NETDEV_STATUS;
-
-	spin_unlock_bh(&adapter->tx_lock);
-	return NETDEV_TX_BUSY;
 }
 
 static void netxen_watchdog(unsigned long v)
@@ -1200,87 +1138,60 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, adapter->netdev->name);
 
-	netxen_nic_close(adapter->netdev);
-	netxen_nic_open(adapter->netdev);
+	netxen_nic_disable_int(adapter);
+	napi_disable(&adapter->napi);
+
 	adapter->netdev->trans_start = jiffies;
+
+	napi_enable(&adapter->napi);
+	netxen_nic_enable_int(adapter);
 	netif_wake_queue(adapter->netdev);
 }
 
-static int
-netxen_handle_int(struct netxen_adapter *adapter, struct net_device *netdev)
+static inline void
+netxen_handle_int(struct netxen_adapter *adapter)
 {
-	u32 ret = 0;
-
-	DPRINTK(INFO, "Entered handle ISR\n");
-	adapter->stats.ints++;
-
 	netxen_nic_disable_int(adapter);
-
-	if (netxen_nic_rx_has_work(adapter) || netxen_nic_tx_has_work(adapter)) {
-		if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
-			/*
-			 * Interrupts are already disabled.
-			 */
-			__netif_rx_schedule(netdev, &adapter->napi);
-		} else {
-			static unsigned int intcount = 0;
-			if ((++intcount & 0xfff) == 0xfff)
-				DPRINTK(KERN_ERR
-				       "%s: %s interrupt %d while in poll\n",
-				       netxen_nic_driver_name, netdev->name,
-				       intcount);
-		}
-		ret = 1;
-	}
-
-	if (ret == 0) {
-		netxen_nic_enable_int(adapter);
-	}
-
-	return ret;
+	napi_schedule(&adapter->napi);
 }
 
-/*
- * netxen_intr - Interrupt Handler
- * @irq: interrupt number
- * data points to adapter stucture (which may be handling more than 1 port
- */
 irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
-	struct net_device *netdev = adapter->netdev;
 	u32 our_int = 0;
 
-	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-		our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		/* not our interrupt */
-		if ((our_int & (0x80 << adapter->portnum)) == 0)
-			return IRQ_NONE;
-	}
+	our_int = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
+	/* not our interrupt */
+	if ((our_int & (0x80 << adapter->portnum)) == 0)
+		return IRQ_NONE;
 
 	if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
 		/* claim interrupt */
-		if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
-			writel(our_int & ~((u32)(0x80 << adapter->portnum)),
+		writel(our_int & ~((u32)(0x80 << adapter->portnum)),
 			NETXEN_CRB_NORMALIZE(adapter, CRB_INT_VECTOR));
-		}
 	}
 
-	if (netif_running(netdev))
-		netxen_handle_int(adapter, netdev);
+	netxen_handle_int(adapter);
 
 	return IRQ_HANDLED;
 }
 
+irqreturn_t netxen_msi_intr(int irq, void *data)
+{
+	struct netxen_adapter *adapter = data;
+
+	netxen_handle_int(adapter);
+	return IRQ_HANDLED;
+}
+
 static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
 	struct netxen_adapter *adapter = container_of(napi, struct netxen_adapter, napi);
-	struct net_device *netdev = adapter->netdev;
-	int done = 1;
+	int tx_complete;
 	int ctx;
 	int work_done;
 
-	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
+	tx_complete = netxen_process_cmd_ring(adapter);
 
 	work_done = 0;
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
@@ -1300,16 +1211,8 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 						     budget / MAX_RCV_CTX);
 	}
 
-	if (work_done >= budget)
-		done = 0;
-
-	if (netxen_process_cmd_ring((unsigned long)adapter) == 0)
-		done = 0;
-
-	DPRINTK(INFO, "new work_done: %d work_to_do: %d\n",
-		work_done, work_to_do);
-	if (done) {
-		netif_rx_complete(netdev, napi);
+	if ((work_done < budget) && tx_complete) {
+		netif_rx_complete(adapter->netdev, &adapter->napi);
 		netxen_nic_enable_int(adapter);
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index ffa3b72..a566b50 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -126,8 +126,11 @@
  */
 #define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
 #define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
+#define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
+#define CRB_NIC_MSI_MODE_FW	  		NETXEN_NIC_REG(0x274)
 
 #define INTR_SCHEME_PERPORT	      	0x1
+#define MSI_MODE_MULTIFUNC	      	0x1
 
 /* used for ethtool tests */
 #define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index f057407..3353991 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -58,9 +58,25 @@
 #define MII_M1111_RX_DELAY		0x80
 #define MII_M1111_TX_DELAY		0x2
 #define MII_M1111_PHY_EXT_SR		0x1b
-#define MII_M1111_HWCFG_MODE_MASK	0xf
-#define MII_M1111_HWCFG_MODE_RGMII	0xb
+
+#define MII_M1111_HWCFG_MODE_MASK		0xf
+#define MII_M1111_HWCFG_MODE_COPPER_RGMII	0xb
+#define MII_M1111_HWCFG_MODE_FIBER_RGMII	0x3
 #define MII_M1111_HWCFG_MODE_SGMII_NO_CLK	0x4
+#define MII_M1111_HWCFG_FIBER_COPPER_AUTO	0x8000
+#define MII_M1111_HWCFG_FIBER_COPPER_RES	0x2000
+
+#define MII_M1111_COPPER		0
+#define MII_M1111_FIBER			1
+
+#define MII_M1011_PHY_STATUS		0x11
+#define MII_M1011_PHY_STATUS_1000	0x8000
+#define MII_M1011_PHY_STATUS_100	0x4000
+#define MII_M1011_PHY_STATUS_SPD_MASK	0xc000
+#define MII_M1011_PHY_STATUS_FULLDUPLEX	0x2000
+#define MII_M1011_PHY_STATUS_RESOLVED	0x0800
+#define MII_M1011_PHY_STATUS_LINK	0x0400
+
 
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -141,12 +157,22 @@ static int marvell_config_aneg(struct phy_device *phydev)
 static int m88e1111_config_init(struct phy_device *phydev)
 {
 	int err;
+	int temp;
+	int mode;
+
+	/* Enable Fiber/Copper auto selection */
+	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
+	temp |= MII_M1111_HWCFG_FIBER_COPPER_AUTO;
+	phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
+
+	temp = phy_read(phydev, MII_BMCR);
+	temp |= BMCR_RESET;
+	phy_write(phydev, MII_BMCR, temp);
 
 	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
 	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
-		int temp;
 
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
 		if (temp < 0)
@@ -171,7 +197,13 @@ static int m88e1111_config_init(struct phy_device *phydev)
 			return temp;
 
 		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
-		temp |= MII_M1111_HWCFG_MODE_RGMII;
+
+		mode = phy_read(phydev, MII_M1111_PHY_EXT_CR);
+
+		if (mode & MII_M1111_HWCFG_FIBER_COPPER_RES)
+			temp |= MII_M1111_HWCFG_MODE_FIBER_RGMII;
+		else
+			temp |= MII_M1111_HWCFG_MODE_COPPER_RGMII;
 
 		err = phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
 		if (err < 0)
@@ -262,6 +294,93 @@ static int m88e1145_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+/* marvell_read_status
+ *
+ * Generic status code does not detect Fiber correctly!
+ * Description:
+ *   Check the link, then figure out the current state
+ *   by comparing what we advertise with what the link partner
+ *   advertises.  Start by checking the gigabit possibilities,
+ *   then move on to 10/100.
+ */
+static int marvell_read_status(struct phy_device *phydev)
+{
+	int adv;
+	int err;
+	int lpa;
+	int status = 0;
+
+	/* Update the link, but return if there
+	 * was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		status = phy_read(phydev, MII_M1011_PHY_STATUS);
+		if (status < 0)
+			return status;
+
+		lpa = phy_read(phydev, MII_LPA);
+		if (lpa < 0)
+			return lpa;
+
+		adv = phy_read(phydev, MII_ADVERTISE);
+		if (adv < 0)
+			return adv;
+
+		lpa &= adv;
+
+		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		status = status & MII_M1011_PHY_STATUS_SPD_MASK;
+		phydev->pause = phydev->asym_pause = 0;
+
+		switch (status) {
+		case MII_M1011_PHY_STATUS_1000:
+			phydev->speed = SPEED_1000;
+			break;
+
+		case MII_M1011_PHY_STATUS_100:
+			phydev->speed = SPEED_100;
+			break;
+
+		default:
+			phydev->speed = SPEED_10;
+			break;
+		}
+
+		if (phydev->duplex == DUPLEX_FULL) {
+			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
+			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
+		}
+	} else {
+		int bmcr = phy_read(phydev, MII_BMCR);
+
+		if (bmcr < 0)
+			return bmcr;
+
+		if (bmcr & BMCR_FULLDPLX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if (bmcr & BMCR_SPEED1000)
+			phydev->speed = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+
+		phydev->pause = phydev->asym_pause = 0;
+	}
+
+	return 0;
+}
+
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = 0x01410c60,
@@ -296,7 +415,7 @@ static struct phy_driver marvell_drivers[] = {
 		.flags = PHY_HAS_INTERRUPT,
 		.config_init = &m88e1111_config_init,
 		.config_aneg = &marvell_config_aneg,
-		.read_status = &genphy_read_status,
+		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index c72787a..3c915b8 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4172,6 +4172,9 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
+	if (sp->config.intr_type == MSI_X)
+		tx_intr_handler(fifo);
+
 	return 0;
 pci_map_failed:
 	stats->pci_map_fail_cnt++;
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 186eb8e..2e26dce 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3199,12 +3199,14 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR), CSR_START);
 
 	if (work_done < to_do) {
-		spin_lock_irq(&hw->hw_lock);
+		unsigned long flags;
+
+		spin_lock_irqsave(&hw->hw_lock, flags);
 		__netif_rx_complete(dev, napi);
 		hw->intr_mask |= napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
-		spin_unlock_irq(&hw->hw_lock);
+		spin_unlock_irqrestore(&hw->hw_lock, flags);
 	}
 
 	return work_done;
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 51d4134..98a832a 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -92,14 +92,14 @@
 #define SMC_insw(a, r, p, l) 	insw ((unsigned long *)((a) + (r)), p, l)
 # endif
 /* check if the mac in reg is valid */
-#define SMC_GET_MAC_ADDR(addr)					\
+#define SMC_GET_MAC_ADDR(lp, addr)				\
 	do {							\
 		unsigned int __v;				\
-		__v = SMC_inw(ioaddr, ADDR0_REG);		\
+		__v = SMC_inw(ioaddr, ADDR0_REG(lp));		\
 		addr[0] = __v; addr[1] = __v >> 8;		\
-		__v = SMC_inw(ioaddr, ADDR1_REG);		\
+		__v = SMC_inw(ioaddr, ADDR1_REG(lp));		\
 		addr[2] = __v; addr[3] = __v >> 8;		\
-		__v = SMC_inw(ioaddr, ADDR2_REG);		\
+		__v = SMC_inw(ioaddr, ADDR2_REG(lp));		\
 		addr[4] = __v; addr[5] = __v >> 8;		\
 		if (*(u32 *)(&addr[0]) == 0xFFFFFFFF) {		\
 			random_ether_addr(addr);		\
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 8909050..5f1c507 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3413,7 +3413,7 @@ static int smctr_make_tx_status_code(struct net_device *dev,
         tsv->svi = TRANSMIT_STATUS_CODE;
         tsv->svl = S_TRANSMIT_STATUS_CODE;
 
-        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);
+	tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) | IBM_PASS_SOURCE_ADDR);
 
         /* Stripped frame status of Transmitted Frame */
         tsv->svv[1] = tx_fstatus & 0xff;
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 4b131a6..0343b00 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -341,7 +341,7 @@ static void dm9601_set_multicast(struct net_device *net)
 	/* We use the 20 byte dev->data for our 8 byte filter buffer
 	 * to avoid allocating memory that is tricky to free later */
 	u8 *hashes = (u8 *) & dev->data;
-	u8 rx_ctl = 0x01;
+	u8 rx_ctl = 0x31;
 
 	memset(hashes, 0x00, DM_MCAST_SIZE);
 	hashes[DM_MCAST_SIZE - 1] |= 0x80;	/* broadcast address */
@@ -562,6 +562,10 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x8515),	/* ADMtek ADM8515 USB NIC */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	USB_DEVICE(0x0a47, 0x9601),	/* Hirose USB-100 */
+	.driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 727547a..369c731 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -283,7 +283,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		struct rndis_set_c	*set_c;
 		struct rndis_halt	*halt;
 	} u;
-	u32			tmp, *phym;
+	u32			tmp, phym_unspec, *phym;
 	int			reply_len;
 	unsigned char		*bp;
 
@@ -363,12 +363,15 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		goto halt_fail_and_release;
 
 	/* Check physical medium */
+	phym = NULL;
 	reply_len = sizeof *phym;
 	retval = rndis_query(dev, intf, u.buf, OID_GEN_PHYSICAL_MEDIUM,
 			0, (void **) &phym, &reply_len);
-	if (retval != 0)
+	if (retval != 0 || !phym) {
 		/* OID is optional so don't fail here. */
-		*phym = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
+		phym_unspec = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
+		phym = &phym_unspec;
+	}
 	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
 			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
 		if (netif_msg_probe(dev))
