From: Dave Jones <davej@redhat.com>
Subject: Re: r8169: DMA-API: exceeded 7 overlapping mappings of pfn 943ad
Date: Tue, 11 Feb 2014 18:33:07 -0500
Message-ID: <20140211233307.GA10472@redhat.com>
References: <20140130160113.GA18779@redhat.com>
 <20140130210802.GA3373@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dan.j.williams@intel.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbaBKXdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 18:33:20 -0500
Content-Disposition: inline
In-Reply-To: <20140130210802.GA3373@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 10:08:02PM +0100, Francois Romieu wrote:
 > Dave Jones <davej@redhat.com> :
 > > WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
 > > DMA-API: exceeded 7 overlapping mappings of pfn 943ad
 > > Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_defrag_ipv4 xt_conntrack nf_conntrack ip6table_filter ip6_tables crc32c_intel ghash_clmulni_intel microcode pcspkr r8169 mii nfsd auth_rpcgss nfs_acl lockd sunrpc i915 i2c_algo_bit drm_kms_helper drm video backlight
 > > CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0+ #10
 > 
 > Was 59f2e7df574c78e952d79435de3f4867349403aa included in the run ?

fyi, still seeing this in .14rc2.

It happens shortly after boot, and seems quite reproducable for me..

/var/log/messages-20140202:Jan 30 10:48:08 firewall kernel: [30254.316836] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
/var/log/messages-20140202:Jan 31 10:42:09 firewall kernel: [ 2333.196185] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
/var/log/messages-20140202:Feb  2 01:40:26 firewall kernel: [  164.305284] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
/var/log/messages-20140209:Feb  7 17:26:06 firewall kernel: [  422.596431] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()

As the hostname suggests, this box is forwarding packets between two 8169s.

(Added Dan to cc in case this is another dma-debug regression, full trace below for his benefit)

	Dave

