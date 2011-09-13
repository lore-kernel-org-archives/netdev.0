From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ixgbe: drop zero length frame segments during a packet
 split rx
Date: Tue, 13 Sep 2011 06:50:03 -0400
Message-ID: <20110913105003.GA16222@hmsreliant.think-freely.org>
References: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51828 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab1IMKuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 06:50:14 -0400
Content-Disposition: inline
In-Reply-To: <1314972197-31557-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2011 at 10:03:17AM -0400, Neil Horman wrote:
> This oops was reported recently no ppc64 hardware:
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc0000000004dda0c
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=1024 NUMA pSeries
> Modules linked in: sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4
> iptable_fi
> lter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state
> nf_conntrack ip6table_filter ip6_tables ipv6 jsm ses enclosure sg ixgbe
> mdio e1000 ehea ext4 jbd2 mbcache sd_mod crc_t10dif ipr dm_mod
> NIP: c0000000004dda0c LR: c0000000004e3e50 CTR: c0000000004e3e20
> REGS: c0000001bffeb8d0 TRAP: 0300   Not tainted  (3.1.0-rc2-10121-gab7e2db)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28002042  XER: 20000000
> CFAR: c000000000004d70
> DAR: 0000000000000000, DSISR: 40000000
> TASK = c000000000d548e0[0] 'swapper' THREAD: c000000000dfc000 CPU: 0
> GPR04: c0000000010f4d80 c0000001bffebd80 0000000000000000 c0000001b18a8200
> GPR08: 0000000000000280 c0000001bcc517a8 c0000001b18a7f80 0000000000000000
> GPR12: d0000000047e5bb0 c000000001f10000 c0000001b19c8700 0000000000000000
> GPR16: c0000001bffebd80 0000000000000083 c00000018f2447a0 0000000000000002
> GPR20: 0000000000000000 c0000001ba860010 c0000001ba860000 d000000003d40000
> GPR24: 0000000000000000 0000000000000083 d000000003d40000 0000000000000001
> GPR28: c00000018f244780 c0000001b2b94310 c000000000da95f0 c0000001bcc51780
> NIP [c0000000004dda0c] .skb_gro_reset_offset+0x5c/0xe0
> LR [c0000000004e3e50] .napi_gro_receive+0x30/0x120
> Call Trace:
> [c0000001bffebb50] [c000000000da95f0] perf_callchain_user+0x0/0x10 (unreliable)
> [c0000001bffebbf0] [d0000000047bd118] .ixgbe_clean_rx_irq+0x7a8/0x8a0 [ixgbe]
> [c0000001bffebd10] [d0000000047bd414] .ixgbe_poll+0x64/0x160 [ixgbe]
> [c0000001bffebdd0] [c0000000004e3358] .net_rx_action+0x108/0x2a0
> [c0000001bffebea0] [c00000000009b220] .__do_softirq+0x110/0x2a0
> [c0000001bffebf90] [c000000000023798] .call_do_softirq+0x14/0x24
> [c000000000dff830] [c000000000011148] .do_softirq+0xf8/0x130
> [c000000000dff8d0] [c00000000009aeb4] .irq_exit+0xb4/0xc0
> [c000000000dff950] [c000000000011254] .do_IRQ+0xd4/0x300
> [c000000000dffa10] [c000000000005024] hardware_interrupt_entry+0x18/0x74
> --- Exception: 501 at .pseries_dedicated_idle_sleep+0xe4/0x210
> LR = .pseries_dedicated_idle_sleep+0x8c/0x210
> [c000000000dffd00] [c00000000005b194] .pseries_dedicated_idle_sleep+0x194/0x210
> (unreliable)
> [c000000000dffdc0] [c000000000018c84] .cpu_idle+0x164/0x210
> [c000000000dffe70] [c00000000000b0d0] .rest_init+0x90/0xb0
> [c000000000dffef0] [c000000000830bc0] .start_kernel+0x54c/0x56c
> [c000000000dfff90] [c00000000000953c] .start_here_common+0x1c/0x60
> 
> Its caused when skb_gro_reset_offset attempts to call PageHighMem on
> skb_shinfo(skb)->frags[0].page, when the frags array was left uninitalized.
> This can happen in the ixgbe driver if the hardware reports a zero length rx
> descriptor ni the middle of a packet split receive transaction.  I've consulted
> with Jesse Brandeburg on this, who is attempting to root cause the issue at
> Intel, but it seems prudent to add this check to the driver to discard frames of
> that encounter this error to avoid the opps
> 
Sorry, I need to rescind this patch.  Looks like this is turning out to be an
issue with an ideosyncracy in the dma hardware on this platform.

Thanks
Neil
