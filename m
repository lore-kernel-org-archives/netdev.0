From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in __skb_flow_get_ports
Date: Fri, 10 Oct 2014 08:14:19 -0700
Message-ID: <5437F7CB.5010101@redhat.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>	<20141010035840.21428.359.stgit@ahduyck-workstation.home> <20141010.004708.1975127853551765914.davem@davemloft.net> <5437F072.5060502@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbaJJPOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 11:14:25 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 07:57 AM, David Laight wrote:
> From: Alexander Duyck
>> On 10/09/2014 09:47 PM, David Miller wrote:
>>> From: alexander.duyck@gmail.com
>>> Date: Thu, 09 Oct 2014 21:03:28 -0700
>>>
>>>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>>>>
>>>> This patch addresses a kernel unaligned access bug seen on a sparc64 system
>>>> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
>>>> be32 pointer which was then having the value directly returned.
>>>>
>>>> In order to keep the handling of the ports consistent with how we were
>>>> handling the IPv4 and IPv6 addresses I have instead replaced the assignment
>>>> with a memcpy to the flow key ports value.  This way it should stay a
>>>> memcpy on systems that cannot handle unaligned access, and will likely be
>>>> converted to a 32b assignment on the systems that can support it.
>>>>
>>>> Reported-by: David S. Miller <davem@davemloft.net>
>>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>>> Guess what the compiler will output for the memcpy()....
>>>
>>> 	*(u32 *)dest = *(u32 *)src;
>>>
>>> Using memcpy() is never a valid way to avoid misaligned loads and
>>> stores.
>> If needed we could convert ports to a __be16 I suppose.
> You would have to cast it somewhere where the compiler cannot
> tell what the original type was.
> This usually means you have to call a non-static function, which
> might have to be in a different compilation unit.
>
> ...

The pointer itself gets assigned from skb->data + offset, since 
skb->data is an unsigned char I would think that it should be safe to 
cast it as a __be16 and have that stick.  It is only if we cast it as a 
__be32 that it should be an issue as we are casting a value that starts 
off only byte aligned.

>> That is what I get for trying to come up with a fix at the end of the
>> day.  Although it does leave me scratching my head why the IPv4 and IPv6
>> addresses were not causing unaligned accesses or were they triggering
>> them as well?
> I think there is code to copy the IP and TCP headers to aligned memory
> before they are parsed.
>
> ...

The code I am talking about is run before we actually get into the 
header parsing.  So for example if you take a look at 
iph_to_flow_copy_addrs that should be getting called before we even get 
to the code that is supposedly triggering this and it is doing 32b 
aligned accesses for the source and destination IP addresses.

>> The problem is the igb / ixgbe / fm10k hardware doesn't have a means of
>> inserting padding from its side...
> Shoot the hardware engineers.
>
> You aren't going to get the performance you expect from a 10Ge card
> unless the rx buffers are 'correctly' aligned.
>
> 	David
>

I think you might be coming to this a little late.  The igb and ixgbe 
drivers had been working this way for a long time.  We did a memcpy to 
move the headers from the page and into the skb->data at an aligned 
offset.  In order to determine the length to memcpy we had a function 
that could walk through the DMA aligned data to get the header length.  
The function for that was replaced with the __skb_flow_dissect as it was 
considered a duplication of code with the flow_dissection functions.  
However that is obviously not the case now that we are hitting these 
alignment issues.

The question I have in all this is do I push forward and make 
__skb_flow_dissect work with unaligned accesses, or do I back off and 
put something equivilent to igb/ixgbe_get_headlen functions in the 
kernel in order to deal with the unaligned accesses as they had no 
issues with them since they were only concerned with getting the header 
length and kept all accesses 16b aligned.

Thanks,

Alex
