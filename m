From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 4/6] cxgb: Use napi_alloc_skb instead of
 netdev_alloc_skb_ip_align
Date: Tue, 09 Dec 2014 19:41:03 -0800
Message-ID: <20141210034103.2114.72532.stgit@ahduyck-vm-fedora20>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, davem@davemloft.net, eric.dumazet@gmail.com,
	brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480AbaLJDlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 22:41:09 -0500
In-Reply-To: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to use napi_alloc_skb I needed to pass a pointer to struct adapter
instead of struct pci_dev.  This allowed me to access &adapter->napi.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb/sge.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 86222a1..babe2a9 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1025,7 +1025,7 @@ MODULE_PARM_DESC(copybreak, "Receive copy threshold");
 
 /**
  *	get_packet - return the next ingress packet buffer
- *	@pdev: the PCI device that received the packet
+ *	@adapter: the adapter that received the packet
  *	@fl: the SGE free list holding the packet
  *	@len: the actual packet length, excluding any SGE padding
  *
@@ -1037,14 +1037,15 @@ MODULE_PARM_DESC(copybreak, "Receive copy threshold");
  *	threshold and the packet is too big to copy, or (b) the packet should
  *	be copied but there is no memory for the copy.
  */
-static inline struct sk_buff *get_packet(struct pci_dev *pdev,
+static inline struct sk_buff *get_packet(struct adapter *adapter,
 					 struct freelQ *fl, unsigned int len)
 {
-	struct sk_buff *skb;
 	const struct freelQ_ce *ce = &fl->centries[fl->cidx];
+	struct pci_dev *pdev = adapter->pdev;
+	struct sk_buff *skb;
 
 	if (len < copybreak) {
-		skb = netdev_alloc_skb_ip_align(NULL, len);
+		skb = napi_alloc_skb(&adapter->napi, len);
 		if (!skb)
 			goto use_orig_buf;
 
@@ -1357,7 +1358,7 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	struct sge_port_stats *st;
 	struct net_device *dev;
 
-	skb = get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad);
+	skb = get_packet(adapter, fl, len - sge->rx_pkt_pad);
 	if (unlikely(!skb)) {
 		sge->stats.rx_drops++;
 		return;
