From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/4 2.6.28] cxgb3 - handle ARP replies for private iSCSI IP address
Date: Wed, 27 Aug 2008 21:21:58 -0700
Message-ID: <200808280421.m7S4Lw4r006465@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, daisyc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, wenxiong-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, bhua-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


[PATCH 2/4 2.6.28] cxgb3 - handle ARP replies for private iSCSI IP address

From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

The accelerated iSCSI traffic uses a private IP address unknown to the OS.
The driver has to reply to ARP requests dedicated to the private IP address.

Signed-off-by: Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---

 drivers/net/cxgb3/sge.c |   72 ++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 67 insertions(+), 5 deletions(-)


diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 1b0861d..2f17cf3 100644
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
@@ -1859,6 +1860,54 @@ static void restart_tx(struct sge_qset *qs)
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
@@ -1882,7 +1931,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	pi = netdev_priv(skb->dev);
 	if (pi->rx_csum_offload && p->csum_valid && p->csum == htons(0xffff) &&
 	    !p->fragment) {
-		rspq_to_qset(rq)->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
+		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
@@ -1891,22 +1940,35 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
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
+					unsigned short vtag = ntohs(p->vlan) &
+							VLAN_VID_MASK;
+					skb->dev = vlan_group_get_device(grp,
+									 vtag);
+					cxgb3_arp_process(adap, skb);
+				}
 				__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
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
