From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Wed, 14 Jan 2009 16:03:10 -0800
Message-ID: <9929d2390901141603s65cd27a3y732c5058de9145c8@mail.gmail.com>
References: <9929d2390901140349v4483bd23wac254673de591bec@mail.gmail.com>
	 <20090114123653.GA19257@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Emil Tantilov" <emil.s.tantilov@intel.com>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.185]:54339 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761293AbZAOADM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 19:03:12 -0500
Received: by rn-out-0910.google.com with SMTP id k40so698252rnd.17
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 16:03:10 -0800 (PST)
In-Reply-To: <20090114123653.GA19257@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 4:36 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>>
>> Ok, a couple of things...
>> First is that we should have the patch in testing (most likely today,
>> do not worry dave, it won't take a week)
>
> Thanks!
>
>> Second is I am not sure you need to keep this code wraped in CONFIG_IGB_LRO...
>>
>>  #ifdef CONFIG_IGB_LRO
>> -       netdev->features |= NETIF_F_LRO;
>> +       netdev->features |= NETIF_F_GRO;
>>  #endif
>
> My objective is to minimise changes with respect to the current
> LRO base (the e1000e was an exception, it was the only hardware
> I had :)
>
> Therefore this patch is simply trying to replace LRO with GRO
> letter by letter, so to speak.  In this case, it's preserving
> the semantics of the Kconfig option, i.e., if LRO was off before,
> then GRO will be off too (although it can now be enabled using
> ethtool without recompiling).
>
>> Also, you left part of the lro code in igb_receive_skb and then put in
>> the GRO code.  Our preference is that you mirrored what you did with
>> e1000e and just replaced the main vlan_hwacel and netif_receive_skb
>> calls.
>
> No I left in the netif_receive_skb but replaced the lro calls by
> the corresponding gro calls.  Again the point is to replace LRO
> exactly as it is.
>
> Later on we can make further changes.
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --

We are seeing a kernel panic during our testing using jumbo frames,
below is the trace.

BUG: Bad page state in process swapper  pfn:1194ff
page:ffffe200060b37a8 flags:8000000000000000 count:-1 mapcount:0
mapping:(null) index:0
Pid: 0, comm: swapper Tainted: G        W  2.6.29-rc1-net-2.6-igb_gro #1
Call Trace:
 <IRQ>  [<ffffffff80283e5e>] bad_page+0x105/0x11c
[<ffffffff8028489f>] prep_new_page+0x4d/0xb2  [<ffffffff80284ae1>]
buffered_rmqueue+0x1dd/0x243  [<ffffffff80284bfb>]
get_page_from_freelist+0xb4/0xef  [<ffffffff80284ec6>]
__alloc_pages_internal+0xa1/0x38f  [<ffffffff8036ad24>]
address_needs_mapping+0xd/0x1e  [<ffffffff8036ad4c>]
range_needs_mapping+0x17/0x21  [<ffffffffa0072a45>]
igb_alloc_rx_buffers_adv+0x6a/0x1bc [igb]  [<ffffffff804cdf06>]
dev_gro_receive+0x43/0x24f  [<ffffffffa0073a5c>]
igb_clean_rx_irq_adv+0x306/0x34b [igb]  [<ffffffff80559baf>]
_spin_unlock_irqrestore+0x63/0x74  [<ffffffffa0074df8>]
igb_clean_rx_ring_msix+0x4a/0xca [igb]  [<ffffffff804d0750>]
net_rx_action+0xa0/0x14f  [<ffffffff80244d6a>] __do_softirq+0x7b/0x116
 [<ffffffff8020cb3c>] call_softirq+0x1c/0x28  [<ffffffff8020de92>]
do_softirq+0x31/0x83  [<ffffffff80244c47>] irq_exit+0x45/0x87
[<ffffffff8020de4b>] do_IRQ+0xa5/0xbb  [<ffffffff8020c353>]
ret_from_intr+0x0/0xf  <EOI> <1>BUG: Bad page state in process swapper
 pfn:12c8f4 page:ffffe200067513e0 flags:8000000000000000 count:-1
mapcount:0 mapping:(null) index:6
Pid: 0, comm: swapper Tainted: G    B   W  2.6.29-rc1-net-2.6-igb_gro #1
Call Trace:
 <IRQ>  [<ffffffff80283e5e>] bad_page+0x105/0x11c
[<ffffffff8028489f>] prep_new_page+0x4d/0xb2  [<ffffffff80284ae1>]
buffered_rmqueue+0x1dd/0x243  [<ffffffff80284bfb>]
get_page_from_freelist+0xb4/0xef  [<ffffffff80284ec6>]
__alloc_pages_internal+0xa1/0x38f  [<ffffffff8036ad24>]
address_needs_mapping+0xd/0x1e  [<ffffffff8036ad4c>]
range_needs_mapping+0x17/0x21  [<ffffffffa0072a45>]
igb_alloc_rx_buffers_adv+0x6a/0x1bc [igb]  [<ffffffff804cdf06>]
dev_gro_receive+0x43/0x24f  [<ffffffffa0073a5c>]
igb_clean_rx_irq_adv+0x306/0x34b [igb]  [<ffffffff80559baf>]
_spin_unlock_irqrestore+0x63/0x74  [<ffffffffa0074df8>]
igb_clean_rx_ring_msix+0x4a/0xca [igb]  [<ffffffff804d0750>]
net_rx_action+0xa0/0x14f  [<ffffffff80244d6a>] __do_softirq+0x7b/0x116
 [<ffffffff8020cb3c>] call_softirq+0x1c/0x28  [<ffffffff8020de92>]
do_softirq+0x31/0x83  [<ffffffff80244c47>] irq_exit+0x45/0x87
[<ffffffff8020de4b>] do_IRQ+0xa5/0xbb  [<ffffffff8020c353>]
ret_from_intr+0x0/0xf  <EOI> <1>BUG: Bad page state in process swapper
 pfn:12999c page:ffffe2000664cda0 flags:8000000000000000 count:-1
mapcount:0 mapping:(null) index:0
Pid: 0, comm: swapper Tainted: G    B   W  2.6.29-rc1-net-2.6-igb_gro #1
Call Trace:
 <IRQ>  [<ffffffff80283e5e>] bad_page+0x105/0x11c
[<ffffffff8028489f>] prep_new_page+0x4d/0xb2  [<ffffffff80284ae1>]
buffered_rmqueue+0x1dd/0x243  [<ffffffff80284bfb>]
get_page_from_freelist+0xb4/0xef  [<ffffffff80284ec6>]
__alloc_pages_internal+0xa1/0x38f  [<ffffffff8036ad24>]
address_needs_mapping+0xd/0x1e  [<ffffffff8036ad4c>]
range_needs_mapping+0x17/0x21  [<ffffffffa0072a45>]
igb_alloc_rx_buffers_adv+0x6a/0x1bc [igb]  [<ffffffff804cdf06>]
dev_gro_receive+0x43/0x24f  [<ffffffffa0073a5c>]
igb_clean_rx_irq_adv+0x306/0x34b [igb]  [<ffffffff80559baf>]
_spin_unlock_irqrestore+0x63/0x74  [<ffffffffa0074df8>]
igb_clean_rx_ring_msix+0x4a/0xca [igb]  [<ffffffff804d0750>]
net_rx_action+0xa0/0x14f  [<ffffffff80244d6a>] __do_softirq+0x7b/0x116
 [<ffffffff8020cb3c>] call_softirq+0x1c/0x28  [<ffffffff8020de92>]
do_softirq+0x31/0x83  [<ffffffff80244c47>] irq_exit+0x45/0x87
[<ffffffff8020de4b>] do_IRQ+0xa5/0xbb  [<ffffffff8020c353>]
ret_from_intr+0x0/0xf  <EOI>

I have added Emil to mail thread, he can give additional testing
details, if necessary.

-- 
Cheers,
Jeff
