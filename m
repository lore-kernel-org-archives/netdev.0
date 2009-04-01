From: Dave Jones <davej@redhat.com>
Subject: More fun with dma debugging: 8139cp frees DMA memory with
	different size
Date: Wed, 1 Apr 2009 11:18:51 -0400
Message-ID: <20090401151851.GA19496@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54757 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932906AbZDAPSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 11:18:54 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n31FIrQM011621
	for <netdev@vger.kernel.org>; Wed, 1 Apr 2009 11:18:53 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n31FIraF020598
	for <netdev@vger.kernel.org>; Wed, 1 Apr 2009 11:18:53 -0400
Received: from localhost.localdomain (vpn-10-62.bos.redhat.com [10.16.10.62])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n31FIqAm011350
	for <netdev@vger.kernel.org>; Wed, 1 Apr 2009 11:18:52 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by localhost.localdomain (8.14.3/8.14.3) with ESMTP id n31FIpXv024986
	for <netdev@vger.kernel.org>; Wed, 1 Apr 2009 11:18:51 -0400
Received: (from davej@localhost)
	by localhost.localdomain (8.14.3/8.14.3/Submit) id n31FIpjv024984
	for netdev@vger.kernel.org; Wed, 1 Apr 2009 11:18:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user reported this..

 > Feb 19 14:24:58 rawhide kernel: ------------[ cut here ]------------
 > Feb 19 14:24:58 rawhide kernel: WARNING: at lib/dma-debug.c:439 check_unmap+0x16a/0x3dd() (Not tainted)
 > Feb 19 14:24:58 rawhide kernel: Hardware name:
 > Feb 19 14:24:58 rawhide kernel: 8139cp 0000:00:03.0: DMA-API: device driver frees DMA memory with different size [device address=0x000000000f74e1c2] [map size=1536 bytes] [unmap size=1538 bytes]
 > Feb 19 14:24:58 rawhide kernel: Modules linked in: sunrpc ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath virtio_balloon pcspkr virtio_pci 8139too virtio_ring 8139cp i2c_piix4 virtio mii i2c_core [last unloaded: freq_table]
 > Feb 19 14:24:58 rawhide kernel: Pid: 0, comm: swapper Not tainted 2.6.29-0.124.rc5.fc11.x86_64 #1
 > Feb 19 14:24:58 rawhide kernel: Call Trace:
 > Feb 19 14:24:58 rawhide kernel: <IRQ>  [<ffffffff810488f6>] warn_slowpath+0xb7/0xe7
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8106934c>] ? graph_unlock+0x6b/0x77
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8106c9d5>] ? __lock_acquire+0xb67/0xc0d
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81029c00>] ? pvclock_tsc_khz+0x8/0x2d
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8137bd9f>] ? _spin_lock_irqsave+0x78/0x86
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff811985eb>] ? get_hash_bucket+0x28/0x34
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8106b139>] ? mark_lock+0x28/0x37f
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81198ae5>] check_unmap+0x16a/0x3dd
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8106b6d3>] ? trace_hardirqs_on_caller+0x118/0x153
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81198ea5>] debug_dma_unmap_page+0x50/0x52
 > Feb 19 14:24:58 rawhide kernel: [<ffffffffa001c19a>] dma_unmap_single+0x67/0x70 [8139cp]
 > Feb 19 14:24:58 rawhide kernel: [<ffffffffa001d587>] cp_rx_poll+0x16c/0x329 [8139cp]
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff812e1631>] net_rx_action+0xb1/0x1e9
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff812e1720>] ? net_rx_action+0x1a0/0x1e9
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8104de7c>] __do_softirq+0x8f/0x173
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff810126ac>] call_softirq+0x1c/0x30
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81013799>] do_softirq+0x4d/0xb4
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8104dac7>] irq_exit+0x4e/0x8b
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81013aa8>] do_IRQ+0x127/0x14b
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81011d93>] ret_from_intr+0x0/0x2e
 > Feb 19 14:24:58 rawhide kernel: <EOI>  [<ffffffff8102927a>] ? native_safe_halt+0x6/0x8
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8106b71b>] ? trace_hardirqs_on+0xd/0xf
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81017a5f>] ? default_idle+0x4c/0x77
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8137ee0c>] ? atomic_notifier_call_chain+0xf/0x11
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff810101db>] ? enter_idle+0x22/0x24
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff81010240>] ? cpu_idle+0x63/0xae
 > Feb 19 14:24:58 rawhide kernel: [<ffffffff8136719d>] ? rest_init+0x61/0x63
 > Feb 19 14:24:58 rawhide kernel: ---[ end trace 6089c83d46ba2fbd ]---

My guess is that we're mapping skb->len, but unmapping skb->len + NET_IP_ALIGN
I don't have hardware to test this, does the patch below make sense ?

	Dave

DMA debugging catches a mismatched DMA alloc/free size.

8139cp 0000:00:03.0: DMA-API: device driver frees DMA memory with different size
 [device address=0x000000000f74e1c2] [map size=1536 bytes] [unmap size=1538 bytes]

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a09e3a7..a4b4491 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1065,7 +1065,8 @@ static int cp_refill_rx(struct cp_private *cp)
 		skb_reserve(skb, NET_IP_ALIGN);
 
 		mapping = dma_map_single(&cp->pdev->dev, skb->data,
-					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+					 cp->rx_buf_sz + NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
 		cp->rx_skb[i] = skb;
 
 		cp->rx_ring[i].opts2 = 0;
