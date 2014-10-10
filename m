From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 13:55:10 -0400 (EDT)
Message-ID: <20141010.135510.284932227690786117.davem@davemloft.net>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	<20141010145647.23006.54451.stgit@ahduyck-workstation.home>
	<1412955376.9362.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbaJJRzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:55:14 -0400
In-Reply-To: <1412955376.9362.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Oct 2014 08:36:16 -0700

> On Fri, 2014-10-10 at 07:59 -0700, alexander.duyck@gmail.com wrote:
>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>> 
>> This patch addresses a kernel unaligned access bug seen on a sparc64 system
>> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
>> be32 pointer which was then having the value directly returned.
>> 
>> In order to keep the handling of the ports consistent with how we were
>> handling the IPv4 and IPv6 addresses I have instead replaced the assignment
>> with a memcpy to the flow key ports value.  This way it should stay a
>> memcpy on systems that cannot handle unaligned access, and will likely be
>> converted to a 32b assignment on the systems that can support it.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
> 
> I believe you also need to take care of calls to ipv6_addr_hash()
> 
> The IPv4 part also needs something in iph_to_flow_copy_addrs(),
> otherwise compiler might assume  &iph->saddr is word aligned.

Right, I still get the unaligned accesses even with this patch:

[487667.804777] Kernel unaligned access at TPC[81de40] __skb_get_poff+0xa0/0x100
[487667.818767] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.17.0+ #3
[487667.830930] Call Trace:
[487667.835954]  [0000000000433288] kernel_unaligned_trap+0x368/0x5c0
[487667.848276]  [000000000042a824] sun4v_do_mna+0x84/0xa0
[487667.858698]  [0000000000406cd0] sun4v_mna+0x5c/0x68
[487667.868592]  [000000000081de40] __skb_get_poff+0xa0/0x100
[487667.879531]  [0000000000843d2c] eth_get_headlen+0x6c/0xa0
[487667.890486]  [000000001003ed54] igb_poll+0x8d4/0xf60 [igb]
[487667.901584]  [0000000000824428] net_rx_action+0xa8/0x1c0
[487667.912348]  [000000000046a1fc] __do_softirq+0xdc/0x2e0
[487667.922932]  [000000000042b96c] do_softirq_own_stack+0x2c/0x40
[487667.934751]  [000000000046a6b8] irq_exit+0x98/0xc0
[487667.944473]  [000000000042b900] handler_irq+0xc0/0x100
[487667.954888]  [00000000004208b4] tl0_irq5+0x14/0x20
[487667.964610]  [000000000042c0d4] arch_cpu_idle+0x74/0xa0
[487667.975201]  [0000000000499cdc] cpu_startup_entry+0x17c/0x2c0
[487667.986843]  [0000000000ab69b8] start_kernel+0x408/0x418
[487667.997603]  [00000000008c3628] tlb_fixup_done+0x98/0xb0
