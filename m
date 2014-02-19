From: jiang.biao2@zte.com.cn
Subject: [PATCH] be2net: Bugfix for packet drop with kernel param swiotlb=force
Date: Wed, 19 Feb 2014 16:25:40 +0800
Message-ID: <OF433C3BAF.359D84C5-ON48257C84.002D80B1-48257C84.002E4C8C@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	wang.liang82@zte.com.cn, cai.qu@zte.com.cn, li.fengmao@zte.com.cn,
	long.chun@zte.com.cn
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5.zte.com.cn ([63.217.80.70]:33612 "EHLO mx5.zte.com.cn"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbaBSIlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 03:41:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Li Fengmao <li.fengmao@zte.com.cn>

There will be packet drop with kernel param "swiotlb = force" on
Emulex 10Gb NIC using be2net driver. The problem is caused by
receiving skb without calling pci_unmap_page() in get_rx_page_info().
rx_page_info->last_page_user is initialized to false in
be_post_rx_frags() when current frag are mapped in the first half of
the same page with another frag. But in that case with
"swiotlb = force" param, data can not be copied into the page of
rx_page_info without calling pci_unmap_page, so the data frag mapped
in the first half of the page will be dropped.

It can be solved by creating only a mapping relation between frag
and page, and deleting rx_page_info->last_page_user to ensure
calling pci_unmap_page when handling each receiving frag.

Steps to reproduce the bug:
1. Prepare a Emulex Corporation OneConnect 10Gb NIC.
2. Add the kernel param like "swiotlb = force" in /boot/grub/grub.conf .
3. Reboot the system. (e.g exec reboot command)
3. Activate the interface. (e.g ifconfig eth0 192.168.1.2 up)
4. There will be packet drop when ping 192.168.1.2 from another host.

Signed-off-by: Li Fengmao <li.fengmao@zte.com.cn>
Signed-off-by: Long Chun <long.chun@zte.com.cn>
Reviewed-by: Wang Liang <wang.liang82@zte.com.cn>
Reviewed-by: Cai Qu <cai.qu@zte.com.cn>
Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>

--- old/drivers/net/ethernet/emulex/benet/be_main.c	2014-02-18 03:34:15.206388270 -0500
+++ new/drivers/net/ethernet/emulex/benet/be_main.c	2014-02-18 03:44:17.368388223 -0500
@@ -1018,13 +1018,9 @@ get_rx_page_info(struct be_adapter *adap
 	rx_page_info = &rxo->page_info_tbl[frag_idx];
 	BUG_ON(!rx_page_info->page);

-	if (rx_page_info->last_page_user) {
-		dma_unmap_page(&adapter->pdev->dev,
-			       dma_unmap_addr(rx_page_info, bus),
-			       adapter->big_page_size, DMA_FROM_DEVICE);
-		rx_page_info->last_page_user = false;
-	}
-
+        dma_unmap_page(&adapter->pdev->dev,
+               dma_unmap_addr(rx_page_info, bus),
+               rx_frag_size, DMA_FROM_DEVICE);
 	atomic_dec(&rxq->used);
 	return rx_page_info;
 }
@@ -1344,20 +1340,15 @@ static void be_post_rx_frags(struct be_r

 	page_info = &rxo->page_info_tbl[rxq->head];
 	for (posted = 0; posted < MAX_RX_POST && !page_info->page; posted++) {
-		if (!pagep) {
-			pagep = be_alloc_pages(adapter->big_page_size, gfp);
-			if (unlikely(!pagep)) {
-				rx_stats(rxo)->rx_post_fail++;
-				break;
-			}
-			page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
-						    0, adapter->big_page_size,
-						    DMA_FROM_DEVICE);
-			page_info->page_offset = 0;
-		} else {
-			get_page(pagep);
-			page_info->page_offset = page_offset + rx_frag_size;
+		pagep = be_alloc_pages(rx_frag_size, gfp);
+		if (unlikely(!pagep)) {
+			rx_stats(rxo)->rx_post_fail++;
+			break;
 		}
+		page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
+						    0, rx_frag_size,
+						    DMA_FROM_DEVICE);
+		page_info->page_offset = 0;
 		page_offset = page_info->page_offset;
 		page_info->page = pagep;
 		dma_unmap_addr_set(page_info, bus, page_dmaaddr);
@@ -1367,12 +1358,7 @@ static void be_post_rx_frags(struct be_r
 		rxd->fragpa_lo = cpu_to_le32(frag_dmaaddr & 0xFFFFFFFF);
 		rxd->fragpa_hi = cpu_to_le32(upper_32_bits(frag_dmaaddr));

-		/* Any space left in the current big page for another frag? */
-		if ((page_offset + rx_frag_size + rx_frag_size) >
-					adapter->big_page_size) {
-			pagep = NULL;
-			page_info->last_page_user = true;
-		}
+		pagep = NULL;

 		prev_page_info = page_info;
 		queue_head_inc(rxq);
