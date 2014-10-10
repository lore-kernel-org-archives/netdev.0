From: David Miller <davem@davemloft.net>
Subject: Re: eth_get_headlen() and unaligned accesses...
Date: Fri, 10 Oct 2014 00:43:16 -0400 (EDT)
Message-ID: <20141010.004316.2276717749634684299.davem@davemloft.net>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	<54374E09.1020907@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbaJJEnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:43:18 -0400
In-Reply-To: <54374E09.1020907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Thu, 09 Oct 2014 20:10:01 -0700

> On 10/09/2014 05:12 PM, David Miller wrote:
>> So, we have a bit of a problem, this is on sparc64:
>>
>> [423475.740836] Kernel unaligned access at TPC[81d330]
>> __skb_flow_get_ports+0x70/0xe0
>> [423475.755756] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.17.0+ #2
>> [423475.767854] Call Trace:
>> [423475.772877]  [0000000000433288] kernel_unaligned_trap+0x368/0x5c0
>> [423475.785203]  [000000000042a824] sun4v_do_mna+0x84/0xa0
>> [423475.795624]  [0000000000406cd0] sun4v_mna+0x5c/0x68
>> [423475.805521]  [000000000081d330] __skb_flow_get_ports+0x70/0xe0
>> [423475.817323]  [000000000081d6ac] __skb_flow_dissect+0x1ac/0x460
>> [423475.829128]  [0000000000843c98] eth_get_headlen+0x38/0xa0
>> [423475.840083]  [0000000010064d54] igb_poll+0x8d4/0xf60 [igb]
>> [423475.851184]  [00000000008243c8] net_rx_action+0xa8/0x1c0
>>
>> The chip DMA's to the beginning of a frag page and (unless timestamps
>> are enabled) that's where the ethernet header begins.
>>
>> So any larger than 16-bit access to the IP and later headers will be
>> unaligned.
>>
>> We have various ways we can deal with this based upon the capabilities
>> of the chips involved.  Can we configure the IGB to put 2 "don't care"
>> bytes at the beginning of the packet?
> 
> The problem is the igb part expects to be able to use 2K buffers which
> means it will always try to use the full half of a page.

Let me try to ask this again.

Can you configure the MAC to put two garbage bytes at the head of
the packet data as it feeds it into the DMA fifos on the IGB chip?

This is an essential (again: _essential_) feature for chips that
manage RX buffers as power-of-2 chunks of pages, as it is the only
cheap way to get the IP headers 32-bit aligned in those power-of-2 DMA
buffer blocks.

That would solve the whole problem.
