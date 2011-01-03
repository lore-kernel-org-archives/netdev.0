From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 03 Jan 2011 13:45:25 -0800
Message-ID: <4D224375.2040208@intel.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>	 <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>	 <20110103.110244.183045594.davem@davemloft.net>	 <1294083039.3167.184.camel@localhost>  <4D2228E0.9030908@intel.com> <1294085724.3167.202.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50658 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861Ab1ACVpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 16:45:46 -0500
In-Reply-To: <1294085724.3167.202.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/3/2011 12:15 PM, Ben Hutchings wrote:
> On Mon, 2011-01-03 at 11:52 -0800, Alexander Duyck wrote:
>> On 1/3/2011 11:30 AM, Ben Hutchings wrote:
>>> On Mon, 2011-01-03 at 11:02 -0800, David Miller wrote:
>>>> From: Tom Herbert<therbert@google.com>
>>>> Date: Mon, 3 Jan 2011 10:47:20 -0800
>>>>
>>>>> I'm not sure why this would be needed.  What is the a advantage in
>>>>> making the TX and RX queues match?
>>>>
>>>> That's how their hardware based RFS essentially works.
>>>>
>>>> Instead of watching for "I/O system calls" like we do in software, the
>>>> chip watches for which TX queue a flow ends up on and matches things
>>>> up on the receive side with the same numbered RX queue to match.
>>>
>>> ixgbe also implements IRQ affinity setting (or rather hinting) and TX
>>> queue selection by CPU, the inverse of IRQ affinity setting.  Together
>>> with the hardware/firmware Flow Director feature, this should indeed
>>> result in hardware RFS.  (However, irqbalanced does not yet follow the
>>> affinity hints AFAIK, so this requires some manual intervention.  Maybe
>>> the OOT driver is different?)
>>>
>>> The proposed change to make TX queue selection hash-based seems to be a
>>> step backwards.
>>>
>>> Ben.
>>>
>>
>> Actually this code would only be applied in the case where Flow Director
>> didn't apply such as non-TCP frames.  It would essentially guarantee
>> that we end up with TX/RX on the same CPU for all cases instead of just
>> when Flow Director matches a given flow.
>
> The code you posted doesn't seem to implement that, though.

Actually it does, it only takes effect in the case that flow director 
isn't enabled.  I just implemented it as a ndo_select_queue and then in 
the case of the igb example I applied it directly, and in the case of 
the ixgbe example I just added it to the end of the ndo_select_queue 
function that it already had.

>
>> The general idea is to at least keep the traffic local to one TX/RX
>> queue pair so that if we cannot match the queue pair to the application,
>> perhaps the application can be affinitized to match up with the queue
>> pair.  Otherwise we end up with traffic getting routed to one TX queue
>> on one CPU, and the RX being routed to another queue on perhaps a
>> different CPU and it becomes quite difficult to match up the queues and
>> the applications.
>
> Right.  That certainly seems like a Good Thing, though I believe it can
> be implemented generically by recording the RX queue number on the
> socket:
>
> http://article.gmane.org/gmane.linux.network/158477

That was one of the reasons why I put this chunk of code out there as an 
RFC as I didn't see anywhere where it really fit in.  I wasn't sure if 
anyone had a use for it or not, but I didn't see much point in keeping 
it to myself and so I submitted as an RFC to see if anyone had any interest.

>> Since the approach is based on Toeplitz it can be applied to all
>> hardware capable of generating a Toeplitz based hash and as a result it
>> would likely also work in a much more vendor neutral kind of way than
>> Flow Director currently does.
>
> Which I appreciate, but I'm not convinced that weakening Toeplitz is a
> good way to do it.
>
> I understand that Robert Watson (FreeBSD hacker) has been doing some
> research on the security and performance implications of flow hashing
> algorithms, though I haven't seen any results of that yet.
>
> Ben.
>

I wasn't really sure about it either, but from what I can tell Toeplitz 
is pretty weak in the first place, especially if using a static key, but 
really hard to do efficiently in software with a full 40 byte key.

The advantages of the 16 bit key were that I could do the hash 
computation with little CPU overhead and then I also was able to 
generate the symmetric hash result so I didn't have to mess with source 
and destination field ordering to generate the TX hash.  Since most of 
the hardware I am familiar with doesn't support more than 128 queues 
anyway the 16 bit hash input and result generated via this approach 
should be more than enough to handle the queue selection and 
distribution needs of the hardware which was my only real concern.

Thanks for the input,

Alex




