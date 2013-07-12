From: Neil Horman <nhorman@tuxdriver.com>
Subject: [net PATCH] via-rhine: fix dma mapping errors
Date: Fri, 12 Jul 2013 13:35:33 -0400
Message-ID: <1373650533-20269-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Roger Luethi <rl@hellgate.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54510 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932813Ab3GLRgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 13:36:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this bug:
https://bugzilla.redhat.com/show_bug.cgi?id=951695

Reported a dma debug backtrace:

WARNING: at lib/dma-debug.c:937 check_unmap+0x47d/0x930()
Hardware name: To Be Filled By O.E.M.
via-rhine 0000:00:12.0: DMA-API: device driver failed to check map error[device
address=0x0000000075a837b2] [size=90 bytes] [mapped as single]
Modules linked in: ip6_tables gspca_spca561 gspca_main videodev media
snd_hda_codec_realtek snd_hda_intel i2c_viapro snd_hda_codec snd_hwdep snd_seq
ppdev mperf via_rhine coretemp snd_pcm mii microcode snd_page_alloc snd_timer
snd_mpu401 snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcore parport_pc
parport shpchp ata_generic pata_acpi radeon i2c_algo_bit drm_kms_helper ttm drm
pata_via sata_via i2c_core uinput
Pid: 295, comm: systemd-journal Not tainted 3.9.0-0.rc6.git2.1.fc20.x86_64 #1
Call Trace:
 <IRQ>  [<ffffffff81068dd0>] warn_slowpath_common+0x70/0xa0
 [<ffffffff81068e4c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff8137ec6d>] check_unmap+0x47d/0x930
 [<ffffffff810ace9f>] ? local_clock+0x5f/0x70
 [<ffffffff8137f17f>] debug_dma_unmap_page+0x5f/0x70
 [<ffffffffa0225edc>] ? rhine_ack_events.isra.14+0x3c/0x50 [via_rhine]
 [<ffffffffa02275f8>] rhine_napipoll+0x1d8/0xd80 [via_rhine]
 [<ffffffff815d3d51>] ? net_rx_action+0xa1/0x380
 [<ffffffff815d3e22>] net_rx_action+0x172/0x380
 [<ffffffff8107345f>] __do_softirq+0xff/0x400
 [<ffffffff81073925>] irq_exit+0xb5/0xc0
 [<ffffffff81724cd6>] do_IRQ+0x56/0xc0
 [<ffffffff81719ff2>] common_interrupt+0x72/0x72
 <EOI>  [<ffffffff8170ff57>] ? __slab_alloc+0x4c2/0x526
 [<ffffffff811992e0>] ? mmap_region+0x2b0/0x5a0
 [<ffffffff810d5807>] ? __lock_is_held+0x57/0x80
 [<ffffffff811992e0>] ? mmap_region+0x2b0/0x5a0
 [<ffffffff811bf1bf>] kmem_cache_alloc+0x2df/0x360
 [<ffffffff811992e0>] mmap_region+0x2b0/0x5a0
 [<ffffffff811998e6>] do_mmap_pgoff+0x316/0x3d0
 [<ffffffff81183ca0>] vm_mmap_pgoff+0x90/0xc0
 [<ffffffff81197d6c>] sys_mmap_pgoff+0x4c/0x190
 [<ffffffff81367d7e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8101eb42>] sys_mmap+0x22/0x30
 [<ffffffff81722fd9>] system_call_fastpath+0x16/0x1b

Usual problem with the usual fix, add the appropriate calls to dma_mapping_error
where appropriate

Untested, as I don't have hardware, but its pretty straightforward

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: David S. Miller <davem@davemloft.net>
CC: Roger Luethi <rl@hellgate.ch>
---
 drivers/net/ethernet/via/via-rhine.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index ca98aca..b75eb9e 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1171,7 +1171,11 @@ static void alloc_rbufs(struct net_device *dev)
 		rp->rx_skbuff_dma[i] =
 			pci_map_single(rp->pdev, skb->data, rp->rx_buf_sz,
 				       PCI_DMA_FROMDEVICE);
-
+		if (dma_mapping_error(&rp->pdev->dev, rp->rx_skbuff_dma[i])) {
+			rp->rx_skbuff_dma[i] = 0;
+			dev_kfree_skb(skb);
+			break;
+		}
 		rp->rx_ring[i].addr = cpu_to_le32(rp->rx_skbuff_dma[i]);
 		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
 	}
@@ -1687,6 +1691,12 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 		rp->tx_skbuff_dma[entry] =
 			pci_map_single(rp->pdev, skb->data, skb->len,
 				       PCI_DMA_TODEVICE);
+		if (dma_mapping_error(&rp->pdev->dev, rp->tx_skbuff_dma[entry])) {
+			dev_kfree_skb(skb);
+			rp->tx_skbuff_dma[entry] = 0;
+			dev->stats.tx_dropped++;
+			return NETDEV_TX_OK;
+		}
 		rp->tx_ring[entry].addr = cpu_to_le32(rp->tx_skbuff_dma[entry]);
 	}
 
@@ -1961,6 +1971,11 @@ static int rhine_rx(struct net_device *dev, int limit)
 				pci_map_single(rp->pdev, skb->data,
 					       rp->rx_buf_sz,
 					       PCI_DMA_FROMDEVICE);
+			if (dma_mapping_error(&rp->pdev->dev, rp->rx_skbuff_dma[entry])) {
+				dev_kfree_skb(skb);
+				rp->rx_skbuff_dma[entry] = 0;
+				break;
+			}
 			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
 		}
 		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
-- 
1.8.1.4
