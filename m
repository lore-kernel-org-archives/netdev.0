From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH v3 2.6.29] cxgb3 - manage private iSCSI IP address
Date: Thu, 18 Dec 2008 18:43:25 -0800
Message-ID: <200812190243.mBJ2hPZY008757@localhost.localdomain>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
	kxie@chelsio.com, divy@chelsio.com, swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:29260 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbYLSCky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 21:40:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH v3 2.6.29] cxgb3 - manage private iSCSI IP address

From: Karen Xie <kxie@chelsio.com>

This patch is re-based on net-next-2.6 instead of scsi-misc-2.6.

The accelerated iSCSI traffic could use a private IP address unknown to the OS:
- The IP address is required in both drivers to manage ARP requests and connection set up.
- Added an control call to retrieve the ip address.
- Reply to ARP requests dedicated to the private IP address.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
Signed-off-by: Karen Xie <kxie@chelsio.com>
---

 drivers/net/cxgb3/adapter.h        |    1 +
 drivers/net/cxgb3/cxgb3_ctl_defs.h |    7 ++++
 drivers/net/cxgb3/cxgb3_offload.c  |   67 ++++++++++++++++++++++++++----------
 drivers/net/cxgb3/sge.c            |   67 ++++++++++++++++++++++++++++++++++--
 4 files changed, 121 insertions(+), 21 deletions(-)


diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index c190a69..5b346f9 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -63,6 +63,7 @@ struct port_info {
 	struct link_config link_config;
 	struct net_device_stats netstats;
 	int activity;
+	__be32 iscsi_ipv4addr;
 };
 
 enum {				/* adapter flags */
diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 1d8d46e..55099eb 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -57,6 +57,7 @@ enum {
 	RDMA_GET_MIB		= 19,
 
 	GET_RX_PAGE_INFO	= 50,
+	GET_ISCSI_IPV4ADDR	= 51,
 };
 
 /*
@@ -86,6 +87,12 @@ struct iff_mac {
 	u16 vlan_tag;
 };
 
+/* Structure used to request a port's iSCSI IPv4 address */
+struct iscsi_ipv4addr {
+	struct net_device *dev;	/* the net_device */
+	__be32 ipv4addr;	/* the return iSCSI IPv4 address */
+};
+
 struct pci_dev;
 
 /*
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 265aa8a..1ce69b7 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -182,7 +182,9 @@ static struct net_device *get_iff_from_mac(struct adapter *adapter,
 static int cxgb_ulp_iscsi_ctl(struct adapter *adapter, unsigned int req,
 			      void *data)
 {
+	int i;
 	int ret = 0;
+	unsigned int val = 0;
 	struct ulp_iscsi_info *uiip = data;
 
 	switch (req) {
@@ -191,32 +193,55 @@ static int cxgb_ulp_iscsi_ctl(struct adapter *adapter, unsigned int req,
 		uiip->llimit = t3_read_reg(adapter, A_ULPRX_ISCSI_LLIMIT);
 		uiip->ulimit = t3_read_reg(adapter, A_ULPRX_ISCSI_ULIMIT);
 		uiip->tagmask = t3_read_reg(adapter, A_ULPRX_ISCSI_TAGMASK);
+
+		val = t3_read_reg(adapter, A_ULPRX_ISCSI_PSZ);
+		for (i = 0; i < 4; i++, val >>= 8)
+			uiip->pgsz_factor[i] = val & 0xFF;
+
+		val = t3_read_reg(adapter, A_TP_PARA_REG7);
+		uiip->max_txsz =
+		uiip->max_rxsz = min((val >> S_PMMAXXFERLEN0)&M_PMMAXXFERLEN0,
+				     (val >> S_PMMAXXFERLEN1)&M_PMMAXXFERLEN1);
 		/*
 		 * On tx, the iscsi pdu has to be <= tx page size and has to
 		 * fit into the Tx PM FIFO.
 		 */
-		uiip->max_txsz = min(adapter->params.tp.tx_pg_size,
-				     t3_read_reg(adapter, A_PM1_TX_CFG) >> 17);
-		/* on rx, the iscsi pdu has to be < rx page size and the
-		   whole pdu + cpl headers has to fit into one sge buffer */
-		uiip->max_rxsz = min_t(unsigned int,
-				       adapter->params.tp.rx_pg_size,
-				       (adapter->sge.qs[0].fl[1].buf_size -
-					sizeof(struct cpl_rx_data) * 2 -
-					sizeof(struct cpl_rx_data_ddp)));
+		val = min(adapter->params.tp.tx_pg_size,
+			  t3_read_reg(adapter, A_PM1_TX_CFG) >> 17);
+		uiip->max_txsz = min(val, uiip->max_txsz);
+
+		/* set MaxRxData to 16224 */
+		val = t3_read_reg(adapter, A_TP_PARA_REG2);
+		if ((val >> S_MAXRXDATA) != 0x3f60) {
+			val &= (M_RXCOALESCESIZE << S_RXCOALESCESIZE);
+			val |= V_MAXRXDATA(0x3f60);
+			printk(KERN_INFO
+				"%s, iscsi set MaxRxData to 16224 (0x%x).\n",
+				adapter->name, val);
+			t3_write_reg(adapter, A_TP_PARA_REG2, val);
+		}
+
+		/*
+		 * on rx, the iscsi pdu has to be < rx page size and the
+		 * the max rx data length programmed in TP
+		 */
+		val = min(adapter->params.tp.rx_pg_size,
+			  ((t3_read_reg(adapter, A_TP_PARA_REG2)) >>
+				S_MAXRXDATA) & M_MAXRXDATA);
+		uiip->max_rxsz = min(val, uiip->max_rxsz);
 		break;
 	case ULP_ISCSI_SET_PARAMS:
 		t3_write_reg(adapter, A_ULPRX_ISCSI_TAGMASK, uiip->tagmask);
-		/* set MaxRxData and MaxCoalesceSize to 16224 */
-		t3_write_reg(adapter, A_TP_PARA_REG2, 0x3f603f60);
 		/* program the ddp page sizes */
-		{
-			int i;
-			unsigned int val = 0;
-			for (i = 0; i < 4; i++)
-				val |= (uiip->pgsz_factor[i] & 0xF) << (8 * i);
-			if (val)
-				t3_write_reg(adapter, A_ULPRX_ISCSI_PSZ, val);
+		for (i = 0; i < 4; i++)
+			val |= (uiip->pgsz_factor[i] & 0xF) << (8 * i);
+		if (val && (val != t3_read_reg(adapter, A_ULPRX_ISCSI_PSZ))) {
+			printk(KERN_INFO
+				"%s, setting iscsi pgsz 0x%x, %u,%u,%u,%u.\n",
+				adapter->name, val, uiip->pgsz_factor[0],
+				uiip->pgsz_factor[1], uiip->pgsz_factor[2],
+				uiip->pgsz_factor[3]);
+			t3_write_reg(adapter, A_ULPRX_ISCSI_PSZ, val);
 		}
 		break;
 	default:
@@ -407,6 +432,12 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 		rx_page_info->page_size = tp->rx_pg_size;
 		rx_page_info->num = tp->rx_num_pgs;
 		break;
+	case GET_ISCSI_IPV4ADDR: {
+		struct iscsi_ipv4addr *p = data;
+		struct port_info *pi = netdev_priv(p->dev);
+		p->ipv4addr = pi->iscsi_ipv4addr;
+		break;
+	}
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 63eb974..6c641a8 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -36,6 +36,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/dma-mapping.h>
+#include <net/arp.h>
 #include "common.h"
 #include "regs.h"
 #include "sge_defs.h"
@@ -1863,6 +1864,54 @@ static void restart_tx(struct sge_qset *qs)
 }
 
 /**
+ *	cxgb3_arp_process - process an ARP request probing a private IP address
+ *	@adapter: the adapter
+ *	@skb: the skbuff containing the ARP request
+ *
+ *	Check if the ARP request is probing the private IP address
+ *	dedicated to iSCSI, generate an ARP reply if so.
+ */
+static void cxgb3_arp_process(struct adapter *adapter, struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct port_info *pi;
+	struct arphdr *arp;
+	unsigned char *arp_ptr;
+	unsigned char *sha;
+	__be32 sip, tip;
+
+	if (!dev)
+		return;
+
+	skb_reset_network_header(skb);
+	arp = arp_hdr(skb);
+
+	if (arp->ar_op != htons(ARPOP_REQUEST))
+		return;
+
+	arp_ptr = (unsigned char *)(arp + 1);
+	sha = arp_ptr;
+	arp_ptr += dev->addr_len;
+	memcpy(&sip, arp_ptr, sizeof(sip));
+	arp_ptr += sizeof(sip);
+	arp_ptr += dev->addr_len;
+	memcpy(&tip, arp_ptr, sizeof(tip));
+
+	pi = netdev_priv(dev);
+	if (tip != pi->iscsi_ipv4addr)
+		return;
+
+	arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
+		 dev->dev_addr, sha);
+
+}
+
+static inline int is_arp(struct sk_buff *skb)
+{
+	return skb->protocol == htons(ETH_P_ARP);
+}
+
+/**
  *	rx_eth - process an ingress ethernet packet
  *	@adap: the adapter
  *	@rq: the response queue that received the packet
@@ -1885,7 +1934,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	pi = netdev_priv(skb->dev);
 	if (pi->rx_csum_offload && p->csum_valid && p->csum == htons(0xffff) &&
 	    !p->fragment) {
-		rspq_to_qset(rq)->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
+		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
@@ -1900,16 +1949,28 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 							     grp,
 							     ntohs(p->vlan),
 							     p);
-			else
+			else {
+				if (unlikely(pi->iscsi_ipv4addr &&
+				    is_arp(skb))) {
+					unsigned short vtag = ntohs(p->vlan) &
+								VLAN_VID_MASK;
+					skb->dev = vlan_group_get_device(grp,
+									 vtag);
+					cxgb3_arp_process(adap, skb);
+				}
 				__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
 					  	  rq->polling);
+			}
 		else
 			dev_kfree_skb_any(skb);
 	} else if (rq->polling) {
 		if (lro)
 			lro_receive_skb(&qs->lro_mgr, skb, p);
-		else
+		else {
+			if (unlikely(pi->iscsi_ipv4addr && is_arp(skb)))
+				cxgb3_arp_process(adap, skb);
 			netif_receive_skb(skb);
+		}
 	} else
 		netif_rx(skb);
 }
