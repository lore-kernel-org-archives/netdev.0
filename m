From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 5/6] ethernet/realtek: use napi_alloc_skb instead
 of netdev_alloc_skb_ip_align
Date: Tue, 09 Dec 2014 19:41:09 -0800
Message-ID: <20141210034109.2114.7694.stgit@ahduyck-vm-fedora20>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	ast@plumgrid.com, davem@davemloft.net, eric.dumazet@gmail.com,
	brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753720AbaLJDlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 22:41:40 -0500
In-Reply-To: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces most of the calls to netdev_alloc_skb_ip_align in the Realtek
drivers.  The one instance I didn't replace in 8139cp.c is because it was
called as a part of init and as such is not always accessed from the
softirq context.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c  |    2 +-
 drivers/net/ethernet/realtek/8139too.c |    2 +-
 drivers/net/ethernet/realtek/r8169.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 75b1693..9c31e46 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -507,7 +507,7 @@ rx_status_loop:
 		netif_dbg(cp, rx_status, dev, "rx slot %d status 0x%x len %d\n",
 			  rx_tail, status, len);
 
-		new_skb = netdev_alloc_skb_ip_align(dev, buflen);
+		new_skb = napi_alloc_skb(napi, buflen);
 		if (!new_skb) {
 			dev->stats.rx_dropped++;
 			goto rx_next;
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 63dc0f9..6d0b9df 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2037,7 +2037,7 @@ keep_pkt:
 		/* Malloc up new buffer, compatible with net-2e. */
 		/* Omit the four octet CRC from the length. */
 
-		skb = netdev_alloc_skb_ip_align(dev, pkt_size);
+		skb = napi_alloc_skb(&tp->napi, pkt_size);
 		if (likely(skb)) {
 #if RX_BUF_IDX == 3
 			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1620184..54a3ec1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7269,7 +7269,7 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 	data = rtl8169_align(data);
 	dma_sync_single_for_cpu(d, addr, pkt_size, DMA_FROM_DEVICE);
 	prefetch(data);
-	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
+	skb = napi_alloc_skb(&tp->napi, pkt_size);
 	if (skb)
 		memcpy(skb->data, data, pkt_size);
 	dma_sync_single_for_device(d, addr, pkt_size, DMA_FROM_DEVICE);
