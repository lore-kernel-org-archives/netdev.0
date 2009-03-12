From: Dave Jones <davej@redhat.com>
Subject: VIA velocity skb leak.
Date: Thu, 12 Mar 2009 00:13:52 -0400
Message-ID: <20090312041352.GA6035@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45786 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbZCLEN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 00:13:57 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2C4DsFO031571
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 00:13:56 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n2C4Dss1017989
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 00:13:54 -0400
Received: from gelk.kernelslacker.org (vpn-12-95.rdu.redhat.com [10.11.12.95])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n2C4DrHR011501
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 00:13:54 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n2C4Dq5b007106
	for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 00:13:52 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id n2C4Dqnf007103
	for netdev@vger.kernel.org; Thu, 12 Mar 2009 00:13:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I've found a bug in the via-velocity driver, but I'm not
sure how to fix it.
We've been carrying some debug patches in the Fedora kernel that
dwmw2 wrote, which do some sanity checks on dma allocations.
Velocity triggered this trace..

[  324.777540] ------------[ cut here ]------------
[  324.777559] WARNING: at lib/dma-debug.c:470 check_unmap+0x196/0x3e4() (Not tainted)
[  324.777575] Hardware name:  
[  324.777591] via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x000000001a4c8ca2] [map size=60 bytes] [unmap size=54 bytes]
[  324.777614] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_LOG xt_limit sunrpc nf_conntrack_netbios_ns ip6t_REJECT ip6table_filter ip6_tables ipv6 cpufreq_ondemand serio_raw usb_storage pcspkr i2c_viapro 3c59x mii i2c_core firewire_ohci via_velocity firewire_core crc_ccitt crc_itu_t ata_generic pata_acpi pata_via ext2 [last unloaded: scsi_wait_scan]
[  324.777792] Pid: 0, comm: swapper Not tainted 2.6.29-0.179.rc6.git5.fc11.i686.PAE #1
[  324.777807] Call Trace:
[  324.777839]  [<c0437a9f>] warn_slowpath+0x7c/0xa7
[  324.777870]  [<c0701800>] ? _spin_unlock_irq+0x1c/0x34
[  324.777899]  [<c042ae55>] ? account_group_exec_runtime+0x4d/0x54
[  324.777929]  [<c045783c>] ? mark_lock+0x1e/0x30b
[  324.777952]  [<c045783c>] ? mark_lock+0x1e/0x30b
[  324.777973]  [<c0554765>] ? get_hash_bucket+0x26/0x2f
[  324.777995]  [<c0554fc3>] check_unmap+0x196/0x3e4
[  324.778021]  [<c040de4d>] ? sched_clock+0x9/0xd
[  324.778042]  [<c05553bf>] debug_dma_unmap_page+0x68/0x70
[  324.778064]  [<c05553bf>] ? debug_dma_unmap_page+0x68/0x70
[  324.778111]  [<dcfc251c>] pci_unmap_single+0x65/0x70 [via_velocity]
[  324.778148]  [<dcfc25f5>] velocity_tx_srv+0xce/0x183 [via_velocity]
[  324.778188]  [<dcfc39a7>] velocity_intr+0x52f/0x594 [via_velocity]
[  324.778211]  [<c0457023>] ? trace_hardirqs_off+0xb/0xd
[  324.778232]  [<c067d15d>] ? netif_rx+0x9d/0x11a
[  324.778277]  [<dc861f8e>] ? boomerang_interrupt+0x324/0x331 [3c59x]
[  324.778300]  [<c045783c>] ? mark_lock+0x1e/0x30b
[  324.778330]  [<c047a6a4>] ? handle_fasteoi_irq+0x76/0xb7
[  324.778351]  [<c04566d8>] ? lock_release_holdtime+0x2b/0x123
[  324.778374]  [<c0479284>] handle_IRQ_event+0x22/0x58
[  324.778394]  [<c0479284>] ? handle_IRQ_event+0x22/0x58
[  324.778417]  [<c047a6ae>] handle_fasteoi_irq+0x80/0xb7
[  324.778437]  [<c047a62e>] ? handle_fasteoi_irq+0x0/0xb7
[  324.778450]  <IRQ>  [<c0409cac>] ? common_interrupt+0x2c/0x34
[  324.778490]  [<c0457d78>] ? trace_hardirqs_on+0xb/0xd
[  324.778501]  [<c059fcca>] ? acpi_idle_enter_simple+0x13a/0x179
[  324.778501]  [<c059f9b4>] ? acpi_idle_enter_bm+0xd1/0x2ad
[  324.778501]  [<c0660105>] ? menu_select+0x3d/0xa4
[  324.778501]  [<c065f670>] ? cpuidle_idle_call+0x65/0x9d
[  324.778501]  [<c065f670>] ? cpuidle_idle_call+0x65/0x9d
[  324.778501]  [<c040871e>] ? cpu_idle+0x72/0x90
[  324.778501]  [<c06efa03>] ? rest_init+0x53/0x55
[  324.778501] ---[ end trace 57ea7e11ea46a364 ]---


It looks like in velocity_xmit we do the skb_padto because the length is below
the minimum frame size (56 bytes) and pci_map the resulting 60 byte skb.
But later, when we free it, we forget that we did that size adjustment.
Does skb_padto adjust the skb->len somewhere, or is this responsibility of the caller?

	Dave

-- 
http://www.codemonkey.org.uk
