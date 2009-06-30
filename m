From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/5] e1000: fix unmap bug
Date: Tue, 30 Jun 2009 15:45:34 -0700
Message-ID: <20090630224534.17771.44956.stgit@localhost.localdomain>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:39216
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752569AbZF3Wps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 18:45:48 -0400
In-Reply-To: <20090630224515.17771.76848.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

as reported by kerneloops.org

[  121.781161] ------------[ cut here ]------------
[  121.781171] WARNING: at lib/dma-debug.c:793 check_unmap+0x14e/0x577()
[  121.781173] Hardware name: S5520HC
[  121.781177] e1000 0000:0a:00.0: DMA-API: device driver tries to free DMA
memory it has not allocated [device address=0x00000001d688b0fa] [size=1522
bytes]
[  121.781180] Modules linked in: e1000 mdio  dca [last unloaded: ixgbe]
[  121.781187] Pid: 4793, comm: bash Tainted: P 2.6.30-master-06161113 #3
[  121.781190] Call Trace:
[  121.781195]  [<ffffffff8123056f>] ? check_unmap+0x14e/0x577
[  121.781201]  [<ffffffff81057a19>] warn_slowpath_common+0x77/0x8f
[  121.781205]  [<ffffffff81057ae1>] warn_slowpath_fmt+0x9f/0xa1
[  121.781212]  [<ffffffff81477ce2>] ? _spin_lock_irqsave+0x3f/0x49
[  121.781216]  [<ffffffff8122fa97>] ? get_hash_bucket+0x28/0x33
[  121.781220]  [<ffffffff8123056f>] check_unmap+0x14e/0x577
[  121.781225]  [<ffffffff810e4f48>] ? check_bytes_and_report+0x38/0xcb
[  121.781230]  [<ffffffff81230bbf>] debug_dma_unmap_page+0x80/0x92
[  121.781234]  [<ffffffff8122e549>] ? unmap_single+0x1a/0x4e
[  121.781239]  [<ffffffff813901e1>] ? __kfree_skb+0x74/0x78
[  121.781250]  [<ffffffffa00662ef>] pci_unmap_single+0x64/0x6d [e1000]
[  121.781259]  [<ffffffffa0066344>] e1000_clean_rx_ring+0x4c/0xbf [e1000]
[  121.781268]  [<ffffffffa00663df>] e1000_clean_all_rx_rings+0x28/0x36 [e1000]
[  121.781277]  [<ffffffffa0067464>] e1000_down+0x138/0x141 [e1000]
[  121.781286]  [<ffffffffa00681c2>] __e1000_shutdown+0x6b/0x198 [e1000]
[  121.781296]  [<ffffffffa0068405>] e1000_suspend+0x17/0x50 [e1000]
[  121.781301]  [<ffffffff81237665>] pci_legacy_suspend+0x3b/0xbe
[  121.781305]  [<ffffffff81237bc6>] pci_pm_suspend+0x3e/0xf1
[  121.781310]  [<ffffffff812eaf1c>] pm_op+0x57/0xde
[  121.781314]  [<ffffffff812eb444>] dpm_suspend_start+0x31e/0x470
[  121.781319]  [<ffffffff810877da>] suspend_devices_and_enter+0x3e/0x1a2
[  121.781323]  [<ffffffff81087a0f>] enter_state+0xd1/0x127
[  121.781327]  [<ffffffff8108717a>] state_store+0xa7/0xc9
[  121.781332]  [<ffffffff81221843>] kobj_attr_store+0x17/0x19
[  121.781336]  [<ffffffff8113c01e>] sysfs_write_file+0xe5/0x121
[  121.781341]  [<ffffffff810ed165>] vfs_write+0xab/0x105
[  121.781344]  [<ffffffff810ed279>] sys_write+0x47/0x6d
[  121.781349]  [<ffffffff81027aab>] system_call_fastpath+0x16/0x1b
[  121.781352] ---[ end trace 97bacaaac2ed7786 ]---

Fix is to correctly zero out internal ->dma value when unmapping
and make sure never to unmap unless there specifically was a mapping done.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5e3356f..972e06d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2185,12 +2185,16 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->skb) {
+		if (buffer_info->dma) {
 			pci_unmap_single(pdev,
 					 buffer_info->dma,
 					 buffer_info->length,
 					 PCI_DMA_FROMDEVICE);
+		}
 
+		buffer_info->dma = 0;
+
+		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
@@ -4033,6 +4037,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		                 buffer_info->dma,
 		                 buffer_info->length,
 		                 PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
 		/* !EOP means multiple descriptors were used to store a single
@@ -4222,6 +4227,7 @@ map_skb:
 			pci_unmap_single(pdev, buffer_info->dma,
 					 adapter->rx_buffer_len,
 					 PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
 
 			break; /* while !buffer_info->skb */
 		}

