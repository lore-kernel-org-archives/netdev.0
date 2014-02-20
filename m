From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Thu, 20 Feb 2014 09:39:53 +0000
Message-ID: <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
References: <OF1C38716E.D9F528E0-ON48257C85.000A026B-48257C85.000AA8C9@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"wang.liang82@zte.com.cn" <wang.liang82@zte.com.cn>,
	"cai.qu@zte.com.cn" <cai.qu@zte.com.cn>,
	"li.fengmao@zte.com.cn" <li.fengmao@zte.com.cn>,
	"long.chun@zte.com.cn" <long.chun@zte.com.cn>,
	David Miller <davem@davemloft.net>
To: "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18821 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaBTJj5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 04:39:57 -0500
In-Reply-To: <OF1C38716E.D9F528E0-ON48257C85.000A026B-48257C85.000AA8C9@zte.com.cn>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: jiang.biao2@zte.com.cn [mailto:jiang.biao2@zte.com.cn]
> 
> 
> From: Li Fengmao <li.fengmao@zte.com.cn>
> 
> There will be packet drop with kernel param "swiotlb = force" on
> Emulex 10Gb NIC using be2net driver. The problem is caused by
> receiving skb without calling pci_unmap_page() in get_rx_page_info().
> rx_page_info->last_page_user is initialized to false in
> be_post_rx_frags() when current frag are mapped in the first half of
> the same page with another frag. But in that case with
> "swiotlb = force" param, data can not be copied into the page of
> rx_page_info without calling pci_unmap_page, so the data frag mapped
> in the first half of the page will be dropped.
> 
> It can be solved by creating only a mapping relation between frag
> and page, and deleting rx_page_info->last_page_user to ensure
> calling pci_unmap_page when handling each receiving frag.

This patch uses an entire page for each RX frag (whose default size is 2048).
Consequently, on platforms like ppc64 where the default PAGE_SIZE is 64K,
memory usage becomes very inefficient.

Instead, I've tried a partial-page mapping scheme. This retains the
page sharing logic, but un-maps each frag separately so that
the data is copied from the bounce buffers.

Pls see if this works for you;  thanks.

---
diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index a150401..013777a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -263,7 +263,6 @@ struct be_rx_page_info {
 	struct page *page;
 	DEFINE_DMA_UNMAP_ADDR(bus);
 	u16 page_offset;
-	bool last_page_user;
 };
 
 struct be_rx_stats {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4f87f5c..9d8ea91 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1448,13 +1448,8 @@ static struct be_rx_page_info *get_rx_page_info(struct be_rx_obj *rxo)
 	rx_page_info = &rxo->page_info_tbl[frag_idx];
 	BUG_ON(!rx_page_info->page);
 
-	if (rx_page_info->last_page_user) {
-		dma_unmap_page(&adapter->pdev->dev,
-			       dma_unmap_addr(rx_page_info, bus),
-			       adapter->big_page_size, DMA_FROM_DEVICE);
-		rx_page_info->last_page_user = false;
-	}
-
+	dma_unmap_page(&adapter->pdev->dev, dma_unmap_addr(rx_page_info, bus),
+		       rx_frag_size, DMA_FROM_DEVICE);
 	queue_tail_inc(rxq);
 	atomic_dec(&rxq->used);
 	return rx_page_info;
@@ -1761,12 +1756,12 @@ static inline struct page *be_alloc_pages(u32 size, gfp_t gfp)
 static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 {
 	struct be_adapter *adapter = rxo->adapter;
-	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
+	struct be_rx_page_info *page_info = NULL;
 	struct be_queue_info *rxq = &rxo->q;
 	struct page *pagep = NULL;
 	struct device *dev = &adapter->pdev->dev;
 	struct be_eth_rx_d *rxd;
-	u64 page_dmaaddr = 0, frag_dmaaddr;
+	u64 frag_dmaaddr;
 	u32 posted, page_offset = 0;
 
 	page_info = &rxo->page_info_tbl[rxq->head];
@@ -1777,24 +1772,22 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 				rx_stats(rxo)->rx_post_fail++;
 				break;
 			}
-			page_dmaaddr = dma_map_page(dev, pagep, 0,
-						    adapter->big_page_size,
-						    DMA_FROM_DEVICE);
-			if (dma_mapping_error(dev, page_dmaaddr)) {
-				put_page(pagep);
-				pagep = NULL;
-				rx_stats(rxo)->rx_post_fail++;
-				break;
-			}
 			page_info->page_offset = 0;
 		} else {
 			get_page(pagep);
 			page_info->page_offset = page_offset + rx_frag_size;
 		}
 		page_offset = page_info->page_offset;
+
+		frag_dmaaddr = dma_map_page(dev, pagep, page_offset,
+					    rx_frag_size, DMA_FROM_DEVICE);
+		if (dma_mapping_error(dev, frag_dmaaddr)) {
+			put_page(pagep);
+			rx_stats(rxo)->rx_post_fail++;
+			break;
+		}
 		page_info->page = pagep;