[  676.433089] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x127/0x130()
[  676.433177] DMA-API: exceeded 7 overlapping mappings of pfn 84
[  676.433243] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter nf_conntrack_ipv4 ip6_tables nf_defrag_ipv4 xt_conntrack nf_conntrack crc32c_intel ghash_clmulni_intel microcode pcspkr r8169 mii nfsd auth_rpcgss nfs_acl lockd sunrpc i915 i2c_algo_bit drm_kms_helper drm video backlight
[  676.433729] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.0-rc2+ #17 
[  676.433842] Hardware name: Shuttle Inc. SH87R/FH87, BIOS 1.02 06/26/2013
[  676.433917]  0000000000000009 a926658692479a32 ffff88013ac03910 ffffffff8157b0d8
[  676.434015]  ffff88013ac03958 ffff88013ac03948 ffffffff8105c313 0000000000000084
[  676.434110]  ffff8800b190bc70 0000000000000286 ffffffff828a0180 0000000000000286
[  676.434205] Call Trace:
[  676.434234]  <IRQ>  [<ffffffff8157b0d8>] dump_stack+0x4d/0x66
[  676.434320]  [<ffffffff8105c313>] warn_slowpath_common+0x73/0x90
[  676.434391]  [<ffffffff8105c387>] warn_slowpath_fmt+0x57/0x80
[  676.434460]  [<ffffffff812c029d>] ? active_pfn_read_overlap+0x2d/0x50
[  676.434535]  [<ffffffff812c0867>] add_dma_entry+0x127/0x130
[  676.434601]  [<ffffffff812c0b9a>] debug_dma_map_page+0x11a/0x140
[  676.434679]  [<ffffffffa01ebaae>] rtl8169_start_xmit+0x1fe/0xac0 [r8169]
[  676.434761]  [<ffffffff810a81af>] ? lock_release_holdtime.part.30+0xf/0x190
[  676.439701]  [<ffffffff8146c3b0>] ? dev_queue_xmit_nit+0x170/0x3d0
[  676.444647]  [<ffffffff8146e65b>] dev_hard_start_xmit+0x2cb/0x4c0
[  676.449593]  [<ffffffff8148f39e>] sch_direct_xmit+0xee/0x280
[  676.454537]  [<ffffffff8146ea50>] __dev_queue_xmit+0x200/0x770
[  676.459320]  [<ffffffff8146e850>] ? dev_hard_start_xmit+0x4c0/0x4c0
[  676.463946]  [<ffffffff8146efcb>] dev_queue_xmit+0xb/0x10
[  676.468409]  [<ffffffff8147a0ea>] neigh_resolve_output+0x17a/0x2e0
[  676.472827]  [<ffffffff814a97b0>] ? ip_finish_output+0x3f0/0x8e0
[  676.477191]  [<ffffffff814a97b0>] ip_finish_output+0x3f0/0x8e0
[  676.481493]  [<ffffffff814a9626>] ? ip_finish_output+0x266/0x8e0
[  676.485744]  [<ffffffff814ab3e7>] ip_output+0x57/0xf0
[  676.489926]  [<ffffffff814a60e1>] ip_forward_finish+0x71/0x1c0
[  676.494055]  [<ffffffff814a6443>] ip_forward+0x213/0x590
[  676.498113]  [<ffffffff814a3ff0>] ip_rcv_finish+0x140/0x570
[  676.502112]  [<ffffffff814a4974>] ip_rcv+0x294/0x3d0
[  676.506040]  [<ffffffff8146ba62>] __netif_receive_skb_core+0x762/0x960
[  676.509937]  [<ffffffff8146b43d>] ? __netif_receive_skb_core+0x13d/0x960
[  676.513783]  [<ffffffff810aad3d>] ? trace_hardirqs_on+0xd/0x10
[  676.517570]  [<ffffffff8146bc73>] __netif_receive_skb+0x13/0x60
[  676.521299]  [<ffffffff8146bced>] netif_receive_skb_internal+0x2d/0x210
[  676.524981]  [<ffffffff8146da28>] napi_gro_receive+0x58/0x80
[  676.528606]  [<ffffffffa01ec4d6>] rtl8169_poll+0x166/0x700 [r8169]
[  676.532180]  [<ffffffff8146c7f9>] net_rx_action+0x129/0x1e0
[  676.535694]  [<ffffffff81060e8c>] __do_softirq+0x11c/0x2a0
[  676.539229]  [<ffffffff8106134d>] irq_exit+0x11d/0x140
[  676.542699]  [<ffffffff810043e3>] do_IRQ+0x53/0xf0
[  676.546183]  [<ffffffff81583def>] common_interrupt+0x6f/0x6f
[  676.549692]  <EOI>  [<ffffffff8142d31f>] ? cpuidle_enter_state+0x4f/0xc0
[  676.553275]  [<ffffffff8142d31b>] ? cpuidle_enter_state+0x4b/0xc0
[  676.556803]  [<ffffffff8142d426>] cpuidle_idle_call+0x96/0x140
[  676.560276]  [<ffffffff8100b949>] arch_cpu_idle+0x9/0x30
[  676.563769]  [<ffffffff810b504a>] cpu_startup_entry+0xea/0x220
[  676.567211]  [<ffffffff81572a43>] rest_init+0x133/0x140
[  676.570589]  [<ffffffff81572910>] ? csum_partial_copy_generic+0x170/0x170
[  676.574017]  [<ffffffff81c78e6c>] start_kernel+0x41f/0x440
[  676.577382]  [<ffffffff81c78856>] ? repair_env_string+0x5c/0x5c
[  676.580692]  [<ffffffff81c78571>] x86_64_start_reservations+0x2a/0x2c
[  676.584036]  [<ffffffff81c7863a>] x86_64_start_kernel+0xc7/0xca
[  676.587390] ---[ end trace 6c6ab4309da33850 ]---
