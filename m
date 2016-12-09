From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [Intel-wired-lan] [RFC PATCH] i40e: enable PCIe relax ordering
 for SPARC
Date: Thu, 8 Dec 2016 16:45:35 -0800
Message-ID: <fc3fc99a-ff53-d895-ec06-56f9cf8a0d13@oracle.com>
References: <1480957627-16825-1-git-send-email-tushar.n.dave@oracle.com>
 <CAKgT0UcyRSub0NCi7oHX2Vf+N4vQxzwdWmcc+V+jOX_J=RYgfg@mail.gmail.com>
 <ec140d5d-3eec-5fc6-6417-11bacc55b807@oracle.com>
 <CAKgT0UfTP+BrvDBzUJAVr9-DRCKgM7T3aS=LgRic8UZz8x82eg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02382BD@AcuExch.aculab.com>
 <CAKgT0Uf3aZBoziv7B0tFMovYe9JNWEYZAZhe9iof2XcuRJD+uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25710 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932300AbcLIArD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 19:47:03 -0500
In-Reply-To: <CAKgT0Uf3aZBoziv7B0tFMovYe9JNWEYZAZhe9iof2XcuRJD+uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/08/2016 08:05 AM, Alexander Duyck wrote:
> On Thu, Dec 8, 2016 at 2:43 AM, David Laight
> <David.Laight@aculab.com> wrote:
>> From: Alexander Duyck
>>> Sent: 06 December 2016 17:10
>> ...
>>> I was thinking about it and I realized we can probably simplify
>>> this even further.  In the case of most other architectures the
>>> DMA_ATTR_WEAK_ORDERING has no effect anyway.  So from what I can
>>> tell there is probably no reason not to just always pass that
>>> attribute with the DMA mappings.  From what I can tell the only
>>> other architecture that uses this is the PowerPC Cell
>>> architecture.
>>
>> And I should have read all the thread :-(
>>
>>> Also I was wondering if you actually needed to enable this
>>> attribute for both Rx and Tx buffers or just Rx buffers?  The
>>> patch that enabled DMA_ATTR_WEAK_ORDERING for Sparc64 seems to
>>> call out writes, but I didn't see anything about reads.  I'm just
>>> wondering if changing the code for Tx has any effect?  If not you
>>> could probably drop those changes and just focus on Rx.
>>
>> 'Weak ordering' only applies to PCIe read transfers, so can only
>> have an effect on descriptor reads and transmit buffer reads.
>>
>> Basically PCIe is a comms protocol and an endpoint (or the host)
>> can have multiple outstanding read requests (each of which might
>> generate multiple response messages. The responses for each request
>> must arrive in order, but responses for different requests can be
>> interleaved. Setting 'not weak ordering' lets the host interwork
>> with broken endpoints. (Or, like we did, you fix the fpga's PCIe
>> implementation.)
>
> I get the basics of relaxed ordering.  The question is how does the
> Sparc64 IOMMU translate DMA_ATTR_WEAK_ORDERING into relaxed ordering
> messages, and at what level the ordering is relaxed.  Odds are the
> wording in the description where this attribute was added to Sparc
> is just awkward, but I was wanting to verify if this only applies to
> writes, or also read completions.
In Sparc64, passing DMA_ATTR_WEAK_ORDERING in dma map/unmap only affects 
PCIe root complex (Hostbridge). Using DMA_ATTR_WEAK_ORDERING, requested 
DMA transaction can be relaxed ordered within the PCIe root complex.

In Sparc64, memory writes can be held at PCIe root complex not letting
other memory writes to go through. By passing DMA_ATTR_WEAK_ORDERING in
dma map/unmap allows memory writes to bypass other memory writes in PCIe
root complex. (This applies to only PCIe root complex and does not 
affect at any other level of PCIe hierarchy e.g. PCIe bridges et al. 
Also the PCIe root complex when bypassing memory writes does follow PCIe 
relax ordering rules as per PCIe specification.

For reference [old but still relevant write-up]: PCI-Express Relaxed 
Ordering and the Sun SPARC Enterprise M-class Servers
https://blogs.oracle.com/olympus/entry/relaxed_ordering

>
>> In this case you need the reads of both transmit and receive rings
>> to 'overtake' reads of transmit data.
>
> Actually that isn't quite right.  With relaxed ordering completions
> and writes can pass each other if I recall correctly, but reads will
> always force all writes ahead of them to be completed before you can
> begin generating the read completions.
That is my understanding as well.

>
>> I'm not at all clear how this 'flag' can be set on dma_map(). It is
>> a property of the PCIe subsystem.
Because in Sparc64, passing DMA_ATTR_WEAK_ORDERING flag in DMA map/unmap 
adds an entry in IOMMU/ATU table so that an access to requested DMA 
address from PCIe root complex can be relaxed ordered.
>
> That was where my original question on this came in.  We can do a
> blanket enable of relaxed ordering for Tx and Rx data buffers, but
> if we only need it on Rx then there isn't any need for us to make
> unnecessary changes.
I ran some quick test and it is likely that we don't need
DMA_ATTR_WEAK_ORDERING for any TX dma buffer (because in case of TX dma
buffers, its all memory reads from device).

-Tushar
>
> - Alex
>
