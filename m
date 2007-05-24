From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Thu, 24 May 2007 09:25:33 -0500
Message-ID: <d79bd7b3b3b89b941e70abf73e684a7b@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com> <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com> <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com> <46558A48.9060403@roinet.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:47024 "EHLO
	ruth.realtime.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750699AbXEXO0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 10:26:30 -0400
In-Reply-To: <46558A48.9060403@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On May 24, 2007, at 7:51 AM, David Acker wrote:
> Milton Miller wrote:
>> Comments?  Questions?
> This sounds pretty reasonable.  I will take a stab at coding this up 
> today; I always think better looking at code.

Thanks.

By the way, find_mark_el should probably get passed
the old fill point.   The EL it will be clearing will
either be on that rx or the previous one (or there is
none for the initial alloc_list).

>> Do we need to continue with the stop-before-last plan?  As
>> long as we set size to 0 with EL, we shoud be able to change
>> the link, sync, set size 0, sync, and then set size.
> Perhaps not.  I can take a try at coding it without it.  It would 
> certainly make the driver easier to follow.
>
>> We still need the "advance at least 2 if not stopped" check when
>> deciding to move the EL.  This would break if the hardware
>> in the dma path can read the multiple cache lines of the
>> RFD out of order, so it may not be safe (if some pci host
>> decided to prefetch data, and got the second line ahead of
>> the first and didn't discard prefetch until pci bus
>> disconnect).  Actually, I am afraid I know hardware that
>> might do that.
> Hmm, me too.
>

I think we should be conservative here, and keep the stop
before the last and modify the last that we currently have.
I know the above prefetch hardware exists on a system that
can plug e100 cards.  While prefetching multiple lines is
based on the pci fetch code (read vs read line vs read
multiple), its just too close to failing.

The reason this behavior won't break us with the two packet
version is we always have written the unaligned (and hence
not atomic) write of the link field before we even expose
the RFD to the hardware.   Since data is aligned to two
bytes, the write to the EL bit and the write to length will
be atomic.  In addition, if the hardware reorders the loads
and gets length with EL, it will just RNR after filling
in the packet and we will handle it just fine.

Perhaps we should comment that we rely on 2 byte alignment,
in case some crazy architecture sets ETH_HDR_ALIGN to an
odd value.  (It's arch dependent to allow trade offs of
partial cache line writes from IO vs processing unaligned
TCP and IP headers by the cpu).  I wouldn't do BUG_ON
but wouldn't object to BUILD_BUG_ON if someone thinks
it's needed.

The difference is a additional pointer follow in the new
find_mark_el() from the new fill point to the mark point
(and the availability of one more RFD for a packet).
Either way we need to check its ->prev for being the
being current EL when hardware is not stopped.

milton

