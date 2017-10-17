From: <netanel@amazon.com>
Subject: [PATCH net 2/3] net: ena: fix rare kernel crash when bar memory remap fails
Date: Tue, 17 Oct 2017 07:33:04 +0000
Message-ID: <1508225585-106167-3-git-send-email-netanel@amazon.com>
References: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:22711 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932887AbdJQHdW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:33:22 -0400
In-Reply-To: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

This failure is rare and only found on testing where deliberately fail
devm_ioremap()

[  451.170464] ena 0000:04:00.0: failed to remap regs bar
451.170549] Workqueue: pciehp-1 pciehp_power_thread
[  451.170551] task: ffff88085a5f2d00 task.stack: ffffc9000756c000
[  451.170552] RIP: 0010:devm_iounmap+0x2d/0x40
[  451.170553] RSP: 0018:ffffc9000756fac0 EFLAGS: 00010282
[  451.170554] RAX: 00000000fffffffe RBX: 0000000000000000 RCX:
0000000000000000
[  451.170555] RDX: ffffffff813a7e00 RSI: 0000000000000282 RDI:
0000000000000282
[  451.170556] RBP: ffffc9000756fac8 R08: 00000000fffffffe R09:
00000000000009b7
[  451.170557] R10: 0000000000000005 R11: 00000000000009b6 R12:
ffff880856c9d0a0
[  451.170558] R13: ffffc9000f5c90c0 R14: ffff880856c9d0a0 R15:
0000000000000028
[  451.170559] FS:  0000000000000000(0000) GS:ffff88085f400000(0000)
knlGS:0000000000000000
[  451.170560] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  451.170561] CR2: 00007f169038b000 CR3: 0000000001c09000 CR4:
00000000003406f0
[  451.170562] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[  451.170562] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
[  451.170563] Call Trace:
[  451.170572]  ena_release_bars.isra.48+0x34/0x60 [ena]
[  451.170574]  ena_probe+0x144/0xd90 [ena]
[  451.170579]  ? ida_simple_get+0x98/0x100
[  451.170585]  ? kernfs_next_descendant_post+0x40/0x50
[  451.170591]  local_pci_probe+0x45/0xa0
[  451.170592]  pci_device_probe+0x157/0x180
[  451.170599]  driver_probe_device+0x2a8/0x460
[  451.170600]  __device_attach_driver+0x7e/0xe0
[  451.170602]  ? driver_allows_async_probing+0x30/0x30
[  451.170603]  bus_for_each_drv+0x68/0xb0
[  451.170605]  __device_attach+0xdd/0x160
[  451.170607]  device_attach+0x10/0x20
[  451.170610]  pci_bus_add_device+0x4f/0xa0
[  451.170611]  pci_bus_add_devices+0x39/0x70
[  451.170613]  pciehp_configure_device+0x96/0x120
[  451.170614]  pciehp_enable_slot+0x1b3/0x290
[  451.170616]  pciehp_power_thread+0x3b/0xb0
[  451.170622]  process_one_work+0x149/0x360
[  451.170623]  worker_thread+0x4d/0x3c0
[  451.170626]  kthread+0x109/0x140
[  451.170627]  ? rescuer_thread+0x380/0x380
[  451.170628]  ? kthread_park+0x60/0x60
[  451.170632]  ret_from_fork+0x25/0x30

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 7040b9052747..c6bd5e24005d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3064,7 +3064,8 @@ static void ena_release_bars(struct ena_com_dev *ena_dev, struct pci_dev *pdev)
 	if (ena_dev->mem_bar)
 		devm_iounmap(&pdev->dev, ena_dev->mem_bar);
 
-	devm_iounmap(&pdev->dev, ena_dev->reg_bar);
+	if (ena_dev->reg_bar)
+		devm_iounmap(&pdev->dev, ena_dev->reg_bar);
 
 	release_bars = pci_select_bars(pdev, IORESOURCE_MEM) & ENA_BAR_MASK;
 	pci_release_selected_regions(pdev, release_bars);
-- 
1.8.3.1
