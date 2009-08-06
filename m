From: Dave Jones <davej@redhat.com>
Subject: 8139cp dma-debug warning.
Date: Thu, 6 Aug 2009 17:57:02 -0400
Message-ID: <20090806215702.GA17555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55533 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbZHFV5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 17:57:06 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n76Lv6Q6016911
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 17:57:06 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n76Lv516031970
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 17:57:06 -0400
Received: from gelk.kernelslacker.org (vpn-10-95.bos.redhat.com [10.16.10.95])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n76Lv28M011187
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 17:57:05 -0400
Received: from gelk.kernelslacker.org (gelk.kernelslacker.org [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n76Lv2pA018416
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 17:57:02 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id n76Lv2Dv018414
	for netdev@vger.kernel.org; Thu, 6 Aug 2009 17:57:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm chasing yet another dma-debug warning where we're unmapping a different
size to what we mapped.

 > WARNING: at lib/dma-debug.c:803 check_unmap+0x1f5/0x509() (Not tainted)
 > Hardware name: 
 > 8139cp 0000:00:03.0: DMA-API: device driver frees DMA memory with different
 > size [device address=0x000000001e9f8852] [map size=1536 bytes] [unmap size=1538
 > bytes]
 > Modules linked in: ipv6 dm_multipath uinput joydev 8139too virtio_balloon
 > 8139cp mii i2c_piix4 virtio_pci i2c_core floppy squashfs pata_acpi ata_generic
 > [last unloaded: scsi_wait_scan]
 > Pid: 0, comm: swapper Not tainted 2.6.31-0.125.rc5.git2.fc12.i686 #1
 > Call Trace:
 >  [<c0444408>] warn_slowpath_common+0x7b/0xa3
 >  [<c0606746>] ? check_unmap+0x1f5/0x509
 >  [<c0444499>] warn_slowpath_fmt+0x34/0x48
 >  [<c0606746>] check_unmap+0x1f5/0x509
 >  [<c04ecb43>] ? check_valid_pointer+0x2c/0x6c
 >  [<c0606c00>] debug_dma_unmap_page+0x62/0x7b
 >  [<e0dc80be>] dma_unmap_single_attrs.clone.2+0x5a/0x75 [8139cp]
 >  [<e0dc8220>] cp_rx_poll+0x147/0x301 [8139cp]
 >  [<c077e5d4>] net_rx_action+0xa7/0x1d3
 >  [<c044accf>] __do_softirq+0xc8/0x192
 >  [<c044ade2>] do_softirq+0x49/0x7f
 >  [<c044af36>] irq_exit+0x48/0x8c
 >  [<c041c302>] smp_apic_timer_interrupt+0x7a/0x99
 >  [<c0404416>] apic_timer_interrupt+0x36/0x3c
 >  [<c0425e98>] ? native_safe_halt+0xa/0xc
 >  [<c040ad6f>] default_idle+0x55/0x98
 >  [<c046e44d>] ? trace_hardirqs_off+0x19/0x2c
 >  [<c04029e3>] cpu_idle+0xac/0xcd
 >  [<c08080ee>] rest_init+0x66/0x79
 >  [<c0a72ae0>] start_kernel+0x36f/0x385
 >  [<c0a7207e>] __init_begin+0x7e/0x96
 > ---[ end trace f3c3298e5df24f15 ]---
 > Mapped at:
 >  [<c0606f6b>] debug_dma_map_page+0x6b/0x13b
 >  [<e0dc7c22>] dma_map_single_attrs.clone.1+0x78/0x93 [8139cp]
 >  [<e0dc86d0>] cp_init_rings+0xaa/0x12c [8139cp]
 >  [<e0dc87d6>] cp_open+0x84/0x154 [8139cp]
 >  [<c077ff2b>] dev_open+0x99/0xe4
 
Looking at 8139cp.c I see this code in cp_rx_poll ..

 552                 buflen = cp->rx_buf_sz + NET_IP_ALIGN;
 553                 new_skb = netdev_alloc_skb(dev, buflen);
 554                 if (!new_skb) {
 555                         dev->stats.rx_dropped++;
 556                         goto rx_next;
 557                 }
 558 
 559                 skb_reserve(new_skb, NET_IP_ALIGN);


Aren't we padding the alignment twice here? or am I missing something?
The warning was a difference of two bytes, which is NET_IP_ALIGN,
so I'm wondering if that skb_reserve line needs to be nuked ?

	Dave

