From: Neil Horman <nhorman@tuxdriver.com>
Subject: [net PATCH] atl1e: fix dma mapping warnings
Date: Fri, 12 Jul 2013 10:58:48 -0400
Message-ID: <1373641128-13634-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52370 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757353Ab3GLO7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 10:59:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently had this backtrace reported:
WARNING: at lib/dma-debug.c:937 check_unmap+0x47d/0x930()
Hardware name: System Product Name
ATL1E 0000:02:00.0: DMA-API: device driver failed to check map error[device
address=0x00000000cbfd1000] [size=90 bytes] [mapped as single]
Modules linked in: xt_conntrack nf_conntrack ebtable_filter ebtables
ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_realtek iTCO_wdt
iTCO_vendor_support snd_hda_intel acpi_cpufreq mperf coretemp btrfs zlib_deflate
snd_hda_codec snd_hwdep microcode raid6_pq libcrc32c snd_seq usblp serio_raw xor
snd_seq_device joydev snd_pcm snd_page_alloc snd_timer snd lpc_ich i2c_i801
soundcore mfd_core atl1e asus_atk0110 ata_generic pata_acpi radeon i2c_algo_bit
drm_kms_helper ttm drm i2c_core pata_marvell uinput
Pid: 314, comm: systemd-journal Not tainted 3.9.0-0.rc6.git2.3.fc19.x86_64 #1
Call Trace:
 <IRQ>  [<ffffffff81069106>] warn_slowpath_common+0x66/0x80
 [<ffffffff8106916c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff8138151d>] check_unmap+0x47d/0x930
 [<ffffffff810ad048>] ? sched_clock_cpu+0xa8/0x100
 [<ffffffff81381a2f>] debug_dma_unmap_page+0x5f/0x70
 [<ffffffff8137ce30>] ? unmap_single+0x20/0x30
 [<ffffffffa01569a1>] atl1e_intr+0x3a1/0x5b0 [atl1e]
 [<ffffffff810d53fd>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff81119636>] handle_irq_event_percpu+0x56/0x390
 [<ffffffff811199ad>] handle_irq_event+0x3d/0x60
 [<ffffffff8111cb6a>] handle_fasteoi_irq+0x5a/0x100
 [<ffffffff8101c36f>] handle_irq+0xbf/0x150
 [<ffffffff811dcb2f>] ? file_sb_list_del+0x3f/0x50
 [<ffffffff81073b10>] ? irq_enter+0x50/0xa0
 [<ffffffff8172738d>] do_IRQ+0x4d/0xc0
 [<ffffffff811dcb2f>] ? file_sb_list_del+0x3f/0x50
 [<ffffffff8171c6b2>] common_interrupt+0x72/0x72
 <EOI>  [<ffffffff810db5b2>] ? lock_release+0xc2/0x310
 [<ffffffff8109ea04>] lg_local_unlock_cpu+0x24/0x50
 [<ffffffff811dcb2f>] file_sb_list_del+0x3f/0x50
 [<ffffffff811dcb6d>] fput+0x2d/0xc0
 [<ffffffff811d8ea1>] filp_close+0x61/0x90
 [<ffffffff811fae4d>] __close_fd+0x8d/0x150
 [<ffffffff811d8ef0>] sys_close+0x20/0x50
 [<ffffffff81725699>] system_call_fastpath+0x16/0x1b

The usual straighforward failure to check for dma_mapping_error after a map
operation is completed.

This patch should fix it, the reporter wandered off after filing this bz:
https://bugzilla.redhat.com/show_bug.cgi?id=954170

and I don't have hardware to test, but the fix is pretty straightforward, so I
figured I'd post it for review.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Jay Cliburn <jcliburn@gmail.com>
CC: Chris Snook <chris.snook@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 26 +++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 895f537..53a725b 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1665,7 +1665,7 @@ check_sum:
 	return 0;
 }
 
-static void atl1e_tx_map(struct atl1e_adapter *adapter,
+static int atl1e_tx_map(struct atl1e_adapter *adapter,
 		      struct sk_buff *skb, struct atl1e_tpd_desc *tpd)
 {
 	struct atl1e_tpd_desc *use_tpd = NULL;
@@ -1677,6 +1677,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 	u16 nr_frags;
 	u16 f;
 	int segment;
+	int ring_start = adapter->tx_ring.next_to_use;
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	segment = (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_MASK;
@@ -1689,6 +1690,9 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 		tx_buffer->length = map_len;
 		tx_buffer->dma = pci_map_single(adapter->pdev,
 					skb->data, hdr_len, PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma))
+			return -ENOSPC;
+
 		ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_SINGLE);
 		mapped_len += map_len;
 		use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
@@ -1715,6 +1719,13 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 		tx_buffer->dma =
 			pci_map_single(adapter->pdev, skb->data + mapped_len,
 					map_len, PCI_DMA_TODEVICE);
+
+		if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma)) {
+			/* Reset the tx rings next pointer */
+			adapter->tx_ring.next_to_use = ring_start;
+			return -ENOSPC;
+		}
+
 		ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_SINGLE);
 		mapped_len  += map_len;
 		use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
@@ -1750,6 +1761,13 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 							  (i * MAX_TX_BUF_LEN),
 							  tx_buffer->length,
 							  DMA_TO_DEVICE);
+
+			if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma)) {
+				/* Reset the ring next to use pointer */
+				adapter->tx_ring.next_to_use = ring_start;
+				return -ENOSPC;
+			}
+
 			ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_PAGE);
 			use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
 			use_tpd->word2 = (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
@@ -1767,6 +1785,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
 	/* The last buffer info contain the skb address,
 	   so it will be free after unmap */
 	tx_buffer->skb = skb;
+	return 0;
 }
 
 static void atl1e_tx_queue(struct atl1e_adapter *adapter, u16 count,
@@ -1834,10 +1853,13 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	atl1e_tx_map(adapter, skb, tpd);
+	if (atl1e_tx_map(adapter, skb, tpd))
+		goto out;
+
 	atl1e_tx_queue(adapter, tpd_req, tpd);
 
 	netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
+out:
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
-- 
1.8.1.4
