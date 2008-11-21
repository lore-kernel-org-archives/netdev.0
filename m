From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 17:26:00 +0100
Message-ID: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-va3.frontbridge.com ([216.32.180.16]:3674 "EHLO
	VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756253AbYKUQ0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:26:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patchset introduces code to debug drivers usage of the DMA-API.
Tests with hardware IOMMUs have shown several bugs in drivers regarding
the usage of that API.
Problems were found especially in network card drivers.

These bugs often don't show up or have any negative impact if there is
no hardware IOMMU in use in the system. But with an hardware IOMMU these
bugs turn the hardware unusable or, in the worst case, cause data
corruption on devices which are managed by other (good) drivers.

With the code these patches introduce driver developers can find several
bugs of misusing the DMA-API in their drivers. But be aware, it can not
find all possible bugs. If it finds a problem it prints out messages
like

tg3 0000:08:04.0: PCI-DMA: device driver tries to free DMA memory it has not allocated [device address=0x000000042f0f3ae7] [size=48 bytes]
Pid: 6285, comm: bash Not tainted 2.6.28-rc5-00176-g6ae6379-dirty #6
Call Trace:
 <IRQ>  [<ffffffff80221276>] check_unmap+0x52/0x1ce
 [<ffffffff80221af0>] debug_unmap_single+0x61/0xa4
 [<ffffffff8053d396>] skb_dma_unmap+0xf2/0x10c
 [<ffffffff8040a986>] tg3_poll+0xe8/0x822
 [<ffffffff803abe2f>] mix_pool_bytes_extract+0x5c/0x155
 [<ffffffff80540e42>] net_rx_action+0x9d/0x170
 [<ffffffff8023bc3c>] __do_softirq+0x7a/0x13d
 [<ffffffff8020c3cc>] call_softirq+0x1c/0x28
 [<ffffffff8020d8ac>] do_softirq+0x2c/0x68
 [<ffffffff8023bb7c>] irq_exit+0x3f/0x85
 [<ffffffff8020db5e>] do_IRQ+0x14d/0x16f
 [<ffffffff8020b686>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff80368187>] memcmp+0xb/0x22
 [<ffffffff8029f11e>] __d_lookup+0xb9/0xf9
 [<ffffffff80298166>] do_lookup+0x2a/0x1c1
 [<ffffffff8029979f>] __link_path_walk+0x331/0xc0d
 [<ffffffff8029a0c1>] path_walk+0x46/0x8b
 [<ffffffff8029a245>] do_path_lookup+0xff/0x121
 [<ffffffff8029ad2d>] path_lookup_open+0x54/0x95
 [<ffffffff8029af7c>] do_filp_open+0x9d/0x782
 [<ffffffff802a234e>] alloc_fd+0x69/0x10c
 [<ffffffff8028fda9>] do_sys_open+0x48/0xcc
 [<ffffffff8020b17b>] system_call_fastpath+0x16/0x1b

or (from another machine with AMD IOMMU):

ixgbe 0000:02:00.0: PCI-DMA: device driver frees DMA memory with different size [device address=0x0000000003fed812] [map size=258 bytes] [unmap size=256 bytes]
Pid: 6178, comm: rmmod Not tainted 2.6.28-rc5 #4
Call Trace:
 [<ffffffff8022a2ae>] iommu_queue_inv_iommu_pages+0x5e/0x70
 [<ffffffff80225956>] check_unmap+0x1c6/0x240
 [<ffffffff80225ff5>] debug_unmap_single+0xb5/0x110
 [<ffffffffa0213997>] ixgbe_clean_rx_ring+0x147/0x220
 [<ffffffffa0214d7d>] ixgbe_down+0x2fd/0x3d0 [ixgbe]
 [<ffffffffa02150b3>] ixgbe_close+0x13/0xc0 [ixgbe]
 [<ffffffff80431326>] dev_close+0x56/0xa0
 [<ffffffff804313b3>] rollback_registered+0x43/0x220
 [<ffffffff804315a5>] unregister_netdevice+0x15/0x60
 [<ffffffff80431601>] unregister_netdev+0x11/0x20
 [<ffffffffa021aef8>] ixgbe_remove+0x48/0x16e [ixgbe]
 [<ffffffff80386ffc>] pci_device_remove+0x2c/0x60
 [<ffffffff803ef929>] __device_release_driver+0x99/0x100
 [<ffffffff803efa48>] driver_detach+0xb8/0xc0
 [<ffffffff803eea6e>] bus_remove_driver+0x8e/0xd0
 [<ffffffff80387374>] pci_unregister_driver+0x34/0x90
 [<ffffffff8026c6c7>] sys_delete_module+0x1c7/0x2a0
 [<ffffffff802a9ce9>] do_munmap+0x349/0x390
 [<ffffffff80374481>] __up_write+0x21/0x150
 [<ffffffff8020c30b>] system_call_fastpath+0x16/0x1b

This way driver developers get an idea where the problem is in their
code.

Please review and send any objections or, if there are none, consider
for inclusion ;)

Thanks,

Joerg



