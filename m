From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: ixgbe warning
Date: Wed, 23 Dec 2009 00:15:42 -0800
Message-ID: <4B31D1AE.3090500@kernel.org>
References: <86802c440912222100j1c23f3d9xfb734a6e52fa2ec9@mail.gmail.com> <OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, NetDev <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:54709 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952AbZLWIRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 03:17:05 -0500
In-Reply-To: <OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 wrote:
>> Yinghai Lu <yinghai@kernel.org>
>>
>> [  809.824721] WARNING: at net/core/dev.c:1908
> dev_queue_xmit+0x243/0x4c7()
>> [  809.832183] Hardware name: Sun
>> [  809.832193] eth16 selects TX queue 98, but real number of TX queues is
> 64
>> [  809.832203] Modules linked in:
>> [  809.832216] Pid: 26440, comm: iperf Not tainted
>> 2.6.33-rc1-tip-yh-00304-g97a015d-dirty #1007
>> [  809.832221] Call Trace:
>> [  809.832232]  <IRQ>  [<ffffffff81c14e08>] ? dev_queue_xmit+0x243/0x4c7
>> [  809.832266]  [<ffffffff8107a098>] warn_slowpath_common+0x7c/0xa9
>> [  809.832283]  [<ffffffff8107a11c>] warn_slowpath_fmt+0x41/0x43
>> [  809.832300]  [<ffffffff81c14e08>] dev_queue_xmit+0x243/0x4c7
>> [  809.832319]  [<ffffffff81c14d5a>] ? dev_queue_xmit+0x195/0x4c7
>> [  809.832340]  [<ffffffff81c52e87>] arp_send+0x39/0x3b
>> [  809.832355]  [<ffffffff81c5384c>] arp_solicit+0x1da/0x1f7
>> [  809.832376]  [<ffffffff81c1d89d>] neigh_timer_handler+0x243/0x292
>> [  809.832391]  [<ffffffff81c1d65a>] ? neigh_timer_handler+0x0/0x292
>> [  809.832411]  [<ffffffff8108844b>] run_timer_softirq+0x265/0x322
>> [  809.832429]  [<ffffffff810883af>] ? run_timer_softirq+0x1c9/0x322
>> [  809.832448]  [<ffffffff81098bd3>] ? __run_hrtimer+0x104/0x132
>> [  809.832471]  [<ffffffff81080909>] __do_softirq+0xee/0x1b9
>> [  809.832488]  [<ffffffff81034a8c>] call_softirq+0x1c/0x3e
>> [  809.832499]  [<ffffffff810360e9>] do_softirq+0x3d/0x85
>> [  809.832516]  [<ffffffff81080492>] irq_exit+0x4a/0x89
>> [  809.832536]  [<ffffffff81d37afb>] smp_apic_timer_interrupt+0x8d/0x9b
>> [  809.832557]  [<ffffffff81034553>] apic_timer_interrupt+0x13/0x20
>> [  809.832563]  <EOI>  [<ffffffff81068e41>] ? walk_tg_tree+0x0/0xe3
>> [  809.832594]  [<ffffffff810a6f29>] ? trace_hardirqs_on+0xd/0xf
>> [  809.832616]  [<ffffffff81d32759>] ? _raw_spin_unlock_irq+0x33/0x36
>> [  809.832634]  [<ffffffff81d2fc12>] schedule+0x7a2/0x83d
>> [  809.832649]  [<ffffffff81d32756>] ? _raw_spin_unlock_irq+0x30/0x36
>> [  809.832666]  [<ffffffff81d31b97>] __down_read+0x97/0xc4
>> [  809.832674]  [<ffffffff81d311c7>] down_read+0x6d/0x81
>> [  809.832684]  [<ffffffff81d3539e>] ? do_page_fault+0x1bb/0x31d
>> [  809.832699]  [<ffffffff81d3539e>] do_page_fault+0x1bb/0x31d
>> [  809.832716]  [<ffffffff81d32c7f>] page_fault+0x1f/0x30
>> [  809.832726] ---[ end trace 9c325e35daa3e5c8 ]---
> 
> I guess you are running on a big SMP system? If so,
> ixgbe_select_queue() is not limiting the queue_index
> based on real_num_tx_queues, and possibly returning
> a bad txq from:
> 
>       if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
>             return txq;
> 
> Also, I was looking at other providers of select_queue and found:
> 
> u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb)
> {
>         return skb_get_queue_mapping(skb);
> }
> 
> How can this be correct (driver supports upto 8 txq's). Unless txq=0 for
> xmits of all locally
> generated packets is fine.

may need this one...

---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/ixgbe/ixgbe_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgbe/ixgbe_main.c
+++ linux-2.6/drivers/net/ixgbe/ixgbe_main.c
@@ -5317,7 +5317,7 @@ static int ixgbe_maybe_stop_tx(struct ne
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int txq = smp_processor_id();
+	int txq = smp_processor_id() % adapter->num_tx_queues;
 
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 		return txq;
