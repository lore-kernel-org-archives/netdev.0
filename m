From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: MAX_SKB_FRAGS and GRO
Date: Mon, 8 Feb 2010 09:35:19 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F12D7FA9DD7@orsmsx501.amr.corp.intel.com>
References: <20100208100306.GQ32246@kryten>
 <20100208124704.GA8538@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"divy@chelsio.com" <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33149 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab0BHRf5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 12:35:57 -0500
In-Reply-To: <20100208124704.GA8538@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Feb 08, 2010 at 09:03:07PM +1100, Anton Blanchard wrote:
>> 
>> I was looking through the hardware GRO support in various drivers
>> and I think we have a couple of issues with PAGE_SIZE > 4k. For
>> example, if we have a 64kB page size then MAX_SKB_FRAGS ends up as 3:
>> 
>> #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
>> 
>> This should be fine for hardware and software GSO, but we encounter
>> issues with hardware GRO (not sure about software GRO).
>> 
>> In the ixgbe case we use MAX_SKB_FRAGS to program the max number of
>> GRO descriptors, even though we assemble GRO packets using
>> ->frag_list: 
>> 
>> #if (MAX_SKB_FRAGS > 16)
>>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_16; #elif
>>                 (MAX_SKB_FRAGS > 8) rscctrl |=
>> IXGBE_RSCCTL_MAXDESC_8; #elif (MAX_SKB_FRAGS > 4)
>>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
>> #else
>>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
>> #endif
> 
> First of all this isn't GRO, but RSC.  With GRO we impose extra
> restrictions on what packets can be merged while RSC is more
> permissive.
> 
> In fact I think the ixgbe code may be broken as it is since it's
> not marking RSC packets in any way to prevent them from being
> forwarded through another interface.
> 
> As to your problem with RSC on a 64K page system, I'm sure one
> of the Intel developers would be able to help you out.
> 
>> Thinking out aloud, would setting a pessimistic value for
>> MAX_SKB_FRAGS 
>> be one way to fix this? ie:
>> 
>> #define MAX_SKB_FRAGS (65536/4096 + 2)
> 
> While I can't think of any serious issues with this, as this is
> an entirely ixgbe-specific problem, the fix should probably stay
> there.
> 
> Cheers,

Herbert is 100% correct, this is HW RSC and not GRO.

When we are using packet split mode we don't use the frag_list, we use frags and just append the buffers as pages.  This is why we use MAX_SKB_FRAGS to determine how many descriptors can be used for a single RSC receive.  The reason for doing it this way is because we can then hand it off to a process like GRO to join up to 3 frames together on systems with 64K pages.

In regards to the bridging/forwarding issue I don't think there is a problem there since we use the LRO flag to determine if HW RSC can be enabled and so typically if you put the port into a forwarding/bridging state HW RSC is automatically disabled.  I will recommend that our validation team double check that though.

If you are running in single buffer mode, which is the mode that uses the frag_list, then you can join up to 16 descriptors as I recall.  However we must avoid joining enough descriptors to result in 64K or more bytes per frame so usually we end up getting a max of 32K per RSC context simply due to the fact that everything is based on powers of 2.

Thanks,

Alex