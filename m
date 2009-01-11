From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] cxgb3: Keep LRO off if disabled when interface is down
Date: Sat, 10 Jan 2009 23:33:29 -0800
Message-ID: <adaljtimh4m.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>, Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:16151 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbZAKHda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:33:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a system with a Chelsio adapter (driven by cxgb3) whose ports are
part of a Linux bridge.  Recently I updated the kernel and discovered
that things stopped working because cxgb3 was doing LRO on packets that
were passed into the bridge code for forwarding.  (Incidentally, this
problem manifested itself in a strange way that made debugging a bit
interesting -- for some reason, the skb_warn_if_lro() check in bridge
didn't trigger and these LROed packets were forwarded out a forcedeth
interface, and caused the forcedeth transmit path to get stuck)

This is because cxgb3 has no way of keeping state for the LRO flag until
the interface is brought up, so if the bridging code disables LRO while
the interface is down, then cxgb3_up() will just reenable LRO, and on my
Debian system at least, the init scripts add interfaces to a bridge
before bringing the interfaces up.

Fix this by keeping track of each interface's LRO state in cxgb3 so that
when bridge disables LRO, it stays disabled in cxgb3_up() when the
interface is brought up.  I did this by changing the rx_csum_offload
flag into a pair of bit flags; the effect of this on the rx_eth() fast
path is miniscule enough that it should be fine (eg on x86, a cmpb
instruction becomes a testb instruction).

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/cxgb3/adapter.h    |    7 ++++++-
 drivers/net/cxgb3/cxgb3_main.c |   22 ++++++++++++++--------
 drivers/net/cxgb3/sge.c        |    2 +-
 3 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 5b346f9..a89d8cc 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -50,12 +50,17 @@ struct vlan_group;
 struct adapter;
 struct sge_qset;
 
+enum {			/* rx_offload flags */
+	T3_RX_CSUM	= 1 << 0,
+	T3_LRO		= 1 << 1,
+};
+
 struct port_info {
 	struct adapter *adapter;
 	struct vlan_group *vlan_grp;
 	struct sge_qset *qs;
 	u8 port_id;
-	u8 rx_csum_offload;
+	u8 rx_offload;
 	u8 nqsets;
 	u8 first_qset;
 	struct cphy phy;
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 2847f94..0089746 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -546,7 +546,7 @@ static int setup_sge_qsets(struct adapter *adap)
 		pi->qs = &adap->sge.qs[pi->first_qset];
 		for (j = pi->first_qset; j < pi->first_qset + pi->nqsets;
 		     ++j, ++qset_idx) {
-			set_qset_lro(dev, qset_idx, pi->rx_csum_offload);
+			set_qset_lro(dev, qset_idx, pi->rx_offload & T3_LRO);
 			err = t3_sge_alloc_qset(adap, qset_idx, 1,
 				(adap->flags & USING_MSIX) ? qset_idx + 1 :
 							     irq_idx,
@@ -1657,17 +1657,19 @@ static u32 get_rx_csum(struct net_device *dev)
 {
 	struct port_info *p = netdev_priv(dev);
 
-	return p->rx_csum_offload;
+	return p->rx_offload & T3_RX_CSUM;
 }
 
 static int set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct port_info *p = netdev_priv(dev);
 
-	p->rx_csum_offload = data;
-	if (!data) {
+	if (data) {
+		p->rx_offload |= T3_RX_CSUM;
+	} else {
 		int i;
 
+		p->rx_offload &= ~(T3_RX_CSUM | T3_LRO);
 		for (i = p->first_qset; i < p->first_qset + p->nqsets; i++)
 			set_qset_lro(dev, i, 0);
 	}
@@ -1830,15 +1832,18 @@ static int cxgb3_set_flags(struct net_device *dev, u32 data)
 	int i;
 
 	if (data & ETH_FLAG_LRO) {
-		if (!pi->rx_csum_offload)
+		if (!(pi->rx_offload & T3_RX_CSUM))
 			return -EINVAL;
 
+		pi->rx_offload |= T3_LRO;
 		for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; i++)
 			set_qset_lro(dev, i, 1);
 
-	} else
+	} else {
+		pi->rx_offload &= ~T3_LRO;
 		for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; i++)
 			set_qset_lro(dev, i, 0);
+	}
 
 	return 0;
 }
@@ -1926,7 +1931,7 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 				pi = adap2pinfo(adapter, i);
 				if (t.qset_idx >= pi->first_qset &&
 				    t.qset_idx < pi->first_qset + pi->nqsets &&
-				    !pi->rx_csum_offload)
+				    !(pi->rx_offload & T3_RX_CSUM))
 					return -EINVAL;
 			}
 
@@ -2946,7 +2951,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		adapter->port[i] = netdev;
 		pi = netdev_priv(netdev);
 		pi->adapter = adapter;
-		pi->rx_csum_offload = 1;
+		pi->rx_offload = T3_RX_CSUM | T3_LRO;
 		pi->port_id = i;
 		netif_carrier_off(netdev);
 		netif_tx_stop_all_queues(netdev);
@@ -2955,6 +2960,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 		netdev->features |= NETIF_F_LLTX;
+		netdev->features |= NETIF_F_LRO;
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 6c641a8..14f9fb3 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1932,7 +1932,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	skb_pull(skb, sizeof(*p) + pad);
 	skb->protocol = eth_type_trans(skb, adap->port[p->iff]);
 	pi = netdev_priv(skb->dev);
-	if (pi->rx_csum_offload && p->csum_valid && p->csum == htons(0xffff) &&
+	if ((pi->rx_offload & T3_RX_CSUM) && p->csum_valid && p->csum == htons(0xffff) &&
 	    !p->fragment) {
 		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
