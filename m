From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: eth_get_headlen() and unaligned accesses...
Date: Thu, 09 Oct 2014 20:10:01 -0700
Message-ID: <54374E09.1020907@redhat.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbaJJDKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2014 23:10:04 -0400
In-Reply-To: <20141009.201248.1210454965155680255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2014 05:12 PM, David Miller wrote:
> So, we have a bit of a problem, this is on sparc64:
>
> [423475.740836] Kernel unaligned access at TPC[81d330] __skb_flow_get_ports+0x70/0xe0
> [423475.755756] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.17.0+ #2
> [423475.767854] Call Trace:
> [423475.772877]  [0000000000433288] kernel_unaligned_trap+0x368/0x5c0
> [423475.785203]  [000000000042a824] sun4v_do_mna+0x84/0xa0
> [423475.795624]  [0000000000406cd0] sun4v_mna+0x5c/0x68
> [423475.805521]  [000000000081d330] __skb_flow_get_ports+0x70/0xe0
> [423475.817323]  [000000000081d6ac] __skb_flow_dissect+0x1ac/0x460
> [423475.829128]  [0000000000843c98] eth_get_headlen+0x38/0xa0
> [423475.840083]  [0000000010064d54] igb_poll+0x8d4/0xf60 [igb]
> [423475.851184]  [00000000008243c8] net_rx_action+0xa8/0x1c0
>
> The chip DMA's to the beginning of a frag page and (unless timestamps
> are enabled) that's where the ethernet header begins.
>
> So any larger than 16-bit access to the IP and later headers will be
> unaligned.
>
> We have various ways we can deal with this based upon the capabilities
> of the chips involved.  Can we configure the IGB to put 2 "don't care"
> bytes at the beginning of the packet?

The problem is the igb part expects to be able to use 2K buffers which 
means it will always try to use the full half of a page.  I had 
forgotten that the function this replaced had worked with unaligned 
accesses as all of the fields I was pulling were only 16b in width.  I 
think I assumed that this function was already setup to handle that.

Actually the fix should be pretty simple.  Just do what we already 
appear to be doing for the iph_to_flow_copy_addrs.  We can use memcpy to 
copy the 4 bytes for the port data instead of doing the direct assignment.

I'll try to submit a patch, just need to see if I have a tree setup as 
it has been a couple weeks.

Thanks,

Alex
