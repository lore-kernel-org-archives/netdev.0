From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Mon, 29 Jul 2013 10:24:04 -0700
Message-ID: <1375118644.10515.18.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
	 <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
	 <1375052482.3669.54.camel@edumazet-glaptop>
	 <1375053654.3669.58.camel@edumazet-glaptop> <877gg9wv08.fsf@canonical.com>
	 <1375095442.3669.67.camel@edumazet-glaptop> <87y58pva88.fsf@canonical.com>
	 <1375111804.10515.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jcliburn@gmail.com
To: Luis Henriques <luis.henriques@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:49998 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758269Ab3G2RYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 13:24:06 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so6071223pad.36
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 10:24:06 -0700 (PDT)
In-Reply-To: <1375111804.10515.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Mon, 2013-07-29 at 08:30 -0700, Eric Dumazet wrote:
> On Mon, 2013-07-29 at 13:09 +0100, Luis Henriques wrote:
> 
> > 
> > I confirm that I can't reproduce the issue using this patch.
> > 
> 
> Thanks, I'll send a polished patch, as this one had an error if
> build_skb() returns NULL (in case sk_buff allocation fails)

Please try the following patch : It should use 2K frags instead of 4K
for normal 1500 mtu

Thanks !

[PATCH] atl1c: use custom skb allocator

We had reports ( https://bugzilla.kernel.org/show_bug.cgi?id=54021 )
that using high order pages for skb allocations is problematic for atl1c

We do not know exactly what the problem is, but we suspect that crossing
4K pages is not well supported by this hardware.

Use a custom allocator, using page allocator and 2K fragments for
optimal stack behavior. We might make this allocator generic
in future kernels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Luis Henriques <luis.henriques@canonical.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    3 +
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   40 +++++++++++++-
 2 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index b2bf324..0f05565 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -520,6 +520,9 @@ struct atl1c_adapter {
 	struct net_device   *netdev;
 	struct pci_dev      *pdev;
 	struct napi_struct  napi;
+	struct page         *rx_page;
+	unsigned int	    rx_page_offset;
+	unsigned int	    rx_frag_size;
 	struct atl1c_hw        hw;
 	struct atl1c_hw_stats  hw_stats;
 	struct mii_if_info  mii;    /* MII interface info */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 786a874..a36a760 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -481,10 +481,15 @@ static int atl1c_set_mac_addr(struct net_device *netdev, void *p)
 static void atl1c_set_rxbufsize(struct atl1c_adapter *adapter,
 				struct net_device *dev)
 {
+	unsigned int head_size;
 	int mtu = dev->mtu;
 
 	adapter->rx_buffer_len = mtu > AT_RX_BUF_SIZE ?
 		roundup(mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN, 8) : AT_RX_BUF_SIZE;
+
+	head_size = SKB_DATA_ALIGN(adapter->rx_buffer_len + NET_SKB_PAD) +
+		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	adapter->rx_frag_size = roundup_pow_of_two(head_size);
 }
 
 static netdev_features_t atl1c_fix_features(struct net_device *netdev,
@@ -952,6 +957,10 @@ static void atl1c_free_ring_resources(struct atl1c_adapter *adapter)
 		kfree(adapter->tpd_ring[0].buffer_info);
 		adapter->tpd_ring[0].buffer_info = NULL;
 	}
+	if (adapter->rx_page) {
+		put_page(adapter->rx_page);
+		adapter->rx_page = NULL;
+	}
 }
 
 /**
@@ -1639,6 +1648,35 @@ static inline void atl1c_rx_checksum(struct atl1c_adapter *adapter,
 	skb_checksum_none_assert(skb);
 }
 
+static struct sk_buff *atl1c_alloc_skb(struct atl1c_adapter *adapter)
+{
+	struct sk_buff *skb;
+	struct page *page;
+
+	if (adapter->rx_frag_size > PAGE_SIZE)
+		return netdev_alloc_skb(adapter->netdev,
+					adapter->rx_buffer_len);
+
+	page = adapter->rx_page;
+	if (!page) {
+		adapter->rx_page = page = alloc_page(GFP_ATOMIC);
+		if (unlikely(!page))
+			return NULL;
+		adapter->rx_page_offset = 0;
+	}
+
+	skb = build_skb(page_address(page) + adapter->rx_page_offset,
+			adapter->rx_frag_size);
+	if (likely(skb)) {
+		adapter->rx_page_offset += adapter->rx_frag_size;
+		if (adapter->rx_page_offset >= PAGE_SIZE)
+			adapter->rx_page = NULL;
+		else
+			get_page(page);
+	}
+	return skb;
+}
+
 static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 {
 	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -1660,7 +1698,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 	while (next_info->flags & ATL1C_BUFFER_FREE) {
 		rfd_desc = ATL1C_RFD_DESC(rfd_ring, rfd_next_to_use);
 
-		skb = netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len);
+		skb = atl1c_alloc_skb(adapter);
 		if (unlikely(!skb)) {
 			if (netif_msg_rx_err(adapter))
 				dev_warn(&pdev->dev, "alloc rx buffer failed\n");
