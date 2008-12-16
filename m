From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [PATCH v2 1/2 2.6.29] cxgb3 - manage private iSCSI IP address
Date: Tue, 16 Dec 2008 10:08:20 -0800
Message-ID: <8A71B368A89016469F72CD08050AD33403FF317E@maui.asicdesigners.com>
References: <1229189304.3465.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"James Bottomley" <James.Bottomley@HansenPartnership.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:2756 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163AbYLPSI4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 13:08:56 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave,

This net patch is independent of any iscsi/scsi changes. 

Thanks,
Karen

-----Original Message-----
From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com] 
Sent: Saturday, December 13, 2008 9:28 AM
To: linux-netdev@vger.kernel.org
Cc: David Miller; Karen Xie
Subject: Fwd: [PATCH v2 1/2 2.6.29] cxgb3 - manage private iSCSI IP
address

This is one half of an iSCSI driver.  What it does is enable the Chelsio
network card to expose a private address for iSCSI acceleration.  I
think both pieces of this driver are now ready for inclusion.

How do you want to handle this net patch, since it's a precursor for the
SCSI initiator?  I can either put both pieces in scsi-misc for 2.6.29 or
you can put this in net and I can create a post merge tree for the SCSI
piece ... either way is fine by me.

James

-------- Forwarded Message --------
From: Karen Xie <kxie@chelsio.com>
To: open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org
Cc: michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
kxie@chelsio.com
Subject: [PATCH v2 1/2 2.6.29] cxgb3 - manage private iSCSI IP address
Date: 	Tue, 9 Dec 2008 14:15:27 -0800

[PATCH v2 1/2 2.6.29] cxgb3 - manage private iSCSI IP address

From: Karen Xie <kxie@chelsio.com>

The accelerated iSCSI traffic could use a private IP address unknown to
the OS:
- The IP address is required in both drivers to manage ARP requests and
connection set up.
- Added an control call to retrieve the ip address.
- Reply to ARP requests dedicated to the private IP address.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
Signed-off-by: Karen Xie <kxie@chelsio.com>
---

 drivers/net/cxgb3/adapter.h        |    1 +
 drivers/net/cxgb3/cxgb3_ctl_defs.h |    7 ++++
 drivers/net/cxgb3/cxgb3_main.c     |    1 +
 drivers/net/cxgb3/cxgb3_offload.c  |   65
++++++++++++++++++++++++---------
 drivers/net/cxgb3/sge.c            |   72
++++++++++++++++++++++++++++++++++--
 5 files changed, 124 insertions(+), 22 deletions(-)


diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index bc8e241..0c60f40 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -63,6 +63,7 @@ struct port_info {
 	struct link_config link_config;
 	struct net_device_stats netstats;
 	int activity;
+	__be32 iscsi_ipv4addr;
 };
 
 enum {				/* adapter flags */
diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h
b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 1d8d46e..58b5bf9 100644
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
+	struct net_device *dev; /* the net_device */
+	__be32 ipv4addr;	/* the return iSCSI IPv4 address */
+};
+
 struct pci_dev;
 
 /*
diff --git a/drivers/net/cxgb3/cxgb3_main.c
b/drivers/net/cxgb3/cxgb3_main.c
index 2c341f8..809aa9f 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -34,6 +34,7 @@
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
+#include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
diff --git a/drivers/net/cxgb3/cxgb3_offload.c
b/drivers/net/cxgb3/cxgb3_offload.c
index 265aa8a..35dc683 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -182,7 +182,9 @@ static struct net_device *get_iff_from_mac(struct
adapter *adapter,
 static int cxgb_ulp_iscsi_ctl(struct adapter *adapter, unsigned int
req,
 			      void *data)
 {
+	int i;
 	int ret = 0;
+	unsigned int val = 0;
 	struct ulp_iscsi_info *uiip = data;
 
 	switch (req) {
@@ -191,31 +193,54 @@ static int cxgb_ulp_iscsi_ctl(struct adapter
*adapter, unsigned int req,
 		uiip->llimit = t3_read_reg(adapter,
A_ULPRX_ISCSI_LLIMIT);
 		uiip->ulimit = t3_read_reg(adapter,
A_ULPRX_ISCSI_ULIMIT);
 		uiip->tagmask = t3_read_reg(adapter,
A_ULPRX_ISCSI_TAGMASK);
+
+		val = t3_read_reg(adapter, A_ULPRX_ISCSI_PSZ);
+		for (i = 0; i < 4; i++, val >>= 8)
+			uiip->pgsz_factor[i] = val & 0xFF;
+
+		val = t3_read_reg(adapter, A_TP_PARA_REG7);
+		uiip->max_txsz =
+		uiip->max_rxsz = min((val >>
S_PMMAXXFERLEN0)&M_PMMAXXFERLEN0,
+				     (val >>
S_PMMAXXFERLEN1)&M_PMMAXXFERLEN1);
 		/*
 		 * On tx, the iscsi pdu has to be <= tx page size and
has to
 		 * fit into the Tx PM FIFO.
 		 */
