From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 3/3] drivers/net/bfin_mac.c: Misc function
 cleanups, neatening
Date: Thu, 29 Jul 2010 18:47:00 -0700
Message-ID: <1280454420.21777.6.camel@Joe-Laptop.home>
References: <cover.1280447281.git.joe@perches.com>
	 <e90ce59d7dcbbdb24e1882a4e99b0c3db2bd116a.1280447281.git.joe@perches.com>
	 <AANLkTikYn+qpDxxLeJ4eu5SsEs=7n_wAu5RzM5pZhVwU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikYn+qpDxxLeJ4eu5SsEs=7n_wAu5RzM5pZhVwU@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use new bfin_alloc_skb to centralize skb allocations
Add and use get_mac_addr function
Neaten bfin_mac_init
Neaten bfin_mac_hard_start_xmit

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bfin_mac.c |   93 ++++++++++++++++++++++++++---------------------
 1 files changed, 51 insertions(+), 42 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 7543b07..6c23a91 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -83,6 +83,26 @@ static u16 pin_req[] = P_RMII0;
 static u16 pin_req[] = P_MII0;
 #endif
 
+static struct sk_buff *bfin_alloc_skb(void)
+{
+	/* allocate a new skb */
+	struct sk_buff *new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+
+	if (!new_skb)
+		return NULL;
+
+	skb_reserve(new_skb, NET_IP_ALIGN);
+	/*
+	 * Invalidate the data cache of skb->data range
+	 * when it is write back cache to prevent overwriting
+	 * the new data from DMA.
+	 */
+	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
+					 (unsigned long)new_skb->end);
+
+	return new_skb;
+}
+
 static void desc_list_free(void)
 {
 	struct net_dma_desc_rx *r;
@@ -195,18 +215,12 @@ static int desc_list_init(void)
 		struct dma_descriptor *b = &(r->desc_b);
 
 		/* allocate a new skb for next time receive */
-		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+		new_skb = bfin_alloc_skb();
 		if (!new_skb) {
 			pr_notice("init: low on mem - packet dropped\n");
 			goto init_error;
 		}
-		skb_reserve(new_skb, NET_IP_ALIGN);
-		/* Invalidate the data cache of skb->data range when it is
-		 * write back cache.
-		 * It will prevent overwriting the new data from DMA
-		 */
-		blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
-					 (unsigned long)new_skb->end);
+
 		r->skb = new_skb;
 
 		/*
@@ -600,6 +614,16 @@ void setup_system_regs(struct net_device *dev)
 	bfin_write_DMA1_Y_MODIFY(0);
 }
 
+/* Grab the MAC address in the MAC */
+static void get_mac_addr(u8 *mac_addr)
+{
+	__le32 addr_low = cpu_to_le32(bfin_read_EMAC_ADDRLO());
+	__le16 addr_hi = cpu_to_le16((u16)bfin_read_EMAC_ADDRHI());
+
+	memcpy(mac_addr, &addr_low, 4);
+	memcpy(mac_addr + 4, &addr_hi, 2);
+}
+
 static void setup_mac_addr(u8 *mac_addr)
 {
 	u32 addr_low = le32_to_cpu(*(__le32 *)&mac_addr[0]);
@@ -998,15 +1022,17 @@ static void tx_reclaim_skb_timeout(unsigned long lp)
 static int bfin_mac_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	u16 *data;
 	u32 data_align = (unsigned long)(skb->data) & 0x3;
+	unsigned long buf_start;
+	unsigned long buf_len;
 	union skb_shared_tx *shtx = skb_tx(skb);
 
 	current_tx_ptr->skb = skb;
 
 	if (data_align == 0x2) {
 		/* move skb->data to current_tx_ptr payload */
-		data = (u16 *)(skb->data) - 1;
+		u16 *data = (u16 *)(skb->data) - 1;
+
 		*data = (u16)(skb->len);
 		/*
 		 * When transmitting an Ethernet packet, the PTP_TSYNC module
@@ -1018,23 +1044,21 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (shtx->hardware)
 			*data |= 0x1000;
 
-		current_tx_ptr->desc_a.start_addr = (u32)data;
-		/* this is important! */
-		blackfin_dcache_flush_range((u32)data,
-					    (u32)((u8 *)data + skb->len + 4));
+		buf_start = (unsigned long)data;
+		buf_len = skb->len + 4;
 	} else {
 		*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
 		/* enable timestamping for the sent packet */
 		if (shtx->hardware)
 			*((u16 *)(current_tx_ptr->packet)) |= 0x1000;
-		memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
-			skb->len);
-		current_tx_ptr->desc_a.start_addr =
-			(u32)current_tx_ptr->packet;
-		blackfin_dcache_flush_range(
-			(u32)current_tx_ptr->packet,
-			(u32)(current_tx_ptr->packet + skb->len + 2));
+		memcpy(current_tx_ptr->packet + 2, skb->data, skb->len);
+
+		buf_start = (unsigned long)current_tx_ptr->packet;
+		buf_len = skb->len + 2;
 	}
+	current_tx_ptr->desc_a.start_addr = buf_start;
+	/* this is important! */
+	blackfin_dcache_flush_range(buf_start, buf_start + buf_len);
 
 	/*
 	 * Make sure the internal data buffers in the core are drained
@@ -1099,20 +1123,12 @@ static void bfin_mac_rx(struct net_device *dev)
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
 
-	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+	new_skb = bfin_alloc_skb();
 	if (!new_skb) {
 		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
-	/* reserve 2 bytes for RXDWA padding */
-	skb_reserve(new_skb, NET_IP_ALIGN);
-	/*
-	 * Invalidate the data cache of skb->data range when it is write back
-	 * cache. It will prevent overwriting the new data from DMA
-	 */
-	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
-					 (unsigned long)new_skb->end);
 
 	current_rx_ptr->skb = new_skb;
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
@@ -1479,14 +1495,10 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	lp = netdev_priv(ndev);
 	lp->ndev = ndev;
 
-	/* Grab the MAC address in the MAC */
-	*(__le32 *)(&(ndev->dev_addr[0])) =
-		cpu_to_le32(bfin_read_EMAC_ADDRLO());
-	*(__le16 *)(&(ndev->dev_addr[4])) =
-		cpu_to_le16((u16)bfin_read_EMAC_ADDRHI());
+	get_mac_addr(ndev->dev_addr);
 
 	/* probe mac */
-	/*todo: how to proble? which is revision_register */
+	/* todo: how to probe? which is revision_register */
 	bfin_write_EMAC_ADDRLO(0x12345678);
 	if (bfin_read_EMAC_ADDRLO() != 0x12345678) {
 		dev_err(&pdev->dev, "Cannot detect Blackfin on-chip ethernet MAC controller!\n");
@@ -1722,12 +1734,9 @@ static struct platform_driver bfin_mac_driver = {
 
 static int __init bfin_mac_init(void)
 {
-	int ret;
-
-	ret = platform_driver_register(&bfin_mii_bus_driver);
-	if (!ret)
-		return platform_driver_register(&bfin_mac_driver);
-	return -ENODEV;
+	if (platform_driver_register(&bfin_mii_bus_driver))
+		return -ENODEV;
+	return platform_driver_register(&bfin_mac_driver);
 }
 
 module_init(bfin_mac_init);
-- 
1.7.2.19.g9a302