-		dma_unmap_addr_set(page_info, bus, page_dmaaddr);
-		frag_dmaaddr = page_dmaaddr + page_info->page_offset;
+		dma_unmap_addr_set(page_info, bus, frag_dmaaddr);
 
 		rxd = queue_head_node(rxq);
 		rxd->fragpa_lo = cpu_to_le32(frag_dmaaddr & 0xFFFFFFFF);
@@ -1802,17 +1795,12 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 
 		/* Any space left in the current big page for another frag? */
 		if ((page_offset + rx_frag_size + rx_frag_size) >
-					adapter->big_page_size) {
+					adapter->big_page_size)
 			pagep = NULL;
-			page_info->last_page_user = true;
-		}
 
-		prev_page_info = page_info;
 		queue_head_inc(rxq);
 		page_info = &rxo->page_info_tbl[rxq->head];
 	}
-	if (pagep)
-		prev_page_info->last_page_user = true;
 
 	if (posted) {
 		atomic_add(posted, &rxq->used);



> 
> Steps to reproduce the bug:
> 1. Prepare a Emulex Corporation OneConnect 10Gb NIC.
> 2. Add the kernel param like "swiotlb = force" in /boot/grub/grub.conf .
> 3. Reboot the system. (e.g exec reboot command)
> 4. Activate the interface. (e.g ifconfig eth0 192.168.1.2 up)
> 5. There will be packet drop when ping 192.168.1.2 from another host.
> 
> Signed-off-by: Li Fengmao <li.fengmao@zte.com.cn>
> Signed-off-by: Long Chun <long.chun@zte.com.cn>
> Reviewed-by: Wang Liang <wang.liang82@zte.com.cn>
> Reviewed-by: Cai Qu <cai.qu@zte.com.cn>
> Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>
> 
> --- old/drivers/net/ethernet/emulex/benet/be_main.c	2014-02-20
> 08:49:49.322503588 +0800
> +++ new/drivers/net/ethernet/emulex/benet/be_main.c	2014-02-20
> 08:56:38.796503104 +0800
> @@ -1018,12 +1018,9 @@ get_rx_page_info(struct be_adapter *adap
>  	rx_page_info = &rxo->page_info_tbl[frag_idx];
>  	BUG_ON(!rx_page_info->page);
> 
> -	if (rx_page_info->last_page_user) {
> -		dma_unmap_page(&adapter->pdev->dev,
> -		               dma_unmap_addr(rx_page_info, bus),
> -		               adapter->big_page_size, DMA_FROM_DEVICE);
> -		rx_page_info->last_page_user = false;
> -	}
> +	dma_unmap_page(&adapter->pdev->dev,
> +	               dma_unmap_addr(rx_page_info, bus),
> +	               rx_frag_size, DMA_FROM_DEVICE);
> 
>  	atomic_dec(&rxq->used);
>  	return rx_page_info;
> @@ -1344,20 +1341,15 @@ static void be_post_rx_frags(struct be_r
> 
>  	page_info = &rxo->page_info_tbl[rxq->head];
>  	for (posted = 0; posted < MAX_RX_POST && !page_info->page; posted++) {
> -		if (!pagep) {
> -			pagep = be_alloc_pages(adapter->big_page_size, gfp);
> -			if (unlikely(!pagep)) {
> -				rx_stats(rxo)->rx_post_fail++;
> -				break;
> -			}
> -			page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
> -			                            0, adapter->big_page_size,
> -			                            DMA_FROM_DEVICE);
> -			page_info->page_offset = 0;
> -		} else {
> -			get_page(pagep);
> -			page_info->page_offset = page_offset + rx_frag_size;
> +		pagep = be_alloc_pages(rx_frag_size, gfp);
> +		if (unlikely(!pagep)) {
> +			rx_stats(rxo)->rx_post_fail++;
> +			break;
>  		}
> +		page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
> +		                            0, rx_frag_size,
> +		                            DMA_FROM_DEVICE);
> +		page_info->page_offset = 0;
>  		page_offset = page_info->page_offset;
>  		page_info->page = pagep;
>  		dma_unmap_addr_set(page_info, bus, page_dmaaddr);
> @@ -1367,12 +1359,7 @@ static void be_post_rx_frags(struct be_r
>  		rxd->fragpa_lo = cpu_to_le32(frag_dmaaddr & 0xFFFFFFFF);
>  		rxd->fragpa_hi = cpu_to_le32(upper_32_bits(frag_dmaaddr));
> 
> -		/* Any space left in the current big page for another frag? */
> -		if ((page_offset + rx_frag_size + rx_frag_size) >
> -					adapter->big_page_size) {
> -			pagep = NULL;
> -			page_info->last_page_user = true;
> -		}
> +		pagep = NULL;
> 
>  		prev_page_info = page_info;
>  		queue_head_inc(rxq);