-		uiip->max_txsz = min(adapter->params.tp.tx_pg_size,
-				     t3_read_reg(adapter, A_PM1_TX_CFG)
>> 17);
-		/* on rx, the iscsi pdu has to be < rx page size and the
-		   whole pdu + cpl headers has to fit into one sge
buffer */
-		uiip->max_rxsz = min_t(unsigned int,
-				       adapter->params.tp.rx_pg_size,
-
(adapter->sge.qs[0].fl[1].buf_size -
-					sizeof(struct cpl_rx_data) * 2 -
-					sizeof(struct
cpl_rx_data_ddp)));
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
+				"%s, iscsi set MaxRxData to 16224
(0x%x).\n",
+				adapter->name, val);
+			t3_write_reg(adapter, A_TP_PARA_REG2, val);
+		}
+
+		/*
+		 * on rx, the iscsi pdu has to be < rx page size and the
+		 *  the max rx data length programmed in TP
+		 */
+		val = min(adapter->params.tp.rx_pg_size,
+			  ((t3_read_reg(adapter, A_TP_PARA_REG2)) >>
+			   S_MAXRXDATA) & M_MAXRXDATA);
+		uiip->max_rxsz = min(val, uiip->max_rxsz);
 		break;
 	case ULP_ISCSI_SET_PARAMS:
 		t3_write_reg(adapter, A_ULPRX_ISCSI_TAGMASK,
uiip->tagmask);
-		/* set MaxRxData and MaxCoalesceSize to 16224 */
-		t3_write_reg(adapter, A_TP_PARA_REG2, 0x3f603f60);
 		/* program the ddp page sizes */
-		{
-			int i;
-			unsigned int val = 0;
-			for (i = 0; i < 4; i++)
-				val |= (uiip->pgsz_factor[i] & 0xF) <<
(8 * i);
-			if (val)
+		for (i = 0; i < 4; i++)
+			val |= (uiip->pgsz_factor[i] & 0xF) << (8 * i);
+		if (val && (val != t3_read_reg(adapter,
A_ULPRX_ISCSI_PSZ))) {
+			printk(KERN_INFO
+				"%s, setting iscsi pgsz 0x%x,
%u,%u,%u,%u.\n",
+				adapter->name, val,
uiip->pgsz_factor[0],
+				uiip->pgsz_factor[1],
uiip->pgsz_factor[2],
+				uiip->pgsz_factor[3]);
 				t3_write_reg(adapter, A_ULPRX_ISCSI_PSZ,
val);
 		}
 		break;
@@ -407,6 +432,12 @@ static int cxgb_offload_ctl(struct t3cdev *tdev,
unsigned int req, void *data)
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
index c6480be..803dc98 100644
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
@@ -1857,6 +1858,54 @@ static void restart_tx(struct sge_qset *qs)
 }
 
 /**
+ *	cxgb3_arp_process - process an ARP request probing a private IP
address
+ *	@adapter: the adapter
+ *	@skb: the skbuff containing the ARP request
+ *
+ *	Check if the ARP request is probing the private IP address
+ *	dedicated to iSCSI, generate an ARP reply if so.
+ */
+static void cxgb3_arp_process(struct adapter *adapter, struct sk_buff
*skb)
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
@@ -1880,7 +1929,7 @@ static void rx_eth(struct adapter *adap, struct
sge_rspq *rq,
 	pi = netdev_priv(skb->dev);
 	if (pi->rx_csum_offload && p->csum_valid && p->csum ==
htons(0xffff) &&
 	    !p->fragment) {
-		rspq_to_qset(rq)->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
+		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
@@ -1889,22 +1938,35 @@ static void rx_eth(struct adapter *adap, struct
sge_rspq *rq,
 		struct vlan_group *grp = pi->vlan_grp;
 
 		qs->port_stats[SGE_PSTAT_VLANEX]++;
-		if (likely(grp))
+
+		if (likely(grp)) {
 			if (lro)
 
lro_vlan_hwaccel_receive_skb(&qs->lro_mgr, skb,
 							     grp,
 
ntohs(p->vlan),
 							     p);
-			else
+			else {
+				if (unlikely(pi->iscsi_ipv4addr &&
+					     is_arp(skb))) {
+					unsigned short vtag =
ntohs(p->vlan) &
+							VLAN_VID_MASK;
+					skb->dev =
vlan_group_get_device(grp,
+
vtag);
+					cxgb3_arp_process(adap, skb);
+				}
 				__vlan_hwaccel_rx(skb, grp,
ntohs(p->vlan),
 					  	  rq->polling);
-		else
+			}
+		} else
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
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

